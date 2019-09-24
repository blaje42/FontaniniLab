function lickStruct = calcLickStructure(ILIdata, minboutsize, minboutILI)
% Calculates licking microstructure from lick ILI data
%
% INPUTS:
%   lickILI (array) = contains lick ILI data (ms), each row is a separate
%                     trial. Can also be fed in 1 trial at a time as a row vector
%   minboutsize (number) = minimum # of licks to be considered as a bout(i.e 3 licks)
%   minboutILI (number), optional = minimum ILI to be considered a new
%                                   bout, ms (default) is 500 ms
%
% OUTPUTS:
%   lickStruct (struct) = contains lick microstructure data calculated from
%                         ILIs

nTrials = size(ILIdata,1);
boutDurationALL = cell(1,nTrials);
boutLickCountALL = cell(1,nTrials);
ibiALL = cell(1,nTrials);

%Convert lick ILI into time relative to first lick
lickTime = NaN(nTrials,size(ILIdata,2)+1);
lickTime(:,1) = zeros(nTrials,1); %Time will be relative to first lick
for n = 1:size(ILIdata,2)     
    lickTime(:,n+1) = ILIdata(:,n) + lickTime(:,n);
end


if nargin < 3
    minboutILI = 500;  % ILI defining new licking bout is 500 ms 
end

totalLick = NaN(1,nTrials);
for trial = 1:nTrials
    totalLick(trial) = length(ILIdata(trial,~isnan(ILIdata(trial,:)))) + 1;
    
    boutstart = find(ILIdata(trial,:) >= minboutILI); % inter lick interval is bigger than <minboutILI> ms, which means a new licking bouts
    boutIDX = cell(1,length(boutstart));
    if ~isempty(boutstart)

        for i = 1:length(boutstart)
             if i == 1
                boutIDX{1} = 1:boutstart(1)-1;
                ibi(1) = ILIdata(trial,boutstart(1)); % first bout could have no preceding bout, so inter-bout-interval is NaN
             else
                 boutIDX{i} = boutstart(i-1) + 1:boutstart(i) - 1;
                 ibi(i) = ILIdata(trial,boutstart(i)); %inter bout interval (time since last lick, initiating new bout)
             end             
        end
        boutIDX{i+1} = boutstart(i):totalLick(trial) - 1; % add remaining licks at end as a bout
    else
        boutIDX{1} = 1:length(ILIdata(trial,~isnan(ILIdata(trial,:)))); %If empty, we have a single bout which includes all licks
        ibi = nan;
    end
    
    
    % Remove the bouts with less than <minboutsize> licks
    for i = 1:length(boutIDX)
        if length(boutIDX{i}) < minboutsize
           boutIDX{i} = [];
        end  
    end
    boutIDX = boutIDX(~cellfun('isempty',boutIDX));
    
    % Calculate # of licks and duration of each bout
    boutduration = NaN(1,length(boutIDX));
    boutLickCount = NaN(1,length(boutIDX));
    for i = 1:length(boutIDX)
        boutduration(i) = sum(ILIdata(trial,boutIDX{i})); % Total duration of each bout (ms)
        boutLickCount(i) = length(boutIDX{i}); % Total lick count of each bout
    end
    
boutLickCountALL{trial} = boutLickCount;
boutDurationALL{trial} = boutduration;
ibiALL{trial} = ibi;

end


if ~isempty(boutLickCountALL)
    
    lickStruct.ili =                    ILIdata; %Original lick ILI (same as input) [array]
    lickStruct.boutDuration =   boutDurationALL; %Duration of each bout (ms) for each trial [cell]
    lickStruct.boutLickCount = boutLickCountALL; %Lick count of each bout for each trial [cell]
    lickStruct.ibi =                     ibiALL; %inter-bout-interval for each trial [cell]
    lickStruct.lickTime =              lickTime; %Time of each lick relative to first lick [array]
    lickStruct.minboutILI =          minboutILI; %Minimum bout ILI used in calculation [number]
    lickStruct.minboutsize =        minboutsize; %Minimum bout size (ms) used in calculation [number]
    lickStruct.totalLick =            totalLick; %Total # of licks for each trial [array]
else
    lickStruct.ili =             ILIdata;
    lickStruct.boutDuration =         [];
    lickStruct.boutLickCount =        [];
    lickStruct.ibi =                  [];
    lickStruct.lickTime =       lickTime;
    lickStruct.minboutILI =   minboutILI;
    lickStruct.minboutsize = minboutsize;
end