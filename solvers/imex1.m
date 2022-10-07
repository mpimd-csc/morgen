function solution = imex1(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: 1st order IMEX solver.

    persistent Rs;
    persistent T0;
    persistent isdual;
    persistent AL;
    persistent AU;
    persistent AP;

    rtz = scenario.T0 * scenario.Rs * config.steady.z0;

    % Caching: Reusable pivoted LU decomposition
    if isempty(Rs) || ...
       not((T0 == scenario.T0) && (Rs == scenario.Rs)) || ...
       not(isdual == isfield(discrete,'dual')) || ...
       not(numel(AP) == discrete.nP + discrete.nQ)

        Rs = scenario.Rs;
        T0 = scenario.T0;
        isdual = isfield(discrete,'dual');

        [AL,AU,AP] = lu(discrete.E(rtz) - (config.relax * config.dt) * discrete.A,'vector');
    end%if

    tID = tic;

    Fcp = discrete.F * scenario.cp;
    fp = @(x,u) Fcp + discrete.B * u + discrete.f(config.steady.xs,x,scenario.us,u,rtz);

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

        zk = config.dt * (discrete.A * xk + fp(xk,u(:,k)));

        xk = xk + AU \ (AL \ zk(AP));

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

