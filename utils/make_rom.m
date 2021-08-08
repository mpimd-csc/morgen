function rdiscrete = make_rom(discrete,proj,order)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Reduced order model assembler.

    rdiscrete.nPorts = discrete.nPorts;

    rdiscrete.nP = min(order,size(proj{1,1},2));
    rdiscrete.nQ = min(order,size(proj{2,1},2));

    L1 = blkdiag(proj{1,1}(:,1:rdiscrete.nP), ...
                 proj{2,1}(:,1:rdiscrete.nQ))';

    if 1 == size(proj,2)	% Structured Galerkin

        R1 = L1';
    else			% Structured Petrov-Galerkin

        assert(size(proj{1,1},2) == size(proj{1,2},2) && ...
               size(proj{2,1},2) == size(proj{2,2},2), ...
               'morgen: Incompatible Petrov-Galerkin projections!');

        R1 = blkdiag(proj{1,2}(:,1:rdiscrete.nP), ...
                     proj{2,2}(:,1:rdiscrete.nQ));
    end%if

    rdiscrete.x0 = zeros(rdiscrete.nP + rdiscrete.nQ,1);
    rdiscrete.E = @(rtz) L1 * discrete.E(rtz) * R1;
    rdiscrete.A = L1 * discrete.A * R1;
    rdiscrete.B = L1 * discrete.B;
    rdiscrete.F = L1 * discrete.F;
    rdiscrete.C = discrete.C * R1;
    rdiscrete.f = @(as,xs,x,us,u,rtz) L1 * discrete.f(as,xs,R1 * x,us,u,rtz);
    rdiscrete.J = @(xs,x,us,rtz) L1 * discrete.J(xs,R1 * x,us,rtz) * R1;
end
