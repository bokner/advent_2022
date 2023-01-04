% Valves (Advent of Code, day 16)
include "globals.mzn";

int: minutes; 

set of int: MINUTES = 1..minutes;
set of int: MINUTES0 =  0..minutes;

enum team = {human, elephant};

enum valves;

array[valves] of int: rates;

array[valves] of set of valves: connections;

array[MINUTES0] of var set of valves: open_valves;

array[MINUTES0, team] of var valves: position;

array[MINUTES0] of var 0..sum(rates): flow;

%% At the start:
%% Initial position is at AA
constraint forall(t in team)(
  position[0, t] = valves[1]
);
constraint flow[0] = 0;

% All valves are closed, except ones which have 0 rate
constraint forall(v in valves)(
  if rates[v] = 0 then v in open_valves[0] else not (v in open_valves[0]) endif
);

% Not changing position for the first time
% implies opening the valve at that position
constraint forall(m in MINUTES)(
  not all_equal([position[m-1, human], position[m, human], 
    position[m-1, elephant], position[m, elephant]]) 
);


constraint forall(m in MINUTES) (
 if ((position[m, human] = position[m-1, human])) /\ (position[m, elephant] = position[m-1, elephant])
 then
  (open_valves[m] = open_valves[m-1] union {position[m-1, human], position[m-1, elephant]})
elseif (position[m, human] = position[m-1, human]) then
  (open_valves[m] = open_valves[m-1] union {position[m-1, human]})
  
 elseif (position[m, elephant] = position[m-1, elephant]) then
  (open_valves[m] = open_valves[m-1] union {position[m-1, elephant]})
 else 
   (open_valves[m] = open_valves[m-1])
 endif    
);


constraint forall(m in MINUTES)(
  flow[m] = sum(v in open_valves[m-1])(rates[v])
);




%% Next move
constraint forall(m in MINUTES, t in team)(
  if position[m-1, t] in open_valves[m-1] then
    position[m, t] in connections[position[m-1, t]]
  else
    position[m, t] in connections[position[m-1, t]] union {position[m-1, t]}
  endif    
);



%constraint flow = sum(v in open_valves[minutes])(rates[v]);
var int: total;

constraint total = sum(flow);

solve maximize total;
