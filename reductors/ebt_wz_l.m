function ROM = ebt_wz_l(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured linear empirical non-symmetric-cross-Gramian-based balanced truncation.

    global ODE;

    name = 'Structured Empirical Balanced Truncation (WZ*)';
    fprintf('%s\n\n',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

    s = [discrete.nPorts,discrete.nP+discrete.nQ,discrete.nPorts];
    t = [config.solver.dt,scenario.Tf];

    ODE = @(f,g,t,x0,u,p) solver(cmov(f()==0,setfields(discrete,'C',1,'x0',x0), ...
                                             setfields(discrete,'A',discrete.A','B',discrete.C','C',1,'x0',x0)), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 config.solver).y;

    WZ = emgr(@() 0,@() 1,s,t,'y',config.samples,[3,0,0,1,1,0,1,0,0,0,0,0,0],config.excitation);

    [LP,~,RP] = balro(WZ(iP,iP),config.rom_max);
    [LQ,~,RQ] = balro(WZ(iQ,iQ),config.rom_max);

    ROM = @(n) make_rom(name,discrete,{LP,RP;LQ,RQ},n);
    ODE = [];

    fprintf('\n');
end
