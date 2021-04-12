function thunklog(s)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Auto linebreak logger.

    persistent col;
    persistent colmax;

    switch nargin

        case 1

            if 0 == s

                colmax = [];
                col = [];
            elseif -1 == s

                col = col - not(isempty(col));
                fprintf('\b');
            else

                colmax = s;
                col = 1;
            end%if

        case 0

            if not(isempty(col))

                if 1 == col

                    fprintf('   ');
                elseif col > colmax

                    fprintf('\n   ');
                    col = 1;
                end%if

                col = col + 1;
            end%if

            fprintf('=');
    end%switch
end
