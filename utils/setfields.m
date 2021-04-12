function t = setfields(s,varargin)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.99 (2021-04-12)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Set multiple structure fields at once.

    t = s;

    for k = 1:2:(nargin - 1)

        t.(varargin{k}) = varargin{k+1};
    end%for
end
