%% *****************************************************************
%  *****                       IMPORT DATA                     *****
%  *****************************************************************

rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR';
sep = '\';
MouseID = 'TDPQF_001';
BATtest = 'Sucrose'; %Name of BAT test (or unique folder identifier for test days)


%Identify subfolders containing data on test days. 
d = dir([rootdir sep MouseID]);
isub = [d(:).isdir]; % returns logical vector
nameFolds = {d(isub).name}';

testFolds = nameFolds(contains(nameFolds, BATtest),1); 

%Import lick data from each folder
nTrialTot = 75; %Total number of trials for BAT stimulus protocol
for testnum = 1:length(testFolds)
    
    cd([rootdir sep MouseID sep testFolds{testnum}]);
    [BATdata{testnum}, LICKdata{testnum}] = importBATdata(MouseID,nTrialTot);

end

disp('*******************************************************************');
disp(['Imported ' num2str(length(testFolds)) ' test(s) for ' MouseID]);
disp('*******************************************************************');
%% ****************************************************************
%  *****                     SUCROSE CURVES                   *****
%  ****************************************************************
%Extract lick #'s for each concentration
for testnum = 1
    
    allconc = BATdata{testnum}.CONCENTRATION;
    conc = unique(allconc); %Unique list of concentrations used
    
    lickCount = BATdata{testnum}.LICKS;
    
    %%% ID each trial based on concentration %%%
    
    %%% Remove trials with no licks %%%
    
end


%%% Convert lick times to relative to trial onset %%%

firstLICK = BATdata{1}.Latency; % Onsets for

%%% Make lick raster (for each trial, grouped by concentration???) %%%

