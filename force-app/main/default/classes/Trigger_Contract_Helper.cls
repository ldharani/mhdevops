/**@@
#TRIGGER NAME        :    ContractTrigger
#HANDLER CLASS NAME  :    Trigger_Contract_Handler
#HELPER CLASS NAME   :    Trigger_Contract_Helper
#TEST CLASS          :    ContractTriggerTest
#CREATED BY          :    Serge Kandukuri
#DESCRIPTION         :    This Helper class will handles all the trigger events and handling the appropriate logic.   
@@**/
public class Trigger_Contract_Helper{

    /**@@
    #DESCRIPTION   : Auto-populate Contract fields
    #Paramaters    : trigger.new
    @@**/
    public static void populateContractFields(List<Contract> newList){
        set<Id> sQuoteId = new set<Id>();
        for(Contract cont: newList){
            if(cont.SBQQ__Quote__c != null){
                sQuoteId.add(cont.SBQQ__Quote__c);
            }
        }
        if(!sQuoteId.isEmpty()){
            String strMAIntakeRecTypeIdQuote = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();

            Map<Id, SBQQ__Quote__c> mapContractWithQuote = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__PrimaryContact__c FROM SBQQ__Quote__c WHERE RecordTypeId =: strMAIntakeRecTypeIdQuote AND Id IN: sQuoteId]);
            List<Pricebook2> lstPB2Id = [SELECT Id FROM Pricebook2 WHERE Name = 'M-A Intake Pricebook'];
            for(Contract cont: newList){
                if(mapContractWithQuote != null && mapContractWithQuote.containsKey(cont.SBQQ__Quote__c)){
                    cont.Primary_Contact__c = mapContractWithQuote.get(cont.SBQQ__Quote__c).SBQQ__PrimaryContact__c;
                    
                    if(!lstPB2Id.isEmpty()){
                        cont.SBQQ__AmendmentPricebookId__c = lstPB2Id[0].Id;
                    }
                }
                
                //if(cont.RecordtypeId == strMAIntakeRecTypeId && !lstPB2Id.isEmpty()){
                //system.assertEquals(cont.RecordtypeId, null);
                ///system.assertEquals(1, 2);
                    //cont.SBQQ__AmendmentPricebookId__c = lstPB2Id[0].Id;
                //}
            }
        }
               
    }
}