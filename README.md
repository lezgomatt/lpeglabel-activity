# LPegLabel Activity
A simple interpreter to try out LPegLabel in preparation for LabLua's
GSoC 2016 project for improving the quality of error messages in PEG parsers.

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

| Error Code | Error                                       | Example  |
| ---------- | ------------------------------------------- | -------- |
| 1          | Missing expression after '=' in a command   | `x =`    |
| 2          | Missing expression after an operator        | `1 +`    |
| 3          | Missing expression after '('                | `()`     |
| 4          | Missing ')'                                 | `(2 * 2` |
| 5          | Missing non-zero digit after '-'            | `-x`     |
| 6          | Unknown or unexpected character encountered | `1/2)`   |

## Actual Grammar
This is the actual grammar implemented in the code, with the captures, 
building of AST nodes, and computing of the error position omitted.

    Program  <- (Cmd / Exp)* space (!. / Err_unexpected)
    Cmd      <- (var EQUALS (Exp / Err_rhs_exp))
    Exp      <- Term (PLUS_MINUS (Term / Err_op_exp))*
    Term     <- Factor (STAR_SLASH (Factor / Err_op_exp))*
    Factor   <- num
              / var
              / OPEN_P (Exp / Err_p_exp) (CLOSE_P / Err_close_p)

    var  <- space [A-Za-z]
    num  <- space ('0' / [1-9][0-9]* / '-' ([1-9][0-9]* / Err_non_zero))
  
    EQUALS      <- space '='
    PLUS_MINUS  <- space ('+' / '-')
    STAR_SLASH  <- space ('*' / '/')
    OPEN_P      <- space '('
    CLOSE_P     <- space ')'
  
    space  <- %s*
