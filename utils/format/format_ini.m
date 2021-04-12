function content = format_ini(filename)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Read ini file and return structure.

    fh = fopen(filename,'r');

    co = textscan(fh,'%s = %s','CommentStyle','#');

    content = cell2struct(co{2},co{1});

    fclose(fh);
end
