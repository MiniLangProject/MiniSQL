// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

//! Provides apps minisql backup main facilities for this project.

import minisql.tools.backup as backup


/// Runs point-in-time recovery using the supplied inputs.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param archivePath Path associated with archive.
/// @param databasePath Path associated with database.
/// @param targetText targetText value consumed by this operation.
function runPitr(archivePath, databasePath, targetText)
  if targetText == "latest" then
    latestReport = try(backup.restoreLatest(archivePath, databasePath))
    if typeof(latestReport) == "error" then print "ERROR " + latestReport.code + ": " + latestReport.message; return 1 end if
    print "MiniSQL PITR: SUCCESS lsn=" + latestReport.targetLsn
    return 0
  end if
  targetLsn = toNumber(targetText)
  if typeof(targetLsn) != "int" then print "ERROR 9001: target LSN must be an integer or latest"; return 2 end if
  pitrReport = try(backup.restoreToLsn(archivePath, databasePath, targetLsn))
  if typeof(pitrReport) == "error" then print "ERROR " + pitrReport.code + ": " + pitrReport.message; return 1 end if
  print "MiniSQL PITR: SUCCESS lsn=" + pitrReport.targetLsn
  return 0
end function

/// Performs the main operation for the apps minisql backup main module.
/// Requires arguments that satisfy the validation performed below.
/// Returns its result or propagates a structured error from validation or a dependency.
/// Any side effects are limited to the explicitly invoked dependencies.
/// @param args Command-line or caller-supplied arguments.
function main(args)
  if len(args) == 1 and args[0] == "--version" then print backup.versionLine(); return 0 end if
  if len(args) == 1 and args[0] == "--m0-self-test" then print backup.m0SelfTestLine(); return 0 end if
  if len(args) == 3 and args[0] == "backup" then
    report = try(backup.run(args[1], args[2]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL backup: SUCCESS files=" + report.fileCount + " bytes=" + report.totalBytes
    return 0
  end if
  if len(args) == 4 and args[0] == "backup-encrypted" then
    report = try(backup.runEncrypted(args[1], args[2], args[3]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL encrypted backup: SUCCESS files=" + report.fileCount + " bytes=" + report.totalBytes
    return 0
  end if
  if len(args) == 3 and args[0] == "restore" then
    report = try(backup.restore(args[1], args[2]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL restore: SUCCESS files=" + report.fileCount + " bytes=" + report.totalBytes
    return 0
  end if
  if len(args) == 4 and args[0] == "restore-encrypted" then
    report = try(backup.restoreEncrypted(args[1], args[2], args[3]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL encrypted restore: SUCCESS files=" + report.fileCount + " bytes=" + report.totalBytes
    return 0
  end if
  if len(args) == 3 and args[0] == "archive-init" then
    report = try(backup.archiveInit(args[1], args[2]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL WAL archive init: SUCCESS generation=" + report.generation + " lsn=" + report.latestEndLsn
    return 0
  end if
  if len(args) == 3 and args[0] == "archive-wal" then
    report = try(backup.archiveWal(args[1], args[2]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL WAL archive: SUCCESS generation=" + report.generation + " lsn=" + report.latestEndLsn
    return 0
  end if
  if len(args) == 3 and args[0] == "archive-wal-live" then
    report = try(backup.archiveWalLive(args[1], args[2]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL live WAL archive: SUCCESS generation=" + report.generation + " lsn=" + report.latestEndLsn
    return 0
  end if
  if len(args) == 4 and args[0] == "restore-pitr" then
    return runPitr(args[1], args[2], args[3])
  end if
  if len(args) == 3 and args[0] == "standby-materialize" then
    report = try(backup.materializeStandby(args[1], args[2]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL standby materialization: SUCCESS generation=" + report.archiveGeneration + " lsn=" + report.appliedLsn
    return 0
  end if
  if len(args) == 3 and args[0] == "standby-refresh" then
    report = try(backup.refreshStandby(args[1], args[2]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL standby refresh: SUCCESS generation=" + report.archiveGeneration + " lsn=" + report.appliedLsn
    return 0
  end if
  if len(args) == 2 and args[0] == "standby-promote" then
    report = try(backup.promoteStandby(args[1]))
    if typeof(report) == "error" then print "ERROR " + report.code + ": " + report.message; return 1 end if
    print "MiniSQL standby promotion: SUCCESS generation=" + report.archiveGeneration + " lsn=" + report.appliedLsn
    return 0
  end if
  if len(args) == 2 and args[0] == "archive-verify" then
    manifest = try(backup.verifyArchive(args[1]))
    if typeof(manifest) == "error" then print "ERROR " + manifest.code + ": " + manifest.message; return 1 end if
    print "MiniSQL WAL archive verify: SUCCESS generation=" + manifest.generation + " lsn=" + manifest.latestEndLsn
    return 0
  end if
  print "Usage: minisql-backup.exe [--version|--m0-self-test|backup <db> <backup>|backup-encrypted <db> <backup> <key>|restore <backup> <db>|restore-encrypted <backup> <db> <key>|archive-init <db> <archive>|archive-wal <db> <archive>|archive-wal-live <db> <archive>|archive-verify <archive>|restore-pitr <archive> <db> <lsn|latest>|standby-materialize <archive> <db>|standby-refresh <archive> <db>|standby-promote <db>]"
  return 2
end function
