function v = inifield(ini,field,default,options)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Get structure field and test if from options.

    v = default;

    if isfield(ini,field)

        v = str2double(getfield(ini,field));

        if isnan(v) % if NaN use char string value

            v = default;

            if nargin == 4

                iv = find(strcmpi(getfield(ini,field),options));

                if any(iv)

                    v = options{iv};
                end%if
            end%if
        end%if
    end%if
end
