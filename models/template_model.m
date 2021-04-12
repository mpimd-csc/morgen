function discrete = template_model(network,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Template model

%% System Dimensions

    discrete.nP = size(network.PQ,1);						% number of pressure states
    discrete.nQ = size(network.QP,1);						% number of mass-flux states
    discrete.nPorts = network.nSupply + network.nDemand; 			% number of ports

    discrete.refine = blkdiag(network.node_op,network.edge_op);
    discrete.np = size(network.node_op,2);
    discrete.nq = size(network.edge_op,2);


    % Your set up code goes here

    discrete.x0 = zeros(discrete.nP+discrete.nQ,1);

    discrete.E = @(rtz) % returns a **sparse** nP+nQ x nP+nQ mass matrix given a scalar gas state (T0 * RS * z0)

    discrete.A = % nP+nQ x nP+nQ **sparse** system matrix

    discrete.As = discrete.A % This is needed for efficient ROM computation, leave as is.

    discrete.B = % nP+nQ times nS+nD **sparse** input matrix

    discrete.F = % np+nQ x nC sparse load matrix

    discrete.C = % nS+nD x nP+nQ **sparse** output matrix

    discrete.f = @(xs,x,u,rtz) % returns nP+nQ vector evaluation of nonlinear vector field

    discrete.J = @(xs,x,u,rtz) % returns nP+nQ x nP+nQ **sparse** Jacobian matrix

    % Arguments for f and J are:
    % xs  - nP+nQ steady state vector
    % x   - nP+nQ dynamic state vector
    % u   - nS+nD input vector
    % rtz - scalar gas state (T0 * RS * z0)
end

