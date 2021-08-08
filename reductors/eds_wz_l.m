function [proj,name] = eds_wz_l(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Structured linear empirical non-symmetric-cross-Gramian-based dominant subspaces.

    global ODE;

    name = 'Struct. Empirical Dominant Subspaces (WZ*)';

    logger('head',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;

    sysdim = [discrete.nPorts, discrete.nP + discrete.nQ, discrete.nPorts];
    timedisc = [config.solver.dt, scenario.tH];
    flags = [3,0,0,1,1,0,1,0,0,0,0,0,0];

    % Specialize primal/dual solver
    ODE = @(f,g,t,x0,u,p) solver(cmov(f()==0,setfields(discrete,'C',1,'x0',x0), ...
                                             setfields(discrete,'A',discrete.A','B',discrete.C','C',1,'x0',x0,'dual',true)), ...
                                 setfields(scenario,'ut',u,'T0',p(1),'Rs',p(2)), ...
                                 config.solver).y;

    % Empirical linear non-symmetric cross Gramian
    WZ = emgr(@() 0,@() 1,sysdim,timedisc,'y',config.samples,flags,config.excitation);

    % Pressure projector
    [uz,dz,vz] = svds(WZ(iP,iP),config.rom_max);
    [LP,~,~] = svds([uz.*diag(dz)',vz.*diag(dz)'],config.rom_max);

    % Mass-flux projector
    [uz,dz,vz] = svds(WZ(iQ,iQ),config.rom_max);
    [LQ,~,~] = svds([uz.*diag(dz)',vz.*diag(dz)'],config.rom_max);

    proj = {LP; ...
            LQ};

    ODE = [];
end
