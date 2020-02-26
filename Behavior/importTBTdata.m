function [STIMdata, TRIALdata] = importTBTdata(FileID,nTrials,nContextHab)

rangeID1 = ['A' num2str(14+nContextHab) ':J' num2str(14+nTrials)]; %Excel range for 
TRIALdata = readtable([FileID '.xlsx'], 'Range', rangeID1);

rangeID2 = ['A5:C7'];
STIMdata = readtable([FileID '.xlsx'], 'Range', rangeID2);

