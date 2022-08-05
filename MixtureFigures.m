COLORS = '#9BCE1E';
axisfontsize = 24;
labelfontsize = 28;


%%

cd('Z:\Fontanini\Jennifer\Liam')
filenames = dir('*.mat');

nFiles = length(filenames);

for i = 1:nFiles
    load(filenames(i).name)
    allsingledata{i} = singleClusterData;
    allparams{i} = params;
end

for i = 1:nFiles
    nTaste(i) = sum([allsingledata{i}.TasteResponsive]);
    nDelay(i) = sum([allsingledata{i}.DelayResponsive]);
    nChoice(i) = sum([allsingledata{i}.ChoiceResponsive]);
    nTotal(i) = length(allsingledata{i}); %Total number of units
    nExcited(i) = length(find([allsingledata{i}.DirectionResponsive] == 1));
    nInhibited(i) = length(find([allsingledata{i}.DirectionResponsive] == -1));
    
    
end

test(1) = 100*sum(nTaste)/sum(nTotal);
test(2) = 100*sum(nDelay)/sum(nTotal);
test(3) = 100*sum(nChoice)/sum(nTotal);

figure;
bar(test,0.5,'EdgeColor','none','FaceColor',COLORS)
box off; 
ylabel('Percent of neurons','fontsize',labelfontsize);
title('Responsive neurons','fontsize',labelfontsize);
set(gca,'TickDir','out','fontsize',axisfontsize,'ylim',[0 100],'XTickLabel',{'Taste','Delay','Choice'},'fontname','Arial');

ppsize = [800 600];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd('C:\Users\Jennifer\Dropbox\FontaniniLab\Manuscripts\Figures')
print(['ResponsiveNeurons-' date],'-r400','-dpdf');

pietime(1) = sum(nExcited)/sum(nTaste); pietime(2) = sum(nInhibited)/sum(nTaste);
pie(pietime,{'Excited','Inhibited'});
cd('C:\Users\Jennifer\Dropbox\FontaniniLab\Manuscripts\Figures')
print(['PieNeurons-' date],'-r400','-dpdf');

%%
t = params.central.timeWin(1):params.central.binsize:params.central.timeWin(2);
t = t(1:end-1);

imagesc(t,1:size(singleFRz,1),singleFRz);
colorbar;
set(gca,'TickDir','out','XTick',[-4:1:15],'YDir','normal')
box off;
xlabel('Time (s)','fontsize',24); ylabel('Neuron','fontsize',24)
set(gcf,'renderer','painters')

ppsize = [1600 700];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd('C:\Users\Jennifer\Dropbox\FontaniniLab\Manuscripts\Figures')
print('PopulationHeatMap','-r400','-dpdf');

%%

unitIDs = [16];
cd('C:\Users\Jennifer\Dropbox\FontaniniLab\Conferences')

for k = 1:length(unitIDs)
    figure;
    i = unitIDs(k);

plotMixtureRasterFR(singleClusterData(i).SpikesxValve,singleClusterData(i).FRxValve,params);

ppsize = [2000 1000];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);
set(gcf,'renderer','painters')

print(['SpikeRaster-Cell' num2str(i)],'-r400','-dpdf');

end






