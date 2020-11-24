function mf = vf2mf(vf,den)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Convert volume flow [m^3/h] in mass flow [kg/s]

    if nargin == 1

        den = 0.7; % [kg/m^3] for high caloric natural gas
    end%if

    mf = (vf / 3600.0) * den;
end
