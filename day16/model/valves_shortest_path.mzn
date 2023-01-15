% Valves (Advent of Code, day 16)
% Model wit precomputed shortest paths
%
%%%%%
% Input %
%%%%%
int: minutes; 

enum valves;

array[valves] of int: rates;

array[valves, valves] of int: distance;
%%%%%%%%%%%%%%%%%%%%
set of int: MINUTES = 1..minutes;
set of int: MINUTES0 =  0..minutes;
%%%%%%%%%%%%%%%%%%%%
% Decision variables
%%%%%%%%%%%%%%%%%%%%

array[MINUTES0] of var opt valves: route;

var MINUTES: path_length;
%%%%%%%%%%%%%%%%%%%%
% Constraints %%%%%%
%%%%%%%%%%%%%%%%%%%%
include "alldifferent.mzn";

%% Start at AA
constraint route[0] = valves[1];

constraint alldifferent(route);

constraint path_length = sum(m in MINUTES)(distance[route[m-1], route[m]]);


solve maximize sum(route);
