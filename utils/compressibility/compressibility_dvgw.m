function z = compressibility_dvgw(p,T,pc,Tc)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: DVGW-G-2000 compressibility formula for up to 70bar.

    z = 1.0 - p ./ 450.0;
end
