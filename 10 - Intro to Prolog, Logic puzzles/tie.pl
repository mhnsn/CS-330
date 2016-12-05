% Problem #1, "It's a tie", Dell Logic Puzzles, October 1999
% Each man (mr so-and-so) got a tie from a relative.

tie(cupids).
tie(happy_faces).
tie(leprechauns).
tie(reindeer).
 
mr(crow).
mr(evans).
mr(hurley).
mr(speigler).
 
relative(daughter).
relative(father_in_law).
relative(sister).
relative(uncle).
 
solve :-
    tie(CrowTie), tie(EvansTie), tie(HurleyTie), tie(SpeiglerTie),
		all_different([CrowTie, EvansTie, HurleyTie, SpeiglerTie]),

    %This predicate first chooses some ties.
    %It will choose the same tie for everybody, then repeatedly backtrack
    %choosing different ties, until the all_different predicate is satisfied.
    %It then does the same thing for relatives.
    %There is a more efficent way of doing this, but this is the simplest.
	
    relative(CrowRelative), relative(EvansRelative), relative(HurleyRelative), relative(SpeiglerRelative),
		all_different([CrowRelative, EvansRelative, HurleyRelative, SpeiglerRelative]),
		
    %each list is a triple [mr, tie, relative]
    %Notice we specify the mr, this is arbitrary we could have specified the tie
    %as long as we cover all three dimentions
    
	Triples = [ [crow, CrowTie, CrowRelative],
                [evans, EvansTie, EvansRelative],
                [hurley, HurleyTie, HurleyRelative],
                [speigler, SpeiglerTie, SpeiglerRelative] ],
 
    % 1. The tie with the grinning leprechauns wasn't a present from a daughter.
    %The underscore, _, is a variable that could unify with anything, and you don't care what.
    \+ member([_, leprechauns, daughter], Triples),
	%Negation isn't difficult, but it's tricky. Here's what you need to remember about negation:
	%Whether negation succeeds or fails, it cannot ever unify (instantiate) anything.
	%You can use negation to prevent certain unifications, as above, but you cannot use it to find out anything.

    % 2. Mr. Crow's tie features neither the dancing reindeer nor the yellow happy faces.
    \+ member([crow, reindeer, _], Triples),
    \+ member([crow, happy_faces, _], Triples),
 
    % 3. Mr. Speigler's tie wasn't a present from his uncle.
    \+ member([speigler, _, uncle], Triples),
 
    % 4. The tie with the yellow happy faces wasn't a gift from a sister.
    \+ member([_, happy_faces, sister], Triples),
 
    % 5. Mr Evans and Mr. Speigler own the tie with the grinning leprechauns
    %    and the tie that was a present from a father-in-law, in some order.
    ( (member([evans, leprechauns, _], Triples),
       member([speigler, _, father_in_law], Triples)) ;
 
      (member([speigler, leprechauns, _], Triples),
       member([evans, _, father_in_law], Triples)) ),
 
    % 6. Mr. Hurley received his flamboyant tie from his sister.
    member([hurley, _, sister], Triples),
 
    tell(crow, CrowTie, CrowRelative),
    tell(evans, EvansTie, EvansRelative),
    tell(hurley, HurleyTie, HurleyRelative),
    tell(speigler, SpeiglerTie, SpeiglerRelative).
 
% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.
all_different([_]).
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
 
tell(X, Y, Z) :-
    write('Mr. '), write(X), write(' got the '), write(Y),
    write(' tie from his '), write(Z), write('.'), nl.