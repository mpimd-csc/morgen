function [TL,HSV,TR] = balro(W,r)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Balance one or product of two system gramians.

    [VR,DR] = eigs(W,min(size(W,1),r));
    [VL,DL] = eigs(W',min(size(W,2),r));

    VR = VR .* sqrt(abs(diag(DR)))';
    VL = VL .* sqrt(abs(diag(DL)))';

    [U,D,V] = svd(VL' * VR);
    HSV = diag(D);
    D = sqrt(HSV)';
    TL = real(VL * (U ./ D));
    TR = real(VR * (V ./ D));
end

