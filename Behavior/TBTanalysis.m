%Two-bottle preference test analysis
clear; close all;
MouseID = 'TDPQM_057';
age = '20wk';

rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR\TWO-BOTTLE\';
sep = '\';
TBTtest = 'Sucrose'; %Tastant used for two-bottle preference test
nTrials = 7; %Number of total days
nContextHab = 2; %Number of habituation trials
OutputFileName = [MouseID '-TBT-' TBTtest '-' age];

% Pre-sets for figures
fontname = 'Arial';
set(0,'DefaultAxesFontName',fontname,'DefaultTextFontName',fontname,'DefaultTextColor','k','defaultAxesFontSize',18);
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'},'defaultAxesTickDir','out','defaultAxesTickDirMode','manual')


%% *****************************************************************
%  *****               IMPORT AND EXTRACT DATA                 *****
%  *****************************************************************
cd([rootdir sep MouseID sep]);

[STIMdata, TBTdata] = importTBTdata([MouseID '_' age],nTrials,nContextHab);
STIMdata.Properties.RowNames = STIMdata.Var1;
STIMdata = removevars(STIMdata,{'Var1'});

%Calculate absolute change in consumption
ConsumptionData = [TBTdata.Solution1_CHANGE TBTdata.Solution2_CHANGE]; %Extract weight consumed for both solutions
ConsumptionData(:,3) = ConsumptionData(:,1) + ConsumptionData(:,2); %Total consumed

%Calculate tastant preference
solutionID = 2;
PercentPreference = 100*(ConsumptionData(:,solutionID)./ConsumptionData(:,3)); %Preference for solution #: solutionID

save([OutputFileName '.mat'],'STIMdata','TBTdata','ConsumptionData'); fprintf('Saving... %s\n', OutputFileName);

%% Add individual data to population data table
TBTstruct.mouseID = MouseID;
TBTstruct.sex = MouseID(5);
[~, TBTstruct.genotype] = xlsread([MouseID '_' age '.xlsx'],'D1:D1');
TBTstruct.age = {age};
[~,TBTstruct.solution1] = xlsread([MouseID '_' age '.xlsx'],'B6:B6');
[~, TBTstruct.solution1_concentration] = xlsread([MouseID '_' age '.xlsx'],'C6:C6');
TBTstruct.solution1_consumption = {TBTdata.Solution1_CHANGE};
[~,TBTstruct.solution2] = xlsread([MouseID '_' age '.xlsx'],'B7:B7');
[~,TBTstruct.solution2_concentration] = xlsread([MouseID '_' age '.xlsx'],'C7:C7');
TBTstruct.solution2_consumption = {TBTdata.Solution2_CHANGE};

TBTtable = struct2table(TBTstruct);

load('C:\Users\Jennifer\Documents\DATA\BEHAVIOR\TWO-BOTTLE\TBT_Summary_Data.mat');

TBTtableALL = [TBTtableALL; TBTtable];

cd(rootdir)
save('TBT_Summary_Data.mat','TBTtableALL');
save(['TBT_Summary_Data-' date '.mat'],'TBTtableALL');
%% *****************************************************************
%  *****                      PLOT DATA                        *****
%  *****************************************************************

colors = {[0, 0.447, 0.741], [0.75, 0.3, 0.6], [0.25 0.25 0.25]};

figure;
subplot(2,3,[1 2]); b = bar(ConsumptionData,'EdgeColor','none','FaceColor','flat');
b(1).FaceColor = colors{1}; b(2).FaceColor = colors{2}; b(3).FaceColor = colors{3};
legend([STIMdata.ID ; 'Total'],'location','northwest')
set(gca,'ylim',[0 4]); box off;
ylabel('Amount Consumed (g)'); xlabel('Test Day'); title('Raw Consumption')

subplot(2,3,3); b = bar(nanmean(ConsumptionData(1:end,:)),'EdgeColor','none','BarWidth',0.5,'FaceColor','flat');
hold on; errorbar(nanmean(ConsumptionData(1:end,:)),nanstd(ConsumptionData(1:end,:)),'k','LineStyle','none');
set(gca,'ylim',[0 4],'XTickLabel',[STIMdata.ID ; 'Total']); box off;
xtickangle(45)
b.CData(1,:) = colors{1}; b.CData(2,:) = colors{2}; b.CData(3,:) = colors{3};
title('Mean')

subplot(2,3,[4 5]); bar(PercentPreference,'EdgeColor','none','BarWidth',0.25,'FaceColor',colors{solutionID});
set(gca,'ylim',[0 100]); box off;
ylabel([STIMdata.ID(solutionID) ' Preference (%)']); xlabel('Test Day'); title([STIMdata.ID{solutionID} ' Preference'])

subplot(2,3,6); bar(nanmean(PercentPreference(2:end)),'EdgeColor','none','BarWidth',0.25,'FaceColor',colors{solutionID})
hold on; errorbar(nanmean(PercentPreference(2:end)),nanstd(PercentPreference(2:end)),'k','LineStyle','none');
set(gca,'ylim',[0 100],'XTick',[]); box off;
title(['Mean: ' num2str(nanmean(PercentPreference(2:end))) '%'])

sgtitle(MouseID,'FontSize',20,'Color','red','Interpreter', 'none')

ppsize = [1200 1000];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd([rootdir sep MouseID sep]);
print([OutputFileName '_TBTsummary'],'-dpdf','-r400'); fprintf('Printing... %s\n', [OutputFileName '_TBTsummary']);

