function plot_online(plot_path,name,orders,data,labels,compact)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause License (opensource.org/licenses/BSD-2-clause)
%%% summary: Plot comparable data as lines.

    ndata = numel(data);
    colors = lines13(ndata);

    if compact

        subplot(2,6,[9,10]);
        title('Relative Online Time');
    else

        fig = figure('Name',['[',name,'] Online Time'],'NumberTitle','off');
    end%if

    semilogy(orders(:),data{1}(:),'Color',colors(1,:),'LineWidth',4);
    hold on;

    for k = 2:ndata

        semilogy(orders(:),data{k}(:),'Color',colors(k,:),'LineWidth',4);
    end%for

    semilogy(orders(:),ones(1,numel(orders(:))),'k','LineWidth',2);
    yl = ylim();
    ylim(real([min(yl(1),0.1),max(yl(2),10)]));

    hold off;
    xlim([min(orders),max(orders)]);
    yl = ylim();
    ylim(real([10.^floor(log10(yl(1))), max(1,10.^ceil(log10(yl(2))))]));
    xlabel('Reduced Dimension');
    ylabel('Relative Online Time');

    if not(compact)

        legend([labels;''],'location','SouthOutside');
        print(fig,'-depsc',[plot_path,filesep,name,'_online.eps']);
    end%if
end
