function plot_error(plot_path,name,id,orders,data,labels,scores,compact,yscale)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.2 (2022-10-07)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause (opensource.org/licenses/BSD-2-clause)
%%% summary: plot comparable data as lines.

    ndata = numel(data);
    colors = lines13(ndata);

    if compact

        subplot(2,6,[5,6,11,12]);
    else

        fig = figure('Name',[id,' [',name,'] Relative ',id,' Output Model Reduction Error'],'NumberTitle','off');
        pbaspect([3,2,1]);
    end%if

    semilogy(orders(:),data{1}(:),'Color',colors(1,:),'LineWidth',4);
    hold on;

    for k = 2:ndata

        semilogy(orders(:),data{k}(:),'Color',colors(k,:),'LineWidth',4);
    end%for

    hold off;
    xlim([min(orders),max(orders)]);
    ylim(real([10^yscale,1]));

    xlabel('Reduced Dimension');
    ylabel(['Relative ',id,'-Error']);

    slabels = {};
    for k=1:numel(labels)

       slabels{k} = [labels{k},' (μ=',sprintf('%1.2f',scores{k}),')'];
    end%for

    if compact

        legend(slabels,'location','SouthOutside');
    else

        set([gca; findall(gca,'Type','text')],'FontSize',16);

        print(fig,'-depsc',[plot_path,filesep,name,'_',id,'error.eps']);

        if not(exist('OCTAVE_VERSION','builtin'))

            legend_print(gca,slabels,[plot_path,filesep,name]);
        end%if
    end%if
end

