function l = friction_nikuradse(Re,D,k)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Nikuradse friction factor formula for turbulent flows.

    l = 1.0 ./ ( -2.0 * log10( k./(3.71*D) ) ).^2.0;
end
