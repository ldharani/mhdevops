@isTest
public class Test_CancelHandleronQuote {
    
      public static testmethod void testmethodA(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
         Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon = DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Early Cancellation Fee', objBR, objRR, objTR, 1);
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        /*lstQuote[0].Marketing_Contact__c = lstCon[0].Id;
        lstQuote[0].Billing_Contact__c = lstCon[0].Id;
        lstQuote[0].SBQQ__PrimaryContact__c = lstCon[0].Id;
        update lstQuote;*/
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
       
        List<Attribute_Lines__c> attrLines = new List<Attribute_Lines__c>();
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        attrLines.add(objAL);
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today().adddays(6);
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
        
        GEO_Location__c geo = new GEO_Location__c(CountryName__c = 'USA', State_Abbrevation__c = 'NY',
                                                  County_Name__c = 'Albany', City_Name__c = 'Albany',
                                                  CountryID__c ='1', StateID__c='2',
                                                  County_ID__c = '3', City_ID__c='4');
        insert geo;
        
    
    
  
        
        
        test.startTest(); 
        
        Map<Id,SBQQ__QuoteLine__c> oldMap = new Map<Id,SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c lstQuote1 = [SELECT ID,Loss_Reasons__c,SBQQ__Quote__c,Cancelled__c FROM SBQQ__QuoteLine__c];
        oldMap.put(lstQuote1.Id, lstQuote1);
        
        List<SBQQ__QuoteLine__c> listQliNE = new List<SBQQ__QuoteLine__c>();
        lstQuote1.Cancelled__c = True;
        lstQuote1.Loss_Reasons__c = 'Price too High';
        update lstQuote1;
        listQliNE.add(lstQuote1);
        
        
        // Create Test Product
        List<Product2> lstQuotePRo = DataFactory.createProduct('Early Cancellation Fee', objBR, objRR, objTR, 1);
        
    
        
        //Product2 lstQuotePRo = [SELECT ID FROM Product2];
        //lstQuotePRo.Name = 'Early Cancellation Fee';
        //Update lstQuotePRo;
        
       /* Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstQuotePRo[0], 'String');
		*/
        
        
       // List<SBQQ__Quote__c> lstQuote = [SELECT ID FROM SBQQ__Quote__c];
        
        
        Map<Id,SBQQ__Quote__c> qOldMap = new Map<Id,SBQQ__Quote__c>();
        List<SBQQ__Quote__c> qList = [SELECT ID,WaiveECF__c,Cancelled__c,ECF__c,SBQQ__PriceBook__c FROM SBQQ__Quote__c limit 1];
        qOldMap.put(qList[0].Id, qList[0]);
        
        
        CancelHandleronQuote.fetchQLI(qList[0].Id);
        CancelHandleronQuote.handleCancelQuote(qList,qOldMap);
        CancelHandleronQuote.handleCancelQuoteLine(listQliNE,oldMap);
        CancelHandleronQuote.createOrUpdateAttribute(attrLines,qList[0].Id);
        CancelHandleronQuote.retrieveProductAttributes(listQliNE[0].Id,lstQuotePRo[0].Id);
        CancelHandleronQuote.deleteAttributeItem(objAL.Id,listQliNE[0].Id);
        CancelHandleronQuote.getAllQuoteLines(qList[0].Id);
        CancelHandleronQuote.cancelQoLns(listQliNE);
        CancelHandleronQuote.retrieveAttributesLines(objAR.Id);
        
        List<String> qlJson = new List<String>();
        qlJson.add(lstQuote1.Id);
        CancelHandleronQuote.fetchInnerProds(Json.serialize(qlJson));
        CancelHandleronQuote.fetchSuggestionsApex('Albany','Service City');
        CancelHandleronQuote.fetchSuggestionsApex('NY','Service State');
        CancelHandleronQuote.fetchSuggestionsApex('USA','Service Country');
        
        
        qList[0].Cancelled__c = True;
        qList[0].WaiveECF__c = 'No';
        update qList;
        
        CancelHandleronQuote classinstance = new CancelHandleronQuote();
        classinstance.FkMethod();
        
        test.stopTest();
    }
}