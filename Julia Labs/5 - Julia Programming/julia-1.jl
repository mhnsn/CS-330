# filename: julia-1.jl

#---------------------- SHAPE ----------------------#

abstract Shape
 
type Position
  x::Real
  y::Real
end
 
type Circ <: Shape
  center::Position
  radius::Real
end
 
type Square <: Shape
  upper_left::Position
  length::Real
end
 
type Rect <: Shape
  upper_left::Position
  width::Real
  height::Real
end

#---------------------- PIXEL ----------------------#


type Pixel
  r::Real
  g::Real
  b::Real
end

#-------------------- TREEITEM ---------------------#

abstract TreeItem
 
type Person <: TreeItem
  name::AbstractString
  birthyear::Integer
  eyecolor::Symbol
  father::TreeItem
  mother::TreeItem
end
 
type Unknown <: TreeItem
end

#-------------------- FUNCTIONS --------------------#

function area(shape::Circ)
	return pi * shape.radius * shape.radius
end

function area(shape::Square)
	return shape.length * shape.length
end

function area(shape::Rect)
	return shape.width * shape.height
end


function in_shape(shape::Circ, position::Position)
	if( (shape.position.x - position.x)*(shape.position.x - position.x) + (shape.position.y - position.y)*(shape.position.y - position.y) <= shape.radius * shape.radius)
		return true
	else
		return false
	end
end

function in_shape(shape::Square, position::Position)
	if(position.x < shape.position.x || position.y < shape.position.y)
		return false
	elseif( ( position.x <= shape.position.x + shape.length) && ( position.y <= shape.position.y + shape.length))
		return true
	else
		return false
	end
end

function in_shape(shape::Rect, position::Position)
	if(position.x < shape.upper_left.x || position.y < shape.upper_left.y)
		return false
	elseif( (position.x <= shape.upper_left.x + shape.width) && (position.y <= shape.upper_left.y + shape.height) )
		return true
	else
		return false
	end
end


function greyscale(picture::Array{Pixel,2})
	return map( x -> Pixel((x.r + x.g + x.b) / 3,(x.r + x.g + x.b) / 3,(x.r + x.g + x.b) / 3), picture)
end

function invert(picture::Array{Pixel,2})
	return map( x -> Pixel(255 - x.r, 255 - x.g, 255 - x.b), picture)
end

function count_persons(tree)
	persons = 0
	if typeof(tree) == Person
		persons = persons + count_persons(tree.mother)
		persons = persons + count_persons(tree.father)
	else
		return 0
	end
	persons = persons + 1
	return persons
end

function sum_ages(tree)
	age = 0
	if typeof(tree) == Person
		age = age + sum_ages(tree.mother)
		age = age + sum_ages(tree.father)
	else
		return 0
	end
	age = age + (2016 - tree.birthyear)
	return age
end

function average_age(tree)
	return sum_ages(tree) / count_persons(tree)
end

function tree_map(f, tree)
	if typeof(tree) == Person
		newRoot = Person(tree.name, tree.birthyear, tree.eyecolor, tree.father, tree.mother)
		newRoot.father = tree_map(f,newRoot.father)
		newRoot.mother = tree_map(f,newRoot.mother)
	else
		return Unknown();
	end
	return f(newRoot)
end

function add_last_name(name::AbstractString, tree)
	tree_map((cur) -> Person(cur.name*name, cur.birthyear, cur.eyecolor, cur.father, cur.mother), tree)
end

function eye_colors(tree)
	colors = []
	
	if typeof(tree) == Person
		colors = [tree.eyecolor;eye_colors(tree.father);eye_colors(tree.mother)]
	end
	return colors
end


#---------------------- TESTS ----------------------#

origin = Position(0,0)
out = Position(50, 50)

circle1 = Circ(origin, 1/sqrt(pi))
rectangle1 = Rect(origin, 3, 3)
square1 = Square(origin, 4)

println(round(area(circle1), 3)) #1.0
println(in_shape(rectangle1, origin)) # true

ptest1 = Pixel(8, 10, 12)
arrayPix1 = fill(ptest1, (3,3))
println(join(greyscale(arrayPix1), ","))
ptest2 = Pixel(255, 255, 255)
arrayPix2 = fill(ptest2, (3,3))
println(join(invert(arrayPix2), ","))

dadTest1 = Person("Ben", 2012, :fusia, Unknown(), Unknown())
momTest1 = Person("Kaitlyn ", 2012, :brown, Unknown(), Unknown())
me = Person("Test", 2012, :ink, dadTest1, momTest1)

println(count_persons(me)) # 3
println(average_age(me)) # 4

lambdaTester1 = x -> Person("Test", x.birthyear, x.eyecolor, x.father, x.mother)

println(tree_map(lambdaTester1, me))
println(add_last_name("Name", me))

println(eye_colors(me))

tests_info =
"""
1. 1 point. area
2. 1 point. in-shape
3. 1 point. greyscale
4. 1 point. invert
5. 1 point. count_persons
6. 1 point. average_age
7. 1 point. tree_map
8. 1 point. last_name
9. 1 point. eye-colors"""

#1.0
#true
#Pixel(10.0,10.0,10.0),Pixel(10.0,10.0,10.0),Pixel(10.0,10.0,10.0),Pixel(10.0,10.0,10.0),Pixel(10.0,10.0,10.0),Pixel(10.0,10.0,10.0),Pixel(10.0,10.0,10.0),Pixel(10.0,10.0,10.0),Pixel(10.0,10.0,10.0)
#Pixel(0,0,0),Pixel(0,0,0),Pixel(0,0,0),Pixel(0,0,0),Pixel(0,0,0),Pixel(0,0,0),Pixel(0,0,0),Pixel(0,0,0),Pixel(0,0,0)
#3
#4.0
#Person("Test",2012,:ink,Person("Test",2012,:fusia,Unknown(),Unknown()),Person("Test",2012,:brown,Unknown(),Unknown()))
#Person("TestName",2012,:ink,Person("BenName",2012,:fusia,Unknown(),Unknown()),Person("Kaitlyn Name",2012,:brown,Unknown(),Unknown()))
#Any[:ink,:fusia,:brown]