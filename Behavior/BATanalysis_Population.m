%% ****************************************************************
%  *****              SUCROSE CURVES (POPULATION)             *****
%  ****************************************************************
% Calculate and plot average sucrose curve for all animals in cohort

ages = {'12wk','20wk'};
cohorts = {'MUT','CTRL','WT'};
plotpad = 20;
age = [];
for i = 1:length(ages)

    figure;

    CohortMUT = loadsessionsBAT(cohorts{1},ages{i});
    CohortCTRL = loadsessionsBAT(cohorts{2},ages{i});
    CohortWT = loadsessionsBAT(cohorts{3},ages{i});

    %%%%%%% I. Plot MUT cohort %%%%%%%
    LickALLMICE = [];
    nMice = length(CohortMUT);
    for mnum = 1:nMice
        cd([rootdir sep CohortMUT{mnum}]);
        load([CohortMUT{mnum} '-BAT-' BATtest '-' ages{i}])
        normlick = meanLickALL./meanLickALL(1); % normalize average licks for each mouse
        LickALLMICE = [LickALLMICE; normlick];    
    end
    meanLickALLMICE = mean(LickALLMICE,1);
    semLickALLMICE = std(LickALLMICE,1)./sqrt(nMice);

    subplot(3,1,1); plot(concALL,meanLickALLMICE,'-ko','MarkerFaceColor','k')
    hold on; errorbar(concALL,meanLickALLMICE,semLickALLMICE,'LineStyle', 'none'); hold off;

    box off; axis tight;
    set(gca,'TickDir','out','XTick',[concALL],'XTickLabels',num2str(concALL),'XLim',[concALL(1)-plotpad, concALL(end)+plotpad])
    xlabel('Sucrose concentration (mM)'); ylabel('normalized # of Licks');
    title(['MUTANT (N = ' num2str(length(CohortMUT)) ')'])

    %%%%%%% II. Plot CTRL cohort %%%%%%%

    LickALLMICE = [];
    nMice = length(CohortCTRL);
    for mnum = 1:nMice
        cd([rootdir sep CohortCTRL{mnum}]);
        load([CohortCTRL{mnum} '-BAT-' BATtest '-' ages{i}])
        normlick = meanLickALL./meanLickALL(1); % normalize average licks for each mouse
        LickALLMICE = [LickALLMICE; normlick];    
    end
    meanLickALLMICE = mean(LickALLMICE,1);
    semLickALLMICE = std(LickALLMICE,1)./sqrt(nMice);

    subplot(3,1,2); plot(concALL, meanLickALLMICE,'-ko','MarkerFaceColor','k')
    hold on; errorbar(concALL, meanLickALLMICE,semLickALLMICE,'LineStyle', 'none'); hold off;

    box off; axis tight; 
    set(gca,'TickDir','out','XTick',concALL,'XTickLabels',num2str(concALL),'XLim',[concALL(1)-plotpad, concALL(end)+plotpad])
    xlabel('Sucrose concentration (mM)'); ylabel('normalized # of Licks');
    title(['CONTROL (N = ' num2str(length(CohortCTRL)) ')'])

% %     sgtitle([BATtest ' - ' age],'FontSize',20, 'Color', 'red')
% % 
% %     ppsize = [800 1000];
% %     set(gcf,'PaperPositionMode','auto');         
% %     set(gcf,'PaperOrientation','landscape');
% %     set(gcf,'PaperUnits','points');
% %     set(gcf,'PaperSize',ppsize);
% %     set(gcf,'Position',[0 0 ppsize]);

    title(['CONTROL (N = ' num2str(length(CohortCTRL)) ')'])

    %%%%%%% III. Plot WT cohort %%%%%%%

    LickALLMICE = [];
    nMice = length(CohortWT);
    for mnum = 1:nMice
        cd([rootdir sep CohortWT{mnum}]);
        load([CohortWT{mnum} '-BAT-' BATtest '-' ages{i}])
        normlick = meanLickALL./meanLickALL(1); % normalize average licks for each mouse
        LickALLMICE = [LickALLMICE; normlick];    
    end
    meanLickALLMICE = mean(LickALLMICE,1);
    semLickALLMICE = std(LickALLMICE,1)./sqrt(nMice);

    subplot(3,1,3); plot(concALL, meanLickALLMICE,'-ko','MarkerFaceColor','k')
    hold on; errorbar(concALL, meanLickALLMICE,semLickALLMICE,'LineStyle', 'none'); hold off;

    box off; axis tight; 
    set(gca,'TickDir','out','XTick',concALL,'XTickLabels',num2str(concALL),'XLim',[concALL(1)-plotpad, concALL(end)+plotpad])
    xlabel('Sucrose concentration (mM)'); ylabel('normalized # of Licks');
    title(['WILDTYPE (N = ' num2str(length(CohortWT)) ')'])


    sgtitle([BATtest ' - ' ages{i}],'FontSize',20, 'Color', 'red')

    ppsize = [800 1000];
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'PaperUnits','points');
    set(gcf,'PaperSize',ppsize);
    set(gcf,'Position',[0 0 ppsize]);
end
%%% Sigmoid fits??? %%%