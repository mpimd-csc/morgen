function f_g = f_grav(d_g,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Gravity model selector generating closure.

    switch config

        case 'none'
            f_g = @(ps,p) 0;

        case 'static'
            f_g = @(ps,p) d_g .* ps;

        case 'dynamic'
            f_g = @(ps,p) d_g .* p;

    end%switch
end
