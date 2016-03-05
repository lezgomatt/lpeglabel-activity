local parser = require "parser"
local interp = require "interpreter"

local function is_valid(string)
  local ast, err = parser.parse(string)
  return not err
end

assert(is_valid "")
assert(is_valid "0")
assert(is_valid "-1")
assert(is_valid "1234567890")
assert(is_valid "1 + 1")
assert(is_valid "2 * 2")
assert(is_valid "1 + 2 * 2")
assert(is_valid "(1 + 2) * 2")
assert(is_valid "1 + (2 * 2)")
assert(is_valid "x = 1 + 1  x")
assert(is_valid "x = 1 + 1  x = 2*x + 1")
assert(not is_valid "1 +")
assert(not is_valid "* 2")
assert(not is_valid "(1 + 1")
assert(not is_valid "1 + 1)")

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

-- 1 "expected expression after '='"
-- 2 "expected expression after operator"
-- 3 "expected expression after '('"
-- 4 "expected ')' after expression"
-- 5 "expected non-zero digit after '-'"
-- 6 "unknown or unexpected character"

local result, err
result, err = parser.parse "-"
assert(err.code == 5)
result, err = parser.parse "-0"
assert(err.code == 5)
result, err = parser.parse "-x"
assert(err.code == 5)
result, err = parser.parse "1 -"
assert(err.code == 2)
result, err = parser.parse "2 /"
assert(err.code == 2)
result, err = parser.parse "()"
assert(err.code == 3)
result, err = parser.parse "(3"
assert(err.code == 4)
result, err = parser.parse "(4+"
assert(err.code == 2)
result, err = parser.parse "(5*)"
assert(err.code == 2)
result, err = parser.parse "(x*y"
assert(err.code == 4)
result, err = parser.parse "x)"
assert(err.code == 6)
result, err = parser.parse "+2"
assert(err.code == 6)
result, err = parser.parse "x ="
assert(err.code == 1)

print("All tests passed!")
