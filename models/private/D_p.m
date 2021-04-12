function r = D_p(D_k, L_k)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Inverse (!) pressure component coefficients (as diagonal matrix).

    r = spdiags(-circsurf(D_k) .* L_k, 0, numel(D_k), numel(D_k));
end
