%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Simulate SciGRID_gas Norway network data set.

for s = {'imex1','imex2','generic','rk4'}
    for m = {'ode_mid','ode_end'}

        morgen('SciGrid_NO','training',m{:},s{:},{},'dt=120');
    end%for
end%for

