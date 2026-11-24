#!/usr/bin/env python3
"""Build the complete MiniSQL manual with pdfLaTeX and MakeIndex.

Requires a normal TeX Live or MiKTeX installation with the packages used in
preamble.tex. No shell escape, network download, or generated raster art is
required. Auxiliary files remain in docs/manual/build.
"""
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
from __future__ import annotations

import argparse
from pathlib import Path
import re
import shutil
import subprocess

MANUAL = Path(__file__).resolve().parents[1]
STEM = "minisql-user-manual"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=MANUAL / f"{STEM}.pdf")
    args = parser.parse_args()
    for executable in ("pdflatex", "makeindex"):
        if shutil.which(executable) is None:
            parser.error(f"{executable} is missing; install TeX Live or MiKTeX")
    build = MANUAL / "build"
    build.mkdir(exist_ok=True)
    command = ["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
               "-file-line-error", f"-output-directory={build}", f"{STEM}.tex"]
    for run in range(4):
        log = build / f"pass-{run + 1}.txt"
        with log.open("w", encoding="utf-8") as stream:
            result = subprocess.run(command, cwd=MANUAL, stdout=stream,
                                    stderr=subprocess.STDOUT, timeout=240)
        if result.returncode:
            print(log.read_text(encoding="utf-8", errors="replace")[-12000:])
            raise SystemExit(f"pdfLaTeX failed; full log: {log}")
        if run == 0:
            result = subprocess.run(["makeindex", f"{STEM}.idx"], cwd=build,
                                    capture_output=True, text=True, timeout=60)
            if result.returncode:
                raise SystemExit(result.stdout + result.stderr)
    log_text = build.joinpath(f"{STEM}.log").read_text(encoding="utf-8", errors="replace")
    if re.search(r"There were undefined references|There were multiply-defined labels", log_text):
        raise SystemExit("Unresolved or duplicate references remain; inspect the TeX log")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(build / f"{STEM}.pdf", args.output)
    overfull = re.findall(r"Overfull \\[hv]box.*", log_text)
    print(f"Built {args.output}")
    print(f"Overfull boxes to inspect: {len(overfull)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
