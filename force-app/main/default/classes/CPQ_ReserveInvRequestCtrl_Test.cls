@isTest 
public class CPQ_ReserveInvRequestCtrl_Test {
	//@testSetup static void setup() {
    public static testMethod void testMethodA() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
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
        String qId = lstQuote[0].Id;
        
        // Create Test Quote Line 
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Quote Line').getRecordTypeId();
        //SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        SBQQ__QuoteLine__c objQLI=new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Product__c=lstProd[0].id;
        objQLI.SBQQ__Quote__c=lstQuote[0].Id;
        objQLI.contact__c = lstCon[0].Id;
        objQLI.RecordTypeId =quoteLineRecordTypeId;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SIN__c = null;
        objQLI.ReservedCount__c = null;
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
        inn.Name = 'PendInventory';
        inn.MethodType__c = 'POST';
        inn.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inn.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inn.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        inn.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        inn.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        inn.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inn;
        
        Integration_Endpoints__c inCheck = new Integration_Endpoints__c();
        inCheck.Name = 'CheckInventory';
        inCheck.MethodType__c = 'POST';
        inCheck.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inCheck.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inCheck.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        inCheck.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        inCheck.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        inCheck.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inCheck;
        
        String custNum = '555666677';
        String avvoCIId = '23456';
        String bbbb =  lstQuote[0].SBQQ__Account__r.Id;
        String userName = 'System Administrator';
        String cccc =  lstQuote[0].Name;
        
        Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
        oldMap.put(lstQuote[0].Id, lstQuote[0]);
        
        List<SBQQ__Quote__c> newLst = new List<SBQQ__Quote__c>();
        lstQuote[0].SBQQ__Status__c = 'Approved';
        newLst.add(lstQuote[0]);
        //update newLst;
        
        Set<Id> qLId = new Set<Id>();
        qLId.add(objQLI.Id);
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        qlList.add(objQLI);
        
        String checkInvResponse = '<CheckInventoryResponse><Systems><System><Name>QUASI</Name><Url>https://quasi.staging.avvo.com/api/v1/orders/check_inventory?timestamp=1694544247%26publicKey=b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966</Url><HttpResponse><Code>200</Code><Body><CheckInventoryResponse><RequestId>a523K000000D8PwQAK-9/12/2023 2:44 PM</RequestId><CustomerNumber>1000417530</CustomerNumber><AvvoCustomerId>19263</AvvoCustomerId><Status>OK</Status><QuoteId>Q-364300</QuoteId><QuoteLines><QuoteLine><QuoteLineId>a4y3K000000KftfQAC</QuoteLineId><AvvoInventoryId>923607</AvvoInventoryId><SalesforceInventoryId>923607</SalesforceInventoryId><Inventory><Available>2</Available><Requested>1</Requested></Inventory><Messages><Message><Code/><Text/></Message></Messages></QuoteLine></QuoteLines></CheckInventoryResponse></Body><Headers><Header><Name>Authorization</Name><Value>8IINKAXUHiVujQQ8ssvmQ5MXB99Ovn5taOacE2ZkoxI=|1694544247</Value></Header><Header><Name>Content-Type</Name><Value>application/xml</Value></Header></Headers></HttpResponse></System><System><Name>OFS</Name><Url>https://stg-back-office-services.lawyers.com/services/orderbroker/v2/check_inventory?timestamp=1694544247%26publicKey=b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966</Url><HttpResponse><Code>200</Code><Body><CheckInventoryResponse xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance" xmlns:xsd="http://www.martindale.com/mhintegration/data-model"><RequestId>a523K000000D8PwQAK-9/12/2023 2:44 PM</RequestId><CustomerNumber>1000417530</CustomerNumber><QuoteId>Q-364300</QuoteId><Status>Error</Status><QuoteLines><QuoteLine><QuoteLineId>a4y3K000000KftgQAC</QuoteLineId><SalesforceInventoryId>01667.656.1628.34.1</SalesforceInventoryId><Inventory><Available>1</Available><Requested>1</Requested></Inventory><Messages><Message><Code>Inv_Err_004</Code><Text>Inventory already reserved for this GEO/AOP for this customer: 1000417530</Text></Message></Messages></QuoteLine></QuoteLines></CheckInventoryResponse></Body><Headers><Header><Name>Authorization</Name><Value>8IINKAXUHiVujQQ8ssvmQ5MXB99Ovn5taOacE2ZkoxI=|1694544247</Value></Header><Header><Name>Content-Type</Name><Value>application/xml</Value></Header></Headers></HttpResponse></System></Systems></CheckInventoryResponse>';
        List<String> chkRspnsLst = new List<String>();
        chkRspnsLst.add(checkInvResponse);
        //String accID
        Test.StartTest();
        AmendQuoteRestructureClass.updateRecordStatus(lstQuote[0].Id,'Draft');
        AmendQuoteRestructureClass.getCurrentUserDetails();
        List<SBQQ__QuoteLine__c> qlRec = [select id,SBQQ__Quote__c from SBQQ__QuoteLine__c];
        system.debug('qlRec '+qlRec);
        List<SBQQ__Quote__c> qRec = [select id, SBQQ__Status__c, SBQQ__Account__c, SBQQ__Account__r.MH_Cust_Number__c,OwnerId,Owner.Email,Owner.Name,
                            SBQQ__Account__r.Avvo_CustomerID__c,(Select id, SBQQ__ProductName__c, SBQQ__Product__r.IsInventoried__c 
                            from SBQQ__LineItems__r) FROM SBQQ__Quote__c Where Id =: lstQuote[0].Id];
        system.debug('qRec '+qRec);
        String accId = qRec[0].SBQQ__Account__c;
        String quoteID = qRec[0].Id;
       // CPQ_ReserveInvRequestCtrl.checkQuoteStatusforPend(newLst, oldMap);
        
       
        CPQ_ReserveInvRequestCtrl.cpq_pendInventoryRequest(qLId,custNum,avvoCIId,userName,bbbb);
        CPQ_ReserveInvRequestCtrl resrvCtrl = new CPQ_ReserveInvRequestCtrl();
        CPQ_ReserveInvRequestCtrl.constructXML_PendInventory(qlList,custNum,avvoCIId,userName);
        CPQ_CheckInvRequestCtrl chkCtrl =  new CPQ_CheckInvRequestCtrl();
        chkCtrl.cpq_checkInventoryRequest(qLId,custNum,avvoCIId,userName,bbbb);
        CPQ_CheckInvRequestCtrl.parseResponseXML_PendInventoryResponse(chkRspnsLst, accId, quoteID);
        objQLI.Available__c = true;
        update objQLI;
        QuoteBannerController.getInvQLCheck(qId);
        Test.StopTest();
        
    }
    
    public static testMethod void testMethodB() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
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
        String qId = lstQuote[0].Id;
        
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
        objQLI.Error_Text__c ='test';
        insert objQLI;
        
        //objQLI.Attribute_Relationship__c = objAR.Id;
        //Update objQLI;
        
        Restrict_Integration_Calls__c rss = new Restrict_Integration_Calls__c();
        rss.Name = 'Restrict';
        rss.Restrict_Callouts__c = false;
        insert rss;
        
        Integration_Endpoints__c inn = new Integration_Endpoints__c();
        inn.Name = 'PendInventory';
        inn.MethodType__c = 'POST';
        inn.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inn.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inn.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        inn.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        inn.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        inn.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inn;
        
        Integration_Endpoints__c inCheck = new Integration_Endpoints__c();
        inCheck.Name = 'CheckInventory';
        inCheck.MethodType__c = 'POST';
        inCheck.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inCheck.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inCheck.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        inCheck.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        inCheck.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        inCheck.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inCheck;
        
        String custNum = '555666677';
        String avvoCIId = '23456';
        String bbbb =  lstQuote[0].SBQQ__Account__r.Id;
        String userName = 'System Administrator';
        String cccc =  lstQuote[0].Name;
        
        Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
        oldMap.put(lstQuote[0].Id, lstQuote[0]);
        
        List<SBQQ__Quote__c> newLst = new List<SBQQ__Quote__c>();
        lstQuote[0].SBQQ__Status__c = 'Approved';
        newLst.add(lstQuote[0]);
        //update newLst;
        
        Set<Id> qLId = new Set<Id>();
        qLId.add(objQLI.Id);
        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        qlList.add(objQLI);
        
        String checkInvResponse = '<CheckInventoryResponse><Systems><System><Name>QUASI</Name><Url>https://quasi.staging.avvo.com/api/v1/orders/check_inventory?timestamp=1694544247%26publicKey=b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966</Url><HttpResponse><Code>200</Code><Body><CheckInventoryResponse><RequestId>a523K000000D8PwQAK-9/12/2023 2:44 PM</RequestId><CustomerNumber>1000417530</CustomerNumber><AvvoCustomerId>19263</AvvoCustomerId><Status>OK</Status><QuoteId>Q-364300</QuoteId><QuoteLines><QuoteLine><QuoteLineId>a4y3K000000KftfQAC</QuoteLineId><AvvoInventoryId>923607</AvvoInventoryId><SalesforceInventoryId>923607</SalesforceInventoryId><Inventory><Available>2</Available><Requested>1</Requested></Inventory><Messages><Message><Code/><Text/></Message></Messages></QuoteLine></QuoteLines></CheckInventoryResponse></Body><Headers><Header><Name>Authorization</Name><Value>8IINKAXUHiVujQQ8ssvmQ5MXB99Ovn5taOacE2ZkoxI=|1694544247</Value></Header><Header><Name>Content-Type</Name><Value>application/xml</Value></Header></Headers></HttpResponse></System><System><Name>OFS</Name><Url>https://stg-back-office-services.lawyers.com/services/orderbroker/v2/check_inventory?timestamp=1694544247%26publicKey=b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966</Url><HttpResponse><Code>200</Code><Body><CheckInventoryResponse xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance" xmlns:xsd="http://www.martindale.com/mhintegration/data-model"><RequestId>a523K000000D8PwQAK-9/12/2023 2:44 PM</RequestId><CustomerNumber>1000417530</CustomerNumber><QuoteId>Q-364300</QuoteId><Status>Error</Status><QuoteLines><QuoteLine><QuoteLineId>a4y3K000000KftgQAC</QuoteLineId><SalesforceInventoryId>01667.656.1628.34.1</SalesforceInventoryId><Inventory><Available>1</Available><Requested>1</Requested></Inventory><Messages><Message><Code>Inv_Err_004</Code><Text>Inventory already reserved for this GEO/AOP for this customer: 1000417530</Text></Message></Messages></QuoteLine></QuoteLines></CheckInventoryResponse></Body><Headers><Header><Name>Authorization</Name><Value>8IINKAXUHiVujQQ8ssvmQ5MXB99Ovn5taOacE2ZkoxI=|1694544247</Value></Header><Header><Name>Content-Type</Name><Value>application/xml</Value></Header></Headers></HttpResponse></System></Systems></CheckInventoryResponse>';
        List<String> chkRspnsLst = new List<String>();
        chkRspnsLst.add(checkInvResponse);
        //String accID
        Test.StartTest();
        AmendQuoteRestructureClass.updateRecordStatus(lstQuote[0].Id,'Draft');
        AmendQuoteRestructureClass.getCurrentUserDetails();
        List<SBQQ__QuoteLine__c> qlRec = [select id,SBQQ__Quote__c from SBQQ__QuoteLine__c];
        system.debug('qlRec '+qlRec);
        List<SBQQ__Quote__c> qRec = [select id, SBQQ__Status__c, SBQQ__Account__c, SBQQ__Account__r.MH_Cust_Number__c,OwnerId,Owner.Email,Owner.Name,
                            SBQQ__Account__r.Avvo_CustomerID__c,(Select id, SBQQ__ProductName__c, SBQQ__Product__r.IsInventoried__c 
                            from SBQQ__LineItems__r) FROM SBQQ__Quote__c Where Id =: lstQuote[0].Id];
        system.debug('qRec '+qRec);
        String accId = qRec[0].SBQQ__Account__c;
        String quoteID = qRec[0].Id;
        CPQ_ReserveInvRequestCtrl.checkQuoteStatusforPend(newLst, oldMap);
        
       
        CPQ_ReserveInvRequestCtrl.cpq_pendInventoryRequest(qLId,custNum,avvoCIId,userName,bbbb);
        CPQ_ReserveInvRequestCtrl resrvCtrl = new CPQ_ReserveInvRequestCtrl();
        CPQ_ReserveInvRequestCtrl.constructXML_PendInventory(qlList,custNum,avvoCIId,userName);
        CPQ_CheckInvRequestCtrl chkCtrl =  new CPQ_CheckInvRequestCtrl();
        chkCtrl.cpq_checkInventoryRequest(qLId,custNum,avvoCIId,userName,bbbb);
        CPQ_CheckInvRequestCtrl.parseResponseXML_PendInventoryResponse(chkRspnsLst, accId, quoteID);
        CPQ_ReserveInvRequestCtrl.FkMethod();
        List<String> strlist = new List<String>();
        String str = '<?xml version="1.0" encoding="UTF-8"?> <ReserveInventoryResponse> <Systems> <System> <Name>QUASI</Name> <Url>https://quasi.staging.avvo.com/api/v1/orders/reserve_inventory?timestamp=1694458338%26publicKey=b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966</Url> <HttpResponse> <Code>200</Code> <Body> <ReserveInventoryResponse> <RequestId>a523K000000D8QVQA0-9/11/2023 2:52 PM</RequestId> <CustomerNumber>1000422006</CustomerNumber> <AvvoCustomerId>534</AvvoCustomerId> <Status>OK</Status> <QuoteId>0</QuoteId> <QuoteLines> <QuoteLine> <QuoteLineId>a4y3K000000KfzUQAS</QuoteLineId> <AvvoInventoryId>923349</AvvoInventoryId> <SalesforceInventoryId>923349</SalesforceInventoryId> <Inventory> <Available>1</Available> <Requested>1</Requested> <Reserved>1</Reserved> </Inventory> <Messages> <Message> <Code/> <Text/> </Message> </Messages> </QuoteLine> </QuoteLines> </ReserveInventoryResponse> </Body> <Headers> <Header> <Name>Authorization</Name> <Value>vxrV8PXXR9gzdVfP0IaxWEp1%2BGXkHsLnkcixSwgorCQ=|1694458338</Value> </Header> <Header> <Name>Content-Type</Name> <Value>application/xml</Value> </Header> </Headers> </HttpResponse> </System> <System> <Name>OFS</Name> <Url>https://stg-back-office-services.lawyers.com/services/orderbroker/v2/reserve_inventory?timestamp=1694458338%26publicKey=b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966</Url> <HttpResponse> <Code>200</Code> <Body> <ReserveInventoryResponse xmlns:xsi="http://www.martindale.com/mhintegration/data-model-instance" xmlns:xsd="http://www.martindale.com/mhintegration/data-model"> <RequestId>a523K000000D8QVQA0-9/11/2023 2:52 PM</RequestId> <CustomerNumber>1000422006</CustomerNumber> <QuoteId>Q-364303</QuoteId> <Status>Ok</Status> <QuoteLines> <QuoteLine> <QuoteLineId>a4y3K000000KfzVQAS</QuoteLineId> <InventoryId>001000422006.01667.00656.00000.01628.034.001</InventoryId> <SalesforceInventoryId>01667.656.1628.34.1</SalesforceInventoryId> <Inventory> <Available>1</Available> <Requested>1</Requested> <Reserved>1</Reserved> </Inventory> <Messages> <Message> <Code/> <Text/> </Message> </Messages> </QuoteLine> </QuoteLines> </ReserveInventoryResponse> </Body> <Headers> <Header> <Name>Authorization</Name> <Value>vxrV8PXXR9gzdVfP0IaxWEp1%2BGXkHsLnkcixSwgorCQ=|1694458338</Value> </Header> <Header> <Name>Content-Type</Name> <Value>application/xml</Value> </Header> </Headers> </HttpResponse> </System> </Systems> </ReserveInventoryResponse>';
        strlist.add(str);
        CPQ_ReserveInvRequestCtrl.parseResponseXML_PendInventoryResponse(strlist, accId, quoteID);
        objQLI.Available__c = true;
        update objQLI;
        QuoteBannerController.getInvQLCheck(qId);
        Test.StopTest();
        
    }
}