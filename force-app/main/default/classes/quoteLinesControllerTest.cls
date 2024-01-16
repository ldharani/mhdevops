/**@@
#APEX CLASS NAME       :   quoteLinesControllerTest
#DESCRIPTION           :   This is test class for quoteLinesController (Apex Class).
@@**/
@IsTest
public class quoteLinesControllerTest{
    /**@@
    #DESCRIPTION     : Creating test records
    #Paramaters      : None
    @@**/
    @testSetup static void setup() {
        Test.startTest();
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
        Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'Service State', 'Multi-Picklist', '', 'Connecticut;Delaware;');
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      
      
        // Create Test Attribute Configuration - Practice Area
        Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstProd[0], 'String');
        
        
        // Create Test Attribute Configuration - Service State
        Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
        ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, lstProd[0], 'Multi-Picklist');
        
        
        // Create Test Attribute Configuration - Service County
        Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
        ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'Multi-Picklist');
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();

        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        objQLI.Attribute_Relationship__c = objAR.Id;
        update objQLI;
        
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
        
        Test.stopTest();
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
        objOI.Status__c = 'Active';
        objOI.Resume_Date__c  = system.today();
        objOI.Attribute_Relationship__c = objAR.Id;
        objOI.SBQQ__QuoteLine__c = objQLI.Id;
        insert objOI;
        
    }
    
     /**@@
    #DESCRIPTION     : This is a test method used to cover add attribute functionality.
    #Paramaters      : None
    @@**/
    public static testMethod void testUnitMethod1(){
        AOPGeo_Products_List__c aopPrdlst = new AOPGeo_Products_List__c(Name='SEO Advanced',Product_Code__c = '30030');
        Insert aopPrdlst;
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        test.startTest();
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        quoteLinesController.fetchQLI(objQuote.Id);
        
        quoteLinesController.returnUsageStateandCounty(objQuote.Id);
        List<String> qList = new List<String>{objQuote.Id};
        quoteLinesController.returnSubUsageStateandCounty(qList);
        List<String> aopGeoProdCode = new List<String>();
        Boolean isAopGeoPro=false;
        aopGeoProdCode.add(aopPrdlst.Product_Code__c);
        quoteLinesController.wrapperAL wrapper= new quoteLinesController.wrapperAL();
        //wrapper.name = 'Test Wrapper';
        List<Attribute_Lines__c> AttLines = new List<Attribute_Lines__c>();
        Attribute_Lines__c attrL = new Attribute_Lines__c(Attribute_Name__c='Aop/Geo',Attribute_Junction__c = objAR.Id,String_Value__c = 'Bank Fraud;NJ;West Keansburg', Show_in_Docusign__c = true);
        Insert attrL;
        AttLines.add(attrL);
        Id aopgeoAttr = attrL.Id;
        String aopGeoAttrLines = '[{"aopGeoId": "'+aopgeoAttr+'","aopValue": "Bank Fraud","cityValue": "West Keansburg","objAL": {"Attribute_Junction__c": "'+objAR.Id+'","Attribute_Name__c": "Aop/Geo","Show_in_Docusign__c": true,"Attribute_Type__c": "String"},"stateValue": "NJ"}]';
        //List<Attribute_Lines__c> AttLines = [SELECT Id, Attribute_Name__c, Multi_Select_Value__c, Attribute_Type__c, String_Value__c, Long_text_value__c FROM Attribute_Lines__c];
        
        wrapper.aopGeoId = aopgeoAttr;
        String[] strVal = attrL.String_Value__c.split(';');
        wrapper.aopValue = strVal[0];
        wrapper.stateValue = strVal[1];
        wrapper.cityValue = strVal[2];
        
        quoteLinesController.createOrUpdateAttribute(AttLines, objQuote.Id, TRUE, aopGeoAttrLines);
        
        quoteLinesController.createOrUpdateAttribute(AttLines, objQuote.Id, FALSE, aopGeoAttrLines);
        
        SBQQ__QuoteLine__c objQLI = [SELECT Id, SBQQ__Product__c, SBQQ__ProductCode__c FROM SBQQ__QuoteLine__c LIMIT 1];
        
        system.debug('==objQLI=='+objQLI);
        quoteLinesController.retrieveProductAttributes(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.fetchQuoteStatus(objQLI.Id);
        quoteLinesController.fetchOppAttrIds(objQLI.Id);
        quoteLinesController.deleteAttributeItem(AttLines[0].Id, objQLI.Id);
        
        quoteLinesController.addNewProductAttributeforAopGeo(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.retrieveProductAttributesforAopGeo(objQLI.Id, objQLI.SBQQ__Product__c);
        // quoteLinesController.queryAllFields('Blng__Quote__c');
       
        String prdCode = objQLI.SBQQ__Product__c;
        
        //quoteLinesController.getPicklistvalues('SBQQ__Quote__c', 'SBQQ__BillingFrequency__c', true);
        quoteLinesController.getPicklistvalues('SBQQ__Quote__c', 'SBQQ__BillingFrequency__c', false);
        
        quoteLinesController.fetchQLIProductWithAttributeCount(objQuote.Id);
        
        /*
        quoteLinesController.fetchSuggestionsApex('New York', 'Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York', prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'Service Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);

        quoteLinesController.fetchSuggestionsApex('New York', 'Xref Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        */
        quoteLinesController.fetchSuggestionsApex('New York', 'State', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        
        test.stopTest();
        quoteLinesController.fetchSuggestionsApex('New York', 'Service State', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Xref State', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'City', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Service City', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'County', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Service County', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Xref County', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Xref City', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Practice Area', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'AOP', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');

        quoteLinesController.getServiceStateWithCounties();
        quoteLinesController.getServiceStateWCoun(objQLI.Id);
        
        quoteLinesController.getServiceStateWithCountiesNew(objQLI.Id);
        /*
        List<String> lstStates = new List<String>();
        lstStates.add('New York');
        lstStates.add('Test');
        quoteLinesController.fetchServiceCountiesApex(lstStates);
        */
        
    }
    
    public static testMethod void testUnitMethod2(){
        test.startTest();
        AOPGeo_Products_List__c aopPrdlst = new AOPGeo_Products_List__c(Name='SEO Advanced',Product_Code__c = '30030');
        Insert aopPrdlst;
        List<String> aopGeoProdCode = new List<String>();
        Boolean isAopGeoPro=false;
        aopGeoProdCode.add(aopPrdlst.Product_Code__c);
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quoteLinesController.fetchQLI(objQuote.Id);
        quoteLinesController.returnUsageStateandCounty(objQuote.Id);
        List<String> qList = new List<String>{objQuote.Id};
        quoteLinesController.returnSubUsageStateandCounty(qList);
        quoteLinesController.wrapperAL wrapper= new quoteLinesController.wrapperAL ();
        //wrapper.name = 'Test Wrapper';
        List<Attribute_Lines__c> AttLines = new List<Attribute_Lines__c>();
        Attribute_Lines__c attrL = new Attribute_Lines__c(Attribute_Name__c='Aop/Geo',Attribute_Junction__c = objAR.Id,String_Value__c = 'Bank Fraud;NJ;West Keansburg', Show_in_Docusign__c = true);
        Insert attrL;
        AttLines.add(attrL);
        Id aopgeoAttr = attrL.Id;
        String aopGeoAttrLines = '[{"aopGeoId": "'+aopgeoAttr+'","aopValue": "Bank Fraud","cityValue": "West Keansburg","objAL": {"Attribute_Junction__c": "'+objAR.Id+'","Attribute_Name__c": "Aop/Geo","Show_in_Docusign__c": true,"Attribute_Type__c": "String"},"stateValue": "NJ"}]';
        //List<Attribute_Lines__c> AttLines = [SELECT Id, Attribute_Name__c, Multi_Select_Value__c, Attribute_Type__c, String_Value__c, Long_text_value__c FROM Attribute_Lines__c];
        quoteLinesController.createOrUpdateAttribute(AttLines, objQuote.Id, TRUE, aopGeoAttrLines);
        quoteLinesController.createOrUpdateAttribute(AttLines, objQuote.Id, FALSE, aopGeoAttrLines);
        SBQQ__QuoteLine__c objQLI = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c LIMIT 1];
        quoteLinesController.retrieveProductAttributes(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.addNewProductAttributeforAopGeo(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.retrieveProductAttributesforAopGeo(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.fetchQuoteStatus(objQLI.Id);
        quoteLinesController.fetchOppAttrIds(objQLI.Id);
        quoteLinesController.deleteAttributeItem(AttLines[0].Id, objQLI.Id);
       // quoteLinesController.queryAllFields('Blng__Quote__c');
       
        String prdCode = objQLI.SBQQ__Product__c;
        
        quoteLinesController.getPicklistvalues('SBQQ__Quote__c', 'SBQQ__BillingFrequency__c', true);
        //quoteLinesController.getPicklistvalues('SBQQ__Quote__c', 'SBQQ__BillingFrequency__c', false);
        
        quoteLinesController.fetchQLIProductWithAttributeCount(objQuote.Id);
        
        
        quoteLinesController.fetchSuggestionsApex('New York', 'Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York', prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Service Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Xref Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        /*
        quoteLinesController.fetchSuggestionsApex('New York', 'State', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'Service State', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'Xref State', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'City', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'Service City', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'County', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'Service County', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'Xref County', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'Xref City', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'Practice Area', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        quoteLinesController.fetchSuggestionsApex('New York', 'AOP', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode);
        */
        quoteLinesController.getServiceStateWithCounties();
        quoteLinesController.getServiceStateWCoun(objQLI.Id);
        
        quoteLinesController.getServiceStateWithCountiesNew(objQLI.Id);
        
        List<String> lstStates = new List<String>();
        lstStates.add('New York');
        lstStates.add('Test');
        quoteLinesController.fetchServiceCountiesApex(lstStates);
        
        test.stopTest();
    }
    
     /**@@
    #DESCRIPTION     : This is a test method used to cover add attribute functionality.
    #Paramaters      : None
    @@**/
    public static testMethod void testUnitMethod3(){
        test.startTest();
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quoteLinesController.returnUsageStateandCounty(objQuote.Id);
        
        SBQQ__QuoteLine__c objQLI = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c LIMIT 1];
        quoteLinesController.getServiceStateWithCountiesLatest(objQLI.Id);
        
        Attribute_Lines__c attrL = new Attribute_Lines__c(Attribute_Name__c='Service State',Attribute_Type__c = 'Picklist',Attribute_Junction__c = objAR.Id,String_Value__c = 'NJ', Show_in_Docusign__c = true);
        Insert attrL;
        
        quoteLinesController.retrieveProductAttributes(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.fetchQuoteStatus(objQLI.Id);
        quoteLinesController.fetchOppAttrIds(objQLI.Id);
        quoteLinesController.deleteAttributeItem(attrL.Id, objQLI.Id);
        
        quoteLinesController.addNewProductAttributeforAopGeo(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.retrieveProductAttributesforAopGeo(objQLI.Id, objQLI.SBQQ__Product__c);
        
        test.stopTest();
    }
    
    public static testMethod void testUnitMethod4(){
        test.startTest();
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        SBQQ__Quote__c objQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quoteLinesController.returnUsageStateandCounty(objQuote.Id);
        
        List<Attribute_Lines__c> AttLines = new List<Attribute_Lines__c>();
        Attribute_Lines__c attrL = new Attribute_Lines__c(Attribute_Name__c='Country',Attribute_Junction__c = objAR.Id,String_Value__c = 'USA', Show_in_Docusign__c = true);
        Insert attrL;
        AttLines.add(attrL);
        Id aopgeoAttr = attrL.Id;
        String aopGeoAttrLines = 'null';
        Attribute_Lines__c attrL2 = new Attribute_Lines__c(Attribute_Name__c='Service State',Attribute_Junction__c = objAR.Id,Multi_Select_Value__c = 'NJ;NY;', Show_in_Docusign__c = true, Attribute_Type__c = 'Multi-Picklist');
        AttLines.add(attrL2);
        Upsert AttLines;
        
        quoteLinesController.createOrUpdateAttribute(AttLines, objQuote.Id, TRUE, aopGeoAttrLines);
        //quoteLinesController.createOrUpdateAttribute(AttLines, objQuote.Id, FALSE, aopGeoAttrLines);
        SBQQ__QuoteLine__c objQLI = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c LIMIT 1];
        quoteLinesController.retrieveProductAttributes(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.addNewProductAttributeforAopGeo(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.retrieveProductAttributesforAopGeo(objQLI.Id, objQLI.SBQQ__Product__c);
        quoteLinesController.fetchQuoteStatus(objQLI.Id);
        quoteLinesController.fetchOppAttrIds(objQLI.Id);
        quoteLinesController.deleteAttributeItem(AttLines[0].Id, objQLI.Id);
       // quoteLinesController.queryAllFields('Blng__Quote__c');
       
        String prdCode = objQLI.SBQQ__Product__c;
        
        quoteLinesController.getPicklistvalues('SBQQ__Quote__c', 'SBQQ__BillingFrequency__c', true);
        quoteLinesController.fetchQLIProductWithAttributeCount(objQuote.Id);
        quoteLinesController.fetchSuggestionsApex('New York', 'Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York', prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Service Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.fetchSuggestionsApex('New York', 'Xref Country', 'USA', 'New York', 'New York', 'New York', 'New York', 'New York',prdCode,'Nassau');
        quoteLinesController.getServiceStateWithCounties();
        quoteLinesController.getServiceStateWCoun(objQLI.Id);
        
        quoteLinesController.getServiceStateWithCountiesNew(objQLI.Id);
        
        List<String> lstStates = new List<String>();
        lstStates.add('New York');
        lstStates.add('Test');
        quoteLinesController.fetchServiceCountiesApex(lstStates);
        test.stopTest();
        
    }
}