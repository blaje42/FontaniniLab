function MouseIDs = loadsessionsTBT(cohortID,age,conc)

if strcmp(cohortID,'MUT')
    
  if strcmp(age,'12wk')
      if strcmp(conc,'100')
         MouseIDs = {'TDPQF_031','TDPQF_033','TDPQM_033','TDPQM_034','TDPQM_036','TDPQM_037','TDPQM_038'};     
      end
      if strcmp(conc,'50')
         MouseIDs = {};   
      end
  end
  
  if strcmp(age,'20wk')
      if strcmp(conc,'100')
         MouseIDs = {'TDPQF_050','TDPQF_051','TDPQF_049'};     
      end
      if strcmp(conc,'50')
         MouseIDs = {};   
      end  
  end
    
elseif strcmp(cohortID,'CTRL')
        
  if strcmp(age,'12wk')
      if strcmp(conc,'100')
         MouseIDs = {'TDPWF_019','TDPWF_020','TDPWF_017','TDPWM_021','TDPWM_022','TDPWF_044','TDPWM_043','TDPWF_040','TDPWM_045','TDPWF_039','TDPWF_043','TDPWM_044'};     
      end
      if strcmp(conc,'50')
         MouseIDs = {};   
      end      

  end
  
  if strcmp(age,'20wk')
      if strcmp(conc,'100')
         MouseIDs = {'TDPWF_035','TDPWM_039','TDPWM_040'};     
      end
      if strcmp(conc,'50')
         MouseIDs = {'TDPWF_049','TDPWF_046','TDPWM_053','TDPWM_056','TDPWM_055','TDPWM_051','TDPWM_048','TDPWM_041','TDPWF_033','TDPWF_034','TDPWF_037'};   
      end         
  end
 
elseif strcmp(cohortID,'WT')
        
  if strcmp(age,'12wk')
      if strcmp(conc,'100')
         MouseIDs = {'TDPQF_029','TDPQF_032','TDPWF_016','TDPWF_018','TDPWM_023','TDPWM_024'};     
      end
      if strcmp(conc,'50')
         MouseIDs = {};   
      end       
  end
  
  if strcmp(age,'20wk')
      if strcmp(conc,'100')
         MouseIDs = {'TDPQF_052','TDPQF_049'};     
      end
      if strcmp(conc,'50')
         MouseIDs = {'TDPWM_052','TDPWF_036'};   
      end  
  end
    
end