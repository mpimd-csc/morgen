function solution = imex2(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: 2nd order IMEX-RK solver.

    persistent p0;
    persistent AL;
    persistent AU;
    persistent AP;
    persistent EL;
    persistent EU;
    persistent EP;

    steady = config.steadystate(scenario);

    %% Parameters for second order IMEX RK family of methods:
    % GAMMA = 1.0 - sqrt(0.5);        % SSP & L-Stable
    % GAMMA = 0.5 + 1.0./sqrt(12.0);  % Passive
    % GAMMA = 0.24;                   % "Efficient"
    GAMMA = 0.5;                      % Stiffly accurate (this is the default)

    % Caching: Reusable Pivoted LU decomposition
    if isempty(p0) || ...
       not( (p0(1) == scenario.T0) && (p0(2) == scenario.Rs) ) || ...
       not(numel(AP) == discrete.nP + discrete.nQ)

        rtz = scenario.T0 * scenario.Rs * steady.z0;

        warning('off','Octave:lu:sparse_input');

        [EL,EU,EP] = lu(discrete.E(rtz),'vector');
        [AL,AU,AP] = lu(discrete.E(rtz) - (config.relax * config.dt * GAMMA) * discrete.A,'vector');
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

        zk = (config.dt * config.relax * GAMMA) * (discrete.A * xk);
        z1 = xk + AU \ (AL \ zk(AP));

        f1 = config.dt * fp(xk,u(:,k));
        a1 = (config.dt * config.relax) * (discrete.A * z1);

        z2 = zk + f1 + (1.0 - 2.0 * GAMMA) * a1;
        z2 = xk + AU \ (AL \ z2(AP));

        f2 = config.dt * fp(z1,u(:,k));
        a2 = (config.dt * config.relax) * (discrete.A * z2);

        zk = 0.5 * (f1 + f2 + a1 + a2);
        xk = xk + EU \ (EL \ zk(EP));

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

