%PILOT DATA 1 ANALYSIS

ages = {'12wk','20wk'};
cohorts = {'MUT','CTRL','WT'};
concs = {'50','100'};
TBTtest = 'Sucrose'; %Tastant used for two-bottle preference test
rootdir = 'C:\Users\Jennifer\Documents\DATA\BEHAVIOR\TWO-BOTTLE\';
sep = '\';

fontname = 'Arial';
set(0,'DefaultAxesFontName',fontname,'DefaultTextFontName',fontname,'DefaultTextColor','k','defaultAxesFontSize',16);
set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},{'k','k','k'},'defaultAxesTickDir','out','defaultAxesTickDirMode','manual')
colors = {[0.85 0.06 0.06], [0.98 0.68 0.13], [0.15 0.15 0.15]};
shapes = {'o','d','s'};


%% Extract data


for i = 1:length(ages)
        Consumption{i} = cell(length(concs),length(cohorts));
        sPreference{i} = cell(length(concs),length(cohorts));
    for conc = 1:length(concs)
        Cohort.MUT = loadsessionsTBT(cohorts{1},ages{i},concs{conc});
        Cohort.CTRL = loadsessionsTBT(cohorts{2},ages{i},concs{conc});
        Cohort.WT = loadsessionsTBT(cohorts{3},ages{i},concs{conc});


        for gg = 1:length(cohorts)
            MICE = Cohort.(cohorts{gg});
            nMice = length(MICE);

            for mnum = 1:nMice

                cd([rootdir sep MICE{mnum}]);
                load([MICE{mnum} '-TBT-' TBTtest '-' ages{i}])
                Consumption{i}{gg,conc}(:,mnum) = ConsumptionData(:,3);
                sPreference{i}{gg,conc}(:,mnum) = 100*(ConsumptionData(:,2)./ConsumptionData(:,3));
            end
        end
    end
end


%% Plot
for i = 1:length(ages)
    figure(i);

    for conc = 1:length(concs)
        for gg = 1:length(cohorts)
            subplot(2,3*length(concs),[3*(conc-1)+1 3*(conc-1)+2])
            hold on;
            for mnum = 1:size(Consumption{i}{gg,conc},1)

                plot(Consumption{i}{gg,conc}(mnum,:),['-' shapes{gg}],'MarkerFaceColor',colors{gg},'MarkerEdgeColor',colors{gg},'Color',colors{gg});

            end  
            hold off
            set(gca,'XTick',[1:5],'XLim',[0.5 5.5],'YLim',[0 4]); 
            title([concs{conc} ' ' TBTtest])
            if conc == 1
                ylabel('Amount consumed (g)')

            end


            subplot(2,3*length(concs),[3*(conc-1)+3*length(concs)+1 3*(conc-1)+3*length(concs)+2])
            hold on;    
            for mnum = 1:size(Consumption{i}{gg,conc},1)

                plot(sPreference{i}{gg,conc}(mnum,:),['-' shapes{gg}],'MarkerFaceColor',colors{gg},'MarkerEdgeColor',colors{gg},'Color',colors{gg});

            end 
            set(gca,'XTick',[1:5],'XLim',[0.5 5.5],'YLim',[0 100]); xlabel('Test Day'); 
            if conc == 1
                ylabel('Sucrose Preference (%)') 
            end

        end



    subplot(2,3*length(concs),3*conc); hold on;
    for gg = 1:length(cohorts)
        mConsumption{i}{gg,conc} = nanmean(Consumption{i}{gg,conc}(:,2:end),2);    
        b = bar(gg,nanmean(mConsumption{i}{gg,conc}),'EdgeColor','none','BarWidth',0.5,'FaceColor','flat');
        errorbar(gg,nanmean(mConsumption{i}{gg,conc}),nanstd(mConsumption{i}{gg,conc}),'k','LineStyle','none');

        b.CData = colors{gg};
    end
    set(gca,'ylim',[0 4], 'XTick',[1:3],'XTickLabel',cohorts); box off;

    subplot(2,3*length(concs),3*conc+3*length(concs)); hold on;
    for gg = 1:length(cohorts)
        mPreference{i}{gg,conc} = nanmean(sPreference{i}{gg,conc}(:,2:end),2);    
        b = bar(gg,nanmean(mPreference{i}{gg,conc}),'EdgeColor','none','BarWidth',0.5,'FaceColor','flat');
        errorbar(gg,nanmean(mPreference{i}{gg,conc}),nanstd(mPreference{i}{gg,conc}),'k','LineStyle','none');

        b.CData = colors{gg};
    end
    set(gca,'ylim',[0 100], 'XTick',[1:3],'XTickLabel',cohorts); box off;
    end

    ppsize = [1800 1000];
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'PaperUnits','points');
    set(gcf,'PaperSize',ppsize);
    set(gcf,'Position',[0 0 ppsize]);

    sgtitle(['Two-bottle preference test: ' ages{i}],'FontSize',20,'Color','red','Interpreter', 'none')

    cd([rootdir sep]);
    %print(['TBT_Population_' ages{i}],'-dpdf','-r400'); fprintf('Printing... %s\n', [OutputFileName '_TBTsummary']);

end

figure; 
sPreferenceMEAN = cell(1,length(ages));
sPreferenceSEM = cell(1,length(ages));
for i = 1:length(ages)
    sPreferenceMEAN{i} = NaN(length(cohorts),length(concs));
    sPreferenceSEM{i} = NaN(length(cohorts),length(concs));
    for gg = 1:length(cohorts)
    for conc = 1:length(concs)
        
        sPreferenceMEAN{i}(gg,conc) = nanmean(mPreference{i}{gg,conc});
        sPreferenceSEM{i}(gg,conc) = nanstd(mPreference{i}{gg,conc})./sqrt(length(mPreference{i}{gg,conc}));

    end
    
    subplot(length(ages),1,i); 
    hold on;
    %for gg = 1:length(cohorts)
        hold on;
        scatter(1:length(concs),sPreferenceMEAN{i}(gg,:),40,colors{gg},shapes{gg},'filled'); hold on;
        errorbar(1:length(concs),sPreferenceMEAN{i}(gg,:),sPreferenceSEM{i}(gg,:),'Color',colors{gg});
    end
    hold off;
    set(gca,'YLim',[0 100],'XLim',[0.5 length(concs)+0.5],'XTick',[1:length(concs)],'XTickLabel',concs);
    xlabel('Sucrose Concentration (mM)');
    ylabel('Sucrose Preference (%)');
    title(ages{i})
end


%% PILOT

% % GROUPA = {'TDPQF_025','TDPQF_026','TDPQM_032','TDPWM_017','TDPWM_018','TDPWF_012'}; %Extra 15 min water in the afternoon
% % GROUPB = {'TDPWM_019','TDPWM_020','TDPQM_029','TDPQM_030','TDPQM_031','TDPQF_027'};
% % 
% % Cohort.MUT = {'TDPQF_026','TDPQF_027','TDPQM_031'};
% % Cohort.CTRL = {'TDPWM_018','TDPWF_012','TDPWM_019'};
% % Cohort.WT = {'TDPQF_025','TDPWM_017','TDPWM_020','TDPQM_029','TDPQM_030','TDPQM_032'};
% % 
% % 
% % colors = {[0.85 0.06 0.06], [0.98 0.68 0.13], [0.15 0.15 0.15]};
% % shapes = {'o','d','s'};
% % 
% % 
% % Consumption = cell(1,length(cohorts));
% % sPreference = cell(1,length(cohorts));
% % for gg = 1:length(cohorts)
% %     MICE = Cohort.(cohorts{gg});
% %     nMice = length(MICE);
% %     
% %     for mnum = 1:nMice
% % 
% %         cd([rootdir sep MICE{mnum}]);
% %         load([MICE{mnum} '-TBT-' TBTtest '-' age])
% %         Consumption{gg}(:,mnum) = ConsumptionData(:,3);
% %         sPreference{gg}(:,mnum) = 100*(ConsumptionData(:,2)./ConsumptionData(:,3));
% %         if ~isempty(find(contains(GROUPA,MICE{mnum})))
% %             groupID{gg}(mnum) = 0;
% %         else groupID{gg}(mnum) = 1;
% %         end
% %         
% %     end
% %     
% % end
% % 
% % %%
% % 
% % figure;
% % for gg = 1:length(cohorts)
% %     subplot(2,3,[1 2])
% %     hold on;
% %     for mnum = 1:size(Consumption{gg},2)
% %         if groupID{gg}(mnum) == 0
% %             plot(Consumption{gg}(:,mnum),['-' shapes{gg}],'MarkerFaceColor',colors{gg},'MarkerEdgeColor',colors{gg},'Color',colors{gg});
% %         else plot(Consumption{gg}(:,mnum),['--' shapes{gg} ],'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',colors{gg},'Color',colors{gg});
% %         end
% %     end  
% %     hold off
% %     set(gca,'XTick',[1:5],'XLim',[0.5 5.5],'YLim',[0 4]); ylabel('Amount consumed (g)') 
% %     
% %  
% %     subplot(2,3,[4 5])
% %     hold on;    
% %     for mnum = 1:size(Consumption{gg},2)
% %         if groupID{gg}(mnum) == 0
% %             plot(sPreference{gg}(:,mnum),['-' shapes{gg}],'MarkerFaceColor',colors{gg},'MarkerEdgeColor',colors{gg},'Color',colors{gg});
% %         else plot(sPreference{gg}(:,mnum),['--' shapes{gg} ],'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',colors{gg},'Color',colors{gg});
% %         end
% %     end 
% %     set(gca,'XTick',[1:5],'XLim',[0.5 5.5]); xlabel('Test Day'); ylabel('Sucrose Preference (%)') 
% %         
% % end
% % 
% % 
% % 
% % subplot(2,3,3); hold on;
% % for gg = 1:length(cohorts)
% %     mConsumption{gg} = mean(Consumption{gg}(2:end,:));    
% %     b = bar(gg,mean(mConsumption{gg}),'EdgeColor','none','BarWidth',0.5,'FaceColor','flat');
% %     errorbar(gg,mean(mConsumption{gg}),std(mConsumption{gg}),'k','LineStyle','none');
% % 
% %     b.CData = colors{gg};
% % end
% % set(gca,'ylim',[0 4], 'XTick',[1:3],'XTickLabel',cohorts); box off;
% % 
% % subplot(2,3,6); hold on;
% % for gg = 1:length(cohorts)
% %     mPreference{gg} = mean(sPreference{gg}(2:end,:));    
% %     b = bar(gg,mean(mPreference{gg}),'EdgeColor','none','BarWidth',0.5,'FaceColor','flat');
% %     errorbar(gg,mean(mPreference{gg}),std(mPreference{gg}),'k','LineStyle','none');
% % 
% %     b.CData = colors{gg};
% % end
% % set(gca,'ylim',[0 100], 'XTick',[1:3],'XTickLabel',cohorts); box off;
% % 
% % ppsize = [1600 1000];
% % set(gcf,'PaperPositionMode','auto');         
% % set(gcf,'PaperOrientation','landscape');
% % set(gcf,'PaperUnits','points');
% % set(gcf,'PaperSize',ppsize);
% % set(gcf,'Position',[0 0 ppsize]);
% % 
% % cd(rootdir)
% % print(['Pilot_TBT_Summary'],'-dpdf','-r400');