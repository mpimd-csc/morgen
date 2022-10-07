function solution = rk2hyp(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: 2nd order explicit Runge Kutta method with increased hyperbolic stability.

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
    x1 = discrete.x0;
    y(:,1) = y(:,1) + discrete.C * x1;

    % Hyperbolic Runge-Kutta Coefficients
    switch(config.rk2type)

        case 5,  hrk = [1/4, 1/6, 3/8, 1/2, 1];
        case 6,  hrk = [1/5, 4/35, 7/25, 4/13, 13/25, 1];
        case 7,  hrk = [1/6, 1/12, 2/9, 4/19, 19/54, 1/2, 1];
        case 8,  hrk = [1/7, 4/63, 9/49, 2/13, 13/49, 8/25, 25/49, 1];
        case 9,  hrk = [1/8, 1/20, 5/32, 2/17, 17/80, 5/22, 11/32, 1/2, 1];
        case 10, hrk = [1/9, 4/99, 11/81, 4/43, 43/243, 6/35, 7/25, 40/123, 41/81, 1];
        case 11, hrk = [1/10, 1/30, 3/25, 4/53, 53/350, 7/52, 26/125, 4/17, 17/50, 1/2, 1];
        case 12, hrk = [1/11, 4/143, 13/121, 1/16, 16/21, 16/147, 21/121, 28/155, 31/121, 20/61, 61/121, 1];
    end%switch


    % Time stepper
    x2 = x1;

    for k = 2:K

        u(:,k) = u(:,k) + scenario.ut(t(k));

        for l = hrk

            x2 = fp(x2,u(:,k));
            x2 = x1 + (l * config.dt) * (EU \ (EL \ x2(EP)));
        end%for
        x1 = x2;

        y(:,k) = y(:,k) + discrete.C * x1;
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

