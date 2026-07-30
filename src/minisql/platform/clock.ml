package minisql.platform.clock

const INVALID_ARGUMENT = 9001

extern function GetTickCount64() from "kernel32.dll" symbol "GetTickCount64" returns u64
extern function Sleep(milliseconds as u32) from "kernel32.dll" symbol "Sleep" returns void

function monotonicMilliseconds()
  return GetTickCount64()
end function

function sleepMilliseconds(milliseconds)
  if typeof(milliseconds) != "int" or milliseconds < 0 or milliseconds > 4294967295 then
    return error(INVALID_ARGUMENT, "platform.clock.sleepMilliseconds: milliseconds must fit U32")
  end if
  Sleep(milliseconds)
  return true
end function

function componentName()
  return "platform.clock"
end function

function targetMilestone()
  return "M3"
end function

function isImplemented()
  return true
end function
