function ROM = ebg_wz(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured nonlinear empirical non-symmetric-cross-Gramian-based balanced gains.

    global ODE;

    name = 'Structured Empirical Balanced Gains (WZ)';
    fprintf('%s\n\n',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

    s = [discrete.nPorts,discrete.nP+discrete.nQ,discrete.nPorts];
    t = [config.solver.dt,scenario.Tf];

    ODE = @(f,g,t,x0,u,p) solver(setfields(discrete,'C',cmov(numel(g(x0,u(0),p,0))==numel(x0),1,discrete.C),'x0',x0), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 config.solver).y;

    WZ = emgr(@() 0,@(x,u,p,t) discrete.C * x,s,t,'x',config.samples,[3,0,0,1,1,0,1,0,0,0,0,0,0],config.excitation);

    [LP,SP,RP] = balro(WZ(iP,iP),config.rom_max);
    [LQ,SQ,RQ] = balro(WZ(iQ,iQ),config.rom_max);

    [LP,~,RP] = balgn(LP,SP,RP,discrete.C(:,iP));
    [LQ,~,RQ] = balgn(LQ,SQ,RQ,discrete.C(:,iQ));

    ROM = @(n) make_rom(name,discrete,{LP,RP;LQ,RQ},n);
    ODE = [];

    fprintf('\n');
end
