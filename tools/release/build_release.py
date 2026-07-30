#!/usr/bin/env python3
"""Build and verify the deterministic MiniSQL 1.0.0 binary distribution."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
import sys
import zipfile
from pathlib import Path, PurePosixPath
from typing import Iterable, Sequence

VERSION = "1.0.0"
ROOT_NAME = f"MiniSQL-{VERSION}"
FIXED_TIME = (2026, 7, 29, 0, 0, 0)
REQUIRED_BINARIES = (
    "minisqld.exe",
    "minisql.exe",
    "minisql-check.exe",
    "minisql-backup.exe",
    "minisql-migrate.exe",
)


class ReleaseError(RuntimeError):
    pass


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read(path: Path) -> bytes:
    if not path.is_file() or path.stat().st_size == 0:
        raise ReleaseError(f"required non-empty release input is missing: {path}")
    return path.read_bytes()


def source_files(project: Path, bin_dir: Path) -> dict[str, bytes]:
    files: dict[str, bytes] = {}
    for name in REQUIRED_BINARIES:
        files[f"bin/{name}"] = read(bin_dir / name)
    mapping = {
        "README.md": project / "docs/release/README.md",
        "NOTICE.md": project / "NOTICE.md",
        "CHANGELOG.md": project / "CHANGELOG.md",
        "config/minisql.example.json": project / "config/minisql.example.json",
        "config/config.schema.json": project / "config/config.schema.json",
        "docs/QUICKSTART.md": project / "docs/quickstart-client-server.md",
        "docs/SQL_REFERENCE.md": project / "docs/release/SQL_REFERENCE.md",
        "docs/ADMIN_GUIDE.md": project / "docs/release/ADMIN_GUIDE.md",
        "docs/SECURITY_GUIDE.md": project / "docs/release/SECURITY_GUIDE.md",
        "docs/BACKUP_RECOVERY.md": project / "docs/release/BACKUP_RECOVERY.md",
        "docs/REPLICATION.md": project / "docs/release/REPLICATION.md",
        "docs/LIMITATIONS.md": project / "docs/release/LIMITATIONS.md",
        "docs/UPGRADE.md": project / "docs/release/UPGRADE.md",
        "docs/upgrade-matrix.json": project / "docs/release/upgrade-matrix.json",
        "docs/feature-matrix.json": project / "docs/release/feature-matrix.json",
        "tools/minisql_tls_proxy.py": project / "tools/tls/minisql_tls_proxy.py",
        "tools/minisql_hot_replica.py": project / "tools/replication/minisql_hot_replica.py",
    }
    for target, source in mapping.items():
        files[target] = read(source)
    return files


def manifest(files: dict[str, bytes]) -> dict[str, object]:
    return {
        "manifestVersion": 1,
        "product": "MiniSQL",
        "version": VERSION,
        "milestone": "M50",
        "databaseFormatVersion": 1,
        "wireProtocolVersion": 1,
        "platform": "windows-x64",
        "pythonSidecars": ["TLS 1.3/X.509", "continuous hot replication"],
        "files": [
            {"path": path, "bytes": len(data), "sha256": sha256(data)}
            for path, data in sorted(files.items())
        ],
    }


def checksums(files: dict[str, bytes]) -> bytes:
    lines = [f"{sha256(data)}  {path}" for path, data in sorted(files.items())]
    return ("\n".join(lines) + "\n").encode("utf-8")


def zip_info(name: str, executable: bool = False) -> zipfile.ZipInfo:
    info = zipfile.ZipInfo(f"{ROOT_NAME}/{name}", FIXED_TIME)
    info.create_system = 3
    mode = 0o755 if executable else 0o644
    info.external_attr = (stat.S_IFREG | mode) << 16
    info.compress_type = zipfile.ZIP_DEFLATED
    return info


def build(project: Path, bin_dir: Path, output: Path) -> None:
    files = source_files(project, bin_dir)
    manifest_bytes = (json.dumps(manifest(files), indent=2, sort_keys=True) + "\n").encode("utf-8")
    files["release-manifest.json"] = manifest_bytes
    files["SHA256SUMS"] = checksums(files)
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(output.suffix + ".new")
    if temporary.exists():
        temporary.unlink()
    with zipfile.ZipFile(temporary, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for path, data in sorted(files.items()):
            executable = path.startswith("bin/") or path.startswith("tools/")
            archive.writestr(zip_info(path, executable), data)
    os.replace(temporary, output)
    verify(output)
    digest_path = output.with_suffix(output.suffix + ".sha256")
    digest_path.write_text(f"{sha256(output.read_bytes())}  {output.name}\n", encoding="ascii")
    print(f"MiniSQL 1.0.0 release build: SUCCESS path={output} files={len(files)}")


def safe_member(name: str) -> PurePosixPath:
    path = PurePosixPath(name)
    if path.is_absolute() or ".." in path.parts or not path.parts or path.parts[0] != ROOT_NAME:
        raise ReleaseError(f"unsafe release member: {name}")
    return path


def verify(output: Path) -> None:
    if not output.is_file():
        raise ReleaseError(f"release archive is missing: {output}")
    with zipfile.ZipFile(output, "r") as archive:
        bad = archive.testzip()
        if bad is not None:
            raise ReleaseError(f"release ZIP CRC failure: {bad}")
        names = archive.namelist()
        if len(names) != len(set(names)):
            raise ReleaseError("release ZIP contains duplicate members")
        for name in names:
            safe_member(name)
        prefix = ROOT_NAME + "/"
        payloads = {name[len(prefix):]: archive.read(name) for name in names}
    for binary in REQUIRED_BINARIES:
        if f"bin/{binary}" not in payloads or len(payloads[f"bin/{binary}"]) < 1024:
            raise ReleaseError(f"release binary is missing or implausibly small: {binary}")
    if "release-manifest.json" not in payloads or "SHA256SUMS" not in payloads:
        raise ReleaseError("release metadata is incomplete")
    document = json.loads(payloads["release-manifest.json"].decode("utf-8"))
    if document.get("version") != VERSION or document.get("milestone") != "M50":
        raise ReleaseError("release manifest version mismatch")
    expected = {}
    for line in payloads["SHA256SUMS"].decode("ascii").splitlines():
        digest, path = line.split("  ", 1)
        expected[path] = digest
    for path, digest in expected.items():
        if path not in payloads:
            raise ReleaseError(f"checksum references missing file: {path}")
        if sha256(payloads[path]) != digest:
            raise ReleaseError(f"checksum mismatch: {path}")
    if "SHA256SUMS" in expected:
        raise ReleaseError("SHA256SUMS must not recursively checksum itself")
    manifest_files = document.get("files")
    if not isinstance(manifest_files, list):
        raise ReleaseError("release manifest file list is invalid")
    for item in manifest_files:
        path = item.get("path")
        if path not in payloads or item.get("sha256") != sha256(payloads[path]) or item.get("bytes") != len(payloads[path]):
            raise ReleaseError(f"release manifest entry mismatch: {path}")
    print(f"MiniSQL 1.0.0 release verify: SUCCESS files={len(payloads)}")


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(description=__doc__)
    sub = root.add_subparsers(dest="mode", required=True)
    build_parser = sub.add_parser("build")
    build_parser.add_argument("--project", required=True)
    build_parser.add_argument("--bin-dir", required=True)
    build_parser.add_argument("--output", required=True)
    verify_parser = sub.add_parser("verify")
    verify_parser.add_argument("--archive", required=True)
    return root


def main(argv: Sequence[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        if args.mode == "build":
            build(Path(args.project).resolve(), Path(args.bin_dir).resolve(), Path(args.output).resolve())
            return 0
        if args.mode == "verify":
            verify(Path(args.archive).resolve())
            return 0
        raise ReleaseError(f"unknown mode: {args.mode}")
    except (ReleaseError, OSError, zipfile.BadZipFile, json.JSONDecodeError) as exc:
        print(f"MiniSQL release gate: FAIL {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
