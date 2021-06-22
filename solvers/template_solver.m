function solution = template_solver(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Template solver

    tID = tic;


    % Your code goes here


    % Set up solution
    solution = struct('t',t, ...						% Time instances of solution
                      'u',u, ...						% Input time series
                      'y',y, ...						% Output time series
                      'steady_iter1',config.steady.iter1, ...			% Steady-state algebraic iterations
                      'steady_iter2',config.steady.iter2, ...			% Steady-state differential iterations
                      'steady_error',config.steady.err, ...			% Steady-state error
                      'steady_z0',config.steady.z0, ...			% Global mean compressibility factor
                      'runtime',toc(tID));					% Solver run-time

    % Log solver call
    logger('solver');
end

