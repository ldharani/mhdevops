/*
** Created by       : IJ
** Created Purpose  : To set the Quote as Evergreen after the contract has been made Evergreen
** Test class :  */

global class Batch_SetOrderasContracted implements Database.Batchable <SObject>,Database.Stateful  {

   
    
    //Start Method which retrieves the invoice records 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String strQuery;
       // Integer mnth = System.Today().MOnth();
       // Integer yr = System.Today().Year();
       // strQuery= 'Select Id,Status__c,EndDate,SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c,Account.Credit_Status__c,Account.BillingCountry,Account.Sub_Type__c,SBQQ__RenewalOpportunity__c from contract where Status__c = \'Evergreened\' and Account.Credit_Status__c = \'Good Standing\' and Do_Not_Renew__c=false and Account.BillingCountry=\'USA\' and recordtype.developername=\'MH_Contract\' and Account.Sub_Type__c=\'Small Law\' and LastmodifiedDate >=: DateToday and LastmodifiedDate <=: DateTomo';
        system.debug(strQuery+'strQuery');
        strQuery= 'select Id,status,ActivateOrder__c,SBQQ__Contracted__c  from Order where ActivateOrder__c=true and status=\'Activated\' and SBQQ__Contracted__c=false';
       if(test.isRunningTest()) {
           strQuery= 'Select Id,Status__c from Order';           
                   
        }
        
        return Database.getQueryLocator(strQuery);
        
    }

    global void execute(Database.BatchableContext BC, List <Order> orderList) {
      set<Id> OrderIds = new set<Id>();
        list<Order> UpdateOrderList= new list<Order>();
        list<OrderItem> UpdateOrderItemList= new list<OrderItem>();
       
        for(Order objOrder : orderList){
        //objOrder.Status = 'Activated';
        objOrder.SBQQ__Contracted__c = true;
        OrderIds.add(objOrder.id);
        UpdateOrderList.add(objOrder);
        
       }
       
        Map<Id,Order> ordMap = OrderUtility.getOrderCustomerNumber(OrderIds);
        
        for(OrderItem ordPrd: [select Id,blng__InvoiceGroupId__c,blng__BillingAccount__c,blng__InvoiceGrouping__c,OrderId from OrderItem where OrderId in:OrderIds]){ 
            if(ordMap.get(ordPrd.OrderId)!= null && ordMap.get(ordPrd.OrderId).CustomerNumber__c != null){
                ordPrd.blng__InvoiceGroupId__c = ordMap.get(ordPrd.OrderId).CustomerNumber__c;
                ordPrd.blng__BillingAccount__c = ordMap.get(ordPrd.OrderId).AccountId;
                ordPrd.blng__InvoiceGrouping__c = 'Order';
               UpdateOrderItemList.add(ordPrd);
            } 
        }
      
      database.update(UpdateOrderItemList,false);
      database.update(UpdateOrderList,false);
        
    }

    global void finish(Database.BatchableContext BC) {
        Boolean dontExecute = false;
        for(AsyncApexJob batch :[Select ExtendedStatus,NumberOfErrors,Status,JobItemsProcessed,TotalJobItems from AsyncApexJob where Id = :BC.getJobId()]){         
            if(batch.JobItemsProcessed > 0){
                dontExecute = false;
            }
            else{
                dontExecute = true;
            }
        }
        if(dontExecute==false){
            Auto_Evergreen_Process__c autoEvergreen = Auto_Evergreen_Process__c.getValues('Auto Evergreen Process');
            String emailAddressString = '';
             String successReport = '';
             String failureReport = '';
            String unmatchedReport = '';
            if(test.isrunningtest()){
                 emailAddressString = 'test';
             successReport = 'test';
             failureReport = 'test';
             unmatchedReport = 'test';
            }else{
                emailAddressString = autoEvergreen.Email_Ids_for_Auto_Evergreen_mail__c;
             successReport = autoEvergreen.Link_for_Success_Report__c;
             failureReport = autoEvergreen.Link_for_Failure_Report__c;
             unmatchedReport = autoEvergreen.Link_for_report_with_unmatching_dates__c; 
            }
            
            
            List<String> sendTo = new List<String>();   
            List<String> toEmailAddress = new List<String>();       
            if(emailAddressString.contains(',')){
                sendTo = emailAddressString.split(',');
                for(String s : sendTo){
                    if(s!='' && s!=null){
                        toEmailAddress.add(s);
                    }
                }
            }
            else{
                toEmailAddress.add(emailAddressString);
            }
            
            try{
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                mail.setSubject('Auto Evergreen Process batch report');      
                mail.setToAddresses(toEmailAddress);
                String body = '<html><body>The Auto Evergreen process batch has completed running successfully<br><br>'+
                'Click on the following links to view more details regarding the run:<br>';
                if(successReport != '')
                body += '(1) Report for success records : <a href="'+successReport+'">'+successReport+'</a><br>';
                if(failureReport != '')
                body += '(2) Report for failure records : <a href="'+failureReport+'">'+failureReport+'</a><br>';
                if(unmatchedReport !='')
                body += '(3) Report for orders and charges with unmatched Service End Date : <a href="'+unmatchedReport+'">'+unmatchedReport+'</a>';            
                body += '</body></html>';
                mail.setHtmlBody(body);
                mails.add(mail);
                Messaging.sendEmail(mails);
            }
            catch(Exception e){
                System.debug('An exception occured' + e.getMessage());
            }
        }       
    }

}