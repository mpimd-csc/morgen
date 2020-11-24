function solution = generic(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Adaptive 2nd order Rosenbrock solver.

    steady = config.steadystate(scenario);

    [x0,ys] = initialstate(discrete,steady,config);

    p0 = [scenario.T0;scenario.Rs];

    tID = tic;

    BusFcp = discrete.B * scenario.us + discrete.F * scenario.cp;

    % Set solver options
    opts = odeset('Mass', discrete.E(p0,steady.z0), ...			% Set mass matrix
                  'MStateDependence', 'none', ... 				% Set state independence of mass matrix
                  'RelTol', 1e-3, ...						% Set relative solver tolerance
                  'AbsTol', 1e-3, ...						% Set absolute solver tolerance
                  'InitialStep', config.dt, ...				% Set initial time step
                  'Jacobian', discrete.J(steady.xs,zeros(discrete.nP+discrete.nQ,1),scenario.us,p0,steady.z0));	% Set Jacobian

    [K,x] = ode23s(@(t,x) discrete.A * x + discrete.B * scenario.ut(t) + BusFcp + discrete.f(steady.xs,x,scenario.us + scenario.ut(t),p0,steady.z0), ...
                   [0,scenario.Tf], x0, opts);

    % Compute input trajectory
    t = 0:config.dt:scenario.Tf;
    u = scenario.us + cell2mat(arrayfun(scenario.ut,t,'UniformOutput',false));

    % Compute output trajectory
    z = cell2mat(arrayfun(@(k) discrete.C * x(k,:)',1:numel(K),'UniformOutput',false));
    y = interp1(K,z',t')' + ys;
    if isfield(config,'x0'), y = y - ys; end%if

    % Adjust time discretization
    solution = struct('t',t, ...
                      'u',u, ...
                      'y',y, ...
                      'steady',steady, ...
                      'runtime',toc(tID));

    % Log solver call
    thunklog();
end

