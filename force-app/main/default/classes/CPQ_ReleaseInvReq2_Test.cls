@isTest
public class CPQ_ReleaseInvReq2_Test {
	//@testSetup static void setup() {
    
    public static testMethod void testMethodA() {
    	// Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        lstAcc[0].MH_Cust_Number__c = '1001570104';
        lstAcc[0].Avvo_CustomerID__c = '387513';
        update lstAcc[0];
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon = DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create ConsumptionSchedule 
        ConsumptionSchedule objCS = DataFactory.createConsumptionSchedule(objBR, objRR, objTR);
        
        // Create ConsumptionSchedule 
        ConsumptionRate objCR = DataFactory.creatConsumptionRate(objCS);
        
        objCS.IsActive = TRUE;
        update objCS;
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        lstProd[0].IsInventoried__c = TRUE;
        update lstProd[0];
        
        // Creaet Test Product Consumption Schedule
        ProductConsumptionSchedule objPCS = DataFactory.creatProductConsumptionSchedule(objCS, lstProd[0]);
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        Attribute_Lines__c objAL = new Attribute_Lines__c();
        objAL.Attribute_Junction__c = objAR.Id;
        objAL.Attribute_Name__c = 'Aop';
        objAL.Attribute_Type__c = 'Picklist';
        objAL.Picklist_Value__c = 'Animal Law';
        objAL.Value_ID__c = '111';
        insert objAL;
        
        Attribute_Lines__c objAL1 = new Attribute_Lines__c();
        objAL1.Attribute_Junction__c = objAR.Id;
        objAL1.Attribute_Name__c = 'State';
        objAL1.Attribute_Type__c = 'Picklist';
        objAL1.Picklist_Value__c = 'NY';
        objAL.Value_ID__c = '32';
        insert objAL1;
        
        Attribute_Lines__c objAL2 = new Attribute_Lines__c();
        objAL2.Attribute_Junction__c = objAR.Id;
        objAL2.Attribute_Name__c = 'County';
        objAL2.Attribute_Type__c = 'Picklist';
        objAL2.Picklist_Value__c = 'Nassau';
        objAL.Value_ID__c = '600';
        insert objAL2;
        
        Attribute_Lines__c objAL3 = new Attribute_Lines__c();
        objAL3.Attribute_Junction__c = objAR.Id;
        objAL3.Attribute_Name__c = 'County';
        objAL3.Attribute_Type__c = 'String';
        objAL3.String_Value__c = 'USA';
        objAL.Value_ID__c = '1';
        insert objAL3;
        
        // Create Test Attribute Configuration - Practice Area
        Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Aop', 1, 'Picklist');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstProd[0], 'Picklist');
        
        
        // Create Test Attribute Configuration - Service State
        Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('State', 4, 'Picklist');
        ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, lstProd[0], 'Picklist');
        
        
        // Create Test Attribute Configuration - Service County
        Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('County', 6, 'Picklist');
        ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'Picklist');
        
        Attribute_Configuration__c objAC3 = DataFactory.createAtrConfiguration('Country', 6, 'Text');
        ProductAttribute__c objPA3 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'String');
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry( lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        test.startTest();
        // Create Test Quote Line 
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Quote Line').getRecordTypeId();
        //SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        SBQQ__QuoteLine__c objQLI=new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Product__c=lstProd[0].id;
        objQLI.SBQQ__Quote__c=lstQuote[0].Id;
        objQLI.contact__c = lstCon[0].Id;
        objQLI.RecordTypeId =quoteLineRecordTypeId;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SIN__c = '';
        objQLI.SFInventoryId__c = '33377788';
        objQLI.AvvoInventoryId__c = '33377788';
        objQLI.SBQQ__PricebookEntryId__c = pricebookId;
        objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
        
        //objQLI.Attribute_Relationship__c = objAR.Id;
        //Update objQLI;
        
        Restrict_Integration_Calls__c rss = new Restrict_Integration_Calls__c();
        rss.Name = 'Restrict';
        rss.Restrict_Callouts__c = false;
        insert rss;
        
        Integration_Endpoints__c inn = new Integration_Endpoints__c();
        inn.Name = 'ReleaseInventory';
        inn.MethodType__c = 'POST';
        inn.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inn.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inn.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        inn.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        inn.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        inn.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inn;
        
        Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
        oldMap.put(lstQuote[0].Id, lstQuote[0]);
        
        
        List<SBQQ__Quote__c> newLst = new List<SBQQ__Quote__c>();
        lstQuote[0].SBQQ__Status__c = 'Closed Lost';
        newLst.add(lstQuote[0]);
        update newLst;
        
        CPQ_ReleaseInvReq2.CPQ_ReleaseInvReq2(newLst, oldMap);
        
        
        
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        String userName = u.Username;
        String custNum = '1001570104';
        String avvoCuId = '387513';
        String accId = lstQuote[0].SBQQ__Account__c;
        String quoteID = lstQuote[0].Id;
        String quoteName = 'Q-386124';
        CPQ_ReleaseInvReq2.cpq_releaseInvRequest(quoteID, quoteName,custNum, avvoCuId, userName, accId);
        
        //String accId = lstQuote[0].SBQQ__Account__c;
        //String quoteID = lstQuote[0].Id;
        String rlsInvResponse = '<ReleaseInventoryResponse><Systems><System><Name>QUASI</Name><Url>https://quasi.staging.avvo.com/api/v1/orders/release_inventory?timestamp=1701360906%26publicKey=b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966</Url><HttpResponse><Code>200</Code><Body><ReleaseInventoryResponse><RequestId>a526s0000009aluAAA-11/30/2023 11:15 AM</RequestId><CustomerNumber>1001570104</CustomerNumber><QuoteId>Q-386124</QuoteId><Status>OK</Status><Messages><Message><Code/><Text/></Message></Messages></ReleaseInventoryResponse></Body><Headers><Header><Name>Authorization</Name><Value>3NjdrJSTvkTfeAaKNhla/rJnJ63y52bnB%2BfsHWEtCPo=&#124;1701360906</Value></Header><Header><Name>Content-Type</Name><Value>application/xml</Value></Header></Headers></HttpResponse></System><System><Name>OFS</Name><Url>https://stg-back-office-services.lawyers.com/services/orderbroker/v2/release_inventory?timestamp=1701360906%26publicKey=b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966</Url><HttpResponse><Code>200</Code><Body><ReleaseInventoryResponse xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance" xmlns:xsd="http://www.martindale.com/mhintegration/data-model"><RequestId>a526s0000009aluAAA-11/30/2023 11:15 AM</RequestId><CustomerNumber>1001570104</CustomerNumber><QuoteId>Q-386124</QuoteId><Status>Error</Status><Messages><Message><Code>Inv_Err_006</Code><Text>Inventory has not been released since we do not have this record: = Q-386124</Text></Message></Messages></ReleaseInventoryResponse></Body><Headers><Header><Name>Authorization</Name><Value>3NjdrJSTvkTfeAaKNhla/rJnJ63y52bnB%2BfsHWEtCPo=&#124;1701360906</Value></Header><Header><Name>Content-Type</Name><Value>application/xml</Value></Header></Headers></HttpResponse></System></Systems></ReleaseInventoryResponse>';
        List<String> rlsRspnsLst = new List<String>();
        rlsRspnsLst.add(rlsInvResponse);
        CPQ_ReleaseInvReq2.parseResponseXML_ReleaseInventoryResponse(rlsRspnsLst, accId, quoteID);
        test.stopTest();
    }
}