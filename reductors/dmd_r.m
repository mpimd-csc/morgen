function [proj,name] = dmd_r(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured dynamic-mode-decomposition-Galerkin.

    global ODE;

    name = 'Dynamic Mode Decomposition Galerkin';

    logger('head',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

    sysdim = [discrete.nPorts, discrete.nP + discrete.nQ, discrete.nPorts];
    timedisc = [config.solver.dt, scenario.tH];
    flags = [3,0,0,1,1,0,0,0,0,0,0,0,0];

    % Specialize state solver
    ODE = @(f,g,t,x0,u,p) solver(setfields(discrete,'C',1,'x0',x0), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 config.solver).y;

    dmd_kernel = @(x,y) blkdiag(dmd(x(iP,:)),dmd(x(iQ,:)));

    % Empirical reachability Gramian
    WR = emgr(@() 0,@() 1,sysdim,timedisc,'c',config.samples,flags,config.excitation,[],[],0.01*scenario.us,[],dmd_kernel);

    % Pressure projector
    [LP,~,~] = svds(WR(iP,iP),config.rom_max);

    % Mass-flux projector
    [LQ,~,~] = svds(WR(iQ,iQ),config.rom_max);

    proj = {LP; ...
            LQ};

    ODE = [];
end
