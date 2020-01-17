%% ****************************************************************
%  *****            IMPORT AND ANALYZE WEIGHT DATA            *****
%  ****************************************************************
% Excel data structure (columns): Mouse ID, Genotype, Sex, DOB, weightX, dateX, ageX
%


%%%% 1. Import weight data %%%%
rootdir = 'C:\Users\Jennifer\Dropbox\FontaniniLab\Experiment Logs';
WeightTable = readtable('WeightLog.xlsx');
GENOTYPE = {'TDP43 Mut','TDP43 Ctrl','TDP43 WT'};
nWeights = (size(WeightTable,2) - 4)/3; %Not all mice will have this number of weights

%%%% 2. Extract weight/age data for different GENOTYPE and SEX %%%%

%Find indexes for different genotypes
geneIDX = cell(1,length(GENOTYPE));
for gg = 1:length(GENOTYPE)
    geneIDX{gg} = find(strcmp(WeightTable.Genotype,GENOTYPE{gg}));
end

%Pre-allocate
WeightData = cell(1,length(GENOTYPE));
WeightDataF = cell(1,length(GENOTYPE));
WeightDataM = cell(1,length(GENOTYPE));
SEX = cell(1,length(GENOTYPE));

%Extract weight/age data for different sexes and genotypes
for gg = 1:length(GENOTYPE)
    SEX{gg} = WeightTable.Sex(geneIDX{gg}); %Extract Sex
    for w = 1:nWeights
        
        age_days = WeightTable.(['age' num2str(w)])(geneIDX{gg}); %Extract age
        weight_g = WeightTable.(['weight' num2str(w)])(geneIDX{gg}); %Extract weights       
        data = [weight_g age_days]; %Concatenate age and weight
        WeightData{gg} = [WeightData{gg}; data];
        
        %Separate data for males and females
        dataF = data(strcmp(SEX{gg},'F'),:);
        dataM = data(strcmp(SEX{gg},'M'),:);
        
        WeightDataF{gg} = [WeightDataF{gg}; dataF];
        WeightDataM{gg} = [WeightDataM{gg}; dataM];
               
    end
end

%%%% 3. Calculate average weights over time window %%%%
age_bins = [4:7:365]; %Create age 'week' bins (i.e. 1 week = 4-10 days)

%Pre-allocate
binIDsF = cell(1,length(GENOTYPE)); binIDsM = cell(1,length(GENOTYPE));
aveWeightM = cell(1,length(GENOTYPE)); aveWeightF = cell(1,length(GENOTYPE));

for gg = 1:length(GENOTYPE)
    
   %Assign age bin IDs (weeks) for each data point
   WeightDataF{gg}(:,3) = discretize(WeightDataF{gg}(:,2),age_bins);
   WeightDataM{gg}(:,3) = discretize(WeightDataM{gg}(:,2),age_bins);
      
   %Average weight in age bins
   binIDsF{gg} = unique(WeightDataF{gg}(:,3));
   for i = 1:length(binIDsF{gg})
       
       aveWeightF{gg}(i,1) = mean(WeightDataF{gg}(WeightDataF{gg}(:,3) == binIDsF{gg}(i),1)); %Average weights for each age bin
       aveWeightF{gg}(i,2) = binIDsF{gg}(i);     
       aveWeightF{gg}(i,3) = std(WeightDataF{gg}(WeightDataF{gg}(:,3) == binIDsF{gg}(i),1))./sqrt(numel(find(WeightDataF{gg}(:,3) == binIDsF{gg}(i)))); %S.E.M.
       
   end
   
   binIDsM{gg} = unique(WeightDataM{gg}(:,3));
   for i = 1:length(binIDsM{gg})
       
       aveWeightM{gg}(i,1) = mean(WeightDataM{gg}(WeightDataM{gg}(:,3) == binIDsM{gg}(i),1));
       aveWeightM{gg}(i,2) = binIDsM{gg}(i);
       aveWeightM{gg}(i,3) = std(WeightDataM{gg}(WeightDataM{gg}(:,3) == binIDsM{gg}(i),1))./sqrt(numel(find(WeightDataM{gg}(:,3) == binIDsM{gg}(i))));
       
   end
end


%% ****************************************************************
%  *****                     PLOT WEIGHTS                     *****
%  ****************************************************************


%%%% 4. Plot weight over time for different GENOTYPE and SEX %%%%

colors = {[0.85 0.06 0.06], [0.98 0.68 0.13], 'k'};
shapes = {'o','d','s'};

figure;
subplot(3,2,[1 2])
hold on;
for gg = 1:length(GENOTYPE)

    scatter(WeightData{gg}(:,2),WeightData{gg}(:,1),25,colors{gg},shapes{gg},'filled'); 
    
end
hold off;
set(gca,'TickDir','out')
legend(GENOTYPE,'location','northwest')
xlabel('age (days)'); ylabel('weight (g)')

subplot(3,2,3)
hold on;
for gg = 1:length(GENOTYPE)

    scatter(WeightDataF{gg}(:,2),WeightDataF{gg}(:,1),25,colors{gg},shapes{gg},'filled');    
    
end
hold off;
set(gca,'TickDir','out')
xlabel('age (days)'); ylabel('weight (g)')
title('FEMALES')

subplot(3,2,4)
hold on;
for gg = 1:length(GENOTYPE)

    scatter(WeightDataM{gg}(:,2),WeightDataM{gg}(:,1),25,colors{gg},shapes{gg},'filled');    
    
end
hold off;
set(gca,'TickDir','out')
xlabel('age (days)'); ylabel('weight (g)')
title('MALES')

subplot(3,2,5)
hold on;
for gg = 1:length(GENOTYPE)

    errorbar(aveWeightF{gg}(:,2),aveWeightF{gg}(:,1),aveWeightF{gg}(:,3),'Color',colors{gg},'Marker',shapes{gg},'MarkerSize',7,'MarkerFaceColor',colors{gg}); 
    
end
hold off;
set(gca,'TickDir','out')
xlabel('age (~weeks)'); ylabel('weight (g)')


subplot(3,2,6)
hold on;
for gg = 1:length(GENOTYPE)

    errorbar(aveWeightM{gg}(:,2),aveWeightM{gg}(:,1),aveWeightM{gg}(:,3),'Color',colors{gg},'Marker',shapes{gg},'MarkerSize',7,'MarkerFaceColor',colors{gg}); 
    
end
hold off;
set(gca,'TickDir','out')
xlabel('age (~weeks)'); ylabel('weight (g)')


ppsize = [1400 1200];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

sgtitle('WEIGHTS','FontSize',20, 'Color', 'red')


