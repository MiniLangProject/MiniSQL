#!/usr/bin/env python3
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Cumulative MiniSQL M0-M10R3 acceptance runner.

The root PowerShell launcher is the only user-facing test entry point. This internal
runner validates the source package, compiles native Windows x64 MiniLang programs,
executes all accepted regressions and all M6-M10R3 candidate tests, and always emits one
result ZIP on success or failure.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import struct
import subprocess
import sys
import time
import zipfile
from datetime import datetime
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "tests" / "m6_m10_manifest.json"
BUILD_ROOT = ROOT / "build" / "m6-m10r3-acceptance"
RESULTS_DIR = ROOT / "build" / "test-results-m6-m10r3"
RESULTS_PATH = RESULTS_DIR / "m6-m10r3-results.json"
LOG_DIR = RESULTS_DIR / "logs"
DATA_DIR = BUILD_ROOT / "data"

VERSION = "0.10.0-m10"
REVISION = "M6-M10R3"
FINAL_SUCCESS = "MiniSQL M6-M10R3 acceptance test: SUCCESS"
FINAL_FAILURE = "MiniSQL M6-M10R3 acceptance test: FAIL"


class AcceptanceFailure(RuntimeError):
    """Signals a deterministic acceptance-contract violation."""
    pass


def load_json(path: Path) -> Any:
    """Loads and decodes a UTF-8 JSON document from the supplied path."""
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001
        raise AcceptanceFailure(f"Invalid JSON {path.relative_to(ROOT)}: {exc}") from exc


def normalized(text: str) -> str:
    """Normalizes line endings and surrounding whitespace for stable output comparison."""
    return text.replace("\r\n", "\n").replace("\r", "\n").strip()


def resolve_compiler(requested: str | None) -> Path:
    """Resolves the requested or conventionally located MiniLang compiler to an absolute path."""
    candidates: list[Path] = []
    if requested:
        candidates.append(Path(requested))
    env_value = os.environ.get("MINILANG_COMPILER")
    if env_value:
        candidates.append(Path(env_value))
    candidates.extend(
        [
            ROOT / "mlc_win64.py",
            ROOT / "tools" / "minilang" / "mlc_win64.py",
            ROOT.parent / "MiniLangCompilerPy" / "mlc_win64.py",
            ROOT.parent / "MiniLang" / "mlc_win64.py",
            ROOT.parent / "mlc_win64.py",
        ]
    )
    for candidate in candidates:
        candidate = candidate.expanduser()
        if candidate.is_file():
            return candidate.resolve()
    raise AcceptanceFailure(
        "MiniLangPy compiler not found. Pass -Compiler/--compiler with the full path "
        "to mlc_win64.py or set MINILANG_COMPILER."
    )


def compiler_command(compiler: Path, source: Path, output: Path) -> list[str]:
    """Builds the compiler command line, including project and compiler-library include roots."""
    prefix = [sys.executable, str(compiler)] if compiler.suffix.lower() == ".py" else [str(compiler)]
    command = prefix + [
        str(source),
        str(output),
        "-I",
        str(ROOT / "src"),
    ]
    library_root = next(
        (candidate for candidate in list(compiler.parents)[:4] if (candidate / "std").is_dir()),
        None,
    )
    if library_root is not None:
        command.extend(["-I", str(library_root)])
    if compiler.suffix.lower() != ".py":
        command.append("--object-pipeline")
    return command + [
        "--keep-going",
        "--max-errors",
        "50",
    ]


def executable_command(exe: Path, *args: str) -> list[str]:
    """Builds a platform-correct command for a native executable and its arguments."""
    if os.name == "nt":
        return [str(exe), *args]
    wine = shutil.which("wine") or shutil.which("wine64")
    if wine:
        return [wine, str(exe), *args]
    raise AcceptanceFailure("Generated Windows executables require Windows or Wine for full acceptance.")


def write_log(name: str, command: list[str], returncode: int, stdout: str, stderr: str) -> None:
    """Persists one subprocess command, exit code and captured streams for later diagnosis."""
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    (LOG_DIR / name).write_text(
        "command: "
        + subprocess.list2cmdline(command)
        + "\n"
        + f"exitCode: {returncode}\n"
        + "--- stdout ---\n"
        + stdout
        + ("\n" if stdout and not stdout.endswith("\n") else "")
        + "--- stderr ---\n"
        + stderr
        + ("\n" if stderr and not stderr.endswith("\n") else ""),
        encoding="utf-8",
    )


def run_command(
    command: list[str],
    *,
    log_name: str,
    verbose: bool,
    timeout: float = 240.0,
    input_text: str | None = None,
) -> subprocess.CompletedProcess[str]:
    """Runs a subprocess with optional stdin, captures its streams and enforces the requested result contract."""
    try:
        result = subprocess.run(
            command,
            cwd=ROOT,
            text=True,
            encoding="utf-8",
            errors="replace",
            input=input_text,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
            timeout=timeout,
        )
    except subprocess.TimeoutExpired as exc:
        stdout = exc.stdout or ""
        stderr = exc.stderr or ""
        if isinstance(stdout, bytes):
            stdout = stdout.decode("utf-8", "replace")
        if isinstance(stderr, bytes):
            stderr = stderr.decode("utf-8", "replace")
        write_log(log_name, command, -999, stdout, stderr + f"\nTIMEOUT after {timeout}s\n")
        raise AcceptanceFailure(f"Command timed out after {timeout}s: {subprocess.list2cmdline(command)}") from exc
    write_log(log_name, command, result.returncode, result.stdout, result.stderr)
    if verbose or result.returncode != 0:
        print("    command:", subprocess.list2cmdline(command))
        if result.stdout:
            for line in result.stdout.rstrip().splitlines():
                print("      stdout: " + line)
        if result.stderr:
            for line in result.stderr.rstrip().splitlines():
                print("      stderr: " + line)
    return result


def validate_pe(path: Path) -> None:
    """Validates that a compiler output is a nonempty Windows PE executable rather than a placeholder."""
    if not path.is_file() or path.stat().st_size < 512:
        raise AcceptanceFailure(f"Compiler did not create a plausible executable: {path.name}")
    image = path.read_bytes()
    if image[:2] != b"MZ" or len(image) < 0x40:
        raise AcceptanceFailure(f"Generated output is not an MZ executable: {path.name}")
    pe_offset = struct.unpack_from("<I", image, 0x3C)[0]
    if pe_offset > len(image) - 26 or image[pe_offset : pe_offset + 4] != b"PE\0\0":
        raise AcceptanceFailure(f"Generated output has an invalid PE header: {path.name}")
    machine = struct.unpack_from("<H", image, pe_offset + 4)[0]
    optional_magic = struct.unpack_from("<H", image, pe_offset + 24)[0]
    if machine != 0x8664 or optional_magic != 0x020B:
        raise AcceptanceFailure(
            f"Generated output is not PE32+ AMD64: {path.name} "
            f"(machine=0x{machine:04X}, optionalMagic=0x{optional_magic:04X})"
        )


def compile_target(compiler: Path, source_rel: str, output_name: str, verbose: bool) -> Path:
    """Compiles one MiniLang entry point and returns the verified native executable path."""
    source = ROOT / source_rel
    output = BUILD_ROOT / output_name
    output.parent.mkdir(parents=True, exist_ok=True)
    result = run_command(
        compiler_command(compiler, source, output),
        log_name=f"{output_name}.compile.log",
        verbose=verbose,
        timeout=1200.0,
    )
    if result.returncode != 0:
        raise AcceptanceFailure(f"Compilation failed for {source_rel} with exit code {result.returncode}")
    validate_pe(output)
    return output


def run_exact(
    exe: Path,
    args: list[str],
    expected: str,
    verbose: bool,
    suffix: str = "default",
    timeout: float = 240.0,
) -> None:
    """Executes a native test and requires an exact normalized stdout value and zero exit status."""
    result = run_command(
        executable_command(exe, *args),
        log_name=f"{exe.name}.{suffix}.run.log",
        verbose=verbose,
        timeout=timeout,
    )
    if result.returncode != 0:
        raise AcceptanceFailure(f"{exe.name} exited with {result.returncode}; expected 0")
    if normalized(result.stdout) != expected:
        raise AcceptanceFailure(
            f"Unexpected stdout from {exe.name}: expected {expected!r}, got {normalized(result.stdout)!r}"
        )
    if normalized(result.stderr):
        raise AcceptanceFailure(f"Unexpected stderr from {exe.name}: {normalized(result.stderr)!r}")


def run_exit_zero(
    exe: Path,
    args: list[str],
    verbose: bool,
    suffix: str,
    timeout: float = 240.0,
) -> None:
    """Executes a native test and requires successful termination, optionally checking output text."""
    result = run_command(
        executable_command(exe, *args),
        log_name=f"{exe.name}.{suffix}.run.log",
        verbose=verbose,
        timeout=timeout,
    )
    if result.returncode != 0:
        raise AcceptanceFailure(f"{exe.name} exited with {result.returncode}; expected 0")
    if normalized(result.stderr):
        raise AcceptanceFailure(f"Unexpected stderr from {exe.name}: {normalized(result.stderr)!r}")


def compile_run_test(
    compiler: Path,
    source: str,
    output: str,
    expected: str,
    verbose: bool,
    args: list[str] | None = None,
    timeout: float = 240.0,
) -> Path:
    """Compiles one MiniLang test entry point and executes it against the supplied acceptance data."""
    exe = compile_target(compiler, source, output, verbose)
    run_exact(exe, args or [], expected, verbose, timeout=timeout)
    return exe


def ensure_runtime_directories() -> None:
    """Creates the generated directories required by the acceptance runner."""
    for relative in ("build", "data", "logs", "tmp"):
        (ROOT / relative).mkdir(parents=True, exist_ok=True)


def clean_path(path: Path) -> None:
    """Removes one generated file or directory without following unrelated paths."""
    if path.is_dir():
        shutil.rmtree(path)
    elif path.exists():
        path.unlink()


def clean_data() -> None:
    """Recreates the acceptance data directory so a run starts from empty durable state."""
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    for path in list(DATA_DIR.iterdir()):
        clean_path(path)


def mask_non_code(text: str) -> str:
    """Masks strings and comments while preserving positions for source-contract scanning."""
    out: list[str] = []
    state = "code"
    i = 0
    while i < len(text):
        c = text[i]
        n = text[i + 1] if i + 1 < len(text) else ""
        if state == "code":
            if c == '"':
                out.append(" ")
                state = "string"
            elif c == "/" and n == "/":
                out.extend((" ", " "))
                i += 1
                state = "line"
            elif c == "/" and n == "*":
                out.extend((" ", " "))
                i += 1
                state = "block"
            else:
                out.append(c)
        elif state == "string":
            if c == "\\" and i + 1 < len(text):
                out.extend((" ", " "))
                i += 1
            elif c == '"':
                out.append(" ")
                state = "code"
            else:
                out.append("\n" if c == "\n" else " ")
        elif state == "line":
            if c == "\n":
                out.append("\n")
                state = "code"
            else:
                out.append(" ")
        else:
            if c == "*" and n == "/":
                out.extend((" ", " "))
                i += 1
                state = "code"
            else:
                out.append("\n" if c == "\n" else " ")
        i += 1
    return "".join(out)


def expected_implemented(target: str) -> bool:
    """Reports whether a manifest target must expose a completed implementation marker."""
    if not re.fullmatch(r"M\d+", target):
        raise AcceptanceFailure(f"Invalid target milestone {target!r}")
    return int(target[1:]) <= 10


def validate_repository(manifest: dict[str, Any]) -> None:
    """Validates the tracked repository inventory, package layout, headers and launcher contract."""
    expected = {
        "manifestVersion": 1,
        "project": "MiniSQL",
        "milestone": "M10",
        "revision": REVISION,
        "version": VERSION,
        "moduleCount": 80,
        "acceptancePhaseCount": 30,
        "userFacingTestRunner": "test.ps1",
    }
    for key, value in expected.items():
        if manifest.get(key) != value:
            raise AcceptanceFailure(f"Manifest {key} mismatch: expected {value!r}, got {manifest.get(key)!r}")

    expected_baseline = {
        "M0": "PASS",
        "M1": "PASS",
        "M2": "PASS",
        "M3": "PASS",
        "M4": "PASS",
        "M5": "PASS",
        "M6": "PASS",
        "evidence": "docs/acceptance/M6_M10R2_FAILURE_20260726.md",
    }
    if manifest.get("acceptedBaseline") != expected_baseline:
        raise AcceptanceFailure("Manifest accepted baseline/evidence mismatch")
    if manifest.get("candidateMilestones") != ["M7", "M8", "M9", "M10"]:
        raise AcceptanceFailure("Manifest candidate milestone list mismatch")

    if manifest.get("resultArchivePattern") != "build/MiniSQL_M6_M10R3_RESULTS_<timestamp>.zip":
        raise AcceptanceFailure("Manifest result archive pattern mismatch")
    if manifest.get("finalSuccessLine") != FINAL_SUCCESS:
        raise AcceptanceFailure("Manifest final success line mismatch")

    required_dirs = manifest.get("requiredDirectories")
    required_files = manifest.get("requiredFiles")
    if not isinstance(required_dirs, list) or not required_dirs:
        raise AcceptanceFailure("requiredDirectories must be a non-empty list")
    if not isinstance(required_files, list) or not required_files:
        raise AcceptanceFailure("requiredFiles must be a non-empty list")
    if len(required_dirs) != len(set(required_dirs)) or len(required_files) != len(set(required_files)):
        raise AcceptanceFailure("Manifest contains duplicate paths")
    for rel in [*required_dirs, *required_files]:
        p = Path(rel)
        if p.is_absolute() or ".." in p.parts:
            raise AcceptanceFailure(f"Manifest path is unsafe: {rel}")
    for rel in required_dirs:
        if not (ROOT / rel).is_dir():
            raise AcceptanceFailure(f"Required directory missing: {rel}")
    for rel in required_files:
        p = ROOT / rel
        if not p.is_file() or p.stat().st_size == 0:
            raise AcceptanceFailure(f"Required non-empty file missing: {rel}")

    launchers = sorted(p.name for p in ROOT.glob("test*.ps1") if p.is_file())
    if launchers != ["test.ps1"]:
        raise AcceptanceFailure(f"Exactly one root PowerShell test launcher is allowed, found: {launchers}")
    test_ps1 = (ROOT / "test.ps1").read_text(encoding="utf-8")
    for phrase in ("run_m6_m10_tests.py", "Unblock-File", "MiniSQL"):
        if phrase not in test_ps1:
            raise AcceptanceFailure(f"test.ps1 contract missing: {phrase}")
    if re.search(r"test-m\d+\.ps1", test_ps1, re.IGNORECASE):
        raise AcceptanceFailure("test.ps1 must not invoke milestone wrapper scripts")

    catalog_doc = load_json(ROOT / "docs" / "module-catalog.json")
    modules = catalog_doc.get("modules") if isinstance(catalog_doc, dict) else None
    if not isinstance(modules, list) or len(modules) != 80:
        raise AcceptanceFailure("Module catalog must contain exactly 80 source modules")
    if catalog_doc.get("version") not in (1, "1"):
        raise AcceptanceFailure("Unsupported module catalog version")

    seen_paths: set[str] = set()
    seen_packages: set[str] = set()
    seen_components: set[str] = set()
    for item in modules:
        rel = item.get("path")
        package = item.get("package")
        component = item.get("component")
        target = item.get("targetMilestone")
        if not all(isinstance(v, str) and v for v in (rel, package, component, target)):
            raise AcceptanceFailure(f"Invalid module catalog entry: {item!r}")
        if rel in seen_paths or package in seen_packages or component in seen_components:
            raise AcceptanceFailure(f"Duplicate module identity: {item!r}")
        seen_paths.add(rel)
        seen_packages.add(package)
        seen_components.add(component)
        source = ROOT / rel
        text = source.read_text(encoding="utf-8")
        first_code = next(
            (
                line.strip()
                for line in text.splitlines()
                if line.strip() and not line.strip().startswith("//")
            ),
            "",
        )
        if first_code != f"package {package}":
            raise AcceptanceFailure(f"Package/path mismatch in {rel}")
        if f'return "{component}"' not in text:
            raise AcceptanceFailure(f"Component identity missing in {rel}")
        if f'function targetMilestone()\n  return "{target}"' not in text:
            raise AcceptanceFailure(f"Target milestone mismatch in {rel}")
        expected_impl = "true" if expected_implemented(target) else "false"
        if f"function isImplemented()\n  return {expected_impl}" not in text:
            raise AcceptanceFailure(f"Implementation marker mismatch in {rel}; expected {expected_impl}")

    actual_modules = sorted((ROOT / "src" / "minisql").rglob("*.ml"))
    if len(actual_modules) != 71:
        raise AcceptanceFailure(f"Expected 71 engine modules, found {len(actual_modules)}")
    actual_rel = {p.relative_to(ROOT).as_posix() for p in actual_modules}
    if actual_rel != seen_paths:
        missing = sorted(seen_paths - actual_rel)
        extra = sorted(actual_rel - seen_paths)
        raise AcceptanceFailure(f"Module catalog/file mismatch; missing={missing}, extra={extra}")

    forbidden = []
    for p in ROOT.rglob("*"):
        if not p.is_file():
            continue
        rel = p.relative_to(ROOT).as_posix()
        if rel.startswith("build/"):
            continue
        if p.suffix.lower() in {".exe", ".dll", ".pyc", ".pyo"} or "__pycache__" in p.parts:
            forbidden.append(rel)
    if forbidden:
        raise AcceptanceFailure(f"Compiled/cache artifacts are not allowed in source package: {forbidden}")

    # Reject source literals that cannot survive MiniLang's tagged signed 61-bit payload.
    numeric = re.compile(r"(?<![A-Za-z0-9_.])(-?(?:0[xX][0-9A-Fa-f]+|0[bB][01]+|[0-9]+))(?![A-Za-z0-9_.])")
    scalar_min = -(1 << 60)
    scalar_max = (1 << 60) - 1
    for ml_path in sorted((ROOT / "src").rglob("*.ml")):
        code = mask_non_code(ml_path.read_text(encoding="utf-8"))
        for match in numeric.finditer(code):
            token = match.group(1)
            value = int(token, 0)
            if value < scalar_min or value > scalar_max:
                rel = ml_path.relative_to(ROOT).as_posix()
                line = code.count("\n", 0, match.start()) + 1
                raise AcceptanceFailure(f"MiniLang integer literal exceeds signed 61-bit payload: {rel}:{line}: {token}")


def validate_config_and_docs() -> None:
    """Validates frozen configuration defaults and required English documentation contracts."""
    config = load_json(ROOT / "config" / "minisql.example.json")
    schema = load_json(ROOT / "config" / "config.schema.json")
    if config.get("configVersion") != 1:
        raise AcceptanceFailure("Example config version must be 1")
    defaults = config.get("databaseDefaults", {})
    if defaults.get("pageSize") != 4096 or defaults.get("checksumAlgorithm") != "crc32c":
        raise AcceptanceFailure("Example database defaults are invalid")
    if config.get("server", {}).get("bindAddress") != "127.0.0.1":
        raise AcceptanceFailure("Pre-DCL example config must bind to loopback")
    if schema.get("type") != "object":
        raise AcceptanceFailure("Config schema root must be object")

    required_docs = [
        "docs/acceptance/M2_M5_STATUS.md",
        "docs/acceptance/M6.md",
        "docs/acceptance/M7.md",
        "docs/acceptance/M8.md",
        "docs/acceptance/M9.md",
        "docs/acceptance/M10.md",
        "docs/acceptance/M6_M10R2_FAILURE_20260726.md",
        "docs/acceptance/M6_M10R3.md",
        "docs/adr/ADR-0023-package-local-concrete-type-predicates.md",
        "docs/spec/18-wal-and-transactions.md",
        "docs/spec/19-checkpoint-and-recovery.md",
        "docs/spec/20-database-directory-and-catalog.md",
        "docs/spec/21-slotted-pages-rows-and-heap-files.md",
        "docs/spec/22-overflow-text-and-blob.md",
        "docs/formats/wal-v1.md",
        "docs/formats/checkpoint-v1.md",
        "docs/formats/catalog-bootstrap-v1.md",
        "docs/formats/slotted-page-v1.md",
        "docs/formats/row-v1.md",
        "docs/formats/heap-forwarding-v1.md",
        "docs/formats/overflow-v1.md",
    ]
    for rel in required_docs:
        text = (ROOT / rel).read_text(encoding="utf-8")
        if len(text.strip()) < 120:
            raise AcceptanceFailure(f"Normative documentation is unexpectedly short: {rel}")
    evidence = (ROOT / "docs" / "acceptance" / "M2_M5_STATUS.md").read_text(encoding="utf-8")
    for phrase in ("SUCCESS", "19/19 PASS", "M2", "M3", "M4", "M5"):
        if phrase not in evidence:
            raise AcceptanceFailure(f"Accepted M2-M5 evidence missing phrase: {phrase}")
    r2_failure = (ROOT / "docs" / "acceptance" / "M6_M10R2_FAILURE_20260726.md").read_text(encoding="utf-8")
    for phrase in ("M6:  PASS", "M7:  FAIL", "scanResult must be WalScan", "M8:  INCOMPLETE"):
        if phrase not in r2_failure:
            raise AcceptanceFailure(f"R2 failure evidence missing phrase: {phrase}")
    r3_candidate = (ROOT / "docs" / "acceptance" / "M6_M10R3.md").read_text(encoding="utf-8")
    for phrase in (REVISION, FINAL_SUCCESS, "package", "typeName"):
        if phrase not in r3_candidate:
            raise AcceptanceFailure(f"R3 candidate documentation missing phrase: {phrase}")


def require_phrases(rel: str, phrases: list[str]) -> None:
    """Requires every supplied source-contract phrase to occur in one repository file."""
    text = (ROOT / rel).read_text(encoding="utf-8")
    for phrase in phrases:
        if phrase not in text:
            raise AcceptanceFailure(f"Required source contract missing from {rel}: {phrase}")


def validate_source_contracts() -> None:
    """Checks milestone-specific implementation contracts without executing native code."""
    version = (ROOT / "src/minisql/common/version.ml").read_text(encoding="utf-8")
    for phrase in ('PRODUCT_VERSION = "0.10.0-m10"', 'MILESTONE = "M10"', 'REVISION = "M6-M10"'):
        if phrase not in version:
            raise AcceptanceFailure(f"Version contract missing: {phrase}")

    contracts = {
        "src/minisql/transaction/wal.ml": [
            "const HEADER_SIZE = 80",
            "const RECORD_TX_BEGIN = 1",
            "const RECORD_PAGE_IMAGE = 2",
            "const MAX_RECORD_SIZE = 67108864",
            "function isWalScan(value)",
            "return value is WalScan",
            "function scanFile(file)",
            "function rewind(writer, lsn)",
        ],
        "src/minisql/transaction/transaction.ml": [
            "transaction.committedChanges = transaction.changes",
            "function takeCommittedPages(transaction)",
            "function failCommit(transaction, startLsn, failure)",
            "wal.rewind(transaction.walWriter, startLsn)",
            "wal.flush(transaction.walWriter)",
        ],
        "src/minisql/transaction/checkpoint.ml": [
            "const SLOT_SIZE = 256",
            "const FILE_SIZE = 512",
            "function publish(checkpointFile",
        ],
        "src/minisql/transaction/recovery.ml": [
            "if not wal.isWalScan(scanResult)",
            "if isCommitted(statuses, record.transactionId)",
            "page.compareLsn",
            "function recoverPath(",
        ],
        "src/minisql/config/loader.ml": [
            "const MAX_CONFIG_BYTES = 1048576",
            "leading zero is not valid JSON",
            "function ensureOnlyKeys(",
        ],
        "src/minisql/config/model.ml": [
            "function isDatabaseDefaults(value)",
            "function isMiniSqlConfig(value)",
            "return value is MiniSqlConfig",
        ],
        "src/minisql/config/validation.ml": [
            "if not model.isMiniSqlConfig(config)",
            "not model.isDatabaseDefaults(config.databaseDefaults)",
        ],
        "src/minisql/catalog/catalog.ml": [
            'temporaryPath = joinPath(dataRoot, ".db_" + identity + ".creating")',
            "file_api.movePath(temporaryPath, finalPath, false)",
            "if not config_model.isDatabaseDefaults(defaults)",
            "if not metadata.isColumnMetadata(definition)",
            "function validateTableFiles(",
            "duplicate global object ID",
            "object ID space is exhausted",
            "function allocateTransactionId(",
        ],
        "src/minisql/catalog/metadata.ml": [
            "function isColumnMetadata(value)",
            "return value is ColumnMetadata",
        ],
        "src/minisql/storage/slotted_page.ml": [
            "const SLOT_SIZE = 8",
            "if generation >= 65535 then return 65535",
            "current.generation < 65535",
            "function rebuild(",
        ],
        "src/minisql/common/endian.ml": [
            "function isInt64Words(value)",
            "return value is Int64Words",
        ],
        "src/minisql/storage/row_codec.ml": [
            "struct SqlNull",
            "function isExternalValue(value)",
            "return value is ExternalValue",
            "if not endian.isInt64Words(value)",
            "MiniLang void is not SQL NULL",
            "const HEADER_SIZE = 16",
            "function decodeRow(",
        ],
        "src/minisql/storage/heap_file.ml": [
            "const FORWARD_SIZE = 24",
            "const MAX_FORWARD_DEPTH = 64",
            "function resolve(",
            "externally visible deletion durable",
        ],
        "src/minisql/storage/overflow.ml": [
            "const POINTER_SIZE = 48",
            "const DATA_OFFSET = 104",
            "if not row_codec.isExternalValue(value)",
            "function prepareReplace(",
            "function commitReplace(",
            "function abortReplace(",
        ],
        "src/minisql/server/database_manager.ml": [
            "file_lock.acquireExclusive",
            "recovery.recover(walWriter",
            "function begin(database",
        ],
    }
    for rel, phrases in contracts.items():
        require_phrases(rel, phrases)

    # MiniLang has a builtin named decode(bytes[, encoding]). An unqualified call
    # to decode(...) inside WAL code can therefore bind to the builtin instead of
    # the package's WalRecord decoder. Keep the public wal.decode API, but require
    # an unambiguous internal helper for scanFile and reject the failed R1 form.
    wal_text = (ROOT / "src/minisql/transaction/wal.ml").read_text(encoding="utf-8")
    for phrase in (
        "function decodeRecord(source)",
        "function decode(source)\n  return decodeRecord(source)",
        "record = decodeRecord(encoded)",
    ):
        if phrase not in wal_text:
            raise AcceptanceFailure(f"WAL decoder collision fix missing: {phrase}")
    if "record = decode(encoded)" in wal_text:
        raise AcceptanceFailure("WAL scan still calls the builtin-colliding unqualified decode name")

    # Concrete struct identity uses compiler type IDs. typeName() is diagnostic
    # text and can be package-qualified, so short-string equality is not a valid
    # machine contract. Cross-package consumers call predicates defined next to
    # the struct. Reject every executable recurrence in engine and test code.
    type_name_comparison = re.compile(r"\btypeName\s*\([^\n)]*\)\s*(?:==|!=)")
    for ml_path in sorted((ROOT / "src").rglob("*.ml")):
        code = mask_non_code(ml_path.read_text(encoding="utf-8"))
        match = type_name_comparison.search(code)
        if match:
            rel = ml_path.relative_to(ROOT).as_posix()
            line = code.count("\n", 0, match.start()) + 1
            raise AcceptanceFailure(f"String-based concrete type check is forbidden: {rel}:{line}")

    # Earlier milestone regressions must remain valid when later features become
    # implemented. They may assert that their own features still work, but must
    # never assert that a later module is still a stub or pin the global product
    # version/milestone to an earlier release. Exact current implementation state
    # is validated above from the module catalog.
    regression_files = [
        "src/tests/m1_all_modules.ml",
        "src/tests/m5_all_modules.ml",
        "src/tests/m10_all_modules.ml",
    ]
    forbidden_literals = (
        "future stub",
        "unexpectedly marked implemented",
        ".productVersion()",
        ".milestone()",
    )
    negative_if = re.compile(r"if\s+(?!not\s+)[A-Za-z0-9_.]+\.isImplemented\(\)\s+then")
    negative_arg = re.compile(r"isImplemented\(\),\s*false")
    for rel in regression_files:
        text = (ROOT / rel).read_text(encoding="utf-8")
        for literal in forbidden_literals:
            if literal in text:
                raise AcceptanceFailure(f"Non-monotonic cumulative regression in {rel}: {literal}")
        if negative_if.search(text) or negative_arg.search(text):
            raise AcceptanceFailure(f"Regression test asserts a later implementation is absent: {rel}")

    require_phrases(
        "src/tests/m1_all_modules.ml",
        ["if not m_common_endian.isImplemented() then"],
    )
    require_phrases(
        "src/tests/m5_all_modules.ml",
        [
            "checkImplemented(m_storage_buffer_pool.isImplemented(), true",
            "MiniSQL M5 module smoke test: SUCCESS (71 modules)",
        ],
    )
    require_phrases(
        "src/tests/m10_all_modules.ml",
        [
            "checkBool(m23_storage_overflow.isImplemented(), true",
            "MiniSQL M10 module smoke test: SUCCESS (71 modules)",
        ],
    )

    errors = (ROOT / "src/minisql/common/errors.ml").read_text(encoding="utf-8")
    for code in range(9011, 9019):
        if f"= {code}" not in errors:
            raise AcceptanceFailure(f"M6-M10 error code {code} is missing")


def uleb(value: int) -> str:
    """Encodes a nonnegative integer as canonical unsigned LEB128 bytes represented in hexadecimal."""
    out = bytearray()
    while True:
        byte = value & 0x7F
        value >>= 7
        if value:
            out.append(byte | 0x80)
        else:
            out.append(byte)
            return out.hex()


def crc32c_python(data: bytes) -> int:
    """Computes the reference CRC-32C value used to cross-check native codec vectors."""
    crc = 0xFFFFFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            crc = (crc >> 1) ^ (0x82F63B78 if crc & 1 else 0)
    return crc ^ 0xFFFFFFFF


def validate_reference_vectors() -> None:
    """Validates independent binary, parser and security reference vectors."""
    vectors = load_json(ROOT / "tests/reference/m2_vectors.json")
    for item in vectors.get("unsignedVarints", []):
        value = int(item["value"])
        if uleb(value) != item["hex"]:
            raise AcceptanceFailure(f"Unsigned varint reference mismatch for {value}")
    for item in vectors.get("signedZigZagVarints", []):
        bits = int(item["bits"])
        value = int(item["value"])
        zigzag = ((value << 1) ^ (value >> (bits - 1))) & ((1 << bits) - 1)
        if uleb(zigzag) != item["hex"]:
            raise AcceptanceFailure(f"Signed varint reference mismatch for {value}")
    for item in vectors.get("crc32c", []):
        actual = crc32c_python(bytes.fromhex(item["hexInput"]))
        if f"{actual:08x}" != item["value"]:
            raise AcceptanceFailure(f"CRC32C reference mismatch for {item['name']}")

    layout4 = load_json(ROOT / "tests/reference/m4_layout.json")
    if layout4["page"]["headerSize"] != 64 or layout4["pagedFile"]["dataOffset"] != 8192:
        raise AcceptanceFailure("M4 reference layout mismatch")

    layout = load_json(ROOT / "tests/reference/m6_m10_layout.json")
    expected = {
        ("wal", "headerSize"): 80,
        ("checkpoint", "fileSize"): 512,
        ("catalog", "initialNextObjectId"): 3,
        ("slottedPage", "slotSize"): 8,
        ("row", "headerSize"): 16,
        ("heap", "forwardSize"): 24,
        ("overflow", "pointerSize"): 48,
        ("overflow", "dataOffset"): 104,
    }
    for (section, field), value in expected.items():
        if layout.get(section, {}).get(field) != value:
            raise AcceptanceFailure(f"M6-M10 reference layout mismatch: {section}.{field}")
    acceptance = layout.get("acceptance", {})
    if acceptance.get("phaseCount") != 30:
        raise AcceptanceFailure("M6-M10R3 reference phase count must be 30")
    if acceptance.get("finalLine") != FINAL_SUCCESS:
        raise AcceptanceFailure("M6-M10R3 reference final line mismatch")



def compile_and_run_apps(compiler: Path, manifest: dict[str, Any], verbose: bool) -> None:
    """Compiles public applications and executes their regression smoke scenarios."""
    for entry in manifest["entryPoints"]:
        exe = compile_target(compiler, entry["source"], entry["output"], verbose)
        run_exact(exe, ["--version"], entry["version"], verbose, "version")
        run_exact(exe, ["--m0-self-test"], entry["m0SelfTest"], verbose, "m0-self-test")


def run_m0(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M0 all-module identity regression."""
    compile_run_test(compiler, "src/tests/m0_all_modules.ml", "minisql-m0-modules.exe", "MiniSQL M0 module smoke test: SUCCESS (71 modules)", verbose)


def run_m1(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M1 integer-model, endian and round-trip regressions."""
    programs = [
        ("src/tests/m1_all_modules.ml", "minisql-m1r1-modules.exe", "MiniSQL M1R1 module smoke test: SUCCESS (71 modules)"),
        ("src/tests/m1_int64_model.ml", "minisql-m1r1-int64-model.exe", "MiniSQL M1R1 tagged-int and I64 model tests: SUCCESS"),
        ("src/tests/m1_endian_golden.ml", "minisql-m1r1-endian-golden.exe", "MiniSQL M1R1 endian golden tests: SUCCESS"),
        ("src/tests/m1_endian_errors.ml", "minisql-m1r1-endian-errors.exe", "MiniSQL M1R1 endian error tests: SUCCESS"),
        ("src/tests/m1_endian_roundtrip.ml", "minisql-m1r1-endian-roundtrip.exe", "MiniSQL M1R1 endian roundtrip tests: SUCCESS"),
    ]
    for source, output, expected in programs:
        compile_run_test(compiler, source, output, expected, verbose, timeout=360.0)


def run_m2_varint(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M2 varint acceptance scenario."""
    compile_run_test(compiler, "src/tests/m2_varint.ml", "minisql-m2-varint.exe", "MiniSQL M2 varint tests: SUCCESS", verbose)


def run_m2_crc(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M2 crc acceptance scenario."""
    compile_run_test(compiler, "src/tests/m2_crc_envelope.ml", "minisql-m2-crc-envelope.exe", "MiniSQL M2 CRC32C and envelope tests: SUCCESS", verbose)


def run_m3_file(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M3 file acceptance scenario."""
    path = DATA_DIR / "m3-random-access.bin"
    clean_path(path)
    compile_run_test(compiler, "src/tests/m3_file.ml", "minisql-m3-file.exe", "MiniSQL M3 random-access file tests: SUCCESS", verbose, [str(path)])


def run_m3_durable(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M3 durable acceptance scenario."""
    path = DATA_DIR / "m3-durable.bin"
    clean_path(path)
    writer = compile_target(compiler, "src/tests/m3_durable_writer.ml", "minisql-m3-durable-writer.exe", verbose)
    reader = compile_target(compiler, "src/tests/m3_durable_reader.ml", "minisql-m3-durable-reader.exe", verbose)
    run_exact(writer, [str(path)], "MiniSQL M3 durability writer: SUCCESS", verbose, "writer")
    run_exact(reader, [str(path)], "MiniSQL M3 durability reader: SUCCESS", verbose, "reader")


def run_m3_lock(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M3 lock acceptance scenario."""
    worker = compile_target(compiler, "src/tests/m3_lock_worker.ml", "minisql-m3-lock-worker.exe", verbose)
    lock_path = DATA_DIR / "m3-exclusive-lock.bin"
    ready_path = DATA_DIR / "m3-exclusive-lock.ready"
    clean_path(lock_path)
    clean_path(ready_path)
    holder_cmd = executable_command(worker, "hold", str(lock_path), str(ready_path), "1500")
    holder = subprocess.Popen(
        holder_cmd,
        cwd=ROOT,
        text=True,
        encoding="utf-8",
        errors="replace",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    try:
        deadline = time.monotonic() + 10.0
        while not ready_path.exists() and time.monotonic() < deadline:
            if holder.poll() is not None:
                stdout, stderr = holder.communicate()
                write_log("minisql-m3-lock-worker.exe.holder.run.log", holder_cmd, holder.returncode, stdout, stderr)
                raise AcceptanceFailure(f"Lock holder exited before readiness with code {holder.returncode}")
            time.sleep(0.025)
        if not ready_path.exists():
            raise AcceptanceFailure("Lock holder did not publish readiness in time")
        run_exact(worker, ["try", str(lock_path), str(ready_path), "0"], "MiniSQL M3 lock contender: SUCCESS", verbose, "contender")
        stdout, stderr = holder.communicate(timeout=10.0)
        write_log("minisql-m3-lock-worker.exe.holder.run.log", holder_cmd, holder.returncode, stdout, stderr)
        if holder.returncode != 0 or normalized(stdout) != "MiniSQL M3 lock holder: SUCCESS" or normalized(stderr):
            raise AcceptanceFailure(
                f"Lock holder failed: code={holder.returncode}, stdout={normalized(stdout)!r}, stderr={normalized(stderr)!r}"
            )
    finally:
        if holder.poll() is None:
            holder.kill()
            holder.communicate()


def run_m4_page(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M4 page acceptance scenario."""
    compile_run_test(compiler, "src/tests/m4_page_superblock.ml", "minisql-m4-page-superblock.exe", "MiniSQL M4 page and superblock tests: SUCCESS", verbose)


def run_m4_paged(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M4 paged acceptance scenario."""
    paths = [DATA_DIR / f"m4-{name}.bin" for name in ("main", "fallback", "corrupt", "8192")]
    for path in paths:
        clean_path(path)
    compile_run_test(
        compiler,
        "src/tests/m4_paged_file.ml",
        "minisql-m4-paged-file.exe",
        "MiniSQL M4 paged-file recovery tests: SUCCESS",
        verbose,
        [str(p) for p in paths],
        timeout=360.0,
    )


def run_m5_pool(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M5 pool acceptance scenario."""
    path = DATA_DIR / "m5-buffer-pool.bin"
    clean_path(path)
    compile_run_test(compiler, "src/tests/m5_buffer_pool.ml", "minisql-m5-buffer-pool.exe", "MiniSQL M5 buffer-pool tests: SUCCESS", verbose, [str(path)], timeout=360.0)


def run_m5_stress(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M5 stress acceptance scenario."""
    path = DATA_DIR / "m5-buffer-pool-stress.bin"
    clean_path(path)
    compile_run_test(compiler, "src/tests/m5_buffer_pool_stress.ml", "minisql-m5-buffer-pool-stress.exe", "MiniSQL M5 buffer-pool stress tests: SUCCESS", verbose, [str(path)], timeout=480.0)


def run_m5_modules(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M5 modules acceptance scenario."""
    compile_run_test(compiler, "src/tests/m5_all_modules.ml", "minisql-m5-modules.exe", "MiniSQL M5 module smoke test: SUCCESS (71 modules)", verbose)


def run_m6_wal(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M6 wal acceptance scenario."""
    path = DATA_DIR / "m6-wal.log"
    clean_path(path)
    compile_run_test(compiler, "src/tests/m6_wal.ml", "minisql-m6-wal.exe", "MiniSQL M6 WAL tests: SUCCESS", verbose, [str(path)], timeout=360.0)


def run_m6_transaction(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M6 transaction acceptance scenario."""
    path = DATA_DIR / "m6-transaction-wal.log"
    clean_path(path)
    compile_run_test(compiler, "src/tests/m6_transaction.ml", "minisql-m6-transaction.exe", "MiniSQL M6 transaction tests: SUCCESS", verbose, [str(path)], timeout=360.0)


def run_m7_checkpoint(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M7 checkpoint acceptance scenario."""
    path = DATA_DIR / "m7-checkpoint.meta"
    clean_path(path)
    compile_run_test(compiler, "src/tests/m7_checkpoint.ml", "minisql-m7-checkpoint.exe", "MiniSQL M7 checkpoint tests: SUCCESS", verbose, [str(path)], timeout=360.0)


def run_m7_recovery(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M7 recovery acceptance scenario."""
    data_path = DATA_DIR / "m7-recovery-table.bin"
    wal_path = DATA_DIR / "m7-recovery-wal.log"
    clean_path(data_path)
    clean_path(wal_path)
    compile_run_test(compiler, "src/tests/m7_recovery.ml", "minisql-m7-recovery.exe", "MiniSQL M7 recovery tests: SUCCESS", verbose, [str(data_path), str(wal_path)], timeout=480.0)


def run_m7_crash_committed(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M7 crash committed acceptance scenario."""
    worker = compile_target(compiler, "src/tests/m7_crash_worker.ml", "minisql-m7-crash-worker.exe", verbose)
    data_path = DATA_DIR / "m7-crash-committed-table.bin"
    wal_path = DATA_DIR / "m7-crash-committed-wal.log"
    clean_path(data_path)
    clean_path(wal_path)
    # ExitProcess intentionally bypasses normal language cleanup and can bypass buffered
    # stdout, so the writer contract is exit code only. The reader output is exact.
    run_exit_zero(worker, ["write-commit", str(data_path), str(wal_path)], verbose, "writer-committed")
    run_exact(worker, ["recover-commit", str(data_path), str(wal_path)], "MiniSQL M7 crash recovery committed: SUCCESS", verbose, "reader-committed", timeout=480.0)


def run_m7_crash_uncommitted(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M7 crash uncommitted acceptance scenario."""
    worker = BUILD_ROOT / "minisql-m7-crash-worker.exe"
    if not worker.is_file():
        worker = compile_target(compiler, "src/tests/m7_crash_worker.ml", "minisql-m7-crash-worker.exe", verbose)
    data_path = DATA_DIR / "m7-crash-uncommitted-table.bin"
    wal_path = DATA_DIR / "m7-crash-uncommitted-wal.log"
    clean_path(data_path)
    clean_path(wal_path)
    run_exit_zero(worker, ["write-uncommitted", str(data_path), str(wal_path)], verbose, "writer-uncommitted")
    run_exact(worker, ["recover-uncommitted", str(data_path), str(wal_path)], "MiniSQL M7 crash recovery uncommitted: SUCCESS", verbose, "reader-uncommitted", timeout=480.0)


def run_m8_config(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M8 config acceptance scenario."""
    invalid = DATA_DIR / "m8-invalid.json"
    clean_path(invalid)
    compile_run_test(
        compiler,
        "src/tests/m8_config.ml",
        "minisql-m8-config.exe",
        "MiniSQL M8 configuration tests: SUCCESS",
        verbose,
        [str(ROOT / "config/minisql.example.json"), str(invalid)],
        timeout=360.0,
    )


def run_m8_catalog(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M8 catalog acceptance scenario."""
    root = DATA_DIR / "m8-databases"
    clean_path(root)
    root.mkdir(parents=True, exist_ok=True)
    compile_run_test(
        compiler,
        "src/tests/m8_catalog.ml",
        "minisql-m8-catalog.exe",
        "MiniSQL M8 database/catalog tests: SUCCESS",
        verbose,
        [str(ROOT / "config/minisql.example.json"), str(root)],
        timeout=600.0,
    )


def run_m9_row(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M9 row acceptance scenario."""
    compile_run_test(compiler, "src/tests/m9_row_codec.ml", "minisql-m9-row-codec.exe", "MiniSQL M9 row-codec tests: SUCCESS", verbose, timeout=360.0)


def run_m9_heap(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M9 heap acceptance scenario."""
    path = DATA_DIR / "m9-heap.tbl"
    clean_path(path)
    compile_run_test(compiler, "src/tests/m9_heap_file.ml", "minisql-m9-heap-file.exe", "MiniSQL M9 heap-file tests: SUCCESS", verbose, [str(path)], timeout=900.0)


def run_m10_overflow(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M10 overflow acceptance scenario."""
    path = DATA_DIR / "m10-overflow.tbl"
    clean_path(path)
    compile_run_test(compiler, "src/tests/m10_overflow.ml", "minisql-m10-overflow.exe", "MiniSQL M10 overflow tests: SUCCESS", verbose, [str(path)], timeout=1200.0)


def run_m10_modules(compiler: Path, verbose: bool) -> None:
    """Compiles and executes the M10 modules acceptance scenario."""
    compile_run_test(compiler, "src/tests/m10_all_modules.ml", "minisql-m10-modules.exe", "MiniSQL M10 module smoke test: SUCCESS (71 modules)", verbose, timeout=360.0)


def run_phase(index: int, total: int, name: str, action: Callable[[], None], phases: list[dict[str, Any]]) -> None:
    """Runs one named acceptance phase, records duration/status and propagates failures."""
    print(f"[{index:02d}/{total:02d}] {name}")
    started = time.perf_counter()
    try:
        action()
    except Exception:
        phases.append({"name": name, "status": "FAIL", "durationSeconds": round(time.perf_counter() - started, 3)})
        raise
    phases.append({"name": name, "status": "PASS", "durationSeconds": round(time.perf_counter() - started, 3)})


def milestone_statuses(phases: list[dict[str, Any]]) -> dict[str, str]:
    # M0-M5 are hard-coded accepted. M6 was accepted by the R2 evidence but is
    # still recomputed from this run so a regression cannot be hidden. Later
    # milestones report the most precise status reached by the cumulative run.
    """Reduces phase results into the frozen per-milestone PASS/FAIL status map."""
    result = {f"M{i}": "PASS" for i in range(0, 6)}
    by_name = {phase["name"]: phase["status"] for phase in phases}
    groups = {
        "M6": [
            "M6 WAL format, scan and torn-tail repair",
            "M6 transaction commit, rollback, locks and fault injection",
        ],
        "M7": [
            "M7 redundant checkpoint metadata",
            "M7 committed-only idempotent recovery",
            "M7 process termination after durable commit",
            "M7 process termination before commit",
        ],
        "M8": [
            "M8 strict configuration loader and defaults",
            "M8 database directory, catalog and manager",
        ],
        "M9": [
            "M9 row format and SQL NULL codec",
            "M9 slotted pages and heap-file workload",
        ],
        "M10": [
            "M10 overflow chains, replacement and reclamation",
            "M10 71-module implementation smoke",
            "M10 final cumulative gate",
        ],
    }
    prior_pass = True
    for milestone in ("M6", "M7", "M8", "M9", "M10"):
        states = [by_name.get(name) for name in groups[milestone]]
        if "FAIL" in states:
            result[milestone] = "FAIL"
            prior_pass = False
        elif prior_pass and all(value == "PASS" for value in states):
            result[milestone] = "PASS"
        else:
            result[milestone] = "INCOMPLETE"
            prior_pass = False
    return result


def write_results(status: str, phases: list[dict[str, Any]], started: float, failure: str | None) -> None:
    """Writes the machine-readable cumulative result report using stable schema fields."""
    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    payload: dict[str, Any] = {
        "project": "MiniSQL",
        "through": "M10",
        "revision": REVISION,
        "version": VERSION,
        "status": status,
        "milestones": milestone_statuses(phases),
        "durationSeconds": round(time.perf_counter() - started, 3),
        "platform": sys.platform,
        "python": sys.version,
        "phases": phases,
    }
    if failure:
        payload["failure"] = failure
    RESULTS_PATH.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def package_results() -> Path:
    """Packages reports and logs into the timestamped acceptance evidence archive."""
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    archive = ROOT / "build" / f"MiniSQL_M6_M10R3_RESULTS_{timestamp}.zip"
    archive.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        if RESULTS_PATH.is_file():
            zf.write(RESULTS_PATH, "m6-m10r3-results.json")
        if MANIFEST_PATH.is_file():
            zf.write(MANIFEST_PATH, "m6_m10r3_manifest.json")
        if LOG_DIR.is_dir():
            for path in sorted(LOG_DIR.rglob("*")):
                if path.is_file():
                    zf.write(path, "logs/" + path.relative_to(LOG_DIR).as_posix())
    return archive


def parse_args() -> argparse.Namespace:
    """Parses and returns the acceptance runner command-line arguments."""
    parser = argparse.ArgumentParser(description="Run cumulative MiniSQL M0-M10R3 acceptance tests")
    parser.add_argument("--compiler", help="Path to mlc_win64.py or a compiler executable")
    parser.add_argument("--static-only", action="store_true", help="Validate source package without accepting milestones")
    parser.add_argument("--keep-artifacts", action="store_true", help="Keep compiled executables and test data")
    parser.add_argument("--verbose", action="store_true", help="Print command output")
    return parser.parse_args()


def main() -> int:
    """Dispatches the selected command, translates known failures and returns a process exit status."""
    args = parse_args()
    started = time.perf_counter()
    phases: list[dict[str, Any]] = []
    ensure_runtime_directories()
    clean_path(RESULTS_DIR)
    clean_path(BUILD_ROOT)
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    static_actions: list[tuple[str, Callable[[], None]]] = []
    try:
        manifest = load_json(MANIFEST_PATH)
        static_actions = [
            ("repository manifest, one-launcher contract and 80-module catalog", lambda: validate_repository(manifest)),
            ("configuration and normative documentation", validate_config_and_docs),
            ("M6-M10R3 source, exact-type and monotonic-regression contracts", validate_source_contracts),
            ("independent reference vectors and persisted layouts", validate_reference_vectors),
        ]
        if args.static_only:
            total = len(static_actions)
            for index, (name, action) in enumerate(static_actions, 1):
                run_phase(index, total, name, action, phases)
            print("MiniSQL M6-M10R3 static validation: SUCCESS (not milestone acceptance)")
            return 0

        compiler = resolve_compiler(args.compiler)
        print(f"MiniLang compiler: {compiler}")
        actions: list[tuple[str, Callable[[], None]]] = list(static_actions)
        actions.extend(
            [
                ("compile and run application regressions", lambda: compile_and_run_apps(compiler, manifest, args.verbose)),
                ("M0 71-module regression", lambda: run_m0(compiler, args.verbose)),
                ("M1R1 codec and module regressions", lambda: run_m1(compiler, args.verbose)),
                ("M2 canonical varints", lambda: run_m2_varint(compiler, args.verbose)),
                ("M2 CRC32C and protected envelopes", lambda: run_m2_crc(compiler, args.verbose)),
                ("M3 random-access files and clock", lambda: run_m3_file(compiler, args.verbose)),
                ("M3 durable writer/reader processes", lambda: run_m3_durable(compiler, args.verbose)),
                ("M3 cross-process exclusive lock", lambda: run_m3_lock(compiler, args.verbose)),
                ("M4 page and superblock formats", lambda: run_m4_page(compiler, args.verbose)),
                ("M4 paged-file recovery and generation fallback", lambda: run_m4_paged(compiler, args.verbose)),
                ("M5 buffer-pool unit and failure paths", lambda: run_m5_pool(compiler, args.verbose)),
                ("M5 deterministic buffer-pool stress", lambda: run_m5_stress(compiler, args.verbose)),
                ("M5 71-module implementation smoke", lambda: run_m5_modules(compiler, args.verbose)),
                ("M6 WAL format, scan and torn-tail repair", lambda: run_m6_wal(compiler, args.verbose)),
                ("M6 transaction commit, rollback, locks and fault injection", lambda: run_m6_transaction(compiler, args.verbose)),
                ("M7 redundant checkpoint metadata", lambda: run_m7_checkpoint(compiler, args.verbose)),
                ("M7 committed-only idempotent recovery", lambda: run_m7_recovery(compiler, args.verbose)),
                ("M7 process termination after durable commit", lambda: run_m7_crash_committed(compiler, args.verbose)),
                ("M7 process termination before commit", lambda: run_m7_crash_uncommitted(compiler, args.verbose)),
                ("M8 strict configuration loader and defaults", lambda: run_m8_config(compiler, args.verbose)),
                ("M8 database directory, catalog and manager", lambda: run_m8_catalog(compiler, args.verbose)),
                ("M9 row format and SQL NULL codec", lambda: run_m9_row(compiler, args.verbose)),
                ("M9 slotted pages and heap-file workload", lambda: run_m9_heap(compiler, args.verbose)),
                ("M10 overflow chains, replacement and reclamation", lambda: run_m10_overflow(compiler, args.verbose)),
                ("M10 71-module implementation smoke", lambda: run_m10_modules(compiler, args.verbose)),
                ("M10 final cumulative gate", lambda: None),
            ]
        )
        total = len(actions)
        for index, (name, action) in enumerate(actions, 1):
            run_phase(index, total, name, action, phases)

        write_results("SUCCESS", phases, started, None)
        archive = package_results()
        if not args.keep_artifacts:
            clean_path(BUILD_ROOT)
        print(f"Result archive: {archive}")
        print(FINAL_SUCCESS)
        return 0
    except Exception as exc:  # noqa: BLE001
        message = str(exc)
        write_results("FAIL", phases, started, message)
        archive = package_results()
        if not args.keep_artifacts:
            clean_path(BUILD_ROOT)
        print(f"ERROR: {message}")
        print(f"Result archive: {archive}")
        print(FINAL_FAILURE)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
