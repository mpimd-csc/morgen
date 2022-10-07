function solution = rk4hyp(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: 4th order explicit Runge Kutta method with increased hyperbolic stability.

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

    switch(config.rk4type)

        case "MeaR99a", hrk = [0.0, 0.16791846623918, 0.48298439719700, 0.70546072965982, 0.09295870406537, 0.76210081248836; ...
                               -0.15108370762927, 0.75384683913851, -0.36016595357907, 0.52696773139913, 0.0, 0.23043509067071];
        case "MeaR99b", hrk = [0.0, 0.11323867464627, 0.38673801369281, 0.62314978336040, 0.05095678842127, 0.54193120548949; ...
                               -1.11863930033618, 2.50614037113582, -2.22307558659639, 0.99978067105009, 0.0, 0.83579384474665];
        case "TseS05",  hrk = [0.0, 0.14656005951358278141218736059705, 0.27191031708348360233615451628133, 0.06936819398523233741339353210366, 0.25897940086636139111948386831759, 0.48921096998463659243576995327396; ...
                               -3.94810815871644627868730966001274, 6.15933360719925137209615595259797, -8.74466100703228369513719502355456, 4.07387757397683429863757134989527, 0.0, 3.45955798457264430309077738107406];
    end%switch

    % Time stepper
    for k = 2:K

        u(:,k) = u(:,k) + scenario.ut(t(k));

        q1 = 0.0;
        q2 = 0.0;

        for l = 1:6

            q1 = fp(xk + (hrk(1,l) * config.dt) * q1,u(:,k));
            q1 = EU \ (EL \ q1(EP));
            q2 = q2 + hrk(2,l) * q1;
        end%for

        xk = xk + config.dt * q2;

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

