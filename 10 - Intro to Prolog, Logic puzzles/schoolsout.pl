% Problem #1, "School's out"
% each teacher is going on a trip to a different state for a different activity

teacher(Appleton).
teacher(Gross).
teacher(Knight).
teacher(McEvoy).
teacher(Parnell).

subject(English).
subject(Gym).
subject(History).
subject(Math).
subject(Science).

state(California).
state(Florida).
state(Maine).
state(Oregon).
state(Virginia).

activity(antiquing).
activity(camping).
activity(sightseeing).
activity(spelunking).
activity(water-skiing).
 
solve :-
	subject(AppletonSubj), subject(GrossSubj), subject(KnightSubj), subject(McEvoySubj), subject(ParnellSubj),
%		all_different([AppletonSubj, GrossSubj, KnightSubj, McEvoySubj, ParnellSubj]),
	state(AppletonState), state(GrossState), state(KnightState), state(McEvoyState), state(ParnellState),
		all_different([AppletonState, GrossState, KnightState, McEvoyState, ParnellState]),
	activity(AppletonAct), activity(GrossAct), activity(KnightAct), activity(McEvoyAct), activity(ParnellAct),
		all_different([AppletonAct, GrossAct, KnightAct, McEvoyAct, ParnellAct]),
    Solutions = [ 	[Appleton	, AppletonState	, AppletonSubj	, AppletonAct	],
					[Gross		, GrossState	, GrossSubj		, GrossAct		],
					[Knight		, KnightState	, KnightSubj	, KnightAct		],
					[McEvoy		, McEvoyState	, McEvoySubj	, McEvoyAct		],
					[Parnell	, ParnellState	, ParnellSubj	, ParnellAct	]  ],

%Negation isn't difficult, but it's tricky. Here's what you need to remember about negation:
%	Whether negation succeeds or fails, it cannot ever unify (instantiate) anything.
%	You can use negation to prevent certain unifications (e.g. "I am not a robot") but you cannot use it to find out anything.

%The underscore, _, is a variable that could unify with anything, and you don't care what.


	% 1. Ms. Gross teaches either math or science.
	%	If Ms. Gross is going antiquing, then she is going to Florida.
	%	Otherwise she is going to California.
	( member(	[Gross	, _ 			, Math		, _			],	Solutions);
	member(		[Gross	, _				, Science	, _ 		],	Solutions)),
	( member(	[Gross	, Florida 		, _			, antiquing	],	Solutions);
	member(		[Gross	, California	, _			, _			],	Solutions)),

	% 2. The science teacher (who is going water-skiing) is going to to travel to either California or Florida.
	%	Mr. McEvoy (who is the history teacher) is going to either Maine or Oregon.
	member(	[_		, _			, Science	, water-skiing	], Solutions),
	(member([_		, California, Science	, water-skiing	], Solutions); 
	member(	[_		, Florida	, Science	, water-skiing	], Solutions)),
	member( [McEvoy	, _			, History	, _				], Solutions),
	(member([McEvoy	, Maine		, _ 		, _				], Solutions);
	member(	[McEvoy	, Oregon	, _ 		, _				], Solutions)),

	% 3. If the woman who is going to Virginia is the English teacher, then she is Ms. Appleton;
	%	otherwise she is Ms. Parnell (who is going spelunking).
	(member([Appleton	, Virginia	, English	, _			 ], Solutions);
	member(	[Parnell	, Virginia	, _			, spelunking ], Solutions)),
	member(	[Parnell	, _			, _			, spelunking ], Solutions),

	% 4. The person who is going to Maine (who isn't the Gym teacher) isn't the one who's going sightseeing.
	(\+ member([Appleton	, Maine	, _		, sightseeing	], Solutions)),
	(\+ member([Gross		, Maine	, _		, sightseeing	], Solutions)),
	(\+ member([Parnell		, Maine	, _		, sightseeing	], Solutions)),
	(\+ member([Knight		, Maine	, _		, sightseeing	], Solutions)),
	(\+ member([McEvoy		, Maine	, _		, sightseeing	], Solutions)),

	(\+ member([Appleton	, Maine	, Gym	, _				], Solutions)),
	(\+ member([Gross		, Maine	, Gym	, _				], Solutions)),
	(\+ member([Parnell		, Maine	, Gym	, _				], Solutions)),
	(\+ member([Knight		, Maine	, Gym	, _				], Solutions)),
	(\+ member([McEvoy		, Maine	, Gym	, _				], Solutions)),

	% 5. Ms. Gross isn't the woman who is going camping.
	%	One woman is going antiquing on her vacation.
	(\+ member(	[Gross		, _	, English	, camping	], Solutions)),
	(\+ member(	[Gross		, _	, History	, camping	], Solutions)),
	(\+ member(	[Gross		, _	, Gym		, camping	], Solutions)),
	(\+ member(	[Gross		, _	, Math		, camping	], Solutions)),
	(\+ member(	[Gross		, _	, Science	, camping	], Solutions)),
	
	( member(	[Gross		, _	, _	, antiquing	], Solutions);
	member(		[Appleton	, _	, _	, antiquing	], Solutions);
	member(		[Parnell	, _	, _	, antiquing	], Solutions)),
 
    tell(Appleton	, AppletonState	, AppletonSubj	, AppletonAct	),
    tell(Gross		, GrossState	, GrossSubj		, GrossAct		),
    tell(Knight		, KnightState	, KnightSubj	, KnightAct		),
    tell(McEvoy		, McEvoyState	, McEvoySubj	, McEvoyAct		),
    tell(Parnell	, ParnellState	, ParnellSubj	, ParnellAct	).
 
% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.
all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

tell(X, Y, Z, A) :-
	write(X), write(' is going to '),
	write(Y), write(' to '),
	write(A), write('. They teach '),
	write(Z), write('.'), nl.