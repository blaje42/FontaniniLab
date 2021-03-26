function [TRIALdata, LICKdata,nTrialTot] = importDAVISdata(FileID)
% Import data from Davis Rig (already converted from .txt to .xlsx format)
%
% INPUTS:
%   FileID (string) = excel file name (exculding .xlsx)
%   nTrialTot (array) = number of total trials for BAT protocol run (NOT #
%                       of trials the mouse ran)
%
% OUTPUTS:
%   TRIALdata (table) = contains table of information for each trial
%   LICKdata (array) = contains trial # (column 1) and lick time ILIs (ms relative to first
%                      lick) for each trial (row = trial)

nTrialTot = xlsread([FileID '.xlsx'],'B10:B10');

rangeID1 = ['A11:K' num2str(11+nTrialTot)]; %Excel range for 
TRIALdata = readtable([FileID '.xlsx'], 'Range', rangeID1);

rangeID2 = ['A' num2str(nTrialTot+13) ':AZZ' num2str(2*nTrialTot+12)];
LICKdata = xlsread([FileID '.xlsx'],rangeID2);
%LICKdata = readmatrix([FileID '.xlsx'],'Range',rangeID2); %This is skipping the first row for some reason so I switched to xlsread...so if you need to use it find a fix for it