function thunklog(s)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: Auto linebreak logger.

    persistent col;
    persistent colmax;

    switch nargin

        case 1

            if (s == 0)

                colmax = [];
                col = [];
            elseif (s == -1)

                col = col - not(isempty(col));
                fprintf('\b');
            else

                colmax = s;
                col = 1;
            end%if

        case 0

            if not(isempty(col))

                if (col == 1)

                    fprintf('   ');
                elseif (col > colmax)

                    fprintf('\n   ');
                    col = 1;
                end%if

                col = col + 1;
            end%if

            fprintf('=');
    end%switch
end
