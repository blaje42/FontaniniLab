rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR\2AFC-MIXTURE';
sep = '\';
TaskID = 'Taste2AC_8V_Mixtures';
MICE = {'JMB010','JMB015','JMB016','JMB018', 'JMB017','JMB019','JMB020','JMB023','JMB024'};

COLORS = '#9BCE1E';
axisfontsize = 24;
labelfontsize = 28;

%% Example lick raster  
figure;
load([rootdir sep 'JMB016\JMB016-Session2-Taste2AC_8V_Mixtures-Data.mat']);
hold on;
for i = 1:length(LickData)
    
    cc = LickData(i).CentralLicks(1);

    plot([LickData(i).CentralLicks-cc; LickData(i).CentralLicks-cc],[i - 0.4; i + 0.4],'Color','k','LineWidth',1.25);
    
    if ~isempty(LickData(i).LeftLicks)
        plot([LickData(i).LeftLicks-cc; LickData(i).LeftLicks-cc],[i - 0.4; i + 0.4],'Color','#900C3F','LineWidth',1.25);
    end
    
    if ~isempty(LickData(i).RightLicks)
        plot([LickData(i).RightLicks-cc; LickData(i).RightLicks-cc],[i - 0.4; i + 0.4],'Color','#FFC300','LineWidth',1.25);
    end
       

end

set(gca,'TickDir','out','YLim',[0 i+1],'XLim',[-1 10],'fontsize',axisfontsize)
set(gcf,'renderer','painters')
xlabel('Time (s)','fontsize',labelfontsize)
ylabel('Trial','fontsize',labelfontsize)

ppsize = [1000 1000];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd('C:\Users\Jennifer\Dropbox\FontaniniLab\Manuscripts\Figures')
print('LickRaster','-r400','-dpdf');

%% Do the behavior psychometric w/ individual curves? I'm not sure...


[groupBehavior.data, groupBehavior.sigfit] = average2AFC(MICE);


%%% Change to make x's an output of sigfit %%%
figure; hold on;

scatter(groupBehavior.data(:,1),100*groupBehavior.data(:,2),40,'MarkerFaceColor','k','MarkerEdgeColor','k');
errorbar(groupBehavior.data(:,1),100*groupBehavior.data(:,2),100*groupBehavior.data(:,3),'LineStyle','none','Color','k');
pp = plot(0:100,100*groupBehavior.sigfit.yfit,'LineWidth',2,'Color',COLORS,'LineWidth',3);

figobj = pp(1);
labels = {['N = ' num2str(length(MICE)) ' mice']};

legend(figobj,labels,'Location','NorthWest')    
xlabel('Sucrose concentration (%)','Fontsize',labelfontsize); ylabel('Sucrose choice (%)','Fontsize',labelfontsize)
title('Mixture Psychometric','Fontsize',20)
set(gca,'TickDir','out','fontsize',axisfontsize,'ylim',[0 100],'xlim',[0 100],'fontname','Arial');

ppsize = [800 600];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);


cd(rootdir)
% % print(['Psychometric-C57-' date],'-r400','-djpeg');
print(['Psychometric-C57-' date],'-r400','-dpdf');

%% Plot sandwiched psychometric (average over % predominant tastant)

for i = 1:length(MICE)
    load([rootdir sep MICE{i} sep MICE{i} '-' TaskID '-average.mat'])
    salt = flipud(1-meanBehavior(1:4,2));
    sandwich = [salt meanBehavior(5:8,2)];
    alltogether(:,i) = mean(sandwich,2);
end

allsandwich(:,1) = [55 65 75 100];
allsandwich(:,2) = mean(alltogether,2);
allsandwich(:,3) = std(alltogether,[],2)./sqrt(length(MICE));

b = glmfit(allsandwich(:,1),allsandwich(:,2),'binomial');
yfit = glmval(b,50:100,'logit');

figure; hold on;
scatter(allsandwich(:,1),100*allsandwich(:,2),40,'MarkerFaceColor','k','MarkerEdgeColor','k');
errorbar(allsandwich(:,1),100*allsandwich(:,2),100*allsandwich(:,3),'LineStyle','none','Color','k');
plot(50:100,100*yfit,'LineWidth',2,'Color',COLORS,'LineWidth',3)
set(gca,'TickDir','out','fontsize',axisfontsize,'ylim',[0 100],'xlim',[50 100],'fontname','Arial');
xlabel('% predominent tastant','fontsize',labelfontsize); ylabel('% correct','fontsize',labelfontsize)



ppsize = [800 600];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd('C:\Users\Jennifer\Dropbox\FontaniniLab\Manuscripts\Figures')
print(['PsychometricSandwich-C57-' date],'-r400','-dpdf');

%% Figure to plot bar/scatter of slope/thresholds

for i = 1:length(MICE)
    
    load([rootdir sep MICE{i} sep MICE{i} '-' TaskID '-average.mat'])
    SLOPE(i) = sigfit.slope;
    X50(i) = sigfit.x50;
    
end
meanSLOPE = mean(SLOPE);
semSLOPE = std(SLOPE)/sqrt(length(SLOPE));

meanX50 = mean(X50);
semX50 = std(X50)/sqrt(length(X50));

%Plot bars and individual data points (with jitter?)
subplot(1,2,1);
bar(meanSLOPE,'EdgeColor','none','FaceColor',COLORS); hold on;
errorbar(meanSLOPE,semSLOPE,'linestyle','none','color','k');
scatter(ones(1,length(MICE)).*(1+(rand(1,length(MICE))-0.5)/10),SLOPE,50,'filled','k')
set(gca,'TickDir','out','fontsize',21,'fontname','Arial','XTickLabel',{''});
title('Slope','Fontsize',labelfontsize)
box off;

subplot(1,2,2)
bar(meanX50,'EdgeColor','none','FaceColor',COLORS); hold on;
errorbar(meanX50,semX50,'linestyle','none','color','k');
scatter(ones(1,length(MICE)).*(1+(rand(1,length(MICE))-0.5)/10),X50,50,'filled','k')
set(gca,'TickDir','out','fontsize',axisfontsize,'fontname','Arial','XTickLabel',{''});
title('Threshold','Fontsize',labelfontsize); ylabel('Sucrose Concentration (%)','Fontsize',labelfontsize)
box off;


ppsize = [800 600];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd(rootdir)
print(['Psychometric-stat-C57-' date],'-r400','-dpdf');


%% Figure to plot delay to lick for each mixture (for each mouse separate?)
%Do for correct trials only???
LickDelayValve = cell(1,8);
for m = 1:length(MICE)

    filenames = dir([rootdir sep MICE{m} sep MICE{m} '-Session*-' TaskID '-Data.mat']);
    
    for n = 1:size(filenames,1)
        load(filenames(n).name)
    
        trialcorrect = [LickData.reward];
        LickDataCorrect = LickData(trialcorrect);

        for i = 1:length(LickDataCorrect)
            firstlateral = min([LickDataCorrect(i).RightLicks LickDataCorrect(i).LeftLicks]);
            LickDelay(i) = firstlateral - LickDataCorrect(i).sampleLateralev(1); 

        end

        if summaryData.Tastants(1) == 100
            ValveOrder = 1:8;
        elseif summaryData.Tastants(1) == 0
            ValveOrder = 8:-1:1;
        end


        for v = ValveOrder
           seqidx = find([LickDataCorrect.ValveSequence] == v);
           LickDelayValve{v} = [LickDelayValve{v} LickDelay(seqidx)];  
        end

    end

end

meanDelay = cellfun(@mean,LickDelayValve);
stdDelay = cellfun(@std,LickDelayValve);


figure;
bar(meanDelay,'EdgeColor','none','FaceColor',COLORS); hold on;
errorbar(meanDelay,stdDelay,'linestyle','none','color','k');
set(gca,'TickDir','out','fontsize',axisfontsize,'fontname','Arial','XTickLabels',{'100','75','65','55','45','35','25','0'});
box off;
xlabel('Sucrose Concentration (%)','Fontsize',labelfontsize); ylabel('Delay to choice (s)','Fontsize',labelfontsize);

ppsize = [800 600];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd(rootdir)
print(['ChoiceDelay-C57-' date],'-r400','-dpdf');

%%

