/*Create a Batch process  to Auto-allocate M-H Payments  to most recent M-H Invoices
 
 Payments = M-H Payments
 Adjustment Reason = M-H Promotional Credit
 M-H Invoices = Most recent Invoice date
*/

global class mdl_BatchtoallocateNoloPayments implements Database.Batchable<sobject>,  Database.Stateful{
    
    //global varaible which stores allocations created from this batch only
    global List<invoiceit_s__Payment_Allocation__c> paymentAllocationCSV;
    
    global mdl_BatchtoallocateNoloPayments(){
        paymentAllocationCSV = new List<invoiceit_s__Payment_Allocation__c>();
    }
    
     global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('*****Start*****');
        if(!test.isRunningTest()){
            return Database.getQueryLocator([select Id,Name,
                                                Adjustment_Reason__c, 
                                                invoiceit_s__Payment_Type__c,
                                                RecordType.Name,
                                                invoiceit_s__Amount__c,
                                                invoiceit_s__Account__c,
                                                (select id, Name 
                                                        from invoiceit_s__Payment_Allocations__r)
                                                from invoiceit_s__Payment__c  
                                                //Done by Sai :Changes made for New Record type changes 
                                                where  RecordType.Name =:RecordTypesFinalStringsClass.RecTypeName_MH_Payments
                                                    and Adjustment_Reason__c = 'M-H Promotional Credit'
                                                ]);
        }
        else{
            return Database.getQueryLocator([select Id,Name,
                                                Adjustment_Reason__c, 
                                                invoiceit_s__Payment_Type__c,
                                                RecordType.Name,
                                                invoiceit_s__Amount__c,
                                                invoiceit_s__Account__c,
                                                (select id, Name 
                                                        from invoiceit_s__Payment_Allocations__r)
                                                from invoiceit_s__Payment__c  
                                                where  RecordType.Name =: RecordTypesFinalStringsClass.RecTypeName_MH_Payments   
                                                    and Adjustment_Reason__c = 'M-H Promotional Credit'
                                                    and isTestRunning__c = true
                                                    LIMIT 5
                                                ]);

        }
        
        
     }
    
    
      global void execute(Database.BatchableContext BC, List<invoiceit_s__Payment__c> paymentsList){
            System.debug('@@@@Start  Execution');
            system.debug('@@@@@payList' + paymentsList);
          
          //forming accids
          set<String> accids = new set<String>();
          
          //accid vs set of paymentIds
          map<id, set<id>> accidVsPaymentIds = new map<Id, Set<id>>();
          
          //Done by Sai :Changes made for New Record type changes 
          Id payallocationRecordTypeId = Schema.SObjectType.invoiceit_s__Payment_Allocation__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Payment_Allocation).getRecordTypeId();
          
          //generic class which gives set of account Ids of account
          accids = genericUtilityClass.formingsetIDsfromList(paymentsList, 'invoiceit_s__Account__c');
          
          //payment allocation list to update
          List<invoiceit_s__Payment_Allocation__c> paymentallocationList = new List<invoiceit_s__Payment_Allocation__c>();
          invoiceit_s__Payment_Allocation__c paymentAllocation;
          
          //forming accid and set of payment Ids
          for(invoiceit_s__Payment__c singlePaymnet : paymentsList){
              if(accidVsPaymentIds.containsKey(singlePaymnet.invoiceit_s__Account__c)){
                  Set<Id> localSet = new Set<Id>(accidVsPaymentIds.get(singlePaymnet.invoiceit_s__Account__c));
                  localSet.add(singlePaymnet.id);
                  accidVsPaymentIds.put(singlePaymnet.invoiceit_s__Account__c, localSet);
              }
              else{
                  accidVsPaymentIds.put(singlePaymnet.invoiceit_s__Account__c, new set<Id>{singlePaymnet.id});
              } 
          }
          
          system.debug('@@@@@accidVsPaymentIds'+ accidVsPaymentIds);
          //querying on account and invoices get Recent Invoice 
           //accid vs set of paymentIds
           map<id,account> accidVSAccountMap = new map<id,account>([select id,Name,
                                                                        (select id, Name,
                                                                                RecordType.Name,
                                                                                invoiceit_s__Invoice_Date__c,invoiceit_s__Invoice_Status__c
                                                                                from invoiceit_s__Invoices__r
                                                                                //Done by Sai :Changes made for New Record type changes 
                                                                                where RecordType.Name =: RecordTypesFinalStringsClass.RecTypeName_MH_Invoice    
                                                                                and invoiceit_s__Invoice_Status__c = 'Posted'
                                                                                order by invoiceit_s__Invoice_Date__c DESC
                                                                                LIMIT 1)
                                                                         from account 
                                                                         where Id IN:(accids)
                                                                         ]);
          
          
          for(invoiceit_s__Payment__c singlePaymnet : paymentsList){ 
              
              //checking payment allocation already created for this payment
              if(singlePaymnet.invoiceit_s__Payment_Allocations__r.size() == 0){
                      //checking in both maps for existence
                  if(accidVSAccountMap.containsKey(singlePaymnet.invoiceit_s__Account__c)
                                    && accidVsPaymentIds.containsKey(singlePaymnet.invoiceit_s__Account__c)){
                      //checking for singlePaymnet exists in map values or not
                      system.debug('@@@@accidVSAccountMap.get(singlePaymnet.invoiceit_s__Account__c).invoiceit_s__Invoices__r.size()'+
                                      accidVSAccountMap.get(singlePaymnet.invoiceit_s__Account__c).invoiceit_s__Invoices__r.size());
                        if(accidVsPaymentIds.get(singlePaymnet.invoiceit_s__Account__c).contains(singlePaymnet.id)
                                      && accidVSAccountMap.get(singlePaymnet.invoiceit_s__Account__c).invoiceit_s__Invoices__r.size() > 0){
                            
                            singlePaymnet.invoiceit_s__Invoice__c =  accidVSAccountMap.get(singlePaymnet.invoiceit_s__Account__c).invoiceit_s__Invoices__r[0].id;   
                            paymentAllocation = new invoiceit_s__Payment_Allocation__c();
                            paymentAllocation.invoiceit_s__Payment__c = singlePaymnet.id;
                            paymentAllocation.invoiceit_s__Amount__c  =  singlePaymnet.invoiceit_s__Amount__c;
                            //paymentAllocation.invoiceit_s__Amount__c  =  singlePaymnet.invoiceit_s__Unallocated_Amount__c;
                            paymentAllocation.invoiceit_s__Status__c  = 'Completed';
                            paymentAllocation.invoiceit_s__Invoice__c = accidVSAccountMap.get(singlePaymnet.invoiceit_s__Account__c).invoiceit_s__Invoices__r[0].id;  
                            paymentAllocation.RecordTypeId = payallocationRecordTypeId;
                            paymentallocationList.add(paymentAllocation);              
                        }                 
                  }
              }
              
              
              
          }
          
          try{
              //update paymentsList;
              insert paymentallocationList;
              
              //adding to satateful list to retain list
              paymentAllocationCSV.addAll(paymentallocationList);
              
          }
          catch(Exception e){
              system.debug('@@@@Exeption'+ e);
          }
          
      }
    
    
      global void finish(Database.BatchableContext BC){
          
          //creating csv and sending email
          string header = 'Record Id , Customer Number, Invoice Number, Payment Allocation Number , Adjustment Reason , Amount , Payment Number , Status \n';
          string finalstr = header ;
          
          List<invoiceit_s__Payment_Allocation__c> paymetAllocationListqueried = new List<invoiceit_s__Payment_Allocation__c>();
          if(paymentAllocationCSV != null  && !paymentAllocationCSV.isEmpty()){
               paymetAllocationListqueried = [select id, Name,invoiceit_s__Invoice__r.Name,
                                                        invoiceit_s__Invoice__r.invoiceit_s__Account__r.MH_Cust_Number__c,
                                                      Adjustment_Reason__c,
                                                      invoiceit_s__Amount__c,
                                                      invoiceit_s__Payment__r.Name,
                                                      invoiceit_s__Status__c
                                                      From invoiceit_s__Payment_Allocation__c
                                                      where Id IN:(paymentAllocationCSV)];
               for(invoiceit_s__Payment_Allocation__c paymentallocation : paymetAllocationListqueried){
              
                    String recordString =  '"'+paymentallocation.id+'","'+paymentallocation.invoiceit_s__Invoice__r.invoiceit_s__Account__r.MH_Cust_Number__c  +'", "'+paymentallocation.invoiceit_s__Invoice__r.Name+'","'+paymentallocation.Name+'","'+paymentallocation.Adjustment_Reason__c+'","'+paymentallocation.invoiceit_s__Amount__c+'","'+paymentallocation.invoiceit_s__Payment__r.Name+'","'+paymentallocation.invoiceit_s__Status__c  +'"\n';
                    finalstr = finalstr +recordString;
              
             }
          
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(finalstr);
            string csvname= 'paymentallocations' + '.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> ();
            toAddresses.add('sfdcsystemautomation@martindale.com');
            String subject ='Report on Payment Allocations With M-H Promotional Credit';
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('Payment Allocations on M-H Promotional Credit');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
              if(!test.isRunningTest()){
                  Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
              }  
            

          }
          
                 
    }


}