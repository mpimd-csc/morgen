function logger(t,s,v,f)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.0 (2021-06-22)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: declarative logging functions

    persistent level;
    persistent column;

    COL_MAX = 100;

    if isempty(level)

        level = 0;
    end%if

    if isempty(column)

        column = 1;
    end%if

    switch(t)

        case 'head'

            level = level + 1;

            fprintf('\n');
            fprintf(repmat('#',[1,level]));
            fprintf(' ');
            fprintf(s);

            if 1 == level

                fprintf('\n');
                fprintf(repmat('=',[1,numel(s)+level+1]));
            end%if

            fprintf('\n\n');

        case {'input','output'}

            fprintf(repmat(' ',[1,level]));

            switch t

                case 'input',  fprintf('<');

                case 'output', fprintf('>');

            end%switch

            fprintf(' ')
            fprintf(s);
            fprintf(':');

            if mod(level+numel(s),2)

               fprintf(' ');
            end%if

            fprintf(repmat('_ ',[1,max(0,ceil((50-level-2-numel(s)-1)/2))]));
            fprintf(f,v);
            fprintf('\n');

        case 'done'

            fprintf('\b\b Done.\n\n');

        case 'next'

            if level > 1

                level = level - 1;    
            end%if

            logger('solver','reset');

        case 'solver'

            if 2 == nargin && strcmp('reset',s)

                column = 1;
            else

                if 1 == column

                    fprintf('\n');
                    fprintf(repmat(' ',[1,level]));
                end%if

                fprintf('=');

                if COL_MAX == column 

                   column = 1;
                else

                   column = column + 1;
                end%if
            end%if

        case 'line'

            if 1 == nargin

                fprintf('\n');
            else

                fprintf(repmat('\n',[1,s]));
            end%if

        case 'exit'

            level = 1;

            fprintf('\n');
            logger('output','Orderly exit','','%s');
            fprintf('\b');

    end%switch
end
