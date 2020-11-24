function [xk,ys] = initialstate(discrete,steady,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Set initial state and initial output.

    if isfield(config,'x0')

        xk = config.x0;
        ys = discrete.C * steady.xs; % This cannot be steady.ys, as the reductors may use C = 1.
    else

        xk = zeros(discrete.nP + discrete.nQ,1);
        ys = steady.ys;
    end%if
end

