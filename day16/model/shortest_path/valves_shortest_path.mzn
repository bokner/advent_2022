% Valves (Advent of Code, day 16)
% Model with precomputed shortest paths
%
%%%%%
% Input %
%%%%%
int: minutes; 
int: team;

int: upper_bound;

enum valves;

set of int: VALVE_IDX =  1..card(valves);
set of int: VALVE_IDX_SHORT = 1..card(valves) - 1;

array[VALVE_IDX] of int: rates;

array[VALVE_IDX, VALVE_IDX] of int: distance;
%%%%%%%%%%%%%%%%%%%%
set of int: MINUTES0 = 0..minutes;
set of int: MINUTES = 1..minutes;

set of int: TEAM = 1..team;
%%%%%%%%%%%%%%%%%%%%
% Decision variables
%%%%%%%%%%%%%%%%%%%%

% Routes
array[VALVE_IDX, TEAM] of var VALVE_IDX: route;

% Total flows per route
array[TEAM] of var min(rates)..upper_bound: total_flow;

% Number of visits in the route
array[TEAM] of var VALVE_IDX_SHORT: visits;
%%%%%%%%%%%%%%%%%%%%
% Constraints %%%%%%
%%%%%%%%%%%%%%%%%%%%
include "globals.mzn"; 

constraint forall(t in TEAM)(
    valve_tour(col(route, t), total_flow[t], visits[t])
);

constraint alldifferent_except(array1d(route), {1});
constraint sum(visits) < card(valves);

% symmetry breaks
constraint increasing(total_flow);
constraint increasing(visits);

solve 
 % :: int_search(total_flow, smallest, indomain_min)
maximize sum(total_flow);

predicate valve_tour(
  array[VALVE_IDX] of var VALVE_IDX: route,
  var min(rates)..upper_bound: total_flow,
  var VALVE_IDX_SHORT: visits
  ) = let {
    array[VALVE_IDX_SHORT] of var MINUTES0: duration;
    array[VALVE_IDX_SHORT] of var MINUTES: opening_time;
    array[VALVE_IDX_SHORT] of var min(rates)..max(rates)*minutes: pressure;
    var MINUTES: path_duration,
    } in

% Start the route with AA
  route[1] = 1 /\
  forall(v in 3..card(valves))(
     (route[v-1] = 1)  -> (route[v] = 1)
)
/\
% Duration, opening times and pressures in order of visits
  forall(v in VALVE_IDX_SHORT)(
  duration[v] = distance[route[v], route[v+1]]
  /\ opening_time[v] = if v = 1 then duration[1] else opening_time[v-1] + duration[v] endif
  /\ pressure[v] = (minutes - opening_time[v]) * rates[route[v+1]]
) 

/\ path_duration = sum(duration) %opening_time[visits-2]
/\ count(route, 1, card(valves) - visits)
/\ visits = sum(v in 2..card(valves))(route[v] != 1)
/\ total_flow = sum(pressure);
