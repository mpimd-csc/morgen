function p = sparsegrid(pmin,pmax,level)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Return sparse parameter grid for 2d parameter space.

    pavg = 0.5 * (pmin + pmax);

    switch(level)

        case 1

            p = [pavg, ...
                 [pavg(1);pmin(2)], [pavg(1);pmax(2)], [pmin(1);pavg(2)], [pmax(1);pavg(2)]];

        case 2

            p = [pavg, ...
                 [pavg(1);pmin(2)], [pavg(1);pmax(2)], [pmin(1);pavg(2)], [pmax(1);pavg(2)] ...
                 pmin, [pmin(1);pmax(2)], [pmax(1);pmin(2)], pmax];

        case 3

           p = [pavg, ...
                 [pavg(1);pmin(2)], [pavg(1);pmax(2)], [pmin(1);pavg(2)], [pmax(1);pavg(2)] ...
                 pmin, [pmin(1);pmax(2)], [pmax(1);pmin(2)], pmax, ...
                 0.5*[pavg(1);pmin(2)], 0.5*[pavg(1);pmax(2)], 0.5*[pmin(1);pavg(2)], 0.5*[pmax(1);pavg(2)]];

        case 4

           p = [pavg, ...
                 [pavg(1);pmin(2)], [pavg(1);pmax(2)], [pmin(1);pavg(2)], [pmax(1);pavg(2)] ...
                 pmin, [pmin(1);pmax(2)], [pmax(1);pmin(2)], pmax, ...
                 0.5*[pavg(1);pmin(2)], 0.5*[pavg(1);pmax(2)], 0.5*[pmin(1);pavg(2)], 0.5*[pmax(1);pavg(2)], ...
                 0.5*pmin, 0.5*[pmin(1);pmax(2)], 0.5*[pmax(1);pmin(2)], 0.5*pmax];

        otherwise

            p = pavg;

    end%switch
end
