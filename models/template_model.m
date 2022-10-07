function discrete = template_model(network,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Template model

%% System Dimensions

    discrete.nP = size(network.PQ,1);						% number of pressure states
    discrete.nQ = size(network.QP,1);						% number of mass-flux states
    discrete.nPorts = network.nSupply + network.nDemand; 			% number of ports
    discrete.refine = blkdiag(network.node_op,network.edge_op);

%% Component Indices

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;
    iS = 1:network.nSupply;

%% Helper Variables

    F_k = config.tuning * (network.length ./ network.nomLen);			% actual-nominal length fraction scaled by tuning factor

    d_p = D_p(network.diameter, network.nomLen);
    d_q = D_q(network.diameter, network.nomLen);
    d_g = D_g(network.incline);
    d_f = D_f(network.diameter, config.friction(network.diameter,network.roughness));

%% Specific Helpers

%% Your set up code goes here

    discrete.x0 = zeros(discrete.nP+discrete.nQ,1);

    discrete.xs = @(xs) xs; % Needed for reduced order steady state, for full order model just identity

    discrete.E = @(rtz) % returns a **sparse** nP+nQ x nP+nQ mass matrix given a scalar gas state (T0 * RS * z0)

    discrete.A = % nP+nQ x nP+nQ **sparse** system matrix

    discrete.B = % nP+nQ times nS+nD **sparse** input matrix

    discrete.F = % np+nQ x nC sparse load matrix

    discrete.C = % nS+nD x nP+nQ **sparse** output matrix

    discrete.f = @(xs,x,us,u,rtz) % returns nP+nQ vector evaluation of nonlinear vector field

    discrete.J = @(xs,x,u,rtz) % returns nP+nQ x nP+nQ **sparse** Jacobian matrix

    % Arguments for f and J are:
    % as  - nP+nQ steady state load (as = Axs + Bus)
    % xs  - nP+nQ steady state vector
    % x   - nP+nQ dynamic state vector
    % us  - nS+nD steady state input
    % u   - nS+nD input vector
    % rtz - scalar gas state (T0 * RS * z0)
end

