#!/usr/bin/env python3
"""Check the manual's source citations, local inputs and labels; write source map."""
# Copyright 2026 MiniLangProject contributors
# SPDX-License-Identifier: Apache-2.0
# Licensed under the Apache License, Version 2.0; see the LICENSE file.
from __future__ import annotations

import json
from pathlib import Path
import re

MANUAL = Path(__file__).resolve().parents[1]
REPO = MANUAL.parents[1]


def main() -> int:
    """Validates source citations and navigation before writing the chapter source map."""
    errors = []
    chapters = {}
    labels = {}
    references = []
    files = sorted(MANUAL.glob("*.tex")) + sorted(MANUAL.joinpath("chapters").glob("*.tex")) + sorted(MANUAL.joinpath("figures").glob("*.tex"))
    for source in files:
        text = source.read_text(encoding="utf-8")
        short = str(source.relative_to(MANUAL))
        paths = sorted(set(re.findall(r"\\sourcecode\{([^}]+)\}", text)))
        if source.parent.name == "chapters":
            chapters[source.name] = paths
        for path in paths:
            if not REPO.joinpath(path).is_file():
                errors.append(f"{short}: missing source citation {path}")
        for label in re.findall(r"\\label\{([^}]+)\}", text):
            if label in labels:
                errors.append(f"{short}: duplicate label {label}")
            labels[label] = short
        references.extend((short, label) for label in re.findall(r"\\(?:ref|pageref|autoref)\{([^}]+)\}", text))
        for path in re.findall(r"\\input\{([^}]+)\}", text):
            if not MANUAL.joinpath(path + ".tex").is_file():
                errors.append(f"{short}: missing TeX input {path}")
        for path in re.findall(r"\\lstinputlisting(?:\[[^]]*\])?\{([^}]+)\}", text):
            if not MANUAL.joinpath(path).is_file():
                errors.append(f"{short}: missing listing input {path}")
        for environment in ("lstlisting", "longtable", "table", "figure", "itemize", "enumerate"):
            starts = text.count("\\begin{" + environment + "}")
            ends = text.count("\\end{" + environment + "}")
            if starts != ends:
                errors.append(f"{short}: unmatched {environment}: {starts}/{ends}")
    for source, label in references:
        if label not in labels:
            errors.append(f"{source}: unknown reference {label}")
    edition = MANUAL.joinpath("edition.tex").read_text()
    baseline = re.search(r"\\newcommand\{\\SourceCommit\}\{([^}]+)\}", edition).group(1)
    MANUAL.joinpath("source-map.json").write_text(json.dumps({"source_baseline": baseline, "chapters": chapters}, indent=2) + "\n", encoding="utf-8")
    if errors:
        print("\n".join(errors))
        return 1
    unique_paths = {path for paths in chapters.values() for path in paths}
    print(f"Manual audit: PASS ({len(files)} TeX files, {len(unique_paths)} source files, {len(labels)} labels)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
