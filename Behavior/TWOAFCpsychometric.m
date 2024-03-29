rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR\2AFC-MIXTURE';
sep = '\';
MouseID = 'JMB017';
SessionID = 'Session3';
TaskID = 'Taste2AC_8V_Mixtures';
Tastants = [100 75 65 55 45 35 25 0]; % Percent sucrose concentration valves 1 --> 8

cd([rootdir sep MouseID sep TaskID sep 'Session Data'])

filename = uigetfile();
load([rootdir sep MouseID sep TaskID sep 'Session Data' sep filename]);

data = extractTrialData2AFC(SessionData,SessionID);

cd([rootdir sep MouseID])
nTrials = length(data);

%% Remove licks outside of sampling window

aCount = 0; bCount = 0; cCount = 0;

%Central licks
for i = 1:nTrials
     if ~isempty(data(i).CentralLicks(:))
         c = find(data(i).CentralLicks > data(i).sampleCentralev(2) | data(i).CentralLicks < data(i).sampleCentralev(1));       
         data(i).CentralLicks(c) = [];
         cCount = cCount + length(c);
     end 
end

%Left licks
for i = 1:nTrials
     if ~isempty(data(i).LeftLicks(:))
         a = find(data(i).LeftLicks(1:end) > data(i).sampleLateralev(2) | data(i).LeftLicks(1:end) < data(i).sampleLateralev(1));
         data(i).LeftLicks(a) = []; 
         aCount = aCount + length(a);
     end 
end



%Right licks
for i = 1:nTrials
     if ~isempty(data(i).RightLicks(:))
         b = find(data(i).RightLicks(1:end) > data(i).sampleLateralev(2) | data(i).RightLicks(1:end) < data(i).sampleLateralev(1));  
         data(i).RightLicks(b) = [];
         bCount = bCount + length(b);
     end
end

fprintf('Removed %d lateral licks and %d central licks from BPOD data\n',[aCount + bCount,cCount]);

%% Verify reward matches licking data
for i = 1:nTrials
   firstLeft = min(data(i).LeftLicks); 
   firstRight = min(data(i).RightLicks);
   
   if isempty(firstLeft) && ~isempty(firstRight)
       data(i).firstLateral = 2;
   elseif isempty(firstRight) && ~isempty(firstLeft)
       data(i).firstLateral = 1;
   elseif ~isempty(firstRight) && ~isempty(firstLeft)
       [~,data(i).firstLateral] = min([firstLeft firstRight]);
   end

   
   if data(i).TrialSequence == data(i).firstLateral
       data(i).Correct = 1;
   else 
       data(i).Correct = 0;
   end
   
end

dataTable = struct2table(data);

%Check that reward was given when first lateral lick was correct
if isequal(dataTable.Correct,double(dataTable.reward))
    fprintf('Reward data match\n')
else
    fprintf('Reward data MISMATCH - needs correction\n')
end
    

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remove trials with no central/lateral licks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LickData = data;
count = 1;
trialmiss = [];

for i = 1:nTrials
    
    A = isempty(data(i).LeftLicks(:));
    B = isempty(data(i).RightLicks(:));
    C = isempty(data(i).CentralLicks(:));
    
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

% remove these trials from trial struct
LickData(trialmiss) = [];
fprintf('Number of trials removed = %d\n',length(trialmiss));



dataTableCut = struct2table(LickData);

%% Calculate probability mouse will choose sucrose as function of sucrose concentration
valveSeq = [];
valveSeq(:,1) = dataTableCut.ValveSequence;
valveSeq(:,2) = dataTableCut.reward;

ratioSucrose = NaN(length(Tastants),2);
for t = 1:length(Tastants)
    trialIDX = find(valveSeq(:,1) == t);
    nCorrect = sum(valveSeq(trialIDX,2));
    ratioSucrose(t,1) = Tastants(t);
    if Tastants(1) == 100
        if t < 5

            ratioSucrose(t,2) = nCorrect/length(trialIDX);

        else
            ratioSucrose(t,2) = 1 - nCorrect/length(trialIDX);
        end
        
    elseif Tastants(1) == 0
        if t < 5
            ratioSucrose(t,2) = 1 - nCorrect/length(trialIDX);
        else
            ratioSucrose(t,2) = nCorrect/length(trialIDX);
        end
        
    end
           
    
end


ratioSucrose = sortrows(ratioSucrose,1,'ascend'); %Sort according to sucrose composition ascending


b = glmfit(ratioSucrose(:,1),ratioSucrose(:,2),'binomial');
yfit = glmval(b,0:100,'logit');

x50 = -b(1)/b(2);
slope = b(2)/4;

%%

figure;
scatter(ratioSucrose(:,1),100*ratioSucrose(:,2),40,'k','filled');
hold on;
plot(0:100,100*yfit,'LineWidth',2);
xlabel('Sucrose concentration (%)','Fontsize',18); ylabel('Sucrose choice (%)','Fontsize',18)
title([MouseID ': mixture psychometric curve'],'Fontsize',20)
set(gca,'TickDir','out','fontsize',16,'ylim',[0 100],'xlim',[0 100]);
xline(x50,'--k');
text(x50,5,['\leftarrow x50 = ' num2str(x50)],'fontsize',14)
text(0,95,[' slope = ' num2str(slope)],'fontsize',14)

print([MouseID '-' SessionID '-Psychometric'],'-r400','-dpdf');
print([MouseID '-' SessionID '-Psychometric'],'-r400','-djpeg');

%Confirm slope is correct
% % figure;
% % scatter(ratioCorr(:,1)-x50,ratioCorr(:,2),25,'filled')
% % hold on;
% % xx = [-20:20]; yy = 0.5+(b(2)/4).*xx;
% % plot(xx,yy)
% % plot([0:100]-x50, yfit)


%%
summaryData.MouseID = MouseID;
summaryData.ratioCorr = ratioSucrose;
summaryData.x50 = x50;
summaryData.slope = slope;
summaryData.task = TaskID;
summaryData.Tastants = Tastants;

save([MouseID '-' SessionID '-' TaskID '-Data'],'summaryData','LickData')


