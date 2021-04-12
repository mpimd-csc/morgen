function rdiscrete = make_rom(name,discrete,spaces,order)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Reduced order model assembler.

    if isa(order,'char') && strcmp(order,'name')      % Return method name

        rdiscrete = name;
    elseif isa(order,'char') && strcmp(order,'save')  % Return projectors

        rdiscrete = spaces;
    else

        rdiscrete.nPorts = discrete.nPorts;

        rdiscrete.nP = min(order,size(spaces{1,1},2));
        rdiscrete.nQ = min(order,size(spaces{2,1},2));

        L1 = blkdiag(spaces{1,1}(:,1:rdiscrete.nP), ...
                     spaces{2,1}(:,1:rdiscrete.nQ))';

        if 1 == size(spaces,2)	% Structured Galerkin

            R1 = L1';
        else			% Structured Petrov-Galerkin

            assert(size(spaces{1,1},2) == size(spaces{1,2},2) && ...
                   size(spaces{2,1},2) == size(spaces{2,2},2), ...
                   'morgen: Incompatible Petrov-Galerkin projections!');

            R1 = blkdiag(spaces{1,2}(:,1:rdiscrete.nP), ...
                         spaces{2,2}(:,1:rdiscrete.nQ));
        end%if

        rdiscrete.x0 = zeros(rdiscrete.nP + rdiscrete.nQ,1);
        rdiscrete.As = L1 * discrete.As;
        rdiscrete.E = @(rtz) L1 * discrete.E(rtz) * R1;
        rdiscrete.A = L1 * discrete.A * R1;
        rdiscrete.B = L1 * discrete.B;
        rdiscrete.F = L1 * discrete.F;
        rdiscrete.C = discrete.C * R1;
        rdiscrete.f = @(xs,x,u,rtz) L1 * discrete.f(xs,R1 * x,u,rtz);
        rdiscrete.J = @(xs,x,u,rtz) L1 * discrete.J(xs,R1 * x,u,rtz) * R1;
    end%if
end
