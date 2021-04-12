function ROM = template_reductor(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Template reductor

    name = 'Your reductor name';
    fprintf('%s\n\n',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

    % Your code goes here


    % and computes the following projectors
    % LP = Left_Pressure_Projector
    % RP = Right_Pressure_Projector
    % LQ = Left_Massflux_Projector
    % RQ = Right_Massflux_Projector

    ROM = @(n) make_rom(name,discrete,{LP,RP;LQ,RQ},n);

    fprintf('\n');
end
