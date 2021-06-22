function v = varfield(vararg,field,default)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Get field or return default.

    nf = numel(field);

    v = default;

    if not(isempty(vararg)) && any(strncmp(vararg,field,nf))

        s = sscanf(vararg{strncmp(vararg,field,nf)},[field,'=%s']);

        v = str2double(s);

        if isnan(v)

           v = s;
        end%if
    end%if
end
