function z = compressibility_papay(p,T,pc,Tc)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Papay compressibility factor for pressures below 150bar.

    a = -3.52 / pc * exp(-2.26 * T / Tc);
    b = 0.274 / (pc * pc) * exp(-1.878 * T / Tc);

    z = 1.0 + a * p + b * (p .* p);
end
