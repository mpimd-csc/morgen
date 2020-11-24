function R = morgen(network_id,scenario_id,model_id,solver_id,reductor_ids,varargin)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Model reduction test platform and task master.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INIT MORGEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Version constant
    MORGEN_VERSION = 0.9;

    % Print welcome message
    fprintf('\n');
    fprintf('# morgen - Model Order Reduction for Gas and Energy Networks\n');
    fprintf('============================================================\n');
    fprintf('\n');

    % Add paths
    addpath(genpath('utils'));
    addpath('models');
    addpath('solvers');
    addpath('reductors');

    % On any exit, call cleanup function
    ocu = onCleanup(@cleanup);

    % Report version
    fprintf(' * Version: _ _ _ _ _ _ _ _ _ _ _ _ _ _ %g \n',MORGEN_VERSION);

    % Report environment
    if not(exist('OCTAVE_VERSION','builtin'))

        vec = @(m) m(:);
        fprintf(' * Environment: _ _ _ _ _ _ _ _ _ _ _ _ MATLAB \n');
    else

        % Octave has "vec" built-in
        fprintf(' * Environment: _ _ _ _ _ _ _ _ _ _ _ _ OCTAVE \n');
    end%if

    % Prepare return value
    R = [];

    fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('## Selected Ensemble:\n\n');

    % Check if "network_id" argument leads to a network file
    assert(isfile(['networks/',network_id,'.net']), ...
           ['morgen: unknown network: ',network_id]);
    network_path = ['networks/',network_id,'.net'];
    fprintf('  * Network:_ _ _ _ _ _ _ _ _ _ _ _ _ _ %s \n',network_id);

    % Check if "scenario_id" argument leads to a scenario file
    assert(isfile(['networks/',network_id,'/',scenario_id,'.ini']), ...
           ['morgen: unknown scenario: ',scenario_id]);
    scenario_path = ['networks/',network_id,'/',scenario_id,'.ini'];
    fprintf('  * Scenario: _ _ _ _ _ _ _ _ _ _ _ _ _ %s \n',scenario_id);

    % Check if "model_id" argument refers to a supported model
    assert(any(strcmpi({vec(dir('models/')).name}, ...
           [model_id,'.m'])),['morgen: unknown model: ',model_id]);
    %model_list = 
    model = str2func(model_id);
    fprintf('  * Discretization: _ _ _ _ _ _ _ _ _ _ %s \n',model_id);

    % Check if "solver_id" argument refers to a supported solver
    assert(any(strcmpi({vec(dir('solvers/')).name}, ...
           [solver_id,'.m'])),['morgen: unknown solver: ',solver_id]);
    solver = str2func(solver_id);
    fprintf('  * Time Stepper: _ _ _ _ _ _ _ _ _ _ _ %s \n',solver_id);

    % Check if "reductor_ids" argument refers to a list of supported reductors
    if exist('reductor_ids','var') && not(isempty(reductor_ids))

        reductor_func_mask = cellfun(@(c) any(strcmpi({vec(dir('reductors/')).name},[c,'.m'])),reductor_ids);
        reductor_file_mask = cellfun(@(c) strcmp('.rom',c(end-3:end)),reductor_ids);

        assert(all(reductor_func_mask + reductor_file_mask), ['morgen: unknown reductor(s): ', reductor_ids{:}]);
        reductor = cell(numel(reductor_ids),1);
        reductor(reductor_func_mask) = cellfun(@(c) str2func(c),reductor_ids(reductor_func_mask),'UniformOutput',false);
        reductor(reductor_file_mask) = reductor_ids(reductor_file_mask);
        fprintf('  * Reductor(s):_ _ _ _ _ _ _ _ _ _ _ _ ');
        cellfun(@(c) fprintf('%s \n                                        ',c),reductor_ids,'UniformOutput',false);
        if numel(reductor_ids) == 0, fprintf('\n'); end%if
    end%if

    fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP CONFIGURATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('## Reading Configuration ... ');

    % Read configuration file
    try

        ini = format_ini('morgen.ini');
    catch

        ini = [];
    end%try

    % Create "plots" folder if not exists
    plot_path = inifield(ini,'morgen_plots','z_plots');
    if not(exist(plot_path, 'dir')), mkdir(plot_path); end%if

    % Create "roms" folder if not exists
    rom_path = inifield(ini,'morgen_roms','z_roms');
    if not(exist(rom_path, 'dir')), mkdir(rom_path); end%if

    fprintf('Done.\n\n');

    if isempty(ini)

        fprintf('  < Configuration:_ _ _ _ _ _ _ _ _ _ _ hard-coded \n');
    else

        fprintf('  < Configuration:_ _ _ _ _ _ _ _ _ _ _ morgen.ini \n');
    end%if

    fprintf('\n');

    fprintf('  > Plot path:_ _ _ _ _ _ _ _ _ _ _ _ _ %s \n',plot_path);
    fprintf('  > ROM path: _ _ _ _ _ _ _ _ _ _ _ _ _ %s \n',rom_path);

    fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP NETWORK GRAPH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('## Loading Topology ... ');

    config.network.dt = max(sqrt(eps),inifield(ini,'network_dt',180));

    if not(isempty(varargin)) && any(strncmp(varargin,'dt=',3))

        config.network.dt = sscanf(varargin{strncmp(varargin,'dt=',3)},'dt=%g');
    end%if

    config.network.vmax = max(sqrt(eps),inifield(ini,'network_vmax',20));

    network = format_network(network_path,config.network);

    fprintf('Done.\n\n');

    fprintf('  < Time step [s]:_ _ _ _ _ _ _ _ _ _ _ %g \n',config.network.dt);
    fprintf('  < Maximum gas velocity [m/s]: _ _ _ _ %g \n',config.network.vmax);

    fprintf('\n');

    fprintf('  > Homogenized pipe length [m]:_ _ _ _ %g \n',network.nomLen);
    fprintf('  > Associated CFL constant:_ _ _ _ _ _ %.2g \n',cfl(network.nomLen,config.network.dt,config.network.vmax));
    fprintf('  > Number of refined edges:_ _ _ _ _ _ %u \n',network.nEdges);
    fprintf('  > Number of refined internal nodes: _ %u \n',network.nInternal);
    fprintf('  > Number of supply nodes: _ _ _ _ _ _ %u \n',network.nSupply);
    fprintf('  > Number of demand nodes: _ _ _ _ _ _ %u \n',network.nDemand);
    fprintf('  > Number of compressor edges: _ _ _ _ %u \n',network.nCompressor);

    fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP DISCRETE MODEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('## Initializing Model ... ');

    config.model.reynolds = inifield(ini,'model_reynolds',1e6);
    config.model.friction_name = inifield(ini,'model_friction','hofer',{'hofer','nikuradse','altshul','schifrinson','pmt1025','igt'});
    config.model.friction_fun = str2func(['friction_',config.model.friction_name]);
    config.model.friction = @(D,k) config.model.friction_fun(config.model.reynolds,D,k);

    discrete = model(network,config.model);

    fprintf('Done.\n\n');

    fprintf('  < Approx. Reynolds number [1]:_ _ _ _ %u \n',config.model.reynolds);
    fprintf('  < Friction model: _ _ _ _ _ _ _ _ _ _ %s \n',config.model.friction_name);

    fprintf('\n');

    fprintf('  > Number of total states: _ _ _ _ _ _ %u \n',discrete.nP + discrete.nQ);
    fprintf('  > Number of pressure states:_ _ _ _ _ %u \n',discrete.nP);
    fprintf('  > Number of mass-flux states: _ _ _ _ %u \n',discrete.nQ);
    fprintf('  > Number of boundary ports: _ _ _ _ _ %u \n',discrete.nPorts);

    fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP STEADY-STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('## Initializing Steady-State ... ');

    config.steady.dt = config.network.dt;
    config.steady.maxiter = max(1,round(inifield(ini,'steady_maxiter',1)));
    config.steady.maxerror = inifield(ini,'steady_maxerror',sqrt(eps));
    config.steady.Tc = celsius2kelvin(inifield(ini,'steady_Tc',-82.595));
    config.steady.pc = inifield(ini,'steady_pc',45.988);
    config.steady.pn = inifield(ini,'steady_pn',101.325);

    config.steady.compressibility_name = inifield(ini,'model_compressibility','ideal',{'ideal','dvgw','aga88','papay'});
    config.steady.compressibility_ref = inifield(ini,'model_compref','steady',{'steady','normal'});
    config.steady.compressibility_fun = str2func(['compressibility_',config.steady.compressibility_name]);

    if isequal(config.steady.compressibility_ref,'normal')

        config.steady.compressibility = @(p,T) config.steady.compressibility_fun(config.steady.pn,T,config.steady.pc,config.steady.Tc);
    else

        config.steady.compressibility = @(p,T) config.steady.compressibility_fun(p,T,config.steady.pc,config.steady.Tc);
    end%if

    fprintf('Done.\n\n');

    fprintf('  < Maximum steady state error: _ _ _ _ %g \n',config.steady.maxerror);
    fprintf('  < Maximum steady state iterations:_ _ %u \n',config.steady.maxiter);
    fprintf('  < Critical temperature [C]: _ _ _ _ _ %g \n',kelvin2celsius(config.steady.Tc));
    fprintf('  < Critical pressure [bar]:_ _ _ _ _ _ %g \n',config.steady.pc);
    fprintf('  < Normal pressure [bar]:_ _ _ _ _ _ _ %g \n',config.steady.pn);
    fprintf('  < Compressibility model:_ _ _ _ _ _ _ %s \n',config.steady.compressibility_name);

    fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP SOLVER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('## Initializing Solver ... ');

    config.solver.dt = config.network.dt;
    config.solver.relax = min(1.0,max(0,inifield(ini,'solver_relax',1)));
    config.solver.steadystate = @(s) steadystate(discrete,s,config.steady);

    fprintf('Done.\n\n');

    fprintf('  < Solver relaxation:_ _ _ _ _ _ _ _ _ %g \n', config.solver.relax);

    fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP SCENARIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('## Loading Scenario ... ');

    scenario = format_scenario(scenario_path,network);

    fprintf('Done.\n\n');

    fprintf('  > Ambient temperature [C]:_ _ _ _ _ _ %.2g \n',kelvin2celsius(scenario.T0));
    fprintf('  > Specific gas constant [J/(kg K)]: _ %g \n',scenario.Rs);
    fprintf('  > Time horizon [s]: _ _ _ _ _ _ _ _ _ %g \n',scenario.Tf);

    fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODEL REDUCTION OFFLINE PHASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if exist('reductor_ids','var') && not(isempty(reductor_ids))

        fprintf('## Computing Reduced Order Models ... \n\n');

        config.mor.rom_max = ceil(0.5*inifield(ini,'mor_max',100));

        if not(isempty(varargin)) && any(strncmp(varargin,'ord=',4))

            config.mor.rom_max = ceil(0.5*sscanf(varargin{strncmp(varargin,'ord=',4)},'ord=%g'));
        end%if

        config.mor.excitation_name = inifield(ini,'mor_excitation','step',{'impulse','step','random-binary','white-noise'});
        config.mor.parametric = inifield(ini,'mor_parametric','yes',{'no','yes'});
        config.mor.solver = config.solver;

        switch config.mor.excitation_name

            case 'step'
                config.mor.excitation = @training_step;

            case 'impulse'
                config.mor.excitation = @(t) training_impulse(t,config.network.dt);

            case 'random-binary'
                rand('seed',1009);
                config.mor.excitation = @training_randombinary;

            case 'white-noise'
                randn('seed',1009);
                config.mor.excitation = @training_whitenoise;
        end%switch

        fprintf('  < Training excitation:_ _ _ _ _ _ _ _ %s \n',config.mor.excitation_name);
        fprintf('  < Maximum reduced order:_ _ _ _ _ _ _ %u \n',2.0 * config.mor.rom_max);
        fprintf('  < Parametric reduction? _ _ _ _ _ _ _ %s \n',config.mor.parametric);

        % Configuration only relevant for parametric model order reduction
        if isequal(config.mor.parametric,'yes')

            config.mor.T0_min = celsius2kelvin(inifield(ini,'T0_min', 0.0));
            config.mor.T0_max = celsius2kelvin(inifield(ini,'T0_max',25.0));
            config.mor.Rs_min = inifield(ini,'Rs_min',500.0);
            config.mor.Rs_max = inifield(ini,'Rs_max',900.0);
            config.mor.pgrid = inifield(ini,'mor_pgrid',0);

            fprintf('  < Temperature range [C]:_ _ _ _ _ _ _ [%g,%g] \n',kelvin2celsius(config.mor.T0_min),kelvin2celsius(config.mor.T0_max));
            fprintf('  < Gas constant range [J/(kg K)]:_ _ _ [%g,%g] \n',config.mor.Rs_min,config.mor.Rs_max);
            fprintf('  < Parameter Grid Level: _ _ _ _ _ _ _ %u \n',config.mor.pgrid);

            config.mor.samples = sparsegrid([config.mor.T0_min;config.mor.Rs_min],[config.mor.T0_max;config.mor.Rs_max],config.mor.pgrid);
        else

            config.mor.samples = [scenario.T0;scenario.Rs];
        end%if

        fprintf('\n');

        nReductors = numel(reductor_ids);

        labels = cell(nReductors,1);
        ROM = cell(nReductors,1);
        offline = cell(nReductors,1);

        % Compute (or load) reduced order model (ROM) for each selected reductor
        for k = 1:nReductors

            fprintf('### ');

            % Compute and save ROM
            if isa(reductor{k},'function_handle')

                clear(func2str(solver));
                thunklog(100)
                off = tic;
                ROM{k} = reductor{k}(solver,discrete,scenario,config.mor);
                offline{k} = toc(off);
                thunklog(0)

                fprintf('\n');
                fprintf('   > Offline Time [s]: _ _ _ _ _ _ _ _ _ %d\n',offline{k});

                spaces = ROM{k}('save');
                name = ROM{k}('name');
                off = offline{k};
                save([rom_path,'/',network_id,'--',model_id,'--',solver_id,'--',reductor_ids{k},'.rom'],'spaces','name','off','-v7');

                fprintf('   > Saved as: _ _ _ _ _ _ _ _ _ _ _ _ _ %s \n\n',[network_id,'--',model_id,'--',solver_id,'--',reductor_ids{k},'.rom']);

            % Load ROM
            else

                rom_id = strsplit(reductor_ids{k},'--');

                if strcmp(network_id,rom_id{1}) && strcmp(model_id,rom_id{2})

                    load([rom_path,'/',reductor_ids{k}],'-mat');

                    ROM{k} = @(n) make_rom(name,discrete,spaces,n);
                    offline{k} = off;
                    fprintf('%s\n\n',ROM{k}('name'));
                    fprintf('   > Loaded from file:_ _ _ _ _ _ _ _ _ %s\n\n',reductor_ids{k});
                else

                    fprintf('   > Incompatible ROM: %s\n\n',reductor_ids{k}); % TODO emit error!
                end%if
            end%if

            labels{k} = name;
        end%for

        if not(isempty(varargin)) && any(strcmp(varargin,'notest'))

            R = struct('offline',offline, ...
                       'method',labels);

            fprintf(' > Orderly exit:_ _ _ _ _ _ _ _ _ _ _ _ ');

            return;
        end%if
    end%if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FULL ORDER SIMULATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('## Computing Reference Solution(s) ... \n\n');

    config.eval.parametric = inifield(ini,'eval_parametric','yes',{'no','yes'});

    % Sample test parameters
    if strcmp(config.eval.parametric,'yes') && exist('reductor_ids','var') && not(isempty(reductor_ids))

        prom = 1;
        config.eval.ptest = inifield(ini,'eval_ptest',1);

        nSamples = config.eval.ptest;

        config.eval.T0_min = celsius2kelvin(inifield(ini,'T0_min', 5.0));
        config.eval.T0_max = celsius2kelvin(inifield(ini,'T0_max',15.0));
        config.eval.Rs_min = inifield(ini,'Rs_min',500.0);
        config.eval.Rs_max = inifield(ini,'Rs_max',900.0);

        t0_samples = [config.eval.T0_min + abs(config.eval.T0_max - config.eval.T0_min) * rand(1,nSamples), scenario.T0]; ...
        rs_samples = [config.eval.Rs_min + abs(config.eval.Rs_max - config.eval.Rs_min) * rand(1,nSamples), scenario.Rs];

        fprintf('  < Parametric evaluation?_ _ _ _ _ _ _ %s \n',config.eval.parametric);
        fprintf('  < Number of parameter samples:_ _ _ _ %u \n',config.eval.ptest);
    else

        prom = 0;

        nSamples = 1;
        t0_samples = scenario.T0;
        rs_samples = scenario.Rs;

        fprintf('  < Parametric evaluation?_ _ _ _ _ _ _ no \n');
    end%if

    fprintf('\n  ');

    n1 = cell(nSamples + prom,1);
    n2 = cell(nSamples + prom,1);
    n8 = cell(nSamples + prom,1);
    n0 = cell(nSamples + prom,1);

    ref_output = cell(nSamples + prom,1);

    pscenario = cell(nSamples + prom,1);

    % Simulate scenario(s)
    for p = 1:(nSamples + prom) % For each test parameter (and the reference parameter) ...

        pscenario{p} = setfields(scenario,'T0',t0_samples(p),'Rs',rs_samples(p));

        clear(func2str(solver));
        ref_output{p} = solver(discrete,pscenario{p},config.solver);

        n1{p} = norm_l1(ref_output{p}.y,config.network.dt);
        n2{p} = norm_l2(ref_output{p}.y,config.network.dt);
        n8{p} = norm_l8(ref_output{p}.y,config.network.dt);
        n0{p} = norm_l0(ref_output{p}.y,config.network.dt);
    end%for

    fprintf('\n\n');

    fprintf('  > Steady state iterations:_ _ _ _ _ _ %u \n', ceil(mean(cellfun(@(s) s.steady.iter1,ref_output))));
    fprintf('  > Steady state extra steps: _ _ _ _ _ %u \n', ceil(mean(cellfun(@(s) s.steady.iter2,ref_output))));
    fprintf('  > Steady state error: _ _ _ _ _ _ _ _ %g \n', mean(cellfun(@(s) s.steady.err,ref_output)));
    fprintf('  > Mean compressibility: _ _ _ _ _ _ _ %g \n', mean(cellfun(@(s) s.steady.z0,ref_output)));
    fprintf('  > Integration time [s]: _ _ _ _ _ _ _ %g \n', mean(cellfun(@(s) s.runtime,ref_output)));

    % Plot input-output of reference solution
    compact = not(isempty(varargin)) && any(strcmp(varargin,'compact'));
    plot_output(plot_path,[network_id,'--',scenario_id,'--',model_id,'--',solver_id],ref_output{end},network,compact);

    fprintf('\n')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REDUCED ORDER MODEL EVALUATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if exist('reductor_ids','var') && not(isempty(reductor_ids))

        fprintf('## Evaluating Reduced Order Models ... \n\n');

        config.eval.skip = max(round(inifield(ini,'eval_skip',2)),2);
        config.eval.max = ceil(0.5 * min(inifield(ini,'eval_max',Inf)));

        if not(isempty(varargin)) && any(strncmp(varargin,'ord=',4))

            config.eval.max = ceil(0.5 * sscanf(varargin{strncmp(varargin,'ord=',4)},'ord=%g'));
        end%if

        config.eval.pnorm = inifield(ini,'eval_pnorm',2,{1,2,Inf});

        fprintf('  < Test every n-th ROM:_ _ _ _ _ _ _ _ %u \n',config.eval.skip);
        fprintf('  < Maximum reduced order:_ _ _ _ _ _ _ %u \n',2.0 * min([config.eval.max,config.mor.rom_max]));
        fprintf('  < Parameter norm: _ _ _ _ _ _ _ _ _ _ %u \n',config.eval.pnorm);

        fprintf('\n');

        redOrder = 1:config.eval.skip:min([config.eval.max,config.mor.rom_max,discrete.nP,discrete.nQ]);
        redOrders = numel(redOrder);

        online = cell(nReductors,1);
        breven = cell(nReductors,1);

        l1 = cell(nReductors,1);
        l2 = cell(nReductors,1);
        l8 = cell(nReductors,1);
        l0 = cell(nReductors,1);

        s1 = cell(nReductors,1);
        s2 = cell(nReductors,1);
        s8 = cell(nReductors,1);
        s0 = cell(nReductors,1);

        for k = 1:nReductors % For each reductor ...

            fprintf('### %s\n\n',ROM{k}('name'));

            % Preallocate error and timing storage
            online{k} = NaN(nSamples,redOrders);
            breven{k} = NaN(nSamples,redOrders);

            l1{k} = NaN(nSamples,redOrders);
            l2{k} = NaN(nSamples,redOrders);
            l8{k} = NaN(nSamples,redOrders);
            l0{k} = NaN(nSamples,redOrders);

            thunklog(redOrders)
            for p = 1:nSamples % For each test parameter ...

                for l = 1:redOrders % For each reduced order

                    red_output = solver(ROM{k}(redOrder(l)),pscenario{p},config.solver);
                    online{k}(p,l) = red_output.runtime ./ ref_output{p}.runtime;
                    breven{k}(p,l) = offline{k} ./ (ref_output{p}.runtime - red_output.runtime);

                    l1{k}(p,l) = norm_l1(ref_output{p}.y - red_output.y,config.network.dt) / n1{p};
                    l2{k}(p,l) = norm_l2(ref_output{p}.y - red_output.y,config.network.dt) / n2{p};
                    l8{k}(p,l) = norm_l8(ref_output{p}.y - red_output.y,config.network.dt) / n8{p};
                    l0{k}(p,l) = norm_l0(ref_output{p}.y - red_output.y,config.network.dt) / n0{p};
                end%for
            end%for
            thunklog(0)

            % Replace NaNs by worst case relative error
            l1{k}(isnan(l1{k}) | (l1{k} > 1.0)) = 1.0;
            l2{k}(isnan(l2{k}) | (l2{k} > 1.0)) = 1.0;
            l8{k}(isnan(l8{k}) | (l8{k} > 1.0)) = 1.0;
            l0{k}(isnan(l0{k}) | (l0{k} > 1.0)) = 1.0;

            % Average over parameter samples
            l1{k} = vecnorm(l1{k},config.eval.pnorm,1);
            l2{k} = vecnorm(l2{k},config.eval.pnorm,1);
            l8{k} = vecnorm(l8{k},config.eval.pnorm,1);
            l0{k} = vecnorm(l0{k},config.eval.pnorm,1);

            % Compute MORscores
            s1{k} = morscore(redOrder,l1{k});
            s2{k} = morscore(redOrder,l2{k});
            s8{k} = morscore(redOrder,l8{k});
            s0{k} = morscore(redOrder,l0{k});

            online{k} = mean(online{k},1);
            breven{k} = mean(breven{k},1);

            fprintf('\n\n');
        end%for

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUALIZE RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        effOrder = 2 * redOrder;

        if not(isempty(varargin)) && any(strncmp(varargin,'ys=',3))

            yscale = sscanf(varargin{strncmp(varargin,'ys=',3)},'ys=%g');
        else

            yscale = -16;
        end%if

        plot_error(plot_path,[network_id,'--',scenario_id,'--',model_id,'--',solver_id],'L_0',effOrder,l0,labels,s0,compact,yscale);
        plot_error(plot_path,[network_id,'--',scenario_id,'--',model_id,'--',solver_id],'L_1',effOrder,l1,labels,s1,compact,yscale);
        plot_error(plot_path,[network_id,'--',scenario_id,'--',model_id,'--',solver_id],'L_8',effOrder,l8,labels,s8,compact,yscale);
        plot_error(plot_path,[network_id,'--',scenario_id,'--',model_id,'--',solver_id],'L_2',effOrder,l2,labels,s2,compact,yscale);

        fprintf('  > L2 MORscores (%s--%s--%s--%s):\n\n',network_id,scenario_id,model_id,solver_id);
        maxlen = max(cellfun(@numel,labels));
        cellfun(@(l,s) fprintf(['  %s:',repmat(' ',[1,maxlen-numel(l)]),' %.2f \n'],l,s),labels,s2);
        save_ini([plot_path,'/',network_id,'--',scenario_id,'--',model_id,'--',solver_id,'_morscore_l2.ini'],labels,s2);
        fprintf('\n');

        plot_offline(plot_path,[network_id,'--',model_id,'--',solver_id],offline,labels,compact);
        plot_online(plot_path,[network_id,'--',scenario_id,'--',model_id,'--',solver_id],effOrder,online,labels,compact);
        plot_breven(plot_path,[network_id,'--',scenario_id,'--',model_id,'--',solver_id],effOrder,breven,labels,compact);

        R = struct('orders',redOrders, ...
                   'l0error',l0, 'l0score',s0, ...
                   'l1error',l1, 'l1score',s1, ...
                   'l2error',l2, 'l2score',s2, ...
                   'l8error',l8, 'l8score',s8, ...
                   'online',online, 'breven',breven, ...
                   'method',labels);
    end%if

    fprintf(' > Orderly exit:_ _ _ _ _ _ _ _ _ _ _ _ ');
end

