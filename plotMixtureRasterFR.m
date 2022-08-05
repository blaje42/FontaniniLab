function plotMixtureRasterFR(Spikes,FR,params,opt)

    t1 = params.central.timeWin(1):params.central.binsize:params.central.timeWin(2);
    t2 = params.lateral.timeWin(1):params.lateral.binsize:params.lateral.timeWin(2);



    t1 = t1(1:end-1);
    t2 = t2(1:end-1);
    nValve = length(params.Tastants);
    
    colors_tastant = {'#581845', '#825274','#AC8BA2','#D5C5D1','#a4c0c6','#76a1aa','#49828e','#1c6372'};
    colors_decision = {'#900C3F','#27B7DA'};
    decision_legend = {'more sucrose','more salt'};
    
    if params.Tastants(1) == 0 %If reverse orientation, reverse the colors so always the same for each tastant
        colors_tastant = fliplr(colors_tastant);
        colors_decision = fliplr(colors_decision); decision_legend = fliplr(decision_legend);
    end


    cumtrials = 0;
    for v = 1:nValve

        %%% Raster plot %%%
        

        %Renumber trials so each mixture is grouped together on plot
        UniqueTrials = unique(Spikes{1,v}(1,:));
        [~,trialIDX] = ismember(Spikes{1,v}(1,:),UniqueTrials);
        trialIDX = trialIDX + cumtrials;
        
        subplot(2,2,1); hold on;
        plot([Spikes{1,v}(2,:); Spikes{1,v}(2,:)],[trialIDX - 0.4; trialIDX + 0.4],'Color',colors_tastant{v},'LineWidth',1.25);
        xline(0,'--');
        set(gca,'TickDir','out','XLim',params.central.timeWin,'fontsize',16)
        axis tight
        ylabel('Trial','Fontsize',18)
        title('Central Aligned','Fontsize',18);
        

        [~,trialIDX2] = ismember(Spikes{2,v}(1,:),UniqueTrials);
        trialIDX2 = trialIDX2 + cumtrials;
        
        subplot(2,2,2); hold on;
% %         plot([Spikes{2,v}(2,:); Spikes{2,v}(2,:)],[trialIDX2 - 0.4; trialIDX2 + 0.4],'Color',colors_tastant{v},'LineWidth',1.25);
        if ismember(v,1:4)
            colorID = colors_decision{1};
        elseif ismember(v,5:8)
            colorID = colors_decision{2};
        end
        plot([Spikes{2,v}(2,:); Spikes{2,v}(2,:)],[trialIDX2 - 0.4; trialIDX2 + 0.4],'Color',colorID,'LineWidth',1.25);
            
            
        xline(0,'--');
        set(gca,'TickDir','out','XLim',params.lateral.timeWin,'fontsize',16)
        axis tight
        title('Lateral Aligned','Fontsize',18);

        cumtrials = cumtrials + length(UniqueTrials);
        
        


        %%% Smooth FR plot %%%
        subplot(2,2,3); hold on;
        pp = plot(t1,FR{1}(v,:),'Color',colors_tastant{v},'LineWidth',2);        
        figobj(v) = pp(1); %For figure legend
        xline(0,'--');
        set(gca,'TickDir','out','XLim',params.central.timeWin,'fontsize',16)
        xlabel('Time (s)','Fontsize',18); ylabel('Firing Rate (Hz)','Fontsize',18)
        
        
% %         subplot(2,2,4); hold on;
% %         plot(t2,FR{2}(v,:),'Color',colors_tastant{v},'LineWidth',2);        
% %         xline(0,'--');
% %         set(gca,'TickDir','out','XLim',params.lateral.timeWin,'fontsize',16)
% %       
% %         xlabel('Time (s)','Fontsize',18); 


    end
    
    subplot(2,2,4); hold on;
    plot(t2,mean(FR{2}(1:4,:)),'Color',colors_decision{1},'LineWidth',2); 
    plot(t2,mean(FR{2}(5:8,:)),'Color',colors_decision{2},'LineWidth',2);
    xline(0,'--');
    legend(decision_legend,'Location','NorthEast')
    set(gca,'TickDir','out','XLim',params.lateral.timeWin,'fontsize',16)

    xlabel('Time (s)','Fontsize',18); 
     
    legend(figobj,string(params.Tastants),'Location','NorthEast')

    ppsize = [1600 1200];
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperUnits','points');
    set(gcf,'PaperSize',ppsize);
    set(gcf,'Position',[0 0 ppsize]);


% % % %For each cluster, raster plot + smooth FR with different color for each mixture
% % % if nargin > 3
% % %     t = params.lateraltimeWin(1):params.binsize:params.lateraltimeWin(2);
% % % else
% % %     t = params.timeWin(1):params.binsize:params.timeWin(2);
% % % end
% % %     t = t(1:end-1);
% % %     nValve = length(params.Tastants);
% % %     
% % %     colors = {'#581845', '#825274','#AC8BA2','#D5C5D1','#a4c0c6','#76a1aa','#49828e','#1c6372'};
% % %     
% % %     if params.Tastants(1) == 0 %If reverse orientation, reverse the colors so always the same for each tastant
% % %         colors = fliplr(colors);
% % %     end
% % % 
% % % 
% % %     cumtrials = 0;
% % %     for v = 1:nValve
% % % 
% % %         %%% Raster plot %%%
% % %         subplot(2,1,1); hold on;
% % % 
% % %         %Renumber trials so each mixture is grouped together on plot
% % %         UniqueTrials = unique(Spikes{v}(1,:));
% % %         [~,trialIDX] = ismember(Spikes{v}(1,:),UniqueTrials);
% % %         trialIDX = trialIDX + cumtrials;
% % % 
% % %         plot([Spikes{v}(2,:); Spikes{v}(2,:)],[trialIDX - 0.4; trialIDX + 0.4],'Color',colors{v},'LineWidth',1.25);
% % %         xline(0,'--');
% % % 
% % %         cumtrials = cumtrials + length(UniqueTrials);
% % %         if nargin > 3
% % %             set(gca,'TickDir','out','XLim',params.lateraltimeWin,'fontsize',16)
% % %         else
% % %             
% % %             set(gca,'TickDir','out','XLim',params.timeWin,'fontsize',16)
% % %         end
% % %         ylabel('Trial','Fontsize',18)
% % % 
% % % 
% % %         %%% Smooth FR plot %%%
% % %         subplot(2,1,2); hold on;
% % %         pp = plot(t,FR(v,:),'Color',colors{v},'LineWidth',2);        
% % %         figobj(v) = pp(1); %For figure legend
% % %         xline(0,'--');
% % % 
% % %         if nargin > 3
% % %             set(gca,'TickDir','out','XLim',params.lateraltimeWin,'fontsize',16)
% % %         else
% % %             
% % %             set(gca,'TickDir','out','XLim',params.timeWin,'fontsize',16)
% % %         end
% % %         
% % %         xlabel('Time (s)','Fontsize',18); ylabel('Firing Rate (Hz)','Fontsize',18)
% % % 
% % % 
% % %     end
% % %      
% % %     legend(figobj,string(params.Tastants),'Location','NorthEast')
% % % 
% % %     ppsize = [700 1400];
% % %     set(gcf,'PaperPositionMode','auto');         
% % %     set(gcf,'PaperOrientation','portrait');
% % %     set(gcf,'PaperUnits','points');
% % %     set(gcf,'PaperSize',ppsize);
% % %     set(gcf,'Position',[0 0 ppsize]);