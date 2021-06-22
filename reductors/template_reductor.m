function [proj,name] = template_reductor(solver,discrete,scenario,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Template reductor

    name = 'Your reductor name';

    logger('head',name);

    iP = 1:discrete.nP;
    iQ = discrete.nP+1:discrete.nP+discrete.nQ;


    % Your code goes here


    % and computes the following projectors
    % LP = Left_Pressure_Projector
    % RP = Right_Pressure_Projector
    % LQ = Left_Massflux_Projector
    % RQ = Right_Massflux_Projector

    proj = {LP,RP;LQ,RQ}; % Petrov-Galerkin

    % or

    proj = {LP;LQ}; % Galerkin
end
