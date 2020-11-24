function json2csv(network_path,output_name)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Convert json to MORGEN csv

    raw = jsondecode(fileread(network_path));

    fields = fieldnames(raw);

    csv{1} = '# type, identifier-in, identifier-out, pipe-length [m], pipe diameter [m], height difference [m], pipe roughness [m]';

    curr = 2;

    nodes = {};
    height = {};

    n = 1;

    % list nodes
    for k = 1:numel(fields)

        if isstruct(raw.(fields{k})) && (lower(raw.(fields{k}).obj_type) == 'n')

            nodes{n} = fields{k};
            height{n} = str2num(raw.(fields{k}).H);
            n = n + 1;
        end%if
    end%for

    % process edges
    for k = 1:numel(fields)

        if isstruct(raw.(fields{k})) && not(lower(raw.(fields{k}).obj_type) == 'n')

            node1 = find(strcmp(nodes,strrep(raw.(fields{k}).node1,'-','_')));
            node2 = find(strcmp(nodes,strrep(raw.(fields{k}).node2,'-','_')));

            switch lower(raw.(fields{k}).obj_type)

                case 'p' % pipeline

                    pipelength = str2num(raw.(fields{k}).l);
                    diameter = str2num(raw.(fields{k}).d);
                    roughness = str2num(raw.(fields{k}).k);

                    csv{curr} = ['P,', ...
                                 num2str(node1,'%u'),',', ...
                                 num2str(node2,'%u'),',', ...
                                 num2str(pipelength,'%.1f'),',', ...
                                 num2str(diameter,'%.2f'),',', ...
                                 num2str(height{node1} - height{node2},'%.1f'),',', ...
                                 num2str(roughness,'%.4f')];
                    curr = curr + 1;

                case 'c' % compressor

                    diameter = str2num(raw.(fields{k}).d);

                    csv{curr} = ['C,', ...
                                 num2str(node1,'%u'),',', ...
                                 num2str(node2,'%u')];
                    curr = curr + 1;

                case 'v' % valve -> short pipe TODO

                    diameter = str2num(raw.(fields{k}).d);

                    csv{curr} = ['S,', ...
                                 num2str(node1,'%u'),',', ...
                                 num2str(node2,'%u')];
                    curr = curr + 1;

                case 'r' % resistor -> short pipe

                    csv{curr} = ['S,', ...
                                 num2str(node1,'%u'),',', ...
                                 num2str(node2,'%u')];
                    curr = curr + 1;

            end%switch
        end%if
    end%for

    fhandle = fopen(['../networks/',output_name,'.net'],'w');
    fprintf(fhandle,'%s\n',csv{:});
    fclose(fhandle);
end
