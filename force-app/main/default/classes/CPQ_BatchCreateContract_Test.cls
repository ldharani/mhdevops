@isTest
public class CPQ_BatchCreateContract_Test {
    static testMethod void BatchCreateContractTestMethod() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
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
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        Id pricebookId = Test.getStandardPricebookId();
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
        Set<Id> oddList = new Set<Id>();
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
        oddList.add(objOrder.Id);
        
        List<OrderItem> ottList = new List<OrderItem>();
        OrderItem oddItem = new OrderItem();
        oddItem.blng__BillingRule__c = objBR.Id;
        oddItem.blng__RevenueRecognitionRule__c = objRR.Id;
        oddItem.blng__TaxRule__c = objTR.Id;
        oddItem.OrderId = objOrder.Id;
        oddItem.PricebookEntryId = objPBEntry.Id;
        oddItem.UnitPrice = 240;
        oddItem.Quantity = 9;
        oddItem.blng__LegalEntity__c = legal.Id;
        insert oddItem;
        ottList.add(oddItem);
        
        OrderItem oddItemA = new OrderItem();
        oddItemA.blng__BillingRule__c = objBR.Id;
        oddItemA.blng__RevenueRecognitionRule__c = objRR.Id;
        oddItemA.blng__TaxRule__c = objTR.Id;
        oddItemA.OrderId = objOrder.Id;
        oddItemA.PricebookEntryId = objPBEntry.Id;
        oddItemA.UnitPrice = 240;
        oddItemA.SBQQ__RequiredBy__c = oddItem.Id;
        oddItemA.Quantity = 9;
        oddItemA.blng__LegalEntity__c = legal.Id;
        insert oddItemA;
        ottList.add(oddItemA);
        
        Test.startTest();
        
        CPQ_BatchCreateContract obj = new CPQ_BatchCreateContract(oddList);
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
    }
}