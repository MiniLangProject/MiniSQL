// Copyright 2026 MiniLangProject contributors
// SPDX-License-Identifier: Apache-2.0
// Licensed under the Apache License, Version 2.0; see LICENSE for details.

import std.ds.list as list
import std.time as time_api

// Isolated runtime-primitive benchmark used to decide whether MiniSQL should
// replace interpreter-level element loops with the compiler's native bulk copy.
const ELEMENTS = 65536
const ITERATIONS = 500

// Copies one array through two explicit MiniLang loops for the control path.
function manualRoundTrip(source)
  intermediate = array(len(source))
  output = array(len(source))
  for index = 0 to len(source) - 1
    intermediate[index] = source[index]
  end for
  for index = 0 to len(source) - 1
    output[index] = intermediate[index]
  end for
  return output
end function

// Copies one array through two bounds-checked native bulk operations.
function nativeRoundTrip(source)
  intermediate = array(len(source))
  output = array(len(source))
  copyArray(intermediate, 0, source, 0, len(source))
  copyArray(output, 0, intermediate, 0, len(source))
  return output
end function

// Exercises the production List conversion methods backed by native copying.
function listRoundTrip(source)
  return list.List.fromArray(source).toArray()
end function

// Times one selected copy strategy and returns its elapsed milliseconds.
function measure(source, mode)
  checksum = 0
  started = time_api.ticks()
  for iteration = 0 to ITERATIONS - 1
    output = void
    if mode == 0 then
      output = manualRoundTrip(source)
    else if mode == 1 then
      output = nativeRoundTrip(source)
    else
      output = listRoundTrip(source)
    end if
    checksum = checksum + output[iteration % ELEMENTS]
  end for
  elapsed = time_api.ticks() - started
  print "mode=" + mode + " elements=" + ELEMENTS + " iterations=" + ITERATIONS + " elapsedMs=" + elapsed + " checksum=" + checksum
  return elapsed
end function

// Builds deterministic input, warms every path, and prints comparable results.
function main(args)
  source = array(ELEMENTS)
  for index = 0 to ELEMENTS - 1
    source[index] = index
  end for
  // Prime generated code and allocator state outside the measured loops.
  warmManual = manualRoundTrip(source)
  warmNative = nativeRoundTrip(source)
  warmList = listRoundTrip(source)
  if warmManual[ELEMENTS - 1] != ELEMENTS - 1 or warmNative[ELEMENTS - 1] != ELEMENTS - 1 or warmList[ELEMENTS - 1] != ELEMENTS - 1 then return 1 end if
  measure(source, 0)
  measure(source, 1)
  measure(source, 2)
  return 0
end function
