module Lexer
using Error

export lex

function lex(source)
  if source[1] != '('
    try
		    return parse(source)
    catch
      throw(LispError("Incomplete Expression: $source"))
    end
	end
  if source[end] != ')'
		throw(LispError("Incomplete expression: $source"))
	end
  source = source[2:end - 1]
	expr = split_exps(source)
	out = Any[]
  for x in expr
    i = lex(x)
    push!(out, i)
  end
  return out
end

##
## Below are a few useful utility functions. These should come in handy when
## implementing `parse`. We don't want to spend the day implementing parenthesis
## counting, after all.
##


# Remove from a string anything in between a ; and a linebreak
function remove_comments(source)
  replace(source, r";.*\n", "\n")
end

## Given a string and the index of an opening parenthesis, determines
## the index of the matching closing paren.
function find_matching_paren(source, start=1)
  @assert source[start] == '('
  pos = start
  open_brackets = 1
  while open_brackets > 0
    pos += 1
    #if length(source) == pos
    if length(source) < pos
      throw(LispError("Incomplete expression: $(source[start:end])"))
    end
    if source[pos] == '('
      open_brackets += 1
    end
    if source[pos] == ')'
      open_brackets -= 1
    end
  end
  return pos
end

## Splits a source string into subexpressions
## that can be parsed individually.

## Example:

##     > split_exps("foo bar (baz 123)")
##     ["foo", "bar", "(baz 123)"]
function split_exps(source)
  rest = strip(source)
  exps = AbstractString[]
  while !isempty(rest)
    exp, rest = first_expression(rest)
    push!(exps, exp)
  end
  return exps
end

## Split string into (exp, rest) where exp is the
## first expression in the string and rest is the
## rest of the string after this expression.
function first_expression(source)
  source = strip(source)
  if source[1] == '\''
    exp, rest = first_expression(source[2:end])
    return "'" * exp, rest
  elseif source[1] == '('
    last = find_matching_paren(source)
    return source[1:last], source[last + 1:end]
  else
    m = match(r"^[^\s)']+", source)
    if typeof(m) == Void
      throw(ParseError("Syntax Error"))
    end
    _end = m.offset + length(m.match) - 1
    atom = source[1:_end]
    return atom, source[_end+1:end]
  end
end
end # module
