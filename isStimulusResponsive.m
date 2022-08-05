function [pResponsive, dirResponsive] = isStimulusResponsive(FR,params,stimType)

if strcmp(stimType,'delay') || strcmp(stimType,'choice')
   tt = round(params.lateral.timeWin(1):params.lateral.binsize:params.lateral.timeWin(2),3);
   baseTimeWin = params.lateral.baseTimeWin;
   stimidx = find(tt == params.lateral.([stimType 'TimeWin'])(1)):find(tt == params.lateral.([stimType 'TimeWin'])(2));
else
    tt = round(params.central.timeWin(1):params.central.binsize:params.central.timeWin(2),3);
    baseTimeWin = params.central.baseTimeWin;
    stimidx = find(tt == params.central.([stimType 'TimeWin'])(1)):find(tt == params.central.([stimType 'TimeWin'])(2));
end
tt = tt(1:end-1);

baseidx = find(tt == baseTimeWin(1)):find(tt == baseTimeWin(2));



% % % pResponsive = signrank(FR(baseidx),FR(stimidx));

criterion = 5;

if mean(FR(stimidx)) > mean(FR(baseidx)) + criterion*std(FR(baseidx)) || mean(FR(stimidx)) < mean(FR(baseidx)) - criterion*std(FR(baseidx))
    pResponsive = 1;
    if mean(FR(stimidx)) > mean(FR(baseidx)) + criterion*std(FR(baseidx))
        dirResponsive = 1;
    elseif mean(FR(stimidx)) < mean(FR(baseidx)) - criterion*std(FR(baseidx))
        dirResponsive = -1;
    end
else 
    pResponsive = 0;
    dirResponsive = 0;
end



