function refined_network = format_network(network_path,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Read net file and return a network structure.

% TODO valves
% FIXME [Octave] textscan padding (S & C)

    % Load CSV file into cell array of columns
    if isfile(network_path)

        col = textscan(fileread(network_path),'%c %f %f %f %f %f %f','HeaderLines',1,'Delimiter',',','EndOfLine','\n');

        % If Octave returns a cell convert to array
        if iscell(col{1})

            col{1} = cell2mat(col{1});
        end%if
    else

        error(['morgen: Could not locate network: ',network_path,' !']);
    end%if

    % Setup network
    idlist = upper(col{1});
    edgelist = [col{2},col{3}];

    network = struct();

    network.length = col{4};
    network.diameter = col{5};
    network.incline = col{6};
    network.roughness = col{7};

    % Test validity of network definition
    assert( all(ischar(idlist)),  'morgen: Illegal edge identifier.');
    assert( all(edgelist(:) > 0), 'morgen: Illegal edge list entry.');
    assert( all(isnumeric(network.incline) | isnan(network.incline)),   'morgen: Illegal edge incline.');
    assert( all((network.length > 0)       | isnan(network.length)),    'morgen: Illegal edge length.');
    assert( all((network.diameter > 0)     | isnan(network.diameter)),  'morgen: Illegal edge diameter.');
    assert( all((network.roughness >= 0)   | isnan(network.roughness)), 'morgen: Illegal edge roughness.');

    % Determine supply nodes
    uni_from = find(histc(edgelist(:,1),1:max(edgelist(:,1))) == 1);
    supply_nodes = intersect(setdiff(edgelist(:,1),edgelist(:,2)),uni_from);

    % Determine demand nodes
    uni_to = find(histc(edgelist(:,2),1:max(edgelist(:,2))) == 1);
    demand_nodes = intersect(setdiff(edgelist(:,2),edgelist(:,1)),uni_to);

%% Refine network

    % Enforce CFL condition
    nom_len = (config.dt * config.vmax) / config.cfl;

    [refined_idlist,refined_edgelist,refined_network] = refine(idlist,edgelist,network,nom_len);

    % Remove supply nodes from node unrefiner
    refined_network.unrefine_nodes(supply_nodes,:) = [];
    refined_network.unrefine_nodes(:,supply_nodes) = [];

    % Average contribution of refined edges
    nunref = size(refined_network.unrefine_edges,1);
    refined_network.unrefine_edges = spdiags(1.0./sum(refined_network.unrefine_edges,2),0,nunref,nunref) * refined_network.unrefine_edges;

%% Quantify network

    [supply_edges,~] = find(refined_edgelist(:,1) == supply_nodes');

    [demand_edges,~] = find(refined_edgelist(:,2) == demand_nodes');

    compressor_edges = find(refined_idlist == 'C');

    refined_network.nEdges = numel(refined_idlist);
    refined_network.nSupply = numel(supply_nodes);
    refined_network.nDemand = numel(demand_nodes);
    refined_network.nInternal = numel(unique(refined_edgelist(:))) - refined_network.nSupply - refined_network.nDemand;
    refined_network.nCompressor = numel(compressor_edges);

%% Build operators 

    % Assemble incidence matrix (nodes x edges)
    incidence = sparse(refined_edgelist, ...
                       repmat((1:refined_network.nEdges)',[1,2]), ...
                       repmat([-1,1],[refined_network.nEdges,1]));

    % Assemble supply operator
    refined_network.Bs = sparse(1:refined_network.nSupply,supply_edges,-1, ...
                                refined_network.nSupply,refined_network.nEdges);

    refined_network.Fc = sparse(1:refined_network.nCompressor,compressor_edges,-1, ...
                                max(1,refined_network.nCompressor),refined_network.nEdges);

    % Reduced incidence matrix (remove all zero rows and supply node rows)
    refined_network.A0 = incidence(setdiff(find(any(incidence,2)),supply_nodes),:); % Remove all supply nodes!

    % Assemble demand operator
    refined_network.Bd = refined_network.A0(:,demand_edges);
    refined_network.Bd(refined_network.Bd < 0) = 0;

    % Reduced incidence matrix of compressor outlets
    cc = refined_network.A0(:,compressor_edges);
    cc(cc > 0) = 0;
    refined_network.Ac = sparse(size(refined_network.A0,1),size(refined_network.A0,2));
    refined_network.Ac(:,compressor_edges) = cc;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [refined_ids,refined_edges,refined_network] = refine(ids,edges,network,nom_len)
%%% summary: Refine too-long pipes in network

    nEdges = numel(ids);
    nNodes = max(edges(:));

    extra = floor(network.length ./ nom_len);

    eff_extra = sum(extra(not(isnan(extra))));

    total = numel(ids) + eff_extra;

    mean_diam = mean(network.diameter(find(ids == 'P')));

    % pre-allocate
    refined_ids = zeros(total,1);
    refined_edges = zeros(total,2);

    refined_network = struct();

    refined_network.nomLen = nom_len;

    refined_network.length = zeros(total,1);
    refined_network.incline = zeros(total,1);
    refined_network.diameter = zeros(total,1);
    refined_network.roughness = zeros(total,1);

    refined_network.unrefine_nodes = [speye(nNodes); sparse(eff_extra,nNodes)];
    refined_network.unrefine_edges = [speye(nEdges); sparse(eff_extra,nEdges)];

    next_edge = size(edges,1) + 1;
    next_node = max(edges(:)) + 1;

    for k = 1:numel(ids)

        %% Handle too long pipes
        if (ids(k) == 'P') && (extra(k) > 0)

            new_edges = next_edge:(next_edge + extra(k) - 1);
            new_nodes = next_node:(next_node + extra(k) - 1);

            refined_edges([k,new_edges],:) = [[edges(k,1);new_nodes'], ... % from
                                              [new_nodes';edges(k,2)]];    % to

            refined_ids([k,new_edges]) = 'P';

            refined_network.length([k,new_edges]) = [repmat(nom_len,[extra(k),1]); ...
                                                     rem(network.length(k),nom_len)];
            refined_network.incline([k,new_edges]) = network.incline(k) ./ extra(k);
            refined_network.diameter([k,new_edges]) = network.diameter(k);
            refined_network.roughness([k,new_edges]) = network.roughness(k);

            next_edge = new_edges(end) + 1;
            next_node = new_nodes(end) + 1;

            refined_network.unrefine_edges(k,new_edges) = 1.0;

        %% Handle non-pipes
        elseif not(ids(k) == 'P')

            refined_ids(k) = ids(k);
            refined_edges(k,:) = edges(k,:);

            refined_network.length(k) = nom_len;
            refined_network.incline(k) = 0;
            refined_network.diameter(k) = mean_diam;
            refined_network.roughness(k) = 0;

        %% Handle nominal pipes
        else

            % copy unrefined network
            refined_ids(k) = ids(k);
            refined_edges(k,:) = edges(k,:);  

            refined_network.length(k) = network.length(k);
            refined_network.incline(k) = network.incline(k);
            refined_network.diameter(k) = network.diameter(k);
            refined_network.roughness(k) = network.roughness(k);  
        end%if
    end%for
end
