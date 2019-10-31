%Code to import, save, calculate, and plot CTA data from Davis Rig
%apparatus 
%(MUST RUN THIS SECTION BEFORE ANY OF THE OTHER SECTIONS EVERY TIME)

MouseID = 'TDPWM_006';
age = '12wk';

rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR';
sep = '\';
CTAtest = 'Sucrose'; %Tastant used for CTA test
testfolderID = 'PreferenceTest';
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

        ILIdataALL.(folderIDs{fold}){u} = ILIdata;
        CTAtableALL.(folderIDs{fold}){u} = CTAtable;
    end

end

    
cd([rootdir sep MouseID]);
save([OutputFileName '.mat'],'CTAtableALL','ILItableALL'); fprintf('Saving... %s\n', OutputFileName);

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

fieldID = fieldnames(CTAtableALL);

for field = 1:length(fieldID)
    for u = 1:length(CTAtableALL.(fieldID{field}))

        lickCount.(fieldID{field})(u) = CTAtableALL.(fieldID{field}){u}.LICKS; %Extract lick counts

    end
end

save(OutputFileName,'lickCount','-append'); fprintf('Appending... %s\n', OutputFileName);

%%%%%%% I. Plot consumption of conditioned tastant over days %%%%%%%

figure; subplot(1,2,1)
bar(lickCount.(CTAtest),0.4,'EdgeColor','none');
hold on; bar(length(lickCount.(CTAtest))+1,lickCount.(testfolderID),0.4,'EdgeColor','none');
set(gca,'TickDir','out')
box off;
ylabel('Licks'); xlabel('Sucrose presentation')


%%%%%%% II. Plot consumption of conditioned tastant on test day vs. water %%%%%%%

subplot(1,2,2)
bar([lickCount.Water lickCount.(testfolderID)],0.4,'EdgeColor','none');
set(gca,'TickDir','out','XTickLabels',{'Water', CTAtest})
box off;
ylabel('Licks'); xlabel('Tastant')


sgtitle(MouseID,'FontSize',20,'Color','red','Interpreter', 'none')
ppsize = [1200 400];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);


print([OutputFileName '_CTASummary'],'-dpdf','-r400'); fprintf('Printing... %s\n', [OutputFileName '_CTASummary']);
