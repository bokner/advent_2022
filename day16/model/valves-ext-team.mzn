% Valves (Advent of Code, day 16)

% part 1: ~7 secs (chuffed)
% part 2: ~8 mins (chuffed)
%%%%%
% Input %
%%%%%
int: minutes; 

set of int: MINUTES = 1..minutes;
set of int: MINUTES0 =  0..minutes;

enum valves;

enum team; % = {human, elephant};

array[valves] of int: rates;

array[valves] of set of valves: connections;

int: upper_bound;

set of valves: valves_with_rates = {v | v in valves where rates[v] > 0};
%%%%%%%%%%%%
% Decision variables %
%%%%%%%%%%%%
array[MINUTES0, team] of var set of valves_with_rates: open_valves;

array[MINUTES0, team] of var valves: position;

%% At the start:
%% Initial position is at AA
constraint forall(t in team)(
  position[0, t] = valves[1]
);
constraint forall(t in team)(
  open_valves[0, t] = {}
 );
%%%%%%%%%%%%%%%%%%%%

include "globals.mzn";
%%%%%%%%%%%
% Main constraints %
%%%%%%%%%%%

%% Open the valve with rate > 0
constraint forall(m in MINUTES, t in team) (
     open_valves[m, t] = open_valves[m-1, t] union (if rates[position[m, t]] > 0 then {position[m, t]} else {} endif) 
);

%% Next move
constraint forall(m in MINUTES, t in team)(
    position[m, t] in connections[position[m-1, t]] 
    %diff open_valves[m-1, t]
);

%% Only one team member opens the valve
constraint forall(m in MINUTES)(
  all_disjoint([open_valves[m, t] | t in team])
);

%% Do not  visit the valve once it's open
constraint forall(m in MINUTES)(
  alldifferent([position[m, t]  | t in team where position[m, t]  in valves_with_rates]) 
); 

%% The valve is opened only once
constraint forall(t in team)(
  alldifferent([position[m, t] | m in MINUTES where position[m, t]  in valves_with_rates])
);





%%%%%%%%%%
%% Objective %%
%%%%%%%%%%
var 0..upper_bound: total_flow;

array[MINUTES0] of var 0..sum(rates): flow;
constraint flow[0] = 0;
constraint forall(m in MINUTES)(
  flow[m] = flow[m-1] + sum(t in team)(rates[position[m-1, t]])
  %sum(v in open_valves[m-1])(rates[v])
);

%%%%%%%%%%
%% Objective %%
%%%%%%%%%%
constraint total_flow =   sum(flow); 
%  sum(m in MINUTES, t in team)(rates[position[m, t]] * (minutes - m));

solve maximize total_flow;

%%%%%%%%%%%%
%% Performance  %%%
%%%%%%%%%%%%

%% Symmetry breaks:
%% It does not make difference who will be opening the valve

constraint lex_chain(position);


% %% Don't return to the same place without opening the valve on your way!
constraint forall(m, n in MINUTES where m < n,  t in team)(
  (position[m, t] = position[n, t]) -> (card(open_valves[m, t]) < card(open_valves[n, t])) 
);

%% Opening the valve precedes visiting it
constraint forall(m in MINUTES, t in team)(
  (position[m, t] in valves_with_rates) -> (position[m-1, t] = enum_prev(position[m, t]))
);
