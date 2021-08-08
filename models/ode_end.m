function discrete = ode_end(network,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Nonlinear implicit ODE endpoint model.

%% System Dimensions

    discrete.nP = size(network.A0,1);						% number of pressure states
    discrete.nQ = size(network.A0,2);						% number of mass-flux states
    discrete.nPorts = network.nSupply + network.nDemand;	 		% number of ports
    discrete.unrefine = blkdiag(network.unrefine_nodes,network.unrefine_edges);

%% Helper Variables

    F_k = config.tuning * (network.length ./ network.nomLen);			% actual-nominal length fraction scaled by tuning factor

    A_R = 0.5 * (network.A0 + abs(network.A0))';				% partial "entering" incidence matrix

    d_p = D_p(network.diameter, network.nomLen);
    d_q = D_q(network.diameter, network.nomLen);
    d_g = D_g(network.incline);
    d_f = D_f(network.diameter, config.friction(network.diameter,network.roughness));

%% Helper Functions

    p2q = @(p) 1e5 * (A_R * p);

%% Component Indices

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

%% System Components

    discrete.x0 = zeros(discrete.nP+discrete.nQ,1);

% Mass matrix
%
%     / (A_R D_P^-1 D_d A_R^T)     0   \
% E = |                                |
%     \            0            D_q^-1 /

    discrete.E = @(rtz) [(A_R' * (d_p ./ rtz) * A_R), sparse(discrete.nP, discrete.nQ); ...
                        sparse(discrete.nQ, discrete.nP), d_q];

% Linear vector field
%
%     /      0         -A_0 \
% A = |                     |
%     \ (A_0 - A_c)^T    0  /

    discrete.A = [sparse(discrete.nP, discrete.nP), -1e-5 * network.A0; ...
                  1e5 * (network.A0 - network.Ac)', sparse(discrete.nQ, discrete.nQ)];

% Linear input matrix
%
%     /   0     B_D \
% B = |             |
%     \ B_S^T    0  /

    discrete.B = [sparse(discrete.nP, network.nSupply), 1e-5 * network.Bd; ...
                                     1e5 * network.Bs', sparse(discrete.nQ, network.nDemand)];

% Source matrix
%
%     /  0  \
% F = |     |
%     \ F_c /

    discrete.F = [sparse(discrete.nP, max(network.nCompressor, 1)); ...
                  1e5 * network.Fc'];

% Output Matrix
%
%     /   0    -B_S \
% C = |             |
%     \ B_D^T    0  /

    discrete.C = [sparse(network.nSupply, discrete.nP), -network.Bs; ...
                                           network.Bd', sparse(network.nDemand, discrete.nQ)];

% Nonlinear vector field
%
%     /                            0                            \
% f = |                                                         |
%     \ -D_G * (A_R^T p) - D_F * D_Q^-1 * (q * |q| / (A_R^T p)) /

    switch config.gravity

        case 'none'
            f_local = @(ps,p,q) [zeros(discrete.nP, 1); ...
                                 -F_k .* ((d_q * d_f) .* ((q .* abs(q)) ./ (ps + p)))];

        case 'static'
            f_local = @(ps,p,q) [zeros(discrete.nP, 1); ...
                                 -F_k .* (d_g .* ps + (d_q * d_f) .* ((q .* abs(q)) ./ (ps + p)))];

        case 'dynamic'
            f_local = @(ps,p,q) [zeros(discrete.nP, 1); ...
                                 -F_k .* (d_g .* (ps + p) + (d_q * d_f) .* ((q .* abs(q)) ./ (ps + p)))];
    end%switch

    discrete.f = @(as,xs,x,us,u,rtz) as + f_local(p2q(xs(iP))./rtz,p2q(x(iP))./rtz,xs(iQ) + x(iQ));

% Local Jacobian
%
%         /       0            0   \
% J = A - |                        |
%         \ df/dp + dg/dp    df/dq /

    J_local = @(p,q,rtz) discrete.A - [sparse(discrete.nP,discrete.nP + discrete.nQ); ...
                                       spdiags( F_k .* ((d_q * d_f .* rtz) .*  (q .* abs(q)) ./ p.^2 + d_g), 0, discrete.nQ, discrete.nQ) * p2q(1), ...
                                       spdiags( F_k .*  (d_q * d_f .* rtz) .* (2.0 * abs(q)) ./ p, 0, discrete.nQ, discrete.nQ) ];

    discrete.J = @(xs,x,us,rtz) J_local(p2q(xs(iP) + x(iP)),xs(iQ) + x(iQ),rtz);
end

