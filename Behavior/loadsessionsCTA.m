function MouseIDs = loadsessionsCTA(cohortID,age)

if strcmp(cohortID,'MUT')
    
  if strcmp(age,'12wk')
      MouseIDs = {'TDPQF_035','TDPQF_037','TDPQF_038'}; 
  end
  
  if strcmp(age,'20wk')
      MouseIDs = {};      
  end
    
elseif strcmp(cohortID,'CTRL')
        
  if strcmp(age,'12wk')
      MouseIDs = {};        
  end
  
  if strcmp(age,'20wk')
      MouseIDs = {'TDPWF_054','TDPWF_055','TDPWF_056','TDPWM_058'};         
  end
 
elseif strcmp(cohortID,'WT')
        
  if strcmp(age,'12wk')
      MouseIDs = {'TDPQM_020','TDPQM_021','TDPQM_022'};       
  end
  
  if strcmp(age,'20wk')
      MouseIDs = {'TDPQF_044','TDPQF_045','TDPWM_057'};
  end
  
elseif strcmp(cohortID,'CONTROL') %Control condition (sodium chloride instead of LiCl)
    if strcmp(age,'13wk')
    
        MouseIDs = {'WT001','TDPQF_024','TDPQM_028'};
        
    end
    
end