local lpeg = require "lpeglabel"

-- Original Grammar:
-- Program  -> (Cmd | Exp)*
-- Cmd      -> var "=" Exp
-- Exp      -> Exp "+" Term | Exp "-" Term | Term
-- Term     -> Term "*" Factor | Term "/" Factor | Factor
-- Factor   -> num | var | (Exp)

-- Modified Grammar:
-- Program  -> (Cmd / Exp)*
-- Cmd      -> var "=" Exp
-- Exp      -> Term (("+" / "-") / Term)*
-- Term     -> Factor (("*" / "/") Factor)*
-- Factor   -> num / var / "(" Exp ")"

local num         = lpeg.P("0") +
                    lpeg.R("19") * lpeg.R("09")^0 +
                    lpeg.S("-") * (lpeg.R("19") + lpeg.T(1)) * lpeg.R("09")^0
local var         = lpeg.R("az")
local equals      = lpeg.S("=")
local plus_minus  = lpeg.S("+-")
local star_slash  = lpeg.S("*/")
local open_p      = lpeg.S("(")
local close_p     = lpeg.S(")")

local space = lpeg.S(" \t\n")^0
num         = space * lpeg.C(num)
var         = space * lpeg.C(var)
equals      = space * lpeg.C(equals)
plus_minus  = space * lpeg.C(plus_minus)
star_slash  = space * lpeg.C(star_slash)
open_p      = space * lpeg.C(open_p)
close_p     = space * lpeg.C(close_p)


local Cmd     = lpeg.V("Cmd")
local Exp     = lpeg.V("Exp")
local Term    = lpeg.V("Term")
local Factor  = lpeg.V("Factor")

local ast = require "ast"

local Grammar = lpeg.P {
  "Program",
  Program  = lpeg.Ct((Cmd + Exp)^0) / ast.prog_node;
  Cmd      = var * equals * (Exp + lpeg.T(2)) / ast.cmd_node;
  Exp      = lpeg.Ct(Term * (plus_minus * (Term + lpeg.T(2)))^0) / ast.op_node;
  Term     = lpeg.Ct(Factor * (star_slash * (Factor + lpeg.T(2)))^0) / ast.op_node;
  Factor   = num / ast.num_node + 
             var / ast.var_node + 
             open_p * (Exp + lpeg.T(2)) * (close_p + lpeg.T(3)) / ast.get_exp;
}

Grammar = Grammar * space * -lpeg.P(1)

local err_msg = {
    "expected non-zero digit after negative sign",
    "expected expression after operator or parenthesis",
    "expected closing parenthesis after expression",
    [0] = "unexpected character encountered";
}

local parser = {}

function parser.parse(string)
  local result, err = lpeg.match(Grammar, string)
  if err then return nil, { code = err; msg = err_msg[err] } end
  return result
end

return parser
