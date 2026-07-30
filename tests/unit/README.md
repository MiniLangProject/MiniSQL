# Unit tests

M1R1's executable unit-level coverage currently lives in `src/tests` because each test is
compiled as a native MiniLang program. Later milestones may add data fixtures or grouped
unit runners here. Every test must expose one exact `SUCCESS` line and a non-zero exit code
on failure.
