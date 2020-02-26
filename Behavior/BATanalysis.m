%Code to import, save, calculate, and plot sucrose curves from Davis Rig
%apparatus 
%(MUST RUN THIS SECTION BEFORE ANY OF THE OTHER SECTIONS EVERY TIME)

%%%%%%%%%%%%%%%%
% TO DO
%%%%%%%%%%%%%%%%
%%% Add option to exclude any number of the tests 


%MouseID = 'TDPWM_016';
MouseIDS = loadsessionsBAT(cohorts{3},ages{2});
age = '20wk';

for mid = 1:length(MouseIDS)
    MouseID = MouseIDS{mid};

rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR';
sep = '\';
BATtest = 'Sucrose'; %Name of BAT test (or unique folder identifier for test days)
OutputFileName = [MouseID '-BAT-' BATtest '-' age];

% Pre-sets for figures
fontname = 'Arial';
set(0,'DefaultAxesFontName',fontname,'DefaultTextFontName',fontname,'DefaultTextColor','k','defaultAxesFontSize',14);
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})


ExcludeFirstTest = 0; %1 = true, 0 = false (excludes first test in combined average)

% % %% *****************************************************************
% % %  *****                       IMPORT DATA                     *****
% % %  *****************************************************************
% % 
% % %Identify subfolders containing data on test days. 
% % d = dir([rootdir sep MouseID sep age]);
% % isub = [d(:).isdir]; % returns logical vector
% % nameFolds = {d(isub).name}';
% % testFolds = nameFolds(contains(nameFolds, BATtest),1); 
% % 
% % 
% % BATdataALL = cell(1,length(testFolds));
% % ILIdataALL = cell(1,length(testFolds));
% % 
% % for testnum = 1:length(testFolds) %Separate analysis for each test day
% %     
% %     cd([rootdir sep MouseID sep age sep testFolds{testnum}]);
% %     
% %     %%% I. Import lick data from each folder %%%
% %     [BATtable, ILIdata, nTrialTot] = importDAVISdata([MouseID '_' BATtest num2str(testnum)]);
% %     if size(ILIdata,1) ~= nTrialTot || size(BATtable,1) ~= nTrialTot %If not importing all trials, exit the loop and display error
% %         error('Import error - not all trials imported, FIX before proceeding')
% %         break
% %     end
% %     
% %     %%% II. Remove trials with no data %%%
% %     ILIdata(BATtable.LICKS == 0,:) = []; %Remove trials with no data
% %     lasttrial = find(BATtable.Latency > 0, 1, 'last'); %Remove last trial because unlikely to be complete duration
% %     
% %        
% %     %Add presentation # to lick ILI data
% %     ILItable = array2table(ILIdata(:,1),'VariableNames',{'PRESENTATION'});
% %     latencies = num2cell(ILIdata(:,2:end),2);
% %     ILItable.Latencies = latencies;
% %              
% %     
% %     %Remove error trials (noticed for TURMERIC starting 10/22/19)
% %     errMIN = 250; %Minimum latency acceptable as not being an error
% %     errIDX = find(BATtable.Latency(1:lasttrial) < errMIN);
% %     if ~isempty(errIDX)
% %         BATtable(errIDX,:) = [];
% %         ILItable(errIDX,:) = [];
% %     end
% %     
% %     if BATtable.Retries(lasttrial + 1) > 0 %Last trial may have no licks but many retries. If this is the case, adjust last trial
% %         lasttrial = lasttrial + 1;
% %     end
% %     
% %     if size(ILItable,1) == lasttrial %Trial may have already been removed if there were no licks
% %         ILItable(lasttrial,:) = [];
% %     end
% %     
% %     
% %     save([MouseID '_' testFolds{testnum} '.mat'],'BATtable','ILItable'); fprintf('Saving... %s\n',[MouseID '_' testFolds{testnum}]); 
% %     
% %     %%% III. Combine data from each test in cell array %%%
% %     BATdataALL{testnum} = BATtable;
% %     ILIdataALL{testnum} = ILItable;
% %     
% % end
% % 
% % cd([rootdir sep MouseID]);
% % save([OutputFileName '.mat'],'BATdataALL','ILIdataALL'); fprintf('Saving... %s\n', OutputFileName);
% % 
% % disp('*************************************');
% % disp(['Imported ' num2str(length(testFolds)) ' test(s) for ' MouseID]);
% % disp('*************************************');



%% ****************************************************************
%  *****              SUCROSE CURVES (INDIVIDUAL)             *****
%  ****************************************************************
% Calculate and plot sucrose curves for each animal

%Extract lick #'s for each concentration
cd([rootdir sep MouseID]);
load(OutputFileName)
nSessions = length(BATdataALL);

% Plotting parameters

plotpad = 20;
if nSessions < 2
    nCol = 2;
else nCol = nSessions;
end


%lickCountALL = [];
lickCountALL = cell(1,nSessions);
normLickALL = [];
figure;
for testnum = 1:nSessions 
    
    %%%%%%% I. Calculate and plot average licks per session %%%%%%%
    nTrials = size(ILIdataALL{testnum},1);
    
    % Extract concentration IDs for each trial
    allconcSTR = BATdataALL{testnum}.CONCENTRATION; %Extract list of concentrations for each trial
    trialconc = cellfun(@(x) sscanf(x,'%f'),allconcSTR); %Convert concentration strings to numbers
    conc = unique(trialconc); %Unique list of concentrations used
    
    % Extract lick count for each trial
    lickCount = BATdataALL{testnum}.LICKS;
    lickCount = [lickCount trialconc];  
        
    % Remove trials with no licks 
    trialconcCUT = trialconc;
    
    trialconcCUT(lickCount(:,1) == 0) = [];
    lasttrial = find(BATdataALL{testnum}.Latency > 0, 1, 'last'); %Remove last trial because unlikely to be complete duration
    if size(trialconcCUT,1) == lasttrial %Trial may have already been removed if there were no licks
        trialconcCUT(lasttrial,:) = [];
    end
    
    
    lickCount(lickCount(:,1) == 0,:) = [];
    lasttrial = find(BATdataALL{testnum}.Latency > 0, 1, 'last'); %Remove last trial because unlikely to be complete duration
    if size(lickCount,1) == lasttrial %Trial may have already been removed if there were no licks
        lickCount(lasttrial,:) = [];
    end
    

    trialconcALL{testnum} = trialconcCUT;
    
    % Calculate average # of licks per concentration
    meanLick = NaN(1,length(conc));
    stdevLick = NaN(1,length(conc));
    for numconc = 1:length(conc)
       meanLick(numconc) = mean(lickCount(lickCount(:,2) == conc(numconc),1)); 
       stdevLick(numconc) = std(lickCount(lickCount(:,2) == conc(numconc),1));
    end
    
    %lickCountALL = [lickCountALL; lickCount]; % For combined curve (includes all sessions)
    lickCountALL{testnum} = lickCount;
    normLick = meanLick./meanLick(1);% For combined - normalized curve 
    normLickALL = [normLickALL; normLick]; % (includes all sessions)
    
    %Plot each session
    subplot(2,nCol,testnum);
    plot(conc,meanLick,'-ko','MarkerFaceColor','k')
    hold on; errorbar(conc,meanLick,stdevLick,'LineStyle', 'none'); hold off;
    box off; axis tight;
    set(gca,'TickDir','out','XTick',conc,'XTickLabels',num2str(conc),'XLim',[conc(1)-plotpad, conc(end)+plotpad], 'YLim',[0 125])
    xlabel('Sucrose concentration (mM)'); ylabel('mean # of Licks'); title(['Session ' num2str(testnum)])
          
    
end

save(OutputFileName,'lickCountALL','-append');

%%%%%%% II. Calculate and plot sucrose curves averaged across sessions %%%%%%%


if ExcludeFirstTest == 1
    lickCountALL{1} = [];
    normLickALL(1,:) = [];
end

lickCountCAT = vertcat(lickCountALL{:});

meanLickALL = NaN(1,length(conc));
stdevLickALL = NaN(1,length(conc));
concALL = unique(lickCountCAT(:,2));
for numconc = 1:length(concALL)
   meanLickALL(numconc) = mean(lickCountCAT(lickCountCAT(:,2) == concALL(numconc),1)); 
   stdevLickALL(numconc) = std(lickCountCAT(lickCountCAT(:,2) == concALL(numconc),1));
end
subplot(2,nCol, nCol + 1);

plot(concALL,meanLickALL,'-ko','MarkerFaceColor','k')
hold on; errorbar(concALL,meanLickALL,stdevLickALL,'LineStyle', 'none'); hold off;
box off; axis tight;
set(gca,'TickDir','out','XTick',concALL,'XTickLabels',num2str(concALL),'XLim',[concALL(1)-plotpad, concALL(end)+plotpad], 'YLim',[0 125])
xlabel('Sucrose concentration (mM)'); ylabel('mean # of Licks'); 
if ExcludeFirstTest == 1
    title('Combined, Sess 1 EXCL')
else title('Combined')
end


subplot(2,nCol, nCol + 2);

plot(concALL, nanmean(normLickALL,1),'-ko','MarkerFaceColor','k')
box off; axis tight;
set(gca,'TickDir','out','XTick',concALL,'XTickLabels',num2str(concALL),'XLim',[concALL(1)-plotpad, concALL(end)+plotpad])
xlabel('Sucrose concentration (mM)'); ylabel('normalized # of Licks'); 
if ExcludeFirstTest == 1
    title('Combined - normalized, Sess 1 EXCL')
else title('Combined - normalized')
end


%%%%%%% III. Save figure and data %%%%%%%
sgtitle(MouseID,'FontSize',20,'Color','red','Interpreter', 'none') 
ppsize = [1600 800];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);
print([OutputFileName '_CurveSummary'],'-dpdf','-r400'); fprintf('Printing... %s\n', [OutputFileName '_CurveSummary']);


save(OutputFileName,'meanLickALL','normLickALL','concALL','trialconcALL','ExcludeFirstTest','-append'); fprintf('Appending... %s\n', OutputFileName);

%% ****************************************************************
%  *****              LICK STRUCTURE (INDIVIDUAL)             *****
%  ****************************************************************

% % cd([rootdir sep MouseID]);
% % load(OutputFileName)
% % nSessions = length(BATdataALL);
% % 
% % %%%%%%% I. Calculate lick structure %%%%%%%
% % minboutsize = 3;
% % LickStruct = cell(1,nSessions);
% % for testnum = 1:nSessions
% %     ILIdata = cell2mat(ILIdataALL{testnum}.Latencies);
% %     LickStruct{testnum} = calcLickStructure(ILIdata, minboutsize); 
% % end
% % 
% % save(OutputFileName,'LickStruct','-append'); fprintf('Appending... %s\n', OutputFileName);
% % 
% % %%%%%%% II. Plot lick structure %%%%%%%
% % figure;
% % 
% % ppsize = [1600 800];
% % plotLickStructure(LickStruct,trialconcALL,MouseID,ppsize)
% % print([OutputFileName '_LickSummary'],'-dpdf','-r400'); fprintf('Printing... %s\n', [OutputFileName '_LickSummary']);

end

