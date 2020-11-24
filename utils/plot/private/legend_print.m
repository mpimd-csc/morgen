function legend_print(fig,lab,name)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: plot only legend of current figure

    leg = legend(lab);

    fig = copyobj(gcf,0);
    ws = warning('off','all');
    lineh = findall(fig,'type','line');
    for i = 1:length(lineh)

        lineh(i).XData = NaN;
    end%for
    axis off

    leg.Units = 'pixels';
    boxLineWidth = leg.LineWidth;

    leg.Position = [6 * boxLineWidth, 6 * boxLineWidth, leg.Position(3), leg.Position(4)];
    legLoc = leg.Position;

    fig.Units = 'pixels';
    fig.InnerPosition = [1, 1, legLoc(3) + 48 * boxLineWidth, legLoc(4) + 48 * boxLineWidth];

    saveas(fig,[name,'_legend.eps'],'epsc');
    close(fig);
    warning(ws);
end
