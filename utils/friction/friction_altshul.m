function l = friction_altshul(Re,D,k)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Altshul friction factor formula for turbulent flows.

    l = 0.11 * ( (68.0./Re) + (k./D) ).^0.25;
end
