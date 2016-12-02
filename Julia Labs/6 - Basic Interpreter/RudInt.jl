# filename: RudInt.jl

module RudInt	

using Error
using Lexer
using ClassInt
export parse, calc, Num
	


# <OWL>	::=	 	number
# 	 	|	 	(+ <OWL> <OWL>)
# 	 	|	 	(- <OWL> <OWL>)
# 	 	|	 	(* <OWL> <OWL>)
# 	 	|	 	(/ <OWL> <OWL>)
#       |       (mod <OWL> <OWL>)
#       |       (collatz <OWL>)
#       |       (- <OWL>)
	
#-------------------- ABSTRACTS --------------------#
	abstract OWL
#-------------------- AST NODES --------------------#	
    type Num <: OWL
      n::Real
    end
	
	type Binop <: OWL
  	  op::Function
	  lhs::OWL
	  rhs::OWL
	end
		  
	type Unop <: OWL
	  op::Function
	  erand::OWL
	end
		
#----------------------- DICT ----------------------#
	
	function Dict(symbol)
	  if symbol == :+
	    return +
	  elseif symbol == :-
	    return -
	  elseif symbol == :*
	    return *
	  elseif symbol == :/
	    return /
  	  elseif symbol == :mod
	    return mod
  	  elseif symbol == :collatz
	    return collatz	    
	  end
	end
	
#-------------------- PARSER --------------------#
	
	function parse(expr::Real)
	  return Num(expr)
	end
	
	function parse(expr::Array{Any})
	    # should be an array of length 3 - something like "(+ lhs rhs)"

	  op_symbol = expr[1]
	  if size(expr)[1] == 1
	    try
	      return parse(op_symbol)
	      catch
            throw( LispError("Whatever you put thar ain't right, pardner.") )
	    end
      elseif size(expr)[1] == 2	
		  if op_symbol == :-
		      erand = parse( expr[2] )
	  	  elseif op_symbol == :collatz
		      erand = parse( expr[2] )
		  else
		    throw( LispError("Unknown unary operation!") )
          end
	  	  return Unop( Dict(op_symbol), erand )
      elseif size(expr)[1] == 3
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
		    println(op_symbol)
		    throw( LispError("Unknown binary operation!") )
		  end
		  return Binop( Dict(op_symbol), lhs, rhs ) 
      else
        println(size(expr))
	    throw( LispError("Invalid arguments to unary/binary operation! Had $expr") )
      end        
	end
	
	# handles errors
	function parse( expr::Any )
      throw( LispError("Invalid type $expr") ) 
    end
	
#--------------------- CALC ---------------------#
	
    # convenience function to make everything easier
    function calc( expr::AbstractString )
      return calc( parse( Lexer.lex(expr) ) )
    end
    
	function calc( num::Num )
	  return num.n
	end	
	
	function calc( op::Binop )
	  todo = op.op
	  
	  if     todo == +
	    return calc(op.lhs) + calc(op.rhs)
	  elseif todo == -
	    return calc(op.lhs) - calc(op.rhs)
	  elseif todo == *
	    return calc(op.lhs) * calc(op.rhs)
	  elseif todo == /
	    if calc(op.rhs) == 0
	      throw( LispError("Attempting to divide by zero!") )
	    else
	      return calc(op.lhs) / calc(op.rhs)
	    end
	  elseif todo == mod
	    return mod(calc(op.lhs), calc(op.rhs))
	  else
	      throw( LispError("Trying to calc invalid Binop!?") )
	  end
	end
	
	function calc( op::Unop )
	  todo = op.op
	  
	  if todo == -
	    return (-calc(op.erand))
	  elseif todo == collatz
	    if calc(op.erand) < 0
	      throw( LispError("Attempting to collatz a negative number!") )
	    else
	      return collatz(calc(op.erand))
	    end
	  else
	      throw( LispError("Trying to calc invalid Unop!?") )
	  end
	end	
	
#------------------- HELPERS --------------------#		
	function collatz( n::Real )
	  return collatz_helper( n, 0 )
	end
	
	function collatz_helper( n::Real, num_iters::Int )
	  if n == 1
	    return num_iters
	  end
	  if mod(n,2)==0
	    return collatz_helper( n/2, num_iters+1 )
	  else
	    return collatz_helper( 3*n+1, num_iters+1 ) 
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
	
	mycalc("\RudIntTests.jl")
 
end # module RudInt

