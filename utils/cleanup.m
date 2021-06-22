function cleanup()
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: morgen on-exit-cleanup.

    clear logger;
    clear steadystate;
    clear rk4;
    clear imex1;
    clear imex2;

    if exist('OCTAVE_VERSION','builtin')

        warning('on','Octave:nearly-Singular-Matrix');
        warning('on','Octave:lu:sparse_input');
        warning('on','Octave:negative-data-log-axis');
    else

        warning('on','MATLAB:nearlySingularMatrix');
    end%if

    fprintf('Bye\n\n');
end
