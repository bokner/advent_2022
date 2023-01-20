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
array[VALVE_IDX] of var opt MINUTES0: intervals;



var MINUTES: path_length;
%%%%%%%%%%%%%%%%%%%%
% Constraints %%%%%%
%%%%%%%%%%%%%%%%%%%%
include "globals.mzn";

%% Start at AA
%constraint succ[1] = 7;
%constraint route[1] = succ[1];
%constraint hop[1] = 0;

% Experiment with excluding valve from subcircuit 
%constraint succ[3] = 3;
%constraint succ = [5, 6, 3, 1, 2, 7, 4];
constraint succ = [5, 6, 3, 1, 2, 4, 7];
%%%%%%%%%%%%%%
constraint subcircuit(succ);

%% Route

%% Start with AA
constraint route[1] = succ[arg_min(succ)];

constraint forall(v in 2..card(valves))(
  route[v] = succ[route[v-1]]
);








 
% constraint forall(v in VALVE_IDX)(
%   intervals[v] = distance[v, succ[v]]
% );


constraint forall(v in 2..points-1)(
  intervals[v-1] = distance[route[v-1],route[v]]
);

%constraint path_length = sum(intervals);
 % Alternative path length with route
 constraint path_length = sum(v in 1..points)(route[v]);
 var VALVE_IDX0: points;
 constraint points = sum(v in VALVE_IDX)(bool2int(succ[v] != v));
 
solve maximize path_length;

