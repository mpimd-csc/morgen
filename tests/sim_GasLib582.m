%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD 2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Simulate GasLib_582 network

for s = {'imex1','imex2','generic','rk4'}
    for m = {'ode_mid','ode_end'}

        morgen('GasLib582','training',m{:},s{:},{},'dt=60');
    end%for
end%for

