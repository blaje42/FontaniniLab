%Code to import, save, calculate, and plot CTA data from Davis Rig
%apparatus 
%(MUST RUN THIS SECTION BEFORE ANY OF THE OTHER SECTIONS EVERY TIME)

MouseID = 'TDPWM_015';
age = '12wk';

rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR';
sep = '\';
CTAtest = 'Sucrose'; %Tastant used for CTA test
OutputFileName = [MouseID '-CTA-' CTAtest '-' age];

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
testfolderID = 'PreferenceTest'; %Identifying string for test folder
testFolds = nameFolds(contains(nameFolds, testfolderID),1); 

%Import lick data from folder
    
cd([rootdir sep MouseID sep age sep testFolds{1}]);

[CTAtable, ILIdata, nTrialTot] = importDAVISdata([MouseID '_' testfolderID '_' CTAtest]);
if size(ILIdata,1) ~= nTrialTot || size(CTAtable,1) ~= nTrialTot %If not importing all trials display error
    error('Import error - not all trials imported, FIX before proceeding')
end

ILIdata(CTAtable.LICKS == 0,:) = []; %Remove trials with no data
ILItable = array2table(ILIdata(:,1),'VariableNames',{'PRESENTATION'});
latencies = num2cell(ILIdata(:,2:end),2);


ILItable.Latencies = latencies;

lasttrial = find(CTAtable.Latency > 0, 1, 'last'); %Remove last trial because unlikely to be complete duration
if size(ILItable,1) == lasttrial %Trial may have already been removed if there were no licks
    ILItable(lasttrial,:) = [];
end

    
cd([rootdir sep MouseID]);
save([OutputFileName '.mat'],'CTAtable','ILItable'); fprintf('Saving... %s\n', OutputFileName);

disp('*************************************');
disp(['Imported ' num2str(length(testFolds)) ' test(s) for ' MouseID]);
disp('*************************************');

%% ****************************************************************
%  *****                PREFERENCE (INDIVIDUAL)               *****
%  ****************************************************************
% Calculate and plot 

%Extract lick counts for each concentration
cd([rootdir sep MouseID]);
load(OutputFileName)

allconcSTR = CTAtable.CONCENTRATION; %Extract list of concentrations for each trial
trialconc = cellfun(@(x) sscanf(x,'%f'),allconcSTR); %Convert concentration strings to numbers
conc = unique(trialconc); %Unique list of concentrations used


lickCount = CTAtable.LICKS; %Extract lick counts
lickCount = [lickCount trialconc]; %Concatenate counts with concentration for each trial

% Remove trials with no licks
lickCount(lickCount(:,1) == 0,:) = [];
lasttrial = find(CTAtable.Latency > 0, 1, 'last'); %Remove last trial because unlikely to be complete duration
if size(lickCount,1) == lasttrial %Trial may have already been removed if there were no licks
    lickCount(lasttrial,:) = [];
end

meanLick = NaN(1,length(conc));
stdevLick = NaN(1,length(conc));
trialIDs = cell(1,length(conc));
for numconc = 1:length(conc)
    trialIDs{numconc} = find(lickCount(:,2) == conc(numconc));
    meanLick(numconc) = mean(lickCount(trialIDs{numconc},1)); 
    stdevLick(numconc) = std(lickCount(trialIDs{numconc},1));
end

save(OutputFileName,'lickCount','-append'); fprintf('Appending... %s\n', OutputFileName);

figure; 
bar(meanLick,0.4,'EdgeColor','none');
set(gca,'TickDir','out','XTickLabels',num2str(conc),'XLim',[0.5, 2.5])
hold on; errorbar(meanLick,stdevLick,'LineStyle', 'none');
scatter(1.1*ones(length(trialIDs{1}),1),lickCount(trialIDs{1},1),50,'filled');
scatter(2.1*ones(length(trialIDs{2}),1),lickCount(trialIDs{2},1),50,'filled');
box off;
ylabel('Licks'); xlabel('Sucrose concentration (mM)')
title(MouseID,'FontSize',20,'Color','red','Interpreter', 'none')

print([OutputFileName '_CTASummary'],'-dpdf','-r400'); fprintf('Printing... %s\n', [OutputFileName '_CurveSummary']);
