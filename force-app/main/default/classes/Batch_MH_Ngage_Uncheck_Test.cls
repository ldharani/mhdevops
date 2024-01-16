/**@@
#TEST CLASS OF         :    Batch_MH_Ngage_Uncheck
#CREATED BY            :    VR
#TICKET                :    MHBS-6708

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************
@@**/

@IsTest
public class Batch_MH_Ngage_Uncheck_Test {
    
	/*@testSetup static void setup() {
        
        DataFactory.loadCustomSettings();
        
 		// Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
    
    	Id accRecordTypeIdParent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        List<Account> lstAccIB = DataFactory.createAccount('Test Acc IB', accRecordTypeIdParent, 1);
        lstAcc[0].ParentID = lstAccIB[0].ID;
    	Update lstAcc;


        DefaultPaymentAccount__c ddd = new DefaultPaymentAccount__c();
        ddd.Name = 'DefaultAccountRecord';
        ddd.Default_Account_ID__c = lstAcc[0].ID;
        ddd.DefaultAccountNumber__c = '1000095499';
        ddd.PaymentAllocationRectypeID__c = '012F0000001K3Lc';
        ddd.PaymentRecordTypeID__c = '012F0000001K3Ld';
        ddd.USDCurrencyID__c = 'a03F0000009vD0D';
        insert ddd;
        
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
        //List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        Product2 prod2 = new Product2(Name='Test Ngage',ProductCode='NgProd',Family='Ngage',IsActive=true,
               SBQQ__ChargeType__c='Recurring',SBQQ__ConfigurationEvent__c='Always',SBQQ__BillingFrequency__c='Monthly',
               SBQQ__BillingType__c = 'Advance',SBQQ__SubscriptionTerm__c = 1,
               SBQQ__NonDiscountable__c=true,SBQQ__PricingMethod__c='List',SBQQ__QuantityEditable__c=false,
               SBQQ__SubscriptionType__c='Renewable',SBQQ__PriceEditable__c=false,
               blng__BillingRule__c=objBR.ID,blng__RevenueRecognitionRule__c=objRR.ID,blng__TaxRule__c=objTR.ID);
        Insert prod2;
         List<Product2> lstProd = new List<Product2>();
    	 lstProd.add(prod2);
       	 
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
    	Test.startTest();
      
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
       // system.debug('DF Query'+DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1));
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('MH Quote Line').getRecordTypeId();
        
        // Create Test Quote Line
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry,quoteLineRecordTypeId, 1);
     
        
        // Create Test Opportunity Line Item
        DataFactory.createOpportunityLineItem(lstOpp[0], lstProd[0], objPBEntry, objQLI);

        lstQuote[0].SBQQ__Ordered__c = TRUE;
        lstQuote[0].SBQQ__PrimaryContact__c = lstCon[0].ID;
        lstQuote[0].Marketing_Contact__c = lstCon[0].ID;
        lstQuote[0].Billing_Contact__c = lstCon[0].ID;
        
    	 List<Order> ordList = [Select ID,Status,SBQQ__Contracted__c from Order  ];
    	
          Contract objContract = new Contract();
            objContract.AccountId = lstOpp[0].AccountId;
            objContract.SBQQ__Opportunity__c = lstOpp[0].Id;
            objContract.SBQQ__Quote__c = lstQuote[0].Id;
            objContract.Status = 'Draft';
            objContract.StartDate = Date.today();
            objContract.ContractTerm = 2;
    
          INSERT objContract;
			//objContract.Original_Order__c = ordList[0].ID;
            objContract.Status = 'Activated';
            objContract.Status__c = 'Active';
            update objContract;
        
      Id subRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('MH Subscriptions').getRecordTypeId();
        
        SBQQ__Subscription__c objSubs = new SBQQ__Subscription__c();
            objSubs.SBQQ__Account__c = lstAcc[0].Id;
            objSubs.SBQQ__Contract__c = objContract.Id; 
            objSubs.SBQQ__Product__c = lstProd[0].Id; 
            objSubs.SBQQ__Quantity__c = 1;
            objSubs.SBQQ__NetPrice__c = 100;
            objSubs.SBQQ__SubscriptionEndDate__c = Date.today().addYears(1);
            objSubs.SBQQ__QuoteLine__c = objQLI.Id;
         	objSubs.RecordTypeID = subRecordTypeId;
        insert objSubs;
    
		blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
    
        pmRec.blng__Account__c = lstAcc[0].Id;
        pmRec.blng__PaymentType__c = 'ACH';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '4111111111111111';
        pmRec.blng__Nameoncard__c = 'Jim';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'Visa';
        pmRec.Payment_Profile_ID__c = 'testProfileId';
    	pmRec.blng__BankRoutingCode__c = '123456789';
    	pmRec.blng__AutoPay__c = true;
    	pmRec.blng__BankAccountName__c = 'AccountName';
    	pmRec.blng__BankAccountNumber__c = '3456';
    	pmRec.blng__BankAccountType__c = 'Checking';
    	pmRec.blng__BankName__c = 'BankName';
    	pmRec.blng__BillingCity__c = 'City';
    	pmRec.blng__BillingCountry__c = 'Anguilla';
    	pmRec.blng__BillingEmail__c = 'testuser@test.com';
    	pmRec.blng__BillingFirstName__c = 'TestUser';
    	pmRec.blng__BillingLastName__c = 'TestUser';
    	pmRec.blng__BillingStateProvince__c = 'state';
    	pmRec.blng__BillingZipPostal__c = 'blng__BillingZipPostal__c';
    
        insert pmRec;
    
    		Test.stopTest();

    }*/
    
    @isTest
    public static void testRun1(){
    
       
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
        
    	Id accRecordTypeIdParent = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        List<Account> lstAccIB = DataFactory.createAccount('Test Acc IB', accRecordTypeIdParent, 1);
        lstAcc[0].ParentID = lstAccIB[0].ID;
    	Update lstAcc;
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Professional Profile', objBR, objRR, objTR, 1);
       // List<Product2> lstProd2 = DataFactory.createProduct('Ngage', objBR, objRR, objTR, 1);
               
test.starttest();
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
         List<Contract> contrList = [Select ID,Status__c from Contract limit 1];
         contrList[0].Status__c = 'Cancelled';
         Update contrList;
         Database.executeBatch(new Batch_MH_Ngage_Uncheck(),1);
        test.stoptest();
     }
       
 /*   @isTest()   
    public static void testUnitMethod2(){
       //  Database.executeBatch(new Batch_MH_Ngage_Association(),1);
       	 List<Contract> contrList = [Select ID,Status__c from Contract limit 1];
         contrList[0].Status__c = 'Cancelled';
         Update contrList;
        test.starttest();
         Database.executeBatch(new Batch_MH_Ngage_Uncheck(),1);
        test.stoptest();
    }   
    */
   
    

}