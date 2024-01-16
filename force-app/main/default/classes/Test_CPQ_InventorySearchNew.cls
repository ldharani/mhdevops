/*Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-8579    Bharath       22/05/2023                   <T01>   requests to SalesInventory Tool should have at least one product code
************************************************************************************************************************/
@isTest(SeeAllData=true)
public class Test_CPQ_InventorySearchNew {
//Lawyers.com Preferred State Results
    
    
    @isTest
    public static void testMethod3National(){
        //Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred National Results',Product_Name__c='Lawyers.com Preferred National Results',Product_Code__c='1920',Type__c ='National');
        Test.startTest();
        //insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred National Results';
        inv.selectedstatecity ='USA,NY,Albany'; 
        inv.selectedProductTypes.add('Lawyers.com Preferred National Results');
        Modified_CPQInventorySearchTool.countyList.add('Independent City');
        inv.runsearch();
        inv.dosearch();
        Test.stopTest(); 
    }
    
    @isTest
    public static void testMethod3County(){
        //Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred County Results',Product_Name__c='Lawyers.com Preferred County Results',Product_Code__c='123452',Type__c ='County');
        Test.startTest();
        //insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred County Results';
        inv.selectedstatecity ='USA,NY,Albany'; 
        inv.selectedProductTypes.add('Lawyers.com Preferred Banner Placements');
        inv.selectedProductTypes.add('Lawyers.com Preferred County Results');
        //line 852
        Modified_CPQInventorySearchTool.countyList.add('Independent City');

        inv.runsearch();
        inv.dosearch();
        Test.stopTest(); 
    }
    
    @isTest
    public static void testMethod3State(){
        //Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred State Results',Product_Name__c='Lawyers.com Preferred State Results',Product_Code__c='12345',Type__c ='State');
        Test.startTest();
        //insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred State Results';
        inv.selectedProductTypes.add('Lawyers.com Preferred State Results');
        inv.selectedstatecity ='USA,NY,Albany'; 
        inv.runsearch();
        inv.dosearch();
        Test.stopTest(); 
    }
    
    @isTest
    public static void testMethod3StateSCL4(){
        //Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred State Results',Product_Name__c='Lawyers.com Preferred State Results',Product_Code__c='12345',Type__c ='State');
        Test.startTest();
        //insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred State Results';
        inv.selectedstatecity =' Co.,USA,NY,Albany'; 
        inv.runsearch();
        inv.dosearch();
        Test.stopTest(); 
    }
    
    @isTest
    public static void testMethod3StateSCL2(){
        //Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred State Results',Product_Name__c='Lawyers.com Preferred State Results',Product_Code__c='12345',Type__c ='State');
        Test.startTest();
        //insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred State Results';
        inv.selectedProductTypes.add('Lawyers.com Preferred State Results');
        inv.selectedstatecity ='NY,Albany'; 
        inv.runsearch();
        //inv.dosearch();
        Test.stopTest(); 
    }
    
    @isTest
    public static void testMethod3City(){
        //Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred City Results',Product_Name__c='Lawyers.com Preferred City Results',Product_Code__c='123451',Type__c ='City');
        Test.startTest();
        //insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred City Results';
        inv.selectedstatecity ='USA,NY,Albany'; 
        inv.selectedProductTypes.add('Lawyers.com Preferred City Results');
        inv.runsearch();
        inv.dosearch();
        Test.stopTest(); 
    }
        @isTest
    public static void testMethod3City3(){
        //Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred City Results',Product_Name__c='Lawyers.com Preferred City Results',Product_Code__c='123451',Type__c ='City');
        Test.startTest();
        //insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred City Results';
        inv.selectedstatecity ='USA,NY'; 
        inv.selectedProductTypes.add('Lawyers.com Preferred City Results');
        inv.runsearch();
        inv.dosearch();
        Test.stopTest(); 
    }
    @isTest
    public static void testMethod3City2(){
        //Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred City Results',Product_Name__c='Lawyers.com Preferred City Results',Product_Code__c='123451',Type__c ='City');
        Test.startTest();
        //insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
        Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred City Results';
        inv.selectedstatecity ='USA'; 
        inv.selectedProductTypes.add('Lawyers.com Preferred City Results');
        //inv.runsearch();
        inv.dosearch();
        Test.stopTest(); 
    }
    @isTest
    public static void testMethod3Banner(){
        Test.startTest();
        Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred Banner',Product_Name__c='Lawyers.com Preferred Banner Placements',Product_Code__c='01920',Type__c ='City');
        //Test.startTest();
        insert pl;
        Modified_CPQInventorySearchTool inv = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
       // inv.resetParameters();
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred Banner Placements';
        inv.selectedProductTypes = new List<String>();
        inv.selectedProductTypes.add('Lawyers.com Preferred Banner Placements');
        inv.selectedProductTypes.add('Lawyers.com Preferred County Results');
        inv.selectedstatecity ='USA,NY,Albany,CA'; 
        
        inv.runsearch();
        inv.dosearch();
     //   inv.finalResults = new Map<String,List<ResultClass>>{'Lawyers.com Preferred National Results'=>(ResultClass:[aop='Lobbying', aop_id=669, available=0, city=null, city_id=null, country='United States of America', country_id=1, county=null, county_id=null, innerordersList=null, pended=0, product='Preferred National Results', product_id=1957, quota=1, searchcount=15, sold=1, state=null, state_id=null])};
        inv.getRenderPageBlockTable();
        Test.stopTest(); 
    }
    //

    
    @isTest
    public static void testMethod4(){
        Test.setMock(HttpCalloutMock.class, new GetSearchCountCalloutMockTest());
       // CPQ_InventorySearchNew.getSearchCount('aop','countryId','stateId','countyId','cityId');
        Modified_CPQInventorySearchTool.getSearchCount('729','countryId','stateId','countyId','102');
        
        Test.starttest();
        Id acc = [Select id from account where recordtype.developername = 'Nolo_Account' limit 1].Id;
        Modified_CPQInventorySearchTool.getRelatedOpenQuotes(acc);
        
        Product2 prod = [Select Id from Product2 Limit 1];
        
        Cart__c cart = new Cart__c();
        insert cart;
        cart.ownerId  = UserInfo.getUserId();
        List<Cart_Line_Item__c> cartLineItemlst =  new List<Cart_Line_Item__c>();
        Cart_Line_Item__c cli = new Cart_Line_Item__c();
        cli.Cart__c = cart.Id;
        cli.Country__c = 'USA';
        cli.AOP__c = 'Administrative';
        cli.CityStateCounty__c = 'New Jersey';
        cli.Price__c = '$10.00';
        cli.Product__c = prod.Id;
        insert cli;
        
        //Modified_CPQInventorySearchTool.createQuote(acc);
        Modified_CPQInventorySearchTool.QuoteCreationWrapper q = Modified_CPQInventorySearchTool.createQuote(acc);
        String jsonString = JSON.serialize(q);
        Modified_CPQInventorySearchTool.createQuoteLinesAsync(jsonString);
        Test.stoptest();
    }
    
     @isTest
    public static void testMethod5City(){
        //GEO_Location__c:{Id=a2W7j000000peDpEAI, Name=GEO-307825, RecordTypeId=0120G000000zre6QAA, City_ID__c=4, City_Name__c=Albany, CountryID__c=1, CountryName__c=USA, County_ID__c=3, County_Name__c=Albany, StateID__c=2, State_Abbrevation__c=NY}
        Test.setMock(HttpCalloutMock.class, new GetResultsByCityCalloutMockTest());
        //Map<String,String> productCodeMap = new Map<String,String> ();
        //productCodeMap.put('City','123451');
        //getResults(String aop,Map<String,String> productCodeMap,String countryId,String stateId,String countyId,String cityId);
        
        Product2 prod = [Select Id from Product2 Limit 1];
        
        String aop = '666';
        Map<String,String> productCodeMap = new Map<String,String>();
        productCodeMap.put('County','01910');
        //<T01> starts
        productCodeMap.put('State','12345');
        productCodeMap.put('National','1920');
        productCodeMap.put('City','123451');
        //<T01> ends
        String countryId = '1';
        String stateId = '51';
        String countyId = '3434';
        String cityId = '13411';
       Modified_CPQInventorySearchTool.getResults(aop,productCodeMap,countryId,stateId,countyId,cityId);
        Cart__c cart = new Cart__c();
        insert cart;
        cart.ownerId  = UserInfo.getUserId();
        List<Cart_Line_Item__c> cartLineItemlst =  new List<Cart_Line_Item__c>();
        Cart_Line_Item__c cli = new Cart_Line_Item__c();
        cli.Cart__c = cart.Id;
        cli.Country__c = 'USA';
        cli.AOP__c = 'Administrative';
        cli.CityStateCounty__c = 'New Jersey';
        cli.Price__c = '$10.00';
        cli.Product__c = prod.Id;
        insert cli;
        cartLineItemlst.add(cli);
        Modified_CPQInventorySearchTool.removeCartLineItems(cli);
    }
    
     @isTest
    public static void testMethod5LDC(){
        //GEO_Location__c:{Id=a2W7j000000peDpEAI, Name=GEO-307825, RecordTypeId=0120G000000zre6QAA, City_ID__c=4, City_Name__c=Albany, CountryID__c=1, CountryName__c=USA, County_ID__c=3, County_Name__c=Albany, StateID__c=2, State_Abbrevation__c=NY}
        Test.setMock(HttpCalloutMock.class, new GetResultsByCityCalloutMockTest2());
        Map<String,String> productCodeMap = new Map<String,String> ();
        productCodeMap.put('National','1920');
        //getResults(String aop,Map<String,String> productCodeMap,String countryId,String stateId,String countyId,String cityId)
        //Modified_CPQInventorySearchTool.getResults('630',productCodeMap,'1','2','3','4');
    }
    
    
     @isTest
    public static void testMethod5State(){
        //GEO_Location__c:{Id=a2W7j000000peDpEAI, Name=GEO-307825, RecordTypeId=0120G000000zre6QAA, City_ID__c=4, City_Name__c=Albany, CountryID__c=1, CountryName__c=USA, County_ID__c=3, County_Name__c=Albany, StateID__c=2, State_Abbrevation__c=NY}
       test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetResultsByCityCalloutNLMockTest());
        Map<String,String> productCodeMap = new Map<String,String> ();
        productCodeMap.put('State','12345');
        test.stoptest();
        //getResults(String aop,Map<String,String> productCodeMap,String countryId,String stateId,String countyId,String cityId)
        //Modified_CPQInventorySearchTool.getResults('630',productCodeMap,'1','2','3','4');
    }
    
   
    
     @isTest
    public static void testMethod6(){
        
        Modified_CPQInventorySearchTool.refreshcountyList(null,'NY');
        Modified_CPQInventorySearchTool.refreshcityList(null,'NY','Martindale.com Preferred County Results',false);
        Modified_CPQInventorySearchTool.refreshStateList('USA');
        Test.startTest();
        
        Product2 prod = [Select Id from Product2 Limit 1];
        
        Cart__c cart = new Cart__c();
        insert cart;
        cart.ownerId  = UserInfo.getUserId();
        List<Cart_Line_Item__c> cartLineItemlst =  new List<Cart_Line_Item__c>();
        Cart_Line_Item__c cli = new Cart_Line_Item__c();
        cli.Cart__c = cart.Id;
        cli.Country__c = 'USA';
        cli.AOP__c = 'Administrative';
        cli.CityStateCounty__c = 'New Jersey';
        cli.Price__c = '$10.00';
        cli.Product__c = prod.Id;
        insert cli;
        cartLineItemlst.add(cli);        
        
        List<SBQQ__Quote__c> quo = [select id from sbqq__quote__c where Sbqq__Account__r.recordtype.developername = 'Nolo_Account' and (SBQQ__Status__c = 'Draft' OR SBQQ__Status__c = 'Approved') and Subscription_type__c != 'Renewal' and Subscription_type__c != 'Evergreen' and Subscription_type__c != 'Rebase Evergreen'and Subscription_type__c != 'EG 2 EG' and recordtype.name != 'Offset Quote' and recordtype.name != 'MH Cancel Quote' limit 1];
        Modified_CPQInventorySearchTool.addtoExistingquote(quo[0].Id);
        Test.stopTest();
    }
    @isTest
     public static void testMethod9(){
        
        Modified_CPQInventorySearchTool.refreshcountyList(null,'NY');
        Modified_CPQInventorySearchTool.refreshcityList(null,'NY','Martindale.com Preferred County Results',false);
        Modified_CPQInventorySearchTool.refreshStateList('USA');
        Test.startTest();
        
        Product2 prod = [Select Id from Product2 Limit 1];
        
        Cart__c cart = new Cart__c();
        insert cart;
        cart.ownerId  = UserInfo.getUserId();
        List<Cart_Line_Item__c> cartLineItemlst =  new List<Cart_Line_Item__c>();
        Cart_Line_Item__c cli = new Cart_Line_Item__c();
        cli.Cart__c = cart.Id;
        cli.Country__c = 'USA';
        cli.AOP__c = 'Administrative';
        cli.CityStateCounty__c = 'New Jersey';
        cli.Price__c = '$10.00';
        cli.Product__c = prod.Id;
        insert cli;
        cartLineItemlst.add(cli);        
        
        List<SBQQ__Quote__c> quo = [select id from sbqq__quote__c where Sbqq__Account__r.recordtype.developername = 'Nolo_Account' and (SBQQ__Status__c = 'Draft' OR SBQQ__Status__c = 'Approved') and (Subscription_type__c =: 'Rebase Evergreen' OR Subscription_type__c =: 'EG 2 EG') and recordtype.name != 'Offset Quote' and recordtype.name != 'MH Cancel Quote' and Id IN (
                                                          SELECT SBQQ__Quote__c 
                                                          FROM SBQQ__QuoteLine__c 
                                                          WHERE Group_Number__c = 2
                                                      ) limit 1];
        Modified_CPQInventorySearchTool.addtoExistingquote(quo[0].Id);
        Test.stopTest();
    }
    
      @isTest
    public static void testMethoddynamic(){
        Test.startTest();
        Modified_CPQInventorySearchTool.statelist = null;
        new Modified_CPQInventorySearchTool().getdynamicCountylist();
        new Modified_CPQInventorySearchTool().getdynamicCitylist();
        new Modified_CPQInventorySearchTool().getdynamicStatelist();
        Test.stopTest();
    }
    
     @isTest
    public static void testMethod7(){
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        new Modified_CPQInventorySearchTool().resetParameters();
        Modified_CPQInventorySearchTool.resultWrapper rw = new Modified_CPQInventorySearchTool.resultWrapper('aop','tcountry','tstate','tcity','tcounty','1');
        
        Modified_CPQInventorySearchTool.innerOrders io = new Modified_CPQInventorySearchTool.innerOrders('tcustomer','tcountry','tstatus','torderOpportunity','tOrderOpportunityId',System.today());
        //Modified_CPQInventorySearchTool.getAccounts();
        String selR = '{"state_id":null,"state":null,"sold":0,"searchcount":2084,"quota":1,"product_id":1957,"product":"Preferred National Results","pended":1,"innerordersList":null,"county_id":null,"county":null,"country_id":1,"country":"United States of America","city_id":null,"city":null,"available":0,"aop_id":722,"aop":"Administrative Law","addToCart":null,"Price":56}';
        Modified_CPQInventorySearchTool.createCart(selR,'true');
        Modified_CPQInventorySearchTool.createCart(selR,'false');
        Modified_CPQInventorySearchTool c = new Modified_CPQInventorySearchTool();
        Modified_CPQInventorySearchTool.cartButton(null);        
        
        String s = '[{"addToCart":true, "aop":"Adoptions", "aop_id":"867", "available":"2", "city":null, "city_id":null, "country":"United States of America", "country_id":"1", "county":null, "county_id":null, "disableCheckbox":null, "innerordersList":null, "pended":"0", "product":"Preferred State Results", "product_id":"1956", "quota":"2", "searchcount":"31", "sold":"0", "state":"Arkansas", "state_id":"4","Price":72}]';
        Inventory_Result__c inv = new Inventory_Result__c();
        inv.ownerId = UserInfo.getUserId();
        inv.Selected_Results__c = s;
        insert inv;
        
        Product2 prod = [Select Id from Product2 where Name like '%Preferred State Results%' limit 1];
        
        Cart__c cart = new Cart__c();
        insert cart;
        cart.ownerId  = UserInfo.getUserId();
        update cart;
        List<Cart_Line_Item__c> cartLineItemlst =  new List<Cart_Line_Item__c>();
        Cart_Line_Item__c cli = new Cart_Line_Item__c();
        cli.Cart__c = cart.Id;
        cli.Country__c = 'United States of America';
        cli.AOP__c = 'Adoptions';
        cli.Product__c = prod.Id;
        //cli.CityStateCounty__c = 'New Jersey';
        insert cli;
        
        Set<Id> cartLineItemIds = new Set<Id>();
        cartLineItemIds.add(cli.Id);
        
        cartLineItemlst.add(cli);
        
        SBQQ__Quote__c quote = [Select Id from SBQQ__Quote__c Limit 1];
        PriceBook2 pb = [Select Id from PriceBook2 Limit 1];
        Account a = new Account(Name = 'Test Account');
        insert a;    
        
        String quotecreationString = '[{"quoteId":quote.Id,"priceBookId":pb.Id,"accountObj":a}]';
        Modified_CPQInventorySearchTool mc = new Modified_CPQInventorySearchTool();
        
        Modified_CPQInventorySearchTool.addToCartButton(null);
        Modified_CPQInventorySearchTool.createQuoteLinesAsync(quotecreationString);
        mc.setprodSummaryList();
        Modified_CPQInventorySearchTool.getAccId();        
        Modified_CPQInventorySearchTool.attributeLinesInsertion(s,cartLineItemIds);
        Test.stopTest();
    }  
    @isTest
    public static void testMethod8(){
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        
        id a = Apexpages.currentpage().getparameters().get('Id');
        Modified_CPQInventorySearchTool.selectedAccDetails(a);
        Modified_CPQInventorySearchTool.queryAllFields('Account');
        Modified_CPQInventorySearchTool.searchMethodApex();
        new Modified_CPQInventorySearchTool().clearCartLineItems();
        new Modified_CPQInventorySearchTool().onTabChangeSTD();
        new Modified_CPQInventorySearchTool().onTabChangeProf();
        new Modified_CPQInventorySearchTool().stdProdSearch();
        new Modified_CPQInventorySearchTool().profProdSearch();
        new Modified_CPQInventorySearchTool().showPageMessage();
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        Modified_CPQInventorySearchTool mcpq = new Modified_CPQInventorySearchTool();
        //mcpq.accountName = acc.Name;
        new Modified_CPQInventorySearchTool().cartButton();
        //Integer x = new Modified_CPQInventorySearchTool().SizeOfMap();
        //Integer y = new Modified_CPQInventorySearchTool().SizeOfProdSum();
        /*Modified_CPQInventorySearchTool inv1 = new Modified_CPQInventorySearchTool(); 
        PageReference pageRef = Page.CPQInventorySearchNew;
        Test.setCurrentPage(pageRef);
        //inv.resetParameters();
        inv1.selectedareaOfPractice = 'Administrative Law';
        inv1.selectedProdType = 'Lawyers.com Preferred Banner Placements';
        inv1.selectedProductTypes = new List<String>();
        inv1.selectedProductTypes.add('Lawyers.com Preferred Banner Placements');
        inv1.selectedProductTypes.add('Lawyers.com Spanish Preferred Banner Placements');
        //inv1.selectedstatecity ='USA,VA,Accomack,CA'; 
        //inv1.countyList = 'Independent City';
        inv1.doSearch();*/
        mcpq.accountId = acc.id;
        mcpq.accountName = acc.Name;
        mcpq.isProfProd = true;
        mcpq.runProdsearch();
        mcpq.runsearch();
        Test.stopTest();
    }
}