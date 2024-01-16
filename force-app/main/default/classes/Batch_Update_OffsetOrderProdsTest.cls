@IsTest
public class Batch_Update_OffsetOrderProdsTest {

     @testSetup static void setup() {
        DataFactory.loadCustomSettings();
 // Create Test Account
 
         Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
         
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
         List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
         system.debug('Test 5  ');
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon =DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);

        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
      
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry,quoteLineRecordTypeId, 1);
     
        test.startTest();
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);

        lstQuote[0].SBQQ__Ordered__c = TRUE;
        lstQuote[0].SBQQ__PrimaryContact__c = lstCon[0].ID;
        lstQuote[0].Marketing_Contact__c = lstCon[0].ID;
        lstQuote[0].Billing_Contact__c = lstCon[0].ID;
        Update lstQuote;
        
        test.stopTest();
         
    }
    
     public static testMethod void testUnitMethod1(){
        List<Order> ordList = [Select ID,Status,SBQQ__Contracted__c from Order limit 1 ];
        List<OrderItem> OIList = [Select Id,Order_Product_Name__c from OrderItem   limit 1];
        List<Contract> contrList = [Select Id from Contract limit 1 ];
        OIList[0].Status__c = 'Off set'; 
         Update OIList;
        System.debug('TEST VISHALA '+ordList.size()+ordList);
        System.debug('TEST VISHALA '+OIList.size()+OIList);
        System.debug('TEST VISHALA '+contrList.size()+contrList);  
        Test.startTest();
        Database.executeBatch(new Batch_Update_OffsetOrderProds(),10);
         Test.stopTest();
     }
}