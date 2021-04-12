%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Pipeline from GruHKetal13.

for s = {'imex1'}%,'imex2','rk4','generic'}
    for m = {'ode_mid'}%,'ode_end'}

        morgen('GruHKetal13','training',m{:},s{:},{},'dt=20'); % TODO Fix scenario
    end%for
end%for

