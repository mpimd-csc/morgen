function solution = generic(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Adaptive 2nd order Rosenbrock solver.

    steady = config.steadystate(scenario);

    rtz = scenario.T0 * scenario.Rs * steady.z0;

    tID = tic;

    AxsBusFcp = discrete.As * steady.xs + discrete.B * scenario.us + discrete.F * scenario.cp;

    % Set solver options
    opts = odeset('Mass', discrete.E(rtz), ...					% Set mass matrix
                  'MStateDependence', 'none', ... 				% Set state independence of mass matrix
                  'RelTol', 1e-3, ...						% Set relative solver tolerance
                  'AbsTol', 1e-3, ...						% Set absolute solver tolerance
                  'InitialStep', config.dt, ...				% Set initial time step
                  'Jacobian', discrete.J(steady.xs,discrete.x0,scenario.us,rtz));	% Set Jacobian

    [K,x] = ode23s(@(t,x) discrete.A * x + discrete.B * scenario.ut(t) + AxsBusFcp + discrete.f(steady.xs,x,scenario.us + scenario.ut(t),rtz), ...
                   [0,scenario.Tf], discrete.x0, opts);

    % Compute input trajectory
    t = 0:config.dt:scenario.Tf;
    u = scenario.us + cell2mat(arrayfun(scenario.ut,t,'UniformOutput',false));

    % Compute output trajectory
    z = cell2mat(arrayfun(@(k) discrete.C * x(k,:)',1:numel(K),'UniformOutput',false));
    y = interp1(K,z',t')' + cmov(numel(discrete.C)==1,steady.xs,steady.ys);

    % Adjust time discretization
    solution = struct('t',t, ...
                      'u',u, ...
                      'y',y, ...
                      'steady',steady, ...
                      'runtime',toc(tID));

    % Log solver call
    thunklog();
end

