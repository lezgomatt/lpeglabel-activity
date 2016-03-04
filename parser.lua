local lpeg = require "lpeg"

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
                    lpeg.S("-")^-1 * lpeg.R("19") * lpeg.R("09")^0
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

require "ast"

local Grammar = lpeg.P {
  "Program",
  Program  = lpeg.Ct((Cmd + Exp)^0) / prog_node;
  Cmd      = var * equals * Exp / cmd_node;
  Exp      = lpeg.Ct(Term * (plus_minus * Term)^0) / op_node;
  Term     = lpeg.Ct(Factor * (star_slash * Factor)^0) / op_node;
  Factor   = num / num_node + 
             var / var_node + 
             open_p * Exp * close_p / get_exp;
}

Grammar = Grammar * space * -lpeg.P(1)


assert(lpeg.match(Grammar, ""))
assert(lpeg.match(Grammar, "0"))
assert(lpeg.match(Grammar, "-1"))
assert(lpeg.match(Grammar, "1234567890"))
assert(lpeg.match(Grammar, "1 + 1"))
assert(lpeg.match(Grammar, "2 * 2"))
assert(lpeg.match(Grammar, "1 + 2 * 2"))
assert(lpeg.match(Grammar, "(1 + 2) * 2"))
assert(lpeg.match(Grammar, "1 + (2 * 2)"))
assert(lpeg.match(Grammar, "x = 1 + 1  x"))
assert(lpeg.match(Grammar, "x = 1 + 1  x = 2*x + 1"))
assert(lpeg.match(Grammar, "1 +") == nil)
assert(lpeg.match(Grammar, "* 2") == nil)
assert(lpeg.match(Grammar, "(1 + 1") == nil)
assert(lpeg.match(Grammar, "1 + 1)") == nil)
