% Valves (Advent of Code, day 16)
%
%%%%%
% Input %
%%%%%
int: minutes; 

set of int: MINUTES = 1..minutes;
set of int: MINUTES0 =  0..minutes;

enum valves;

enum team = {human, elephant};

array[valves] of int: rates;

array[valves] of set of valves: connections;

%%%%%%%%%%%%
% Decision variables %
%%%%%%%%%%%%
array[MINUTES0] of var set of valves: open_valves;

array[MINUTES0, team] of var valves: position;

%% At the start:
%% Initial position is at AA
constraint forall(t in team)(
  position[0, t] = valves[1]
);
constraint open_valves[0] = {};
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%
% Main constraints %
%%%%%%%%%%%

%% Open the valve with rate > 0
constraint forall(m in MINUTES) (
    open_valves[m] = open_valves[m-1] union array_union([if rates[position[m, t]] > 0 then {position[m, t]} else {} endif | t in team]) 
);

%% Next move: don't open valves more then once
constraint forall(m in MINUTES, t in team)(
    position[m, t] in connections[position[m-1, t]] diff open_valves[m-1]
);

array[MINUTES] of var 0..sum(rates): flow;
constraint forall(m in MINUTES)(
  flow[m] = sum(v in open_valves[m-1])(rates[v])
);

var int: total_flow;

constraint total_flow =   sum(flow); %sum(m in MINUTES, t in team)(rates[position[m, t]] * (minutes - m));

solve maximize total_flow;
