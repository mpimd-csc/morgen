function z = compressibility_aga88(p,T,pc,Tc)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: AGA-88 compressibility factor for pressures below 70bar.

    z = 1.0 + (0.257 - 0.533 * Tc / T) * p ./ pc;
end
