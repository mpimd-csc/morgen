function randscen(network,scenario_name)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Generate random scenario from training scenario

    %% Read Training Scenario

    f = fopen(['../networks/',network,'/training.ini'],'r');

    co = textscan(f,'%s = %s','CommentStyle','#');

    ini = cell2struct(co{2},co{1});

    fclose(f);

    %% Write Random Scenario

    f = fopen(['../networks/',network,'/',scenario_name,'.ini'],'w');

    fprintf(f,'T0 = %g\n',str2double(ini.T0));
    fprintf(f,'Rs = %g\n',str2double(ini.Rs));
    fprintf(f,'tH = %g\n',86400.0);

    %% Compressor Pressures

    if isfield(ini,'cp')
        compressor_pressure = cell2mat(cellfun(@(c) str2double(c),strsplit(ini.cp,';'),'UniformOutput',false))';

        fprintf(f,'cp = ');
        for l = 1:(numel(compressor_pressure) - 1)

            fprintf(f,'%g;',compressor_pressure(l));
        end%for

        fprintf(f,'%g\n',compressor_pressure(end));
    end%if

    %% Supply Pressures

    supply_pressure = cell2mat(cellfun(@(c) str2double(c),strsplit(ini.up,';'),'UniformOutput',false))';

    fprintf(f,'up = ');
    for k = 1:24

        for l = 1:numel(supply_pressure)

            if l < numel(supply_pressure)

                fprintf(f,'%g;',supply_pressure(l));
            elseif k < 24

                fprintf(f,'%g|',supply_pressure(l));
            else

                fprintf(f,'%g\n',supply_pressure(l));
            end%if
        end%for
    end%for

    %% Demand Mass-Fluxes

    demand_massflux = cell2mat(cellfun(@(c) str2double(c),strsplit(ini.uq,';'),'UniformOutput',false));

    rand_demand = [demand_massflux; demand_massflux .* (0.5 + 0.75*rand(23,numel(demand_massflux)))];

    fprintf(f,'uq = ');
    for k = 1:24

        for l = 1:numel(demand_massflux)

            if l < numel(demand_massflux)

                fprintf(f,'%g;',rand_demand(k,l));
            elseif k < 24

                fprintf(f,'%g|',rand_demand(k,l));
            else

                fprintf(f,'%g\n',rand_demand(k,l));
            end%if
        end%for
    end%for

    %% Time Inidices

    fprintf(f,'ut = ');
    for k = 0:22

        fprintf(f,'%g|',k*3600);
    end%for

    fprintf(f,'%g\n',23*3600);

    fclose(f);
end
