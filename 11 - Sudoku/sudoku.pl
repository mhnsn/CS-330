% A Sudoku solver.  The basic idea is for each position,
% check that it is a digit with `digit`.  Then verify that the digit
% chosen doesn't violate any constraints (row, column, and cube).
% If no constraints were violated, proceed further.  If a constraint
% was violated, then backtrack to the last digit choice and move from
% there (the Prolog engine should handle this for you automatically).
% If we reach the end of the board with this scheme, it means that
% the whole thing is solved.
 
% YOU SHOULD FILL IN THE SOLVE PROCEDURE, DOWN BELOW.
 
digit(1).
digit(2).
digit(3).
digit(4).
digit(5).
digit(6).
digit(7).
digit(8).
digit(9).
 
numBetween(Num, Lower, Upper) :-
        Num >= Lower,
        Num =< Upper.
 
% cubeBounds: (RowLow, RowHigh, ColLow, ColHigh, CubeNumber)
cubeBounds(0, 2, 0, 2, 0).
cubeBounds(0, 2, 3, 5, 1).
cubeBounds(0, 2, 6, 8, 2).
cubeBounds(3, 5, 0, 2, 3).
cubeBounds(3, 5, 3, 5, 4).
cubeBounds(3, 5, 6, 8, 5).
cubeBounds(6, 8, 0, 2, 6).
cubeBounds(6, 8, 3, 5, 7).
cubeBounds(6, 8, 6, 8, 8).
 
% Given a board and the index of a column of interest (0-indexed),
% returns the contents of the column as a list.
% columnAsList: (Board, ColumnNumber, AsRow)
columnAsList([], _, []).
columnAsList([Head|Tail], ColumnNum, [Item|Rest]) :-
        nth0(ColumnNum, Head, Item),
        columnAsList(Tail, ColumnNum, Rest).
 
% given which row and column we are in, gets which cube
% is relevant.  A helper ultimately for `getCube`.
% cubeNum: (RowNum, ColNum, WhichCube)
cubeNum(RowNum, ColNum, WhichCube) :-
        cubeBounds(RowLow, RowHigh, ColLow, ColHigh, WhichCube),
        numBetween(RowNum, RowLow, RowHigh),
        numBetween(ColNum, ColLow, ColHigh).
 
% Drops the first N elements from a list.  A helper ultimately
% for `getCube`.
% drop: (InputList, NumToDrop, ResultList)
drop([], _, []):-!.
drop(List, 0, List):-!.
drop([_|Tail], Num, Rest) :-
        Num > 0,
        NewNum is Num - 1,
        drop(Tail, NewNum, Rest).
 
% Takes the first N elements from a list.  A helper ultimately
% for `getCube`.
% take: (InputList, NumToTake, ResultList)
take([], _, []):-!.
take(_, 0, []):-!.
take([Head|Tail], Num, [Head|Rest]) :-
        Num > 0,
        NewNum is Num - 1,
        take(Tail, NewNum, Rest).
 
% Gets a sublist of a list in the same order, inclusive.
% A helper for `getCube`.
% sublist: (List, Start, End, NewList)
sublist(List, Start, End, NewList) :-
        drop(List, Start, TempList),
        NewEnd is End - Start + 1,
        take(TempList, NewEnd, NewList).
 
% Given a board and cube number, gets the corresponding cube as a list.
% Cubes are 3 x 3 portions, numbered from the top left to the bottom right,
% starting from 0.  For example, they would be numbered like so:
%
% 0  1  2
% 3  4  5
% 6  7  8
%
% getCube: (Board, CubeNumber, ContentsOfCube)
getCube(Board, Number, AsList) :-
        cubeBounds(RowLow, RowHigh, ColLow, ColHigh, Number),
        sublist(Board, RowLow, RowHigh, [Row1, Row2, Row3]),
        sublist(Row1, ColLow, ColHigh, Row1Nums),
        sublist(Row2, ColLow, ColHigh, Row2Nums),
        sublist(Row3, ColLow, ColHigh, Row3Nums),
        append(Row1Nums, Row2Nums, TempRow),
        append(TempRow, Row3Nums, AsList).
 
% Given a board, solve it in-place.
% After calling `solve` on a board, the board should be fully
% instantiated with a satisfying Sudoku solution.
 
% ---- PUT CODE HERE ---
% ---- PUT CODE HERE ---
boardRows(Board,Rows) :-
	Rows = Board.
	
makeCubeStrings(Board, AsList) :-
	Cubes = [Cub0, Cub1, Cub2, Cub3, Cub4, Cub5, Cub6, Cub7, Cub8],
	getCube(Board,0,Cub0),
	getCube(Board,1,Cub1),
	getCube(Board,2,Cub2),
	getCube(Board,3,Cub3),
	getCube(Board,4,Cub4),
	getCube(Board,5,Cub5),
	getCube(Board,6,Cub6),
	getCube(Board,7,Cub7),
	getCube(Board,8,Cub8),
	append(Cub0,S0),
	append(Cub1,S1),
	append(Cub2,S2),
	append(Cub3,S3),
	append(Cub4,S4),
	append(Cub5,S5),
	append(Cub6,S6),
	append(Cub7,S7),
	append(Cub8,S8),
	AsList = [S0, S1, S2, S3, S4, S5, S6, S7, S8].

assignRow(Row, Result) :- 
	digit(A), digit(B), digit(C),
	digit(D), digit(E), digit(F),
	digit(G), digit(H), digit(I),
	Row = [A, B, C, D, E, F, G, H, I],
	is_set(Row),
	Result = Row.
	
test :-
	Board = [[_, _, _, 7, 9, _, 8, _, _],
			[_, _, _, _, _, 4, 3, _, 7],
			[_, _, _, 3, _, _, _, 2, 9],
			[7, _, _, _, 2, _, _, _, _],
			[5, 1, _, _, _, _, _, 4, 8],
			[_, _, _, _, 5, _, _, _, 1],
			[1, 2, _, _, _, 8, _, _, _],
			[6, _, 4, 1, _, _, _, _, _],
			[_, _, 3, _, 6, 2, _, _, _]],
	solve(Board),
	printBoard(Board).

solve(Board) :- 
	length(Board, 9),
	maplist(same_length(Board), Board),
	digit(A), digit(B), digit(C),
	digit(D), digit(E), digit(F),
	digit(G), digit(H), digit(I),
	Set = [A, B, C, D, E, F, G, H, I],
	maplist(assignRow, Board, R),
	transpose(R,Cols),
	maplist(is_set, Cols),
	makeCubeStrings(R,Cubes),
	maplist(isCorrectEntry,A,R,Cols,Cubes).
	
% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.
% all_different([H | T]) :- member(H, T), !, fail.
% all_different([_ | T]) :- all_different(T).
% all_different([_]).
	
isCorrectEntry(S00,Row,Col,Cub) :-
			(nonvar(S00); var(S00), digit(S00), is_set(Row), is_set(Col), is_set(Cub)).
 
% ---- PUT CODE HERE ---
% ---- PUT CODE HERE ---
 
% Prints out the given board.
printBoard([]).
printBoard([Head|Tail]) :-
        write(Head), nl,
        printBoard(Tail).
 
test1(Board) :-
        Board = [[2, _, _, _, 8, 7, _, 5, _],
                 [_, _, _, _, 3, 4, 9, _, 2],
                 [_, _, 5, _, _, _, _, _, 8],
                 [_, 6, 4, 2, 1, _, _, 7, _],
                 [7, _, 2, _, 6, _, 1, _, 9],
                 [_, 8, _, _, 7, 3, 2, 4, _],
                 [8, _, _, _, _, _, 4, _, _],
                 [3, _, 9, 7, 4, _, _, _, _],
                 [_, 1, _, 8, 2, _, _, _, 5]],
        solve(Board),
        printBoard(Board).
 
test2(Board) :-
        Board = [[_, _, _, 7, 9, _, 8, _, _],
                 [_, _, _, _, _, 4, 3, _, 7],
                 [_, _, _, 3, _, _, _, 2, 9],
                 [7, _, _, _, 2, _, _, _, _],
                 [5, 1, _, _, _, _, _, 4, 8],
                 [_, _, _, _, 5, _, _, _, 1],
                 [1, 2, _, _, _, 8, _, _, _],
                 [6, _, 4, 1, _, _, _, _, _],
                 [_, _, 3, _, 6, 2, _, _, _]],
        solve(Board),
        printBoard(Board).