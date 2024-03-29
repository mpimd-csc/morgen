function A = dmd(X)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Dynamic mode decomposition with scaling.

    s = 1.0 ./ max(eps,vecnorm(X(:,2:end),2,1));

    [U0,D0,V0] = svd(X(:,1:end-1).*s,'econ');

    D0 = diag(D0);

    A = (X(:,2:end).*s) * (V0 ./ D0') * U0';
end
