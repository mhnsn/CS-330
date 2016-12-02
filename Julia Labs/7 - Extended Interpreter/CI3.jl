
# If you're getting errors about not being able to load this, you may
# need to add the current directory to the module load path:
#
# push!(LOAD_PATH, ".")

module CI3

using Error
using Lexer
export parse, calc, Num

#
# ===================================================
#

# This is the abstract class "arithmetic expression"
abstract AE

type Num <: AE
  n::Real
end

type Plus <: AE
  lhs::AE
  rhs::AE
end

type Minus <: AE
  lhs::AE
  rhs::AE
end

# NEW STUFF HERE -------------------------
type If0 <: AE
  condition::AE
  zerobranch::AE
  nonzerobranch::AE
end

#
# ===================================================
#

function parse( expr::Real )
  return Num( expr ) # return a "Num" type object, with the "n" member set to "expr"
end

function parse( expr::Array{Any} )
  # should be an array of length 3 - something like "(+ lhs rhs)"

  op_symbol = expr[1]    

  if op_symbol == :+
      lhs = parse( expr[2] )
      rhs = parse( expr[3] )
      return Plus( lhs, rhs )
      
  elseif op_symbol == :-
      lhs = parse( expr[2] )
      rhs = parse( expr[3] )
      return Minus( lhs, rhs )

  # NEW STUFF HERE -------------------------      
  elseif op_symbol == :if0
      condition = parse( expr[2] )
      zerobranch = parse( expr[3] )
      nonzerobranch = parse( expr[4] )
      return If0( condition, zerobranch, nonzerobranch )

  else
    throw( LispError("Whoa there!  Unknown operation!") )
  end
end

# the default case
function parse( expr::Any )
  throw( LispError("Invalid type $expr") )
end

#
# ===================================================
#

# convenience function to make everything easier
function calc( expr::AbstractString )
  return calc( parse( Lexer.lex(expr) ) )
end


# just a number - return it!
function calc( ae::Num )
  return ae.n
end

# calc each side and combine
function calc( ae::Plus )
  left = calc( ae.lhs )
  right = calc( ae.rhs )
  return left + right
end

# calc each side and combine
function calc( ae::Minus )
  left = calc( ae.lhs )
  right = calc( ae.rhs )
  return left - right
end

# NEW STUFF HERE -------------------------

# an if statement
function calc( ae::If0 )
  cond = calc( ae.condition )
  if cond == 0
    return calc( ae.zerobranch )
  else
    return calc( ae.nonzerobranch )
  end
end
    
end # module
