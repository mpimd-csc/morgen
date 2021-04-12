function solution = imex1(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: 1st order IMEX solver.

    persistent p0;
    persistent AL;
    persistent AU;
    persistent AP;

    steady = config.steadystate(scenario);

    % Caching: Reusable pivoted LU decomposition
    if isempty(p0) || ...
       not( (p0(1) == scenario.T0) && (p0(2) == scenario.Rs) ) || ...
       not(numel(AP) == discrete.nP + discrete.nQ)

        rtz = scenario.T0 * scenario.Rs * steady.z0;

        warning('off','Octave:lu:sparse_input');
        [AL,AU,AP] = lu(discrete.E(rtz) - (config.relax * config.dt) * discrete.A,'vector');
    end%if

    tID = tic;

    AxsFcp = discrete.As * steady.xs + discrete.F * scenario.cp;
    fp = @(x,u) AxsFcp + discrete.B * u + discrete.f(steady.xs,x,u,rtz);

    t = 0:config.dt:scenario.Tf;
    K = numel(t);
    u = repmat(scenario.us,[1,K]);						% Preallocate input trajectory
    y = repmat(cmov(numel(discrete.C)==1,steady.xs,steady.ys),[1,K]);		% Preallocate output trajectory
    xk = discrete.x0;
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

