function csv2net(network_path,output_name)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Convert SciGrid_gas csv file to morgen csv net


    if isfile(network_path)

        col = textscan(fileread(network_path),'%s %s %s %s %s %s %s %s %s %s %s %s','HeaderLines',1,'Delimiter',';','EndOfLine','\n');

        % If Octave returns a cell convert to array
        if iscell(col{4})

            col{4} = col{4};
            col{9} = col{9};
        end%if
    end%if

    ids = unique([cellfun(@(c) findtok(c,'[''',''''),col{4},'UniformOutput',false); ...
                  cellfun(@(c) findtok(c,', ''',''''),col{4},'UniformOutput',false)]);

    fid = fopen([output_name,'.net'],'w');
    fprintf(fid,'# type, identifier-in, identifier-out, pipe-length [m], pipe diameter [m], height difference [m], pipe roughness [m]\n');

    for k = 1:numel(col{4})

        from = find(strcmp(ids,findtok(col{4}{k},'[''','''')));
        to = find(strcmp(ids,findtok(col{4}{k},', ''','''')));



        if strcmp(ids(from),'') || strcmp(ids(to),''), continue; end%if

        dia = str2num(findtok(col{9}{k},'''diameter_mm'':',',')) * 0.001;
        len = str2num(findtok(col{9}{k},'''length_km'':',',')) * 1000.0;

        fprintf(fid,'%c,%i,%i,%f,%f,%f,%f \n','P',from,to,len,dia,0,0.0001);

    end%for

    fclose(fid);
end

function token = findtok(str,pat,del)

    idx = strfind(str,pat) + numel(pat);
    token = strtok(str(idx:end),del);
end

