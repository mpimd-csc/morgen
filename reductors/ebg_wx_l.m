function [proj,name] = ebg_wx_l(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured linear empirical cross-Gramian-based balanced gains.

    global ODE;

    name = 'Empirical Balanced Gains wx';

    logger('head',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

    sysdim = [discrete.nPorts,discrete.nP+discrete.nQ,discrete.nPorts];
    timedisc = [config.solver.dt,scenario.tH];
    flags = [3,0,0,1,1,0,0,0,0,0,0,0,0];

    % Specialize primal/dual solver
    ODE = @(f,g,t,x0,u,p) solver(cmov(f()==0,setfields(discrete,'C',1,'x0',x0), ...
                                             setfields(discrete,'A',discrete.A','B',discrete.C','C',1,'x0',x0,'dual',true)), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 config.solver).y;

    % Empirical linear cross Gramian
    WX = emgr(@() 0,@() 1,sysdim,timedisc,'y',config.samples,flags,config.excitation,[],[],0.01*scenario.us);

    % Pressure projector
    [LP,SP,RP] = balro(WX(iP,iP),config.rom_max);
    [LP,~,RP] = balgn(LP,SP,RP,discrete.C(:,iP));

    % Mass-flux projector
    [LQ,SQ,RQ] = balro(WX(iQ,iQ),config.rom_max);
    [LQ,~,RQ] = balgn(LQ,SQ,RQ,discrete.C(:,iQ));

    proj = {LP,RP; ...
            LQ,RQ};

    ODE = [];
end
