@IsTest
public class Test_Batch_AutoevergreenCPQ {
    static testmethod void testRun1(){
    
       
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();        
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        
        
        SBQQ__Quote__c quote=new SBQQ__Quote__c();
        quote.Marketing_Contact__c=con.id;
        quote.Billing_Contact__c=con.id;
        quote.SBQQ__PrimaryContact__c=con.id;
        quote.SBQQ__Account__c=acc.id;
        quote.SBQQ__Opportunity2__c=opp.id;
        quote.SBQQ__StartDate__c=system.today();
        quote.SBQQ__SubscriptionTerm__c = 12;
        insert quote;
        
        opp.SBQQ__PrimaryQuote__c=quote.id;
        update opp;
        
        Contract objcont=new contract();
        objcont.SBQQ__RenewalOpportunity__c =opp.id;
        objcont.accountid=acc.id;
        insert objcont;
        
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';  
        ord.Activateorder__c=true; 
        ord.EffectiveDate = Date.today();
        insert ord;
        
      
        
         Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Professional Profile', objBR, objRR, objTR, 1);
       // List<Product2> lstProd2 = DataFactory.createProduct('Ngage', objBR, objRR, objTR, 1);
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        Id pricebookId = Test.getStandardPricebookId();
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';  
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
       objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        insert objOrder;
        
        List<OrderItem> ottList = new List<OrderItem>();
        OrderItem oddItem = new OrderItem();
        oddItem.blng__BillingRule__c = objBR.Id;
        oddItem.blng__RevenueRecognitionRule__c = objRR.Id;
        oddItem.blng__TaxRule__c = objTR.Id;
        oddItem.OrderId = objOrder.Id;
        oddItem.PricebookEntryId = objPBEntry.Id;
        oddItem.UnitPrice = 240;
        oddItem.Quantity = 9;
        oddItem.SBQQ__DefaultSubscriptionTerm__c=1;
        oddItem.StatusCheck__c = false;
        insert oddItem;
        ottList.add(oddItem);
         Test.startTest();
        objOrder.status='Activated';
        objOrder.ActivateOrder__c=true;
        update objOrder;
        
        objcont.SBQQ__Order__c=objOrder.id;
        update objcont;
        
        /*Order objOrder1 = new Order();
        objOrder1.Name = 'Test Order ';
        objOrder1.RecordtypeId = strMAIntakeRecTypeId;
        objOrder1.Status = 'Draft';
        objOrder1.EffectiveDate = system.today();
       objOrder1.EndDate = system.today() + 4;
        objOrder1.AccountId = lstAcc[0].id;
        objOrder1.Pricebook2Id = Test.getStandardPricebookId();
        objOrder1.blng__BillingDayOfMonth__c = '1';
       
        insert objOrder1;
        
        OrderItem oddItem1 = new OrderItem();
        oddItem1.blng__BillingRule__c = objBR.Id;
        oddItem1.blng__RevenueRecognitionRule__c = objRR.Id;
        oddItem1.blng__TaxRule__c = objTR.Id;
        oddItem1.OrderId = objOrder1.Id;
        oddItem1.PricebookEntryId = objPBEntry.Id;
        oddItem1.UnitPrice = 240;
        oddItem1.Quantity = 9;
        oddItem1.SBQQ__DefaultSubscriptionTerm__c=1;
        insert oddItem1;
        ottList.add(oddItem);
        
        objOrder1.status='Activated';
        objOrder1.ActivateOrder__c=true;
        update objOrder1;
        
        Auto_Evergreen_Process__c autoEvergreen = new Auto_Evergreen_Process__c();
        autoEvergreen.MarkQuoteasClosedWon__c=false;
        autoEvergreen.name='Auto Evergreen Process';
        autoEvergreen.Email_Ids_for_Auto_Evergreen_mail__c='test';
        autoEvergreen.Link_for_Success_Report__c='test';
        autoEvergreen.Link_for_Failure_Report__c='test';
        autoEvergreen.Link_for_report_with_unmatching_dates__c='test';
        insert autoEvergreen;*/
         
       
       
        Batch_SetcontractasActive batch2 = new Batch_SetcontractasActive();
        Database.executebatch(new Batch_SetcontractasActive() ,1);
        
        Batch_SetcontractasAutoEvergreen batch3 = new Batch_SetcontractasAutoEvergreen();
        Database.executebatch(new Batch_SetcontractasAutoEvergreen());
        
        
        Batch_SetOrderasContracted batch4 = new Batch_SetOrderasContracted();
        Database.executebatch(new Batch_SetOrderasContracted());
        
        Test.stopTest();
     }
     
     static testmethod void testMethodA(){
        
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> con =DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
        
        product2 objproduct= new product2();
        objproduct.Name ='Test Product';
        objproduct.IsInventoried__c = True;
        objproduct.ProductCode = '11006';
        insert objproduct;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__PrimaryContact__c = con[0].Id; 
        objquote.Billing_Contact__c = con[0].Id; 
        objquote.Marketing_Contact__c = con[0].Id; 
        objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__StartDate__c=system.today();
        objquote.SBQQ__SubscriptionTerm__c = 12;
        insert objquote;
        
        String qID = objquote.Id; 
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        insert quoteline;
        
        SBQQ__QuoteLine__c quotelineA=new SBQQ__QuoteLine__c();
        quotelineA.SBQQ__Product__c=objproduct.id;
        quotelineA.SBQQ__Quote__c=objquote.Id;
        quotelineA.SBQQ__RequiredBy__c = quoteline.Id;
        quotelineA.Attribute_Relationship__c = objAR.Id;
        insert quotelineA;
        
        Contract objcont=new contract();
        objcont.SBQQ__RenewalOpportunity__c =oppid;
        objcont.accountid=lstAcc[0].id;
        insert objcont;
        
        testopp.SBQQ__PrimaryQuote__c=objquote.id;
        update testopp;
        
        Auto_Evergreen_Process__c autoEvergreen = new Auto_Evergreen_Process__c();
        autoEvergreen.MarkQuoteasClosedWon__c=false;
        autoEvergreen.name='Auto Evergreen Process';
        insert autoEvergreen;
      
      Test.startTest();
        
      Batch_SetQuoteasAutoEvergreen batch = new Batch_SetQuoteasAutoEvergreen();
        Database.executebatch(new Batch_SetQuoteasAutoEvergreen());
        
        //Auto_Evergreen_Process__c autoEvergreen1 = new Auto_Evergreen_Process__c();
        autoEvergreen.MarkQuoteasClosedWon__c=true;
       // autoEvergreen.name='test';
        update autoEvergreen;
        
        Batch_SetQuoteasAutoEvergreen batch2 = new Batch_SetQuoteasAutoEvergreen();
        Database.executebatch(new Batch_SetQuoteasAutoEvergreen());
        
        
        Batch_SetQuotelineAutoEvergreen batch1 = new Batch_SetQuotelineAutoEvergreen();
        Database.executebatch(new Batch_SetQuotelineAutoEvergreen());
        
        
        Test.stopTest();
     }
     
   /*  static testmethod void testMethod2(){
        
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> con =DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
        
        product2 objproduct= new product2();
        objproduct.Name ='Test Product';
        objproduct.IsInventoried__c = True;
        objproduct.ProductCode = '11006';
        insert objproduct;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__PrimaryContact__c = con[0].Id; 
        objquote.Billing_Contact__c = con[0].Id; 
        objquote.Marketing_Contact__c = con[0].Id; 
        objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__Status__c ='Draft';
        objquote.SBQQ__StartDate__c = system.today();
        objquote.SBQQ__SubscriptionTerm__c = 12;
        insert objquote;
        
        String qID = objquote.Id; 
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        quoteline.SBQQ__SubscriptionType__c = 'Renewable';
        insert quoteline;
        
        SBQQ__QuoteLine__c quotelineA=new SBQQ__QuoteLine__c();
        quotelineA.SBQQ__Product__c=objproduct.id;
        quotelineA.SBQQ__Quote__c=objquote.Id;
        quotelineA.SBQQ__RequiredBy__c = quoteline.Id;
        quotelineA.Attribute_Relationship__c = objAR.Id;
         quoteline.SBQQ__SubscriptionType__c = 'Renewable';
        insert quotelineA;
        
        Contract objcont=new contract();
        objcont.SBQQ__RenewalOpportunity__c =oppid;
        objcont.accountid=lstAcc[0].id;
        insert objcont;
        
        testopp.SBQQ__PrimaryQuote__c=objquote.id;
        update testopp;
        
        Auto_Evergreen_Process__c autoEvergreen = new Auto_Evergreen_Process__c();
        autoEvergreen.MarkQuoteasClosedWon__c=false;
        autoEvergreen.name='Auto Evergreen Process';
        insert autoEvergreen;
       
        
        objquote.SBQQ__Status__c ='Closed Won';
         objquote.Reason_Won_Lost__c = 'Administrative';
      //  update objquote;
       Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
         
      Order objOrder = new Order();
        objOrder.Name = 'Test Order ';  
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
       // objOrder.SBQQ__Quote__c=quote.id;
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        insert objOrder;
      Test.startTest();
        
      
        
        Batch_SetQuotelineAutoEvergreen batch1 = new Batch_SetQuotelineAutoEvergreen();
        Database.executebatch(new Batch_SetQuotelineAutoEvergreen());
        
        
        Test.stopTest();
     }*/
     
     
      
}