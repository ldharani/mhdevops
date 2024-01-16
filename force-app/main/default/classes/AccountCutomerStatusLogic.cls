public class AccountCutomerStatusLogic { 
    
    public Static void updateCustomerStatus(Map<Id, Account> newAccMap, Map<Id, Account> oldAccMap){
        Set<Id> accKey = newAccMap.KeySet();
        
        for(Id Key : accKey){
            Account newAcc = newAccMap.get(Key); 
            Account oldAcc = oldAccMap.get(Key); 
            
            if(oldAcc.Acquisition_date__c == Null && newAcc.Acquisition_date__c != Null){
                newAcc.Customer_Status__c = 'New';
            }
            
            if((oldAcc.Order_Status__c == 'Cancelled' || oldAcc.Order_Status__c == 'Expired') && (newAcc.Order_Status__c == 'Active' || newAcc.Order_Status__c == 'Evergreen')){
                if(oldAcc.Acquisition_date__c != Null && newAcc.Re_acquisition_date__c != Null && newAcc.LossDateCheck__c != Null){
                    if(((oldAcc.Acquisition_date__c.Year() == newAcc.Re_acquisition_date__c.Year()) && (newAcc.Re_acquisition_date__c.Year() == newAcc.LossDateCheck__c.Year()))){
                        newAcc.Customer_Status__c = 'New';
                    }
                }
            }
            
            if((oldAcc.Order_Status__c == 'Cancelled' || oldAcc.Order_Status__c == 'Expired') && (newAcc.Order_Status__c == 'Active' || newAcc.Order_Status__c == 'Evergreen')){
                if(oldAcc.Acquisition_date__c != Null && newAcc.Re_acquisition_date__c != Null && newAcc.LossDateCheck__c != Null){
                    
                    if((oldAcc.Acquisition_date__c.Year() < newAcc.LossDateCheck__c.Year()) &&
                       (newAcc.Re_acquisition_date__c.Year() == newAcc.LossDateCheck__c.Year())){
                           newAcc.Customer_Status__c = 'Existing';
                       }
                    
                    if(newAcc.Re_acquisition_date__c.Year() > newAcc.LossDateCheck__c.Year()){
                        newAcc.Customer_Status__c = 'New';  
                    }
                }
            }
            
            if((oldAcc.Order_Status__c == 'Active' || oldAcc.Order_Status__c == 'Evergreen') && (newAcc.Order_Status__c == 'Cancelled' || newAcc.Order_Status__c == 'Expired')){
                //Date firstDayOfMonth = System.today().toStartOfMonth();
                //newAcc.Loss_Date__c = firstDayOfMonth.addMonths(1).addDays(-1);
                newAcc.Customer_Status__c = 'Former Sub';
            }
            
       /*     if(newAcc.Customer_Status__c != Null && oldAcc.Customer_Status__c != newAcc.Customer_Status__c && newAcc.Customer_Status__c == 'New'){
                if(newAcc.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId()){
                    AccountCutomerStatusLogic.caseCreationOnStatusNew(newAccMap, oldAccMap);
                }
            }*/
        }
    }
    
    public Static void caseCreationOnStatusNew(Map<Id, Account> newAccMap, Map<Id, Account> oldAccMap){
        List<Case> caseRec = new List<Case>();
        List<Id> accId = new List<Id>();
        List<Group> queueId = Account_UtilityClass.OrderProductCaseCreationGroup();
        for(Account acc: newAccMap.Values()){
            if(newAccMap.get(acc.Id).Customer_Status__c != oldAccMap.get(acc.Id).Customer_Status__c &&
               newAccMap.get(acc.Id).Customer_Status__c == 'New'){
                   Case caseRecord = new Case();
                   caseRecord.AccountId = newAccMap.get(acc.Id).Id; 
                   caseRecord.Area__c = 'Onboarding';
                   caseRecord.Description = 'New account for Onboarding';
                   caseRecord.Origin = 'Onboarding';
                   caseRecord.OwnerId = queueId[0].Id;
                   caseRecord.Priority = 'Medium';
                   caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case Record').getRecordTypeId();
                   caseRecord.Status = 'New';
                   caseRecord.Sub_Area__c = 'New Customer';
                   caseRecord.Subject = 'Onboarding';
                   caseRec.add(caseRecord);
               }
        }
        if(caseRec.size()>0){
            insert caseRec;
        }
    } 
    
    public Static void updateAcquisitionDate(Map<Id, SBQQ__Quote__c> newOppMap, Map<Id, SBQQ__Quote__c> oldOppMap){
        List<Account> accList =new List<Account>();
        List<Id> accId = new List<Id>();
        
        for(SBQQ__Quote__c oppA : newOppMap.Values()){ 
            if(newOppMap.get(oppA.Id).SBQQ__Status__c !=  oldOppMap.get(oppA.Id).SBQQ__Status__c && newOppMap.get(oppA.Id).SBQQ__Status__c == 'Closed Won' ){
                accId.add(newOppMap.get(oppA.Id).SBQQ__Account__c);
            }
        }
        
        for(Account accRec : [Select Id,Acquisition_date__c FROM Account WHERE Id IN:accId ]){
            if(accRec.Acquisition_date__c == Null){
                //  Date firstDayOfMonth = System.today().toStartOfMonth();
                accRec.Acquisition_date__c = System.today();
                accRec.Customer_Status__c = 'New';
                accList.add(accRec);
            }
        }
        if(accList.size()>0){
            Update accList;
        }
        MDL_RecursionHandler.updateAcquisitionDate = false;
        
    }
}