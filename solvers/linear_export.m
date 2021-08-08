function solution = linear_export(discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Linearize and export to state-space model

    N = discrete.nP + discrete.nQ;
    M = discrete.nPorts;

    rtz = scenario.T0 * scenario.Rs * config.steady.z0;

    qs = config.steady.xs(discrete.nP+1:end);

    E = discrete.E(rtz);
    A = discrete.A + spdiags(discrete.f(sparse(N,1),config.steady.xs,sparse(N,1),scenario.us,sparse(M,1),rtz)./ [ones(discrete.nP,1);qs],0,N,N);
    B = discrete.B;
    C = discrete.C;
    F = discrete.F + config.steady.as;

    save([config.id,'--','I',num2str(discrete.nPorts), ...
                         'S',num2str(N), ...
                         'O',num2str(discrete.nPorts),'.mat'],'E','A','B','C','F');

    % Set up solution
    solution = imex1(discrete,scenario,config);
end

