function [TL,D,TR] = balgn(tl,hs,tr,cb)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Simplified balanced gains.

    D = sum((cb * tl).^2,1)' .* hs(:);

    [D,ix] = sort(D,'descend');

    TL = tl(:,ix);

    if 3 == nargout

        TR = tr(:,ix);
    end%if
end
