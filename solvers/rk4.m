function solution = rk4(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: 4th order "classic" Runge Kutta method.

    persistent p0;
    persistent EL;
    persistent EU;
    persistent EP;

    steady = config.steadystate(scenario);

    % Caching: Reusable Pivoted LU decomposition
    if isempty(p0) || ...
    not( (p0(1) == scenario.T0) && (p0(2) == scenario.Rs) ) || ...
    not(numel(EP) == discrete.nP + discrete.nQ)

        rtz = scenario.T0 * scenario.Rs * steady.z0;

        warning('off','Octave:lu:sparse_input');
        [EL,EU,EP] = lu(discrete.E(rtz),'vector');
    end%if

    tID = tic;

    AxsFcp = discrete.As * steady.xs + discrete.F * scenario.cp;
    fp = @(x,u) AxsFcp + discrete.A * x + discrete.B * u + discrete.f(steady.xs,x,u,rtz);
    Ep = discrete.E(rtz);

    t = 0:config.dt:scenario.Tf;
    K = numel(t);
    u = repmat(scenario.us,[1,K]);						% Preallocate input trajectory
    y = repmat(cmov(numel(discrete.C)==1,steady.xs,steady.ys),[1,K]);		% Preallocate output trajectory
    xk = discrete.x0;
    y(:,1) = y(:,1) + discrete.C * xk;

    % Time stepper
    for k = 2:K

        u(:,k) = u(:,k) + scenario.ut(t(k));

        zk = Ep * xk;

        f1 = config.dt * fp(xk,u(:,k));
        z1 = zk + 0.5 * f1;
        z1 = EU \ (EL \ z1(EP));

        f2 = config.dt * fp(z1,u(:,k));
        z2 = zk + 0.5 * f2;
        z2 = EU \ (EL \ z2(EP));

        f3 = config.dt * fp(z2,u(:,k));
        z3 = zk + f3;
        z3 = EU \ (EL \ z3(EP));

        f4 = config.dt * fp(z3,u(:,k));

        xk = (1.0/6.0) * (f1 + 2.0 * f2 + 2.0 * f3 + f4);
        xk = xk + EU \ (EL \ xk(EP));

        y(:,k) = y(:,k) + discrete.C * xk;
    end%for

    solution = struct('t',t, ...
                      'u',u, ...
                      'y',y, ...
                      'steady',steady, ...
                      'runtime',toc(tID));

    %Log solver call
    thunklog();
end

