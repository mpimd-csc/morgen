function ROM = ebt_wz(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured empirical non-symmetric-cross-Gramian-based balanced truncation.

    global ODE;

    name = 'Structured Empirical Balanced Truncation (WZ)';
    fprintf('%s\n\n',name);

    ODE = @(f,g,t,x0,u,p) solver(setfields(discrete,'C',cmov(numel(g(x0,u(0),p,0))==numel(x0),1,discrete.C)), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 setfields(config.solver,'x0',x0)).y;

    s = [discrete.nPorts,discrete.nP+discrete.nQ,discrete.nPorts];
    t = [config.solver.dt,scenario.Tf];

    WZ = emgr([],@(x,u,p,t) 1,s,t,'x',config.samples,[0,0,0,1,1,0,1,0,0,0,0,0,0],config.excitation);

    [LP,~,RP] = balro(WZ(1:discrete.nP,1:discrete.nP),config.rom_max);
    [LQ,~,RQ] = balro(WZ(discrete.nP+1:end,discrete.nP+1:end),config.rom_max);

    ROM = @(n) make_rom(name,discrete,{LP,RP;LQ,RQ},n);
    ODE = [];

    fprintf('\n');
end
