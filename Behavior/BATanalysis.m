%Code to import, save, calculate, and plot sucrose curves from Davis Rig
%apparatus 
%(MUST RUN THIS SECTION BEFORE ANY OF THE OTHER SECTIONS EVERY TIME)

MouseID = 'TDPQF_002';
age = '11wk';

rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR';
sep = '\';
BATtest = 'Sucrose'; %Name of BAT test (or unique folder identifier for test days)
OutputFileName = [MouseID '-' BATtest '-' age];

% Pre-sets for figures
fontname = 'Arial';
set(0,'DefaultAxesFontName',fontname,'DefaultTextFontName',fontname,'DefaultTextColor','k','defaultAxesFontSize',14);
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})

%% *****************************************************************
%  *****                       IMPORT DATA                     *****
%  *****************************************************************

%Identify subfolders containing data on test days. 
d = dir([rootdir sep MouseID sep age]);
isub = [d(:).isdir]; % returns logical vector
nameFolds = {d(isub).name}';
testFolds = nameFolds(contains(nameFolds, BATtest),1); 

%Import lick data from each folder
BATdataALL = cell(1,length(testFolds));
ILIdataALL = cell(1,length(testFolds));
for testnum = 1:length(testFolds)
    
    cd([rootdir sep MouseID sep age sep testFolds{testnum}]);
    
    [BATtable, ILIdata, nTrialTot] = importBATdata([MouseID '_' BATtest num2str(testnum)]);
    if size(ILIdata,1) ~= nTrialTot || size(BATtable,1) ~= nTrialTot %If not importing all trials, exit the loop and display error
        disp('Import error - not all trials imported, FIX before proceeding')
        break
    end
    ILIdata(isnan(ILIdata(:,2)),:) = []; %Remove trials with no data
    ILItable = array2table(ILIdata(:,1),'VariableNames',{'PRESENTATION'});
    latencies = num2cell(ILIdata(:,2:end),2);
    ILItable.Latencies = latencies;
        
    BATdataALL{testnum} = BATtable;
    ILIdataALL{testnum} = ILItable;
    
    
    save([MouseID '_' testFolds{testnum} '.mat'],'BATtable','ILItable'); %Save extracted data in .mat folder for each test session    
    fprintf('Saving... %s\n',[MouseID '_' testFolds{testnum}]);
    
end

cd([rootdir sep MouseID]);
save([OutputFileName '.mat'],'BATdataALL','ILIdataALL');
fprintf('Saving... %s\n', OutputFileName);

disp('*************************************');
disp(['Imported ' num2str(length(testFolds)) ' test(s) for ' MouseID]);
disp('*************************************');
%% ****************************************************************
%  *****              SUCROSE CURVES (INDIVIDUAL)             *****
%  ****************************************************************
% Calculate and plot sucrose curves for each animal

%Extract lick #'s for each concentration
cd([rootdir sep MouseID]);
load(OutputFileName)
nSessions = length(BATdataALL);

lickCountALL = [];
normLickALL = [];
figure;
for testnum = 1:nSessions 
    
    %%%%%%% I. Calculate and plot average licks per session %%%%%%%
    nTrials = size(ILIdataALL{testnum},1);
    
    % Extract concentration IDs for each trial
    allconcSTR = BATdataALL{testnum}.CONCENTRATION; %Extract list of concentrations for each trial
    allconc = cellfun(@(x) sscanf(x,'%f'),allconcSTR); %Convert concentration strings to numbers
    conc = unique(allconc); %Unique list of concentrations used
    
    % Extract lick count for each trial
    lickCount = BATdataALL{testnum}.LICKS;
    lickCount = [lickCount allconc];  
    
    % Remove trials with no licks
    lickCount(lickCount(:,1) == 0,:) = []; 
    
    % Calculate average # of licks per concentration
    meanLick = NaN(1,length(conc));
    stdevLick = NaN(1,length(conc));
    for numconc = 1:length(conc)
       meanLick(numconc) = mean(lickCount(lickCount(:,2) == conc(numconc),1)); 
       stdevLick(numconc) = std(lickCount(lickCount(:,2) == conc(numconc),1));
    end
    
    lickCountALL = [lickCountALL; lickCount]; % For combined curve (includes all sessions)
    normLick = meanLick./meanLick(1);% For combined - normalized curve 
    normLickALL = [normLickALL; normLick]; % (includes all sessions)
    
    %Plot each session
    subplot(2,nSessions + 1,testnum);
    plot(meanLick,'-ko','MarkerFaceColor','k')
    hold on; errorbar(meanLick,stdevLick,'LineStyle', 'none'); hold off;
    box off; axis tight; axis square
    set(gca,'TickDir','out','XTick',[1:length(conc)],'XTickLabels',num2str(conc),'XLim',[0.5, length(conc)+0.5])
    xlabel('Sucrose concentration (mM)'); ylabel('mean # of Licks'); title(['Session ' num2str(testnum)])
    
    %%%%%%% II. Calculate and plot lick rasters %%%%%%%
    
    % Convert lick ILI to absolute time relative to trial onset
    ILIdata = cell2mat(ILIdataALL{testnum}{1:nTrials,'Latencies'});
    firstLICK = BATdataALL{testnum}.Latency; % Onsets for first lick    
    firstLICKcut = firstLICK(1:nTrials);    
    
    lickTime = NaN(nTrials,size(ILIdata,2)+1);
    lickTime(:,1) = zeros(nTrials,1); %Time will be relative to first lick
    for n = 1:size(ILIdata,2)     
        lickTime(:,n+1) = ILIdata(:,n) + lickTime(:,n);
    end
    
    % Sort lick times based on concentration and trial # (sort function
    % will put earliest trials of each concentration first)
    [sortCONC,IDX] = sort(allconc(1:nTrials));
    sortLickTime = lickTime(IDX,:);
    
    % Plot individual lick rasters
    subplot(2,nSessions + 1,testnum + nSessions + 1); 
    colors = [0 0 0; 0.6 0.2 0.3; 0.37 0.6 0.2; 0.67 0.36 0.22; 0.46 0.15 0.42; 0.17 0.28 0.44];
    for t = 1:nTrials
        hold on;
        scatter(sortLickTime(t,:),repmat(t,1,size(sortLickTime,2)),10,colors(conc == sortCONC(t),:),'filled')        
    end
    set(gca,'TickDir','out','YTick',[(nTrials/length(conc))/2:nTrials/length(conc):100],'YTickLabels',num2str(conc))
    box off; axis tight
    xlabel('Time from first lick (ms)'); ylabel('Conc. by Trial # (mM)'); title('Lick Raster')
      
    
end

%%%%%%% III. Calculate and plot sucrose curves averaged across sessions %%%%%%%

meanLickALL = NaN(1,length(conc));
stdevLickALL = NaN(1,length(conc));
concALL = unique(lickCountALL(:,2));
for numconc = 1:length(concALL)
   meanLickALL(numconc) = mean(lickCountALL(lickCountALL(:,2) == concALL(numconc),1)); 
   stdevLickALL(numconc) = std(lickCountALL(lickCountALL(:,2) == concALL(numconc),1));
end
subplot(2,nSessions + 1, nSessions + 1);

plot(meanLickALL,'-ko','MarkerFaceColor','k')
hold on; errorbar(meanLickALL,stdevLickALL,'LineStyle', 'none'); hold off;
box off; axis tight; axis square
set(gca,'TickDir','out','XTick',[1:length(concALL)],'XTickLabels',num2str(concALL),'XLim',[0.5, length(concALL)+0.5])
xlabel('Sucrose concentration (mM)'); ylabel('mean # of Licks'); title('Combined')

subplot(2,nSessions + 1, 2*(nSessions + 1));

plot(mean(normLickALL,1),'-ko','MarkerFaceColor','k')
box off; axis tight; axis square
set(gca,'TickDir','out','XTick',[1:length(concALL)],'XTickLabels',num2str(concALL),'XLim',[0.5, length(concALL)+0.5])
xlabel('Sucrose concentration (mM)'); ylabel('normalized # of Licks'); title('Combined - normalized')


%%%%%%% IV. Save figure and data %%%%%%%
sgtitle(MouseID,'FontSize',20,'Color','red','Interpreter', 'none') 
ppsize = [1600 800];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);
print([OutputFileName '_SummaryFig'],'-dpdf','-r400'); fprintf('Printing... %s\n', [OutputFileName '_SummaryFig']);


save(OutputFileName,'meanLickALL','normLickALL','lickTime','concALL','-append'); fprintf('Appending... %s\n', OutputFileName);

%% ****************************************************************
%  *****              SUCROSE CURVES (POPULATION)             *****
%  ****************************************************************
% Calculate and plot average sucrose curve for all animals in cohort

CohortMUT = {'TDPQM_002', 'TDPQM_008'};
CohortCTRL = [];
CohortWT = {'TDPQF_001', 'TDPQF_002'};
plotpad = 20;

figure;
age = '12wk'
%%%%%%% I. Plot MUT cohort %%%%%%%
LickALLMICE = [];
nMice = length(CohortMUT);
for mnum = 1:nMice
    cd([rootdir sep CohortMUT{mnum}]);
    load([CohortMUT{mnum} '-' BATtest '-' age])
    normlick = meanLickALL./meanLickALL(1); % normalize average licks for each mouse
    LickALLMICE = [LickALLMICE; normlick];    
end
meanLickALLMICE = mean(LickALLMICE,1);
semLickALLMICE = std(LickALLMICE,1)./sqrt(nMice);

subplot(3,1,1); plot(concALL,meanLickALLMICE,'-ko','MarkerFaceColor','k')
hold on; errorbar(concALL,meanLickALLMICE,semLickALLMICE,'LineStyle', 'none'); hold off;

box off; axis tight;
set(gca,'TickDir','out','XTick',[concALL],'XTickLabels',num2str(concALL),'XLim',[concALL(1)-plotpad, concALL(end)+plotpad])
xlabel('Sucrose concentration (mM)'); ylabel('normalized # of Licks');
title(['MUTANT (N = ' num2str(length(CohortMUT)) ')'])

% % % %%%%%%% II. Plot CTRL cohort %%%%%%%
% % % 
% % % for mnum = 1:length(CohortCTRL)
% % %     cd([rootdir sep CohortCTRL(mnum)]);
% % %     load(OutputFileName)    
% % % end
% % % 
% % % title(['CONTROL (N = ' num2str(length(CohortCTRL)) ')'])

%%%%%%% III. Plot WT cohort %%%%%%%
age = '11wk'

LickALLMICE = [];
nMice = length(CohortWT);
for mnum = 1:nMice
    cd([rootdir sep CohortWT{mnum}]);
    load([CohortWT{mnum} '-' BATtest '-' age])
    normlick = meanLickALL./meanLickALL(1); % normalize average licks for each mouse
    LickALLMICE = [LickALLMICE; normlick];    
end
meanLickALLMICE = mean(LickALLMICE,1);
semLickALLMICE = std(LickALLMICE,1)./sqrt(nMice);

subplot(3,1,3); plot(concALL, meanLickALLMICE,'-ko','MarkerFaceColor','k')
hold on; errorbar(concALL, meanLickALLMICE,semLickALLMICE,'LineStyle', 'none'); hold off;

box off; axis tight; 
set(gca,'TickDir','out','XTick',concALL,'XTickLabels',num2str(concALL),'XLim',[concALL(1)-plotpad, concALL(end)+plotpad])
xlabel('Sucrose concentration (mM)'); ylabel('normalized # of Licks');
title(['WILDTYPE (N = ' num2str(length(CohortWT)) ')'])

sgtitle([BATtest ' - ' age],'FontSize',20, 'Color', 'red')

ppsize = [800 1000];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

%%% Sigmoid fits??? %%%