function v = inifield(ini,field,default,options)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Get structure field and test if from options.

    v = default;

    if isfield(ini,field)

        v = str2double(getfield(ini,field));

        if isnan(v) % if NaN use char string value

            v = default;

            if 4 == nargin

                iv = find(strcmpi(getfield(ini,field),options));

                if any(iv)

                    v = options{iv};
                end%if
            end%if
        end%if
    end%if
end
