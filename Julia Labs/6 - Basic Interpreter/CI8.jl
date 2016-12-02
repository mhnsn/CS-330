# If you're getting errors about not being able to load this, you may
# need to add the current directory to the module load path:
#
# push!(LOAD_PATH, ".")
#
# This is how I make sure it's reloaded when something changes:
# workspace(); reload("CI8"); using CI8;
#
# This is a helper function to run through a bunch of tests in a file:
# CI8.calcf( "./tests.txt" )
#

module CI8

using Error
using Lexer
using Images
using Cairo

export parse, calc, NumVal, ClosureVal, MatrixVal

#
# =========================================================
# =========================================================
#
#  The high performance primitives you must bind in.
#
# =========================================================
# =========================================================
#

function simple_load( img_path::AbstractString )
  im = Images.load( img_path );
  tmp = Images.separate(im);
  d = Images.data( tmp );
  d = d[:,:,1];  # just the r channel
  d = convert( Array{Float32,2}, d );
  return d    
end

function simple_save( output::Array, img_path::AbstractString )
    output[ output .> 1.0 ] = 1.0
    output[ output .< 0.0 ] = 0.0
    tmpc = convert( Array{UInt32,2}, floor(output*255.0) )
    tmp_output =  tmpc + tmpc*256 + tmpc*65536 + 0xff000000
    c2 = CairoImageSurface( transpose(tmp_output), Cairo.FORMAT_ARGB32 )
    write_to_png( c2, ae.fn )
    return 42
end

#-------------------------------------------------------------

function render_text( text_str::AbstractString, xpos, ypos )

  data = Matrix{UInt32}( 256, 256 );
  c = CairoImageSurface( data, Cairo.FORMAT_ARGB32 );
  cr = CairoContext( c );

  set_source_rgb( cr, 1., 1., 1. );
  rectangle( cr, 0., 0., 256., 256. );
  fill( cr );

  set_source_rgb( cr, 0, 0, 0 );
  select_font_face( cr, "Sans", Cairo.FONT_SLANT_NORMAL,
                    Cairo.FONT_WEIGHT_BOLD );
  set_font_size( cr, 90.0 );

  move_to( cr, xpos, ypos );
  show_text( cr, text_str );

  # tmp is an Array{UInt32,2}
  tmp = cr.surface.data;

  # grab just the blue channel, and convert the array to an array of floats
  tmp2 = convert( Array{Float32,2}, tmp & 0x000000ff ) / 255.0;
  tmp2 = convert( Array{Float32,2}, tmp2 );

  return tmp2
end

#-------------------------------------------------------------

function emboss( img::Array )
  f = [ -2. -1. 0.
        -1.  1. 1.
         0.  1. 1. ];
  f = convert( Array{Float32,2}, f );

  es = conv2( f, img );
  es = es[1:256,1:256];
  return es    
end

#-------------------------------------------------------------

function drop_shadow( img::Array )
  foo = convert( Array{Float32,2}, gaussian2d(5.0,[25,25]) );
  foo = foo / maximum(foo);
  ds = conv2( foo, img );
  ds = ds[13:256+12,13:256+12];
  ds = ds / sum(foo);
  return ds
end

#-------------------------------------------------------------

# assumes img is black-on-white
function inner_shadow( img::Array )
  foo = convert( Array{Float32,2}, gaussian2d(5.0,[25,25]) );
  foo = foo / maximum(foo);
  is = conv2( foo, 1.0-img );
  is = is[8:251+12,8:251+12];
  is = is / sum(foo);
  is = max( is, img );
  return is
end

#
# ===================================================
#

abstract Environment
abstract OWL
abstract RetVal

# Return values ---------------------------------

type NumVal <: RetVal
    n::Real
end

type MatrixVal <: RetVal
    n::Array{Float32,2}
end

type ClosureVal <: RetVal
    param::Symbol
    body::OWL
    env::Environment  # this is the environment at definition time!
end

# Environments  ---------------------------------

type mtEnv <: Environment
end

type CEnvironment <: Environment
    name::Symbol
    value::RetVal
    parent::Environment
end

# AST nodes  ---------------------------------

type FunDef <: OWL
    formal_parameter::Symbol
    fun_body::OWL
end

type FunApp <: OWL
    fun_expr::OWL
    arg_expr::OWL
end

type Num <: OWL
    n::Real
end

type Plus <: OWL
    lhs::OWL
    rhs::OWL
end

type Minus <: OWL
    lhs::OWL
    rhs::OWL
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


# (render_text "Hello" (+ 25 100) 400)
type RenderText <: OWL
    the_words::AbstractString
    xpos::OWL
    ypos::OWL
end

#
# ===================================================
# ===================================================
# ===================================================
#

function parse( expr::Real )
    return Num( expr ) # return a "Num" type object, with the "n" member set to "expr"
end

function parse( expr::Symbol )
    return Id( expr )
end

function parse( expr::Array{Any} )
    
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
        zero_branch = parse( expr[3] )
        nonzero_branch = parse( expr[4] )
        return If0( condition, zero_branch, nonzero_branch )

    elseif op_symbol == :with    # (with x (+ 5 1) (+ x x) )
        sym = expr[2]
        binding_expr = parse( expr[3] )
        body = parse( expr[4] )
        return With( sym, binding_expr, body )

    elseif op_symbol == :lambda
        return FunDef( expr[2], parse(expr[3]) )

    elseif op_symbol == :render_text
        return RenderText( expr[2], parse(expr[3]), parse(expr[4]) )
        
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
# ===================================================
# ===================================================
#

# A simple pretty printer to help us inspect the AST

function pp( ast::OWL, depth::Int )
    throw( LispError( "PP - Unknown node!" ) )
end


function pp( ast::FunDef, depth::Int )
    print( "(lambda ", ast.formal_parameter, " " )
    pp( ast.fun_body, depth+1 )
    print( ")" )
end

function pp( ast::FunApp, depth::Int )
    print( "(" )
    pp( ast.fun_expr, depth+1 )
    print( " " )
    pp( ast.arg_expr, depth+1 )    
    print( ")" )
end

function pp( ast::Num, depth::Int )
    print( ast.n )
end

function pp( ast::Plus, depth::Int )
    print( "(+ " )
    pp( ast.lhs, depth+1 )
    print( " " )
    pp( ast.rhs, depth+1 )    
    print( ")" )
end

function pp( ast::Minus, depth::Int )
    print( "(- " )
    pp( ast.lhs, depth+1 )
    print( " " )
    pp( ast.rhs, depth+1 )    
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


# ===================================================
#
# Program analysis
#
#   constant propagation / arithmetic expression simplification
#   semantic sugar  (with -> lambda)
#   dead code removal
#
#   tail call optimization
#   automatic parallelization
#   code deduplication
#   

function analyze( ast::OWL )
    throw( LispError( "Analyze - Unknown node!" ) )
end

function analyze( ast::Num )
    return ast
end

function analyze( ast::Id )
    return ast
end

function analyze( ast::Plus )
    lhs = analyze( ast.lhs )
    rhs = analyze( ast.rhs )

    if typeof(lhs) == Num && typeof(rhs) == Num
        return Num( lhs.n + rhs.n )
    else
        return Plus( lhs, rhs )
    end
    
end

function analyze( ast::Minus )
    lhs = analyze( ast.lhs )
    rhs = analyze( ast.rhs )

    if typeof(lhs) == Num && typeof(rhs) == Num
        return Num( lhs.n - rhs.n )
    else
        return Minus( lhs, rhs )
    end
    
end

function analyze( ast::With )
    fd = FunDef( ast.name, analyze( ast.body ) )
    fa = FunApp( fd, analyze( ast.binding_expr ) )
    return fa
end

function analyze( ast::FunDef )
    return FunDef( ast.formal_parameter, analyze( ast.fun_body) )
end

function analyze( ast::FunApp )
    return FunApp( analyze(ast.fun_expr), analyze( ast.arg_expr) )
end

function analyze( ast::If0 )

    cond = analyze(ast.condition)

    if typeof( cond ) == Num

        if cond.n == 0
            return analyze(ast.zero_branch)
        else
            return analyze(ast.nonzero_branch)            
        end
        
    else
        return If0( cond, analyze(ast.zero_branch), analyze(ast.nonzero_branch) )
    end
    
end

#
# ===================================================
# ===================================================
# ===================================================
#

# convenience function to make everything easier
function calc( expr::AbstractString )
    lxd = Lexer.lex( expr )
    ast = parse( lxd )

    ast = analyze( ast )

    pp( ast, 0 );
    print("\n")

    println( "---------- Return value -----------" )
    
    return calc( ast )
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
            println( "---------- Analysis returned -----------" )
            println( calc( cur_prog ) )
            # try
            #     println( calc( cur_prog ) )
            # catch errobj
            #     println( ">> ERROR: lxd" )
            #     lxd = Lexer.lex( cur_prog )
            #     println( lxd )
            #     println( ">> ERROR: ast" )
            #     ast = parse( lxd )
            #     println( ast )
            #     println( ">> ERROR: rethrowing error" )
            #     throw( errobj )
            # end
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
# ===================================================
# ===================================================

function calc( ast::OWL )
    return @time calc( ast, mtEnv() )
end

function calc( ae::Num, env::Environment )
    return NumVal( ae.n )
end

function calc( ae::Plus, env::Environment )
    lhs = calc( ae.lhs, env )
    rhs = calc( ae.rhs, env )
    return NumVal( lhs.n + rhs.n )
end

function calc( ae::Minus, env::Environment )
    lhs = calc( ae.lhs, env )
    rhs = calc( ae.rhs, env )
    return NumVal( lhs.n - rhs.n )
end

function calc( ae::If0, env::Environment )
    cond = calc( ae.condition, env )

    if typeof( cond ) != NumVal
        throw( LispError( "Illegal expression in if0 condition" ) )
    end
    
    if cond.n == 0
        return calc( ae.zero_branch, env )
    else
        return calc( ae.nonzero_branch, env )
    end
end

function calc( ae::With, env::Environment )
    # NOTE: we never call this anymore!!!
    throw( LispError( "Shouldn't ever call this!" ) )
end

function calc( ae::Id, env::Environment )
    if env == mtEnv()
        println( "couldn't find $ae" )
        throw( LispError( "WARGH! Couldn't find symbol!" ) )
    elseif env.name == ae.name
        return env.value
    else
        return calc( ae, env.parent )
    end
end

function calc( ae::FunDef, env::Environment )
    return ClosureVal( ae.formal_parameter, ae.fun_body, env )
end

function calc( ae::FunApp, env::Environment )

    # the function expression should result in a closure
    the_closure = calc( ae.fun_expr, env )

    if typeof( the_closure ) != ClosureVal
        throw( LispError( "Tried to call non-closure!" ) )
    end

    # extend the current environment by binding the actual parameter to the formal parameter
    actual_parameter = calc( ae.arg_expr, env )

    formal_parameter = the_closure.param
    extended_env = CEnvironment( formal_parameter, actual_parameter, the_closure.env )
    
    # support recursion!
    if typeof( actual_parameter ) == ClosureVal
        actual_parameter.env = extended_env
    end

    return calc( the_closure.body, extended_env )
end


function calc( ae::RenderText, env::Environment )
    xpos = calc( ae.xpos, env )
    ypos = calc( ae.ypos, env )

    retval = render_text( ae.the_words, xpos.n, ypos.n )

    return MatrixVal( retval )
end

#
# ===================================================
# ===================================================
# ===================================================
#

end # module
