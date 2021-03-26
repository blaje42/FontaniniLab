
ages = {'12wk', '20wk'};
cohorts = {'MUT','CTRL','WT'};
colors = {[0.85 0.06 0.06], [0.98 0.68 0.13], [0.15 0.15 0.15]};
shapes = {'o','d','s'};

% ages = {'13wk'};
% cohorts = {'CONTROL'};
% colors = {[0.15 0.15 0.15]};
% shapes = {'s'};


CTAtest = 'Sucrose'; %Tastant used for two-bottle preference test
rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR\CTA\';
sep = '\';

fontname = 'Arial';
set(0,'DefaultAxesFontName',fontname,'DefaultTextFontName',fontname,'DefaultTextColor','k','defaultAxesFontSize',16);
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'},'defaultAxesTickDir','out','defaultAxesTickDirMode','manual')

%%
allLickCount = [];
catLickCount = cell(length(ages),length(cohorts));
for i = 1:length(ages)

    
    for gg = 1:length(cohorts)
        
         MICE = loadsessionsCTA(cohorts{gg},ages{i});
         nMice = length(MICE);
    
        for mnum = 1:nMice
            
            cd([rootdir sep MICE{mnum}]);
            load([MICE{mnum} '-CTA-' CTAtest '-' ages{i}])
            allLickCount{i,gg}{mnum,1} = MICE{mnum};
            allLickCount{i,gg}{mnum,2} = lickCount;
            
%             fieldIDs = fieldnames(lickCount);
%             
%             temp = [];
%             for ff = 1:length(fieldIDs)
%                 temp = [temp allLickCount{i,gg}{mnum,2}.(fieldIDs{ff})];
%            
%             end
            
            %catLickCount{i,gg}(mnum,:) = temp;
            
            catLickCount{i,gg}(mnum,:) = [allLickCount{i,gg}{mnum,2}.(CTAtest) allLickCount{i,gg}{mnum,2}.PreferenceTest];
            
            normalizer = allLickCount{i,gg}{mnum,2}.(CTAtest)(1);
            normLickCount{i,gg}(mnum,:) = [allLickCount{i,gg}{mnum,2}.(CTAtest)./normalizer allLickCount{i,gg}{mnum,2}.PreferenceTest./normalizer];
            
            
        end
    end
end

%% Extinction

MouseIDs = {'TDPWF_056', 'TDPWF_055','TDPWF_054','TDPQF_044','TDPQF_045','TDPWM_057','TDPWM_058'};

CTAdataALL = [];
test = NaN(length(MouseIDs), 6);
testnorm = NaN(length(MouseIDs), 6);
for mnum = 1:length(MouseIDs)
    cd([rootdir sep MouseIDs{mnum}]);
    load([MouseIDs{mnum} '-CTA-' CTAtest '-20wk'])
    
    CTAdataALL = [CTAdataALL; CTADATA];
    
    test(mnum,1) = CTADATA.PreferenceTest{1};
    test(mnum,2:length(CTADATA.Extinction{1})+1) = CTADATA.Extinction{1};
    
    normalizer = CTADATA.(CTAtest){1}(1);
    
    testnorm(mnum,:) = test(mnum,:)./normalizer;
    
    
    GG(mnum) = find(strcmp(CTAdataALL.genotype(mnum,:),cohorts));

end

figure;
subplot(2,1,1)
for mnum = 1:size(test,1)

    hold on;
    plot(test(mnum,:),['--' shapes{GG(mnum)}],'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',colors{GG(mnum)},'Color',colors{GG(mnum)});

end

for gg = 1:length(cohorts)
    
    test2 = test(GG==gg,:);
    hold on;
errorbar(nanmean(test2,1),nanstd(test2,1)./sqrt(size(test2,1)),...
    ['-' shapes{gg}],'MarkerFaceColor',colors{gg},'MarkerEdgeColor',colors{gg},'Color',colors{gg},'LineWidth',1.5);

end
ylabel('# of Licks'); xlabel('Sucrose day')
set(gca,'XTick',[1:6],'XLim',[0.9 6.1],'XTickLabel',{'0','E1','E2','E3','E4','E5'},'YLim',[0 inf])


subplot(2,1,2)
for mnum = 1:size(test,1)

    hold on;
    plot(testnorm(mnum,:),['--' shapes{GG(mnum)}],'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',colors{GG(mnum)},'Color',colors{GG(mnum)});

end

for gg = 1:length(cohorts)
    
    test2 = testnorm(GG==gg,:);
    hold on;
errorbar(nanmean(test2,1),nanstd(test2,1)./sqrt(size(test2,1)),...
    ['-' shapes{gg}],'MarkerFaceColor',colors{gg},'MarkerEdgeColor',colors{gg},'Color',colors{gg},'LineWidth',1.5);

end
ylabel('normalized # of Licks'); xlabel('Sucrose day')
set(gca,'XTick',[1:6],'XLim',[0.9 6.1],'XTickLabel',{'0','E1','E2','E3','E4','E5'},'YLim',[0 1])

sgtitle('Extinction')
ppsize = [600 1200];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd('C:\Users\Jennifer\Documents\DATA\BEHAVIOR\CTA')
print(['CTA_Population_Extinction'] ,'-dpdf','-r400');


%%




for i = 1:length(ages)
figure(i);

for gg = 1:length(cohorts)
    if ~isempty(allLickCount{i,gg})
    subplot(2,1,1)
    for mnum = 1:size(allLickCount{i,gg},1)
        
        hold on;
        plot(catLickCount{i,gg}(mnum,:),['--' shapes{gg}],'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',colors{gg},'Color',colors{gg});

    end
    errorbar(mean(catLickCount{i,gg},1),std(catLickCount{i,gg},1)./sqrt(size(allLickCount{i,gg},1)),...
        ['-' shapes{gg}],'MarkerFaceColor',colors{gg},'MarkerEdgeColor',colors{gg},'Color',colors{gg},'LineWidth',1.5);
    ylabel('# of Licks')
    set(gca,'XTick',[1:3],'XLim',[0.9 3.1],'YLim',[0 inf])
        
    subplot(2,1,2)
    for mnum = 1:size(allLickCount{i,gg},1)
        hold on;
        plot(normLickCount{i,gg}(mnum,:),['--' shapes{gg}],'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',colors{gg},'Color',colors{gg});

    end
    errorbar(mean(normLickCount{i,gg},1),std(normLickCount{i,gg},1)./sqrt(size(allLickCount{i,gg},1)),['-' shapes{gg}],'MarkerFaceColor',colors{gg},'MarkerEdgeColor',colors{gg},'Color',colors{gg},'LineWidth',1.5)
    set(gca,'XTick',[1:3],'XLim',[0.9 3.1],'YLim',[0 inf])
    ylabel('Normalized licks'); xlabel('Sucrose Day')
    end
end

sgtitle(ages{i})

ppsize = [600 1200];
set(gcf,'PaperPositionMode','auto');         
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','points');
set(gcf,'PaperSize',ppsize);
set(gcf,'Position',[0 0 ppsize]);

cd('C:\Users\Jennifer\Dropbox\FontaniniLab\Lab Meeting\Figures\LabMeeting1')
print(['CTA_Population_' ages{i}] ,'-dpdf','-r400');

end



