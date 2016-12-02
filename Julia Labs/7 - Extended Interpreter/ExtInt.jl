# filename: ExtInt.jl

module ExtInt	

using Error
using Lexer
using ClassInt
export parse, calc, NumVal, ClosureVal

#    <OWL> ::= number
#          | (+ <OWL> <OWL>)
#          | (- <OWL> <OWL>)
#          | (* <OWL> <OWL>)
#          | (/ <OWL> <OWL>)
#          | (mod <OWL> <OWL>)
#          | (collatz <OWL>)
#          | (- <OWL>)
#          | id
#          | (if0 <OWL> <OWL> <OWL>)
# 
# Major change: function definitions, calls &
# with statements now take a variable number of arguments!
# Note the extra parens.
# 
#          | (with ( (id <OWL>)* ) <OWL>)
#          | (lambda (id*) <OWL>)
#          | (<OWL> <OWL>*)         	

#-------------------- ABSTRACTS --------------------#
	abstract OWL
	abstract Environment
    abstract RetVal
    
#----------------- TYPE HIERARCHY ------------------#	
    type NumVal <: RetVal
      n::Real
    end

    type ClosureVal <: RetVal
      param::Symbol
      body::OWL
      env::Environment  # this is the environment at definition time!
    end
    
#--------------- ENVIRONMENT STRUCT ----------------#
    type mtEnv <: Environment
    end

	type CEnvironment <: Environment
	  name::Symbol
	  value::RetVal
	  parent::Environment
	end
	
#-------------------- AST NODES --------------------#
    type Num <: OWL
      n::Real
    end	
	
	type Binop <: OWL
  	  op::Symbol
	  lhs::OWL
	  rhs::OWL
	end
		  
	type Unop <: OWL
	  op::Symbol
	  erand::OWL
	end
	
	type If0 <: OWL
	  condition::OWL
	  zero_branch::OWL
	  nonzero_branch::OWL
    end
 
	type With <: OWL
	  name::Symbol
	  binding_expr::OWL
	  body::OWL
	end
	 
	type Id <: OWL
	  name::Symbol
	end
	 
	type FuncDef <: OWL
	    formal_parameter::Symbol
	    fun_body::OWL
	end
	 
	type FuncApp <: OWL
	    func_expr::OWL
	    arg_expr::OWL
	end
		
#----------------------- DICT ----------------------#
	function Dict(symbol)
	  if symbol == :+
	    return :+
	  elseif symbol == :-
	    return :-
	  elseif symbol == :*
	    return :*
	  elseif symbol == :/
	    return :/
  	  elseif symbol == :mod
	    return :mod
  	  elseif symbol == :collatz
	    return :collatz	    
	  end
	end
	
# ===================================================
# ===================================================
# ===================================================
#
# A simple pretty printer to help us inspect the AST

function pp( ast::FuncDef, depth::Int )
    print( "(lambda ", ast.formal_parameter, " " )
    pp( ast.fun_body, depth+1 )
    print( ")" )
end

function pp( ast::FuncApp, depth::Int )
    print( "(" )
    pp( ast.func_expr, depth+1 )
    print( " " )
    pp( ast.arg_expr, depth+1 )    
    print( ")" )
end

function pp( ast::Num, depth::Int )
    print( ast.n )
end

function pp( ast::Binop, depth::Int )
    print( "(" )
    print(ast.op)
    print(" ")
    pp( ast.lhs, depth+1 )
    print( " " )
    pp( ast.rhs, depth+1 )    
    print( ")" )
end

function pp( ast::Unop, depth::Int )
    print( "(" )
    print(ast.op)
    print(" ")
    pp( ast.erand, depth+1 )
    print( ")" )
end

function pp( ast::If0, depth::Int )
    print( "(if0 " )
    pp( ast.condition, depth+1 )
    print( " " )
    pp( ast.zero_branch, depth+1 )    
    print( " " )
    pp( ast.nonzero_branch, depth+1 )    
    print( ")" )
end

function pp( ast::With, depth::Int )
    print( "(with ", ast.name, " " )
    pp( ast.binding_expr, depth+1 )    
    print( " " )
    pp( ast.body, depth+1 )    
    print( ")" )
end

function pp( ast::Id, depth::Int )
    print( ast.name )
end

	

#-------------------- PARSER --------------------#
	function parse(expr::Real)
	  return Num(expr)
	end
	
	function parse(expr::Bool)
	  return Bool(expr)
	end

	function parse( expr::Symbol )
	  return Id( expr )
	end
	      
    function parse(expr::Array{Any})
    # should be an array of length 3 - something like "(+ lhs rhs)"
	  op_symbol = expr[1]
	  
	  if op_symbol == :with
	  end

	  if size(expr)[1] == 1 #Nullop parsing
	    try
	      return parse(op_symbol)
        catch
          println(op_symbol)
          throw( LispError("SYNTAX ERROR: Whatever you put thar ain't right, pardner.") )
	    end
	    
      elseif size(expr)[1] == 2	#Unop parsing
		  if op_symbol == :-
		      erand = parse( expr[2] )
	  	  elseif op_symbol == :collatz
		      erand = parse( expr[2] )
		  else
		    println(op_symbol)		    
		    throw( LispError("SYNTAX ERROR: Unknown unary operation!") )
	        end
	  	  return Unop( Dict(op_symbol), erand )
      
      elseif size(expr)[1] == 3 #Binop parsing
		  if op_symbol == :+
		      lhs = parse( expr[2] )
		      rhs = parse( expr[3] )
          elseif op_symbol == :-
		      lhs = parse( expr[2] )
		      rhs = parse( expr[3] )
          elseif op_symbol == :*
		      lhs = parse( expr[2] )
		      rhs = parse( expr[3] )
          elseif op_symbol == :/
		      lhs = parse( expr[2] )
		      rhs = parse( expr[3] )
          elseif op_symbol == :mod
		      lhs = parse( expr[2] )
		      rhs = parse( expr[3] )
		  else
		    print("(")
		    print(op_symbol)
  		    print(" ")		    
		    println(expr[2])
		    print(" ")
  		    println(expr[3])
		    print(")")
		    throw( LispError("SYNTAX ERROR: Unknown binary operation!") )
          end
		  return Binop( Dict(op_symbol), lhs, rhs )
		  		  
      elseif size(expr)[1] == 4 # ternary op        
          if op_symbol == :if0
		      condition = parse( expr[2] )
		      zero_branch = parse( expr[3] )
		      nonzero_branch = parse( expr[4] )
		      return If0( condition, zero_branch, nonzero_branch )
		  elseif op_symbol == :with    # (with x (+ 5 1) (+ x x) )
		      sym = expr[2]
		      binding_expr = parse( expr[3] )
		      body = parse( expr[4] )
		      return With( sym, binding_expr, body )		      
          else
  		    println(op_symbol)
            throw( LispError("SYNTAX ERROR: Unknown ternary operation!") )
          end
        
      else  # arbitrary-length op
  		  if op_symbol == :with    # (with x (+ 5 1) (+ x x) )
		      sym = expr[2]
		      binding_expr = parse( expr[3] )
		      body = parse( expr[4] )
		      return With( sym, binding_expr, body )
          elseif op_symbol == :lambda
	          return FuncDef( expr[2], parse(expr[3]) )
          else  # no parse errors on this; must be caught in calc
	          return FuncApp( parse(expr[1]), parse(expr[2]) )
          end
      end
    end
	
	# handles errors
	function parse( expr::Any )
      throw( LispError("SYNTAX/TYPE ERROR: Invalid type $expr") ) 
    end
	
#--------------------- CALC ---------------------#
    # convenience function to make everything easier
    function calc( expr::AbstractString )
      lexed = Lexer.lex(expr)
      ast = parse(lexed)
      
      pp( ast, 0 );
      println()
      
      return calc(ast)
    end
    
    function calc( ast::OWL )
      return calc( ast, mtEnv() )
    end
    
  	function calc( n::Num, env::Environment )
	  return NumVal(n.n)
	end
    
	function calc( op::Binop, env::Environment )
	  todo = op.op  
	  lhrVal = calc(op.lhs, env)
	  rhrVal = calc(op.rhs, env)
	  
	  if     todo == :+
#	    if typeof(lhrVal == NumVal) && typeof(rhrVal == NumVal)
	      return NumVal(lhrVal.n + rhrVal.n)
#	    else
#	      throw( LispError("RUNTIME ERROR: Did not get back numbers to add!") )
#	    end
	  elseif todo == :-
#  	    if typeof(lhrVal == NumVal) && typeof(rhrVal == NumVal)    
  	      return NumVal(lhrVal.n - rhrVal.n)
#  	    else
#	      throw( LispError("RUNTIME ERROR: Did not get back numbers to subtract!") )
#	    end
	  elseif todo == :*
 # 	    if typeof(lhrVal == NumVal) && typeof(rhrVal == NumVal)
  	      return NumVal(lhrVal.n * rhrVal.n)
#  	    else
#  	      throw( LispError("RUNTIME ERROR: Did not get back numbers to multiply!") )
#  	    end
	  elseif todo == :/
#	    if rhrVal.n == 0
#	      throw( LispError("RUNTIME ERROR: Attempting to divide by zero!") )
#	    else
#	      if typeof(lhrVal == NumVal) && typeof(rhrVal == NumVal)
	        return NumVal(lhrVal.n / rhrVal.n)
#	      else
#	        throw( LispError("RUNTIME ERROR: Did not get back numbers to divide!") )
#	      end
#	    end
	  elseif todo == :mod
#  	    if typeof(lhrVal == NumVal) && typeof(rhrVal == NumVal)
  	      return NumVal(mod(lhrVal.n, rhrVal.n))
#  	    else
#  	      throw( LispError("RUNTIME ERROR: Did not get back numbers for mod!") )	      
#  	    end
	  else
	      throw( LispError("Trying to calc invalid Binop!?") )
	  end
	end
	
	function calc( op::Unop, env::Environment )
	  todo = op.op
  	  rVal = calc(op.erand, env)
	  
	  if todo == :-
#  	    if typeof(rVal == NumVal)
          return NumVal(-rVal.n)
#  	    else
#  	      throw( LispError("RUNTIME ERROR: Did not get back number to take negative!") )
#  	    end
	  elseif todo == :collatz
 # 	    if typeof(rVal == NumVal)
#		    if rVal.n < 0
#		      throw( LispError("RUNTIME ERROR: Attempting to collatz a negative number!") )
#		    else
		      return NumVal(collatz(rVal.n, env))
#		    end
#	    else
  	      throw( LispError("RUNTIME ERROR: Did not get back number for collatz!") )
#	    end
	  else
	      throw( LispError("Trying to calc invalid Unop!?") )
	  end
	end	
		
	function calc( ae::If0, env::Environment )
	  cond = calc( ae.condition, env )
	  if cond.n == 0
	    return calc( ae.zero_branch, env )
	  else
	    return calc( ae.nonzero_branch, env )
	  end
	end
	
#	function calc( ae::With, env::Environment )
#	  val = calc( ae.binding_expr, env )
#	  extended_env = CEnvironment( ae.name, val, env )
#	  return calc( ae.body, extended_env )
#	end
	
	function calc( ae::With, env::Environment )    
    
	  val = calc( ae.binding_expr, env )

	  extended_env = CEnvironment( ae.name, val, env )

	  # support recursion!
	  if typeof(val) == ClosureVal
        val.env = extended_env
      end
	    
	  return calc( ae.body, extended_env )
    end
	
	function calc( ae::Id, env::Environment )
	  if env == mtEnv()
	    throw( LispError( "SYNTAX ERROR: WARGH! Couldn't find symbol! Likely syntax or spelling error." ) )
	  elseif env.name == ae.name
	    return env.value
	  else
	    return calc( ae, env.parent )
	  end
	end
		
	function calc( def::FuncDef, env::Environment )
	  return ClosureVal( def.param, def.body, env )
    end
    
    function calc( func::FuncApp, env::Environment )
	    # the function expression should result in a closure
	    closure = calc( func.func_expr, env )
	
	    if typeof( closure ) != ClosureVal
	        throw( LispError( "Attempting to call a non-function as a function!" ) )
	    end
	
	    # extend the current environment by binding the actual parameter to the formal parameter
	    actual_parameter = calc( func.arg_expr, env )
	
	    formal_parameter = closure.param
	    extended_env = CEnvironment( formal_parameter, actual_parameter, closure.env )
	    
	    # support recursion!
	    if typeof( actual_parameter ) == ClosureVal
	        actual_parameter.env = extended_env
	    end
	
	    return calc( closure.body, extended_env )
    end
	
	function calc(o::Any)
      throw( LispError("SYNTAX ERROR: Invalid operation or id (cannes ewe spel?)") )
	end
	
	
#------------------- HELPERS --------------------#		
	function collatz( n::Real, env::Environment )
	  return collatz_helper( n, 0, env)
	end
	
	function collatz_helper( n::Real, num_iters::Int, env::Environment )
	  if n == 1
	    return num_iters
	  end
	  if mod(n,2)==0
	    return collatz_helper( n/2, num_iters+1, env)
	  else
	    return collatz_helper( 3*n+1, num_iters+1, env) 
	  end
	end

#-------------------- TESTS ---------------------#
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
	              println(errobj)
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
	
	# modified function to verify behavior
	function mycalc( fn::AbstractString )
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
	              ast = ""
	              try
	                ast = parse( lxd )
                  catch othererror
                    println( "Cannot construct AST." )
                    println( "------------ done -------------" )
                    println( "" )
                    cur_prog = ""
                    continue
                  end
	              println( ast )
	              #println( ">> ERROR: rethrowing error" )
	              #throw( errobj )
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
	
	test = true
	justerrors = true
	errors = true
	
	if test == true
	  if justerrors == false
	    println("Beginning tests...")
	    mycalc("\ExtIntTests.jl")
	    println("...finished tests!")	    
	  end
    if errors == true
        println("")
        println("Beginning error checks...")
        calcf("\ExtIntErrorTests.jl")
        println("...finished!")        
  	  end
	end
	
end # module ExtInt