function MouseIDs = loadsessionsBAT(cohortID,age)

if strcmp(cohortID,'MUT')
    
  if strcmp(age,'12wk')
      MouseIDs = {'TDPQM_002', 'TDPQM_008', 'TDPQF_005', 'TDPQF_010', 'TDPQF_011','TDPQF_015','TDPQF_016',...
      'TDPQF_017'};     
% %        MouseIDs = {'TDPQM_002', 'TDPQM_008', 'TDPQF_010', 'TDPQF_011','TDPQF_015','TDPQF_016',...
% %       'TDPQF_017'}; 
  end
  
  if strcmp(age,'20wk')
      MouseIDs = {'TDPQM_002','TDPQM_008','TDPQF_005', 'TDPQM_010','TDPQF_010','TDPQF_011','TDPQM_013','TDPQM_016'};      
  end
    
elseif strcmp(cohortID,'CTRL')
        
  if strcmp(age,'12wk')
      MouseIDs = {'TDPWF_002','TDPWM_016','TDPWM_001','TDPWM_002','TDPWM_005','TDPWM_011','TDPWF_005','TDPWF_006','TDPWF_007','TDPWF_008',...
      'TDPWF_011'};       
% %         MouseIDs = {'TDPWF_002','TDPWM_016','TDPWM_001','TDPWM_002','TDPWM_005','TDPWM_011','TDPWF_005','TDPWF_006','TDPWF_007',...
% %       'TDPWF_011'};   
  end
  
  if strcmp(age,'20wk')
      MouseIDs = {'TDPWF_002','TDPWM_016','TDPWM_001','TDPWM_002','TDPWM_005','TDPWM_011','TDPWF_007','TDPWF_008','TDPWF_011'};         
  end
 
elseif strcmp(cohortID,'WT')
        
  if strcmp(age,'12wk')
      MouseIDs = {'TDPQF_006', 'TDPQM_011', 'TDPWF_001','TDPQF_012','TDPQM_015','TDPQF_018','TDPQF_019'};     
  end
  
  if strcmp(age,'20wk')
      MouseIDs = {'TDPQF_001','TDPQF_006','TDPQM_011','TDPWF_001','TDPQF_012','TDPQM_015',};
  end
    
end