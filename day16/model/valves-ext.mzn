% Valves (Advent of Code, day 16)
%
%%%%%
% Input %
%%%%%
int: minutes; 

set of int: MINUTES = 1..minutes;
set of int: MINUTES0 =  0..minutes;

enum valves;

array[valves] of int: rates;

array[valves] of set of valves: connections;

%%%%%%%%%%%%
% Decision variables %
%%%%%%%%%%%%
array[MINUTES0] of var set of valves: open_valves;

array[MINUTES0] of var valves: position;

enum team;
%% At the start:
%% Initial position is at AA
constraint position[0] = valves[1];
constraint open_valves[0] = {};
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%
% Main constraints %
%%%%%%%%%%%

%% Open the valve with rate > 0
constraint forall(m in MINUTES) (
  open_valves[m] = open_valves[m-1] union (if rates[position[m]] > 0 then {position[m]} else {} endif)
);

%% Next move: don't open valves more then once
constraint forall(m in MINUTES)(
    position[m] in connections[position[m-1]] diff open_valves[m-1]
);

var 0..sum(rates) * minutes: total_flow;

constraint total_flow =   sum(m in MINUTES)(rates[position[m]] * (minutes - m));

solve maximize total_flow;
