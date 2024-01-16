@isTest(seeAlldata = true)
private class TestClassForRetryPaymentMethods {
    static testMethod void testBatchProcessRetryFailedTransaction() {
      Account account = new Account(Name = 'Test Account' );
        insert account;
        
        Contact contact =  new Contact(LastName = 'Laxman', AccountId = account.Id);                                 
        insert contact;
        
        invoiceit_s__Currency__c currency1 = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '$1');
        insert currency1;   
        
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(Name = 'Test Job', 
                invoiceit_s__Account__c = account.Id,
                invoiceit_s__Billing_Contact__c = contact.Id,
                invoiceit_s__Shipping_Contact__c = contact.Id,
                invoiceit_s__Number_Of_Terms__c = 24,
                invoiceit_s__CurrencyL__c = currency1.Id,
                invoiceit_s__Start_Date__c = system.today(), 
                invoiceit_s__Service_Activation_Date__c = system.today(), 
                invoiceit_s__Service_End_Date__c = system.today(),
                invoiceit_s__Preferred_Billing_Day__c = '01',
                invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0
        );
        insert job;
         
         
         invoiceit_s__Invoice__c invoice = new invoiceit_s__Invoice__c(invoiceit_s__Account__c = account.id,
                                            invoiceit_s__Billing_Contact__c = contact.Id,
                                            invoiceit_s__Shipping_Contact__c = contact.Id,
                                            invoiceit_s__CurrencyL__c = currency1.Id, 
                                            invoiceit_s__Target_Date__c = Date.today(),
                                            invoiceit_s__Delivery_Type__c = 'Both',
                                            invoiceit_s__Invoice_Status__c = 'Posted',
                                            invoiceit_s__Payment_Request_Amount__c = 120,                                     
                                            invoiceit_s__Due_Date__c = system.today(),
                                            invoiceit_s__Invoice_Date__c = system.today()                                   
                                            );
                                            
        insert invoice;
        
        list<invoiceit_s__Invoice_Lines__c> listInvoiceLines = new list<invoiceit_s__Invoice_Lines__c>();
        listInvoiceLines.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Invoice__c = invoice.id, invoiceit_s__Charge_Date__c = system.today(), invoiceit_s__Line_Name__c = 'Broadband Installation For L',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = job.Id , invoiceit_s__Service_End_Date__c = system.today()));
        listInvoiceLines.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Invoice__c = invoice.id, invoiceit_s__Charge_Date__c = system.today(), invoiceit_s__Line_Name__c = 'Broadband Installation For X',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = job.Id, invoiceit_s__Service_End_Date__c = system.today()));
        listInvoiceLines.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Invoice__c = invoice.id, invoiceit_s__Charge_Date__c = system.today(), invoiceit_s__Line_Name__c = 'Broadband Installation For M',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = job.Id, invoiceit_s__Service_End_Date__c = system.today()));
        insert listInvoiceLines;
         
         invoiceit_s__Gateway__c gateway = new invoiceit_s__Gateway__c();
         
         gateway = new invoiceit_s__Gateway__c(invoiceit_s__Active__c = true, invoiceit_s__Default__c = false, invoiceit_s__Gateway_Type__c = 'Authorize.net', invoiceit_s__Test_Mode__c = true, invoiceit_s__Merchant_ID__c = '73tMUG47mL', invoiceit_s__Security_Key__c = '8EdU4593cCA7hWXn');
         insert gateway;
         
         invoiceit_s__Payment_Scheduler__c paymenRunScheduler = new invoiceit_s__Payment_Scheduler__c();
         paymenRunScheduler.invoiceit_s__Type__c = 'Once';
         paymenRunScheduler.invoiceit_s__Target_Date__c = system.today();
         paymenRunScheduler.invoiceit_s__Start_date_and_time__c = system.now().addMinutes(20);
         paymenRunScheduler.invoiceit_s__Currency__c = currency1.Id;
         insert paymenRunScheduler;
         
         invoiceit_s__Payment_Run__c paymentRun = new invoiceit_s__Payment_Run__c(Name = 'payment Run' , invoiceit_s__Status__c = 'Processing',invoiceit_s__Payment_Scheduler__c = paymenRunScheduler.id);
         insert paymentRun;
        
          List<invoiceit_s__Payment_Method__c> paymentMethods  = new List<invoiceit_s__Payment_Method__c>();
         paymentMethods.add(new invoiceit_s__Payment_Method__c(invoiceit_s__Active__c = true, invoiceit_s__Default__c = true,
                                                                                           invoiceit_s__Account__c = account.Id, invoiceit_s__CVV__c = string.valueOf(123) , 
                                                                                           invoiceit_s__Card_Number__c = string.valueOf(1234567890), 
                                                                                           invoiceit_s__Card_Expiration_Year__c = '2023', 
                                                                                           invoiceit_s__Card_Expiration_Month__c = '10',Rank__c = '1',
                                                                                           invoiceit_s__Billing_Email__c = 'Test@test123.com',
                                                                                          invoiceit_s__Bank_Account_Number__c = string.valueOf(1234567890)));
         //insert paymentMethod;
         
         paymentMethods.add(new invoiceit_s__Payment_Method__c(invoiceit_s__Account__c = account.Id, invoiceit_s__CVV__c = string.valueOf(123), 
                                                                                            invoiceit_s__Card_Number__c = string.valueOf(1234567890), 
                                                                                            invoiceit_s__Card_Expiration_Year__c = '2022', 
                                                                                            invoiceit_s__Card_Expiration_Month__c = '10',Rank__c = '3',
                                                                                           invoiceit_s__Bank_Account_Number__c = string.valueOf(1234567890)));
         //insert paymentMethod1;    
         
         paymentMethods.add(new invoiceit_s__Payment_Method__c(invoiceit_s__Account__c = account.Id, invoiceit_s__CVV__c = string.valueOf(123), 
                                                                                            invoiceit_s__Card_Number__c = string.valueOf(1234567890), 
                                                                                            invoiceit_s__Card_Expiration_Year__c = '2023', 
                                                                                            invoiceit_s__Card_Expiration_Month__c = '10',Rank__c = '5',
                                                                                           invoiceit_s__Bank_Account_Number__c = string.valueOf(1234567890)));
         insert paymentMethods;    
        
        
        paymentRun.invoiceit_s__Status__c = 'Completed';
        update paymentRun;
        
        set<Id> setofPaymentRunIDs = new set<Id>();
        setofPaymentRunIDs.add(paymentRun.id);
        
        invoiceit_s__Transaction__c transaction1= new invoiceit_s__Transaction__c();
        transaction1.invoiceit_s__Type__c = 'Charge';
        transaction1.invoiceit_s__Payment_Gateway__c = gateway.id;
        transaction1.invoiceit_s__Payment_Method__c = paymentMethods[0].id;
        transaction1.invoiceit_s__Response_Status__c = 'Declined';
        transaction1.invoiceit_s__Amount__c = 120;
        transaction1.invoiceit_s__Currency__c = currency1.id;
        transaction1.invoiceit_s__Request_Invoice__c = invoice.id;
        transaction1.invoiceit_s__Payment_Run__c = paymentRun.id;
        //transaction1.PM_Billing_Email__c = transaction1.Populate_Email__c;
        
        insert transaction1;
        
        system.Test.startTest();    
            string sQuery = 'SELECT Id FROM invoiceit_s__Transaction__c';
            BatchProcessRetryFailedTransaction b = new BatchProcessRetryFailedTransaction(sQuery,setofPaymentRunIDs, null);
            Id batchId = Database.executeBatch(b, 1); 
            system.debug(batchId);
        system.Test.stopTest(); 
        
        invoiceit_s__Transaction__c transaction2= new invoiceit_s__Transaction__c();
        transaction2.invoiceit_s__Type__c = 'Charge';
        transaction2.invoiceit_s__Payment_Gateway__c = gateway.id;
        transaction2.invoiceit_s__Payment_Method__c = paymentMethods[0].id;
        transaction2.invoiceit_s__Response_Status__c = 'Approved';
        transaction2.invoiceit_s__Amount__c = 120;
        transaction2.invoiceit_s__Currency__c = currency1.id;
        transaction2.invoiceit_s__Request_Invoice__c = invoice.id;
        
        insert transaction2;
        
       PaymentOperationsForAuthoriseDotNet.void(transaction2.Id);  
       PaymentOperationsForAuthoriseDotNet.refund(transaction2.Id); 
        
        
    }

}