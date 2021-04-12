function ROM = gopod_r(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured goal-oriented proper orthogonal decomposition.

    global ODE;

    name = 'Structured Goal-Oriented POD (WR)';
    fprintf('%s\n\n',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

    s = [discrete.nPorts, discrete.nP + discrete.nQ, discrete.nPorts];
    t = [config.solver.dt, scenario.Tf];

    ODE = @(f,g,t,x0,u,p) solver(setfields(discrete,'C',1,'x0',x0), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 config.solver).y;

    WR = emgr(@() 0,@() 1,s,t,'c',config.samples,[3,0,0,1,1,0,0,0,0,0,0,0,0],config.excitation);

    [LP,SP,RP] = svds(WR(iP,iP),config.rom_max);
    [LQ,SQ,RQ] = svds(WR(iQ,iQ),config.rom_max);

    [LP,~] = balgn(LP,diag(SP),[],discrete.C(:,iP));
    [LQ,~] = balgn(LQ,diag(SQ),[],discrete.C(:,iQ));

    ROM = @(n) make_rom(name,discrete,{LP;LQ},n);
    ODE = [];

    fprintf('\n');
end
