/***********************************************************************************************************************
 * @author - SS
 * @date - 30 Mar 2022
 * @description - Test class
 * @testclass - Test_Batch_EvgPriceIncrease

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6878    SS            30/03/2022   John Mattheson  <T01>   Package relationship cascading on EG price increase batch job
************************************************************************************************************************/
@istest
public class Test_Batch_EvgPriceIncrease {
        @isTest()
	    public static void testRun1(){
            
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());

        
    
        Cls_UtilTestClass util = new Cls_UtilTestClass();
                
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
                
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
        objcont.Price_Increased__c = true;      
        insert objcont;
                
        objcont.Status__c = 'Evergreen in progress';
        update objcont;
        
        Batch_EvgIncreaseContractActive batch2 = new Batch_EvgIncreaseContractActive();
        Database.executebatch(new Batch_EvgIncreaseContractActive());
                
        objcont.Amend_Quote__c = quote.Id;
        update objcont;
        
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
        List<Product2> lstProd2 = DataFactory.createProduct('Ngage', objBR, objRR, objTR, 1);
         PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
                
        Id qliMAIntakeRectypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
                                      
       SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = quote.id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = qliMAIntakeRectypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        insert objQLI;

        SBQQ__QuoteLineGroup__c qlR = new SBQQ__QuoteLineGroup__c();
        qlR.SBQQ__Quote__c = quote.id;
        qlR.SBQQ__Number__c = 2;
        qlR.Name = 'Cloned Products';
        qlR.SBQQ__ListTotal__c = quote.SBQQ__NetAmount__c;
        qlR.SBQQ__CustomerTotal__c = quote.SBQQ__NetAmount__c;
        qlR.SBQQ__NetTotal__c = quote.SBQQ__NetAmount__c;
        insert qlR; 
        // Create PricebookEntry
       Test.startTest();
        
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
        
        objOrder.status='Activated';
        objOrder.ActivateOrder__c=true;
        update objOrder;
        
        objcont.SBQQ__Order__c=objOrder.id;
        update objcont;        
        
        
       
        
        Batch_PriceIncreaseContractasEvergreen batch3 = new Batch_PriceIncreaseContractasEvergreen();
        Database.executebatch(new Batch_PriceIncreaseContractasEvergreen());
        
         Batch_PriceIncreaseEGtoEG batch4 = new Batch_PriceIncreaseEGtoEG();
        Database.executebatch(new Batch_PriceIncreaseEGtoEG());
                Batch_PriceIncreaseEGtoEGInsert batch6 = new Batch_PriceIncreaseEGtoEGInsert();
        Database.executebatch(new Batch_PriceIncreaseEGtoEGInsert());
        Batch_ProceIncreaseClosedWon batch5 = new Batch_ProceIncreaseClosedWon();
        Database.executebatch(new Batch_ProceIncreaseClosedWon());   
               
        
        Test.stopTest();
     }
    
        @isTest()
    	public static void testRun2(){
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        Cls_UtilTestClass util = new Cls_UtilTestClass();
                
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
                
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
        objcont.Price_Increased__c = true;      
        insert objcont;
                
        objcont.Status__c = 'Evergreen in progress';
        update objcont;
        
        Batch_EvgIncreaseContractActive batch2 = new Batch_EvgIncreaseContractActive();
        Database.executebatch(new Batch_EvgIncreaseContractActive());
                
        objcont.Amend_Quote__c = quote.Id;
        update objcont;
        
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
        List<Product2> lstProd2 = DataFactory.createProduct('Ngage', objBR, objRR, objTR, 1);
         PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
                
        Id qliMAIntakeRectypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
                                      
       SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = quote.id;
        objQLI.SBQQ__Product__c = lstProd[0].Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.Id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = qliMAIntakeRectypeId;
        objQLI.Usage_List_Price__c = 100;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        insert objQLI;
            
         Set<Id> qLiIds = new Set<Id>();
         qLiIds.add(objQLI.Id);

        SBQQ__QuoteLineGroup__c qlR = new SBQQ__QuoteLineGroup__c();
        qlR.SBQQ__Quote__c = quote.id;
        qlR.SBQQ__Number__c = 2;
        qlR.Name = 'Cloned Products';
        qlR.SBQQ__ListTotal__c = quote.SBQQ__NetAmount__c;
        qlR.SBQQ__CustomerTotal__c = quote.SBQQ__NetAmount__c;
        qlR.SBQQ__NetTotal__c = quote.SBQQ__NetAmount__c;
        insert qlR; 
        // Create PricebookEntry
       Test.startTest();
        
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
        
        objOrder.status='Activated';
        objOrder.ActivateOrder__c=true;
        update objOrder;
        
        objcont.SBQQ__Order__c=objOrder.id;
        update objcont;        
        
        
       
        
        Batch_PriceIncreaseContractasEvergreen batch3 = new Batch_PriceIncreaseContractasEvergreen();
        Database.executebatch(new Batch_PriceIncreaseContractasEvergreen());
         Batch_PriceIncreaseContractasEvergreen batch4 = new Batch_PriceIncreaseContractasEvergreen();
        Database.executebatch(new Batch_PriceIncreaseContractasEvergreen(objcont.id));       
        
         Batch_SetOrderasContracted  batch7 = new Batch_SetOrderasContracted();
        Database.executebatch(new Batch_SetOrderasContracted());  
            
            Batch_UpdatePackageQuotelines batch8 = new Batch_UpdatePackageQuotelines(qLiIds);
             Database.executebatch(new Batch_UpdatePackageQuotelines(qLiIds));    
        
        Test.stopTest();
     }
}