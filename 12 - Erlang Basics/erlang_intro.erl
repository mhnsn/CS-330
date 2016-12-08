-module(erlang_intro).
-export([fib/1, area/2, sqrList/1, calcTotals/1, map/2, quickSortServer/0]).
-import(math, [pi/0, pow/2]).
-import(random, [uniform/1]).
-import(lists, [nth/2]).
-import(translate_service,[loop/0, translate/2]).

%% fib/1
%% fib will return the n'th Fibonacci number where fib(1) = 1, fib(2) = 1, and fib(N) = fib(N-1) + fib(N-2).
fib(1) -> 1;
fib(2) -> 1;
fib(N) -> fib(N-1) + fib(N-2).

%% area/2
%% Area takes either rectangle, square, circle, or triangle and the shape info, and returns its area. Note for rectangle the shape Info will be a tuple {Length, Height}, triangle's shapeInfo will be a tuple {Base, Height}, and circle and square will each get a single scalar (radius and side length, respectively). Use pattern matching.

area(rectangle, {Length, Height}) -> Length * Height;
area(triangle, {Base, Height}) -> 1/2 * Base * Height;
area(circle, Radius) -> pi() * pow(Radius, 2);
area(square, Side) -> pow(Side,2).

%% sqrList/1
%% Returns a new list in which each item of List has been squared. Use list comprehensions.

sqrList(List) -> [N*N || N <- List].

%% calcTotals/1
%% Takes a List of tuples of the form {Item, Quantity, Price} and returns a list of the form {Item, TotalPrice}. (Treat the list item by item: no need to consider the possibility of multiple tuples with the same “item” name.)

calcTotals([{Item, Quantity, Price}])		-> TotalPrice = Quantity*Price, [{Item, TotalPrice}];
calcTotals([{Item, Quantity, Price} | T])	-> calcTotals([{Item, Quantity, Price}]) ++ calcTotals(T).

%% map/2
%% Map takes a function and List and applies that function to each item in the list. To test it the call should look like this map(fun module:functionName/arity, list).

map(_blank, []) -> [];
map(Function, [H | T]) -> [Function(H) | map(Function, T)].


%% quickSortServer/0
%% quickSortServer will start a simple server (see slides, particularly slide 19 which shows the translate_service module that receives a message and sends one back) that will receive a list and sort it and send it to the caller. It should sort via a modified version of quickSort as discussed in class. quickSort will choose the pivot randomly, and you will need to implement the new pivot functionality. The module random function random:uniform(N) will be useful for this, as well as lists:nth(N, List)

%% Notes to run this thingy.
%% cd("path/to/file").
%% c(erlang_intro).
%% PID = spawn(fun erlang_intro:quickSortServer/0).
%% PID ! {self(), [5,4,3,2,16,23,324,7,1,5]}.
%% receive X -> X end.

quickSort([])	->	[];
quickSort(L) 	-> 	Random = lists:nth(random:uniform(length(L)), L),
					T = lists:delete(Random, L),
					quickSort([Smaller || Smaller <- T, Smaller =< Random]) ++
					[Random] ++
					quickSort([Larger || Larger <- T, Larger > Random]).

quickSortServer() ->
    receive
        {From, List} -> 
            From ! quickSort(List),
            quickSortServer()
	end.