function plot_breven(plot_path,name,orders,data,labels,compact)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: plot comparable data as lines.

    ndata = numel(data);
    colors = lines13(ndata);

    if compact

        subplot(2,6,[9,10]);
        title('Breakeven');
    else

        fig = figure('Name',['[',name,'] Breakeven'],'NumberTitle','off');
    end%if

    semilogy(orders(:),data{1}(:),'Color',colors(1,:),'LineWidth',4);
    hold on;

    for k = 2:ndata

        semilogy(orders(:),data{k}(:),'Color',colors(k,:),'LineWidth',4);
    end%for

    yl = ylim();
    ylim([min(yl(1),1.0),max(yl(2),10)]);

    hold off;
    xlim([min(orders),max(orders)]);
    yl = ylim();
    ylim([10.^floor(log10(yl(1))), max(1,10.^ceil(log10(yl(2))))]);
    xlabel('Reduced Dimension');
    ylabel('Breakeven');

    if not(compact)

        legend([labels;''],'location','SouthOutside');
        print(fig,'-depsc',[plot_path,filesep,name,'_breven.eps']);
    end%if
end
