function lickStruct = calcLickStructure(lickILI, minboutsize, minboutILI)

nTrials = size(lickILI,1);

%Convert lick ILI into time relative to first lick
lickTime = NaN(nTrials,size(lickILI,2)+1);
lickTime(:,1) = zeros(nTrials,1); %Time will be relative to first lick
for n = 1:size(lickILI,2)     
    lickTime(:,n+1) = lickILI(:,n) + lickTime(:,n);
end


if nargin < 2
    minboutILI = 500;  % ILI defining new licking bout is 500 ms
end

for trial = 1%:nTrials
    boutstart = find(lickILI(trial,:) > minboutILI);     % inter lick interval is bigger than XXX ms, which means a new licking bouts
    boutIDX = cell(1,length(boutstart));
    if ~isempty(boutstart)
        for i = 1:length(boutstart)
            if i == 1
                boutIDX{1} = 1:boutstart(1)-1;
                ibi(i) = lickILI(trial,boutstart(1)); % inter bout interval (time since last lick, initiating new bout)
            else
                boutIDX{i} = boutstart(i-1) + 1:boutstart(i) - 1;
                ibi(i) = lickILI(trial,boutstart(i));
            end
        end
    else
        boutIDX{1} = 1:length(lickILI(trial,:)); %If empty, we have a single bout which includes all licks
        ibi = nan;
    end
    
    
    % Remove the bouts with less than XXX licks
    lickSpont = [];
    for i = 1:length(boutIDX)
        if length(boutIDX{i}) < minboutsize
           randlick = boutIDX{i};
           boutIDX{i} = [];
           lickSpont = [lickSpont randlick]; %%% Do I need to keep this??? Not including other licks... %%%
        end  
    end
    boutIDX = boutIDX(~cellfun('isempty',boutIDX));

    % lickSpont=ili(lickSpont); % timestamps of all Non-bouts licks
    for i = 1:length(boutIDX)
        boutduration(i) = sum(lickILI(boutIDX{i})); % Total duration of each bout (ms)
        boutLickCount(i) = length(boutIDX{i}) + 1; % Total lick count of each bout
    end

end


if ~isempty(boutstart)
    
    lickStuct.ili =               lickILI;
    lickStuct.boutduration =   boutduration;
    lickStuct.boutLickCount = boutLickCount;
    lickStuct.ibi =                   ibi;
    lickStruct.lickTime =        lickTime;
    lickStruct.minboutILI = minboutILI;
    lickStruct.minboutsize = minboutsize;
else
    lickStuct.ili =        lickILI;
    lickStuct.boutduration =    [];
    lickStuct.boutLickCount =   [];
    lickStuct.ibi =             [];
    lickStruct.lickTime = lickTime;
    lickStruct.minboutILI = minboutILI;
    lickStruct.minboutsize = minboutsize;
end