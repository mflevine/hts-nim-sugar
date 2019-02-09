# Package
version       = "0.1.0"
author        = "Max Levine"
description   = "hts-nim wrapper sugar"
license       = "MIT"

# Dependencies
requires "nim >= 0.18.0", "hts >= 0.2.7"

srcDir = "src"
skipDirs = @["tests"]

task test, "run the tests":
  exec "nim c --lineDir:on --debuginfo -r tests/all"
