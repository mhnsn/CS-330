
# If you're getting errors about not being able to load this, you may
# need to add the current directory to the module load path:
#
# push!(LOAD_PATH, ".")

module CI4

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

type If0 <: AE
  condition::AE
  true_branch::AE
  false_branch::AE
end

# NEW STUFF HERE -------------------------

type With <: AE
  name::Symbol
  binding_expr::AE
  body::AE
end

type Id <: AE
  name::Symbol
end

abstract Environment

type mtEnv <: Environment
end

type CEnvironment <: Environment
  name::Symbol
  value::Real
  parent::Environment
end

#
# ===================================================
#

function parse( expr::Real )
  return Num( expr ) # return a "Num" type object, with the "n" member set to "expr"
end

function parse( expr::Symbol )
  return Id( expr )
end
    
function parse( expr::Array{Any} )

  # the length of the 'expr' array could be 
    
  op_symbol = expr[1]    

  if op_symbol == :+
      lhs = parse( expr[2] )
      rhs = parse( expr[3] )
      return Plus( lhs, rhs )
      
  elseif op_symbol == :-
      lhs = parse( expr[2] )
      rhs = parse( expr[3] )
      return Minus( lhs, rhs )

  elseif op_symbol == :if0
      condition = parse( expr[2] )
      true_branch = parse( expr[3] )
      false_branch = parse( expr[4] )
      return If0( condition, true_branch, false_branch )

  # NEW STUFF HERE -------------------------      
  elseif op_symbol == :with    # (with x (+ 5 1) (+ x x) )
      sym = expr[2]
      binding_expr = parse( expr[3] )
      body = parse( expr[4] )
      return With( sym, binding_expr, body )
      
  else
      return Id( op_symbol )
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

# ===================================================

function calc( ast::AE )
  return calc( ast, mtEnv() )
end

function calc( ae::Num, env::Environment )
  return ae.n
end

function calc( ae::Plus, env::Environment )
  left = calc( ae.lhs, env )
  right = calc( ae.rhs, env )
  return left + right
end

function calc( ae::Minus, env::Environment )
  left = calc( ae.lhs )
  right = calc( ae.rhs )
  return left - right
end

# an if statement
function calc( ae::If0, env::Environment )
  cond = calc( ae.condition, env )
  if cond == 0
    return calc( ae.true_branch, env )
  else
    return calc( ae.false_branch, env )
  end
end

# NEW STUFF HERE ------------------

function calc( ae::With, env::Environment )
  val = calc( ae.binding_expr, env )
  extended_env = CEnvironment( ae.name, val, env )
  return calc( ae.body, extended_env )
end

# look up Id in current environment
function calc( ae::Id, env::Environment )
  if env == mtEnv()
    throw( LispError( "WARGH! Couldn't find symbol!" ) )
  elseif env.name == ae.name
    return env.value
  else
    return calc( ae, env.parent )
  end
end
    
end # module
