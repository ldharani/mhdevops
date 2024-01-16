global class BatchToUpdateAccountOrderStatus_AC implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,AccountId,CreatedDate,Status__c,SBQQ__Evergreen__c,Cancelled__c FROM Contract WHERE AccountId != Null ORDER BY CreatedDate ASC';
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext bc, List<Contract> conRec){
        Map<Id,Contract> lastConMap = new Map<Id,Contract>();
        for(Contract lastCon : conRec){
            lastConMap.put(lastCon.AccountId,lastCon);
        }
        System.debug('lastConMap ' +lastConMap);
        
        Map<Id,List<Contract>> conMap = new Map<Id,List<Contract>>();
        for(Contract conA: conRec){
            if(conMap.containsKey(conA.AccountId) && conMap.get(conA.AccountId) != null) {
                List<Contract> conList = conMap.get(conA.AccountId);
                conList.add(conA);
                conMap.put(conA.AccountId,conList); 
            }   
            else {
                conMap.put(conA.AccountId, new List<Contract> {conA});
            }
        }
        
        System.debug('conMap ' + conMap);
        
        Map<Id, Account> updateAcc = new Map<Id, Account>();
        
        for(Contract conB: lastConMap.Values()){
            Id conId = conB.Id;
            Boolean active = False;
            Boolean amendInProgress = False;
            Boolean amended = False;
            Boolean renewInProgress = False;
            Boolean rebaseInProgress = False;
            Boolean evergreen = False;
            Boolean evergreenInProgress = False;
            Boolean cancelled = False;
            Boolean expired = False;  
            if(!conMap.IsEmpty()){
                if(conMap.containskey(conB.AccountId)){
                    for(Contract conC: conMap.get(conB.AccountId)){
                        if(conC.Status__c == 'Active' && conC.SBQQ__Evergreen__c == false){
                            active = True; 
                        }else if(conC.Status__c == 'Amend in progress'){
                            amendInProgress = True; 
                        }else if(conC.Status__c == 'Amended'){
                            amended = True; 
                        }else if(conC.Status__c == 'Renew in Progress'){ 
                            renewInProgress = True; 
                        }else if(conC.Status__c == 'Rebase in progress'){
                            rebaseInProgress = True; 
                        }else if(conC.Status__c == 'Evergreen' || (conC.SBQQ__Evergreen__c == true && conC.Cancelled__c == false)){
                            evergreen = True; 
                        }else if(conC.Status__c == 'Evergreen in progress'){
                            evergreenInProgress = True; 
                        }else if(conC.Status__c == 'Cancelled'){
                            cancelled = True; 
                        }else if(conC.Status__c == 'Expired'){
                            expired = True; 
                        }
                    }
                }
            }
            List<ContractHistory> conHis = [SELECT OldValue, NewValue, Field, CreatedDate FROM ContractHistory where ContractId =: conB.Id AND Field = 'Status__c' ORDER BY CreatedDate DESC LIMIT 1];
            
            Account accRecA = new Account(Id = conB.AccountId);
            if((conB.Status__c == 'Amend in progress' || conB.Status__c == 'Renew in Progress' || conB.Status__c == 'Rebase in progress' || conB.Status__c == 'Cancel in progress' || conB.Status__c == 'Mid-term in progress' || conB.Status__c == 'Evergreen in progress') && conHis[0].OldValue == 'Evergreen'){
                accRecA.Order_Status__c = 'Evergreen'; 
                updateAcc.put(accRecA.Id,accRecA);
            }else if(evergreen == True){
                accRecA.Order_Status__c = 'Evergreen'; 
                updateAcc.put(accRecA.Id,accRecA);
            }else if((conB.Status__c == 'Amend in progress' || conB.Status__c == 'Renew in Progress' || conB.Status__c == 'Rebase in progress' || conB.Status__c == 'Cancel in progress' || conB.Status__c == 'Mid-term in progress' || conB.Status__c == 'Evergreen in progress') && conHis[0].OldValue == 'Active'){
                accRecA.Order_Status__c = 'Active'; 
                updateAcc.put(accRecA.Id,accRecA);
            }else if(active == True || amended == True){
                accRecA.Order_Status__c = 'Active';
                updateAcc.put(accRecA.Id,accRecA);
            }else if(cancelled == True && (active == False && amendInProgress == False && amended == False && renewInProgress == False && rebaseInProgress == False && evergreen == False)){
                accRecA.Order_Status__c = 'Cancelled';
                updateAcc.put(accRecA.Id,accRecA);
            }else if(expired == True && (active == False && amendInProgress == False && amended == False && renewInProgress == False && rebaseInProgress == False && evergreen == False)){
                accRecA.Order_Status__c = 'Expired'; 
                updateAcc.put(accRecA.Id,accRecA);
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