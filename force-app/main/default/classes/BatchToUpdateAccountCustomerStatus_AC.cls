global class BatchToUpdateAccountCustomerStatus_AC implements Database.Batchable<sObject>{ 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Loss_Date__c,Acquisition_date__c,Re_acquisition_date__c,Customer_Status__c,Order_Status__c FROM Account';
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext bc, List<Account> accList){
        Map<Id, Account> updateAcc = new Map<Id, Account>();
        
        for(Account acc : accList){
            if(acc.Loss_Date__c == Null){
                if(acc.Acquisition_date__c != Null){
                    if(acc.Acquisition_date__c.year() == System.Today().year()){
                        acc.Customer_Status__c = 'New'; 
                        updateAcc.put(acc.Id,acc);
                    }else if(acc.Acquisition_date__c.year() == System.Today().year()-1){
                        acc.Customer_Status__c = 'Existing';
                        updateAcc.put(acc.Id,acc);
                    }
                }
                
                if(acc.Re_acquisition_date__c != Null){
                    if(acc.Re_acquisition_date__c.year() == System.Today().year()){
                        acc.Customer_Status__c = 'New'; 
                        updateAcc.put(acc.Id,acc);
                    }else if(acc.Re_acquisition_date__c.year() == System.Today().year()-1){
                        acc.Customer_Status__c = 'Existing'; 
                        updateAcc.put(acc.Id,acc);
                    }
                }
            }  
            if(!test.isRunningTest()){
                List<AccountHistory> accHis = [SELECT OldValue, NewValue, Field, CreatedDate FROM AccountHistory WHERE AccountId =: acc.Id AND Field = 'Order_Status__c' ORDER BY CreatedDate DESC LIMIT 1];
                
                if((accHis[0].OldValue == 'Active' || accHis[0].OldValue == 'Evergreen') && (acc.Order_Status__c == 'Cancelled' || acc.Order_Status__c == 'Expired')){
                    acc.Customer_Status__c = 'Former Sub';
                    updateAcc.put(acc.Id,acc);
                }
            }
        }
        if(!updateAcc.IsEmpty()){
            Update updateAcc.values();
            updateAcc.clear();
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    } 
}