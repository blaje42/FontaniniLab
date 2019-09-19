%Code to import, save, calculate, and plot sucrose curves from Davis Rig
%apparatus

MouseID = 'TDPQM_002';
rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR';
sep = '\';
BATtest = 'Sucrose'; %Name of BAT test (or unique folder identifier for test days)
OutputFileName = [MouseID '-' BATtest];

% Pre-sets for figures
fontname = 'Arial';
set(0,'DefaultAxesFontName',fontname,'DefaultTextFontName',fontname,'DefaultTextColor','k','defaultAxesFontSize',14);
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})

%% *****************************************************************
%  *****                       IMPORT DATA                     *****
%  *****************************************************************

%Identify subfolders containing data on test days. 
d = dir([rootdir sep MouseID]);
isub = [d(:).isdir]; % returns logical vector
nameFolds = {d(isub).name}';
testFolds = nameFolds(contains(nameFolds, BATtest),1); 

%Import lick data from each folder
BATdataALL = cell(1,length(testFolds));
ILIdataALL = cell(1,length(testFolds));
for testnum = 1:length(testFolds)
    
    cd([rootdir sep MouseID sep testFolds{testnum}]);
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

%meanLickALL = cell(1,nSessions);
lickCountALL = [];
normlickALL = [];
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
    

    lickCountALL = [lickCountALL; lickCount]; % For combined curve
    normlick = meanLick./meanLick(1);% For combined - normalized curve
    normlickALL = [normlickALL; normlick];
    
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
    %lickTime(:,1) = firstLICKcut; %Include first lick latency (time will be relative to trial start)
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

%%% Average curves across sessions (Do I want to normalize and then average for each session?) %%%
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

plot(mean(normlickALL),'-ko','MarkerFaceColor','k')
box off; axis tight; axis square
set(gca,'TickDir','out','XTick',[1:length(concALL)],'XTickLabels',num2str(concALL),'XLim',[0.5, length(concALL)+0.5])
xlabel('Sucrose concentration (mM)'); ylabel('normalized # of Licks'); title('Combined - normalized')


%%% Sigmoid fits??? %%%


%%% Save figure and data %%%
sgtitle(MouseID,'FontSize',20,'Color','red','Interpreter', 'none')   
set(gcf,'Position',[0 0 1600 800]);

%% ****************************************************************
%  *****              SUCROSE CURVES (POPULATION)             *****
%  ****************************************************************
% Calculate and plot average sucrose curve for all animals in cohort

CohortMUT = ['TDPQM_002', 'TDPQM_008'];
CohortCTRL = [];
CohortWT = ['TDPQF_001', 'TDPQF_002'];

%%% Normalize water licks to 0 %%%