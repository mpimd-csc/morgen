function plot_error(plot_path,name,id,orders,data,labels,scores,compact,yscale)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-11-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: plot comparable data as lines.

    ndata = numel(data);
    colors = lines12(ndata);

    if compact

        subplot(2,6,[5,6,11,12]);
    else

        f = figure('Name',[id,' [',name,'] Relative ',id,' Output Model Reduction Error'],'NumberTitle','off');
        pbaspect([3,2,1]);
    end%if

    semilogy(orders(:),data{1}(:),'Color',colors(1,:),'LineWidth',4);
    hold on;

    for k = 2:ndata

        semilogy(orders(:),data{k}(:),'Color',colors(k,:),'LineWidth',4);
    end%for

    ylabel(['Relative ',id,' Output Error']);

    hold off;
    xlim([min(orders),max(orders)]);
    ylim([10^yscale,1]);
    xlabel('Reduced Dimension');
    set([gca; findall(gca,'Type','text')],'FontSize',16);

    if compact

        scorelabels = cellfun(@(l,s) [l,' \mu=',sprintf('%.2f',s)],labels,scores,'UniformOutput',false);
        legend(scorelabels,'location','SouthOutside');
    else

        print('-depsc',[plot_path,'/',name,'_',id,'error.eps']);

        if not(exist('OCTAVE_VERSION','builtin'))

            pause(2);
            legend_print(f,labels,[plot_path,'/',name]);
        end%if
    end%if
end

