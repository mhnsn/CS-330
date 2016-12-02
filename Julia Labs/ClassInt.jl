
# If you're getting errors about not being able to load this, you may
# need to add the current directory to the module load path:
#
# push!(LOAD_PATH, ".")

module ClassInt

using Error
export parse, calc, Num, Plus, Minus

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

#
# ===================================================
#

function parse( expr::Real )
  return Num( expr ) # return a "Num" type object, with the "n" member set to "expr"
end

function parse( expr::Array{Any} )
  # should be an array of length 3 - something like "(+ lhs rhs)"

  op_symbol = expr[1]
  lhs = parse( expr[2] )
  rhs = parse( expr[3] )

  if op_symbol == :+
    return Plus( lhs, rhs )    

  elseif op_symbol == :-
    return Minus( lhs, rhs )

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

end # module
