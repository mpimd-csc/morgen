function R = morgen(network_id,scenario_id,model_id,solver_id,reductor_ids,varargin)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Model reduction test platform and task master.
%
% For help on morgen please see the <README.md> file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INIT MORGEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Start timer
    total = tic;

    % Version constant
    MORGEN_VERSION = 1.2;

    % Random number seeding
    SEED = 1009;
    rand('seed',SEED);
    randn('seed',SEED);

    % Add util path (recursively)
    addpath(genpath('utils'));

    % Print welcome message
    logger('head','morgen - Model Order Reduction for Gas and Energy Networks');

    % Add module paths
    addpath('models');
    addpath('solvers');
    addpath('reductors');

    % On any exit, call cleanup function
    ocu = onCleanup(@cleanup);

    % Report version
    logger('output','Version',MORGEN_VERSION,'%.1f');

    % Report environment and turn off specific warnings (restored by cleanup)
    if not(exist('OCTAVE_VERSION','builtin'))

        vec = @(m) m(:); % MATLAB does not have this functional definition of : (colon) operator
        warning('off','MATLAB:nearlySingularMatrix');       % Turn off warning potentially bloating the log
        warning('off','MATLAB:Axes:NegativeDataInLogAxis'); % Turn off about ignoring negative data in log plots
        logger('output','Environment','MATLAB','%s');
    else

        % Octave has "vec" built-in
        warning('off','Octave:nearly-singular-matrix'); % Turn off warning potentially bloating the log
        warning('off','Octave:lu:sparse_input');        % Octave warns by default about sparse matrices in LU decompositions
        warning('off','Octave:negative-data-log-axis'); % Turn off about ignoring negative data in log plots
        logger('output','Environment','OCTAVE','%s');
    end%if

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    logger('head','Parsing Ensemble: ...');

    % Check if "network_id" argument leads to a network file
    assert(isfile(['networks',filesep,network_id,'.net']), ...
           ['morgen: unknown network: ',network_id]);
    network_path = ['networks',filesep,network_id,'.net'];

    % Check if "scenario_id" argument leads to a scenario file
    assert(isfile(['networks',filesep,network_id,filesep,scenario_id,'.ini']), ...
           ['morgen: unknown scenario: ',scenario_id]);
    scenario_path = ['networks',filesep,network_id,filesep,scenario_id,'.ini'];

    % Check if "model_id" argument refers to a supported model
    assert(any(strcmpi({vec(dir(['models',filesep])).name}, ...
           [model_id,'.m'])),['morgen: unknown model: ',model_id]); 
    model_fun = str2func(model_id);

    % Check if "solver_id" argument refers to a supported solver
    assert(any(strcmpi({vec(dir(['solvers',filesep])).name}, ...
           [solver_id,'.m'])),['morgen: unknown solver: ',solver_id]);
    solver_fun = str2func(solver_id);

    % Check if "reductor_ids" argument refers to a list of supported reductors
    if exist('reductor_ids','var') && not(isempty(reductor_ids))

        reductor_func_mask = cellfun(@(c) any(strcmpi({vec(dir(['reductors',filesep])).name},[c,'.m'])),reductor_ids);
        reductor_file_mask = cellfun(@(c) strcmp('.rom',c(end-3:end)),reductor_ids);

        assert(all(reductor_func_mask + reductor_file_mask), ['morgen: unknown reductor(s): ', reductor_ids{:}]);
        reductor = cell(numel(reductor_ids),1);
        reductor(reductor_func_mask) = cellfun(@(c) str2func(c),reductor_ids(reductor_func_mask),'UniformOutput',false);
        reductor(reductor_file_mask) = reductor_ids(reductor_file_mask);
    end%if

    logger('done');

    logger('input','Network',network_id,'%s');
    logger('input','Scenario',scenario_id,'%s');
    logger('input','Discretization',model_id,'%s');
    logger('input','Time Stepper',solver_id,'%s');

    logger('line');

    if exist('reductor_ids','var') && not(isempty(reductor_ids))

        for k = reductor_ids

            logger('input','Reductor',k{:},'%s');
        end%for
    end%if

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP CONFIGURATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    logger('head','Reading Configuration ...');

    % Read configuration file
    try

        ini = format_ini('morgen.ini');
        ini_path = 'morgen.ini';
    catch

        ini = [];
        ini_path = 'hard-coded';
    end%try

    % Create "plots" folder if not exists
    plot_path = inifield(ini,'morgen_plots','z_plots');
    if not(exist(plot_path, 'dir')), mkdir(plot_path); end%if

    % Create "roms" folder if not exists
    rom_path = inifield(ini,'morgen_roms','z_roms');
    if not(exist(rom_path, 'dir')), mkdir(rom_path); end%if

    logger('done');

    logger('input','Configuration',ini_path,'%s');

    logger('line');

    logger('output','Plot path',plot_path,'%s');
    logger('output','ROM path',rom_path,'%s');

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP NETWORK GRAPH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    logger('head','Loading Topology ...');

    config.network.dt = varfield(varargin,'dt',inifield(ini,'network_dt',180));
    config.network.vmax = inifield(ini,'network_vmax',20);
    config.network.cfl = varfield(varargin,'cfl',inifield(ini,'network_cfl',0.5));

    network = format_network(network_path,config.network);

    logger('done');

    logger('input','Time step [s]',config.network.dt,'%g');
    logger('input','Maximum gas velocity [m/s]',config.network.vmax,'%g');
    logger('input','Enforced CFL constant',config.network.cfl,'%.2g');

    logger('line');

    logger('output','Homogenized pipe length [m]',network.nomLen,'%g');
    logger('output','Number of refined edges',network.nEdges,'%u');
    logger('output','Number of refined internal nodes',network.nInternal,'%u');
    logger('output','Number of supply nodes',network.nSupply,'%u');
    logger('output','Number of demand nodes',network.nDemand,'%u');
    logger('output','Number of compressor edges',network.nCompressor,'%u');

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP DISCRETE MODEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    logger('head','Initializing Model ...');

    config.model.tuning = varfield(varargin,'tf',inifield(ini,'model_tuning',1.0));
    config.model.reynolds = inifield(ini,'model_reynolds',1e6);
    friction_name = inifield(ini,'model_friction','hofer',{'hofer','nikuradse','altshul','schifrinson','pmt1025','igt'});
    friction_fun = str2func(['friction_',friction_name]);
    config.model.friction = @(D,k) friction_fun(config.model.reynolds,D,k);
    config.model.gravity = inifield(ini,'model_gravity','static',{'none','static','dynamic'});

    discrete = model_fun(network,config.model);

    logger('done');

    logger('input','Approx. Reynolds number [1]',config.model.reynolds,'%u');
    logger('input','Friction model',friction_name,'%s');
    logger('input','Gravity computation',config.model.gravity,'%s');

    logger('line');

    logger('output','Number of total states',discrete.nP + discrete.nQ,'%u');
    logger('output','Number of pressure states',discrete.nP,'%u');
    logger('output','Number of mass-flux states',discrete.nQ,'%u');
    logger('output','Number of boundary ports',discrete.nPorts,'%u');

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP STEADY-STATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    logger('head','Initializing Steady-State ...');

    config.steady.dt = config.network.dt;
    config.steady.maxiter_lin = max(1,round(inifield(ini,'steady_maxiter_lin',1)));
    config.steady.maxiter_non = max(1,round(inifield(ini,'steady_maxiter_non',1)));
    config.steady.maxerror = inifield(ini,'steady_maxerror',sqrt(eps));
    config.steady.Tc = celsius2kelvin(inifield(ini,'steady_Tc',-82.595));
    config.steady.pc = inifield(ini,'steady_pc',45.988);
    config.steady.pn = inifield(ini,'steady_pn',101.325);

    compressibility_name = inifield(ini,'model_compressibility','ideal',{'ideal','dvgw','aga88','papay'});
    compressibility_ref = inifield(ini,'model_compref','steady',{'steady','normal'});
    compressibility_fun = str2func(['compressibility_',compressibility_name]);

    if isequal(compressibility_ref,'normal')

        config.steady.compressibility = @(p,T) compressibility_fun(config.steady.pn,T,config.steady.pc,config.steady.Tc);
    else

        config.steady.compressibility = @(p,T) compressibility_fun(p,T,config.steady.pc,config.steady.Tc);
    end%if

    logger('done');

    logger('input','Maximum steady state error',config.steady.maxerror,'%g');
    logger('input','Maximum iterations (least-norm)',config.steady.maxiter_lin,'%u');
    logger('input','Maximum iterations (time-step)',config.steady.maxiter_non,'%u');
    logger('input','Critical temperature [C]',kelvin2celsius(config.steady.Tc),'%g');
    logger('input','Critical pressure [bar]',config.steady.pc,'%g');
    logger('input','Normal pressure [bar]',config.steady.pn,'%g');
    logger('input','Compressibility model',compressibility_name,'%s');

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP SOLVER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    logger('head','Initializing Solver ...');

    config.solver.dt = config.network.dt;
    config.solver.relax = min(1.0,max(0,inifield(ini,'solver_relax',1)));
    config.solver.rk2type = inifield(ini,'solver_rk2type',11,{5,6,7,8,9,10,11,12});
    config.solver.rk4type = inifield(ini,'solver_rk4type','MeaR99a',{'MeaR99a','MeaR99b','TseS05','App14'});
    config.solver.id = [network_id,'--',scenario_id];

    solver = @(d,s,c) solver_fun(d,s,setfield(c,'steady',steadystate(discrete,s,config.steady)));

    logger('done');

    switch solver_id

        case {'imex1','imex2'}, logger('input','Solver relaxation',config.solver.relax,'%.2f');
        case 'rk2hyp',          logger('input','Number of stages',config.solver.rk2type,'%u');
        case 'rk4hyp',          logger('input','Type',config.solver.rk4type,'%s');
    end%switch

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SETUP SCENARIO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    logger('head','Loading Scenario ...');

    scenario = format_scenario(scenario_path,network);

    logger('done');

    logger('output','Ambient temperature [C]',kelvin2celsius(scenario.T0),'%.2g');
    logger('output','Specific gas constant [J/(kg K)]',scenario.Rs,'%g');
    logger('output','Time horizon [s]',scenario.tH,'%g');

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODEL REDUCTION OFFLINE PHASE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if exist('reductor_ids','var') && not(isempty(reductor_ids))

        logger('head','Computing Reduced Order Models ...');

        rom_max = varfield(varargin,'ord',inifield(ini,'mor_max',250));

        config.mor.rom_max = min([ceil(0.5 * rom_max),discrete.nP,discrete.nQ]);

        config.mor.parametric = inifield(ini,'mor_parametric','true',{'false','true'});
        config.mor.solver = config.solver;

        excitation_name = inifield(ini,'mor_excitation','step',{'impulse','step','random-binary','white-noise'});

        % Set training input
        switch excitation_name

            case 'step'
                config.mor.excitation = @training_step;

            case 'impulse'
                config.mor.excitation = @(t) training_impulse(t,config.network.dt);

            case 'random-binary'
                config.mor.excitation = @training_randombinary;

            case 'white-noise'
                config.mor.excitation = @training_whitenoise;
        end%switch

        logger('input','Training excitation',excitation_name,'%s');
        logger('input','Max reduced order per variable',config.mor.rom_max,'%u');
        logger('input','Parametric reduction?',config.mor.parametric,'%s');

        logger('line');

        % Configuration only relevant for parametric model order reduction
        if strcmp(config.mor.parametric,'true')

            config.mor.T0_min = celsius2kelvin(inifield(ini,'T0_min', 0.0));
            config.mor.T0_max = celsius2kelvin(inifield(ini,'T0_max',25.0));
            config.mor.Rs_min = inifield(ini,'Rs_min',500.0);
            config.mor.Rs_max = inifield(ini,'Rs_max',900.0);
            config.mor.pgrid = inifield(ini,'mor_pgrid',0);

            logger('output','Temperature range [C]',[kelvin2celsius(config.mor.T0_min),kelvin2celsius(config.mor.T0_max)],'[%g,%g]');
            logger('output','Gas constant range [J/(kg K)]',[config.mor.Rs_min,config.mor.Rs_max],'[%g,%g]');
            logger('output','Parameter Grid Level',config.mor.pgrid,'%u');

            config.mor.samples = sparsegrid([config.mor.T0_min;config.mor.Rs_min],[config.mor.T0_max;config.mor.Rs_max],config.mor.pgrid);
        else

            config.mor.samples = [scenario.T0;scenario.Rs];
        end%if

        nReductors = numel(reductor_ids);

        labels = cell(nReductors,1);
        ROM = cell(nReductors,1);
        offline = cell(nReductors,1);

        % Compute (or load) reduced order model (ROM) for each selected reductor
        for k = 1:nReductors

            % Compute and save ROM
            if isa(reductor{k},'function_handle')

                id_off = tic;
                [proj,name] = reductor{k}(solver,discrete,scenario,config.mor);
                offtime = toc(id_off);						% Offline time used by reductor

                save([rom_path,filesep,network_id,'--',model_id,'--',solver_id,'--',reductor_ids{k},'.rom'],'proj','name','offtime','-v7');

                logger('line',2);

                logger('output','Offline Time [s]',offtime,'%.1f');
                logger('output','Saved as',[network_id,'--',model_id,'--',solver_id,'--',reductor_ids{k},'.rom'],'%s');

                logger('next');

            % Load ROM
            else

                rom_id = strsplit(reductor_ids{k},'--');

                if strcmp(network_id,rom_id{1}) && strcmp(model_id,rom_id{2})

                    load([rom_path,filesep,reductor_ids{k}],'-mat');

                    logger('head',name);

                    logger('line');

                    logger('output','Offline Time [s]',offtime,'%.1f');
                    logger('output','Loaded from file',reductor_ids{k},'%s');

                    logger('next');
                else

                    error(['Incompatible ROM: ',reductor_ids{k}]);
                end%if

                reductor_ids{k} = reductor_ids{k}(find(reductor_ids{k} == '-',1,'last')+1 ...
                                                  :find(reductor_ids{k} == '.',1,'last')-1); % NOTE: Argument mutation!
            end%if

            labels{k} = name;
            ROM{k} = @(n) make_rom(discrete,proj,n);
            offline{k} = offtime;
        end%for

        % Exit if only ROMs are to be computed and not tested
        if not(isempty(varargin)) && any(strcmp(varargin,'notest'))

            R = struct('reductors',labels, ...
                       'offline',offline);

            logger('exit',total);

            return;
        end%if

        logger('next');

    end%if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FULL ORDER SIMULATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    logger('head','Computing Reference Solution(s) ...');

    config.eval.parametric = inifield(ini,'eval_parametric','true',{'false','true'});

    % Sample test parameters
    if strcmp(config.eval.parametric,'true') && exist('reductor_ids','var') && not(isempty(reductor_ids))

        prom = 1;
        config.eval.ptest = inifield(ini,'eval_ptest',1);

        nSamples = config.eval.ptest;

        config.eval.T0_min = celsius2kelvin(inifield(ini,'T0_min', 5.0));
        config.eval.T0_max = celsius2kelvin(inifield(ini,'T0_max',15.0));
        config.eval.Rs_min = inifield(ini,'Rs_min',500.0);
        config.eval.Rs_max = inifield(ini,'Rs_max',900.0);

        t0_samples = [config.eval.T0_min + abs(config.eval.T0_max - config.eval.T0_min) * rand(1,nSamples), scenario.T0]; ...
        rs_samples = [config.eval.Rs_min + abs(config.eval.Rs_max - config.eval.Rs_min) * rand(1,nSamples), scenario.Rs];

        logger('input','Parametric evaluation?',config.eval.parametric,'%s');
        logger('input','Number of parameter samples',config.eval.ptest,'%u');
    else

        prom = 0;

        nSamples = 1;
        t0_samples = scenario.T0;
        rs_samples = scenario.Rs;

        logger('input','Parametric evaluation?','false','%s');
    end%if

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

    logger('line',2);

    logger('output','Steady state iterations',ceil(mean(cellfun(@(s) s.steady_iter1,ref_output))),'%u');
    logger('output','Steady state extra steps',ceil(mean(cellfun(@(s) s.steady_iter2,ref_output))),'%u');
    logger('output','Steady state error',mean(cellfun(@(s) s.steady_error,ref_output)),'%g');
    logger('output','Mean compressibility',mean(cellfun(@(s) s.steady_z0,ref_output)),'%g');
    logger('output','Integration time [s]',mean(cellfun(@(s) s.runtime,ref_output)),'%.1f');

    % Plot input-output of reference solution
    compact = not(isempty(varargin)) && any(strcmp(varargin,'compact'));
    plot_output(plot_path,[network_id,'--',scenario_id,'--',model_id,'--',solver_id],ref_output{end},network,compact);

    logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REDUCED ORDER MODEL EVALUATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if exist('reductor_ids','var') && not(isempty(reductor_ids))

        logger('head','Testing Reduced Order Models ...');

        config.eval.skip = max(round(inifield(ini,'eval_skip',2)),2);

        eval_max = varfield(varargin,'ord',inifield(ini,'eval_max',Inf));

        config.eval.max = min([floor(0.5*eval_max),config.mor.rom_max,discrete.nP,discrete.nQ]);

        config.eval.pnorm = inifield(ini,'eval_pnorm',2,{1,2,Inf});

        config.eval.gain = inifield(ini,'eval_gain','true',{'true','false'});

        redOrder = 1:config.eval.skip:config.eval.max;
        redOrders = numel(redOrder);

        logger('input','Test every n-th ROM',config.eval.skip,'%u');
        logger('input','Maximum reduced order',2 * config.eval.max,'%u'); % NOTE: config.eval.max means max red order per variable
        logger('input','Tested ROMs per reductor',nSamples * redOrders,'%u');

        if strcmp(config.eval.parametric,'true')

            logger('input','Parameter norm',config.eval.pnorm,'L%u');
        end%if

        logger('input','Use gain correction?',config.eval.gain,'%s');

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

        st = cell(nReductors,1);

        for k = 1:nReductors % For each reductor ...

            logger('head',labels{k});

            % Preallocate error and timing storage
            online{k} = NaN(nSamples,redOrders);
            breven{k} = NaN(nSamples,redOrders);

            dc = NaN(1,redOrders);

            l1{k} = NaN(nSamples,redOrders);
            l2{k} = NaN(nSamples,redOrders);
            l8{k} = NaN(nSamples,redOrders);
            l0{k} = NaN(nSamples,redOrders);

            logger('solver','reset');

            for p = 1:nSamples % For each test parameter ...

                tmp_online = NaN(1,redOrders);

                tmp_l1 = NaN(1,redOrders);
                tmp_l2 = NaN(1,redOrders);
                tmp_l8 = NaN(1,redOrders);
                tmp_l0 = NaN(1,redOrders);

                for l = 1:redOrders % For each reduced order ... 

                    rdiscrete = ROM{k}(redOrder(l));

                    red_output = solver(rdiscrete,pscenario{p},config.solver);

                    % Compute gain correction
                    if 1 == p
                        D = phgain(discrete,rdiscrete);
                        cor_gain = D * (red_output.u - scenario.us);
                        dc(l) = norm(cor_gain(:),1);
                    end%if

                    % Add gain correction
                    if strcmp(config.eval.gain,'true')

                        red_output.y = red_output.y + cor_gain;
                    end%if

                    tmp_online(l) = red_output.runtime;

                    tmp_l1(l) = norm_l1(ref_output{p}.y - red_output.y,config.network.dt);
                    tmp_l2(l) = norm_l2(ref_output{p}.y - red_output.y,config.network.dt);
                    tmp_l8(l) = norm_l8(ref_output{p}.y - red_output.y,config.network.dt);
                    tmp_l0(l) = norm_l0(ref_output{p}.y - red_output.y,config.network.dt);
                end%for

                online{k}(p,:) = tmp_online ./ ref_output{p}.runtime;
                breven{k}(p,:) = offline{k} ./ (ref_output{p}.runtime - tmp_online);

                l1{k}(p,:) = tmp_l1 ./ n1{p};
                l2{k}(p,:) = tmp_l2 ./ n2{p};
                l8{k}(p,:) = tmp_l8 ./ n8{p};
                l0{k}(p,:) = tmp_l0 ./ n8{p};

                logger('solver','reset');
            end%for

            logger('line');

            % Replace NaNs by worst case relative error
            l1{k}(isnan(l1{k}) | (l1{k} > 1.0)) = 1.0;
            l2{k}(isnan(l2{k}) | (l2{k} > 1.0)) = 1.0;
            l8{k}(isnan(l8{k}) | (l8{k} > 1.0)) = 1.0;
            l0{k}(isnan(l0{k}) | (l0{k} > 1.0)) = 1.0;

            % Count unstable ROMs
            st{k} = sum(l8{k}(:) == 1.0);

            % Average errors over parameter samples
            l1{k} = vecnorm(l1{k},config.eval.pnorm,1);
            l2{k} = vecnorm(l2{k},config.eval.pnorm,1);
            l8{k} = vecnorm(l8{k},config.eval.pnorm,1);
            l0{k} = vecnorm(l0{k},config.eval.pnorm,1);

            % Compute MORscores
            s1{k} = morscore(redOrder,l1{k});
            s2{k} = morscore(redOrder,l2{k});
            s8{k} = morscore(redOrder,l8{k});
            s0{k} = morscore(redOrder,l0{k});

            % Average timings over parameter samples
            online{k} = mean(online{k},1);
            breven{k} = mean(breven{k},1);

            logger('line');
            logger('output',['MORscore (L',num2str(config.eval.pnorm),' x L0)'],s0{k},'%.4f');
            logger('output',['MORscore (L',num2str(config.eval.pnorm),' x L1)'],s1{k},'%.4f');
            logger('output',['MORscore (L',num2str(config.eval.pnorm),' x L2)'],s2{k},'%.4f');
            logger('output',['MORscore (L',num2str(config.eval.pnorm),' x LInf)'],s8{k},'%.4f');
            logger('output','Average Gain Error',norm(dc(:),2),'%g');
            logger('output','Number of Unstable ROMs',st{k},'%u');

            logger('next');
        end%for

        logger('next');

        logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VISUALIZE RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        logger('head','Generating Plots ...');

        yscale = varfield(varargin,'ys',-16);

        plot_id = varfield(varargin,'pid','');
        base_name = [network_id,'--',scenario_id,'--',model_id,'--',solver_id];
        if not(isempty(plot_id))

            base_name = [base_name,'--',plot_id];
        end%if

        plot_error(plot_path,base_name,'L0',2 * redOrder,l0,labels,s0,compact,yscale);
        plot_error(plot_path,base_name,'L1',2 * redOrder,l1,labels,s1,compact,yscale);
        plot_error(plot_path,base_name,'L8',2 * redOrder,l8,labels,s8,compact,yscale);
        plot_error(plot_path,base_name,'L2',2 * redOrder,l2,labels,s2,compact,yscale);

        plot_offline(plot_path,[network_id,'--',model_id,'--',solver_id],offline,labels,compact);
        plot_morscore(plot_path,[network_id,'--',model_id,'--',solver_id],s2,labels,compact);
        plot_online(plot_path,base_name,2 * redOrder,online,labels,compact);
        plot_breven(plot_path,base_name,2 * redOrder,breven,labels,compact);

        logger('done');

        close(figure());

        logger('next');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRINT AND SAVE RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        logger('head',['MORscore Summary (',base_name,')']);

        logger('input','State norm',2,'L%u');
        logger('input','Parameter norm',config.eval.pnorm,'L%u');
        logger('input','Numerical precision |log10|',abs(floor(log10(eps))),'%u');
        logger('input','Maximum reduced order',2 * config.eval.max,'%u');

        logger('line');

        % For each reductor print L2 MORscore
        for k = 1:nReductors

            logger('output',reductor_ids{k},s2{k},'%.4f');
        end%for

        save_ini([plot_path,filesep,base_name,'_morscore_l2.ini'],labels,s2);

        R = struct('name',base_name, ...
                   'reductors',labels, ...
                   'orders',redOrder, ...
                   'l0error',l0, 'l0score',s0, ...
                   'l1error',l1, 'l1score',s1, ...
                   'l2error',l2, 'l2score',s2, ...
                   'l8error',l8, 'l8score',s8, ...
                   'offline',offline, ...
                   'online',online, ...
                   'breven',breven);
    else

        R = ref_output{1}.y;
    end%if

    logger('exit',total);
end

