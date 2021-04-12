%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Simulate GasLib_4197 network

for s = {'imex1','imex2','generic','rk4'}
    for m = {'ode_mid','ode_end'}

        morgen('GasLib4197','training',m{:},s{:},{},'dt=60'); % TODO Fix scenario
    end%for
end%for

