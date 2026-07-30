import minisql.tools.check as checker

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
