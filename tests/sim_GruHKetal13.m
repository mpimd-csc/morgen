%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD 2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Pipeline from GruHKetal13

for s = {'imex1','imex2','rk4','generic'}
    for m = {'ode_mid','ode_end'}

        morgen('GruHKetal13','rand',m{:},s{:},{},'dt=20');
    end%for
end%for

