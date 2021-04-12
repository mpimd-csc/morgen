function scenario = format_scenario(scenario_path,network)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Read scenario ini file and return a structure.

    ini = format_ini(scenario_path);

    scenario.T0 = celsius2kelvin(str2double(ini.T0));				 % ambient temperature
    scenario.Rs = str2double(ini.Rs);						 % specific gas constant
    scenario.Tf = str2double(ini.tH);						 % time horizon

    supply_pressure = cell2mat(cellfun(@(c) str2num(c),strsplit(ini.up,'|'),'UniformOutput',false));
    assert(size(supply_pressure,1) == network.nSupply,'network/scenario supply mismatch');

    demand_massflux = cell2mat(cellfun(@(c) str2num(c),strsplit(ini.uq,'|'),'UniformOutput',false));
    assert(size(demand_massflux,1) == network.nDemand,'network/scenario demand mismatch');

    time_index = str2double(strsplit(ini.ut,'|'));
    assert(numel(time_index) == size(supply_pressure,2),'scenario time/supply mismatch');
    assert(numel(time_index) == size(demand_massflux,2),'scenario time/demand mismatch');

    % Decode and center input time series
    scenario.us = [supply_pressure(:,1); demand_massflux(:,1)];		 % steady state input

    centered_input = [supply_pressure; demand_massflux] - scenario.us;		 % shift by time zero values (assumed to be steady-state)					

    scenario.ut = @(t) centered_input(:,find(t >= time_index,1,'last'));	 % input function

    % Decode compressors
    if isfield(ini,'cp')

        scenario.cp = str2num(ini.cp);
        assert(numel(scenario.cp) == network.nCompressor,'network/scenario demand mismatch');
    else

        scenario.cp = 0;
        assert(0 == network.nCompressor,'network/scenario demand mismatch');
    end%if
end

