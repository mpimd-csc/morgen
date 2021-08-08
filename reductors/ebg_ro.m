function [proj,name] = ebg_ro(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured nonlinear empirical balanced gains.

    global ODE;

    name = 'Struct. Empirical Balanced Gains (WR + WO)';

    logger('head',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

    sysdim = [discrete.nPorts,discrete.nP+discrete.nQ,discrete.nPorts];
    timedisc = [config.solver.dt,scenario.tH];
    flags = [3,0,0,1,1,0,0,0,0,0,0,0,0];

    % Specialize state solver
    ODE = @(f,g,t,x0,u,p) solver(setfields(discrete,'C',1,'x0',x0), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 config.solver).y;

    % Empirical reachability Gramian
    WR = emgr(@() 0,@() 1,sysdim,timedisc,'c',config.samples,flags,config.excitation);

    % Specialize output solver
    ODE = @(f,g,t,x0,u,p) solver(setfields(discrete,'x0',x0), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 config.solver).y;

    % Empirical observability Gramian
    WO = emgr(@() 0,@(x,u,p,t) discrete.C * x,sysdim,timedisc,'o',config.samples,flags,config.excitation);

    % Pressure projector
    [LP,SP,RP] = balro(WR(iP,iP)*WO(iP,iP),config.rom_max);
    [LP,~,RP] = balgn(LP,SP,RP,discrete.C(:,iP));

    % Mass-flux projector
    [LQ,SQ,RQ] = balro(WR(iQ,iQ)*WO(iQ,iQ),config.rom_max);
    [LQ,~,RQ] = balgn(LQ,SQ,RQ,discrete.C(:,iQ));

    proj = {LP,RP; ...
            LQ,RQ};

    ODE = [];
end
