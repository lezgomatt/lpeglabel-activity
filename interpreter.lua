local parser = require "parser"

local interpreter = {}

local function new_env(init_tbl)
  env = {}
  if init_tbl then
    for var, val in pairs(init_tbl) do
      env[var] = val
    end
  end
  return env
end

local function eval(node, env)
  if not env then env = new_env() end

  if node.type == "prog" then
    local result, err
    for i, node in ipairs(node.lines) do
      result, err = eval(node, env)
      if err then
        err = "Error: " .. err .. " in line " .. i
        print(err)
        return nil, err 
      end

      if result then
        print(result)
      end
    end
    return result

  elseif node.type == "cmd" then
    local val, err = eval(node.val, env)
    if err then return nil, err end
    env[node.var] = val
    return nil

  elseif node.type == "op" then
    local left, err = eval(node.left, env)
    if err then return nil, err end

    local right, err = eval(node.right, env)
    if err then return nil, err end

    if     node.op == "+" then return left + right
    elseif node.op == "-" then return left - right
    elseif node.op == "*" then return left * right
    elseif node.op == "/" then return left / right
    else
      return nil, "unknown operation " .. node.op
    end

  elseif node.type == "num" then
    return node.val

  elseif node.type == "var" then
    if env[node.name] then
      return env[node.name]
    else
      return nil, "undefined variable " .. node.name
    end

  else
    return nil, "unknown node type " .. node.type
  end
end


interpreter.new_env = new_env
interpreter.eval = eval

return interpreter
