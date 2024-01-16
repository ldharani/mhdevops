public class CPQ_Quote_Delete_controller {
    public Id currentRecordId {get;set;}
    public CPQ_Quote_Delete_controller(ApexPages.StandardController controller){
       currentRecordId = ApexPages.CurrentPage().getparameters().get('id'); 
    }
    public Pagereference deleteQuote(){
        system.debug('currentRecordId : '+currentRecordId);
        List<SBQQ__Quote__c> quoteList = [select id from SBQQ__Quote__c where id= :currentRecordId];
        try{
           delete quoteList;
           PageReference retURL = new PageReference('/lightning/page/home');
               retURL.setRedirect(true);
            return retURL;
        }catch(Exception e){
            System.debug(' Exception Exception: '+e.getMessage());
            return null;
        }
        
        //return null;
    }
}