//Test class to test the 'TriggerOnPayment' where a new payment is created when 'Created from Account' is updated.
@isTest(seealldata=true)
public with sharing class MDL_Test_TrghandlerOnPayment {
    static testmethod void updatePayment(){
        
        id rectypeforNolo = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).RecordTypeId;
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc;
        String Acclabel = label.Payment_Account;
        //create account
        for(Account a : [select Id from Account where Name =: Acclabel LIMIT 1]){
            acc = a;
        }
        if(acc==null){
            acc = new Account(Name='JV Payment Account');
            insert acc;
        }
        //create account to update 'Created from Account' of the payment
        Account account1 = new Account(Name='Test Account 12');
        insert account1;
        //create account to update 'Created from Account' of the payment
        Account account2 = new Account(Name='Cloned Account 12');
        insert account2;
        //create currency
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        //create order for invoice line
        invoiceit_s__Job__c order1 = util.getOrder(account1.Id,currency1.Id);
        invoiceit_s__Payment__c payment1 = new invoiceit_s__Payment__c(invoiceit_s__Account__c = account1.Id,
                                                                        invoiceit_s__Currency__c = currency1.Id,
                                                                        invoiceit_s__Amount__c = 200.00,
                                                                        invoiceit_s__Payment_Date__c = Date.today(),
                                                                        invoiceit_s__Payment_Type__c = 'ACH',
                                                                        invoiceit_s__Status__c = 'Completed'
                                                                         //RecordTypeId = rectypeforNolo
                                                                      );                                                                       
        if(acc.Id!=null)payment1.Created_From_Account__c = acc.Id;
        insert payment1;  
        //create invoice,invoice line and payment allocation for the payment
        invoiceit_s__Invoice__c invoice1 = util.getInvoice(account1.id);    
        invoiceit_s__Invoice_Lines__c invoiceline1 = util.getInvoiceLines(invoice1.Id,order1.Id);                                                           
        invoiceit_s__Payment_Allocation__c paymentalloc1 = util.getPaymentAlloc(payment1.Id,invoice1.Id);       
        //update payment
        Test.startTest();
        try{
            payment1.Created_From_Account__c=account1.Id;
            update payment1;
        }catch(Exception e){}
        try{
            payment1.Created_From_Account__c=account2.Id;
            update payment1;
        }catch(Exception e){}
        Test.stopTest();
      }
      static testmethod void testrestrictpaymentcreation(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account a1 = util.getAccount();
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        Id userId = userInfo.getUserId();
        User u1 = [select name from User where Id=:userId];
        System.runAs(u1){  
            PermissionSet ps = new PermissionSet(Name='Test_Finance_Process_Permissions',Label='Test Finance Process Permissions');  
            insert ps;          
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.Id,AssigneeId=u1.Id);
            insert psa;
            Test.startTest();
            invoiceit_s__Payment__c payment1 = new invoiceit_s__Payment__c(invoiceit_s__Account__c = a1.Id,
                                                                        invoiceit_s__Currency__c = currency1.Id,
                                                                        invoiceit_s__Amount__c = 200.00,
                                                                        invoiceit_s__Payment_Date__c = Date.today(),
                                                                        invoiceit_s__Payment_Type__c = 'ACH',
                                                                        invoiceit_s__Status__c = 'Completed',
                                                                        Created_From_Account__c = a1.Id,
                                                                        Applied_Type__c = 'Write-off');
            insert payment1;
            delete payment1;
            Test.stopTest();
        }       
      }
    
    
    static testmethod void run2condition(){
        id rectypeforNolo = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).RecordTypeId;
        system.debug('@@rectypeidpayment'+ rectypeforNolo);
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc;
        //create account
        for(Account a : [select Id from Account where Name='Payment Account' LIMIT 1]){
            acc = a;
        }
        if(acc==null){
            acc = new Account(Name='Payment Account');
          insert acc;
       }
        //create account to update 'Created from Account' of the payment
        Account account1 = new Account(Name='Test Account34');
        insert account1;
        //create account to update 'Created from Account' of the payment
        Account account2 = new Account(Name='Cloned Account34');
        account2.MH_Cust_Number__c = '123456789';
        insert account2;
        system.debug('@@acountid'+ account2.id);
        //create currency
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        //create order for invoice line
        
 
        invoiceit_s__Job__c order1 = util.getOrder(account1.Id,currency1.Id);
        invoiceit_s__Invoice__c singleinv = util.getInvoice(account1.id);
        
        
       
         invoiceit_s__Invoice_Lines__c singleinvline = util.getInvoiceLines(singleinv.id, order1.id);
        singleinv = [select id, Name, invoiceit_s__Account__c,
                             invoiceit_s__Due_Date__c, invoiceit_s__Invoice_Date__c,
                             invoiceit_s__Unpaid_Amount__c,invoiceit_s__Total_Invoice_Value__c,
                           invoiceit_s__Amount__c 
                             from invoiceit_s__Invoice__c
                              where id = :singleinv.id ];
         system.debug('@@@singleinv' + singleinv);
        invoiceit_s__Payment__c payment1 = new invoiceit_s__Payment__c(
                                                                        invoiceit_s__Currency__c = currency1.Id,
                                                                        invoiceit_s__Amount__c = 200.00,
                                                                        invoiceit_s__Payment_Date__c = Date.today(),
                                                                        invoiceit_s__Payment_Type__c = 'ACH',
                                                                        invoiceit_s__Status__c = 'Completed',
                                                                         RecordTypeId = rectypeforNolo,
                                                                       Uploaded_payment__c = true,
                                                                        Invoice__c = singleinv.id,
                                                                       CSVReference_Account__c ='123456789',
                                           invoiceit_s__Account__c = account2.Id
                                                                       
                                                                       
                                                                      );                                                                       
        if(acc.Id!=null)payment1.Created_From_Account__c = acc.Id;
        insert payment1;  
        
        invoiceit_s__Payment__c payment2 = new invoiceit_s__Payment__c(
                                                                        invoiceit_s__Currency__c = currency1.Id,
                                                                        invoiceit_s__Amount__c = 200.00,
                                                                        invoiceit_s__Payment_Date__c = Date.today(),
                                                                        invoiceit_s__Payment_Type__c = 'ACH',
                                                                        invoiceit_s__Status__c = 'Completed',
                                                                         RecordTypeId = rectypeforNolo,
                                                                       Uploaded_payment__c = true,
                                                                        Invoice__c = singleinv.id,
                                                                       //CSVReference_Account__c ='123456789',
                                           invoiceit_s__Account__c = account2.Id
                                                                       
                                                                       
                                                                      );                                                                       
        if(acc.Id!=null)payment1.Created_From_Account__c = acc.Id;
        insert payment2;  
    }
    
    
    static testmethod void oldNoloUploadPayment(){
        id rectypeforNolo = Schema.SObjectType.invoiceit_s__Payment__c.RecordTypeInfosByName.get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).RecordTypeId;
        system.debug('@@rectypeidpayment'+ rectypeforNolo);
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc;
        //create account
        for(Account a : [select Id from Account where Name='New Payment Account' LIMIT 1]){
            acc = a;
        }
        if(acc==null){
            acc = new Account(Name='New Payment Account');
            acc.Customer_ID__c ='123456';
          insert acc;
       }
        //create account to update 'Created from Account' of the payment
        Account account1 = new Account(Name='Test Account546');
        account1.Customer_ID__c = '65464646';
        insert account1;
        
        //create account to update 'Created from Account' of the payment
        Account account2 = new Account(Name='Test Account 26');
        account2.Customer_ID__c = '';
        insert account2;
        
        system.debug('@@acountid'+ account2.id);
        
        //create currency
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        //create order for invoice line
        
        invoiceit_s__Invoice__c invoice1= new invoiceit_s__Invoice__c();
        invoice1.invoiceit_s__Account__c = account1.id;
        invoice1.invoiceit_s__Invoice_Reference__c='INV-002';     
        
        invoiceit_s__Invoice__c invoice2= new invoiceit_s__Invoice__c();
        invoice2.invoiceit_s__Account__c = account2.id;   
        invoice2.invoiceit_s__Invoice_Reference__c='INV-003';
        
        system.debug('@@@singleinv' + invoice1);
        invoiceit_s__Payment__c payment1 = new invoiceit_s__Payment__c(
                                                                        invoiceit_s__Currency__c = currency1.Id,
                                                                        invoiceit_s__Amount__c = 2000.00,
                                                                        invoiceit_s__Payment_Date__c = Date.today(),
                                                                        invoiceit_s__Payment_Type__c = 'Credit Card',
                                                                        invoiceit_s__Status__c = 'Completed',
                                                                         RecordTypeId = rectypeforNolo,
                                                                       Old_Uploaded_Payment__c= true,
                                                                        CSVReference_Invoice__c = 'INV-002',
                                                                       CSVReference_Account__c ='65464646',
                                           invoiceit_s__Account__c = account1.Id,Invoice__c = invoice1.id
                                                                       
                                                                       
                                                                      );                                                                       
        insert payment1;  
        
        invoiceit_s__Payment__c payment2 = new invoiceit_s__Payment__c(
                                                                        invoiceit_s__Currency__c = currency1.Id,
                                                                        invoiceit_s__Amount__c = 100.00,
                                                                        invoiceit_s__Payment_Date__c = Date.today(),
                                                                        invoiceit_s__Payment_Type__c = 'Credit Card',
                                                                        invoiceit_s__Status__c = 'Completed',
                                                                         RecordTypeId = rectypeforNolo,
                                                                       Old_Uploaded_Payment__c= true,
                                                                        CSVReference_Invoice__c = 'INV-003',
                                                                       CSVReference_Account__c ='65464678',
                                           invoiceit_s__Account__c = account2.id,Invoice__c = invoice2.id
                                                                       
                                                                       
                                                                      );                                                                       
     
        insert payment2;  
    }
    
    
    
}