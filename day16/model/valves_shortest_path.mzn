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


% Symmetry break
constraint succ[1] > 1;

%% Start the route with AA
constraint route[1] = succ[1];
constraint forall(v in 2..card(valves))(
  route[v] = succ[route[v-1]]
);

% Valve opening times
array[1..card(valves)-1] of var MINUTES0: times;
constraint times[1] = distance[1, succ[1]];
constraint forall(v in 2..card(valves) - 1)(
  times[v] = if (v < points) then 
    (times[v-1] +distance[route[v-1],route[v]]) 
    else 0
    endif
);

 constraint path_length = max(times);
 var VALVE_IDX: points;

 constraint points = arg_min(route);
 constraint points = sum(v in VALVE_IDX)(succ[v] != v);
 
 var 0..sum(rates)*minutes: total_flow;
 
constraint total_flow = sum(v in 1..card(valves)-1)(
      (v < points) * (minutes - times[v]) * rates[route[v]]
  );
 
solve maximize total_flow;


%% Things to try: subpath from Peter Stuckey.
% array[1..5] of var 1..6: spath;
% var int: start = 1;
% var int: end;

% constraint stuckey_subpath(spath, start, end);

% predicate stuckey_path(array[int] of var int: succ, var int: start, var int: end) =
% 	circuit(succ ++ [start]) /\ succ[end] = length(succ)+1;
	
% 	predicate stuckey_subpath(array[int] of var int: succ, var int: start, var int: end) =
% 	subcircuit(succ ++ [start]) /\ start <= length(succ) /\ succ[end] = length(succ)+1;

	

