function l = friction_hofer(Re,D,k)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Hofer friction factor formula for turbulent flows.

    l = 1.0 ./ (-2.0 * log10( (4.518./Re) .* log10(Re./7.0) + k./(3.71*D) )).^2.0;
end
