function D = phgain(discrete,rdiscrete)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Approximate port-Hamiltonian feed-forward/feed-through term

    D = discrete.B' * discrete.B - rdiscrete.B' * rdiscrete.B;
end
