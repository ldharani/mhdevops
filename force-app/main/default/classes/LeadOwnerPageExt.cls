/* 
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-8429    Lakshmi	   20-Jan-2023	John			<T01>   Redirect the page to detail page of Lead once save is successful	 
************************************************************************************************************************
*/
public class LeadOwnerPageExt {
    
    public Boolean sendEmail{get;set;}
    public lead l{get;set;}
    Id oldownerId;
    public Boolean error{get;set;}
    
    public LeadOwnerPageExt(ApexPages.StandardController ctrl){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        l = (Lead)ctrl.getRecord();
        error = false;
        sendEmail = false;
        oldownerId = l.OwnerId;
        
         if(profileName ==  'MH Sales Rep'  || profileName == 'Ngage HS Sales' ){
            error = true; 
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Insufficient Privileges to change the Ownership '));
        }
        else if(l!=null){
          system.debug('@@@@@Check 1 ');
             Id currentUserprofileId = UserInfo.getProfileId();
             String currUserProfileName = [Select Name from Profile where Id =: currentUserprofileId].Name;
              for(Lead ld  : [Select id, Name, RecordType.DeveloperName From Lead Where ID =: l.id]){
                      boolean profileCheck = checkProfile(ld.RecordType.DeveloperName, currUserProfileName);
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
      if(rectypeDevName == 'Nolo_Leads' && profName != 'MH Sales Rep' && profName != 'Fulfillment Ops Rep' &&  profName != 'System Administrator' &&  profName != 'Data Governor'
         &&  profName != 'MH Marketing' &&  profName != 'Marketing Team' &&  profName != 'Sales Support' &&  profName != 'MN Marketing' &&  profName != 'Marketing User'){
            system.debug('@@@@@Check 3 ');
            return false;
       }
      else if(rectypeDevName == 'M_NG_Leads' && profName != 'Ngage Sales' && profName != 'Ngage Sales Management' &&  profName != 'System Administrator'  &&  profName != 'Data Governor'
         &&  profName != 'MH Marketing' &&  profName != 'Marketing Team' &&  profName != 'Sales Support' &&  profName != 'MN Marketing' &&  profName != 'Marketing User'){
         system.debug('@@@@@Check 4 ');
         return false;
     }
     else if(rectypeDevName == 'M_N_Leads' && profName != 'MN Sales Reps' && profName != 'MN Ad Services' &&  profName != 'System Administrator'  && profName != 'M-A Intake Sales'
         &&  profName != 'MH Marketing' &&  profName != 'Marketing Team' &&  profName != 'Sales Support' &&  profName != 'MN Marketing' &&  profName != 'Marketing User' &&  profName != 'Data Governor'){
         system.debug('@@@@@Check 5 ');
         return false;
     }
     
       return true;

        
        
    }
    
    public PageReference SaveRecord(){
        Database.SaveResult sr;
        
        sr = LeadOwnerChangeExtHelper.updateLeadOwner(l, sendEmail);
        if(sr.isSuccess()){
            
            if(userInfo.getUiThemeDisplayed() == 'Theme3'){
                pageReference lPage = new ApexPages.standardController(l).view();
                return lPage;
            }
            else{
                pageReference lPage = new ApexPages.standardController(l).view(); //<T01>
                return lpage; //<T01>
            }
        }
        
        else{
            for(Database.Error err : sr.getErrors()){
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, err.getMessage()));
                
            }
            return null;
        }
        
        
        
    }

}