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
array[VALVE_IDX, TEAM] of var VALVE_IDX: route;

array[VALVE_IDX_SHORT, TEAM] of var MINUTES0: duration;
array[VALVE_IDX_SHORT, TEAM] of var MINUTES: opening_time;

array[VALVE_IDX_SHORT, TEAM] of var min(rates)..max(rates)*minutes: pressure;

array[TEAM] of  var MINUTES: path_duration;

array[TEAM] of var min(rates)..upper_bound: total_flow;

%%%%%%%%%%%%%%%%%%%%
% Constraints %%%%%%
%%%%%%%%%%%%%%%%%%%%
include "globals.mzn"; 

%constraint valve_tour(col(route, 1), col(duration, 1), col(opening_time, 1), col(pressure, 1), path_duration[1], total_flow[1]);
%constraint valve_tour(col(route, 2), col(duration, 2), col(opening_time, 2), col(pressure, 2), path_duration[2], total_flow[2]);
constraint forall(t in TEAM)(
    valve_tour(col(route, t), col(duration, t), col(opening_time, t), col(pressure, t), path_duration[t], total_flow[t])
);

constraint forall(t1, t2 in TEAM where t1 < t2)(
  all_different_except(col(route, t1) ++ col(route, t2), {1})
);

% symmetry breaks
constraint increasing(total_flow);

solve 
  %:: int_search([visits], input_order, indomain_min)
maximize sum(total_flow);


predicate valve_tour(
  array[VALVE_IDX] of var VALVE_IDX: route,
  array[VALVE_IDX_SHORT] of var MINUTES0: duration,
  array[VALVE_IDX_SHORT] of var MINUTES: opening_time,  
  array[VALVE_IDX_SHORT] of var min(rates)..max(rates)*minutes: pressure, 
  var MINUTES: path_duration,
  var min(rates)..upper_bound: total_flow) = let {
   % Number of visits in the tour.
    var VALVE_IDX: visits = sum(v in 2..card(valves))(route[v] != 1) + 1
    } in

alldifferent_except(route, {1}) 
/\
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

/\ path_duration = opening_time[visits-1]
/\ count(route, 1, card(valves) - visits + 1)
/\ total_flow = sum(pressure);
