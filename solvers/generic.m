function solution = generic(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Adaptive 2nd order Rosenbrock solver.

    rtz = scenario.T0 * scenario.Rs * config.steady.z0;

    tID = tic;

    Fcp = discrete.F * scenario.cp;

    % Set solver options
    opts = odeset('Mass', discrete.E(rtz), ...					% Set mass matrix
                  'MStateDependence', 'none', ... 				% Set state independence of mass matrix
                  'MassSingular', 'no', ...					% Set mass matrix singularity
                  'RelTol', 1e-3, ...						% Set relative solver tolerance
                  'AbsTol', 1e-3, ...						% Set absolute solver tolerance
                  'InitialStep', config.dt, ...				% Set initial time step
                  'Jacobian', discrete.J(config.steady.xs,discrete.x0,scenario.us,rtz));	% Set Jacobian

    [K,x] = ode23s(@(t,x) discrete.A * x + discrete.B * (scenario.us + scenario.ut(t)) + Fcp ...
                          + discrete.f(config.steady.xs,x,scenario.us,scenario.ut(t),rtz), ...
                   [0,scenario.tH], discrete.x0, opts);

    % Compute input trajectory
    t = 0:config.dt:scenario.tH;
    u = scenario.us + cell2mat(arrayfun(scenario.ut,t,'UniformOutput',false));

    % Compute output trajectory
    z = cell2mat(arrayfun(@(k) discrete.C * x(k,:)',1:numel(K),'UniformOutput',false));
    y = interp1(K,z',t')' + cmov(numel(discrete.C)==1,config.steady.xs,config.steady.ys);

    % Adjust time discretization
    solution = struct('t',t, ...
                      'u',u, ...
                      'y',y, ...
                      'steady_iter1',config.steady.iter1, ...
                      'steady_iter2',config.steady.iter2, ...
                      'steady_error',config.steady.err, ...
                      'steady_z0',config.steady.z0, ...
                      'runtime',toc(tID));

    % Log solver call
    logger('solver');
end

