package minisql.common.errors

enum ErrorCode
  Ok = 0
  NotImplemented = 9000
  InvalidArgument = 9001
  InvalidConfiguration = 9002
  UnsupportedFormat = 9003
  CorruptData = 9004
  IoFailure = 9005
  ProtocolFailure = 9006
  LockConflict = 9007
  ClosedHandle = 9008
  BufferPoolExhausted = 9009
  PinnedPage = 9010
  TransactionState = 9011
  ReadOnlyViolation = 9012
  ObjectExists = 9013
  ObjectNotFound = 9014
  PageFull = 9015
  RowNotFound = 9016
  TypeMismatch = 9017
  StaleReference = 9018
  SqlSyntax = 9019
  BindingError = 9020
  ConstraintViolation = 9021
  DuplicateKey = 9022
  DdlState = 9023
  IndexCorrupt = 9024
  UnsupportedSql = 9025
  NetworkFailure = 9026
  AuthenticationFailed = 9027
  AuthenticationRequired = 9028
  PermissionDenied = 9029
  SecurityState = 9030
end enum

function notImplemented(component, operation)
  return error(9000, "M0 stub: " + component + "." + operation)
end function

function componentName()
  return "common.errors"
end function

function targetMilestone()
  return "M0"
end function

function isImplemented()
  return true
end function
