%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Simulate GasLib_582 network

for s = {'imex1'}%,'imex2','generic','rk4'}
    for m = {'ode_mid'}%,'ode_end'}

        morgen('GasLib582','training',m{:},s{:},{},'dt=180'); % TODO Fix scenario
    end%for
end%for

