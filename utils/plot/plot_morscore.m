function plot_morscore(plot_path,name,data,labels,compact)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Plot offline time as horizontal bars.

    ndata = numel(labels);

    if compact

        subplot(2,6,4);
    else

        fig = figure('Name',['[',name,'] MORscore'],'NumberTitle','off');
    end%if

    h = barh(cell2mat(data));
    set(h,'FaceColor','flat');

    if exist('OCTAVE_VERSION','builtin')

        set(get(h,'Children'),'CData',lines13(ndata));
    else

        set(h,'CData',lines13(ndata));
    end%if

    set(gca,'YDir','reverse');
    xlim([0,1]);
    xlabel('MORscore');

    if compact

        set(gca,'YTickLabel','');
    else

        set(gca,'YTickLabel',labels);
        print(fig,'-depsc',[plot_path,filesep,name,'_morscore.eps']);
    end%if
end
