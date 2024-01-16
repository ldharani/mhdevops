/**@@
#APEX CLASS NAME       :   subscriptionLinesControllerTest
#CREATED BY            :   Serge Kandukuri
#DESCRIPTION           :   This is test class for subscriptionLinesController (Apex Class).
@@**/
@IsTest(SeeAllData=true)
public class subscriptionLinesControllerTest{
    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    /*
    @testSetup static void setup() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
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
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        
        // Create Attribute_Lines__c - Service State
       // Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'Service State', 'Multi-Picklist', '', 'Connecticut;Delaware;');
        
        // Create Attribute_Lines__c - Practice Area
       // Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      
      
        // Create Test Attribute Configuration - Practice Area
        //Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        //ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstProd[0], 'String');
        
        
        // Create Test Attribute Configuration - Service State
       // Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
       // ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, lstProd[0], 'Multi-Picklist');
        
        
        // Create Test Attribute Configuration - Service County
        //Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
        //ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'Multi-Picklist');
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c    .getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        objQLI.Attribute_Relationship__c = objAR.Id;
        update objQLI;
        
         Contract objContract = DataFactory.createContract(lstAcc[0], lstOpp[0]);
         
        SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], objContract, lstProd[0], objQLI);
        
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);
        
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
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
        
          
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = lstProd[0].id;
        objOI.PricebookEntryId=objPBEntry.id;
        objOI.SBQQ__ChargeType__c = 'Recurring';
        objOI.SBQQ__BillingFrequency__c = 'Monthly';
        objOI.SBQQ__BillingType__c = 'Arrears';
        objOI.blng__BillingRule__c = objBR.Id;
        objOI.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI.SBQQ__Activated__c = TRUE;
        objOI.blng__TaxRule__c = objTR.Id;
        objOI.SBQQ__DefaultSubscriptionTerm__c = 12;
        //objOI.Status__c = 'Draft';
        objOI.SBQQ__Status__c = 'Draft';
        objOI.Resume_Date__c  = system.today();
        objOI.Attribute_Relationship__c = objAR.Id;
        objOI.SBQQ__QuoteLine__c = objQLI.Id;
        insert objOI;
        
        
    }
    */
     /**@@
    #DESCRIPTION     : This is a test method used to cover add attribute functionality.
    #Paramaters      : None
    @@**/
    public static testMethod void testUnitMethod1(){
        
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOItem());
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        
        objOrder.Status = 'Activated';
        update objOrder;
        
        objOrder.SBQQ__Contracted__c = TRUE;
        update objOrder;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Contract objContract =  [SELECT Id FROM Contract LIMIT 1];
        
     
      

         
        SBQQ__Subscription__c objSub = [SELECT Id, SBQQ__Account__c FROM SBQQ__Subscription__c Where SBQQ__Account__c != Null LIMIT 1];
        
        String proName = 'Web Gold';
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive(proName);
        Insert proj;
        proj.Account__c = objAcc.Id;
        proj.Subscription__c = objSub.Id;
        update proj;
        
        Milestone1_Milestone__c milst = Milestone1_Test_Utility.sampleMilestone(proj);
        Insert milst;
        Boolean isBlocked = false;
        DateTime testDueDate = system.now();
        DateTime testKODate = system.now();
        Boolean isComplete = false;
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(milst.Id,testKODate,testDueDate,isComplete,isBlocked);
        insert testTask;
        
          
        objSub.Status__c = 'Cancelled';
        update objSub;
        proj.Status__c = 'Cancelled';
        update proj;

        test.stopTest();
    }
    
      public static testMethod void testUnitMethod3(){
        
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOItem());
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        
        objOrder.Status = 'Activated';
        update objOrder;
        
        objOrder.SBQQ__Contracted__c = TRUE;
        update objOrder;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Contract objContract =  [SELECT Id FROM Contract LIMIT 1];
        
     
        //test.startTest();

         
        SBQQ__Subscription__c objSub = [SELECT Id FROM SBQQ__Subscription__c Where SBQQ__Account__c != Null LIMIT 1];
        
        String proName = 'Web Gold';
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive(proName);
        Insert proj;
        proj.Account__c = objAcc.Id;
        proj.Subscription__c = objSub.Id;
        update proj;
        
        Milestone1_Milestone__c milst = Milestone1_Test_Utility.sampleMilestone(proj);
        Insert milst;
        Boolean isBlocked = false;
        DateTime testDueDate = system.now();
        DateTime testKODate = system.now();
        Boolean isComplete = false;
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(milst.Id,testKODate,testDueDate,isComplete,isBlocked);
        insert testTask;
        
        objSub.Status__c = 'Cancelled';
        update objSub;
        proj.Status__c = 'Cancelled';
        update proj;
        
        
        //test.stopTest();
        
        
                
        subscriptionLinesController.fetchSLI(objContract.Id, null);
        subscriptionLinesController.fetchSLI(objContract.Id, 'Active');
        
        Attribute_Relationship__c objAR = [SELECT Id FROM Attribute_Relationship__c LIMIT 1];
        subscriptionLinesController.retrieveAttributesLines(objAR.Id);
        
       test.stopTest();
    }
    
      public static testMethod void testUnitMethod2(){
        
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOItem());
        Order objOrder = [SELECT Id FROM Order LIMIT 1];
        
        objOrder.Status = 'Activated';
        update objOrder;
        
        objOrder.SBQQ__Contracted__c = TRUE;
        update objOrder;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Contract objContract =  [SELECT Id FROM Contract LIMIT 1];
        
     
        //test.startTest();

         
        SBQQ__Subscription__c objSub = [SELECT Id, SBQQ__Product__c FROM SBQQ__Subscription__c LIMIT 1];
        
        String proName = 'Web Gold';
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive(proName);
        Insert proj;
        proj.Account__c = objAcc.Id;
        proj.Subscription__c = objSub.Id;
        update proj;
        
        Milestone1_Milestone__c milst = Milestone1_Test_Utility.sampleMilestone(proj);
        Insert milst;
        Boolean isBlocked = false;
        DateTime testDueDate = system.now();
        DateTime testKODate = system.now();
        Boolean isComplete = false;
        Milestone1_Task__c testTask = Milestone1_Test_Utility.sampleTask(milst.Id,testKODate,testDueDate,isComplete,isBlocked);
        insert testTask;
        
        objSub.Status__c = 'Cancelled';
        update objSub;
        proj.Status__c = 'Cancelled';
        update proj;
        
        
        //test.stopTest();
        
        
                
        subscriptionLinesController.fetchSLI(objContract.Id, null);
        subscriptionLinesController.fetchSLI(objContract.Id, 'Active');
        
        Attribute_Relationship__c objAR = [SELECT Id FROM Attribute_Relationship__c LIMIT 1];
        subscriptionLinesController.retrieveAttributesLines(objAR.Id);
        
        subscriptionLinesController.retrieveProductAttributes(objSub.Id, objSub.SBQQ__Product__c);
        
        //List<Attribute_Lines__c> AttLines = [SELECT Id, Attribute_Type__c, String_Value__c, Long_text_value__c FROM Attribute_Lines__c LIMIT 1];
       // subscriptionLinesController.deleteAttributeItem(objAL2.Id, null);
        
        subscriptionLinesController.getPicklistvalues('Contract', 'Status__c', true);
        subscriptionLinesController.getPicklistvalues('Contract', 'Status__c', false);
        
        subscriptionLinesController.fetchSLIProductWithAttributeCount(objContract.Id);
        
        if(objSub != Null){
            subscriptionLinesController.getServiceStateWithCountiesNew(objSub.Id);
        }
        
        test.stopTest();
    }
    
    public static testmethod void  unittest3()
    {
         Attribute_Relationship__c objAR = [SELECT Id FROM Attribute_Relationship__c LIMIT 1];
       Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      
        subscriptionLinesController.deleteAttributeItem(objAL2.ID,null);
    }
}