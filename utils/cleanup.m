function cleanup()
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: morgen on exit cleanup.

    clear steadystate;
    clear rk4;
    clear imex1;
    clear imex2;
    fprintf('Bye\n\n');
end
