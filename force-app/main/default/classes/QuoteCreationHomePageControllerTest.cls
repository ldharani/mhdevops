@isTest
public class QuoteCreationHomePageControllerTest {
    
    @testSetup static void setup() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account(Name = 'Test', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId());
        insert acc;
        Account acc2 = new Account(Name = 'Test', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId());
        insert acc2;
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Related_To_Account__c = acc.Id);
        insert con;
        AccountContactRelation accCon = new AccountContactRelation(AccountId = acc2.Id, ContactId = con.Id);
        insert accCon;
        Opportunity opp = new Opportunity(StageName = 'Prospect', CloseDate = System.today(), Name = 'Test', AccountId = acc.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId());
        insert opp;
        blng__BillingRule__c bRule = DataFactory.createBillingRule();
        blng__RevenueRecognitionRule__c bRev = DataFactory.createRevenueRecognitionRule();
        blng__TaxRule__c bTRule = DataFactory.createTaxRule();
        List<Product2> prds = new List<Product2>();
        prds.add(new Product2(Name = 'Avvo.com Sponsored Listings', Family = 'Advertising', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Avvo.com Banner Ads', Family = 'Listings', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod3', Family = 'Web Services', Productcode = '11017', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod4', Family = 'Listings', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod5', Family = 'Advertising', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod6', Family = 'Web Services', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod7', Family = 'Advertising', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod8', Family = 'Listings', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod9', Family = 'Web Services', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod10', Family = 'Listings', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        prds.add(new Product2(Name = 'Prod11', Family = 'Advertising', Productcode = '123', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionType__c = 'Renewable', SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Arrears', SBQQ__PricingMethod__c = 'List', blng__BillingRule__c = bRule.Id, blng__RevenueRecognitionRule__c = bRev.Id, blng__TaxRule__c = bTRule.Id));
        insert prds;
        List<Attribute_Configuration__c> configs = new List<Attribute_Configuration__c>();
        configs.add(new Attribute_Configuration__c(Name = 'AOP', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'Service Country', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'Service State', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'Service City', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'Service Street Address', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'Country', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'State', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'City', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'County', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'Service Account Name', AttributeType__c = 'Text'));
        configs.add(new Attribute_Configuration__c(Name = 'URL', AttributeType__c = 'Text'));
        insert configs;
        List<ProductAttribute__c> attrs = new List<ProductAttribute__c>();
        Integer i = 0;
        for(Product2 prd : prds) {
            attrs.add(new ProductAttribute__c(Product__c = prd.Id, AttributeName__c = 'AOP', AttributeType__c = 'String', AttributeConfiguration__c = configs[i].Id));
            i++;
        }
        insert attrs;
        List<SBQQ__SolutionGroup__c> sols = new List<SBQQ__SolutionGroup__c>();
        sols.add(new SBQQ__SolutionGroup__c(Name = 'Advertisements'));
        sols.add(new SBQQ__SolutionGroup__c(Name = 'Listings'));
        sols.add(new SBQQ__SolutionGroup__c(Name = 'Web Services'));
        insert sols;
        List<GEO_Location__c> geoLocations = new List<GEO_Location__c>();
        geoLocations.add(new GEO_Location__c(Country_Inv_Flag__c = 'Yes', CountryName__c = 'Test', CountryID__c = 'Test', RecordtypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByDeveloperName().get('M_H_GEO_Locations').getRecordTypeId()));
        geoLocations.add(new GEO_Location__c(State_Inv_Flag__c = 'Yes', State_Abbrevation__c = 'Test', stateId__c = 'Test1', CountryID__c = 'Test', RecordtypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByDeveloperName().get('M_H_GEO_Locations').getRecordTypeId()));
        geoLocations.add(new GEO_Location__c(County_Inv_Flag__c = 'Yes', stateId__c = 'Test', SalesRegionId__c = '123', County_ID__c = 'Test', County_Name__c = 'Test', State_Abbrevation__c = 'Co.', RecordtypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByDeveloperName().get('M_A_Geo_Locations').getRecordTypeId()));
        geoLocations.add(new GEO_Location__c(City_Inv_Flag__c = 'Yes', stateId__c = 'Test2', City_Name__c = 'Test', City_ID__c = 'Test', County_ID__c = 'Test', County_Name__c = 'Independent City', RecordtypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByDeveloperName().get('M_H_GEO_Locations').getRecordTypeId()));
        insert geoLocations;
        Pricebook2 pBook = new Pricebook2(Name = 'Martindale-Avvo Price Book', IsActive = true);
        insert pBook;
        PricebookEntry priceEntry = new PricebookEntry(Product2Id = prds[0].Id, IsActive = true, Pricebook2Id = Test.getStandardPricebookId(), UnitPrice = 123);
        insert priceEntry;
        SBQQ__Quote__c quo = new SBQQ__Quote__c(RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId(), SBQQ__Account__c = acc.Id, SBQQ__PricebookId__c = Test.getStandardPricebookId(), SBQQ__Opportunity2__c = opp.Id, SBQQ__StartDate__c = system.today(), SBQQ__EndDate__c = system.today().adddays(30), SBQQ__SubscriptionTerm__c = 12, SBQQ__Primary__c = True, SBQQ__Status__c = 'Approved', SBQQ__ExpirationDate__c = system.today().adddays(30), SBQQ__BillingFrequency__c = 'Monthly');
        insert quo;
        insert new SBQQ__QuoteLine__c(SBQQ__Quote__c = quo.id, SBQQ__Product__c = prds[0].Id, SBQQ__PricebookEntryId__c = priceEntry.Id, SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__Quantity__c = 1, SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BillingType__c = 'Advance', RecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId(), Usage_List_Price__c = 100, SBQQ__SubscriptionTerm__c = 1, skipFlows__c = true);
    }
    static testmethod void testMethodA() {
        test.starttest();
        List<Account> accs = QuoteCreationHomePageController.getAccounts();
        QuoteCreationHomePageController.selectedAccId = accs[0].Id;
        Id accId = QuoteCreationHomePageController.getAccountId();
        List<Account> accDetails = QuoteCreationHomePageController.getAccountDetails(accId);
        QuoteCreationHomePageController.getSearchResults();
        List<Product_List__mdt> pdList = QuoteCreationHomePageController.getAdTypes();
        List<Aop_Geo_Table__mdt> tableList = QuoteCreationHomePageController.getAOPList();
        
        List<Account> searchTextAccs = QuoteCreationHomePageController.findAccounts('Test');
        List<Account> searchNumAccs = QuoteCreationHomePageController.findAccounts('1234');
        List<Contact> cons = QuoteCreationHomePageController.getContacts(accId); 
        List<Object> countries = QuoteCreationHomePageController.getMapCountryValues();
        List<Object> states = QuoteCreationHomePageController.getMapStateValues('Test');
        List<Object> counties = QuoteCreationHomePageController.getMapCountyValues('Test');
        List<Object> cities = QuoteCreationHomePageController.getMapCityValues('Test', true, true);
        QuoteCreationHomePageController.getProductListings();
        List<Contact> conDetails = QuoteCreationHomePageController.getContactDetails(accId);
        List<Contact> searchTextCons = QuoteCreationHomePageController.getContactDetailsSearch('Test', 'Test');
        List<Contact> searchNumCons = QuoteCreationHomePageController.getContactDetailsSearch('123', 'Test');
        List<SBQQ__QuoteLine__c> quoLines = QuoteCreationHomePageController.getQuoteDetails(accId);
        QuoteCreationHomePageController.getOpenQuotesUnderAccount(accs[1]);
        QuoteCreationHomePageController.getQuoteDetailsToSave(new List<Id> {}, 'Test', 'true', 'Test', 'Test', 'Test', 'Test');
        List<SBQQ__QuoteLine__c> quoLineDetails = QuoteCreationHomePageController.getQuoteLineDetails(new List<Id>(), 'Test', 'Test', true);
        Map<String,String> qLossReasons = QuoteCreationHomePageController.getQLLossReasonFieldValue();
        QuoteCreationHomePageController.modifyAmendmentQuote(Null, JSON.serialize(new List<Map<String,Object>>()));
        Cart__c cart = new Cart__c(OwnerId = UserInfo.getUserId());
        insert cart;
        List<Cart_Line_Item__c> clis = new List<Cart_Line_Item__c>();
        clis.add(new Cart_Line_Item__c(Name = 'Prod3', Cart__c = cart.Id, AOP__c = '123', CountyId__c = '123', CityId__c = '123', StateId__c = '123', AvvoInventoryId__c = '123', Price__c = '123'));
        clis.add(new Cart_Line_Item__c(Name = 'Prod4', Cart__c = cart.Id, CountyId__c = '123', CityId__c = '123', StateId__c = '123', AvvoInventoryId__c = '123', Price__c = '123'));
        insert clis;
        QuoteCreationHomePageController.saveQuote(Null, clis, accId);
        List<SBQQ__Quote__c> quos = [SELECT Id FROM SBQQ__Quote__c];
        SBQQ__Quote__c quo = quos[0];
        List<SBQQ__QuoteLine__c> qLines = [SELECT Id FROM SBQQ__QuoteLine__c];
        SBQQ__QuoteLine__c qLine = qLines[0];
        List<Product2> prds = [SELECT Id FROM Product2];
        Product2 prd = prds[0];
        String pRes = '[{ "Id" : "'+qLine.Id+'", "ProductId" : "'+prd.Id+'", "Quantity" : "2", "Price" : "123", "QuoteId" : "'+quo.Id+'", "StartDate" : "2022-01-01", "LossReasons" : "123", "isModified" : "yes"}]';
        //test.starttest();
        QuoteCreationHomePageController.QLModification(pRes);
        QuoteCreationHomePageController.QLModificationWithAmendment(pRes, Null, clis, accId);
        test.stoptest();
    }
    
    static testmethod void testMethodB() {
        List<Account> accs = QuoteCreationHomePageController.getAccounts();
        QuoteCreationHomePageController.selectedAccId = accs[0].Id;
        Id accId = QuoteCreationHomePageController.getAccountId();
        List<Object> custs = QuoteCreationHomePageController.getCustData('Preferred National Results', 'Test', 'Test', 'Test', 'Test', 'Test');
        List<Object> lossReasons = QuoteCreationHomePageController.getLossReasonsList();
        Boolean qCheck = QuoteCreationHomePageController.checkNewQuoteLinesInQuote(Null);
    }
    
    static testmethod void testMethodC() {
        List<Account> accs = QuoteCreationHomePageController.getAccounts();
        QuoteCreationHomePageController.selectedAccId = accs[0].Id;
        Id accId = QuoteCreationHomePageController.getAccountId();
        List<Object> custs = QuoteCreationHomePageController.getCustData('Preferred State Results', 'Test', 'Test', 'Test', 'Test', 'Test');
    }
    
    static testmethod void testMethodD() {
        List<Account> accs = QuoteCreationHomePageController.getAccounts();
        QuoteCreationHomePageController.selectedAccId = accs[0].Id;
        Id accId = QuoteCreationHomePageController.getAccountId();
        List<Object> custs = QuoteCreationHomePageController.getCustData('Preferred City Results', 'Test', 'Test', 'Test', 'Test', 'Test');
    }
    
    static testmethod void testMethodE() {
        List<Account> accs = QuoteCreationHomePageController.getAccounts();
        QuoteCreationHomePageController.selectedAccId = accs[0].Id;
        Id accId = QuoteCreationHomePageController.getAccountId();
        List<Object> custs = QuoteCreationHomePageController.getCustData('Preferred County Results', 'Test', 'Test', 'Test', 'Test', 'Test');
    }
    
    static testmethod void testMethodF() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        insert new Integration_Endpoints__c(Name = 'Avvo Inventory', Endpoint_URL__c = 'http://example.com/example/test');
        List<Account> accs = QuoteCreationHomePageController.getAccounts();
        QuoteCreationHomePageController.selectedAccId = accs[1].Id;
        Id accId = QuoteCreationHomePageController.getAccountId();
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c];
        Test.startTest();
        List<Object> avvoCusts = QuoteCreationHomePageController.getAvvoCustData('Test');
        String avvoResults = QuoteCreationHomePageController.getAvvoResults(new Map<String,Object>{'Test' => 'Test'}, 'Test', 'Test');
        String results = QuoteCreationHomePageController.getResults(new Map<String,String>{'A' => '123'}, 'Test', 'Test', 'Test', 'Test');
        Map<String,Integer> searchResults = QuoteCreationHomePageController.getSearchCount('Test', 'Test', 'Test', 'Test');
        Test.stopTest();
    }
    static testmethod void testMethodG() {
        List<Account> accs = [SELECT Id FROM Account];
        Account acc = accs[0];
        List<Contact> cons = [SELECT Id FROM Contact];
        Contact con = cons[0];
        List<SBQQ__Quote__c> quos = [SELECT Id FROM SBQQ__Quote__c];
        //SBQQ__Quote__c quo = quos[0];
        List<SBQQ__QuoteLine__c> qLines = [SELECT Id FROM SBQQ__QuoteLine__c];
        //SBQQ__QuoteLine__c qLine = qLines[0];
        List<Map<String,Object>> prdData = new List<Map<String,Object>>();
        prdData.add(new Map<String,Object>{'product' => 'Prod3', 'customerId' => con.Id, 'Price' => 123});
        prdData.add(new Map<String,Object>{'product' => 'Prod4', 'customerId' => con.Id, 'Price' => 123});
        prdData.add(new Map<String,Object>{'product' => 'Prod5', 'customerId' => con.Id});
        List<Map<String,Object>> selData = new List<Map<String,Object>>();
        selData.add(new Map<String,Object>{'Domain' => 'Avvo', 'Region' => 'Test,Co.', 'product' => 'Sponsored Listing', 'SalesRegionId' => '123', 'Price' => 123});
        selData.add(new Map<String,Object>{'product' => 'Display', 'countryName' => 'United States of America', 'Region' => 'Test,Co.', 'Blocks' => '123', 'cityId' => '123', 'stateId' => 'Test', 'countyId' => '123', 'animated' => true, 'Price' => 123});
        selData.add(new Map<String,Object>{'Domain' => 'Avvo', 'Region' => 'Test,Co.', 'product' => 'Prod3', 'SalesRegionId' => '123', 'Price' => 123});
        selData.add(new Map<String,Object>{'product' => 'Prod4', 'countryName' => 'India', 'Region' => 'Test,Co.', 'Blocks' => '123', 'cityId' => '123', 'animated' => true, 'Price' => 123});
        selData.add(new Map<String,Object>{'Domain' => 'Avvo', 'Region' => 'Test,Co.', 'product' => 'Prod5', 'SalesRegionId' => '123', 'Price' => 123});
        selData.add(new Map<String,Object>{'product' => 'Prod6', 'countryName' => 'United States of America', 'Region' => 'Co.,Test', 'Blocks' => '123', 'stateId' => 'Test', 'animated' => true, 'Price' => 123});
        selData.add(new Map<String,Object>{'Domain' => 'Avvo', 'Region' => 'Test,Co.', 'product' => 'Prod7', 'SalesRegionId' => '123', 'Price' => 123});
        selData.add(new Map<String,Object>{'product' => 'Prod8', 'countryName' => 'United States of America', 'Region' => 'Test,Co.', 'Blocks' => '123', 'countyId' => '123', 'animated' => true, 'Price' => 123});
        selData.add(new Map<String,Object>{'Domain' => 'Avvo', 'Region' => 'Test,Co.', 'product' => 'Prod9', 'SalesRegionId' => '123', 'Price' => 123});
        selData.add(new Map<String,Object>{'product' => 'Prod10', 'countryName' => 'United States of America', 'Region' => 'Test,Co.', 'Blocks' => '123', 'cityId' => '123', 'stateId' => 'Test', 'countyId' => '123', 'animated' => true, 'Price' => 123});
        selData.add(new Map<String,Object>{'Domain' => 'Avvo', 'Region' => 'Test,Co.', 'product' => 'Prod11', 'SalesRegionId' => '123', 'Price' => 123});
        Test.startTest();
        QuoteCreationHomePageController.createNewQuote(JSON.serialize(selData), acc.Id, JSON.serialize(prdData));
        QuoteCreationHomePageController.createQuoteLinesProfProd(Null, acc.Id, JSON.serialize(prdData));
        Test.stopTest(); 
    }
    
    static testmethod void testmethodH() {
        List<Account> accs = [SELECT Id FROM Account];
        Account acc = accs[0];
        List<Contact> cons = [SELECT Id FROM Contact];
        Contact con = cons[0];
        Cart__c cart = new Cart__c(OwnerId = UserInfo.getUserId());
        insert cart;
        Cart_Line_Item__c cLine = new Cart_Line_Item__c(Name = 'Prod3', Cart__c = cart.Id);
        insert cLine;
        List<SBQQ__Quote__c> quos = [SELECT Id FROM SBQQ__Quote__c];
        //SBQQ__Quote__c quo = quos[0];
        List<SBQQ__QuoteLine__c> qLines = [SELECT Id FROM SBQQ__QuoteLine__c];
        //SBQQ__QuoteLine__c qLine = qLines[0];
        List<Map<String,Object>> prdData = new List<Map<String,Object>>();
        prdData.add(new Map<String,Object>{'product' => 'Avvo.com Sponsored Listings', 'customerId' => con.Id, 'Price' => 123});
        prdData.add(new Map<String,Object>{'product' => 'Avvo.com Banner Ads', 'customerId' => con.Id, 'Price' => 123});
        prdData.add(new Map<String,Object>{'product' => 'Prod3', 'customerId' => con.Id});
        List<Map<String,Object>> selData = new List<Map<String,Object>>();
        selData.add(new Map<String,Object>{'product' => 'Sponsored Listing', 'animated' => true, 'SalesRegionId' => '123', 'cityId' => '123', 'Price' => 123, 'Blocks' => '2'});
        selData.add(new Map<String,Object>{'product' => 'Display', 'animated' => true, 'SalesRegionId' => '123', 'countyId' => '123', 'Price' => 123, 'Blocks' => '2'});
        selData.add(new Map<String,Object>{'product' => 'Prod3', 'animated' => true, 'SalesRegionId' => '123', 'Price' => 123, 'Blocks' => '2'});
        Test.startTest();
        QuoteCreationHomePageController.addtoExistingquote(Null, JSON.serialize(selData), JSON.serialize(prdData), true, acc.Id);
        Test.stopTest(); 
    }
}