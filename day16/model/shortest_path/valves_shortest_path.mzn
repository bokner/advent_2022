% Valves (Advent of Code, day 16)
% Model with precomputed shortest paths
%
%%%%%
% Input %
%%%%%
int: minutes; 

int: upper_bound;

enum valves;

set of int: VALVE_IDX =  1..card(valves);

array[VALVE_IDX] of int: rates;

array[VALVE_IDX, VALVE_IDX] of int: distance;
%%%%%%%%%%%%%%%%%%%%
set of int: MINUTES0 = 0..minutes;
set of int: MINUTES = 1..minutes;
%%%%%%%%%%%%%%%%%%%%
% Decision variables
%%%%%%%%%%%%%%%%%%%%
array[VALVE_IDX] of var VALVE_IDX: route;

var MINUTES: path_duration;
% Number of visits in a subcircuit that represents the chosen path.
var VALVE_IDX: visits;

var min(rates)..upper_bound: total_flow;

%%%%%%%%%%%%%%%%%%%%
% Constraints %%%%%%
%%%%%%%%%%%%%%%%%%%%
include "globals.mzn";

%%%%%%%%%%%%%%
constraint alldifferent_except(route, {1});

% Start the route with AA
constraint route[1] = 1;
constraint forall(v in 3..card(valves))(
     (route[v-1] = 1)  -> (route[v] = 1)
);

% Duration, opening times and pressures in order of visits
constraint forall(v in 1..card(valves)-1)(
  duration[v] = distance[route[v], route[v+1]]
  /\ opening_time[v] = if v = 1 then duration[1] else opening_time[v-1] + duration[v] endif
  /\ pressure[v] = (minutes - opening_time[v]) * rates[route[v+1]]
);  

array[1..card(valves)-1] of var MINUTES0: duration;
array[1..card(valves)-1] of var MINUTES: opening_time;

array[1..card(valves)-1] of var min(rates)..max(rates)*minutes: pressure;

constraint path_duration = opening_time[visits-1]; 
constraint count(route, 1, card(valves) - visits + 1);
constraint visits = sum(v in 2..card(valves))(route[v] != 1) + 1;
 
constraint total_flow = sum(pressure);
  
solve 
  %:: int_search([visits], input_order, indomain_min)
maximize total_flow;
