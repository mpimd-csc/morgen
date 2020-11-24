function refined_network = format_network(network_path,config)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Read net file and return a network structure.

% TODO valves
% FIXME textscan padding and broadcasting in lines 60,61 in Octave (fails for networks with compressors)

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

    nom_len = 2.0 * config.dt * config.vmax;

    [refined_idlist,refined_edgelist,refined_network] = refine(idlist,edgelist,network,nom_len);

    refined_network.node_op(supply_nodes,:) = [];
    refined_network.node_op(:,supply_nodes) = [];
    refined_network.node_op = refined_network.node_op ./ vecnorm(refined_network.node_op,2,1);
    refined_network.edge_op = refined_network.edge_op ./ vecnorm(refined_network.edge_op,2,1);  

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

    % PQ reduced incidence matrix (remove all zero rows and supply node rows)
    refined_network.PQ = incidence(setdiff(find(any(incidence,2)),supply_nodes),:); % Remove all supply nodes!

    % Assemble demand operator
    refined_network.Bd = refined_network.PQ(:,demand_edges);
    refined_network.Bd(refined_network.Bd < 0) = 0;

    % QP transposed reduced incidence matrix (edges x nodes)
    refined_network.QP = refined_network.PQ';
%
    % Correct incidence for compressors
    tmp = refined_network.QP(compressor_edges,:);

    tmp(tmp < 0) = 0;

    refined_network.QP(compressor_edges,:) = tmp;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [refined_idlist,refined_edgelist,refined_network] = refine(idlist,edgelist,network,nom_len)
%%% summary: Refine too-long pipes in network

    nEdges = numel(idlist);
    nNodes = max(edgelist(:));

    extra = floor(network.length ./ nom_len);

    eff_extra = sum(extra(not(isnan(extra))));

    total = numel(idlist) + eff_extra;

    mean_diam = mean(network.diameter(find(idlist == 'P')));

    % pre-allocate
    refined_id = zeros(total,1);
    refined_edgelist = zeros(total,2);

    refined_network = struct();

    refined_network.nomLen = nom_len;

    refined_network.length = zeros(total,1);
    refined_network.incline = zeros(total,1);
    refined_network.diameter = zeros(total,1);
    refined_network.roughness = zeros(total,1);

    refined_network.edge_op = [speye(nEdges); sparse(eff_extra,nEdges)];
    refined_network.node_op = [speye(nNodes); sparse(eff_extra,nNodes)];

    next_edge = size(edgelist,1) + 1;
    next_node = max(edgelist(:)) + 1;

    for k = 1:numel(idlist)

        %% Handle too long pipes
        if (idlist(k) == 'P') && (extra(k) > 0)

            new_edges = next_edge:(next_edge + extra(k) - 1);
            new_nodes = next_node:(next_node + extra(k) - 1);

            refined_edgelist([k,new_edges],:) = [[edgelist(k,1);new_nodes'], ... % from
                                                 [new_nodes';edgelist(k,2)]];    % to

            refined_idlist([k,new_edges]) = 'P';

            refined_network.length([k,new_edges]) = [repmat(nom_len,[extra(k),1]); ...
                                                     rem(network.length(k),nom_len)];
            refined_network.incline([k,new_edges]) = network.incline(k) ./ extra(k);
            refined_network.diameter([k,new_edges]) = network.diameter(k);
            refined_network.roughness([k,new_edges]) = network.roughness(k);

            next_edge = new_edges(end) + 1;
            next_node = new_nodes(end) + 1;

            refined_network.edge_op(new_edges,k) = 1.0;
            refined_network.node_op(new_nodes,edgelist(k,2)) = 1.0;

        %% Handle non-pipes
        elseif not(idlist(k) == 'P')

            refined_idlist(k) = idlist(k);
            refined_edgelist(k,:) = edgelist(k,:);

            refined_network.length(k) = nom_len;
            refined_network.incline(k) = 0;
            refined_network.diameter(k) = mean_diam;
            refined_network.roughness(k) = 0;

        %% Handle nominal pipes
        else

            % copy unrefined network
            refined_idlist(k) = idlist(k);
            refined_edgelist(k,:) = edgelist(k,:);  

            refined_network.length(k) = network.length(k);
            refined_network.incline(k) = network.incline(k);
            refined_network.diameter(k) = network.diameter(k);
            refined_network.roughness(k) = network.roughness(k);  
        end%if
    end%for
end
