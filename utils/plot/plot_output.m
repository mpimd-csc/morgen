function plot_output(plot_path,name,solution,network,compact)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 0.9 (2020-01-24)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: 2-Clause BSD (opensource.org/licenses/BSD-2-clause)
%%% summary: plot mass flow at supply nodes and pressure at demand nodes.

    if compact

        figure('Name',name,'NumberTitle','off','DefaultAxesFontSize',8);
        b = 4;

        if not(exist('OCTAVE_VERSION','builtin'))
            sgtitle(name,'Interpreter','None');
        end%if
    else

        figure('Name',['[',name,'] Supply and Demand Node Pressure and Flow'],'NumberTitle','off','DefaultAxesFontSize',8);
        b = 0;
    end%if

    subplot(2,2+b,1);
    set(0,'DefaultAxesColorOrder',monomapper(1,network.nSupply));
    plot(solution.t,solution.u(1:network.nSupply,:),'linewidth',3);
    ylabel('Pressure @ Supply [bar]');
    xlim([0,solution.t(end)]);
    yl = ylim();
    ylim([floor(yl(1)),max(ceil(yl(2)),floor(yl(1))+2)]);

    subplot(2,2+b,2);
    set(0,'DefaultAxesColorOrder',monomapper(2/3,network.nDemand));
    plot(solution.t,solution.u(network.nSupply+1:end,:),'linewidth',3);
    ylabel('Mass Flow @ Demand [kg/s]');
    xlim([0,solution.t(end)]);
    yl = ylim();
    ylim([floor(yl(1)),max(ceil(yl(2)),floor(yl(1))+2)]);

    subplot(2,2+b,3+b);
    set(0,'DefaultAxesColorOrder',monomapper(2/3,network.nSupply));
    plot(solution.t,solution.y(1:network.nSupply,:),'linewidth',3);
    ylabel('Mass Flow @ Supply [kg/s]');
    xlim([0,solution.t(end)]); 
    yl = ylim();
    %ylim([floor(yl(1)),max(ceil(yl(2)),floor(yl(1))+2)]); % TODO activate once steady-state testing is done

    subplot(2,2+b,4+b);
    set(0,'DefaultAxesColorOrder',monomapper(1,network.nDemand));
    plot(solution.t,solution.y(network.nSupply+1:end,:),'linewidth',3);
    ylabel('Pressure @ Demand [bar]');
    xlim([0,solution.t(end)]);
    yl = ylim();
    %ylim([floor(yl(1)),max(ceil(yl(2)),floor(yl(1))+2)]); % TODO activate once steady-state testing is done

    print('-depsc','-painters',[plot_path,'/',name,'_output.eps']);
end

function cm = monomapper(hue,num)

    cm = hsv2rgb([hue*ones(num,1), ...
                  [linspace(0.5,1.0-(mod(num,2)==0)/num,ceil(num/2))';ones(floor(num/2),1)], ...
                  [ones(floor(num/2),1);linspace(1.0-(mod(num,2)==0)/num,0.5,ceil(num/2))']]);
end

