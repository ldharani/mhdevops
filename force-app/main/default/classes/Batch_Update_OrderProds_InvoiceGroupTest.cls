/* 
* Class Name   : Batch_Update_OrderProds_InvoiceGroupTest    
* Test Class Of: Batch_Update_OrderProds_InvoiceGroup
* Description  : Create the batch job update Invoice Group & Invoice Group ID
* Developed By : VR
* Ticket       : MHBS-6933
*  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************

*/

@IsTest
public class Batch_Update_OrderProds_InvoiceGroupTest {
    
    @testSetup static void setup() {
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();        
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        test.startTest();  
        
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
        
        objOrder.status='Activated';
        objOrder.ActivateOrder__c=true;
        update objOrder;
        
        objcont.SBQQ__Order__c=objOrder.id;
        update objcont;
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Batch_Update_OrderProds_InvoiceGroup orItems = New Batch_Update_OrderProds_InvoiceGroup();
        
        Database.QueryLocator ql = orItems.start(null);
        orItems.execute(null,ottList);
        orItems.Finish(null);
        test.stopTest();
    }
    
    @isTest()
    public static void testUnitMethod1(){
        test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2()); 
        Database.executeBatch(new Batch_Update_OrderProds_InvoiceGroup(),1);
        test.stopTest();
    }
}