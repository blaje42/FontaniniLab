%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load cluster and behavior data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rootdir = 'C:\Users\Jennifer\Documents\DATA\Spikes';
sep = '\';
MouseID = 'JMB010';
SessionID = 'Session1';

cd([rootdir sep MouseID sep])


load([MouseID '-' SessionID '-LickData']);
load([MouseID '-' SessionID '-ClusterData']);

%%%%%%% Analysis parameters %%%%%%%%
params.Tastants = [100 75 65 55 45 35 25 0]; % Percent sucrose concentration valves 1 --> 8
params.GCrange = [0 1000]; %Range (in um) for GC cutoff
params.BlockStartTrialsRemoved = 0; 
params.NoResponseTrialsRemoved = 0; %Indicates trials with no response have not been removed
params.lowFRremoved = 0;

baseT = -4;
endT = 15;
params.central.timeWin = [baseT endT];
params.lateral.timeWin = params.central.timeWin - 5;
params.central.binsize = 0.1; %binsize in seconds
params.lateral.binsize = params.central.binsize;

params.central.baseTimeWin = [-3.5 -2.5]; 
params.central.stimTimeWin = [0 1];

params.lateral.baseTimeWin = [-7.5 -6.5];
params.lateral.delayTimeWin = [-1.2 -0.2];
params.lateral.choiceTimeWin = [0 1];

params.FRcutoff = 1; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



save([MouseID '-' SessionID '-ClusterData'],'params','-append');

fprintf(['Loaded Lick Data and Cluster Data for ' MouseID ' ' SessionID '\n']);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Structs for single and multi-units in GC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Filter table by depth
depthcut = filtertable(ClusterData,'depth',params.GCrange);
fprintf('Total number of units in GC = %d\n',size(depthcut,1));

%Filter table by unit type
cutgood = filtertable(depthcut,'unitType','good');
fprintf('Number of good units in GC = %d\n',size(cutgood,1));
singleClusterData = table2struct(cutgood);

cutmua = filtertable(depthcut,'unitType','mua');
muaClusterData = table2struct(cutmua);



save([MouseID '-' SessionID '-ClusterData'],'params','singleClusterData','muaClusterData','-append');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove trials with no central/lateral licks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

count = 1;
trialmiss = [];
nTrials = size(LickData,2);
for i = 1:nTrials
    
    A = isempty(LickData(i).LeftLicks(:));
    B = isempty(LickData(i).RightLicks(:));
    C = isempty(LickData(i).CentralLicks(:));
    
    if A && B
        trialmiss(count) = i;
        count = count + 1;
    elseif C
        trialmiss(count) = i;
        count = count + 1;
        
    end
    
end


% Remove first 12 trials (first 12 trials are blocked pure tastes)
trialmiss = unique([1:12 trialmiss]);
fprintf('Removed first 12 trials\n');
params.BlockStartTrialsRemoved = 1; 


% remove these trials from trial struct
BehaviorData = LickData;
BehaviorData(trialmiss) = [];

%Remove trials from single unit clusters
nClust = size(singleClusterData,1);
for i = 1:nClust
    SPIKES = singleClusterData(i).spikes;
    badIDX = find(ismember(SPIKES(1,:),trialmiss)); %Identify column indices of trials to be removed
    SPIKEScut = SPIKES;
    SPIKEScut(:,badIDX) = [];
    
    singleClusterData(i).spikes = SPIKEScut;
end

%Remove trials from mua clusters
nClust = size(muaClusterData,1);
for i = 1:nClust
    SPIKES = muaClusterData(i).spikes;
    badIDX = find(ismember(SPIKES(1,:),trialmiss)); %Identify column indices of trials to be removed
    SPIKEScut = SPIKES;
    SPIKEScut(:,badIDX) = [];
    
    muaClusterData(i).spikes = SPIKEScut;    
end

params.NoResponseTrialsRemoved = 1; %Indicates trials with no response have been removed


save([MouseID '-' SessionID '-ClusterData'],'BehaviorData','singleClusterData','muaClusterData','params','-append');

fprintf('Number of trials removed = %d\n',length(trialmiss));
%% Remove low FR units


nClust = size(singleClusterData,1);
singleFRave.central = [];
singleFRave.lateral = [];
singleFRz = [];
figure;

trialcorrect = [BehaviorData.reward];
BehaviorDataCorrect = BehaviorData(trialcorrect);
for i = 1:nClust

    [singleClusterData(i).SpikesxValve, singleClusterData(i).FRxValve] = getMixtureSpikes(singleClusterData(i).spikes(2,:),BehaviorDataCorrect,params);
    
    singleFRave.central(i,:) = nanmean(singleClusterData(i).FRxValve{1});
    singleFRave.lateral(i,:) = nanmean(singleClusterData(i).FRxValve{2});
    singleFRz(i,:) = (singleFRave.central(i,:) - nanmean(singleFRave.central(i,:)))/nanstd(singleFRave.central(i,:));
    
end

lowFRidx = find(max(singleFRave.central') < params.FRcutoff);

if params.lowFRremoved == 0
    singleClusterData(lowFRidx) = [];
    singleFRz(lowFRidx,:) = [];
    params.lowFRremoved = 1;
end

save([MouseID '-' SessionID '-ClusterData'],'BehaviorData','singleClusterData','params','-append');

t = params.central.timeWin(1):params.central.binsize:params.central.timeWin(2);
t = t(1:end-1);

imagesc(t,1:size(singleFRz,1),singleFRz);
colorbar;
set(gca,'TickDir','out','XTick',[-4:1:15])
box off;
xlabel('Time (s)','fontsize',24); ylabel('Neuron','fontsize',24)

ppsize = [1600 700];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd([rootdir sep MouseID sep 'Figures\'])
print([MouseID '-' SessionID '-SingleUnits'],'-r200','-djpeg');


%%
% % % % % % Repeat for mua % % %
% % % nClust2 = size(muaClusterData,1);
% % % figure;
% % % for i = 1:nClust2
% % % 
% % %     [muaClusterData(i).SpikesxValve, muaClusterData(i).FRxValve] = getMixtureSpikes(muaClusterData(i).spikes(2,:),BehaviorDataCorrect,params);
% % %     
% % %     muaFRave(i,:) = mean(muaClusterData(i).FRxValve);
% % %     
% % % end
% % % 
% % % lowFRidx2 = find(max(muaFRave') < params.FRcutoff);
% % % 
% % % muaClusterData(lowFRidx2) = [];




%% Taste/Delay/Choice responsive units
%Try comparing 2 new tests:
% 1. Go back to variance cutoff
% 2. for each trial compute average baseline and average stimulus, then
% signrank (or ranksum?) these for each mixture.

cd([rootdir sep MouseID sep 'Figures\'])
mkdir('Mixtures')
cd([rootdir sep MouseID sep 'Figures\Mixtures\'])

nClust = size(singleClusterData,1);
figure;
valveclusters = {[1:4],[5:8]};
for i = 1:nClust  
  
    tasteresp = zeros(1,length(params.Tastants));
    delayresp = zeros(1,2);
    choiceresp = zeros(1,2);
    for v = 1:length(params.Tastants)
        [tasteresp(v), dirresp(i,v)] = isStimulusResponsive(singleClusterData(i).FRxValve{1}(v,:),params,'stim');
    end
    
    for v = 1:2
        [delayresp(v),~] = isStimulusResponsive(mean(singleClusterData(i).FRxValve{2}(valveclusters{v},:)),params,'delay'); 
        [choiceresp(v),~] = isStimulusResponsive(mean(singleClusterData(i).FRxValve{2}(valveclusters{v},:)),params,'choice');
    end
    
    if sum(tasteresp) > 0
        singleClusterData(i).TasteResponsive = 1;
    else 
        singleClusterData(i).TasteResponsive = 0;
    end
    
    if sum(delayresp) > 0
        singleClusterData(i).DelayResponsive = 1;
    else 
        singleClusterData(i).DelayResponsive = 0;
    end
    
    if sum(choiceresp) > 0
        singleClusterData(i).ChoiceResponsive = 1;
    else 
        singleClusterData(i).ChoiceResponsive = 0;
    end
    
    if sum(dirresp(i,:)) > 0
        singleClusterData(i).DirectionResponsive = 1;
    elseif sum(dirresp(i,:)) < 0
        singleClusterData(i).DirectionResponsive = -1;
    else 
        singleClusterData(i).DirectionResponsive = 0;
    end
    
    

   plotMixtureRasterFR(singleClusterData(i).SpikesxValve,singleClusterData(i).FRxValve,params);

    
   CellInfo = singleClusterData(i,:);   
   
   sgtitle({[CellInfo.mouseID '-' CellInfo.sessionID '-' num2str(CellInfo.cellNum,'%03.f')],...
       ['Taste = ' num2str(CellInfo.TasteResponsive), '; Delay = ' num2str(CellInfo.DelayResponsive) '; Choice = ' num2str(CellInfo.ChoiceResponsive)]},...
       'FontSize',20,'Color','r')
   
   print([MouseID '-' SessionID '-' num2str(singleClusterData(i).cellNum,'%03.f') '-' num2str(singleClusterData(i).unitTypeNum) '-Mixtures'],'-r200','-djpeg');
   clf;
end



cd([rootdir sep MouseID sep])
save([MouseID '-' SessionID '-ClusterData'],'BehaviorData','singleClusterData','params','-append');