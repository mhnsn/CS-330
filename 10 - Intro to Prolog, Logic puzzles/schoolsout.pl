% Problem #1, "School's out"
% each teacher is going on a trip to a different state for a different activity

teacher(appleton).
teacher(gross).
teacher(knight).
teacher(mcevoy).
teacher(parnell).

subject(english).
subject(gym).
subject(history).
subject(math).
subject(science).

state(california).
state(florida).
state(maine).
state(oregon).
state(virginia).

activity(antiquing).
activity(camping).
activity(sightseeing).
activity(spelunking).
activity(waterskiing).


solve :-
	subject(AppletonSubj), subject(GrossSubj), subject(KnightSubj), subject(McevoySubj), subject(ParnellSubj),
		all_different([AppletonSubj, GrossSubj, KnightSubj, McevoySubj, ParnellSubj]),
	state(AppletonState), state(GrossState), state(KnightState), state(McevoyState), state(ParnellState),
		all_different([AppletonState, GrossState, KnightState, McevoyState, ParnellState]),
	activity(AppletonAct), activity(GrossAct), activity(KnightAct), activity(McevoyAct), activity(ParnellAct),
		all_different([AppletonAct, GrossAct, KnightAct, McevoyAct, ParnellAct]),
    Solutions = [ 	[appleton	, AppletonState	, AppletonSubj	, AppletonAct	],
					[gross		, GrossState	, GrossSubj		, GrossAct		],
					[knight		, KnightState	, KnightSubj	, KnightAct		],
					[mcevoy		, McevoyState	, McevoySubj	, McevoyAct		],
					[parnell	, ParnellState	, ParnellSubj	, ParnellAct	]  ],

	%	Negation isn't difficult, but it's tricky. Here's what you need to remember about negation:
	%	Whether negation succeeds or fails, it cannot ever unify (instantiate) anything.
	%	You can use negation to prevent certain unifications (e.g. "I am not a robot") but you cannot use it to find out anything.
	%	The underscore, _, is a variable that could unify with anything, and you don't care what.

	% 1. Ms. gross teaches either math or science.
	%	If Ms. gross is going antiquing, then she is going to florida.
	%	Otherwise she is going to california.
	(member(	[gross	, _ 			, math		, _			],	Solutions);
	member(		[gross	, _				, science	, _ 		],	Solutions)),
	( member(	[gross	, florida 		, _			, antiquing	],	Solutions);
	member(		[gross	, california	, _			, _			],	Solutions)),

	% 2. The science teacher (who is going waterskiing) is going to travel to either california or florida.
	%	Mr. mcevoy (who is the history teacher) is going to either maine or oregon.
	member(	[_		, _			, science	, waterskiing	], Solutions),
	(member([_		, california, science	, waterskiing	], Solutions); 
	member(	[_		, florida	, science	, waterskiing	], Solutions)),
	member( [mcevoy	, _			, history	, _				], Solutions),
	(member([mcevoy	, maine		, history 	, _				], Solutions);
	member(	[mcevoy	, oregon	, history	, _				], Solutions)),

	% 3. If the woman who is going to virginia is the english teacher, then she is Ms. appleton;
	%	otherwise she is Ms. parnell (who is going spelunking).
	(member([appleton	, virginia	, english	, _			 ], Solutions);
	member(	[parnell	, virginia	, _			, spelunking ], Solutions)),
	member(	[parnell	, _			, _			, spelunking ], Solutions),

	% 4. The person who is going to maine (who isn't the gym teacher) isn't the one who's going sightseeing.
	(\+ member([_			, maine	, gym	, _				], Solutions)),
	(\+ member([_			, maine	, _		, sightseeing	], Solutions)),	

	% 5. Ms. gross isn't the woman who is going camping.
	%	One woman is going antiquing on her vacation.
	(\+ member(	[gross		, _	, _	, camping	], Solutions)),
	( member(	[gross		, _	, _	, antiquing	], Solutions);
	member(		[appleton	, _	, _	, antiquing	], Solutions);
	member(		[parnell	, _	, _	, antiquing	], Solutions)),
 
    tell(appleton	, AppletonState	, AppletonSubj	, AppletonAct	),
    tell(gross		, GrossState	, GrossSubj		, GrossAct		),
    tell(knight		, KnightState	, KnightSubj	, KnightAct		),
    tell(mcevoy		, McevoyState	, McevoySubj	, McevoyAct		),
    tell(parnell	, ParnellState	, ParnellSubj	, ParnellAct	).
 
% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(X, Y, Z, A) :-
	write(X), write(' is going to '),
	write(Y), write(' for '),
	write(A), write(', and teaches '),
	write(Z), write('.'), nl.