#!/usr/bin/env lua

local parser = require "parser"
local interp = require "interpreter"

if arg[1] then
  local file = io.open(arg[1], "r")
  if not file then
    print("Error: file does not exist")
    os.exit(1)
  end
  local code = file:read("*all")
  file:close()

  local ast = parser.parse(code)
  if not ast then
    print("Error: syntax")
  else
    interp.eval(ast)
  end
else
  print("Type `quit` to end the session.")

  local env = interp.new_env()

  repeat
    io.write("> ")

    local line = io.read()
    if line == "quit" then break end

    local ast = parser.parse(line)
    if not ast then
      print("Error: syntax")
    else
      interp.eval(ast, env)
    end
  until false
end
