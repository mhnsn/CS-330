% Problem #1, "School's out"
% each teacher is going on a trip to a different state for a different activity

customer(hugh).
customer(ida).
customer(jeremy).
customer(leroy).
customer(stella).

rose(cottage).
rose(golden).
rose(mountain).
rose(pink).
rose(sweet).

event(anniversary).
event(charity).
event(retirement).
event(prom).
event(wedding).

item(balloons).
item(candles).
item(chocolates).
item(placecards).
item(streamers).


solve :-
	rose(HughRose), rose(IdaRose), rose(JeremyRose), rose(LeroyRose), rose(StellaRose),
		all_different([HughRose, IdaRose, JeremyRose, LeroyRose, StellaRose]),
	event(HughEvent), event(IdaEvent), event(JeremyEvent), event(LeroyEvent), event(StellaEvent),
		all_different([HughEvent, IdaEvent, JeremyEvent, LeroyEvent, StellaEvent]),
	item(HughItem), item(IdaItem), item(JeremyItem), item(LeroyItem), item(StellaItem),
		all_different([HughItem, IdaItem, JeremyItem, LeroyItem, StellaItem]),
    Solutions = [ 	[hugh	, HughEvent		, HughRose	, HughItem	],
					[ida	, IdaEvent		, IdaRose	, IdaItem	],
					[jeremy	, JeremyEvent	, JeremyRose, JeremyItem],
					[leroy	, LeroyEvent	, LeroyRose	, LeroyItem	],
					[stella	, StellaEvent	, StellaRose, StellaItem]  ],

	%	Negation isn't difficult, but it's tricky. Here's what you need to remember about negation:
	%	Whether negation succeeds or fails, it cannot ever unify (instantiate) anything.
	%	You can use negation to prevent certain unifications (e.g. "I am not a robot") but you cannot use it to find out anything.
	%	The underscore, _, is a variable that could unify with anything, and you don't care what.
	
	% 1. Jeremy made a purchase for the senior prom.
	% 	 Stella (who didn't chose flowers for a weddding) picked the cottage beauty variety.
		member([jeremy	, prom 		, _ 		, _ ], Solutions),
		member([stella	, _			, cottage	, _	], Solutions),
	\+	member([stella	, wedding 	, _ 		, _ ], Solutions),

	
	% 2. Hugh (who selected the pink paradise blooms) didn't choose flowers for either the charity auction or the wedding
		member([hugh , _ 		, pink	, _ ], Solutions),
	\+  member([hugh , charity	, _		, _ ], Solutions),
	\+  member([hugh , wedding	, _ 	, _ ], Solutions),
	
	% 3. The cutomer who picked roses for an anniversary party also bought streamers.
	%    The one shopping for a wedding chose the balloons.
		member([_ , anniversary	, _ 	, streamers ], Solutions),
		member([_ , wedding		, _ 	, balloons	], Solutions),	
	
	% 4. The customer who bought the sweet dreams variety also bought gourmet chocolates
	% 	 Jeremy didn't pick the mountain bloom variety.
		member([_ 		, _	, sweet		, chocolates ], Solutions),
	\+  member([jeremy	, _ , mountain	, _ 		 ], Solutions),
	
	% 5. Leroy was shopping for the retirement banquet.
	%	 The customer in charge decorating the prom also bought the candles.
		member([leroy , retirement 	, _ , _ 		], Solutions),
		member([_	  , prom 		, _ , candles	], Solutions),
	
    tell(hugh	, HughEvent		, HughRose	, HughItem	),
    tell(ida	, IdaEvent		, IdaRose	, IdaItem	),
    tell(jeremy	, JeremyEvent	, JeremyRose, JeremyItem),
    tell(leroy	, LeroyEvent	, LeroyRose	, LeroyItem	),
    tell(stella	, StellaEvent	, StellaRose, StellaItem).
 
% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(X, Y, Z, A) :-
	write(X), write(' is buying for a '),
	write(Y), write(' and bought '),
	write(Z), write(' roses and '),
	write(A), write('.'), nl.