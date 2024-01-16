@isTest
public class MDL_triggerOnContactHandler_Test {
    
    @testSetup static void setup() {
         // Load Custom settings
       
        DataFactory.loadCustomSettings();
        
        Campaign camp = new Campaign(Name='Avvo - Conversica Hot Lead');
        insert camp;
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        

        List<Account> lstAcc1 = DataFactory.createAccount('Test Acc1', accRecordTypeId, 1);
        
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
        
        // Create ConsumptionSchedule 
     //   ConsumptionSchedule objCS = DataFactory.createConsumptionSchedule(objBR, objRR, objTR);
        
        // Create ConsumptionSchedule 
    //    ConsumptionRate objCR = DataFactory.creatConsumptionRate(objCS);
        
    //    objCS.IsActive = TRUE;
    //    update objCS;
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        // Creaet Test Product Consumption Schedule
    //    ProductConsumptionSchedule objPCS = DataFactory.creatProductConsumptionSchedule(objCS, lstProd[0]);
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        
        // Create Attribute_Lines__c - Service State
    //    Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'Service State', 'Multi-Picklist', '', 'Connecticut;Delaware;');
        
        // Create Attribute_Lines__c - Practice Area
       Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      
      
        // Create Test Attribute Configuration - Practice Area
   //     Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
   //     ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstProd[0], 'String');
        
        
        // Create Test Attribute Configuration - Service State
    //    Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
    //    ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, lstProd[0], 'Multi-Picklist');
        
        
        // Create Test Attribute Configuration - Service County
    //    Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
    //    ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'Multi-Picklist');
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line 
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
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
        insert objOrder;
        
        
       
    }
    static testmethod void addcontact() 
    {
        
        //Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        List<Contact> newContact = new List<Contact>();
        Map<Id,Contact> oldConMap = new Map<Id,Contact>();
       Test.startTest();
        //Account objAcc = [SELECT Id FROM Account LIMIT 1];
        Account objAcc = new Account(name='TestAccAddCon');
        
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Open',
                          MN_Lead_Source__c = 'Marketing',
                          RecordTypeId = LeadRecordTypeId,First_Activity_Created__c = TRUE,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820',Email ='test@con.com'
                          );
       insert lead;
        
        
        
      //  Contact objCon = [Select Id,Actively_being_sequenced__c from contact limit 1];
        Account acc = new Account(name='TestAccAddCon',AE_Book__c=true);
        insert acc;
        Contact objCon = new Contact(FirstName= 'test', LastName = 'conLastName' + ' Mark Beamish',AE_Book__c='Remove from my book');
        objCon.Email = 'test@abc.com';
        objCon.Phone = '123456789';
        objCon.Related_To_Account__c=acc.id;
        insert objCon;

        System.Debug(objCon.Actively_being_sequenced__c);
        oldConMap.put(objCon.Id,objCon);
        objCon.Actively_being_sequenced__c = true;
       objCon.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        objCon.related_to_account__c = objAcc.Id;
        objCon.Avvo_Lead_Source__c='Avvo Website';
        System.Debug(objCon.Actively_being_sequenced__c);
        objCon.Email ='test@con.com';
        objCon.AE_Book__c = 'Add to waitlist';
        newContact.add(objCon);
        
       
        
        MDL_triggerOnContactHandler.updateAccOwnerToIntegration(newContact,oldConMap);
        MDL_triggerOnContactHandler.populateAccAvvoLeadSources(newContact,oldConMap);
        MDL_triggerOnContactHandler.populateAfterHotlead(newContact,oldConMap,true);
        MDL_triggerOnContactHandler.checkAdvertisingPartner(newContact,oldConMap,true);

        MDL_triggerOnContactHandler.offenseActiveInAE(newContact,oldConMap);
        
        objCon.Avvo_AI_Sales_Assistant_Date_Added__c = Date.Today();
        objCon.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = Date.Today();
        update objCon;
        newContact.add(objCon);
        MDL_triggerOnContactHandler.contactsequenceCheck(newContact,oldConMap);
        
        MDL_triggerOnContactHandler.populateAfterHotlead(newContact,oldConMap,false);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());

            Test.stopTest();
            
    }
    
     static testmethod void addcontact1() 
    {
        List<Contact> newContact = new List<Contact>();
        Map<Id,Contact> oldConMap = new Map<Id,Contact>();
       Test.startTest();
        Account objAcc = [SELECT Id FROM Account order by createdDate asc LIMIT 1];
        objAcc.Active_campaign__c = true;
        update objAcc;
        
        Account objAcc1 = [SELECT Id FROM Account order by createdDate desc LIMIT 1];
        
        Contact objCon = [Select Id,Actively_being_sequenced__c,Claimed_Method__c,Avvo_AI_Sales_Assistant__c,Avvo_AI_Sales_Assistant_Hot_Lead__c,related_to_account__c from contact limit 1];
        oldConMap.put(objCon.Id,objCon);
       objCon.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        objCon.Avvo_AI_Sales_Assistant_Hot_Lead__c = true;
        objCon.related_to_account__c = objAcc.Id;
        objCon.mailingpostalcode = '90245';
        objCon.Actively_being_sequenced__c = true;
        objCon.Email ='test@con.com';
        objCon.Claimed_Method__c = 'Admin';
         objCon.Related_To_Account__c = objAcc1.Id;
        newContact.add(objCon);
        
        
        
        objCon.Avvo_AI_Sales_Assistant_Date_Added__c = Date.Today();
        objCon.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = Date.Today();
        update objCon;
        newContact.add(objCon);
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        MDL_triggerOnContactHandler.populateAfterHotlead(newContact,oldConMap,false);
        MDL_triggerOnContactHandler.contactsequenceCheck(newContact,oldConMap);

            Test.stopTest();
            
    }
    public static testmethod void testCaseA(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
       
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
       
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> conLst = new List<Contact>();
        Map<Id,Contact> oldMap = new Map<Id,Contact>();
       Test.startTest();
        Contact con = new Contact(FirstName= 'test', LastName = 'conLastName');
        con.AccountId = lstAcc[0].Id;
        con.Email = 'test@abc.com';
        con.Phone = '123456789';
        con.RecordTypeId = conRecordTypeId;
        con.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        con.Avvo_AI_Sales_Assistant_Hot_Lead__c = false;
        con.Related_To_account__C = lstAcc[0].Id;        
        con.AE_Book__c = 'Add to my book';
        insert con;
       
        conLst.add(con);
        oldMap.put(con.Id, con);
       
        Contact conA = new Contact(FirstName= 'test', LastName = 'conLastNameAS');
        conA.AccountId = lstAcc[0].Id;
        conA.Email = 'test@abc.com';
        conA.Phone = '123456789';
        conA.RecordTypeId = conRecordTypeId;
        con.Related_To_account__C = lstAcc[0].Id;        
        con.AE_Book__c = 'Add to waitlist';
        insert conA;
       
        conLst.add(conA);
        oldMap.put(conA.Id, conA);
       
       
        
        MDL_triggerOnContactHandler.populateBeforeHotlead(conLst,oldMap,True);
        MDL_triggerOnContactHandler.populateBeforeHotlead(conLst,oldMap,False);
         MDL_triggerOnContactHandler.checkAdvertisingPartner(conLst,oldMap,False);
        MDL_triggerOnContactHandler.checkAdvertisingPartner(conLst,oldMap,true);
        MDL_triggerOnContactHandler.offenseActiveInAE(conLst,oldMap);
        
        
        Account objAcc = [SELECT Id FROM Account order by createdDate asc LIMIT 1];
        objAcc.Waitlist_Date_Time__c = null;
        objAcc.Waitlist__c = false;
        update objAcc;
        
       
        Test.stopTest();
        
       
    }
    public static testmethod void testCaseB(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
       
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Active_campaign__c = false;
        update lstAcc;
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> conLst = new List<Contact>();
        Map<Id,Contact> oldMap = new Map<Id,Contact>();
       Test.startTest();
        Contact con = new Contact(FirstName= 'test', LastName = 'conLastName');
        con.AccountId = lstAcc[0].Id;
        con.Email = 'test@abc.com';
        con.Phone = '123456789';
        con.RecordTypeId = conRecordTypeId;
        con.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        con.related_to_account__c = lstAcc[0].Id;
        insert con;
       
        conLst.add(con);
        oldMap.put(con.Id, con);
       
        Contact conA = new Contact(FirstName= 'test', LastName = 'conLastNameAS');
        conA.AccountId = lstAcc[0].Id;
        conA.Email = 'testsss@abc.com';
        conA.Phone = '123456789';
        conA.RecordTypeId = conRecordTypeId;
        conA.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        conA.Avvo_AI_Sales_Assistant_Hot_Lead__c = true;
        conA.related_to_account__c = lstAcc[0].Id;
        insert conA;
       
        conLst.add(conA);
        oldMap.put(conA.Id, conA);
       
       
        
        MDL_triggerOnContactHandler conClass = new MDL_triggerOnContactHandler();
        MDL_triggerOnContactHandler.populateAfterHotlead(conLst,oldMap,True);
        Test.stopTest();
    }
    
     public static testmethod void testCaseD(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
       
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Active_campaign__c = false;
        update lstAcc;
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> conLst = new List<Contact>();
        Map<Id,Contact> oldMap = new Map<Id,Contact>();
       Test.startTest();
        Contact con = new Contact(FirstName= 'test', LastName = 'conLastName');
        con.AccountId = lstAcc[0].Id;
        con.Email = 'test@abc.com';
        con.Phone = '123456789';
        con.RecordTypeId = conRecordTypeId;
        con.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        con.related_to_account__c = lstAcc[0].Id;
        insert con;
       
        conLst.add(con);
        oldMap.put(con.Id, con);
       
        Contact conA = new Contact(FirstName= 'test', LastName = 'conLastNameAS');
        conA.AccountId = lstAcc[0].Id;
        conA.Email = 'testsss@abc.com';
        conA.Phone = '123456789';
        conA.RecordTypeId = conRecordTypeId;
        conA.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        conA.Avvo_AI_Sales_Assistant_Hot_Lead__c = true;
        conA.related_to_account__c = lstAcc[0].Id;
        insert conA;
       
        conLst.add(conA);
        oldMap.put(conA.Id, conA);
       
       
        
        MDL_triggerOnContactHandler conClass = new MDL_triggerOnContactHandler();
        MDL_triggerOnContactHandler.populateAfterHotlead(conLst,oldMap,False);
        conClass.FkMethod();
       
        Test.stopTest();
    }
    /*
    public static testMethod void testContPMCreation(){
        DataFactory.loadCustomSettings();
        Id accParentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Account').getRecordTypeId();
        Account parentAcc = new Account(Name='IB Acc', RecordTypeId= accParentRecordTypeId);
        Insert parentAcc;
       
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        //List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        List<Account> lstAcc = new List<Account>();
        Set<id> accId = new Set<id>();
        Account ac = new Account();
        ac.Name = 'Test Mark Beamish';
        ac.ParentId = parentAcc.Id;
        ac.BillingStreet = 'test';
        ac.BillingCity =  'test';
        ac.BillingState =  'CA';
        ac.BillingCountry =  'USA';
        ac.BillingPostalCode =  '562';
        ac.RecordTypeId = accRecordTypeId;
        ac.ShippingStreet = 'test';
        ac.ShippingCity =  'test';
        ac.ShippingState =  'CA';
        ac.ShippingCountry =  'USA';
        ac.ShippingPostalCode =  '562';
        ac.Business_Unit__c = 'Martindale-Hubbell';
        lstAcc.add(ac);
        Insert lstAcc;
        accId.add(lstAcc[0].Id);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> conLst = new List<Contact>();
        Map<Id,Contact> newMap = new Map<Id,Contact>();
        Map<Id,Contact> oldMap = new Map<Id,Contact>();
       
        Contact con = new Contact(FirstName= 'test', LastName = 'conLastName');
        con.AccountId = lstAcc[0].Id;
        con.Email = 'test@abc.com';
        con.Phone = '123456789';
        con.RecordTypeId = conRecordTypeId;
        con.Avvo_AI_Sales_Assistant__c = 'Blaire Carson (Acquisition)';
        con.related_to_account__c = lstAcc[0].Id;
        con.CardNumber__c = '';
        insert con;
        //oldMap.put(con.Id, con);
        
        con.NameonCard__c= 'test';    
        con.CardNumber__c = '411111111111112';
        con.CVV__c = '123';
        con.CardExpirationMonth__c = '12';
        con.CardExpirationYear__c = '2025';
        con.CardType__c ='Visa';
        con.StreetAddress__c = '123 test st';
        con.City__c = 'Edison';
        con.State__c = 'NJ';
        con.ZipPostalCode__c = '08820';
        con.Country__c = 'USA';
        update con;
        
        conLst.add(con);
        //newMap.put(con.Id, con);
        
        
        Test.startTest();
        MDL_triggerOnContactHandler conHandler = new MDL_triggerOnContactHandler();
        conHandler.createPaymentMethod(conLst, newMap, oldMap);
        Test.stopTest();
        /*
        blng__PaymentMethod__c paymntmtd = new blng__PaymentMethod__c();
        paymntmtd.blng__Active__c = True;
        paymntmtd.blng__AutoPay__c = True;
        
        paymntmtd.blng__Account__c = lstAcc[0].Id;
        paymntmtd.Card_Number__c = con.CardNumber__c;
        paymntmtd.blng__Nameoncard__c = con.NameonCard__c;
        paymntmtd.blng__CardType__c = con.CardType__c;
        paymntmtd.blng__CardExpirationMonth__c = con.CardExpirationMonth__c;
        paymntmtd.blng__CardExpirationYear__c = con.CardExpirationYear__c;
        paymntmtd.blng__CVV__c = con.CVV__c;
        paymntmtd.blng__BillingStreet__c =con.StreetAddress__c;
        paymntmtd.blng__BillingCity__c = con.City__c;
        if((con.Country__c == 'US'|| con.Country__c == 'USA' ||con.Country__c == 'United States'||con.Country__c == 'U.S.A')|| test.isRunningTest()){
            paymntmtd.blng__BillingCountry__c = 'United States';
        }
        paymntmtd.blng__BillingStateProvince__c = con.State__c;
        paymntmtd.blng__BillingZipPostal__c = con.ZipPostalCode__c;
        paymntmtd.CreatedByDocuSign__c = con.OwnerId;
        paymntmtd.blng__PaymentType__c = 'Credit Card';
        //paymntmtd.blng__PaymentGateway__c = paymntGateWayId;
        paymntmtd.blng__BillingFirstName__c = con.FirstName;
        paymntmtd.blng__BillingLastName__c = con.LastName;
        paymntmtd.blng__BillingEmail__c = con.Email;
        Insert paymntmtd;
        
    }*/
    

   
}