int: steps = 24;

%% Robots 
enum robots = {ore_robot,  clay_robot,  obsidian_robot, geode_robot};
array[0..steps,  robots] of var 0..steps: robot_nums;
%array[1..steps, robots] of var bool: robot_built;

%% Minerals
enum minerals = {ore, clay, obsidian};
array[0..steps, minerals] of var 0..steps*(steps + 1) div 2: mineral_nums;
array[1..steps, minerals] of var 0..max(blueprint): minerals_spent;

array[minerals] of robots: mineral_collectors = [ore_robot, clay_robot, obsidian_robot];

%% Blueprint
% array[robots, minerals] of int: blueprint = 
%   %array2d(robots,  minerals, [ 
%     [| 4, 0, 0
%     | 2, 0, 0
%     | 3, 14, 0
%     | 2, 0, 7
%   |];



array[robots, minerals] of int: blueprint
%  = 
%   array2d(robots,  minerals, [ 
%     2, 0, 0,
%     3, 0, 0,
%     3, 8, 0,
%     3, 0, 12
%   ])
;


%% Geodes
array[0..steps] of var 0..steps*(steps + 1) div 2: geodes;

%% At the start:
constraint geodes[0] = 0;

constraint forall(m in minerals) (
    mineral_nums[0,  m] = 0
);

constraint forall(m in minerals) (
  minerals_spent[1, m] = 0
);

constraint 
  robot_nums[0,  ore_robot] = 1  /\ % one ore robot
  robot_nums[0,  clay_robot] = 0 /\
  robot_nums[0, obsidian_robot] = 0 /\
  robot_nums[0, geode_robot] = 0; 

% Minerals: collect and spend
constraint forall(s in 1..steps, m in minerals) (
    mineral_nums[s, m] = mineral_nums[s-1, m] + robot_nums[s-1,  mineral_collectors[m]] - minerals_spent[s, m]
);

% Build robots
constraint forall(s in 1..steps, r in robots) (  
    robot_nums[s, r] - robot_nums[s-1, r] in {0,1}
);

constraint forall(s in 0..steps - 1, r in robots) (
    (robot_nums[s+1, r] = robot_nums[s, r] + 1)  -> can_build_robot(s, r)
);

%Open geodes
constraint forall(s in 1..steps) (
  geodes[s] = geodes[s-1] + robot_nums[s-1,  geode_robot]
);


predicate can_build_robot(int: step, robots: robot) = 
  forall(m in minerals)(
    let {
      int: cost = blueprint[robot,  m]; 
      var int: available = mineral_nums[step, m];
      var bool: can_build = available >= cost;
      }
    in (
        if can_build then minerals_spent[step+1, m] = cost else minerals_spent[step+1, m] = 0 endif 
        /\ can_build  
      )
  ); 

solve maximize(geodes[steps]);

%output[show(geodes[steps])];
 