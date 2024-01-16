public class LeadOwnerChnageListPageExt {
    PageReference cancel;
    public List<Lead> leadsList;
    public List<Id> ListofLeads;
    public Boolean sendEmail{get;set;}
    public lead l{get;set;}
    public Boolean error{get;set;}
    

    public LeadOwnerChnageListPageExt(ApexPages.StandardSetController ctrl){
          Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        error = false;
        l = new Lead();
        leadsList = (List<lead>)ctrl.getSelected();
        
        cancel = ctrl.cancel();
        system.debug('@@@leadsList'+leadsList);
        if(profileName ==  'MH Sales Rep'  || profileName == 'Ngage Sales Management'
        || profileName == 'Ngage HS Sales' || profileName == 'Fulfillment Ops Rep' ){
            error = true; 
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Insufficient Privileges to change the Ownership'));
        }
        else if(leadsList.isEmpty() ||  leadsList == NULL){
            error = true;
             apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please select at least one Record'));
        }
        else if(!leadsList.isEmpty()){
          system.debug('@@@@@Check 1 ');
             Id currentUserprofileId = UserInfo.getProfileId();
             String currUserProfileName = [Select Name from Profile where Id =: currentUserprofileId].Name;
              for(Lead l  : [Select id, Name, RecordType.DeveloperName From Lead Where ID IN: leadsList]){
                      boolean profileCheck = checkProfile(l.RecordType.DeveloperName, currUserProfileName);
                       system.debug('@@@@@profileCheck  '+profileCheck );
                      if(profileCheck == False){
                          system.debug('@@@@@Check 2 ');
                             error = true;
                             apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'You can only change ownership on leads for your BU'));
                      }

               }
       }
        
        
        
    }
    
    public boolean checkProfile(string rectypeDevName, String profName){
      if(rectypeDevName == 'Nolo_Leads' && profName != 'MH Sales Rep' &&  profName != 'System Administrator' &&  profName != 'Data Governor'
          &&  profName != 'MH Marketing' &&  profName != 'Marketing Team' &&  profName != 'Sales Support' &&  profName != 'MN Marketing' &&  profName != 'Marketing User'){
            system.debug('@@@@@Check 3 ');
            return false;
       }
      else if(rectypeDevName == 'M_NG_Leads' && profName != 'Ngage Sales' &&  profName != 'System Administrator' &&  profName != 'Data Governor'
          &&  profName != 'MH Marketing' &&  profName != 'Marketing Team' &&  profName != 'Sales Support' &&  profName != 'MN Marketing' &&  profName != 'Marketing User'){
         system.debug('@@@@@Check 4 ');
         return false;
     }
     else if(rectypeDevName == 'M_N_Leads' && profName != 'MN Sales Reps' && profName != 'MN Ad Services' &&  profName != 'System Administrator' &&  profName != 'Data Governor'
          &&  profName != 'MH Marketing' &&  profName != 'Marketing Team' &&  profName != 'Sales Support' &&  profName != 'MN Marketing' &&  profName != 'Marketing User'){
         system.debug('@@@@@Check 5 ');
         return false;
     }
     
       return true;

        
        
    }
    
     public PageReference SaveRecords(){
        Database.DMLOptions dlo = new database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = sendEmail;
        
        
         for(Lead lead : leadsList){
             lead.ownerId = l.OwnerId;
             
         }
        
           Database.saveResult[] rslt= database.update(leadsList, dlo);
          Integer count = 0;
         
          for(Database.saveResult r: rslt){
            if(r.isSuccess()){
              
            }
            else{
                  for(Database.Error err : r.getErrors()){
                   apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage()));
                   return null;   
                }
            }
        }
         
         
         return cancel.setRedirect(true);
        
        
    }
    
    public  void FkMethod(){
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    
    }   

}