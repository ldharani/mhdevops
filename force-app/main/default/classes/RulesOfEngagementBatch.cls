global class RulesOfEngagementBatch implements Database.Batchable<sObject>,Database.stateful, Database.AllowsCallouts{
    global String query;
    global User u;
    global Map<Id, List<String>> parentAccIdVsReasonMap;
    global Map<Id, List<String>> conIdVsReasonMap;
    
    global RulesOfEngagementBatch() {
        u = [select Id, username from User where Id = :UserInfo.getUserId()];
        query ='';
        parentAccIdVsReasonMap = new Map<Id,List<String>>();
        conIdVsReasonMap = new Map<Id,List<String>>();
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select id, RecordType.Name,Acquisition_date__c ,Re_acquisition_date__c,Sub_Type__c,Credit_Status__c ,Least_Service_End_Date__c,Active_Account_Binary__c , ParentId, Start_Restart_Date__c,Failed_CC_Total_Owed__c,Parent.ParentId '+
                'from Account ' + 
          'Where (RecordType.Name = \'M-H Account\' OR RecordType.Name = \'M-N Account\' OR RecordType.Name = \'M-NG Account\' OR RecordType.Name = \'M-A Atty Account\') '; 
         //'Where (RecordType.Name = \'M-A Atty Account\' AND id=\'0011b00000hjsP0\') '; 
        if(Test.isRunningTest()) {
            query += ' LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        System.debug('@@@@@@@Scope--------------->'+scope);
        
        String reasonForNotSolicit;
        date todayDate = Date.Today();
        Set<Id> parentAccIds = new Set<Id>();   
        Set<Id> parntAccIdsFromBatch = new Set<Id>();
        List<Contact> updateContactList = new List<Contact>();
       
        
        for(Account acc: scope){
            
            if(acc.RecordType.Name == 'M-H Account'){
                parntAccIdsFromBatch.add(acc.ParentId);
                System.debug('@@@@@@@@@  Re - Acquisition date--------->'+acc.Re_acquisition_date__c);
                if(acc.Re_acquisition_date__c!=NULL){
                    if(acc.Re_acquisition_date__c >= Date.Today() - 120 && Date.Today() >= acc.Re_acquisition_date__c){
                        //reasonForNotSolicit = 'M-H Business Re-Acquired in last 4 months-----.' ;
                        parentAccIds.add(acc.ParentId);
                        if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                            parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'MH has Re-acquired the business in past 4 months'});
                        }else{
                            parentAccIdVsReasonMap.get(acc.ParentId).add('MH has Re-acquired the business in past 4 months');
                        }
                    }
                }
                else{
                    System.debug('@@@@@@@@@ Acquisition date--------->'+acc.Acquisition_date__c);
                    if(acc.Re_acquisition_date__c == NULL && acc.Acquisition_date__c!=NULL){
                        if(acc.Acquisition_date__c >= Date.Today() - 120 && Date.Today() >= acc.Acquisition_date__c ){
                            //reasonForNotSolicit += 'M-H Business Acquired in last 4 months.' ;
                            parentAccIds.add(acc.ParentId);
                            if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                                parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'MH has acquired the business in past 4 months.'});
                            }else{
                                parentAccIdVsReasonMap.get(acc.ParentId).add('MH has acquired the business in past 4 months.');
                            }
                        }
                    }
                }
                

                if(acc.RecordType.Name == 'M-H Account' && acc.Sub_Type__c!=NULL ){
                    if(acc.Sub_Type__c == 'Elite' ){
                        //reasonForNotSolicit = 'Elite M-H Business Account.' ;
                        parentAccIds.add(acc.ParentId);
                        if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                            parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'MH Elite Account.'});
                        }else{
                            parentAccIdVsReasonMap.get(acc.ParentId).add('MH Elite Account.');
                        }
                    }
                }
                
                if(acc.RecordType.Name == 'M-H Account' && acc.Credit_Status__c!=NULL ){
                    if(acc.Credit_Status__c == 'Bad Debt' || acc.Credit_Status__c == 'Past Due'){
                        //reasonForNotSolicit = 'Elite M-H Business Account.' ;
                        parentAccIds.add(acc.ParentId);
                        if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                            parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'MH Account in Bad Debt or Past Due.'});
                        }else{
                            parentAccIdVsReasonMap.get(acc.ParentId).add('MH Account in Bad Debt or Past Due.');
                        }
                    }
                }
                
                System.debug('@@@@@@@@ Account Least Service End Date-----------------> '+acc.Least_Service_End_Date__c);
                if(acc.RecordType.Name == 'M-H Account' && acc.Least_Service_End_Date__c!=NULL &&  Date.Today()>= acc.Least_Service_End_Date__c - 90 && Date.Today()<= acc.Least_Service_End_Date__c){
                    //reasonForNotSolicit = 'Elite M-H Business Account.' ;
                    parentAccIds.add(acc.ParentId);
                    if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                        parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'MH contract expires in next 3 months.'});
                    }else{
                        parentAccIdVsReasonMap.get(acc.ParentId).add('MH contract expires in next 3 months.');
                    }
                    
                }
                
                
                
            }
            
            if(acc.RecordType.Name == 'M-N Account'){
                parntAccIdsFromBatch.add(acc.ParentId);
                System.debug('@@@@@@@@@ADSDADASD  Re - Acquisition date--------->'+acc.Re_acquisition_date__c);
                if(acc.Re_acquisition_date__c!=NULL){
                    if(acc.Re_acquisition_date__c >= Date.Today() - 120 && Date.Today() >= acc.Re_acquisition_date__c ){
                        //reasonForNotSolicit = 'M-H Business Re-Acquired in last 4 months-----.' ;
                        parentAccIds.add(acc.ParentId);
                        if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                            parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'Nolo has Re-acquired the business in past 4 months.'});
                        }else{
                            parentAccIdVsReasonMap.get(acc.ParentId).add('Nolo has Re-acquired the business in past 4 months');
                        }
                    }
                }
                //
                else{
                    System.debug('@@@@@@@@@ Acquisition date--------->'+acc.Acquisition_date__c);
                    if(acc.Re_acquisition_date__c == NULL && acc.Acquisition_date__c!=NULL){
                        if(acc.Acquisition_date__c >= Date.Today() - 120 && Date.Today() >= acc.Acquisition_date__c){
                            //reasonForNotSolicit += 'M-H Business Acquired in last 4 months.' ;
                            parentAccIds.add(acc.ParentId);
                            if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                                parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'Nolo has acquired the business in past 4 months.'});
                            }else{
                                parentAccIdVsReasonMap.get(acc.ParentId).add('Nolo has acquired the business in past 4 months.');
                            }
                        }
                    }
                }
            }
            
            if(acc.RecordType.Name == 'M-NG Account'){
                parntAccIdsFromBatch.add(acc.ParentId);
                System.debug('@@@@@@@@@ADSDADASD  Re - Acquisition date--------->'+acc.Re_acquisition_date__c);
                if(acc.Re_acquisition_date__c!=NULL){
                    if(acc.Re_acquisition_date__c >= Date.Today() - 120 && Date.Today() >= acc.Re_acquisition_date__c ){
                        //reasonForNotSolicit = 'M-H Business Re-Acquired in last 4 months-----.' ;
                        parentAccIds.add(acc.ParentId);
                        if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                            parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'Ngage has Re-acquired the business in past 4 months.'});
                        }else{
                            parentAccIdVsReasonMap.get(acc.ParentId).add('Ngage has Re-acquired the business in past 4 months.');
                        }
                    }
                }
                //
                else{
                    System.debug('@@@@@@@@@ Acquisition date--------->'+acc.Acquisition_date__c);
                    if(acc.Re_acquisition_date__c == NULL && acc.Acquisition_date__c!=NULL){
                        if(acc.Acquisition_date__c >= Date.Today() - 120 && Date.Today() >= acc.Acquisition_date__c ){
                            //reasonForNotSolicit += 'M-H Business Acquired in last 4 months.' ;
                            parentAccIds.add(acc.ParentId);
                            if(!parentAccIdVsReasonMap.containskey(acc.ParentId)){
                                parentAccIdVsReasonMap.put(acc.ParentId, new List<String>{'Ngage has acquired the business in past 4 months.'});
                            }else{
                                parentAccIdVsReasonMap.get(acc.ParentId).add('Ngage has acquired the business in past 4 months.');
                            }
                        }
                    }
                }
            }
            
            
            if(acc.RecordType.Name == 'M-A Atty Account'){
                parntAccIdsFromBatch.add(acc.Parent.ParentId);
                System.debug('@@@@@@@@@  Start/Restart date--------->'+acc.Start_Restart_Date__c);
                if(acc.Start_Restart_Date__c!=NULL){
                    if(acc.Start_Restart_Date__c>= Date.Today() - 120 && Date.Today() >= acc.Start_Restart_Date__c && acc.Active_Account_Binary__c == 1){
                        System.debug('Falls in the Avvo criteria------------------------>'+acc.Start_Restart_Date__c);
                        //reasonForNotSolicit = 'M-H Business Re-Acquired in last 4 months-----.' ;
                        parentAccIds.add(acc.Parent.ParentId);
                        if(!parentAccIdVsReasonMap.containskey(acc.Parent.ParentId)){
                            parentAccIdVsReasonMap.put(acc.Parent.ParentId, new List<String>{'Avvo has acquired the business in past 4 months.'});
                        }else{
                            parentAccIdVsReasonMap.get(acc.Parent.ParentId).add('Avvo has acquired the business in past 4 months.');
                        }
                    }
                }

                if(acc.Failed_CC_Total_Owed__c!=NULL ){
                    if(acc.Failed_CC_Total_Owed__c > 0 ){
                        System.debug('Avvo account owe amount----------------->'+acc.Failed_CC_Total_Owed__c);
                        //reasonForNotSolicit = 'Elite M-H Business Account.' ;
                        parentAccIds.add(acc.Parent.ParentId);
                        if(!parentAccIdVsReasonMap.containskey(acc.Parent.ParentId)){
                            parentAccIdVsReasonMap.put(acc.Parent.ParentId, new List<String>{'Avvo Account Past due.'});
                        }else{
                            parentAccIdVsReasonMap.get(acc.Parent.ParentId).add('Avvo Account Past due.');
                        }
                    }
                }
                
                if(acc.Sub_Type__c!=NULL){
                    if(acc.Sub_Type__c == 'Elite' ){
                        //reasonForNotSolicit = 'Elite M-H Business Account.' ;
                        parentAccIds.add(acc.Parent.ParentId);
                        if(!parentAccIdVsReasonMap.containskey(acc.Parent.ParentId)){
                            parentAccIdVsReasonMap.put(acc.Parent.ParentId, new List<String>{'Avvo Elite Account.'});
                        }else{
                            parentAccIdVsReasonMap.get(acc.Parent.ParentId).add('Avvo Elite Account.');
                        }
                    }
                }
            }
            
            
            
        }
        System.debug('@@@@@@@@@@parentAccIdVsReasonMap------------>'+parentAccIdVsReasonMap);
        
        
        //List<Contact> contactList = [Select id, name,Last_Nolo_Sales_Activity_Date__c,Last_Ngage_Sales_Activity_Date__c,AccountId,Is_under_ROE__c,ROE_Update_Date__c,Reason_for_Not_Solicit__c,Last_MH_Sales_Activity_Date__c From Contact FOR UPDATE];
        
       // System.debug('Contact List to update----------->'+contactList);
       Map<Id, List<Contact>> mapParentIdVsContList = new Map<Id, List<Contact>>();
       List<Contact> contactList = new List<Contact>();
       
        for(Contact con: [Select id, name,Last_Nolo_Sales_Activity_Date__c,Last_Ngage_Sales_Activity_Date__c,AccountId,Is_under_ROE__c,ROE_Update_Date__c,Reason_for_Not_Solicit__c,Last_MH_Sales_Activity_Date__c From Contact WHERE AccountId IN: parntAccIdsFromBatch]){
            
           /* if(mapParentIdVsContList.containskey(con.AccountId)){
                mapParentIdVsContList.get(con.AccountId).add(con);
            }else{
                mapParentIdVsContList.put(con.AccountId, new List<Contact> {con});
            }*/
            contactList.add(con);
            
        }

        if(!contactList.isempty() && contactList!=NULL){            
        for(Contact con: contactList){
            if(con.Last_MH_Sales_Activity_Date__c!=NULL && con.Last_MH_Sales_Activity_Date__c>= Date.Today() - 30){
                
                    if(!conIdVsReasonMap.containskey(con.Id)){
                        System.debug('== inside the con id map id----------->');
                        conIdVsReasonMap.put(con.id, new List<String>{'Prospect actively worked by MH in past 30 days.'});
                    }else{
                        
                        List<String> activityReasons = conIdVsReasonMap.get(con.Id);
                    
                        if(activityReasons.Contains('Prospect actively worked by MH in past 30 days.')){
                            
                        }else{
                            conIdVsReasonMap.get(con.Id).add('Prospect actively worked by MH in past 30 days.');
                        }
                        
                    }     
                
            }
            
            if(con.Last_Ngage_Sales_Activity_Date__c!=NULL && con.Last_Ngage_Sales_Activity_Date__c>= Date.Today() - 30){
                
             
                if(!conIdVsReasonMap.containskey(con.Id)){
                    System.debug('== inside the con id map id----------->');
                    conIdVsReasonMap.put(con.id, new List<String>{'Prospect actively worked by Ngage in past 30 days.'});
                }else{
                    
                    List<String> activityReasons = conIdVsReasonMap.get(con.Id);
                
                    if(activityReasons.Contains('Prospect actively worked by Ngage in past 30 days.')){
                        
                    }else{
                        conIdVsReasonMap.get(con.Id).add('Prospect actively worked by Ngage in past 30 days.');
                    }
                    
                }    
            }
            
            if(con.Last_Nolo_Sales_Activity_Date__c!=NULL && con.Last_Nolo_Sales_Activity_Date__c>= Date.Today() - 30){
              
                System.debug('@@@@@@@@@@inside the conId map Ngage condition-0------------>');
                if(!conIdVsReasonMap.containskey(con.Id)){
                    System.debug('== inside the con id map id----------->');
                    conIdVsReasonMap.put(con.id, new List<String>{'Prospect actively worked by Nolo in past 30 days.'});
                }else{
                    System.debug('== inside the con id else nageg map id----------->');
                    List<String> activityReasons = conIdVsReasonMap.get(con.Id);
                
                    if(activityReasons.Contains('Prospect actively worked by Nolo in past 30 days.')){
                        
                    }else{
                        conIdVsReasonMap.get(con.Id).add('Prospect actively worked by Nolo in past 30 days.');
                    }
                    
                }    
            }
            
            
            
             
        }
        
        
        System.debug('@@@@@@@conIdVsReasonMap---------------->'+conIdVsReasonMap);
            
            for(Contact con: contactList){
                
                List<String> parentAccdoNotSolicit;
                List<String> conDoNotSolicit;
                
                if(parentAccIdVsReasonMap.containskey(con.AccountId) && conIdVsReasonMap.containskey(con.Id)){
                     System.debug('@@@@@@Both account and contact reasons---------->');
                     List<String> combinedReasons = new List<String>();
                     
                     parentAccdoNotSolicit = parentAccIdVsReasonMap.get(con.AccountId);
                     conDoNotSolicit = conIdVsReasonMap.get(con.Id);
                     combinedReasons.addAll(parentAccdoNotSolicit);
                     combinedReasons.addAll(conDoNotSolicit );
             
                     
                     if(con.Is_under_ROE__c == FALSE){
                        con.ROE_Update_Date__c= System.now();
                        con.Is_under_ROE__c = True;
                        
                    }
                    con.Reason_for_Not_Solicit__c = string.Join(combinedReasons, '\n' );
                    updateContactList.add(con); 
                }else if(!parentAccIdVsReasonMap.containskey(con.AccountId) &&  conIdVsReasonMap.containskey(con.Id)){
                    System.debug('@@@@@@Only contact reasons present---------->');
                    if(con.Is_under_ROE__c == FALSE){
                        con.ROE_Update_Date__c= System.now();
                        con.Is_under_ROE__c = True;
                        
                    }
                    con.Reason_for_Not_Solicit__c = string.Join(conIdVsReasonMap.get(con.Id), '\n' );
                    updateContactList.add(con); 
                
                }else if(parentAccIdVsReasonMap.containskey(con.AccountId) &&  !conIdVsReasonMap.containskey(con.Id)){
                    System.debug('@@@@@@Only parent reasons present---------->');
                    System.debug('@@@con.Is_under_ROE__c----'+con.Is_under_ROE__c);
                    if(con.Is_under_ROE__c == FALSE){
                        con.ROE_Update_Date__c= System.now();
                        con.Is_under_ROE__c = True;
                    }
                    con.Reason_for_Not_Solicit__c = string.Join(parentAccIdVsReasonMap.get(con.AccountId), '\n' );
                    updateContactList.add(con); 
                
                }else{
                    System.debug('@@@@@Inside the false condition for ROE-------------->'+con.Is_under_ROE__c);
                    if(con.Is_under_ROE__c == True){
                        con.Is_under_ROE__c = False;
                        con.Reason_for_Not_Solicit__c = '';
                        con.ROE_Update_Date__c= System.now();
                        updateContactList.add(con);    
                    }
                }
            }
            System.debug('@@@@@@@Contacts to be updated------------->'+updateContactList);

        }
        if(!updateContactList.isempty()){
            update updateContactList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}