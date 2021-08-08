function plot_offline(plot_path,name,data,labels,compact)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: Plot offline time as horizontal bars.

    ndata = numel(labels);

    if compact

        subplot(2,6,[3,4]);
    else

        fig = figure('Name',['[',name,'] Offline Time'],'NumberTitle','off');
    end%if

    h = barh(cell2mat(data));
    set(h,'FaceColor','flat');

    if exist('OCTAVE_VERSION','builtin')

        set(get(h,'Children'),'CData',lines13(ndata));
    else

        set(h,'CData',lines13(ndata));
    end%if

    set(gca,'YDir','reverse');
    xlabel('Time [s]');

    if compact

        ylabel('Offline Time');
        set(gca,'YTickLabel','');
    else

        set(gca,'YTickLabel',labels);
        print(fig,'-depsc',[plot_path,filesep,name,'_offline.eps']);
    end%if
end
