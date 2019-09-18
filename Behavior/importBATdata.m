function [BATdata, LICKdata] = importBATdata(FileID,nTrialTot)
% Import data for Brief Access Test from Davis Rig (already converted from
% .txt to .xlsx format
%
% INPUTS:
%   FileID (string) = excel file name (exculding format)
%   nTrialTot (array) = number of total trials for BAT protocol run (NOT #
%                       of trials the mouse ran)
%
% OUTPUTS:
%   BATdata (table) = contains table of information for each trial
%   LICKdata (array) = contains lick time onsets (ms relative to first
%                      lick) for each trial (row = trial)

rangeID1 = ['A11:K' num2str(11+nTrialTot)]; %Excel range for 

BATdata = readtable([FileID '.xlsx'], 'Range', rangeID1);

rangeID2 = ['B' num2str(nTrialTot+13) ':ZZ' num2str(nTrialTot+87)];
LICKdata = readmatrix([FileID '.xlsx'],'Range',rangeID2);