function discrete = ode_end(network,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Nonlinear implicit ODE endpoint model.

%% System Dimensions

    discrete.nP = size(network.PQ,1);						% number of pressure states
    discrete.nQ = size(network.QP,1);						% number of mass-flux states
    discrete.nPorts = network.nSupply + network.nDemand;	 		% number of ports

    discrete.refine = blkdiag(network.node_op,network.edge_op);
    discrete.np = size(network.node_op,2);
    discrete.nq = size(network.edge_op,2);

%% Helper Variables

    F_k = network.length ./ network.nomLen;					% actual-nominal length fraction

    A_R = 0.5 * (network.QP + abs(network.QP));				% partial "entering" incidence matrix

    d_p = D_p(network.diameter, network.nomLen);
    d_q = D_q(network.diameter, network.nomLen);
    d_g = D_g(network.diameter, network.nomLen, network.incline);
    d_f = D_f(network.diameter, config.friction(network.diameter,network.roughness));

%% Helper Functions

    p2q = @(p) 1e5 * (A_R * p);

%% Component Indices

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

%% System Components

% Mass matrix
%
%     / (A_R D_P^-1 D_d A_R^T)  0 \
% E = |                           |
%     \            0            1 /

    discrete.E = @(p,z) [(A_R' * (d_p * D_d(p,z)) * A_R), sparse(discrete.nP, discrete.nQ); ...
                        sparse(discrete.nQ, discrete.nP), speye(discrete.nQ)];

% Linear vector field
%
%     /    0      A_pq \
% A = |                |
%     \ D_q A_qp   0   /

    discrete.A = [sparse(discrete.nP, discrete.nP), -1e-5 * network.PQ; ...
                            1e5 * d_q * network.QP, sparse(discrete.nQ, discrete.nQ)];

% Linear input matrix
%
%     /    0       -B_D \
% B = |                 |
%     \ D_q B_S^T    0  /

    discrete.B = [sparse(discrete.nP, network.nSupply), 1e-5 * network.Bd; ...
                               1e5 * d_q * network.Bs', sparse(discrete.nQ, network.nDemand)];

% Source matrix
%
%     /     0     \
% F = |           |
%     \ (D_Q F_c) /

    discrete.F = [sparse(discrete.nP, max(network.nCompressor, 1)); ...
                  1e5 * d_q * network.Fc'];

% Output Matrix
%
%     /    0     |A_S| \
% C = |                |
%     \ |B_D^T|    0   /

    discrete.C = [sparse(network.nSupply, discrete.nP), abs(network.Bs); ...
                                      abs(network.Bd'), sparse(network.nDemand, discrete.nQ)];

% Nonlinear vector field
%
%     /                  0                  \
% f = |                                     |
%     \ -(RT * D_F) * (q * |q| / (A_R^T p)) /

    f_local = @(p,q,rtz) [zeros(discrete.nP, 1); ...
                          -( (d_g ./ rtz) .* p2q(p) ...
                           + (d_f .* rtz) .* F_k .* (q .* abs(q)) ./ p2q(p))];

    discrete.f = @(xs,x,u,p,z) discrete.A * xs + f_local(xs(iP) + x(iP),xs(iQ) + x(iQ),p(1) * p(2) * z);

% Local Jacobian % TODO add gravity derivative
%
%         /   0        0   \
% J = A - |                |
%         \ df/dp    df/dq /

    J_local = @(p,q,rtz) discrete.A - [sparse(discrete.nP,discrete.nP + discrete.nQ); ...
                                       spdiags( (d_f .* rtz) .* F_k .*  (q .* abs(q)) ./ p2q(p).^2, 0, discrete.nQ, discrete.nQ) * p2q(1), ...
                                       spdiags( (d_f .* rtz) .* F_k .* (2.0 * abs(q)) ./ p2q(p), 0, discrete.nQ, discrete.nQ) ];

    discrete.J = @(xs,x,u,p,z) J_local(xs(iP) + x(iP),xs(iQ) + x(iQ),p(1) * p(2) * z);
end

