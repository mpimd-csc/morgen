function solution = rk4(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: 4th order "classic" Runge Kutta method.

    persistent Rs;
    persistent T0;
    persistent isdual;
    persistent EL;
    persistent EU;
    persistent EP;

    rtz = scenario.T0 * scenario.Rs * config.steady.z0;

    % Caching: Reusable pivoted LU decomposition
    if isempty(Rs) || ...
       not((T0 == scenario.T0) && (Rs == scenario.Rs)) || ...
       not(isdual == isfield(discrete,'dual')) || ...
       not(numel(EP) == discrete.nP + discrete.nQ)

        Rs = scenario.Rs;
        T0 = scenario.T0;
        isdual = isfield(discrete,'dual');

        [EL,EU,EP] = lu(discrete.E(rtz),'vector');
    end%if

    tID = tic;

    Fcp = discrete.F * scenario.cp;
    fp = @(x,u) Fcp + discrete.A * x + discrete.B * u + discrete.f(config.steady.xs,x,scenario.us,u,rtz);

    t = 0:config.dt:scenario.tH;
    K = numel(t);
    u = repmat(scenario.us,[1,K]);						% Preallocate input trajectory
    y = repmat(cmov(numel(discrete.C)==1,config.steady.xs, ...
                                         config.steady.ys),[1,K]);		% Preallocate output trajectory
    xk = discrete.x0;
    y(:,1) = y(:,1) + discrete.C * xk;

    % Time stepper
    for k = 2:K

        u(:,k) = u(:,k) + scenario.ut(t(k));

        f1 = fp(xk,u(:,k));
        f1 = EU \ (EL \ f1(EP));

        f2 = fp(xk + config.dt * 0.5 * f1,u(:,k));
        f2 = EU \ (EL \ f2(EP));

        f3 = fp(xk + config.dt * 0.5 * f2,u(:,k));
        f3 = EU \ (EL \ f3(EP));

        f4 = fp(xk + config.dt * f3,u(:,k));
        f4 = EU \ (EL \ f4(EP));

        xk = xk + (config.dt/6.0) * (f1 + 2.0 * f2 + 2.0 * f3 + f4);

        y(:,k) = y(:,k) + discrete.C * xk;
    end%for

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

