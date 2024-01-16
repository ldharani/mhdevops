@isTest
public class TestBatchInvoiceAutoAllocation {
    static testMethod void testMethod1(){
     Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
       Cls_UtilTestClass util = new Cls_UtilTestClass();
       Account acc = util.getAccount();
       acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
       update acc;
       Contact con = util.getContact(acc.Id);
       Opportunity opp = util.getOpportunity(acc.Id , con.Id);
       
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Professional Profile', objBR, objRR, objTR, 1);
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 500.00);
                
        Order ord = new Order();
        ord.RecordtypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = Date.today();
        ord.EndDate = system.today() + 30;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.blng__BillingDayOfMonth__c = '1';
        ord.OpportunityId = opp.Id;
        insert ord;
        
        List<OrderItem> ottList = new List<OrderItem>();
        OrderItem oddItem = new OrderItem();
        oddItem.blng__BillingRule__c = objBR.Id;
        oddItem.blng__RevenueRecognitionRule__c = objRR.Id;
        oddItem.blng__TaxRule__c = objTR.Id;
        oddItem.OrderId = ord.Id;
        oddItem.PricebookEntryId = objPBEntry.Id;
        oddItem.UnitPrice = 240;
        oddItem.Quantity = 9;
        oddItem.SBQQ__DefaultSubscriptionTerm__c=1;
        oddItem.StatusCheck__c = false;
        insert oddItem;
        
        ord.Status = 'Activated';
        ord.Activateorder__c=true;
        update ord;
        
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.RecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('MH Invoice').getRecordTypeId();
        invoice.blng__Account__c = acc.Id;
        invoice.blng__Order__c = ord.Id;
        insert invoice;
        
        
        blng__InvoiceLine__c singleinvline = new blng__InvoiceLine__c ();
        
        singleinvline.blng__Invoice__c = invoice.id;
        singleinvline.blng__StartDate__c = date.today();
        singleinvline.blng__EndDate__c = date.Today() + 365;
        //singleinvline.blng__UnitPrice__c = 300.00;
        //singleinvline.blng__Quantity__c = 1;
        //singleinvline.blng__TotalAmount__c = 300.00;
        singleinvline.blng__OrderProduct__c = oddItem.Id;
        
        insert singleinvline;
        
        invoice.blng__InvoiceStatus__c = 'Post In progress';
        update invoice;
        
        
      //  List<blng__InvoiceLine__c> invLineResult =[Select Id,blng__Balance__c,blng__TotalAmount__c,blng__UnitPrice__c from blng__InvoiceLine__c];
      //  System.debug('invLineResult========>'+invLineResult);
        
        DefaultPaymentAccount__c ddd = new DefaultPaymentAccount__c();
        ddd.Name = 'DefaultAccountRecord';
        ddd.Default_Account_ID__c = acc.ID;
        ddd.DefaultAccountNumber__c = '1000095499';
        ddd.PaymentAllocationRectypeID__c = '0123w0000026DqdAAE';
        ddd.PaymentRecordTypeID__c = '012F0000001K3Ld';
        ddd.USDCurrencyID__c = 'a03F0000009vD0D';
        insert ddd;
        blng__Payment__c pay = new blng__Payment__c();
        pay.RecordTypeId = Schema.SObjectType.blng__Payment__c.getRecordTypeInfosByName().get('MH Payment').getRecordTypeId();
        pay.blng__Account__c = acc.Id;
        pay.blng__Amount__c = 100.00;
        pay.blng__PaymentDate__c = Date.today();
        pay.blng__PaymentType__c = 'Check';
        pay.blng__Status__c = 'Posted';
        insert pay;
     
        invoice.blng__InvoiceStatus__c = 'Posted';
        update invoice;
        
     Test.startTest();
     Id batchJobId1 = Database.executeBatch(new BatchInvoiceAutoAllocation(String.valueOf(acc.Id)), 1);
     Test.stopTest();
    }
    
    static testMethod void testMethod2(){
     Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
       Cls_UtilTestClass util = new Cls_UtilTestClass();
       Account acc = util.getAccount();
       acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
       update acc;
       Contact con = util.getContact(acc.Id);
       Opportunity opp = util.getOpportunity(acc.Id , con.Id);
       
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Professional Profile', objBR, objRR, objTR, 1);
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 500.00);
                
        Order ord = new Order();
        ord.RecordtypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';
        ord.EffectiveDate = Date.today();
        ord.EndDate = system.today() + 30;
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.blng__BillingDayOfMonth__c = '1';
        insert ord;
        
        List<OrderItem> ottList = new List<OrderItem>();
        OrderItem oddItem = new OrderItem();
        oddItem.blng__BillingRule__c = objBR.Id;
        oddItem.blng__RevenueRecognitionRule__c = objRR.Id;
        oddItem.blng__TaxRule__c = objTR.Id;
        oddItem.OrderId = ord.Id;
        oddItem.PricebookEntryId = objPBEntry.Id;
        oddItem.UnitPrice = 240;
        oddItem.Quantity = 9;
        oddItem.SBQQ__DefaultSubscriptionTerm__c=1;
        oddItem.StatusCheck__c = false;
        insert oddItem;
        
        ord.Status = 'Activated';
        ord.Activateorder__c=true;
        update ord;
        
        
        /*blng__Invoice__c invoice = new blng__Invoice__c(blng__Account__c=acc.id,blng__Order__c = ord.id);
        insert invoice;*/
        
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.RecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('MH Invoice').getRecordTypeId();
        invoice.blng__Account__c = acc.Id;
        invoice.blng__Order__c = ord.Id;
        insert invoice;
        
        
        blng__InvoiceLine__c singleinvline = new blng__InvoiceLine__c ();
        
        singleinvline.blng__Invoice__c = invoice.id;
        singleinvline.blng__StartDate__c = date.today();
        singleinvline.blng__EndDate__c = date.Today() + 365;
        //singleinvline.blng__UnitPrice__c = 300.00;
        //singleinvline.blng__Quantity__c = 1;
        //singleinvline.blng__TotalAmount__c = 300.00;
        singleinvline.blng__OrderProduct__c = oddItem.Id;
        
        insert singleinvline;
        //singleinvline.blng__InvoiceLineStatus__c = 'Draft';
        //update singleinvline;
        
        invoice.blng__InvoiceStatus__c = 'Post In progress';
        update invoice;
        
        
      //  List<blng__InvoiceLine__c> invLineResult =[Select Id,blng__Balance__c,blng__TotalAmount__c,blng__UnitPrice__c from blng__InvoiceLine__c];
      //  System.debug('invLineResult========>'+invLineResult);
        
        DefaultPaymentAccount__c ddd = new DefaultPaymentAccount__c();
        ddd.Name = 'DefaultAccountRecord';
        ddd.Default_Account_ID__c = acc.ID;
        ddd.DefaultAccountNumber__c = '1000095499';
        ddd.PaymentAllocationRectypeID__c = '0123w0000026DqdAAE';
        ddd.PaymentRecordTypeID__c = '012F0000001K3Ld';
        ddd.USDCurrencyID__c = 'a03F0000009vD0D';
        insert ddd;
        blng__Payment__c pay = new blng__Payment__c();
        pay.RecordTypeId = Schema.SObjectType.blng__Payment__c.getRecordTypeInfosByName().get('MH Payment').getRecordTypeId();
        pay.blng__Account__c = acc.Id;
        pay.blng__Amount__c = 100.00;
        pay.blng__PaymentDate__c = Date.today();
        pay.blng__PaymentType__c = 'Check';
        pay.blng__Status__c = 'Posted';
        insert pay;
     
        invoice.blng__InvoiceStatus__c = 'Posted';
        update invoice;
     
     Test.startTest();
     Id batchJobId1 = Database.executeBatch(new BatchInvoiceAutoAllocation(), 1);
     Test.stopTest();
    }
}