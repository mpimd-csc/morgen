function s = morscore(orders,errors)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: MORscore computation.

    pp = errors;
    pp(isnan(errors)) = 1.0;

    nx = orders ./ max(orders);
    ny = log10(pp) ./ floor(log10(eps));

    if not(nx(end) == 1)

        nx(end+1) = 1;
        ny(end+1) = ny(end);
    end%if

    s = max(0, trapz(nx(:),ny(:)));
end
