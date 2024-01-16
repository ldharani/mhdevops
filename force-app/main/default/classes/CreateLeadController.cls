/***********************************************
 * Author       : Akash
 * Description  : Create lead 
 * Created Date : 06/06/2017
 * *************************************************/


public class CreateLeadController {
   
    public Id conId{get;set;}
    public contact con{get;set;}
    
    public CreateLeadController(){
        conId = ApexPages.currentPage().getParameters().get('Recid');
        con = [select id, AccountId
                      From contact
                      where Id=:conId];
    }
    
     public PageReference leadCreation() {
        String leadId = CreateLeadFromContact.createLead(conId);
         system.debug('@@@Lead Id'+ leadId);
        PageReference pageRef = new PageReference('/' + leadId ); 
        pageRef.setRedirect(true);
        
        return pageRef;
    }  
     

}