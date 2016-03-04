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
  ast = parser.parse(string)
  if not ast then return "ERROR" end
  return interp.eval(ast)
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
assert(run "x + 1  x  x = 8-13  x" == "ERROR")
assert(run "x = 7  y = 28  y/x" == 4)
