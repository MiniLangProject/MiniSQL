// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import minisql.tools.check as checker

// Implements main for this module.
// Requires arguments that satisfy the validation performed below.
// Returns its result or propagates a structured error from validation or a dependency.
// Any side effects are limited to the explicitly invoked dependencies.
function main(args)
  if len(args) == 1 and args[0] == "--version" then print checker.versionLine(); return 0 end if
  if len(args) == 1 and args[0] == "--m0-self-test" then print checker.m0SelfTestLine(); return 0 end if
  if len(args) == 1 then
    report = try(checker.run(args[0]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL check: SUCCESS tables=" + report.tableCount + " rows=" + report.rowCount + " indexes=" + report.indexCount
    for each warning in report.warnings
      print "WARNING: " + warning
    end for
    return 0
  end if
  print "Usage: minisql-check.exe [--version|--m0-self-test|<database-path>]"
  return 2
end function
