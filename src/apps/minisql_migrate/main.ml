// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

//! Provides apps minisql migrate main facilities for this project.

import minisql.tools.migrate as migrate

/// Performs the main operation for the apps minisql migrate main module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param args Command-line or caller-supplied arguments.
function main(args)
  if len(args) == 1 and args[0] == "--version" then print migrate.versionLine(); return 0 end if
  if len(args) == 1 and args[0] == "--m0-self-test" then print migrate.m0SelfTestLine(); return 0 end if
  if len(args) == 2 then
    pageSize = toNumber(args[1])
    if typeof(pageSize) != "int" then print "Invalid page size"; return 2 end if
    report = try(migrate.run(args[0], pageSize))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL migration: SUCCESS changed=" + report.changed
    return 0
  end if
  if len(args) == 5 and args[0] == "--rewrite" then
    pageSize = toNumber(args[4])
    if typeof(pageSize) != "int" then print "Invalid page size"; return 2 end if
    report = try(migrate.rewrite(args[1], args[2], args[3], pageSize))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL migration rewrite: SUCCESS target=" + report.targetPath + " rows=" + report.rowCount + " indexes=" + report.indexCount
    return 0
  end if
  print "Usage: minisql-migrate.exe [--version|--m0-self-test|<database-path> <page-size>|--rewrite <source-path> <target-root> <target-name> <page-size>]"
  return 2
end function
