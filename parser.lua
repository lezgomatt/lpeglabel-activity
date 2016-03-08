local re = require 'relabel'
local ast = require 'ast'

-- Original Grammar:
-- Program  <- (Cmd | Exp)*
-- Cmd      <- var "=" Exp
-- Exp      <- Exp "+" Term | Exp "-" Term | Term
-- Term     <- Term "*" Factor | Term "/" Factor | Factor
-- Factor   <- num | var | (Exp)

-- Modified Grammar:
-- Program  <- (Cmd / Exp)*
-- Cmd      <- var "=" Exp
-- Exp      <- Term (("+" / "-") / Term)*
-- Term     <- Factor (("*" / "/") Factor)*
-- Factor   <- num / var / "(" Exp ")"


-- `err:rule` is a shorthand for `(rule / Err_err)`
local rules = [[
  Program  <- ({| (Cmd / Exp)* |} space (!. / Err_unexpected))  -> prog_node
  Cmd      <- (var EQUALS rhs_exp:Exp)                          -> cmd_node
  Exp      <- {| Term ((PLUS / MINUS) op_exp:Term)* |}          -> op_node
  Term     <- {| Factor ((STAR / SLASH) op_exp:Factor)* |}      -> op_node
  Factor   <- num                                               -> num_node
            / var                                               -> var_node
            / (OPEN_P p_exp:Exp close_p:CLOSE_P)                -> get_exp
            / (MINUS neg_exp:Factor)                           -> neg_node
]]

local tokens = [[
  var  <- space {[A-Za-z]}
  num  <- space {'0' / [1-9][0-9]*}
  
  EQUALS   <- space {'='}
  PLUS     <- space {'+'}
  MINUS    <- space {'-'}
  STAR     <- space {'*'}
  SLASH    <- space {'/'}
  OPEN_P   <- space {'('}
  CLOSE_P  <- space {')'}
  
  space <- %s*
]]

local err_arr = {}
local err_msg = {}
local function add_error(err, msg)
  table.insert(err_arr, err)
  err_msg[#err_arr] = msg
end

add_error('rhs_exp',    "expected expression after '='")
add_error('op_exp',     "expected expression after operator")
add_error('p_exp',      "expected expression after '('")
add_error('close_p',    "expected ')' after expression")
add_error('neg_exp',    "expected expression after '-'")
add_error('unexpected', "unknown or unexpected character")
err_msg[0] = "syntax error"

local errors = "\n"
local label_tbl = {}
for i, err in ipairs(err_arr) do
  errors = errors .. "Err_" .. err .. " <- Compute_pos %{err_" .. err .. "}\n"
  label_tbl["err_" .. err] = i
end
errors = errors .. "Compute_pos <- '' => compute_pos\n"
re.setlabels(label_tbl)

local line, col
function compute_pos(string, i)
  line, col = 1, 1
  local function next_line()
    line = line + 1
    col = 1
    return true
  end
  local function next_col()
    col = col + 1
    return true
  end
  
  local patt = re.compile([[
    S <- (%nl -> next_line / . -> next_col)*
  ]], { 
    next_line = next_line; 
    next_col = next_col;
  })
  patt:match(string:sub(1, i))
  
  return true
end

-- transform `err:rule` shorthand into `(rule / Err_err)`
local function transform_err(string)
  return re.gsub(rules, [[
    S <- {ident} ':' {ident}
    ident <- [A-Za-z][A-Za-z0-9_]*
  ]], function(err, rule)
    return '(' .. rule .. ' / Err_' .. err .. ')'
  end)
end

rules = transform_err(rules)

local grammar = re.compile(rules .. tokens .. errors, {
  prog_node  = ast.prog_node;
  cmd_node   = ast.cmd_node;
  op_node    = ast.op_node;
  num_node   = ast.num_node;
  var_node   = ast.var_node;
  get_exp    = ast.get_exp;
  neg_node   = ast.neg_node;
  
  compute_pos = compute_pos;
})

local parser = {}
parser.err_codes = label_tbl;

function parser.parse(string)
  local result, err = grammar:match(string)
  if err then
    if err == parser.err_codes.err_unexpected  then
      local char
      line_num = 0
      for text_line in string:gmatch("[^%nl]*") do
        line_num = line_num + 1
        if line_num == line then
          char = text_line:sub(col-1, col-1)
          break
        end
      end
      return nil, { 
        code = err; 
        msg = err_msg[err] .. " '" .. char .. "'"; 
        line = line; col = col-1;
      }
    end
    return nil, { code = err; msg = err_msg[err]; line = line; col = col; }
  end
  return result
end

return parser
