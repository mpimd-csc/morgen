function kgs = vf2kgs(value,vol_unit,time_unit,gas_density)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version:1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Convert volume flow in mass flow [kg/s]

    switch vol_unit

       case {'m3','m^3','sm3','sm^3'}
           vf = 1.0;

       case {'ksm3','ksm^3'}
           vf = 1000.0;

       case {'km3','km^3'}
           vf = 1000000.0;

       case {'cf'}
           vf = 1.0 / 35.315;

       case {'mcf'}
           vf = 1000.0 / 35.315;

       case {'mmcf'}
           vf = 1000000.0 / 35.315;

    end%switch

    switch time_unit

        case 's'
            uf = vf;

        case 'h'
            uf = vf / 3600.0;

        case 'd'
            uf = vf / 86400.0;

    end%switch

    if 3 == nargin

        gas_density = 0.7; % [kg/m^3] for high caloric natural gas
    end%if

    kgs = value .* uf .* gas_density;
end
