local ast = {}

function ast.prog_node(lines)
  return {
    type   = "prog";
    lines  = lines;
  }
end

function ast.cmd_node(var, eq, exp)
  return {
    type  = "cmd";
    var   = var;
    val   = exp;
  }
end

function ast.op_node(ops)
  local node = ops[1]
  for i = 2, #ops, 2 do
    node = {
      type   = "op";
      op     = ops[i];
      left   = node;
      right  = ops[i+1];
    }
  end
  return node
end

function ast.num_node(num)
  return {
    type  = "num";
    val   = tonumber(num);
  }  
end

function ast.var_node(var)
  return {
    type  = "var";
    name  = var;
  }  
end

function ast.get_exp(open, exp, close)
  return exp
end


-- table pretty printing for easy AST node inspection
-- taken from https://gist.github.com/ripter/4270799
function ast.tprint (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))		
    else
      print(formatting .. v)
    end
  end
end

return ast
