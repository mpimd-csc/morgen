function [TL,D,TR] = balgn(tl,hs,tr,cb)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Simplified balanced gains.

    D = sum((cb * tl).^2,1)' .* hs(:);

    [D,ix] = sort(D,'descend');

    TL = tl(:,ix);
    TR = tr(:,ix);
end
