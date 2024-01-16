/**@@
#APEX CLASS NAME     :    SchBatch_generateTokenforDMController
#TEST CLASS          :    SchBatch_generateTokenforDMControllerTest
#DESCRIPTION         :    This Schedular Class is used to Schedule batch class - Batch_generateTokenforDMController 
@@**/
global class SchBatch_generateTokenforDMController implements schedulable{
    /**@@
        #DESCRIPTION   : Generate Tokenization
        #Paramaters    : SchedulableContext sc
    @@**/
    global void execute(SchedulableContext sc){
       Set<Id> sPaymentMethodId = new Set<Id>();
        for(blng__PaymentMethod__c  ppp : [SELECT ID FROM blng__PaymentMethod__c WHERE Payment_Profile_ID__c = null]){
            sPaymentMethodId.add(ppp.Id);
        }
        Id batchJobId = Database.executeBatch(new Batch_generateTokenforDMController(sPaymentMethodId), 100);
        
    }// END OF EXECUTE METHOD
}// END OF CLASS