function n = norm_l0(x,h)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Time-domain approximate Lebesgue-0 norm.

    n = sum(prod(abs(x),1).^(1.0/size(x,1)),2);
end
