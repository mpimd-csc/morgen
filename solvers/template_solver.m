function solution = template_solver(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Template solver

    steady = config.steadystate(scenario);

    rtz = scenario.T0 * scenario.Rs * steady.z0;

    tID = tic;


    % Your code goes here


    % Set up solution
    solution = struct('t',t, ...		% Time instances of solution
                      'u',u, ...		% Input time series
                      'y',y, ...		% Output time series
                      'steady',steady, ...	% Steady state solution
                      'runtime',toc(tID));	% Solver run-time

    % Log solver call
    thunklog();
end

