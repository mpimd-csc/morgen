function discrete = ode_mid(network,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Nonlinear implicit ODE midpoint model.

%% System Dimensions

    discrete.nP = size(network.PQ,1);						% number of pressure states
    discrete.nQ = size(network.QP,1);						% number of mass-flux states
    discrete.nPorts = network.nSupply + network.nDemand; 			% number of ports

    discrete.refine = blkdiag(network.node_op,network.edge_op);
    discrete.np = size(network.node_op,2);
    discrete.nq = size(network.edge_op,2);

%% Helper Variables

    F_k = network.length ./ network.nomLen;					% actual-nominal length fraction

    absApq = abs(network.PQ);
    absAqp = abs(network.QP);
    absBqs = abs(network.Bs)';

    d_p = D_p(network.diameter, network.nomLen);
    d_q = D_q(network.diameter, network.nomLen);
    d_g = D_g(network.diameter, network.nomLen, network.incline);
    d_f = D_f(network.diameter, config.friction(network.diameter,network.roughness));

%% Helper Functions

    p2q = @(p,us) 1e5 * 0.5 * ( (absAqp * p) + (absBqs * us) );

%% Component Indices

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;
    iS = 1:network.nSupply;

%% System Components

%
%     / (|A_pq| 1/2 D_P^-1 D_d |A_qp|)  0 \
% E = |                                   |
%     \               0                 1 /

    discrete.E = @(p,z) [absApq * (0.25 * d_p * D_d(p,z)) * absAqp, sparse(discrete.nP, discrete.nQ); ...
                                  sparse(discrete.nQ, discrete.nP), speye(discrete.nQ)];

% System Matrix
%
%     /    0      -A_pq \
% A = |                 |
%     \ D_q A_qp    0   /

    discrete.A = [sparse(discrete.nP, discrete.nP), -1e-5 * network.PQ; ...
                            1e5 * d_q * network.QP, sparse(discrete.nQ, discrete.nQ)];

% Input matrix
%
%     /    0        B_d \
% B = |                 |
%     \ D_q B_s^T    0  /

    discrete.B = [sparse(discrete.nP, network.nSupply), 1e-5 * network.Bd; ... 
                               1e5 * d_q * network.Bs', sparse(discrete.nQ, network.nDemand)];

% Source matrix
%
%     /    0    \
% F = |         |
%     \ D_q F_c /

    discrete.F = [sparse(discrete.nP, max(network.nCompressor, 1)); ...
                  1e5 * d_q * network.Fc'];

% Output Matrix
%
%     /    0     |B_s| \
% C = |                |
%     \ |B_d^T|    0   /

    discrete.C = [sparse(network.nSupply, discrete.nP), abs(network.Bs); ...
                                      abs(network.Bd'), sparse(network.nDemand, discrete.nQ)];

% Nonlinear vector field
%
%     /                        0                            \
% f = |                                                     |
%     \ D_F * ( q * |q| ) / ( |A_0^T| * p + |A_S^T| * u_S ) /

    f_local = @(p,q,us,rtz) [zeros(discrete.nP, 1); ...
                             -( (d_g ./ rtz) .* p2q(p,us) ...
                              + (d_f .* rtz) .* F_k .* ((q .* abs(q)) ./ p2q(p,us)))];

    discrete.f = @(xs,x,u,p,z) discrete.A * xs + f_local(xs(iP) + x(iP),xs(iQ) + x(iQ),u(iS),p(1) * p(2) * z);

% Local Jacobian % TODO add gravity derivative
%
%         /   0        0   \
% J = A - |                |
%         \ df/dp    df/dq /

    J_local = @(p,q,us,rtz) discrete.A - [sparse(discrete.nP,discrete.nP + discrete.nQ); ...
                                          spdiags( (d_f .* rtz) .* F_k .*  (q .* abs(q)) ./ p2q(p,us).^2, 0, discrete.nQ, discrete.nQ) * p2q(1,sparse(network.nSupply,discrete.nP)), ... 
                                          spdiags( (d_f .* rtz) .* F_k .* (2.0 * abs(q)) ./ p2q(p,us), 0, discrete.nQ, discrete.nQ) ];

    discrete.J = @(xs,x,u,p,z) J_local(xs(iP) + x(iP),xs(iQ) + x(iQ),u(iS),p(1) * p(2) * z);
end

