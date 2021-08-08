function plot_output(plot_path,name,solution,network,compact)
%%% project: morgen - Model Order Reduction for Gas and Energy Networks
%%% version: 1.1 (2021-08-08)
%%% authors: C. Himpe (0000-0003-2194-6754), S. Grundel (0000-0002-0209-6566)
%%% license: BSD-2-Clause License (opensource.org/licenses/BSD-2-clause)
%%% summary: Plot mass flow at supply nodes and pressure at demand nodes.

    if compact

        b = 4;

        figure('Name',name,'NumberTitle','off','DefaultAxesFontSize',8);

        if not(exist('OCTAVE_VERSION','builtin'))

            sgtitle(name,'Interpreter','None');
        end%if
    else
        b = 0;

        fig = figure('Name',['[',name,'] Supply and Demand Node Pressure and Flow'],'NumberTitle','off','DefaultAxesFontSize',13);
    end%if

    pr1 = (min(min(min(solution.u(1:network.nSupply,:))),min(min(solution.y(network.nSupply+1:end,:)))));

    pr2 = (max(max(max(solution.u(1:network.nSupply,:))),max(max(solution.y(network.nSupply+1:end,:)))));

    mf1 = (min(min(min(solution.u(network.nSupply+1:end,:))),min(min(solution.y(1:network.nSupply,:)))));

    mf2 = (max(max(max(solution.u(network.nSupply+1:end,:))),max(max(solution.y(1:network.nSupply,:)))));

    prd = max(0.1,0.25 * abs(pr2 - pr1));

    mfd = max(0.1,0.25 * abs(mf2 - mf1));

    subplot(2,2+b,1);
    set(0,'DefaultAxesColorOrder',monomapper(1,network.nSupply));
    plot(solution.t,solution.u(1:network.nSupply,:),'linewidth',3);
    xlim([0,solution.t(end)]);
    ylim([pr1 - prd,pr2 + prd]);
    xlabel('Supply');    
    ylabel('Pressure [bar]');
    set(gca,'XAxisLocation','top','xticklabel',[]);

    subplot(2,2+b,2);
    set(0,'DefaultAxesColorOrder',monomapper(2/3,network.nDemand));
    plot(solution.t,solution.u(network.nSupply+1:end,:),'linewidth',3);
    xlim([0,solution.t(end)]);
    ylim([mf1 - mfd,mf2 + mfd]);
    xlabel('Demand');  
    ylabel('Mass Flow [kg/s]');
    set(gca,'YAxisLocation','right','XAxisLocation','top','xticklabel',[]);

    subplot(2,2+b,3+b);
    set(0,'DefaultAxesColorOrder',monomapper(2/3,network.nSupply));
    plot(solution.t,solution.y(1:network.nSupply,:),'linewidth',3);
    xlim([0,solution.t(end)]); 
    ylim([mf1 - mfd,mf2 + mfd]);
    xlabel('Time [s]')
    ylabel('Mass Flow [kg/s]');

    subplot(2,2+b,4+b);
    set(0,'DefaultAxesColorOrder',monomapper(1,network.nDemand));
    plot(solution.t,solution.y(network.nSupply+1:end,:),'linewidth',3);
    xlim([0,solution.t(end)]);
    ylim([pr1 - prd,pr2 + prd]);
    xlabel('Time [s]')
    ylabel('Pressure [bar]');
    set(gca,'YAxisLocation','right');

    if not(compact)

        print(fig,'-depsc','-painters',[plot_path,filesep,name,'_output.eps']);
        drawnow;
    end%if
end

%% Local Function: monomapper
function cm = monomapper(hue,num)
% Summary: Depending on the number requested colors return a single color gradient 

    cm = hsv2rgb([hue*ones(num,1), ...
                  [linspace(0.5,1.0-(mod(num,2)==0)/num,ceil(num/2))';ones(floor(num/2),1)], ...
                  [ones(floor(num/2),1);linspace(1.0-(mod(num,2)==0)/num,0.5,ceil(num/2))']]);
end

