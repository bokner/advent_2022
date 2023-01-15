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

array[MINUTES0, team] of var valves: position;

%% At the start:
%% Initial position is at AA
constraint forall(t in team)(
  position[0, t] = valves[1]
);

include "globals.mzn";
%%%%%%%%%%%
% Main constraints %
%%%%%%%%%%%

%% Next move
constraint forall(m in MINUTES, t in team)(
    position[m, t] in connections[position[m-1, t]] 
);

%% Only one team member opens the valve
constraint 
  all_disjoint([{position[m, t] | m in MINUTES where position[m,t] in valves_with_rates} | t in team]);


%% Do not  visit the valve once it's open
array[1..card(valves_with_rates)] of valves: valves_with_rates_set = set2array(valves_with_rates);
array[1..card(valves_with_rates)] of 0..0: zeros = [0 | i in valves_with_rates];
array[1..card(valves_with_rates)] of 1..1: ones = [1 | i in valves_with_rates];

constraint forall(t in team)(
  global_cardinality_low_up(col(position, t), valves_with_rates_set, 
    zeros,
    ones)
);

%%%%%%%%%%
%% Objective %%
%%%%%%%%%%
var 0..upper_bound: total_flow;

array[MINUTES0] of var min(rates)..sum(rates): flow;
constraint flow[0] = 0;
constraint forall(m in MINUTES)(
  flow[m] = flow[m-1] + sum(t in team)(rates[position[m-1, t]])
  %sum(v in open_valves[m-1])(rates[v])
);

constraint total_flow =   sum(flow); 
%  sum(m in MINUTES, t in team)(rates[position[m, t]] * (minutes - m));

solve maximize total_flow;

%%%%%%%%%%%%
%% Performance  %%%
%%%%%%%%%%%%

%% Symmetry breaks:
%% The routes are interchangeable between team members
constraint lex_chain(position);

% %% Don't return to the same place without opening the valve on your way!
constraint forall(m, n in MINUTES where m < n,  t in team)(
  (position[m, t] = position[n, t]) -> flow[m] < flow[n]
);

%% Opening the valve precedes visiting it
constraint forall(m in MINUTES, t in team)(
  (position[m, t] in valves_with_rates) -> (position[m-1, t] = enum_prev(position[m, t]))
);
