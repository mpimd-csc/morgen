function ROM = eds_ro(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured empirical dominant subspaces.

    global ODE;

    name = 'Structured Empirical Dominant Subspaces (WR + WO)';
    fprintf('%s\n\n',name);

    ODE = @(f,g,t,x0,u,p) solver(setfields(discrete,'C',cmov(numel(g(x0,u(0),p,0)) == numel(x0),1,discrete.C)), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 setfields(config.solver,'x0',x0)).y;

    s = [discrete.nPorts, discrete.nP + discrete.nQ, discrete.nPorts];
    t = [config.solver.dt, scenario.Tf];

    WR = emgr([],@(x,u,p,t) 1,s,t,'c',config.samples,[0,0,0,1,1,0,0,0,0,0,0,0,0],config.excitation,[],[],[],[]);
    WO = emgr([],@(x,u,p,t) 1,s,t,'o',config.samples,[0,0,0,1,1,0,0,0,0,0,0,0,0],config.excitation,[],[],[],[]);

    [uc,sc,~] = svds(WR(1:discrete.nP,1:discrete.nP),config.rom_max);
    [uo,so,~] = svds(WO(1:discrete.nP,1:discrete.nP),config.rom_max);
    [LP,~,~] = svds([uc.*(diag(sc)./norm(sc))',uo.*(diag(so)./norm(so))'],config.rom_max);

    [uc,sc,~] = svds(WR(discrete.nP+1:end,discrete.nP+1:end),config.rom_max);
    [uo,so,~] = svds(WO(discrete.nP+1:end,discrete.nP+1:end),config.rom_max);
    [LQ,~,~] = svds([uc.*(diag(sc)./norm(sc))',uo.*(diag(so)./norm(so))'],config.rom_max);

    ROM = @(n) make_rom(name,discrete,{LP;LQ},n);
    ODE = [];

    fprintf('\n');
end
