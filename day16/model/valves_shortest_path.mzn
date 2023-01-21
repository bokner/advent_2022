% Valves (Advent of Code, day 16)
% Model wit precomputed shortest paths
%
%%%%%
% Input %
%%%%%
int: minutes; 

enum valves;

set of int: VALVE_IDX =  1..card(valves);
set of int: VALVE_IDX0 = 0..card(valves);

array[VALVE_IDX] of int: rates;

array[VALVE_IDX, VALVE_IDX] of int: distance;
%%%%%%%%%%%%%%%%%%%%
set of int: MINUTES = 1..minutes;
set of int: MINUTES0 =  0..minutes;
%%%%%%%%%%%%%%%%%%%%
% Decision variables
%%%%%%%%%%%%%%%%%%%%

array[VALVE_IDX] of var VALVE_IDX: succ;
array[VALVE_IDX] of var VALVE_IDX0: route;

% Intervals between opening times of adjacent valves
% array[1..card(valves)-1] of var MINUTES0: intervals;

var MINUTES: path_length;
%%%%%%%%%%%%%%%%%%%%
% Constraints %%%%%%
%%%%%%%%%%%%%%%%%%%%
include "globals.mzn";

%%%%%%%%%%%%%%
constraint subcircuit(succ);

%% Route
constraint succ[1] > 1;

%% Start with AA
constraint route[1] = 1; %succ[arg_min(succ)];
constraint forall(v in 2..card(valves))(
  route[v] = succ[route[v-1]]
);

% Valve opening times
array[1..card(valves)-1] of var MINUTES0: times;
%constraint times[1] = intervals[1];
constraint times[1] = distance[1, succ[1]];
constraint forall(v in 2..card(valves) - 1)(
  times[v] = (v < points) * (times[v-1] +distance[route[v],route[v+1]])  
);

 constraint path_length = max(times); %sum(intervals);
 var VALVE_IDX: points;
 constraint points = sum(v in VALVE_IDX)(succ[v] != v);
 
 var 0..sum(rates)*minutes: total_flow;
 
 array[1..card(valves)-1] of var 0..max(rates)*minutes: flow;
 constraint forall(v in 1..card(valves)-1)(flow[v] = (times[v] > 0)*(minutes - times[v]) * rates[route[v+1]]);

constraint total_flow = sum(flow);
 
solve maximize total_flow;

