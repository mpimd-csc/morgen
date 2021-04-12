function l = friction_schifrinson(Re,D,k)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Schifrinson friction factor formula for turbulent flows.

    l = 0.11 * (k./D).^0.25;
end
