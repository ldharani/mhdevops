/***********************************************************************************************************************
 * @author - Ieswarya J
 * @date - 24 Nov 2020
 * @description - Helper class for the debit trigger handler.
*************************************************************************************************************************/

public class DebitTriggerHelper 
{
     //When Balance becomes greater than zero, update Balance Allocated Date with null
    public static void updateAllocatedDate(List<blng__DebitNote__c> newList, Map<Id,blng__DebitNote__c> oldMap) 
    {
        Date todayDate = Date.today();
        Date expirationDate = todayDate.addDays(60);
        
        for(blng__DebitNote__c debitNote : newList)
        {
            if(debitNote.blng__Balance__c <> oldMap.get(debitNote.Id).blng__Balance__c &&
               debitNote.blng__Balance__c == 0)
            {
                debitNote.Balance_Allocated_Expiration_Date__c = expirationDate;
                }
            
            if(oldMap.get(debitNote.Id).blng__Balance__c == 0 && 
               debitNote.blng__Balance__c > 0)
            {
                debitNote.Balance_Allocated_Expiration_Date__c = null;
            }
        }
    }
}