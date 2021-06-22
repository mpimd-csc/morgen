function r = D_q(D_k, L_k)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Inverse (!) mass-flux component coefficients (as diagonal matrix).

    r = spdiags(-L_k ./ circsurf(D_k), 0, numel(D_k), numel(D_k));
end
