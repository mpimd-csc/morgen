function legend_print(fig,lab,name)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Plot only legend of current figure.

    f = figure();
    h = copyobj(fig,f);
    leg = legend(lab);
    ws = warning('off','all');
    lineh = findall(h,'type','line');

    for i = 1:length(lineh)

        lineh(i).XData = NaN;
    end%for

    axis off

    leg.Units = 'pixels';
    boxLineWidth = leg.LineWidth;

    leg.Position = [6 * boxLineWidth, 6 * boxLineWidth, leg.Position(3), leg.Position(4)];
    legLoc = leg.Position;

    h.Units = 'pixels';
    h.InnerPosition = [1, 1, legLoc(3) + 48 * boxLineWidth, legLoc(4) + 48 * boxLineWidth];

    saveas(f,[name,'_legend.eps'],'epsc');
    close(f);
    warning(ws);
end
