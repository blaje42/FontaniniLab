function plotLickStructure(LickStruct,trialconc,figtitle,ppsize)
%Summary figure of lick structure for individual animal
%
% INPUTS:
%   LickStruct (cell of structs) = lick structure data, output from
%                                  calcLickStructure.m
%   trialconc (column/row array) =
%   figtitle (string) = Figure title
%   ppsize (row array), optional = row vector with 2 values [width height] figure size (points). 
%                                  Excluding this input will not resize the figure. 
%
% OUTPUTS:
%   figure containing lick rasters


nSessions = length(LickStruct);

colors = [0 0 0; 0.6 0.2 0.3; 0.37 0.6 0.2; 0.67 0.36 0.22; 0.46 0.15 0.42; 0.17 0.28 0.44]; %Colors for lick rasters
for testnum = 1:nSessions 
    nTrials = length(trialconc{testnum});
    conc = unique(trialconc{testnum});
    lickTime = LickStruct{testnum}.lickTime;
    [sortCONC,IDX] = sort(trialconc{testnum});
    sortLickTime = lickTime(IDX,:);
    
    % Plot individual lick rasters
    subplot(3,nSessions*2,[2*testnum-1 2*testnum])
    
    for t = 1:nTrials
        hold on;
        scatter(sortLickTime(t,:),repmat(t,1,size(sortLickTime,2)),10,colors(conc == sortCONC(t),:),'filled')        
    end
    set(gca,'TickDir','out','YTick',[(nTrials/length(conc))/2:nTrials/length(conc):100],'YTickLabels',num2str(conc))
    box off; axis tight
    xlabel('Time from first lick (ms)'); title(['Session ' num2str(testnum)])
    if testnum == 1
        ylabel('Conc. by Trial # (mM)');
    end
    
    %# of licks total per trial per concentration
    subplot(3,nSessions*2,2*nSessions+2*(testnum-1)+1)
    
    for c = 1:length(conc)
        cidx = find(trialconc{testnum} == conc(c));
        hold on; scatter(repmat(c,1,length(cidx)), LickStruct{testnum}.totalLick(cidx),25,colors(c,:),'filled');
        scatter(c,sum(LickStruct{testnum}.totalLick(cidx)),25,'dr','filled') %Plot total licks across trials for each concentration
    end
    box off; axis tight;
    set(gca,'TickDir','out','XTick',1:length(conc),'XTickLabels',num2str(conc),'XLim',[0.5, length(conc)+0.5])
    ylabel('Total # of licks'); xlabel('Concentration (mM)')

    %Distribution of ILIs for the entire session
    subplot(3,nSessions*2,2*nSessions+2*(testnum-1)+2)
    
    edges = [0:10:LickStruct{testnum}.minboutILI];
    c = histc(LickStruct{testnum}.ili(:),edges);
%     term = find(c > 2,1,'last'); %Find last bin with nonzero value
%     c(term+1:end) = [];
%     edges(term+1:end) = [];
    bar(edges,c,'EdgeColor','none')
    box off; axis tight;
    set(gca,'TickDir','out','XTick',0:100:LickStruct{testnum}.minboutILI,'XTickLabels',num2str([0:100:LickStruct{testnum}.minboutILI]'));
    xlabel('ILI (ms)'); ylabel('# of licks');
    
    %# of licks/bout per concentration
    subplot(3,nSessions*2,4*nSessions+2*(testnum-1)+1)
        
    for c = 1:length(conc)
        cidx = find(trialconc{testnum} == conc(c));
        hold on; scatter(repmat(c,1,length(horzcat(LickStruct{testnum}.boutLickCount{cidx}))), ...
            horzcat(LickStruct{testnum}.boutLickCount{cidx}),25,colors(c,:),'filled');
    end
    box off; axis tight;
    set(gca,'TickDir','out','XTick',1:length(conc),'XTickLabels',num2str(conc),'XLim',[0.5, length(conc)+0.5])
    ylabel('# licks per bout'); xlabel('Concentration (mM)')
    
    %# of bouts per concentration
    subplot(3,nSessions*2,4*nSessions+2*(testnum-1)+2)

    for c = 1:length(conc)
        cidx = find(trialconc{testnum} == conc(c));
        hold on; scatter(repmat(c,1,length(cidx)), cellfun('length',LickStruct{testnum}.boutLickCount(cidx)),25,colors(c,:),'filled');
    end
    box off; axis tight;
    set(gca,'TickDir','out','XTick',1:length(conc),'XTickLabels',num2str(conc),'XLim',[0.5, length(conc)+0.5])
    ylabel('# bouts'); xlabel('Concentration (mM)')
    
end

sgtitle([figtitle ' Lick Structure'],'FontSize',20,'Color','red','Interpreter', 'none')

if nargin > 3
    set(gcf,'PaperPositionMode','auto');         
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'PaperUnits','points');
    set(gcf,'PaperSize',ppsize);
    set(gcf,'Position',[0 0 ppsize]);
end