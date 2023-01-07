% Valves (Advent of Code, day 16)

int: minutes; 

set of int: MINUTES = 1..minutes;
set of int: MINUTES0 =  0..minutes;

enum valves;

array[valves] of int: rates;

array[valves] of set of valves: connections;

array[MINUTES0] of var set of valves: open_valves;

array[MINUTES0] of var valves: position;


array[MINUTES0] of var 0..sum(rates): flow;

%% At the start:
%% Initial position is at AA
constraint position[0] = valves[1];
constraint flow[0] = 0;

% All valves are closed, except ones which have 0 rate
constraint forall(v in valves)(
  if rates[v] = 0 then v in open_valves[0] else not (v in open_valves[0]) endif
);

% Not changing position for the first time
% implies opening the valve at that position
constraint forall(m in MINUTES) (
 %if (position[m] = position[m-1]) 
 %then
  (open_valves[m] = open_valves[m-1] union {position[m]})

 %else
 %  (open_valves[m] = open_valves[m-1])
 %endif    
);

%% Next move
constraint forall(m in MINUTES)(
%  if position[m-1] in open_valves[m-1] then
    position[m] in connections[position[m-1]] 
%  else
%    position[m] in connections[position[m-1]] union {position[m-1]}
%  endif    
);

% Do not visit the node that represent a closed valve more than 1 time.
constraint forall(m in MINUTES) (
  forall(v in valves) (
    (rates[v] > 0) -> count_leq(position, v, 1) 
  )
);

constraint forall(m in MINUTES)(
  flow[m] = sum(v in open_valves[m-1])(rates[v])

);


var int: total;

constraint total = sum(flow);

solve maximize total;
