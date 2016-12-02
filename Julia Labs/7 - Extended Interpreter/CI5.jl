
# If you're getting errors about not being able to load this, you may
# need to add the current directory to the module load path:
#
# push!(LOAD_PATH, ".")
#
# This is how I make sure it's reloaded when something changes:
# workspace(); reload("CI5"); using CI5;
#
# This is a helper function to run through a bunch of tests in a file:
# CI5.calcf( "./tests.txt" )
#

module CI5

using Error
using Lexer
export parse, calc, NumVal, ClosureVal

#
# ===================================================
#

abstract Environment
abstract AE
abstract RetVal

# Rejigger our type hierarchy to better support return values

type NumVal <: RetVal
  n::Real
end

type ClosureVal <: RetVal
    param::Symbol
    body::AE
    env::Environment  # this is the environment at definition time!
end

type mtEnv <: Environment
end

type CEnvironment <: Environment
  name::Symbol
  value::RetVal
  parent::Environment
end

#
# NEW STUFF HERE --------------------------------
#

type FunDef <: AE
    formal_parameter::Symbol
    fun_body::AE
end

type FunApp <: AE
    fun_expr::AE
    arg_expr::AE
end

# --------------------------------------------------

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
  zero_branch::AE
  nonzero_branch::AE
end

type With <: AE
  name::Symbol
  binding_expr::AE
  body::AE
end

type Id <: AE
  name::Symbol
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

#
# NEW STUFF HERE --------------------------------
#

  elseif op_symbol == :lambda
      return FunDef( expr[2], parse(expr[3]) )

  else
      return FunApp( parse(expr[1]), parse(expr[2]) )
      
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

# evaluate a series of tests in a file
function calcf( fn::AbstractString )
  f = open( fn )

  cur_prog = ""
  for ln in eachline(f)
      ln = chomp( ln )
      if length(ln) == 0 && length(cur_prog) > 0
          println( "" )          
          println( "--------- Evaluating ----------" )
          println( cur_prog )
          println( "---------- Returned -----------" )
          try
              println( calc( cur_prog ) )
          catch errobj
              println( ">> ERROR: lxd" )
              lxd = Lexer.lex( cur_prog )
              println( lxd )
              println( ">> ERROR: ast" )
              ast = parse( lxd )
              println( ast )
              println( ">> ERROR: rethrowing error" )
              throw( errobj )
          end
          println( "------------ done -------------" )
          println( "" )          
          cur_prog = ""
      else
          cur_prog *= ln
      end
  end
    
  close( f )
end

# ===================================================

function calc( ast::AE )
  return calc( ast, mtEnv() )
end

function calc( ae::Num, env::Environment )
  return NumVal( ae.n )
end

function calc( ae::Plus, env::Environment )
  left = calc( ae.lhs, env )
  right = calc( ae.rhs, env )
  return NumVal( left.n + right.n )
end

function calc( ae::Minus, env::Environment )
  left = calc( ae.lhs )
  right = calc( ae.rhs )
  return NumVal( left.n - right.n )
end

function calc( ae::If0, env::Environment )
  cond = calc( ae.condition, env )
  if cond.n == 0
    return calc( ae.zero_branch, env )
  else
    return calc( ae.nonzero_branch, env )
  end
end

function calc( ae::With, env::Environment )
  val = calc( ae.binding_expr, env )
  extended_env = CEnvironment( ae.name, val, env )
  return calc( ae.body, extended_env )
end

function calc( ae::Id, env::Environment )
  if env == mtEnv()
    throw( LispError( "WARGH! Couldn't find symbol!" ) )
  elseif env.name == ae.name
    return env.value
  else
    return calc( ae, env.parent )
  end
end

#
# NEW STUFF HERE --------------------------------
#

function calc( ae::FunDef, env::Environment )
    return ClosureVal( ae.formal_parameter, ae.fun_body, env )
end

function calc( ae::FunApp, env::Environment )

    # the function expression should result in a closure
    the_closure = calc( ae.fun_expr, env )

    # extend the current environment by binding the actual parameter to the formal parameter
    actual_parameter = calc( ae.arg_expr, env )
    formal_parameter = the_closure.param
    new_env = CEnvironment( formal_parameter, actual_parameter, the_closure.env )

    rval = calc( the_closure.body, new_env )

    return rval
end

    
end # module
