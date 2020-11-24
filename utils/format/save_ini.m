function save_ini(filename,key,val)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Save ini file.

    fh = fopen(filename,'w');

    assert(numel(key) == numel(val),'key/value dimension mismatch.');

    for k = 1:numel(key)

        fprintf(fh,'"%s" = %.3f\n',key{k},val{k});
    end%for

    fclose(fh);
end
