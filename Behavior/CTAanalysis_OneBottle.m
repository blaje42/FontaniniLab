%Code to import, save, calculate, and plot CTA data from Davis Rig
%apparatus 
%(MUST RUN THIS SECTION BEFORE ANY OF THE OTHER SECTIONS EVERY TIME)

MouseID = 'TDPQM_028';
age = '13wk';

rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR';
sep = '\';
CTAtest = 'Sucrose'; %Tastant used for CTA test
testfolderID = 'PreferenceTest';
nContextHab = 2; %Number of habituation trials
OutputFileName = [MouseID '-CTA-' CTAtest '-' age];

% Pre-sets for figures
fontname = 'Arial';
set(0,'DefaultAxesFontName',fontname,'DefaultTextFontName',fontname,'DefaultTextColor','k','defaultAxesFontSize',14);
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'})

%% *****************************************************************
%  *****                       IMPORT DATA                     *****
%  *****************************************************************

%%%%% Change import to reflect date -- change folder names to include date at beginning so order is by day %%%%%

%Identify subfolders containing data on test days. 
d = dir([rootdir sep MouseID sep age]);
d(1:2,:) = [];
d(1:nContextHab,:) = [];
isub = [d(:).isdir]; % returns logical vector
nameFolds = {d(isub).name}';
folderIDs = {CTAtest, testfolderID, 'Water'}; %Identifying string for test folder

for fold = 1:length(folderIDs)
    
    testFolds = nameFolds(contains(nameFolds, folderIDs{fold}),1); 

    %Import lick data from folder
    for u = 1:length(testFolds)
        cd([rootdir sep MouseID sep age sep testFolds{u}]);

        [CTAtable, ILIdata, nTrialTot] = importDAVISdata([MouseID '_' folderIDs{fold}]);
        if size(ILIdata,1) ~= nTrialTot || size(CTAtable,1) ~= nTrialTot %If not importing all trials display error
            error('Import error - not all trials imported, FIX before proceeding')
        end

        ILItableALL.(folderIDs{fold}){u} = ILIdata;
        CTAtableALL.(folderIDs{fold}){u} = CTAtable;
    end

end

clear CTAtable ILIdata
for fold = 1:length(nameFolds)
    cd([rootdir sep MouseID sep age sep nameFolds{fold}]);
    foldID = nameFolds{fold}(isstrprop(nameFolds{fold},'alpha'));
    [CTAtable{fold}, ILIdata{fold}, nTrialTot] = importDAVISdata([MouseID '_' foldID]); 
    CTAtable{fold}.SOLUTION = foldID;
    
end



    
cd([rootdir sep MouseID]);
save([OutputFileName '.mat'],'CTAtableALL','ILItableALL','CTAtable','ILIdata'); fprintf('Saving... %s\n', OutputFileName);

disp('*************************************');
disp(['Imported ' num2str(length(d)) ' test(s) for ' MouseID]);
disp('*************************************');

%% ****************************************************************
%  *****                PREFERENCE (INDIVIDUAL)               *****
%  ****************************************************************
% Calculate and plot 

%Extract lick counts for each concentration
cd([rootdir sep MouseID]);
load(OutputFileName)

fieldID = fieldnames(CTAtableALL);

for field = 1:length(fieldID)
    for u = 1:length(CTAtableALL.(fieldID{field}))

        lickCount.(fieldID{field})(u) = CTAtableALL.(fieldID{field}){u}.LICKS; %Extract lick counts

    end
end

save(OutputFileName,'lickCount','-append'); fprintf('Appending... %s\n', OutputFileName);

%%%%%%% I. Plot consumption over days %%%%%%%

figure; subplot(1,3,[1 2]); hold on;
for u = 1:length(CTAtable)
    if strcmp(CTAtable{u}.SOLUTION,CTAtest)
        bar(u,CTAtable{u}.LICKS,0.4,'FaceColor',[0.73 0.32 0.62],'EdgeColor','none')
    elseif strcmp(CTAtable{u}.SOLUTION,'Water')
        bar(u,CTAtable{u}.LICKS,0.4,'FaceColor',[0.05 0.45 0.73],'EdgeColor','none')
    else bar(u,CTAtable{u}.LICKS,0.4,'FaceColor', [0.85 0.33 0.15],'EdgeColor','none')
    end
    ID{u} = CTAtable{u}.SOLUTION;
end

set(gca,'TickDir','out','XTick',1:length(ID),'XTickLabel',ID)
ylabel('Licks');

%%%%%%% II. Plot consumption of conditioned tastant over days %%%%%%%

subplot(1,3,3)
bar(lickCount.(CTAtest),0.4,'FaceColor',[0.73 0.32 0.62],'EdgeColor','none');
hold on; bar(length(lickCount.(CTAtest))+1,lickCount.(testfolderID),0.4,'FaceColor',[0.85 0.33 0.15],'EdgeColor','none');
set(gca,'TickDir','out')
box off;
ylabel('Licks'); xlabel('Sucrose presentation')


%%%%%%% III. Plot consumption of conditioned tastant on test day vs. water %%%%%%%


sgtitle(MouseID,'FontSize',20,'Color','red','Interpreter', 'none')
ppsize = [1600 400];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);


print([OutputFileName '_CTASummary'],'-dpdf','-r400'); fprintf('Printing... %s\n', [OutputFileName '_CTASummary']);
