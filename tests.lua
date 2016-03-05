local parser = require "parser"
local interp = require "interpreter"

assert(parser.parse "")
assert(parser.parse "0")
assert(parser.parse "-1")
assert(parser.parse "1234567890")
assert(parser.parse "1 + 1")
assert(parser.parse "2 * 2")
assert(parser.parse "1 + 2 * 2")
assert(parser.parse "(1 + 2) * 2")
assert(parser.parse "1 + (2 * 2)")
assert(parser.parse "x = 1 + 1  x")
assert(parser.parse "x = 1 + 1  x = 2*x + 1")
assert(parser.parse "1 +" == nil)
assert(parser.parse "* 2" == nil)
assert(parser.parse "(1 + 1" == nil)
assert(parser.parse "1 + 1)" == nil)

local function run(string)
  local ast, err = parser.parse(string)
  if err then return "SYNTAX ERROR" end
  return interp.eval(ast, nil, true)
end

assert(run "" == nil)
assert(run "0" == 0)
assert(run "-1" == -1)
assert(run "1 + 1" == 2)
assert(run "2 * 2" == 4)
assert(run "1 + 2 * 2" == 5)
assert(run "(1 + 2) * 2" == 6)
assert(run "1 + (2 * 2)" == 5)
assert(run "x = 1 + 1  x" == 2)
assert(run "x = 1 + 1  x = 2*x + 1  x" == 5)
assert(run "x = 1 + 1  x  x = 8-13  x" == -5)
assert(run "x + 1  x  x = 8-13  x" == nil)
assert(run "x = 7  y = 28  y/x" == 4)

local result, err
result, err = parser.parse "-"
assert(err.code == 1)
result, err = parser.parse "-0"
assert(err.code == 1)
result, err = parser.parse "-x"
assert(err.code == 1)
result, err = parser.parse "1 -"
assert(err.code == 2)
result, err = parser.parse "2 /"
assert(err.code == 2)
result, err = parser.parse "()"
assert(err.code == 2)
result, err = parser.parse "(3"
assert(err.code == 3)
result, err = parser.parse "(4+"
assert(err.code == 2)
result, err = parser.parse "(5*)"
assert(err.code == 2)
result, err = parser.parse "(x*y"
assert(err.code == 3)
result, err = parser.parse "x)"
assert(err.code == 0)
result, err = parser.parse "+2"
assert(err.code == 0)
result, err = parser.parse "x ="
assert(err.code == 2)

print("All tests passed!")
