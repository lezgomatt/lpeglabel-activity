local parser = require "parser"

local interpreter = {}

local function new_env(init_tbl)
  env = {}
  if init then
    for var, val in pairs(init_tbl) do
      env[var] = val
    end
  end
  return env
end

local function eval(node, env)
  if not env then env = new_env() end
  if node.type == "prog" then
    local result
    for i, node in ipairs(node.lines) do
      result = eval(node, env)
      if result and result ~= "ERROR" then
        print(result)
      elseif result == "ERROR" then
        print("  in line " .. i)
        break
      end
    end
    return result
  elseif node.type == "cmd" then
    local val = eval(node.val, env)
    if val == "ERROR" then return "ERROR" end
    env[node.var] = val
    return nil
  elseif node.type == "op" then
    local left = eval(node.left, env)
    if left == "ERROR" then return "ERROR" end
    local right = eval(node.right, env)
    if right == "ERROR" then return "ERROR" end
    if     node.op == "+" then return left + right
    elseif node.op == "-" then return left - right
    elseif node.op == "*" then return left * right
    elseif node.op == "/" then return left / right
    else
      print("Error: unknown operation " .. node.op)
      return "ERROR"
    end
  elseif node.type == "num" then
    return node.val
  elseif node.type == "var" then
    if env[node.name] then
      return env[node.name]
    else
      print("Error: undefined variable " .. node.name)
      return "ERROR"
    end
  else
    print("Error: unknown node type " .. node.type)
    return "ERROR"
  end
end


interpreter.new_env = new_env
interpreter.eval = eval

return interpreter
