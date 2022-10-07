%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Simulate GasLib_134 network.

for s = {'imex1','imex2','cnab2','rk4','rk2hyp','rk4hyp'} % generic crashes MATLAB
    for m = {'ode_mid','ode_end'}

        morgen('GasLib134','rand',m{:},s{:},{},'dt=30');
    end%for
end%for

