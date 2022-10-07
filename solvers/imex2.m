function solution = imex2(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: 2nd order IMEX-RK solver.

% Note:
% Compared to the companion publication, the relaxation has been changed
% from multiplicative to additive to match the imex1 solver.

    persistent Rs;
    persistent T0;
    persistent isdual;
    persistent AL;
    persistent AU;
    persistent AP;
    persistent EL;
    persistent EU;
    persistent EP;

    rtz = scenario.T0 * scenario.Rs * config.steady.z0;

    % Parameters for second order IMEX RK family of methods:
    % LAMBDA = 0.5 + 1.0./sqrt(12.0);  % Passive
    % LAMBDA = 1.0 - sqrt(0.5);        % Passive, SSP & L-Stable
    % LAMBDA = 0.24;                   % "Efficient"
    LAMBDA = 0.5;                      % Stiffly accurate (this is the default)

    % Caching: Reusable Pivoted LU decomposition
    if isempty(Rs) || ...
       not((T0 == scenario.T0) && (Rs == scenario.Rs)) || ...
       not(isdual == isfield(discrete,'dual')) || ...
       not(numel(EP) == discrete.nP + discrete.nQ)

        Rs = scenario.Rs;
        T0 = scenario.T0;
        isdual = isfield(discrete,'dual');

        [EL,EU,EP] = lu(discrete.E(rtz),'vector');
        [AL,AU,AP] = lu(discrete.E(rtz) - (config.relax * config.dt * LAMBDA) * discrete.A,'vector');
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

        zk = discrete.E(rtz) * xk;
        z1 = AU \ (AL \ zk(AP));

        f1 = config.dt * fp(xk,u(:,k));
        if config.relax < 1.0, f1 = f1 + (1.0 - config.relax) * (discrete.A * xk); end%if
        a1 = (config.dt * config.relax) * discrete.A * z1;

        z2 = zk + f1 + (1.0 - 2.0 * LAMBDA) * a1;
        z2 = AU \ (AL \ z2(AP));

        f2 = config.dt * (fp(z1,u(:,k)) + (1.0 - config.relax) * z1);
        if config.relax < 1.0, f2 = f2 + (1.0 - config.relax) * (discrete.A * z1); end%if
        a2 = (config.dt * config.relax) * discrete.A * z2;

        zk = 0.5 * (f1 + f2 + a1 + a2);
        xk = xk + EU \ (EL \ zk(EP));

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

