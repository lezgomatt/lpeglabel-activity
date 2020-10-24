# LPegLabel Activity
A simple interpreter to try out LPegLabel in preparation for LabLua's
GSoC 2016 project for improving the quality of error messages in PEG parsers
[(details)](https://summerofcode.withgoogle.com/archive/2016/projects/4549674694344704/).
You can read about my GSoC 2016 experience
[here](https://github.com/lezgomatt/lpeglabel-gsoc-2016/blob/master/README.md).

## Usage
Simply run `main.lua` to test out the intearctive REPL (make sure you have
the proper packages installed). You may also enter a filename as an argument
to run the interpreter on that file instead.

## Langauge Grammar
    Program <- (Cmd | Exp)*
    Cmd     <- var = Exp
    Exp     <- Exp + Term | Exp - Term | Term
    Term    <- Term * Factor | Term / Factor | Factor
    Factor  <- num | var | (Exp)

where `num` is an integer, and `var` is a single letter variable.
Whitespace is *not* significant in this language.

## Table of Syntax Errors
The following table lists the syntax errors implemented:

| Error Label    | Error                                       | Example  |
| -------------- | ------------------------------------------- | -------- |
| err_rhs_exp    | Missing expression after '=' in a command   | `x =`    |
| err_op_exp     | Missing expression after an operator        | `1 +`    |
| err_p_exp      | Missing expression after '('                | `()`     |
| err_close_p    | Missing ')'                                 | `(2 * 2` |
| err_neg_exp    | Missing expression after '-'                | `-`      |
| err_unexpected | Unknown or unexpected character encountered | `1/2)`   |

## Actual Grammar
This is the actual grammar implemented in the code, with the captures, 
building of AST nodes, and computing of the error position omitted.

    Program  <- (Cmd / Exp)* space (!. / Err_unexpected)
    Cmd      <- (var EQUALS (Exp / Err_rhs_exp))
    Exp      <- Term ((PLUS / MINUS) (Term / Err_op_exp))*
    Term     <- Factor ((STAR / SLASH) (Factor / Err_op_exp))*
    Factor   <- num
              / var
              / OPEN_P (Exp / Err_p_exp) (CLOSE_P / Err_close_p)
              / MINUS (Factor / Err_neg_exp)

    var  <- space [A-Za-z]
    num  <- space ('0' / [1-9][0-9]*)
  
    EQUALS   <- space '='
    PLUS     <- space '+'
    MINUS    <- space '-'
    STAR     <- space '*'
    SLASH    <- space '/'
    OPEN_P   <- space '('
    CLOSE_P  <- space ')'
  
    space  <- %s*
