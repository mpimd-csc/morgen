function solution = imex1(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: 1st order IMEX solver.

    persistent p0;
    persistent AL;
    persistent AU;
    persistent AP;

    steady = config.steadystate(scenario);

    [xk,ys] = initialstate(discrete,steady,config);

    % Caching: Reusable pivoted LU decomposition
    if isempty(p0) || ...
       not( (p0(1) == scenario.T0) && (p0(2) == scenario.Rs) ) || ...
       not(numel(AP) == discrete.nP + discrete.nQ)

        p0 = [scenario.T0;scenario.Rs];

        warning('off','Octave:lu:sparse_input');
        [AL,AU,AP] = lu(discrete.E(p0,steady.z0) - (config.relax * config.dt) * discrete.A,'vector');
    end%if

    tID = tic;

    Fcp = discrete.F * scenario.cp;
    fp = @(x,u) Fcp + discrete.B * u + discrete.f(steady.xs,x,u,p0,steady.z0);

    t = 0:config.dt:scenario.Tf;
    K = numel(t);
    u = repmat(scenario.us,[1,K]);						% Preallocate input trajectory
    y = repmat(ys,[1,K]);							% Preallocate output trajectory
    if isfield(config,'x0'), y = 0 * y; end%if

    y(:,1) = y(:,1) + discrete.C * xk;

    % Time stepper
    for k = 2:K

        u(:,k) = u(:,k) + scenario.ut(t(k));

        tk = config.dt * (discrete.A * xk + fp(xk,u(:,k)));

        xk = xk + AU \ (AL \ tk(AP));

        y(:,k) = y(:,k) + discrete.C * xk;
    end%for

    solution = struct('t',t, ...
                      'u',u, ...
                      'y',y, ...
                      'steady',steady, ...
                      'runtime',toc(tID));

    % Log solver call
    thunklog();
end

