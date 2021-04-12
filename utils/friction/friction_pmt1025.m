function l = friction_pmt1025(Re,D,k)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2020-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: PMT-1025 friction factor formula for turbulent flows.

    l = 0.067 * ( (158.0./Re) + (2.0*k)./D ).^0.2;
end
