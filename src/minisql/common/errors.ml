//! Provides minisql common errors facilities for this project.

package minisql.common.errors
// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see the LICENSE file.

// Stable public error-code registry. Numeric values are part of MiniSQL's
// observable API and must not be renumbered when new conditions are added.

/// Defines the error code enumeration used by this module.
enum ErrorCode
  /// Ok variant of the error code.
  Ok = 0
  /// Not implemented variant of the error code.
  NotImplemented = 9000
  /// Invalid argument variant of the error code.
  InvalidArgument = 9001
  /// Invalid configuration variant of the error code.
  InvalidConfiguration = 9002
  /// Unsupported format variant of the error code.
  UnsupportedFormat = 9003
  /// Corrupt data variant of the error code.
  CorruptData = 9004
  /// Io failure variant of the error code.
  IoFailure = 9005
  /// Protocol failure variant of the error code.
  ProtocolFailure = 9006
  /// Lock conflict variant of the error code.
  LockConflict = 9007
  /// Closed handle variant of the error code.
  ClosedHandle = 9008
  /// Buffer pool exhausted variant of the error code.
  BufferPoolExhausted = 9009
  /// Pinned page variant of the error code.
  PinnedPage = 9010
  /// Transaction state variant of the error code.
  TransactionState = 9011
  /// Read only violation variant of the error code.
  ReadOnlyViolation = 9012
  /// Object exists variant of the error code.
  ObjectExists = 9013
  /// Object not found variant of the error code.
  ObjectNotFound = 9014
  /// Page full variant of the error code.
  PageFull = 9015
  /// Row not found variant of the error code.
  RowNotFound = 9016
  /// Type mismatch variant of the error code.
  TypeMismatch = 9017
  /// Stale reference variant of the error code.
  StaleReference = 9018
  /// Sql syntax variant of the error code.
  SqlSyntax = 9019
  /// Binding error variant of the error code.
  BindingError = 9020
  /// Constraint violation variant of the error code.
  ConstraintViolation = 9021
  /// Duplicate key variant of the error code.
  DuplicateKey = 9022
  /// Ddl state variant of the error code.
  DdlState = 9023
  /// Index corrupt variant of the error code.
  IndexCorrupt = 9024
  /// Unsupported sql variant of the error code.
  UnsupportedSql = 9025
  /// Network failure variant of the error code.
  NetworkFailure = 9026
  /// Authentication failed variant of the error code.
  AuthenticationFailed = 9027
  /// Authentication required variant of the error code.
  AuthenticationRequired = 9028
  /// Permission denied variant of the error code.
  PermissionDenied = 9029
  /// Security state variant of the error code.
  SecurityState = 9030
  /// Archive or replication state is inconsistent.
  ArchiveState = 9031
  /// A logical lock wait exceeded its configured deadline.
  LockTimeout = 9032
  /// A standby cannot execute the requested writable operation.
  StandbyState = 9033
  /// Native TLS setup or transport failed.
  TlsFailure = 9034
  /// An administrator cancelled the active statement.
  QueryCancelled = 9035
  /// The configured execution deadline expired.
  QueryTimeout = 9036
  /// A configured process, result, or temporary-storage budget was exhausted.
  ResourceLimit = 9037
end enum

/// Performs the not implemented operation for this module.
/// Inputs: `component`, `operation`. Returns the produced value or propagates a structured error from validation or delegated operations.
/// @param component component value consumed by this operation.
/// @param operation operation value consumed by this operation.
function notImplemented(component, operation)
  return error(9000, "M0 stub: " + component + "." + operation)
end function

/// Performs the componentName operation for the minisql common errors module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function componentName()
  return "common.errors"
end function

/// Performs the targetMilestone operation for the minisql common errors module.
/// Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.
function targetMilestone()
  return "M0"
end function

/// Returns whether implemented satisfies the condition required by the minisql common errors module.
/// Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.
function isImplemented()
  return true
end function
