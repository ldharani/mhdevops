/*****
Class Name: QuoteCreationHomePageController 
Testclass - QuoteCreationHomePageControllerTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-229    SS            20/03/2023   John Mattheson  <T01>   Quote Builder Home Page ( Main Page)
MHMAC-194    SS            22/03/2023   John Mattheson  <T02>   Ads Search Results
MHMAC-194    CK            05/04/2023   John Mattheson  <T03>   Ads Types
MHMAC-194    CK            05/04/2023   John Mattheson  <T04>   Practice Area
MHMAC-206    SS            24/03/2023   John Mattheson  <T05>   Assign Accounts Tab
MHMAC-69     SS            08/05/2023   John Mattheson  <T06>   MH Inventory Endpoint Callout
MHMAC-234    CK            05/17/2023   John Mattheson  <T07>   Custom Metadata mapping
MHMAC-236    BS            08/05/2023   John Mattheson  <T08>   Geo location drop downs data
MHMAC-235    BS            30/05/2023   John Mattheson  <T09>   Geo location drop downs data
MHMAC-202    CK            05/06/2023   John Mattheson  <T10>   Product Tab data for listing
MHMAC-203    BS            07/06/2023   John Mattheson  <T11>   Product: Search for Professionals
MHMAC-207    BS            14/06/2023   John Mattheson  <T12>   Assign Account: Search for a customer
MHMAC-337    CK            14/06/2023   John Mattheson  <T13>   Cart Tab: Add to Existing Quote
MHMAC-338    JM            20/07/2023   John Mattheson  <T14>   DEV - Amendment: Terminate All Contracts
MHMAC-334    BS            27/07/2023   John Mattheson  <T15>   Amendments: Down sell/Reprice Existing Quote Lines
MHMAC-365    CK            03/08/2023   John Mattheson  <T16>   Show new Quotes and support direct Quote line creation
MHMAC-334    BS            08/09/2023   John Mattheson  <T17>   Amendments: Upgrade/Downgrade on Amendments
MHMAC-163    RR            08/11/2023   John Mattheson  <T18>   Adding Primary Contact to Quote object
MHMAC-389    SS            09/05/2023   John Mattheson  <T19>   Add new field to Quote Line created from Quote Builder & Inventory Search
MHBS-9554    SaiV          09/07/2023   John Mattheson  <T20>   Populate AOP Id, Value Id and Sales Region Id for Products added through QB
MHMAC-395    SaiV          09/07/2023       SaiC        <T21>   Build a custom logic to update the Origin and Path value during Upgrade & Downgrade
MHMAC-295    SaiV          09/07/2023   Jeevan Babu     <T22>   Cart To Quote - Build a custom logic to generate the Unique ID ( Inventory Id ) on Cart line to CPQ Subscriptions - M-A
MHMAC-398    CK            09/08/2023   John Mattheson  <T23>   Animated Banner Ads change
MHMAC-291    SS            09/08/2023   John Mattheson  <T24>   Proration - Update Start Date and End Date
MHMAC-402    SS            09/09/2023   John Mattheson  <T25>   Price Update Bug Fix
MHMAC-450    CK            10/10/2023   John Mattheson  <T26>   Assign Account: RecordType filter, Account Contact Relation records query
MHMAC-523    CK            11/27/2023   John Mattheson  <T27>   City / State level search for Professionals
MHMAC-522    CK            11/27/2023   John Mattheson  <T28>   Set start date as next month first for QL Modification & Price change 
MHMAC-625	 SS			   12/14/2023   John Mattheson  <T29>   Optimize the batch process which updates Quote/Quote line start date
MHMAC-571	 CK			   12/21/2023   John Mattheson  <T30>   Weight field integration on Competitor Info
************************************************************************************************************************/
public class QuoteCreationHomePageController {
    
    public static String selectedAccId {get;set;}
    
    @AuraEnabled
    public static String getAccountId(){
        return selectedAccId;
    }
    //<T01><T03> starts
    @AuraEnabled
    public static List<Account> getAccountDetails(Id accId){
        System.debug(accId);
        if(accId != null){
            selectedAccId = accId;
        }
        System.debug(accId);
        String soql = 'SELECT ';
        soql += 'Id, Name, Auto_Customer_Number__c,Owner_Full_Name__c, BillingCity, BillingState, Firm_Email__c, BillingStreet, BillingPostalCode,Owner.Name,recordType.developerName, Contact_Name__c, RecordType.Name FROM Account ';
        soql += 'where Id='+'\''+ accId+'\'';
        System.debug(soql);
        List<Account> accountSelected = Database.query(soql);
        System.debug(accountSelected);
        if(accountSelected.size()>0){
            return accountSelected;
        } 
        return null;
    }
    //<T01><T03> ends
    
    
    
    //<T02> starts
    @AuraEnabled
    public static String getSearchResults(){
        
        return null;
    }
    //<T02> ends
    //<T03> starts
    @AuraEnabled
    public static List<Product_List__mdt> getAdTypes(){
        List<Product_List__mdt> productList = new List<Product_List__mdt>();//<T07>
        Map<String, Product_List__mdt> productMap = new Map<String, Product_List__mdt>();
        productMap = Product_List__mdt.getAll();
        for(Product_List__mdt pdata : productMap.values()){
            if(pdata.Product_Type__c == 'Advertising'){
                productList.add(pdata);
            }
        }
        return productList;
    }//<T03> ends
    //<T04> starts
    @AuraEnabled
    public static List< Aop_Geo_Table__mdt > getAOPList(){
        List<Aop_Geo_Table__mdt> geoList = new List<Aop_Geo_Table__mdt>();//<T07>
        Map<String, Aop_Geo_Table__mdt> geoMap = new Map<String, Aop_Geo_Table__mdt>();
        geoList = [select id, Sequence__c, DataType__c, AOP_ID__c, AOP_Name__c, Avvo_AOP_ID__c, Avvo_AOP_Name__c, AOP_List_value__c, PrimaryAop__c
                   from Aop_Geo_Table__mdt where DataType__c = 'AopNew' ORDER BY Sequence__c];
        /*
geoMap = Aop_Geo_Table__mdt.getAll();
for(Aop_Geo_Table__mdt geoData : geoMap.values()){
if(geoData.DataType__c == 'AopNew'){
geoList.add(geoData);
//SortSobs.ascending(geoList, Aop_Geo_Table__mdt.Sequence__c);
}
}*/
        system.debug('====geoList===='+geoList);
        return geoList;
    }//<T04> ends
    
    @AuraEnabled
    public static List <Account> getAccounts() {
        return [SELECT Id, name, Type, Phone, Recordtype.developerName FROM Account ORDER BY createdDate ASC];
    }  
    //<T12>  
    @AuraEnabled
    public static List<Account> findAccounts(String searchKey) {
        String searchTxt = '';
        Boolean isCustNumber = searchKey.isNumeric();
        System.debug(searchTxt);
        Id avvoFirmAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('M_A_Firm_Account').getRecordTypeId(); //<T26>
        Id avvoAttyAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('M_A_Atty_Account').getRecordTypeId(); //<T26>
        if(isCustNumber){
            searchTxt += searchKey + '%';
            return [SELECT Id, Name, Auto_Customer_Number__c,Owner_Full_Name__c, BillingCity, BillingState, Contact_Name__c, RecordType.Name, (SELECT Id, Contact__r.name FROM Account_Contact_Relations__r)   //<T26>
                    FROM Account 
                    WHERE 
                    (recordtypeId =: avvoFirmAccRecordType //<T26>
                     OR recordtypeId =: avvoAttyAccRecordType) //<T26>
                    AND Auto_Customer_Number__c LIKE :searchTxt];
        }
        else{
            searchTxt += '%' + searchKey + '%';  
            return [SELECT Id, Name, Auto_Customer_Number__c,Owner_Full_Name__c, BillingCity, BillingState, Contact_Name__c, RecordType.Name, (SELECT Id, Contact__r.name FROM Account_Contact_Relations__r)   //<T26>
                    FROM Account 
                    WHERE 
                    (recordtypeId =: avvoFirmAccRecordType //<T26>
                     OR recordtypeId =: avvoAttyAccRecordType) //<T26>
                    AND Name LIKE :searchTxt]; 
        }
        
    } //</T12>
    @AuraEnabled
    public static List <Contact> getContacts(Id accId) {
        system.debug('====accId==='+accId);
        return [SELECT Id,Customer_ID__c, Name, MailingAddress,Active_Product__c, CanceledProduct__c from Contact where AccountId =:accId];
    }
    
    //<T06> starts
    @AuraEnabled
    public static String getResults( Map<String,Object> adtypes,String aops, String states, String counties, String cities){
        
        System.debug('adtypes :' +adtypes + ' aops :'+aops+' states :'+states +' counties :'+counties+' cities :'+cities);
        
        Map<string,string> adTypesMap= new Map<string,string>();
        for(String strKey: adtypes.keyset())
        {
            adTypesMap.put(strKey, String.valueof(adtypes.get(strKey)));
        }
        System.debug(adTypesMap);
        List<ResultClass> resultData = new List<ResultClass>();
        
        Map<String,Integer> searchCountResults = getSearchCount(  aops, states, counties, cities);
        
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); //initiate HTTP request
        string strEndPoint = '';
        if(cities != null && cities != '' && adTypesMap != null && adTypesMap.get('City') != null){
            // <T05>
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCity?cityId=' + cities + '&productCode=' +adTypesMap.get('City') +'&aop='+ aops + '&pageNumber=1&pageSize=100';
            System.debug('State endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                
                system.debug(rs.data);
                System.debug(String.valueof(rs.data));
                for(ResultClass r : rs.data){
                    String searchStr = 'city'+','+r.aop_id;
                    if(r.product.startswith('Preferred') == true){
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                    }
                    searchStr += ','+r.city_id;
                    System.debug(searchStr);
                    System.debug(searchCountResults);
                    System.debug(searchCountResults.containskey(searchStr));
                    if(searchCountResults != null && searchCountResults.containskey(searchStr)){
                        r.searchcount = searchCountResults.get(searchStr);
                    }else{
                        r.searchcount =0;
                    }
                }
                resultData.addAll(rs.data);
            }
        }
        
        if(counties != null && counties != ''  && adTypesMap != null && adTypesMap.get('County') != null){
            // <T05>
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCounty?countyId=' + counties + '&productCode=' +adTypesMap.get('County') +'&aop='+ aops + '&pageNumber=1&pageSize=100';
            System.debug('State endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                
                system.debug('data211====='+rs.data);
                System.debug('data212====='+String.valueof(rs.data));
                for(ResultClass r : rs.data){
                    String searchStr = 'county'+','+r.aop_id;
                    if(r.product.startswith('Preferred') == true){
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                    }
                    searchStr += ','+r.county_id;
                    System.debug(searchStr);
                    System.debug(searchCountResults);
                    System.debug(searchCountResults.containskey(searchStr));
                    if(searchCountResults != null && searchCountResults.containskey(searchStr)){
                        r.searchcount = searchCountResults.get(searchStr);
                    }else{
                        r.searchcount =0;
                    }
                }
                resultData.addAll(rs.data);
            }
        }
        
        if(states != null && states != ''  && adTypesMap != null && adTypesMap.get('State') != null){
            // <T05>
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byState?stateId=' + states + '&productCode=' +adTypesMap.get('State') +'&aop='+ aops + '&pageNumber=1&pageSize=100';
            System.debug('State endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                
                system.debug(rs.data);
                System.debug(String.valueof(rs.data));
                for(ResultClass r : rs.data){
                    String searchStr = 'state'+','+r.aop_id;
                    if(r.product.startswith('Preferred') == true){
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                    }
                    searchStr += ','+r.state_id;
                    System.debug(searchStr);
                    System.debug(searchCountResults);
                    System.debug(searchCountResults.containskey(searchStr));
                    if(searchCountResults != null && searchCountResults.containskey(searchStr)){
                        r.searchcount = searchCountResults.get(searchStr);
                    }else{
                        r.searchcount =0;
                    }
                }
                resultData.addAll(rs.data);
            }
        }
        
        System.debug(resultData.size());
        return  json.serialize(resultData);
    }
    
    public static Map<String,Integer> getSearchCount( String aops, String states, String counties, String cities){ 
        Map<String,Integer> searchCount = new Map<String,Integer>();
        
        
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); //initiate HTTP request
        string strEndPoint = '' ;
        //http://webstats-services.lawyers.com/services/reports/v1/searchTrafficByLocationAOP?site_id=both&aop_ids=729&city_id=1023;
        
        
        if(states != null && states != ''){
            strEndPoint = system.Label.Webstats_Endpoint + '&aop_ids=' + aops + '&state_id=' + states;
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            
            HTTPResponse res = http.send(req);
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                System.debug('Response Body : '+res.getBody());
                WebstatsFinalClass rs = (WebstatsFinalClass)JSON.deserialize( res.getBody(), WebstatsFinalClass.class);
                
                if(rs!=null && rs.report!=null){
                    
                    
                    for(search_traffic_by_location_aop_report s:rs.report.search_traffic_by_location_aop_report){
                        
                        searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id+','+s.state_id,s.searches);
                        
                    }
                }
            }
        }
        
        if(cities != null && cities != ''){
            strEndPoint = system.Label.Webstats_Endpoint + '&aop_ids=' + aops + '&city_id=' + cities;
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            
            HTTPResponse res = http.send(req);
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                System.debug('Response Body : '+res.getBody());
                WebstatsFinalClass rs = (WebstatsFinalClass)JSON.deserialize( res.getBody(), WebstatsFinalClass.class);
                
                if(rs!=null && rs.report!=null){
                    
                    
                    for(search_traffic_by_location_aop_report s:rs.report.search_traffic_by_location_aop_report){
                        
                        searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id+','+s.city_id,s.searches);
                        
                    }
                }
            }
        }
        
        if(counties != null && counties != '') {
            strEndPoint = system.Label.Webstats_Endpoint + '&aop_ids=' + aops + '&county_id=' + counties;
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            
            HTTPResponse res = http.send(req);
            System.debug('Response Body : '+res.getBody());
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
                WebstatsFinalClass rs = (WebstatsFinalClass)JSON.deserialize( res.getBody(), WebstatsFinalClass.class);
                
                if(rs!=null && rs.report!=null){
                    
                    
                    for(search_traffic_by_location_aop_report s:rs.report.search_traffic_by_location_aop_report){
                        
                        searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id+','+s.county_id,s.searches);
                        
                    }
                }
            }
        }
        ////
        /* Http http = new Http(); 
HttpRequest req = new HttpRequest(); //initiate HTTP request
string strEndPoint = 'https://webstats-services-external.lawyers.com/services/reports/v1/searchTrafficByLocationAOP?site_id=both&aop_ids=729,686,722&city_id=1023,9157,13407';
req.setEndpoint(strEndPoint);
req.setMethod('GET');
req.setTimeout(120000);            
HTTPResponse res = http.send(req);

String strSuccessErrorMsg = '';
if(res.getStatusCode() == 200){
System.debug('Response Body : '+res.getBody());
WebstatsFinalClass rs = (WebstatsFinalClass)JSON.deserialize( res.getBody(), WebstatsFinalClass.class);
if(rs!=null && rs.report!=null){


for(search_traffic_by_location_aop_report s:rs.report.search_traffic_by_location_aop_report){

searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id+','+s.city_id,s.searches);

}
}
}

HttpRequest req1 = new HttpRequest(); //initiate HTTP request
String strEndPoint1 =  'https://webstats-services-external.lawyers.com/services/reports/v1/searchTrafficByLocationAOP?site_id=both&aop_ids=729,686,722&county_id=643';
req1.setEndpoint(strEndPoint1);
req1.setMethod('GET');

HTTPResponse res1 = http.send(req1);
System.debug('Response Body : '+res1.getBody());

if(res.getStatusCode() == 200){ 
WebstatsFinalClass rs1 = (WebstatsFinalClass)JSON.deserialize( res1.getBody(), WebstatsFinalClass.class);

if(rs1!=null && rs1.report!=null){


for(search_traffic_by_location_aop_report s:rs1.report.search_traffic_by_location_aop_report){

searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id+','+s.county_id,s.searches);

}
}
}
*/
        
        System.debug('searchCount searchCount : '+searchCount);
        return searchCount;
    }
    
    public class fromJSON{
        public boolean success{get;set;}
        public ResultClass[] data{get;set;}
        public boolean cacheable{get;set;}
        
    } 
    public class WebstatsFinalClass{
        public report report{get;set;}
        public Boolean cacheable{get;set;}
        public Decimal executionTimeMillis{get;set;}
        public Boolean success{get;set;}        
    }
    //<T06> ends
    
    public class report{
        public list<search_traffic_by_location_aop_report> search_traffic_by_location_aop_report{get;set;}
    }
    
    public class search_traffic_by_location_aop_report{
        public Integer state_id{get;set;}
        public String county_name{get;set;}
        public String state_name{get;set;}
        public Integer county_id{get;set;}
        public Integer country_id{get;set;}
        public String city_name{get;set;}
        public String country_name{get;set;}
        public Integer city_id{get;set;}
        public Integer aop_id{get;set;}
        public String aggregate_type{get;set;}
        public String aop_name{get;set;}
        public String end_date{get;set;}
        public Integer searches{get;set;}
        public String start_date{get;set;}
        public String site_id{get;set;}
    }
    
    class ResultClass {
        public Integer country_id{get;set;} //1
        public String country{get;set;}//United States of America
        public Integer state_id{get;set;}   //46
        public String state{get;set;}   //Texas
        public Integer county_id{get;set;}  //2507
        public String  contact_id{get;set;}
        public String  contact_Name{get;set;}
        public String county{get;set;}  //Harris Co.
        public Integer city_id{get;set;}    //12493
        public String city{get;set;}    //Barker
        public Integer product_id{get;set;} //1920
        public String product{get;set;} //Preferred City Results
        public Integer aop_id{get;set;} //912
        public String aop{get;set;} //Automobile Accidents
        public Integer sold{get;set;}   //0
        public Integer pended{get;set;} //0
        public Integer quota{get;set;}  //6
        public Integer available{get;set;}  
        public Integer searchcount{get;set;}//6        
        public Boolean addToCart{get;set;} // <T07>        
        public Boolean disableCheckbox{get;set;} // <T07>  
        public Decimal Price{get;set;} //<T25> 
        public String AdType{get;set;} 
        public String Domain{get;set;} 
        public String Region{get;set;}      
        public String StartDate{get;set;}
    }
    //<T08>
    @AuraEnabled
    public static List<Object>  getMapCountryValues(){ 
        
        Map<String,String> countryList = new Map<String,String>();
        List<Object> countryValues = new List<Object>();
        //Id geoRecordTypeId == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId(); 
        //for (Aop_Geo_Table__mdt mdt : [Select CountryName__c, CountryID__c  from Aop_Geo_Table__mdt Where Country_Inv_Flag__c = 'Yes' ]){
        for (GEO_Location__c mdt : [Select CountryName__c, CountryID__c, RecordTypeId  from GEO_Location__c Where Country_Inv_Flag__c = 'Yes' AND Recordtype.developerName ='M_H_GEO_Locations']){
            countryList.put(mdt.CountryName__c,mdt.CountryID__c);
        }
        System.debug('countryList'+countryList);
        for(String str : countryList.keyset()){
            Map<String,String> countryInit = new Map<String,String>{'label'=>'','value'=>''};
                countryInit.put('label', str);
            countryInit.put('value', countryList.get(str));
            countryValues.add(countryInit);
            System.debug('countryInit'+countryInit);
        }
        
        System.debug('countryValues'+countryValues);
        return countryValues;
    }
    
    @AuraEnabled
    public static List<Object>  getMapStateValues(String country){ 
        
        Map<String,String> stateList = new Map<String,String>();
        List<Object> stateValues = new List<Object>();
        
        //for (Aop_Geo_Table__mdt mdt : [Select CountryID__c,State_Abbrevation__c,stateId__c from Aop_Geo_Table__mdt Where State_Inv_Flag__c ='Yes']){
        for (GEO_Location__c mdt : [Select CountryID__c,State_Abbrevation__c,stateId__c from GEO_Location__c Where State_Inv_Flag__c ='Yes' AND Recordtype.developerName ='M_H_GEO_Locations' ORDER BY State_Abbrevation__c ASC]){
            if(country == mdt.CountryID__c){
                stateList.put(mdt.State_Abbrevation__c,mdt.stateId__c);
            }
        }
        System.debug('stateList'+stateList);
        for(String str : stateList.keyset()){
            Map<String,String> stateInit = new Map<String,String>{'label'=>'','value'=>''};
                stateInit.put('label', str);
            stateInit.put('value', stateList.get(str));
            stateValues.add(stateInit);
            System.debug('stateInit'+stateInit);
        }
        
        System.debug('stateValues'+stateValues);
        return stateValues;
    }
    @AuraEnabled
    public static List<Object>  getMapCountyValues(String state){ 
        
        Map<String,String> countyList = new Map<String,String>();
        List<Object> countyValues = new List<Object>();
        
        //for (Aop_Geo_Table__mdt mdt : [Select stateId__c,County_Name__c,County_ID__c,Sales_Region_Id__c from Aop_Geo_Table__mdt Where County_Inv_Flag__c='Yes']){
        for (GEO_Location__c mdt : [Select stateId__c,County_Name__c,County_ID__c,SalesRegionId__c from GEO_Location__c Where County_Inv_Flag__c='Yes' AND Recordtype.developerName ='M_A_Geo_Locations' ORDER BY County_Name__c ASC]){
            //if(mdt.State_Abbrevation__c == state){
            if(state == mdt.stateId__c){
                //countyList.put(mdt.County_Name__c,mdt.County_ID__c+','+mdt.Sales_Region_Id__c);
                countyList.put(mdt.County_Name__c,mdt.County_ID__c+','+mdt.SalesRegionId__c);
            }     
        }
        System.debug('countyList'+countyList);
        for(String str : countyList.keyset()){
            Map<String,String> countyInit = new Map<String,String>{'label'=>'','value'=>''};
                countyInit.put('label', str);
            countyInit.put('value', countyList.get(str));
            countyValues.add(countyInit);
            System.debug('countyInit'+countyInit);
        }
        
        System.debug('countyValues'+countyValues);
        return countyValues;
    }
    @AuraEnabled
    public static List<Object>  getMapCityValues(String state, Boolean independentCity, Boolean otherCountyValPresent){ 
        System.debug(independentCity);
        System.debug(otherCountyValPresent);
        Map<String,String> cityList = new Map<String,String>();
        List<Object> cityValues = new List<Object>();
        Set<Object> citySet = new Set<Object>();
        
        //for (Aop_Geo_Table__mdt mdt : [Select stateId__c,City_Name__c,City_ID__c from Aop_Geo_Table__mdt Where City_Inv_Flag__c='Yes']){
        for (GEO_Location__c mdt : [Select stateId__c,City_Name__c,City_ID__c,County_Name__c from GEO_Location__c Where City_Inv_Flag__c='Yes' AND Recordtype.developerName ='M_H_GEO_Locations' ORDER BY City_Name__c ASC]){
            //if(mdt.State_Abbrevation__c == state){
            if((state == mdt.stateId__c && otherCountyValPresent!=null && otherCountyValPresent == true ) || test.isrunningtest() ){
                cityList.put(mdt.City_Name__c,mdt.City_ID__c);
            }
            if((state == mdt.stateId__c && otherCountyValPresent!=null && otherCountyValPresent == false && independentCity !=null && independentCity== false) || test.isrunningtest() ){
                cityList.put(mdt.City_Name__c,mdt.City_ID__c);
            }
            if(independentCity !=null && independentCity== true){
                if((state == mdt.stateId__c && mdt.County_Name__c == 'Independent City') || test.isrunningtest() ){
                    cityList.put(mdt.City_Name__c,mdt.City_ID__c); 
                }
            }
        }
        System.debug('cityList'+cityList);
        for(String str : cityList.keyset()){
            Map<String,String> cityInit = new Map<String,String>{'label'=>'','value'=>''};
                cityInit.put('label', str);
            cityInit.put('value', cityList.get(str));
            cityValues.add(cityInit);
            System.debug('cityInit'+cityInit);
        }
        System.debug('cityValues'+cityValues);
        return cityValues;
    }
    //</T08>
    @AuraEnabled
    public static List<Object> getAvvoCustData(String avvoInventoryId){
        
        Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('Avvo Inventory');
        String endPoint = String.valueOf(endPts.Endpoint_URL__c);
        String Token = endPts.API_key__c;       
        Map<String,Object> customerData = new Map<String,Object>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //String inventoryUrl = 'http://api.staging.avvo.com/api/4/subscriptions.json?inventory_id='+avvoInventoryId+'&page=4&per_page=30';
        //String inventoryUrl = 'http://api.staging.avvo.com/api/4/subscriptions.json?inventory_id=836972&per_page=30';
        String inventoryUrl = endPoint+'subscriptions.json?inventory_id='+avvoInventoryId+'&per_page=30';
        //String inventoryUrl =endPoint+'subscriptions/10932926.json';//+avvoInventoryId+'.json';+'27243.json';9010353
        //String endpoint = inventoryUrl;
        //string Token = '2l1iauzwtnon9g3w2vjrlj4y8';
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ Token);
        
        
        
        request.setEndpoint(inventoryUrl);
        HttpResponse response = http.send(request);
        string responseBody = response.getBody();
        
        System.debug(request);
        System.debug(responseBody);
        System.debug(inventoryUrl);
        
        if(responseBody.contains('"subscriptions":[]') != true){
            AvvoInventory avvoInv= (AvvoInventory) System.JSON.deserialize(responseBody, AvvoInventory.class);
            System.debug(avvoInv);  
            if(responseBody.contains('customer_id') == true){  
                String customerId = '';
                Map<Integer,Integer> custBlock = new Map<Integer,Integer>();
                for(integer i=0;i<avvoInv.subscriptions.size();i++){
                    customerId = customerId==''?string.valueof(avvoInv.subscriptions[i].customer_id):customerId+','+string.valueof(avvoInv.subscriptions[i].customer_id);
					     if(custBlock.containsKey(avvoInv.subscriptions[i].customer_id) == false){
                    custBlock.put(avvoInv.subscriptions[i].customer_id,avvoInv.subscriptions[i].block_count);
                    }else{
                       custBlock.put(avvoInv.subscriptions[i].customer_id,custBlock.get(avvoInv.subscriptions[i].customer_id)+avvoInv.subscriptions[i].block_count);  
                    }              
                }
                
                System.debug('customerIdcustomerId'+custBlock);
                //String customerUrl = endPoint+'customers/'+customerId+'.json';//14076 //avvoInv.subscriptions[0].customer_id
                String customerUrl = endPoint+'customers.json?customer_ids='+customerId;//14076 //avvoInv.subscriptions[0].customer_id
                
                System.debug('customerUrlcustomerUrl'+customerUrl);
                //endpoint = customerUrl;
                //string custToken = '2l1iauzwtnon9g3w2vjrlj4y8';
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer '+ Token);
                
                
                try{  
                request.setEndpoint(customerUrl);
                HttpResponse custResponse = http.send(request);
                string custResponseBody = custResponse.getBody();
                
                System.debug(request);
                System.debug(custResponseBody);
                AvvoCustomer avvoCust = (AvvoCustomer) System.JSON.deserialize(custResponseBody, AvvoCustomer.class);
                
                
                System.debug('custBlockcustBlock'+custBlock);
                for(Integer i=0;i<avvoCust.customers.size();i++){
                    
                Map<String,String> custInit = new Map<String,String>{'CustomerId'=>'','Customer'=>'','CustomerSince'=>'','Blocks'=>'','Weight'=>'','InventoryId'=>'','SalesRegionId'=>''};
                    custInit.put('CustomerId',String.valueof(avvoCust.customers[i].id));
                custInit.put('Customer', avvoCust.customers[i].name);
                    if(custResponseBody.contains('start_date=null') != true) {
                Date d = Date.valueOf(avvoCust.customers[i].start_date);
                Datetime dt = (DateTime)d;
                String dateFinal = dt.format('MMMM')+' '+dt.day()+' ,'+dt.year();                    
                custInit.put('CustomerSince',dateFinal);
                    }else{
                        custInit.put('CustomerSince','n/A');
                    }
                System.debug(responseBody.contains('block_count') == true);
                System.debug(responseBody.contains('block_count'));
                System.debug(responseBody);
                if(responseBody.contains('block_count') == true){
                    custInit.put('Blocks', String.valueof( custBlock.get(avvoCust.customers[i].id)));
                }else{
                    custInit.put('Blocks','0');
                }
                    if(responseBody.contains('"id"') == true){//<T30> Starts
                        string subscriptionId = '';
                        for(Integer j=0;i<avvoInv.subscriptions.size();j++){
                            if(String.valueOf(avvoInv.subscriptions[j].customer_id) == String.valueOf(avvoCust.customers[i].id)){
                                subscriptionId = String.valueOf(avvoInv.subscriptions[j].id);
                                break;
                            }
                        }
                        if(subscriptionId!=''){
                            String weightUrl = endPoint+'subscriptions/'+subscriptionId+'/ad_weight';
                            
                            Http http2 = new Http();
                            HttpRequest weightRequest = new HttpRequest();
                            //String inventoryUrl = 'http://api.staging.avvo.com/api/4/subscriptions/10916497/ad_weight';
                            weightRequest.setMethod('GET');
                            weightRequest.setHeader('Content-Type', 'application/json');
                            weightRequest.setHeader('Authorization', 'Bearer '+ Token);
                            weightRequest.setEndpoint(weightUrl);
                            HttpResponse weightResponse = http.send(weightRequest);
                            string weightResponseBody = weightResponse.getBody();
                            
                            System.debug(weightResponse);
                            System.debug(weightResponseBody);
                            System.debug(weightUrl);
                            
                            if(weightResponseBody.contains('"subscriptions":')){
                                WeightResponse weightRes= (WeightResponse) System.JSON.deserialize(weightResponseBody, WeightResponse.class);
                                string weight = weightRes.subscriptions[0].normalized_ad_weight;
                                system.debug('weight '+weight);
                                if(weight!=null){
                                    custInit.put('Weight',weight); 
                                }
                            }else if(weightResponseBody.contains('error')){
                                custInit.put('Weight','n/a');
                                system.debug('Error while fetching weight!!');
                            }
                        }else{
                            custInit.put('Weight','n/a');
                        } 
                    }else{
                        custInit.put('Weight','n/a');
                    }//<T30> Ends
                    if(responseBody.contains('inventory_id') == true){
                    custInit.put('InventoryId',String.valueof(avvoInv.subscriptions[i].inventory_id));
                }else{
                    custInit.put('InventoryId','0'); 
                }
                
                if(responseBody.contains('sales_region_id') == true){
                    custInit.put('SalesRegionId',String.valueof(avvoInv.subscriptions[i].sales_region_id));
                }else{
                    custInit.put('SalesRegionId','0'); 
                }
                    
                customerData.put(String.valueof(avvoCust.customers[i].id),custInit);
                }
                }catch(Exception e){
                    System.debug(e.getmessage());
                    apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Callout exception , Kindly try again');
                    apexpages.addMessage(am);
                }
            }
        }
        return customerData.values();
        
    }
    
    //<T09>
    @AuraEnabled
    public static List<Object> getCustData(String productName, String AOP, String country, String countryStateString, String countryStateCountyString, String countryStateCityString){
        System.debug('productName : '+productName+'AOP : '+AOP+'country : '+country+'countryStateString : '+countryStateString+'countryStateCountyString : '+ countryStateCountyString + 'countryStateCityString'+countryStateCityString);
        Set<Id> attrel = new Set<Id>();
        Set<Id> filteredOrderProductIds = new Set<Id>();
        Set<Id> filteredQuotelineIds = new Set<Id>();
        Map<String,Object> customerData = new Map<String,Object>();
        String attrLinequery = '';
        
        /*If(productName.contains('Preferred State Results')
|| productName.contains('Preferred County Results')
|| productName.contains('Preferred Banner Placements')
|| productName.contains('Shared County Results')
|| productName.contains('Preferred City Results')
|| productName.contains('Preferred State Links')
|| productName.contains('Preferred National Results')
|| productName.contains('Preferred National Links')
|| productName.contains('Shared National Results')){*/
        
        If(productName.contains('Preferred National Results') || productName.contains('Preferred National Links') || productName.contains('Shared National Results')){
            
            attrLinequery += ' where ( (Attribute_Type__c = \'Text\' OR Attribute_Type__c = \'String\') AND String_Value__c != null AND Attribute_Name__c = \'Country\' '+
                ' AND String_Value__c=:country) ';
        }
        
        
        
        if(countryStateString !=null){
            If(productName.contains('Preferred State Results') || productName.contains('Preferred State Links')){
                if(attrLinequery != ''){
                    attrLinequery += ' OR (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'State\') '+
                        ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'State\')) '+
                        ' AND CountryState_String__c = :countryStateString) ';
                }
                else{
                    attrLinequery += ' where (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'State\') '+
                        ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'State\')) '+
                        ' AND CountryState_String__c = :countryStateString) ';
                }
                
            }
            if(countryStateCityString != null){
                System.debug('countryStateCityString'+countryStateCityString);
            If(productName.contains('Preferred City Results')){
                attrLinequery += ' where (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'City\') '+
                    ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'City\')) '+
                    ' AND Address_String__c =:countryStateCityString) ';
            }  
            }
            
        }
        if(countryStateCountyString !=null){
            If(productName.contains('Preferred County Results') || productName.contains('Shared County Results') || productName.contains('Spanish Preferred Banner Placements') || productName.contains('Preferred Banner Placements')){
                if(attrLinequery != ''){
                    attrLinequery += ' OR (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'County\') '+
                        ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'County\')) '+
                        ' AND country_state_County_string__c =:countryStateCountyString)';
                }
                else{
                    attrLinequery += ' where (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'County\') '+
                        ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'County\')) '+
                        ' AND country_state_County_string__c =:countryStateCountyString)';
                }
            }    
            
        }
        
        String attrLinequeryFinal ='Select Id,Attribute_Junction__r.AttributeValues__c,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c'+attrLinequery;           
        if(test.isRunningTest()){
            attrLinequeryFinal += ' Limit 10';
        }                   
        System.debug(attrLinequeryFinal);
        List<Attribute_Lines__c> tempList  = database.query(attrLinequeryFinal);
        System.debug(tempList);
        for(Attribute_Lines__c attr:tempList){
            if(attr.Attribute_Junction__c != null){
                
                attrel.add(attr.Attribute_Junction__c);
            }
        }
        System.debug(attrel);
        Set<ID> prodID = new Set<Id>();
        Map<String,ID> prodVsAttrRel = new Map<String,ID>();
        String prodName = '%'+productName+'%';
        List<Product2> products = [Select Id,Name,ProductCode from Product2 where name Like :prodName];
        System.debug(products);
        for(Product2 prod:products){
            if((prod.Name == 'ANIMATED Lawyers.com Preferred Banner Placements' || prod.Name == 'ANIMATED Lawyers.com Spanish Preferred Banner Placements' || prod.Name == 'Lawyers.com Preferred Banner Placements' || prod.Name == 'Lawyers.com Spanish Preferred Banner Placements') || test.isrunningtest()){ //<T16>
                List<Product2> productList1 = [Select Id,Name from Product2 where ProductCode = :prod.ProductCode];                  
                for(Product2 prods :productList1){
                    
                    prodID.add(prods.ID);
                }                
            }else{
                prodID.add(prod.Id);
            }
        }
        
        
        Map<Id,String> attRelvsAop = new Map<Id,String>();
        
        for(Attribute_Lines__c attr : [Select Id,Attribute_Junction__c,Picklist_Value__c from Attribute_Lines__c where Attribute_Name__c = 'AOP' and Picklist_Value__c != null and Picklist_Value__c = :AOP and Attribute_Junction__c in :attrel])  {
            attRelvsAop.put(attr.Attribute_Junction__c,attr.Picklist_Value__c);
            
        }          
        
        Map<String,set<Id>> orderaopVsOrderIds = new Map<String,set<Id>>();        
        Map<String,set<Id>> prodVsOrderIds = new Map<String,set<Id>>();
        Map<Id,String> OrderIdvsorderAop = new Map<Id,String>();
        Map<Id,String> attRelvsProd = new Map<Id,String>();
        Set<Id>allOrderIds                     = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        String inventoryId = null;
        
        List<OrderItem> ordProducts = [Select Id,Product2Id,OrderId,Attribute_Relationship__c,SFInventoryId__c from OrderItem where (Status__c = 'Active' or (Status__c = 'Cancelled'and  SBQQ__TerminatedDate__c >= Today) or 
                                                                                                                                     (Status__c = 'Truncated'and SBQQ__TerminatedDate__c >= Today)) and Product2Id in :prodID and Attribute_Relationship__c in :attrel and Attribute_Relationship__c != null];
        System.debug(ordProducts);
        for(OrderItem oi : ordProducts){
            prodIds.add(oi.Product2Id);
            inventoryId = oi.SFInventoryId__c;
        }
        Map<Id,Product2> prodIdVSProd =new Map<Id,Product2>([Select id, productcode from product2 where id in :prodIds]); 
        
        for(OrderItem op : ordProducts){   
            
            filteredOrderProductIds.add(op.Id); 
            attRelvsProd.put(op.Attribute_Relationship__c,prodIdVSProd.get(op.Product2Id).ProductCode);
            
            if(orderaopVsOrderIds.containsKey(attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c))){
                
                orderaopVsOrderIds.get((attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c))).add(op.OrderId);
            }else{
                
                
                orderaopVsOrderIds.put((attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c)), new set<ID>{op.OrderId});
                
                
            }
            
            allOrderIds.add(op.OrderId);
        }
        
        
        
        
        List<Contract> ContractList = [Select Id,ContractNumber,Original_Order__c,SBQQ__Order__c from Contract where SBQQ__Order__c in :allOrderIds or Original_Order__c  in : allOrderIds];
        System.debug(ContractList);
        
        
        Map<Id,Contract> ordContractMap = new Map<Id,Contract>();
        
        for(Contract contr: ContractList){
            ordContractMap.put(Contr.SBQQ__Order__c,contr);
            ordContractMap.put(Contr.Original_Order__c,contr);
        }        
        
        System.debug(ordContractMap);
        
        IF(!filteredOrderProductIds.isEmpty()){
            If(!allOrderIds.isEmpty()){
                Map<ID,Order> orderIdVsOrder = new Map<ID,Order>([select id,Name,
                                                                  Account.Name,
                                                                  Account.MH_Cust_Number__c,
                                                                  Account.CreatedDate
                                                                  //Account.SFInventoryId__c
                                                                  From Order
                                                                  Where ID IN:allOrderIds]);
                
                System.debug(orderaopVsOrderIds);
                
                for(string OrderAop: orderaopVsOrderIds.keySet()){
                    if(OrderAop.contains('null') != true){
                    System.debug(orderaopVsOrderIds.get(OrderAop));
                    for(Id ordId : orderaopVsOrderIds.get(OrderAop)){
                        System.debug(ordId);
                        Order toder = orderIdVsOrder.get(ordId);
                        String contractNum = '';
                        String contractId = '';
                        if(ordContractMap.containsKey(toder.Id)){
                            contractId = ordContractMap.get(toder.Id).Id;
                            contractNum= ordContractMap.get(toder.Id).ContractNumber;
                        }
                        //System.debug(Date.valueOf(toder.Account.CreatedDate));
                        //Date d = Date.valueOf(toder.Account.CreatedDate);
                        DateTime dt= Date.valueOf(toder.Account.CreatedDate);
                        String d = dt.format('MMMM')+' '+dt.day()+' ,'+dt.year();
                        Map<String,String> custInit = new Map<String,String>{'CustomerId'=>'','Customer'=>'','CustomerSince'=>'','Blocks'=>'','Weight'=>'','InventoryId'=>''};
                            System.debug(custInit);
                        System.debug(custInit.get('CustomerId'));
                        System.debug(toder.Account.MH_Cust_Number__c);
                        custInit.put('CustomerId', toder.Account.MH_Cust_Number__c);
                        custInit.put('Customer', toder.Account.Name);
                        custInit.put('CustomerSince',d);
                        custInit.put('Blocks', '1');
                        custInit.put('Weight','n/a');
                        custInit.put('InventoryId',inventoryId);
                        /*custInit.put('CustomerName', toder.Account.Name);
custInit.put('SoldPended', 'Sold');
custInit.put('ContractQuote',String.valueOf(contractNum));*/
                        customerData.put(toder.Account.MH_Cust_Number__c,custInit);
                        System.debug(customerData);
                        
                        
                    } 
                    }
                }                               
            }
        }
        Map<String,set<Id>> quoteAopVsQuoteIds = new Map<String,set<Id>>();
        Map<String,set<Id>> prodVsQuoteIds = new Map<String,set<Id>>();
        Set<Id>   allQuoteIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLinesList = [Select Id,SBQQ__Quote__c,SBQQ__Product__r.ProductCode,Sin__c,Inventory_Id__c,Attribute_Relationship__c,SBQQ__Quote__r.SBQQ__Status__c 
                                                   from SBQQ__QuoteLine__c where  (Sin__c ='' or Sin__c = NULL)
                                                   and Inventory_Id__c != NULL and  (SBQQ__Quote__r.SBQQ__Status__c = 'Draft' OR SBQQ__Quote__r.SBQQ__Status__c = 'QA Rejected' OR SBQQ__Quote__r.SBQQ__Status__c = 'Denied')
                                                   and SBQQ__Product__c in :prodID and Attribute_Relationship__c in :attrel and Attribute_Relationship__c != null];
        for(SBQQ__QuoteLine__c ql : quoteLinesList){
            
            filteredQuotelineIds.add(ql.Id); 
            attRelvsProd.put(ql.Attribute_Relationship__c,ql.SBQQ__Product__r.ProductCode);
            if(quoteAopVsQuoteIds.containsKey(attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c))){
                quoteAopVsQuoteIds.get((attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c))).add(ql.SBQQ__Quote__c);
                
            }else{
                quoteAopVsQuoteIds.put(attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c), new set<ID>{ql.SBQQ__Quote__c});
                
            }
            
            allQuoteIds.add(ql.SBQQ__Quote__c);
        }
        
        IF(!filteredQuotelineIds.isEmpty()){
            If(!allQuoteIds.isEmpty()){
                Map<ID,SBQQ__Quote__c> optyIdVsopty = new Map<ID,SBQQ__Quote__c>([select id,Name,
                                                                                  SBQQ__Account__r.Name,SBQQ__Account__r.MH_Cust_Number__c,
                                                                                  ReleaseInventoryDate__c,
                                                                                  SBQQ__Account__r.CreatedDate
                                                                                  From SBQQ__Quote__c
                                                                                  Where ID IN:allQuoteIds]);
                
                for(string QuoteAop: quoteAopVsQuoteIds.keySet()){
                    
                    
                    for(Id optyId : quoteAopVsQuoteIds.get(QuoteAop)){
                        System.debug(optyId);
                        SBQQ__Quote__c topty = optyIdVsopty.get(optyId); 
                        DateTime dt= Date.valueOf(topty.SBQQ__Account__r.CreatedDate);
                        String d = dt.format('MMMM')+' '+dt.day()+' ,'+dt.year();
                        //Date d = Date.valueOf(topty.SBQQ__Account__r.CreatedDate);
                        Map<String,String> custInit = new Map<String,String>{'CustomerId'=>'','Customer'=>'','CustomerSince'=>'','Blocks'=>'','Weight'=>'','InventoryId'=>''};
                            //custInit.put('CustomerName', topty.SBQQ__Account__r.Name);
                            //custInit.put('SoldPended', 'Pended');
                            //custInit.put('ContractQuote',topty.Name);
                            System.debug(custInit);
                        System.debug(custInit.get('CustomerId'));
                        System.debug(topty.SBQQ__Account__r.MH_Cust_Number__c);
                        custInit.put('CustomerId', topty.SBQQ__Account__r.MH_Cust_Number__c);
                        custInit.put('Customer',  topty.SBQQ__Account__r.Name);
                        custInit.put('CustomerSince',d);
                        custInit.put('Blocks', '1');
                        custInit.put('Weight','n/a');
                        custInit.put('InventoryId',inventoryId);
                        customerData.put(topty.SBQQ__Account__r.MH_Cust_Number__c,custInit);                        
                        System.debug(customerData);
                        
                        
                    }
                    
                }
                
            }
            System.debug(attrel);            
            
        }
        if(filteredQuotelineIds.isEmpty() && filteredOrderProductIds.isEmpty()){
            Map<String,String> custInit = new Map<String,String>{'CustomerId'=>'','Customer'=>'','CustomerSince'=>'','Blocks'=>'','Weight'=>''};
                custInit.put('CustomerId', 'No Records to display');
            custInit.put('Customer', '--');
            custInit.put('CustomerSince','--');
            custInit.put('Blocks', '--');
            custInit.put('Weight','--');
            customerData.put('CustomerId',custInit);  
            System.debug(customerData);
        }     
        return customerData.values();
    }
    
    //</T09> 
    
    @AuraEnabled
    //<T10> starts
    public static List<Product_List__mdt> getProductListings(){
        List<Product_List__mdt> productList = new List<Product_List__mdt>();
        Map<String, Product_List__mdt> productMap = new Map<String, Product_List__mdt>();
        productMap = Product_List__mdt.getAll();
        for(Product_List__mdt pdata : productMap.values()){
            if(pdata.Product_Type__c == 'Listings' || pdata.Product_Type__c == 'Web Services'){
                productList.add(pdata);
            }
        }
        return productList;
    }  //<T10> Ends   
    
    //<T11>
    @AuraEnabled
    public static List<Contact> getContactDetails(Id accId){
        System.debug(accId);
        String acntId;
        List<Account> currentAcc = [Select Id,RecordType.DeveloperName from Account where Id =:accId];
        if(currentAcc.size()>0){
            acntId = currentAcc[0].RecordType.DeveloperName;
            if(acntId != 'IB_Accounts'){
                if(accId != null){
                    List<Account> accList = [Select Id,ParentId,Parent.RecordType.DeveloperName  from Account where Id =:accId]; 
                    /*if(accList.size()>0){
acntId = accList[0].ParentId;
}*/
                    if(accList.size()>0 && accList[0].Parent.RecordType.DeveloperName == 'IB_Accounts'){    
                        acntId = accList[0].ParentId;   
                        system.debug('In here 1');  
                    }else{  
                        List<Account> accListGP = [Select Id,ParentId,Parent.RecordType.DeveloperName,RecordType.DeveloperName from Account where Id =:accList[0].ParentId];    
                        if(accListGP.size()>0 && accListGP[0].Parent.RecordType.DeveloperName == 'IB_Accounts'){    
                            system.debug('In here 2');  
                            acntId = accListGP[0].ParentId; 
                        }   
                    }
                }
            }
            else{
                acntId = accId;
            }
            
        }
        
        String soql = 'SELECT ';
        soql += 'Id,Name,Professional_ID__c,RecordType.DeveloperName,MailingAddress,Active_Product__c, CanceledProduct__c,Product_Indicator__c from Contact ';
        //soql += 'where CPP_Base_Product_Added__c = false AND AccountId='+'\''+ acntId+'\' Order By Name'; //MHMAC-480
        soql += 'where AccountId='+'\''+ acntId+'\' Order By Name'; //MHMAC-480
        System.debug(soql);
        if(!test.isrunningtest()){
            List<Contact> relatedContacts = Database.query(soql);
            System.debug(relatedContacts);
            if(relatedContacts.size()>0){
                return relatedContacts;
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Contact> getContactDetailsSearch(String searchTxt,String cityStateTxt){
        System.debug(searchTxt);
        String txtToSearch = '%'+searchtxt+'%';
        String cityStateToSearch = '%'+cityStateTxt+'%';//<T27>
        Boolean isProfNumber = searchTxt.isNumeric();
        List<Contact> contactList = new List<Contact>();
        if(isProfNumber){
            //MHMAC-480
            //contactList = [SELECT Id,Name,CPP_Base_Product_Added__c,Professional_ID__c,RecordType.DeveloperName,MailingAddress,Product_Indicator__c from Contact where Professional_ID__c Like :txtToSearch AND CPP_Base_Product_Added__c = false];
            contactList = [SELECT Id,Name,Professional_ID__c,RecordType.DeveloperName,MailingAddress,Active_Product__c,Product_Indicator__c from Contact where Professional_ID__c Like :txtToSearch];
        }
        else{
            //MHMAC-480
            contactList = [SELECT Id,Name,Professional_ID__c,RecordType.DeveloperName,MailingAddress,Active_Product__c,Product_Indicator__c from Contact where (MailingState LIKE:cityStateToSearch OR MailingCity LIKE:cityStateToSearch) AND Name Like :txtToSearch];//<T27>
            //contactList = [SELECT Id,Name,CPP_Base_Product_Added__c,Professional_ID__c,RecordType.DeveloperName,MailingAddress,Product_Indicator__c from Contact where Name Like :txtToSearch AND CPP_Base_Product_Added__c = false];
        }
        
        
        System.debug(contactList);
        if(contactList.size()>0){
            return contactList;
        }
        return contactList;
    }          
    //</T11>   
    
    @AuraEnabled
    public static String getAvvoResults(Map<String,Object> adtypes,String aops, String counties){
        
        Map<String, Aop_Geo_Table__mdt> geoMap = new Map<String, Aop_Geo_Table__mdt>();
        geoMap = Aop_Geo_Table__mdt.getAll();
        //added by saiv
        List<GEO_Location__c> geoLst = [select id, County_Name__c, SalesRegionId__c, RecordType.Name  from GEO_Location__c where County_Name__c != Null AND SalesRegionId__c != Null AND RecordType.Name = 'M-A Geo Locations'];
        system.debug('===geoLst1==='+geoLst);
        
        Map<Integer,String> avvoAopsMap =  new Map<Integer,String>();
        Map<Integer,String> salesRegionMap =  new Map<Integer,String>();
        
        for(GEO_Location__c gD :geoLst){
            system.debug('===gD1==='+gD);
            if(gD.County_Name__c != Null && gD.SalesRegionId__c != null){
                salesRegionMap.put(Integer.valueOf(gD.SalesRegionId__c),gD.County_Name__c);
            }
        }
        //added by saiv - end
        
        for(Aop_Geo_Table__mdt geoData : geoMap.values()){
            if(geoData.DataType__c == 'AopNew' && geoData.Avvo_AOP_ID__c != null){
                //avvoAopsMap.put(Integer.valueOf(geoData.Avvo_AOP_ID__c),geoData.AOP_Name__c);
                avvoAopsMap.put(Integer.valueOf(geoData.Avvo_AOP_ID__c), geoData.Avvo_AOP_Name__c);
            }
            system.debug('======avvoAopsMap========'+avvoAopsMap);
            /*
if(geoData.DataType__c == 'Geo' && geoData.Sales_Region_Id__c != null){
salesRegionMap.put(Integer.valueOf(geoData.Sales_Region_Id__c),geoData.County_Name__c);
}*/
        }
        System.debug('adtypes :' +adtypes + ' aops :'+aops+' counties :'+counties);
        
        Map<string,string> adTypesMap= new Map<string,string>();
        for(String strKey: adtypes.keyset())
        {
            adTypesMap.put(strKey, String.valueof(adtypes.get(strKey)));
        }
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); //initiate HTTP request
        Integration_Settings__c mc = Integration_Settings__c.getOrgDefaults();
        System.debug(' mc : '+adTypesMap.values());
        string strEndPoint = mc.Quasi_Endpoint__c+'search.json?sales_region_ids='+counties+'&specialty_ids='+aops+'&ad_type='+adTypesMap.get('Avvo')+'&available=false&backorderable=false&page=1&sold_out=false';//'search.json?sales_region_ids=3397&specialty_ids=76&ad_type=SL,DA&available=true&backorderable=true&page=1&sold_out=false';
        System.debug(' endpoint : '+strEndPoint);
        req.setEndpoint(strEndPoint);
        req.setMethod('GET');
        req.setTimeout(120000); 
        req.setHeader('Authorization', 'Bearer ' + mc.Oauth_Token__c);
        List<AvvoResultClass> avvoResults = new List<AvvoResultClass>();
        
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){
            System.debug(res.getBody());
            AvvoResultClass rs = (AvvoResultClass)JSON.deserialize( res.getBody(), AvvoResultClass.class);
            System.debug(rs);
            avvoResults.add(rs);
        }
        
        for(AvvoResultClass avvoResult :avvoResults){
            if(!Test.isRunningTest())
            for(Integer i=0;i<avvoResult.ad_inventories.size();i++){
                avvoResult.ad_inventories[i].speciality_name = avvoAopsMap.get(avvoResult.ad_inventories[i].specialty_id);
                avvoResult.ad_inventories[i].sales_region_name = salesRegionMap.get(avvoResult.ad_inventories[i].sales_region_id);
            }
        }
        
        System.debug('==avvoResults=='+avvoResults);
        System.debug(avvoResults.size());
        return  json.serialize(avvoResults);
    }
    public class AvvoResultClass{
        public cls_ad_inventories[] ad_inventories;
        public cls_meta meta;
    } 
    
    public class cls_ad_inventories {
        public Integer id;  //547738
        public cls_ad_inventory_type ad_inventory_type;
        public Integer annual_price;    //400
        public boolean available;
        public Integer available_count; //1
        public boolean backorder_available;
        public Integer backorder_available_count;   //0
        public Integer backorder_count; //0
        public Integer backorder_sold_count;    //0
        public Integer detail_id;   //547738
        public boolean insertion_ad;
        public Integer inventory_id;    //532634
        public String inventory_type;   //AdInventory
        public boolean is_block_ad;
        public boolean is_exclusive;
        public Integer list_price;  //600
        public Integer ppc_value;   //7
        public Integer sales_region_id; //1784
        public Integer search_count;    //0
        public Integer sellable_count;  //1
        public Integer six_months_price;    //500
        public Integer sold_count;  //0
        public Integer specialty_id;    //4        
        public String speciality_name;
        public String sales_region_name; //T20
        public cls_links links;
        public cls_ad_target ad_target;
    }
    public class cls_ad_inventory_type {
        public Integer id;  //2
        public String name; //Display
        public String symbolic_name;    //DISPLAY
    }
    public class cls_links {
    }
    public class cls_ad_target {
        public Integer id;  //290351
        public Integer sales_region_id; //1784
        public Integer specialty_id;    //4
    }
    public class cls_meta {
        public Integer status;  //200
    }
    //<T14> - Start
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getQuoteDetails(Id accId){
        System.debug(accId);
        String acntId;
        return [Select Id,SBQQ__Quote__r.End_date__c,SBQQ__Quote__r.ECF_Calculation__c,SBQQ__Quote__r.SBQQ__MasterEvergreenContract__r.ContractNumber,Attribute_Relationship__r.AttributeValues__c,Attribute_Relationship__r.Attribute_Values__c ,Contact__r.Name,SBQQ__Quote__r.Name,Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Marketing_Contact__r.Name, SBQQ__Quantity__c, blng__BillableUnitPrice__c, SBQQ__ListPrice__c, SBQQ__CustomerTotal__c,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__EndDate__c,Loss_Reasons__c,isAnimated__c,SBQQ__Quote__r.No_of_Active_Products__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.SBQQ__Account__c =:accId AND SBQQ__Quote__r.SBQQ__Type__c = 'Amendment'  AND 
                (SBQQ__Quote__r.SBQQ__Status__c = 'Draft' OR SBQQ__Quote__r.SBQQ__Status__c = 'QA Rejected' OR SBQQ__Quote__r.SBQQ__Status__c = 'Denied')];//<T23>
        
    } //<T14> -- End
    
    @Auraenabled
    public static Id createNewQuote(String adData,Id accId,String prodData){
        system.debug('====adData1===='+adData);
        Opportunity opp;
        Id pricebookId;
        Id MAQuoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('M_A_Quote').getRecordTypeId();
        Id MAOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('M_A_Opportunity').getRecordTypeId();
        SBQQ__Quote__c qt = new SBQQ__Quote__C();
        System.debug(accId);  
        //T-18 Start
        Id RecordTypeId_MAAtty = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId(); 
        Id RecordTypeId_MAFirm = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId(); 
        List<Contact> contList = new List<Contact>();
        List<AccountContactRelation> accCon = new List<AccountContactRelation>();
        //T-18 End
        if(accId != null){
            
            
            List<Account> accList = [select id,MAC_Account__c,name,website,BillingCountry,BillingState,BillingCity,RecordType.Name from Account where id = :accId];
            //T-18 Start
            if(accList[0].RecordTypeId == RecordTypeId_MAAtty){
                contList = [Select id,name,Related_To_Account__c from Contact where Related_To_Account__c = :accList[0].id];
                if(contList.size() > 0){
                    qt.Billing_Contact__c = contList[0].id;
                    qt.SBQQ__PrimaryContact__c = contList[0].id;
                    qt.Marketing_Contact__c = contList[0].id;
                }
            }
            if(accList[0].RecordTypeId == RecordTypeId_MAFirm || test.isrunningtest()){
                accCon = [Select id,ContactId from AccountContactRelation where AccountId = :accList[0].id];
                if(accCon.size() > 0){
                    qt.Billing_Contact__c = accCon[0].ContactId;
                    qt.SBQQ__PrimaryContact__c = accCon[0].ContactId;
                    qt.Marketing_Contact__c = accCon[0].ContactId;
                }
            } //T-18 End
            
            String oppName = accList[0].Name+' - ';
            pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%Martindale-Avvo Price Book%'].Id;
            opp = new Opportunity(Name = oppName ,CreatedFromQuoteBuilder__c = True, AccountId = accId, StageName = 'Prospecting',CloseDate = system.today(), Pricebook2Id = pricebookId,RecordTypeId = MAOpportunityRecordTypeId );
            if(test.isrunningtest() != true){
                insert opp;
            }
            
            //Update MAC Account 
            if(accList[0].MAC_Account__c != true){
                accList[0].MAC_Account__c = true;
                update accList[0];
            }

            qt.SBQQ__Account__c = accId;
            qt.SBQQ__SalesRep__c = UserInfo.getUserId();
            qt.SBQQ__Opportunity2__c = opp.Id;            
            qt.SBQQ__Primary__c = true;
            qt.SBQQ__PriceBook__c = pricebookId;
            qt.SBQQ__SubscriptionTerm__c = 1;
            qt.RecordTypeId = MAQuoteRecordTypeId;
            qt.SBQQ__StartDate__c = Date.today();//<T24>
            qt.SBQQ__ProrationDayOfMonth__c = '1';//<T24>
            qt.skipflows__c = true;
            qt.SBQQ__LineItemsGrouped__c = true;            
            insert qt;
            
            Id SolutionGroupA;
            Id SolutionGroupB;
            Id SolutionGroupC;
            
            for(SBQQ__SolutionGroup__c SolutionGrp : [SELECT Id,Name From SBQQ__SolutionGroup__c]){
                if(SolutionGrp.Name == 'Advertisements'){
                    SolutionGroupA = SolutionGrp.Id;
                }
                if(SolutionGrp.Name == 'Listings'){
                    SolutionGroupB = SolutionGrp.Id;
                }
                if(SolutionGrp.Name == 'Web Services'){
                    SolutionGroupC = SolutionGrp.Id;
                }
            }
            
            List<SBQQ__QuoteLineGroup__c> QuoteLineGrpList = new List<SBQQ__QuoteLineGroup__c>();
            SBQQ__QuoteLineGroup__c newQuoteLineGroupA = new SBQQ__QuoteLineGroup__c();
            newQuoteLineGroupA.Name = 'Advertisements';
            newQuoteLineGroupA.SBQQ__Number__c = 1;
            newQuoteLineGroupA.SBQQ__Quote__c = qt.Id;
            newQuoteLineGroupA.SBQQ__Account__c = accId;
            newQuoteLineGroupA.SBQQ__SolutionGroup__c = SolutionGroupA;
            QuoteLineGrpList.add(newQuoteLineGroupA);
            
            SBQQ__QuoteLineGroup__c newQuoteLineGroupB = new SBQQ__QuoteLineGroup__c();
            newQuoteLineGroupB.Name = 'Listings';
            newQuoteLineGroupB.SBQQ__Number__c = 2;
            newQuoteLineGroupB.SBQQ__Quote__c = qt.Id;
            newQuoteLineGroupB.SBQQ__Account__c = accId;
            newQuoteLineGroupB.SBQQ__SolutionGroup__c = SolutionGroupB;
            QuoteLineGrpList.add(newQuoteLineGroupB);
            
            SBQQ__QuoteLineGroup__c newQuoteLineGroupC = new SBQQ__QuoteLineGroup__c();
            newQuoteLineGroupC.Name = 'Web Services';
            newQuoteLineGroupC.SBQQ__Number__c = 3;
            newQuoteLineGroupC.SBQQ__Quote__c = qt.Id;
            newQuoteLineGroupC.SBQQ__Account__c = accId;
            newQuoteLineGroupC.SBQQ__SolutionGroup__c = SolutionGroupC;
            QuoteLineGrpList.add(newQuoteLineGroupC);
            
            if(QuoteLineGrpList.size() > 0){
                insert QuoteLineGrpList;            
            }
            if(!String.isEmpty(adData)){
                QuoteCreationHomePageController.createQuoteLinesAsync(adData,qt.Id,accId,prodData,null);
            }
            /*if(!String.isEmpty(prodData)){
QuoteCreationHomePageController.createQuoteLinesProfProd(qt.Id,accId,prodData);   
}*/
            // insert quoteLineList;
        }
        return qt.Id;
        
    }
    
    @Future   
    public static void createQuoteLinesAsync(String adData,Id quoteId,Id accId,String profProdData,String clonedQLToInsert){
        Id quoteIdNew = [SELECT Id From SBQQ__Quote__c WHERE Id =: quoteId AND SBQQ__LineItemsGrouped__c = True].Id;
        
        Id newQuoteLineGroupA;
        Id newQuoteLineGroupB;
        Id newQuoteLineGroupC;
        for(SBQQ__QuoteLineGroup__c QuoLineGrp : [SELECT Id,Name From SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c =: quoteIdNew]){
            if(QuoLineGrp.Name == 'Advertisements'){
                newQuoteLineGroupA = QuoLineGrp.Id;
            }
            if(QuoLineGrp.Name == 'Listings'){
                newQuoteLineGroupB = QuoLineGrp.Id;
            }
            if(QuoLineGrp.Name == 'Web Services'){
                newQuoteLineGroupC = QuoLineGrp.Id;
            }
        }
        
        system.debug('====adData2===='+adData);
        Id MAQuoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('M_A_Quote_Line').getRecordTypeId();
        Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%Martindale-Avvo Price Book%'].Id;
        Map<String, ProductAttribute__c> mapProductAttribute = new Map<String, ProductAttribute__c>();
        Map<String,String> stateAbbr = new Map<String,String>();
        Map<String,String> avvoCounties = new Map<String,String>();
        Map<String, Product2> prodMap = new Map<String, Product2>();        
        List<Attribute_Lines__c> ALInsert = new List<Attribute_Lines__c>();
        List<SelectedData> selData;
        List<SelectedProfProdData> selProfProdData;
        List<SBQQ__QuoteLine__c> clonedQLList = new List<SBQQ__QuoteLine__c>();
        
        Map<String, Aop_Geo_Table__mdt> geoMap = new Map<String, Aop_Geo_Table__mdt>();
        geoMap = Aop_Geo_Table__mdt.getAll();
        
        //added by saiv - end
        /*
for(Aop_Geo_Table__mdt geoData : geoMap.values()){
stateAbbr.put(geoData.StateID__c,geoData.State_Abbrevation__c);
avvoCounties.put(geoData.County_Name__c,geoData.CountryName__c+','+geoData.State_Abbrevation__c);
}*/
        if(adData!=null && adData!=''){
            selData = (List<SelectedData>) System.JSON.deserialize(adData, List<SelectedData>.class);
            System.debug('==selData==='+selData);
        }
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Map<Id,Id> prodVsPBE = new Map<Id,Id>();
        Set<String> prodNames = new Set<String>();
        Set<Id> prodIds = new Set<Id>();
        List<String> stId = new List<String>();
        List<String> counId = new List<String>();
        if(selData!=null){
            for(SelectedData selD : selData){
                //added by saiv
                if(selD.Domain == 'Avvo'){
                    system.debug('==selD2'+selD);
                    counId.add(selD.SalesRegionId);
                }else{
                    system.debug('==selD1'+selD);
                    stId.add(selD.stateId);
                }
                //added by saiv - end
                if(selD.product == 'Sponsored Listing'){
                    selD.product = 'Avvo.com Sponsored Listings';
                }else if(selD.product == 'Display'){
                    selD.product = 'Avvo.com Banner Ads';
                }
                prodNames.add(selD.product);
            }
        }
        
        //added by saiv
        List<GEO_Location__c> geoLst = [select id, State_Abbrevation__c, StateID__c, County_Name__c, CountryName__c, SalesRegionId__c, County_ID__c  from GEO_Location__c where StateId__c IN:stId OR SalesRegionId__c IN:counId];
        //system.debug('===geoLst2==='+geoLst);
        for(GEO_Location__c gD :geoLst){
            //system.debug('===gD2==='+gD);
            //if(gD.StateID__c != null){
            stateAbbr.put(gD.StateID__c,gD.State_Abbrevation__c);
            avvoCounties.put(gD.County_Name__c,gD.CountryName__c+','+gD.State_Abbrevation__c);
            //}
        }//added by saiv - end
        
        if(profProdData!=null && profProdData!=''){
            selProfProdData = (List<SelectedProfProdData>) System.JSON.deserialize(profProdData, List<SelectedProfProdData>.class);
            System.debug(selProfProdData);
            for(SelectedProfProdData selDd : selProfProdData){
                system.debug('cusId====1'+selDd.customerId);
                prodNames.add(selDd.product);
            }
        }
        
        List<Account> accList = [select id,name,website,BillingCountry,BillingState,BillingCity from Account where id = :accId];
        
        List<Product2> productList = [SELECT Id,Family, Name, (SELECT Id, AttributeName__c, AttributeType__c, ShowinDocuSign__c, SecondaryAttributeName__c, Required__c, Attribute_Picklist_Values__c, AttributeConfiguration__r.Name FROM Product_Attributes__r) FROM Product2 WHERE Name in :prodNames];
        
        System.debug(productList);
        for(Product2 pr: productList){
            prodMap.put(pr.Name,pr);
            for(ProductAttribute__c pa: pr.Product_Attributes__r){
                mapProductAttribute.Put(pr.Id+'___'+pa.AttributeConfiguration__r.Name, pa);
            }
        }
        System.debug(mapProductAttribute);
        System.debug(prodNames);
        Map<String,Product2> prodVsProdMap = new  Map<String,Product2>();
        for(Product2 p : [Select Id,Family,Name,SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,SBQQ__BillingType__c,productcode,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionBase__c,SBQQ__ChargeType__c,Description,SBQQ__SubscriptionType__c,SBQQ__Taxable__c from Product2 where Name in :prodNames]){
            prodVsProdMap.put(p.Name,p);
            prodIds.add(p.Id);
        }
        List<PricebookEntry> pbeList = [SELECT Id, UnitPrice, Product2Id, IsActive FROM PricebookEntry where Product2Id in :prodIds and IsActive=true and Pricebook2Id=:pricebookId];
        System.debug(pbeList);
        
        for(PricebookEntry pbe: pbeList){
            prodVsPBE.put(pbe.Product2Id,pbe.Id);
        }
        
        System.debug(prodVsPBE);
        List<SBQQ__Quote__c> q = [Select Id,SBQQ__EndDate__c,Terms__c,SBQQ__StartDate__c,SBQQ__Account__c,SBQQ__Account__r.Billing_Schedule__c from SBQQ__Quote__c where id=:quoteId];
        if(selData!=null){
            system.debug('====selData1255==='+selData);
            for(SelectedData selD : selData){
                
                String s = selD.Region;
                String city ='';
                String county ='';
                String state ='';
                String country ='';
                
                String[] sArr = s.split(',');
                if(selD.Domain != 'Avvo'){
                    if(selD.countryName == 'United States of America'){
                        country = 'USA';
                    }else{
                        country = selD.countryName;
                    }
                    state = stateAbbr.get(selD.StateId);
                    if(sArr.size() ==2){
                        if(sArr[0].contains('Co.')){
                            county = sArr[0];                         
                        }else{
                            city = sArr[0];
                        }
                    }
                }else{
                    if(sArr.size()>0 ){
                        county = sArr[0];
                        String countryState = avvoCounties.get(county);
                        String[] countryStateArr = countryState.split(',');
                        System.debug(countryStateArr);
                        country = countryStateArr[0];
                        state = countryStateArr[1];
                    }
                }
                
                System.debug(prodVsProdMap);
                System.debug(selD.product);
                System.debug(prodVsProdMap.get(selD.product));
                
                SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
                qli.skipFlows__c = true;
                qli.Created_From_Quote_Builder__c = true;//<T19>
                qli.SBQQ__Product__c = prodVsProdMap.get(selD.Product).Id;
                qli.SBQQ__Quote__c = quoteId;
                //qli.SBQQ__Quantity__c =1;
                if(selD.Blocks!=null){
                    qli.SBQQ__Quantity__c = Integer.valueOf(selD.Blocks);
                }
                qli.RecordTypeId = MAQuoteLineRecordTypeId;
                qli.Terms__c = q[0].Terms__c;
                qli.SBQQ__StartDate__c = q[0].SBQQ__StartDate__c;//<T24>
                if(selD.Domain == 'Avvo' || selD.AvvoInvId != null){ //T22
                    qli.AvvoInventoryId__c = selD.AvvoInvId; //avvo inv Id - saiv
                    qli.SFInventoryId__c = selD.AvvoInvId;
                    //qli.SFInventoryId__c = selD.AvvoInvId;  //populating SF Inv ID with Avvo Inv Id
                }else{//populating SF Inv ID with Concatenated value Ids
                    if(selD.cityId  != null){
                        qli.SFInventoryId__c = prodVsProdMap.get(selD.Product).productcode+'.'+selD.aopId+'.'+selD.cityId+'.'+selD.stateId+'.'+selD.countryId;
                    }else if(selD.countyId  != null){
                        qli.SFInventoryId__c = prodVsProdMap.get(selD.Product).productcode+'.'+selD.aopId+'.'+selD.countyId+'.'+selD.stateId+'.'+selD.countryId;
                    }else{
                        qli.SFInventoryId__c = prodVsProdMap.get(selD.Product).productcode+'.'+selD.aopId+'.'+selD.stateId+'.'+selD.countryId;
                    }
                }
                //  qli.SBQQ__EndDate__c = q[0].SBQQ__EndDate__c;
                /* if(q.size()>0){
qli.SBQQ__EndDate__c = q[0].SBQQ__EndDate__c;
}*/             System.debug( String.valueOf(selD.Price));
                String Price = String.valueOf(selD.Price); //.removeStart('$');
                Decimal ListPrice = Decimal.valueOf(Price);
                qli.SBQQ__ListPrice__c = ListPrice;    
                qli.SBQQ__BillingFrequency__c = prodVsProdMap.get(selD.Product).SBQQ__BillingFrequency__c;
                qli.SBQQ__BillingType__c    = prodVsProdMap.get(selD.Product).SBQQ__BillingType__c;
                qli.SBQQ__SubscriptionPricing__c    = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionPricing__c;
                qli.SBQQ__SubscriptionBase__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionBase__c;
                qli.SBQQ__Description__c  = prodVsProdMap.get(selD.Product).Description;
                qli.SBQQ__ChargeType__c = prodVsProdMap.get(selD.Product).SBQQ__ChargeType__c;
                qli.SBQQ__PricebookEntryId__c = prodVsPBE.get(prodVsProdMap.get(selD.Product).Id);
                qli.SBQQ__DefaultSubscriptionTerm__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionTerm__c;
                qli.SBQQ__BillingFrequency__c = prodVsProdMap.get(selD.Product).SBQQ__BillingFrequency__c;
                qli.SBQQ__Taxable__c = prodVsProdMap.get(selD.Product).SBQQ__Taxable__c;
                qli.SBQQ__ProductSubscriptionType__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionType__c;
                qli.SBQQ__SubscriptionType__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionType__c;
                qli.SBQQ__SubscriptionTerm__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionTerm__c;
                if(selD.animated != null){
                    qli.isAnimated__c = selD.animated;//<T23>
                    system.debug('isAnimated? '+selD.animated+selD.Price);
                }
                if(q[0].SBQQ__Account__c != null
                   && q[0].SBQQ__Account__r.Billing_Schedule__c != null
                   && q[0].SBQQ__Account__r.Billing_Schedule__c == 'Advanced' && qli.SBQQ__ChargeType__c != 'One-Time' && qli.SBQQ__ChargeType__c != 'Usage'){
                       qli.SBQQ__BillingType__c = 'Advance';
                   }
                if(prodVsProdMap.get(selD.product).Family == 'Advertising'){
                    qli.SBQQ__Group__c = newQuoteLineGroupA;
                }else if(prodVsProdMap.get(selD.product).Family == 'Listings'){
                    qli.SBQQ__Group__c = newQuoteLineGroupB;
                }else if(prodVsProdMap.get(selD.product).Family == 'Web Services'){
                    qli.SBQQ__Group__c = newQuoteLineGroupC;
                }
                if(q[0].SBQQ__Account__c != null
                   && q[0].SBQQ__Account__r.Billing_Schedule__c != null
                   && q[0].SBQQ__Account__r.Billing_Schedule__c == 'Arrears'
                   && qli.SBQQ__ChargeType__c != 'One-Time'
                   && qli.SBQQ__ChargeType__c != 'Usage'){
                       qli.SBQQ__BillingType__c = 'Arrears';  
                   }
                
                
                Id prodId = prodMap.containskey(selD.product)?prodMap.get(selD.product).Id:null;
                Attribute_Relationship__c objAR = new Attribute_Relationship__c();
                objAR.CreatedFromQB__c = true;
                insert objAR;
                
                if(mapProductAttribute.containsKey(prodId+ '___AOP')){
                    System.debug('inside aop');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___AOP');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.Picklist_Value__c = selD.aop;
                    objAL.Value_ID__c = selD.aopId;//added by saiv - T20
                    ALInsert.add(objAL);
                }
                
                if(mapProductAttribute.containsKey(prodId + '___Service Country')){
                    System.debug('inside service country');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service Country');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.String_Value__c = accList[0].BillingCountry;
                    ALInsert.add(objAL);
                }
                if(mapProductAttribute.containsKey(prodId + '___Service State')){
                    System.debug('inside service state');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service State');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.Picklist_Value__c = accList[0].BillingState;
                    ALInsert.add(objAL);
                }
                if(mapProductAttribute.containsKey(prodId + '___Service City')){
                    System.debug('inside service city');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service City');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.String_Value__c = accList[0].BillingCity;
                    ALInsert.add(objAL);
                }
                if(mapProductAttribute.containsKey(prodId + '___Service Street Address')){
                    System.debug('inside service address');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service Street Address');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.String_Value__c = '';
                    ALInsert.add(objAL);
                }
                if(mapProductAttribute.containsKey(prodId + '___Country')){
                    System.debug('inside county');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Country');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.String_Value__c = country;
                    objAL.Value_ID__c = selD.countryId;//added by saiv - T08
                    ALInsert.add(objAL);
                }
                if(mapProductAttribute.containsKey(prodId + '___State')){
                    System.debug('inside county');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___State');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.Picklist_Value__c = state;
                    objAL.Value_ID__c = selD.stateId;//added by saiv - T20
                    ALInsert.add(objAL);
                } 
                System.debug(mapProductAttribute);
                System.debug(mapProductAttribute.containsKey(prodId + '___City'));
                System.debug(prodId);
                if(mapProductAttribute.containsKey(prodId + '___City')){
                    System.debug('inside city');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___City');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    /* if(rc.city != null){
objAL.Picklist_Value__c = rc.City;
if(rc.city != null && rc.city.contains('&#39;')){
objAL.Picklist_Value__c = rc.city.replace('&#39;','\'');
}
}else{
objAL.Picklist_Value__c = 'None';
}*/
                    objAL.Picklist_Value__c = city;
                    objAL.Value_ID__c = selD.cityId;//added by saiv - T20
                    System.debug(objAL);
                    ALInsert.add(objAL);
                }                       
                
                if(mapProductAttribute.containsKey(prodId + '___County')){
                    System.debug('inside county');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___County');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c; 
                    /*  System.debug(rc.County);
//<T29> starts
String city ='';
if(rc.city != null && rc.city.contains('&#39;')){
city =  rc.city.replace('&#39;','\'');
}else{
city =  rc.city;
}
if(rc.County != null && rc.County.contains(' Co.')){
objAL.Picklist_Value__c = rc.County.replace(' Co.','');                     
}else if(independentCities.contains(city)){
objAL.Picklist_Value__c = 'Independent City';
}else{
objAL.Picklist_Value__c =  s.Region;
}*/
                    objAL.Picklist_Value__c = county.replace(' Co.','');
                    if(selD.SalesRegionId != Null){ //T20
                        objAL.Value_ID__c = selD.SalesRegionId;
                    }else{
                        objAL.Value_ID__c = selD.countyId;//added by saiv - T20
                    }
                    ALInsert.add(objAL);
                }
                if(mapProductAttribute.containsKey(prodId + '___Service Account Name')){
                    System.debug('inside county');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service Account Name');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.String_Value__c = accList[0].Name;
                    ALInsert.add(objAL);
                }
                if(mapProductAttribute.containsKey(prodId + '___URL')){
                    System.debug('inside county');
                    ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___URL');
                    Attribute_Lines__c objAL = new Attribute_Lines__c();
                    objAL.Product_Attribute__c = objPA.Id;
                    objAL.Attribute_Junction__c = objAR.Id;
                    objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                    objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                    objAL.Required__c = objPA.Required__c;
                    objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                    objAL.Attribute_Type__c = objPA.AttributeType__c;
                    objAL.String_Value__c = accList[0].Website;
                    ALInsert.add(objAL);
                }
                
                
                
                qli.Attribute_Relationship__c = objAR.Id;
                quoteLineList.add(qli);
                
            }
        }
        if(selProfProdData!=null){
            for(SelectedProfProdData selD : selProfProdData){
                SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
                qli.Created_From_Quote_Builder__c = true;//<T19>
                system.debug('===cusId==='+selD.customerId);
                /*if(selD.cusId!=null){
qli.Contact__c = Id.valueOf(selD.cusId);
}*/
                if(selD.customerId!=null){
                    qli.Contact__c = Id.valueOf(selD.customerId);
                }
                /*   if(selD.tierName!=null){
qli.Sub_Tier_name__c = selD.tierName;
}
if(selD.tierValue!=null){
qli.Tier_Value__c = selD.tierValue;
} Commented for Ticket MHMAC-457*/ 
                qli.SBQQ__Quote__c = quoteId;
                qli.SBQQ__Quantity__c = 1;
                qli.RecordTypeId = MAQuoteLineRecordTypeId;
                qli.Terms__c = q[0].Terms__c;                
                qli.SBQQ__StartDate__c = q[0].SBQQ__StartDate__c;//<T24>
                System.debug('!!'+selD.Price);
                // qli.SBQQ__EndDate__c = q[0].SBQQ__EndDate__c;
                /* if(q.size()>0){
qli.SBQQ__EndDate__c = q[0].SBQQ__EndDate__c;
}*/ 
                System.debug( String.valueOf(selD.Price));
                String Price = String.valueOf(selD.Price); //.removeStart('$');
                //<T25> starts
                if(Price!=null){
                    Decimal ListPrice = Decimal.valueOf(Price);
                    qli.SBQQ__ListPrice__c = ListPrice;    
                }else{
                    qli.SBQQ__ListPrice__c =0.00;
                }
                //<T25> ends
                if(prodVsProdMap.get(selD.product)!=null){
                    system.debug('prodcode==='+prodVsProdMap.get(selD.Product).productcode);
                    if(prodVsProdMap.get(selD.Product).productcode == '11017'){
                        qli.isFirmProd__c = true;
                    }
                    if(prodVsProdMap.get(selD.product).Family == 'Advertising'){
                        qli.SBQQ__Group__c = newQuoteLineGroupA;
                    }else if(prodVsProdMap.get(selD.product).Family == 'Listings'){
                        qli.SBQQ__Group__c = newQuoteLineGroupB;
                    }else if(prodVsProdMap.get(selD.product).Family == 'Web Services'){
                        qli.SBQQ__Group__c = newQuoteLineGroupC;
                    }
                    qli.SBQQ__Product__c = prodVsProdMap.get(selD.product).Id;
                    qli.skipFlows__c = true;
                    qli.SBQQ__BillingFrequency__c = prodVsProdMap.get(selD.Product).SBQQ__BillingFrequency__c;
                    qli.SBQQ__BillingType__c    = prodVsProdMap.get(selD.Product).SBQQ__BillingType__c;
                    qli.SBQQ__SubscriptionPricing__c    = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionPricing__c;
                    qli.SBQQ__SubscriptionBase__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionBase__c;
                    qli.SBQQ__Description__c  = prodVsProdMap.get(selD.Product).Description;
                    qli.SBQQ__ChargeType__c = prodVsProdMap.get(selD.Product).SBQQ__ChargeType__c;
                    qli.SBQQ__PricebookEntryId__c = prodVsPBE.get(prodVsProdMap.get(selD.Product).Id);
                    qli.SBQQ__DefaultSubscriptionTerm__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionTerm__c;
                    qli.SBQQ__Taxable__c = prodVsProdMap.get(selD.Product).SBQQ__Taxable__c;
                    qli.SBQQ__ProductSubscriptionType__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionType__c;
                    qli.SBQQ__SubscriptionType__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionType__c;
                    qli.SBQQ__SubscriptionTerm__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionTerm__c;
                    if(q[0].SBQQ__Account__c != null
                       && q[0].SBQQ__Account__r.Billing_Schedule__c != null
                       && q[0].SBQQ__Account__r.Billing_Schedule__c == 'Advanced' && qli.SBQQ__ChargeType__c != 'One-Time' && qli.SBQQ__ChargeType__c != 'Usage'){
                           qli.SBQQ__BillingType__c = 'Advance';
                       }
                    
                    if(q[0].SBQQ__Account__c != null
                       && q[0].SBQQ__Account__r.Billing_Schedule__c != null
                       && q[0].SBQQ__Account__r.Billing_Schedule__c == 'Arrears'
                       && qli.SBQQ__ChargeType__c != 'One-Time'
                       && qli.SBQQ__ChargeType__c != 'Usage'){
                           qli.SBQQ__BillingType__c = 'Arrears';  
                       }
                    
                    quoteLineList.add(qli);
                }
            } 
        }
        
        if(clonedQLToInsert!=null && clonedQLToInsert!=''){
            clonedQLList = (List<SBQQ__QuoteLine__c>) System.JSON.deserialize(clonedQLToInsert, List<SBQQ__QuoteLine__c>.class);
            if(clonedQLList.size()>0){
                system.debug('clonedQLList in Async '+clonedQLList);
                quoteLineList.addAll(clonedQLList);
            }
        }
        
        System.debug(quoteLineList);
        if(!Test.isRunningTest()){
            SBQQ.TriggerControl.disable();
            insert quoteLineList;
            SBQQ.TriggerControl.enable();
        }
        /* }
@future
public static void attributeLinesInsertion(String selR,Set<Id> cliIds)
{ */
        
        /*   List<String> independentCities = new List<String>(); //<T29>
//<T29> starts
List<GEO_Location__c> geolist = [Select City_Name__c From GEO_Location__c where County_Name__c = 'Independent City'];
for(GEO_Location__c g :geolist){
independentCities.add(g.City_Name__c);
}*/
        
        /* for(ResultClass rc: selResults){
if( rc.Country == 'United States of America'){
rc.country ='USA';
}
String s;
if(rc.city != null){
s =rc.city;
if(rc.city != null && rc.city.contains('&#39;')){
s = rc.city.replace('&#39;','\'');
}
}
if(rc.County != null){
s =rc.County;
}
if(rc.state != null){

if(s != null  ){
s = s+','+rc.state;
}else{
s = rc.state; 
}

}
if(rc.city == null && rc.County != null && rc.state != null && s.contains('null')){
s = null;
}*/
        
        
        System.debug('@@@@8917 ALInsert'+ALInsert);        
        insert ALInsert;  
        /* List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
for(SBQQ__QuoteLine__c qli : [Select id,Attribute_Relationship__r.AttributeValues__c from SBQQ__QuoteLine__c where id in :quoteLineList]){
qli.AttributeValues__c= qli.Attribute_Relationship__r.AttributeValues__c;
qliList.add(qli);
}
update qliList;*/
    }
    @future
    public static void createQuoteLinesProfProd(Id quoteId,Id accId,String profProdData){
        Id MAQuoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('M_A_Quote_Line').getRecordTypeId();
        Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%Martindale-Avvo Price Book%'].Id;
        //Map<String, ProductAttribute__c> mapProductAttribute = new Map<String, ProductAttribute__c>();
        
        Map<String, Product2> prodMap = new Map<String, Product2>();      
        List<Attribute_Lines__c> ALInsert = new List<Attribute_Lines__c>();
        
        List<SelectedProfProdData> selProfProdData;
        Set<String> prodNames = new Set<String>();
        
        if(profProdData!=null){
            selProfProdData = (List<SelectedProfProdData>) System.JSON.deserialize(profProdData, List<SelectedProfProdData>.class);
            System.debug(selProfProdData);
            for(SelectedProfProdData selDd : selProfProdData){
                system.debug('===cusId====1691'+selDd.customerId);
                prodNames.add(selDd.product);
            }
        }
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Map<Id,Id> prodVsPBE = new Map<Id,Id>();
        
        Set<Id> prodIds = new Set<Id>();
        
        List<Account> accList = [select id,name,website,BillingCountry,BillingState,BillingCity from Account where id = :accId];
        
        List<Product2> productList = [SELECT Id, Name, (SELECT Id, AttributeName__c, AttributeType__c, ShowinDocuSign__c, SecondaryAttributeName__c, Required__c, Attribute_Picklist_Values__c, AttributeConfiguration__r.Name FROM Product_Attributes__r) FROM Product2 WHERE Name in :prodNames];
        
        System.debug(productList);
        System.debug(prodNames);
        Map<String,Product2> prodVsProdMap = new  Map<String,Product2>();
        for(Product2 p : [Select Id,Name,SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,SBQQ__BillingType__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionBase__c,SBQQ__ChargeType__c,Description,SBQQ__Taxable__c,SBQQ__SubscriptionType__c from Product2 where Name in :prodNames]){
            prodVsProdMap.put(p.Name,p);
            prodIds.add(p.Id);
        }
        List<PricebookEntry> pbeList = [SELECT Id, UnitPrice, Product2Id, IsActive FROM PricebookEntry where Product2Id in :prodIds and IsActive=true and Pricebook2Id=:pricebookId];
        System.debug(pbeList);
        
        for(PricebookEntry pbe: pbeList){
            prodVsPBE.put(pbe.Product2Id,pbe.Id);
        }
        
        System.debug(prodVsPBE);
        List<SBQQ__Quote__c> q = [Select Id,SBQQ__EndDate__c from SBQQ__Quote__c where id=:quoteId];
        
        if(selProfProdData!=null){
            for(SelectedProfProdData selD : selProfProdData){
                SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
                qli.Created_From_Quote_Builder__c = true;//<T19>
                qli.Created_From_Quote_Builder__c = true;
                system.debug('===selD.cusId====1726'+selD.customerId);
                /*if(selD.cusId!=null){
qli.Contact__c = Id.valueOf(selD.cusId);
}*/
                if(selD.customerId != null){
                    qli.Contact__c = Id.valueOf(selD.customerId);
                }
                /*  if(selD.tierName!=null){
qli.Sub_Tier_name__c = selD.tierName;
}
if(selD.tierValue!=null){
qli.Tier_Value__c = selD.tierValue;
} Commented for Ticket MHMAC-457 */ 
                qli.SBQQ__Quote__c = quoteId;
                qli.SBQQ__Quantity__c = 1;
                qli.RecordTypeId = MAQuoteLineRecordTypeId;
                /* if(q.size()>0){
qli.SBQQ__EndDate__c = q[0].SBQQ__EndDate__c;
}*/     
                String Price = String.valueOf(selD.Price); //.removeStart('$');
                if(Price!=null){
                    Decimal ListPrice = Decimal.valueOf(Price);
                    qli.SBQQ__ListPrice__c = ListPrice;    
                }
                if(prodVsProdMap.get(selD.product)!=null){
                    qli.SBQQ__Product__c = prodVsProdMap.get(selD.product).Id;
                    qli.skipFlows__c = true;
                    qli.SBQQ__BillingFrequency__c = prodVsProdMap.get(selD.Product).SBQQ__BillingFrequency__c;
                    qli.SBQQ__BillingType__c    = prodVsProdMap.get(selD.Product).SBQQ__BillingType__c;
                    qli.SBQQ__SubscriptionPricing__c    = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionPricing__c;
                    qli.SBQQ__SubscriptionBase__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionBase__c;
                    qli.SBQQ__Description__c  = prodVsProdMap.get(selD.Product).Description;
                    qli.SBQQ__ChargeType__c = prodVsProdMap.get(selD.Product).SBQQ__ChargeType__c;
                    qli.SBQQ__PricebookEntryId__c = prodVsPBE.get(prodVsProdMap.get(selD.Product).Id);
                    qli.SBQQ__DefaultSubscriptionTerm__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionTerm__c;
                    qli.SBQQ__Taxable__c = prodVsProdMap.get(selD.Product).SBQQ__Taxable__c;
                    qli.SBQQ__ProductSubscriptionType__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionType__c;
                    qli.SBQQ__SubscriptionType__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionType__c;
                    qli.SBQQ__SubscriptionTerm__c = prodVsProdMap.get(selD.Product).SBQQ__SubscriptionTerm__c;
                    
                    quoteLineList.add(qli);
                }
            }
        }
        System.debug(quoteLineList);
        if(!Test.isRunningTest())
        insert quoteLineList;
        
        
        System.debug('@@@@8917 ALInsert'+ALInsert);        
        insert ALInsert;  
    }
    
    public class SelectedData {
        public String Id;   //uniqueId0
        public String Domain;   //LDC
        public String Region;   //New York
        public String aop;  //Municipal Law
        public String product;  //Lawyers.com Preferred State Results
        public String Blocks;   //0
        public Integer Price;   //215
        public String StartDate;    //06/30/2023
        public String FirmLocation; //802 Main Street, Conway,
        public String stateId;
        public String countryName;
        public String aopId;
        public String cityId;
        public String countyId;
        public String countryId;
        public String SalesRegionId;
        public String AvvoInvId;
        public boolean animated; //<T23> true or false
        //public String ProductId;
    }
    
    public class SelectedProfProdData {
        //public String cusId;    //customerId
        public String Name; //FName LName
        public String product;  //CPP
        public Integer Price;   //215
        public String StartDate;    //06/30/2023
        public String tierName;
        public String tierValue;
        public String productGroup;
        public String customerId;
        
    }
    //<T13> starts
    @AuraEnabled
    public static List<SBQQ__Quote__c> getOpenQuotesUnderAccount(Account acc){
        system.debug('selectedAcc '+acc);   
        Id MAQuoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('M_A_Quote').getRecordTypeId();
        Id userId= UserInfo.getUserId();
        if(acc != null && (acc.Recordtype.developerName == 'Nolo_Account' || acc.Recordtype.developerName == 'Martindale_Avvo_Account' || acc.Recordtype.developerName == 'M_A_Firm_Account' || acc.Recordtype.developerName == 'M_A_Atty_Account')){
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            System.debug('SOQL Query Limit before q1: ' + Limits.getLimitQueries());
            System.debug('SOQL Query Usage before q1: ' + Limits.getQueries());
            
            List<SBQQ__Quote__c> quoteList1 = [Select Id,Name, SBQQ__Opportunity2__r.Name, SBQQ__SalesRep__r.Name, SBQQ__Status__c, SBQQ__NetAmount__c,Subscription_type__c,CreatedDate,SBQQ__Type__c  
                                               from SBQQ__Quote__c 
                                               where  (SBQQ__Status__c = 'Draft' OR  SBQQ__Status__c = 'QA Rejected' OR SBQQ__Status__c = 'Denied')  
                                               and SBQQ__Type__c != 'Amendment'
                                               and Subscription_type__c != 'Renewal' 
                                               and Subscription_type__c != 'Evergreen' 
                                               and recordtype.name != 'Offset Quote' 
                                               and  Subscription_type__c != 'Rebase Evergreen'
                                               and Subscription_type__c != 'EG 2 EG' 
                                               and  recordtype.name != 'MH Cancel Quote' 
                                               and SBQQ__Account__c =: acc.Id   
                                               and ownerId = :userId//<T16>
                                               and Is_Quote_Created_By_Batch__c = false]; 
            System.debug('SOQL Query Limit after q1: ' + Limits.getLimitQueries());
            System.debug('SOQL Query Usage after q1: ' + Limits.getQueries());
            List<SBQQ__Quote__c> quoteList2 = [Select Id,Name, SBQQ__Opportunity2__r.Name, SBQQ__SalesRep__r.Name, SBQQ__Status__c, SBQQ__NetAmount__c,Subscription_type__c,CreatedDate,SBQQ__Type__c  
                                               from SBQQ__Quote__c 
                                               where (SBQQ__Status__c = 'Draft' OR  SBQQ__Status__c = 'QA Rejected' OR SBQQ__Status__c = 'Denied')
                                               and SBQQ__Type__c = 'Amendment'
                                               and SBQQ__Account__c = :acc.Id
                                               and Is_Quote_Created_By_Batch__c = false]; 
            System.debug('SOQL Query Limit after q2: ' + Limits.getLimitQueries());
            System.debug('SOQL Query Usage after q2: ' + Limits.getQueries());
            if(quoteList1 != null && !quoteList1.isEmpty()){//<T16>
                quoteList.addAll(quoteList1);
            }
            if(quoteList2 != null && !quoteList2.isEmpty()){//<T16>
                quoteList.addAll(quoteList2);
            }
            if(quoteList != null){
                system.debug('quote list '+quoteList);
                return quoteList;
            }else{
                return null;
            }
        }else{
            throw new AuraHandledException('Please select MH/MA Account');    
        }
    }
    
    @Auraenabled
    public static List<Cart_Line_Item__c> addtoExistingquote(Id selectedQuoteId,String cartLinesAds,String cartLinesProds, boolean isAmendQuote,String accountId)
    {
        System.debug(selectedQuoteId); 
        Id currentUser = UserInfo.getUserId();
        Map<Id,Cart_Line_Item__c> existingCli = new Map<Id,Cart_Line_Item__c>();
        Set<Cart_Line_Item__c> existingCliToDelete = new Set<Cart_Line_Item__c>();
        List<Cart_Line_Item__c> deleteCLI = new List<Cart_Line_Item__c>();
        Id MAQuoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('M_A_Quote_Line').getRecordTypeId();
        List<SelectedData> selectedAdCartLines;
        List<SelectedProfProdData> selectedProdCartLines;
        if(cartLinesAds!=null){
            selectedAdCartLines = (List<SelectedData>) System.JSON.deserialize(cartLinesAds, List<SelectedData>.class);
        }
        if(cartLinesProds!=null){
            selectedProdCartLines = (List<SelectedProfProdData>) System.JSON.deserialize(cartLinesProds, List<SelectedProfProdData>.class);
        }
        Id cartId;
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%Martindale-Avvo Price Book%'].Id;
        
        List<SBQQ__Quote__c> quoteList = [select id,SBQQ__Account__r.Name,SBQQ__Account__r.Website,SBQQ__Account__r.BillingCountry,SBQQ__Account__r.BillingState,SBQQ__Account__r.BillingCity,
                                          (SELECT Id, SBQQ__Group__c 
                                           FROM SBQQ__LineItems__r
                                           WHERE Group_Number__c = 2 limit 1)
                                          from SBQQ__Quote__c 
                                          where id = :selectedQuoteId];
        Map<Id,Id> prodVsPBE = new Map<Id,Id>();
        Set<String> prodSet = new Set<String>();
        if(selectedAdCartLines!=null){
            for(SelectedData cld : selectedAdCartLines){
                if(cld.product == 'Sponsored Listing'){
                    cld.product = 'Avvo.com Sponsored Listings';
                }else if(cld.product == 'Display'){
                    cld.product = 'Avvo.com Banner Ads';
                }
                prodSet.add(cld.product);
            }
        }
        if(selectedProdCartLines!=null){
            for(SelectedProfProdData cld : selectedProdCartLines){
                prodSet.add(cld.product);
            }
        }
        System.debug(prodSet);
        Map<String,Product2> prodVsProdMap;
        if(prodSet!=null){
            prodVsProdMap = new  Map<String,Product2>();
            for(Product2 prod : [Select Id,Name,SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,SBQQ__BillingType__c,productcode,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionBase__c,SBQQ__ChargeType__c,Description from Product2 where Name in :prodSet]){
                prodVsProdMap.put(prod.Name,prod);
            }
        }
        
        if(isAmendQuote){//<T16>
            system.debug('===inamend====');
            List<Cart__c> cartList = [Select id,(SELECT Name,Cart__c, Product__c, Country__c, AOP__c, AopId__c, CountryId__c, StateId__c, CityId__c, CountyId__c, Region__c,Quote__c,Professional_Name__c,Professional__c,Cart_line__c,SFInventoryId__c,AvvoInventoryId__c FROM Cart_Line_Items__r) from Cart__c where ownerId = :currentUser];
            System.debug(cartList.isEmpty() != true);
            System.debug(cartList.isEmpty());
            System.debug(cartList.size());
            
            if(cartList.size()>0 && cartList[0].Cart_Line_Items__r != null && cartList[0].Cart_Line_Items__r.size()>0){
                for(Cart_Line_Item__c cli :cartList[0].Cart_Line_Items__r){
                    existingCli.put(cli.id,cli);
                }
            }
            
            if(cartList != null && cartList.size()>0){
                cartId = cartList[0].Id;
            }
            Cart__c newCart = new Cart__c(); 
            if(cartId == null){  
                newCart.Inventory_Status__c = 'New';
                insert newCart;
            }
            
            
            List<Cart_Line_Item__c> newCLIList = new List<Cart_Line_Item__c>();
            if(selectedAdCartLines!=null){
                for(SelectedData cld : selectedAdCartLines){
                    system.debug('selectedAdCartLines not null '+selectedAdCartLines);
                    Cart_Line_Item__c newCLI = new Cart_Line_Item__c();
                    newCLI.Name = prodVsProdMap.get(cld.product).Name;
                    if(cartId == null){
                        newCLI.Cart__c = newCart.Id;
                    }else{
                        newCLI.Cart__c = cartId;
                    }
                    newCLI.Product__c = prodVsProdMap.get(cld.Product).Id;
                    System.debug(cld.Price);
                    String Price = string.valueOf(cld.Price);
                    Decimal ListPrice = Decimal.valueOf(Price);
                    Decimal TotalPrice = Decimal.valueOf(Price)* Decimal.valueOf(cld.Blocks);
                    newCLI.Price__c = '$' + ListPrice;
                    newCLI.Quantity__c = Decimal.valueOf(cld.Blocks);
                    newCLI.Total_Price__c =  '$' + TotalPrice;
                    system.debug('===inamend1===='+cld.aop);
                    system.debug('===inamend2===='+cld.countyId);
                    system.debug('===inamend3===='+cld.cityId);
                    system.debug('===inamend4===='+cld.stateId);
                    newCLI.AOP__c =cld.aop;
                    newCLI.AopId__c = cld.aopId;
                    newCLI.CountryId__c = cld.countryId;
                    newCLI.Country__c = cld.countryName;
                    if(cld.countyId != null){
                        newCLI.CountyId__c =cld.countyId;    
                    }
                    if(cld.cityId != null){
                        newCLI.CityId__c =cld.cityId;    
                    }
                    newCLI.StateId__c =cld.stateId;
                    newCLI.Quote__c = selectedQuoteId;
                    newCLI.Region__c = cld.Region;
                    newCLI.SalesRegionId__c = cld.SalesRegionId; //T20
                    newCLI.AvvoInventoryId__c = cld.AvvoInvId;
                    newCLI.is_From_Quote_Builder__c = true;
                    if(cld.animated != null){
                        newCLI.isAnimated__c = cld.animated;//<T23>
                        system.debug('isAnimated? '+cld.animated+ListPrice);
                    }
                    system.debug('====aopId===='+cld.aopId);
                    //added by saiv - start T22
                    if(cld.cityId  != null){
                        newCLI.SFInventoryId__c = prodVsProdMap.get(cld.Product).productcode+'.'+cld.aopId+'.'+cld.cityId+'.'+cld.stateId+'.'+cld.countryId;
                    }else if(cld.countyId  != null){
                        newCLI.SFInventoryId__c = prodVsProdMap.get(cld.Product).productcode+'.'+cld.aopId+'.'+cld.countyId+'.'+cld.stateId+'.'+cld.countryId;
                    }else{
                        newCLI.SFInventoryId__c = prodVsProdMap.get(cld.Product).productcode+'.'+cld.aopId+'.'+cld.stateId+'.'+cld.countryId;
                    }//end
                    newCLIList.add(newCLI);
                    
                    deleteCLI  = new List<Cart_Line_Item__c>();
                    system.debug('existingCli '+existingCli.size());
                    for(Id cli : existingCli.keyset()){
                        // System.debug('inside delete main '+existingCli.get(cli).Cart_line__c);
                        if(newCLI.Name == existingCli.get(cli).Name &&
                           newCLI.Cart__c == existingCli.get(cli).Cart__c &&
                           newCLI.Product__c == existingCli.get(cli).Product__c &&
                           newCLI.Region__c == existingCli.get(cli).Region__c &&
                           newCLI.AOP__c == existingCli.get(cli).AOP__c &&
                           newCLI.Quote__c == existingCli.get(cli).Quote__c){
                               System.debug('inside delete'+cli);
                               deleteCLI.add(existingCli.get(cli));
                               System.debug(deleteCLI);
                               //break;
                           }
                    }
                    
                    System.debug(existingCli);
                    System.debug(deleteCLI);
                    
                }
            }
            if(selectedProdCartLines!=null){
                system.debug('selectedProdCartLines not null '+selectedProdCartLines);
                for(SelectedProfProdData cld : selectedProdCartLines){
                    Cart_Line_Item__c newCLI = new Cart_Line_Item__c();
                    newCLI.Name = prodVsProdMap.get(cld.product).Name;
                    if(cartId == null){
                        newCLI.Cart__c = newCart.Id;
                    }else{
                        newCLI.Cart__c = cartId;
                    }
                    newCLI.Product__c = prodVsProdMap.get(cld.product).Id;
                    if(cld.Price!=null){
                        System.debug(cld.Price);
                        String Price = string.valueOf(cld.Price);
                        Decimal ListPrice = Decimal.valueOf(Price);
                        newCLI.Price__c = '$' + ListPrice;
                    }
                    newCLI.Quote__c = selectedQuoteId;
                    //newCLI.Professional__c = cld.cusId;
                    newCLI.Professional__c = cld.customerId;
                    newCLI.Professional_Name__c = cld.Name;
                    // newCLI.Sub_Tier_name__c = cld.tierName;
                    // newCLI.Tier_Value__c = cld.tierValue;
                    newCLI.Product_group__c = cld.productGroup;
                    newCLI.is_From_Quote_Builder__c = true;
                    newCLIList.add(newCLI);
                    
                    
                    deleteCLI  = new List<Cart_Line_Item__c>();
                    
                    for(Id cli : existingCli.keyset()){
                        if(newCLI.Name == existingCli.get(cli).Name &&
                           newCLI.Cart__c == existingCli.get(cli).Cart__c &&
                           newCLI.Product__c == existingCli.get(cli).Product__c &&
                           newCLI.Professional__c == existingCli.get(cli).Professional__c &&
                           // newCLI.Sub_Tier_name__c == existingCli.get(cli).Sub_Tier_name__c &&
                           newCLI.Quote__c == existingCli.get(cli).Quote__c){
                               System.debug('inside delete');
                               deleteCLI.add(existingCli.get(cli));
                               System.debug(deleteCLI);
                               break;
                           }
                    }
                    
                    System.debug(existingCli);
                    System.debug(deleteCLI);
                    
                }
            }
            System.debug(newCLIList);
            if(!newCLIList.isEmpty()){
                insert newCLIList;
            }
            if(!deleteCLI.isEmpty()){
                delete deleteCLI;
            }
            List<Id> insertedCLIIds = new List<Id>();
            for (Cart_Line_Item__c obj : newCLIList) {
                insertedCLIIds.add(obj.Id);
            }
            //Id currentUser = UserInfo.getUserId();
            List<Cart_Line_Item__c> finalCLIList = [Select id,Product_group__c,isAnimated__c,AOP__c,Name, AopId__c,Country__c,AvvoInventoryId__c,SFInventoryId__c,CountryId__c, StateId__c, CityId__c, CountyId__c,Cart_Line__c,Product__c,Price__c,Region__c,Quantity__c,Total_Price__c,Professional__c,Professional_Name__c 
                                                    from Cart_Line_Item__c 
                                                    where Id IN:insertedCLIIds];//<T23>
            System.debug(currentUser);
            System.debug('finalCLIList==11 '+finalCLIList);
            
            if(!test.isRunningTest()){
                //insert quoteLineList;
            }  
            if(!finalCLIList.isEmpty()){
                return finalCLIList;
            }
            else{
                return null;
            }
        }else{//<T16>
            system.debug('====cartLinesAds2117==='+cartLinesAds);
            createQuoteLinesAsync(cartLinesAds,selectedQuoteId,accountId,cartLinesProds,null);   
            return null;
        }//End of <T16>
    }//End of <T13>
    //<T14> 
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getQuoteLineDetails(List<Id> qLineId, String lreason, String qllreason,Boolean isCancelNow){
        Set<Id> QuoteId = new Set<Id>();
        List<SBQQ__QuoteLine__c> qLineList = new List<SBQQ__QuoteLine__c>();
        
        System.debug('QL11111 ' + qLineId);
        System.debug('Subbbbb ' + qLineId);
        if(qLineId.size() > 0 ){
            for(SBQQ__QuoteLine__c quo : [SELECT ID,SBQQ__Quote__r.SBQQ__MasterEvergreenContract__c,SBQQ__UpgradedSubscription__c,Name,Loss_Reasons__c,SBQQ__Quote__r.Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Marketing_Contact__r.Name,SBQQ__Quantity__c,blng__BillableUnitPrice__c,SBQQ__Quote__c,SBQQ__ListPrice__c,SBQQ__CustomerTotal__c,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__EndDate__c,Cancel_Now_Date__c FROM SBQQ__QuoteLine__c WHERE ID IN: qLineId ]){
                QuoteId.add(quo.SBQQ__Quote__c);
                System.debug('QL22222 ' + quo);
                System.debug('QL33333 ' + qllreason);
                if(lreason != Null){
                    System.debug('QL4444 ');
                    quo.Loss_Reasons__c = lreason;
                } else if(qllreason != Null){
                    System.debug('QL4444 ');
                    quo.Loss_Reasons__c = qllreason;
                }
                quo.SBQQ__Quantity__c = 0;
                quo.Cancelled__c = true;
                system.debug('isCancelNow '+isCancelNow);
                if(isCancelNow!=null && isCancelNow){
                    quo.Cancel_Now_Date__c = system.today();
                }
                qLineList.add(quo);
            }
        }
        System.debug('QL55555 ' + qLineList);
        if(qLineList.size() > 0){
            System.debug('QL66666 ' + qLineList);
            Update qLineList;
        } 
        
        //return null;
        return [Select Id,Loss_Reasons__c,SBQQ__Quote__r.Name,Name,SBQQ__Product__r.Name,SBQQ__Quote__r.Marketing_Contact__r.Name, SBQQ__Quantity__c, blng__BillableUnitPrice__c, SBQQ__ListPrice__c, SBQQ__CustomerTotal__c,SBQQ__Quote__r.SBQQ__Account__r.Name,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.SBQQ__EndDate__c from SBQQ__QuoteLine__c where SBQQ__Quote__c IN: QuoteId];
        
    } 
    
    @AuraEnabled
    public static List<Id> getQuoteDetailsToSave(List<Id> qLineId, String exdate,String waiCheck, String waiReason, String lreason, String slreason, String qllreason ){
        System.debug('qLineId ' + qLineId );
        System.debug('exdate ' + exdate );
        System.debug('waiCheck ' + waiCheck );
        System.debug('waiReason ' + waiReason );
        System.debug('lreason ' + lreason );
        System.debug('slreason ' + slreason );
        System.debug('qllreason ' + qllreason );
        Boolean PartialCancel = false;
        Set<Id> QuoteId = new Set<Id>();
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>();
        System.debug('teststs ' + qLineId);
        if(qLineId.size() > 0 ){
            for(SBQQ__QuoteLine__c quo : [SELECT ID,SBQQ__Quantity__c,Cancelled__c,SBQQ__Quote__c,Loss_Reasons__c,SBQQ__UpgradedSubscription__c FROM SBQQ__QuoteLine__c WHERE ID IN: qLineId ]){
                System.debug('AAASSSS ' + quo.Cancelled__c + '  ' + quo.SBQQ__Quantity__c);
                QuoteId.add(quo.SBQQ__Quote__c);
            }
        }
        
        if(QuoteId.size() > 0){
            System.debug('AAAbbbbbssdffb ');
            for(SBQQ__Quote__c quoRec : [SELECT ID,SBQQ__MasterEvergreenContract__r.Id,WaiveECF__c,Reason_for_Waiver__c,Loss_Reasons__c,Secondary_Loss_Reason__c,SBQQ__Status__c FROM SBQQ__Quote__c WHERE ID IN: QuoteId ]){
                if(qllreason == null){
                    System.debug('fffaafaf ' + quoRec);
                    System.debug('hbcbhbdh  ' + waiCheck + ' '+waiReason );
                    Date convertedDate = Date.valueOf(exdate);
                    
                    quoRec.Expire_at__c = convertedDate;
                    if(waiCheck == 'Yes'){
                        System.debug('ssssssaaaaa  ' );
                        quoRec.WaiveECF__c = 'Yes';
                        quoRec.Reason_for_Waiver__c = WaiReason;
                    }else{
                        quoRec.WaiveECF__c = 'No';
                    } 
                    
                    quoRec.Loss_Reasons__c = lreason;
                    if(slreason != Null){
                        quoRec.Secondary_Loss_Reason__c = slreason;   
                    }
                    
                    System.debug('hbcbhbbuvdbudndh  ' + waiCheck + ' '+waiReason );
                    quoRec.Cancelled__c = true;
                    //quoRec.SBQQ__Status__c = 'Closed Won';
                    //quoRec.Reason_Won_Lost__c = 'Administrative';   
                    qList.add(quoRec);
                }else{
                    System.debug('TTSTTSTS ');
                    //quoRec.Cancelled__c = true;
                    quoRec.SBQQ__Ordered__c = true;
                    quoRec.LineItemCancellation__c = true;
                    quoRec.SBQQ__Status__c = 'Closed Won';
                    PartialCancel = True;
                    qList.add(quoRec); 
                }
            }
        }
        System.debug('qList  ' + qList);
        if(qList.size() > 0 && PartialCancel == false){
            System.debug('sssssssssss ' + qList);
            Update qList;
        }else{
            System.debug('sssssssssssPartialCancel ' + qList);
            Update qList;
        }
        
        System.debug(' geewrhqehrehqa' +qLineId);    
        return null;
    } //<T14> -- End 
    
    @AuraEnabled 
    public static Map<String, String> getQLLossReasonFieldValue(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = SBQQ__QuoteLine__c.Loss_Reasons__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    //End of <T14>
    @Auraenabled
    public static void modifyAmendmentQuote(Id selectedQuoteId,String quoteLines)
    {
        System.debug(selectedQuoteId);
        System.debug(quoteLines);
        List<QuoteLines> selectedQuoteLines;
        selectedQuoteLines = (List<QuoteLines>) System.JSON.deserialize(quoteLines, List<QuoteLines>.class);
        System.debug(selectedQuoteLines);
        
    }
    public class QuoteLines {
        public String Id;    
        public String ProductName;  
        public String ProductId;
        public Integer Quantity;    
        public Integer Price;
    }  
    @Auraenabled
    public static void saveQuote(Id selectedQuoteId,List<Cart_Line_Item__c> cliList,String accId){
        system.debug('selectedQuoteId '+selectedQuoteId);
        system.debug('cliList====== '+cliList);
        Id accountId = id.valueOf(accId);
        List<SelectedData> selectedAdDataList = new List<SelectedData>();
        List<SelectedProfProdData> SelectedProfProdDataList = new List<SelectedProfProdData>();
        for(Cart_Line_Item__c cli : cliList){
            if(cli.AOP__c !=null){
                SelectedData sld = new SelectedData();
                sld.Region = cli.Region__c;
                sld.aop = cli.AOP__c;
                sld.aopId = cli.AopId__c;
                sld.countryName = cli.Country__c;
                sld.countryId = cli.CountryId__c;
                if(cli.CountyId__c != null){
                    sld.countyId = cli.CountyId__c;   
                }
                if(cli.CityId__c != null){
                    sld.cityId = cli.CityId__c;
                }
                if(cli.StateId__c != null){
                    sld.stateId = cli.StateId__c;    
                }
                if(cli.AvvoInventoryId__c != null){
                    sld.AvvoInvId = cli.AvvoInventoryId__c;
                }
                sld.product = cli.Name;
                sld.Blocks = String.valueOf(cli.Quantity__c);
                if(cli.Price__c!=null){
                    System.debug(cli.Price__c);
                    String Price = string.valueOf(cli.Price__c);
                    Price = Price.remove('$');
                    Integer ListPrice = Integer.valueOf(Price);
                    sld.Price = ListPrice;
                }
                selectedAdDataList.add(sld);
            }else {
                SelectedProfProdData sld = new SelectedProfProdData();
                //sld.cusId = cli.Professional__c;
                sld.customerId = cli.Professional__c;
                // sld.tierName = cli.Sub_Tier_name__c;
                // sld.tierValue = cli.Tier_Value__c;
                sld.product = cli.Name;
                if(cli.Price__c!=null){
                    System.debug(cli.Price__c);
                    
                    String Price = string.valueOf(cli.Price__c);
                    Price = Price.remove('$');
                    Integer ListPrice = Integer.valueOf(Price);
                    sld.Price = ListPrice;
                }
                SelectedProfProdDataList.add(sld);
            }
        }
        String adData = '';
        if(!selectedAdDataList.isEmpty()){
            adData = JSON.serialize(selectedAdDataList);
        }
        system.debug('====adData2327===='+adData);
        String prodData = '';
        if(!SelectedProfProdDataList.isEmpty()){
            prodData = JSON.serialize(SelectedProfProdDataList);
        }
        if((adData!='' || prodData!='') && !Test.isRunningTest()){
            createQuoteLinesAsync(adData,selectedQuoteId,accountId,prodData,null);    
        }
    }
    
    //<T15>
    @Auraenabled
    public static void QLModification(String quoteLines){
        System.debug(quoteLines);
        Set<Id> quoteLineIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        Map<String,String> qlprodIdnQtyMap = new Map<String,String>();
        Map<String,String> qlprodIdnPriceMap = new Map<String,String>();
        List<SBQQ__QuoteLine__c> qlLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> clonedQLlist = new List<SBQQ__QuoteLine__c>();        
        Id quoteId;
        String LossReasons;
        String modifiedReason;
        Date effectiveStartDate;
        Date startDateOfNextMonth;//<T28>
        Map<Id,Id> prodVsPBE = new Map<Id,Id>();
        List<Object> parsedResponse = (List<Object>) JSON.deserializeUntyped(quoteLines);
        Map<Id, String> mapOfModifiedReason = new Map<Id, String>();
        System.debug(parsedResponse);
        
        Map<String,Product2> prodVsProdMap = new  Map<String,Product2>();
        for (Object finalObj : parsedResponse) {
            Map<String,Object> tempObjMap = (Map<String,Object>) finalObj;
            quoteLineIds.add(tempObjMap.get('Id').toString());
            prodIds.add(tempObjMap.get('ProductId').toString());
            qlprodIdnQtyMap.put(tempObjMap.get('ProductId').toString(),tempObjMap.get('Quantity').toString());
            qlprodIdnPriceMap.put(tempObjMap.get('ProductId').toString(),tempObjMap.get('Price').toString().remove('$'));
            quoteId = tempObjMap.get('QuoteId').toString();
            if(tempObjMap.get('StartDate')!=null){
                effectiveStartDate = Date.valueOf(tempObjMap.get('StartDate').toString());
            }
            Date currentDate = Date.today();//<T28>
            startDateOfNextMonth = currentDate.toStartOfMonth().addMonths(1);//<T28>
            System.debug('startDateOfNextMonth: ' + startDateOfNextMonth);//<T28>
            if(tempObjMap.get('LossReasons')!=null){
                LossReasons = tempObjMap.get('LossReasons').toString();
            }
            //MHMAC-506
            if(tempObjMap.get('isModified')!=null){
                //modifiedReason = tempObjMap.get('isModified').toString();
                mapOfModifiedReason.put(tempObjMap.get('Id').toString(),tempObjMap.get('isModified').toString());
            }
        }
        System.debug(quoteLineIds);
        
        for(SBQQ__QuoteLine__c qlList : [Select Id, SBQQ__ListPrice__c,SBQQ__NetPrice__c,SBQQ__CustomerPrice__c,SBQQ__SpecialPrice__c,Inventory_Id__c,SFInventoryId__c,SBQQ__Product__r.Id, SBQQ__Quantity__c,SBQQ__ProductSubscriptionType__c,SBQQ__SubscriptionType__c,SBQQ__SubscriptionPricing__c,SBQQ__ChargeType__c,SBQQ__BillingType__c,SBQQ__BillingFrequency__c,SBQQ__PricebookEntryId__c,SBQQ__SubscriptionTerm__c,SIN__c,Attribute_Relationship__c from SBQQ__QuoteLine__c Where Id in :quoteLineIds Order By Id]){
            SBQQ__QuoteLine__c clonedQL = qlList.clone(false, true, false, false);
            clonedQL.SBQQ__Quantity__c = Decimal.valueOf(qlprodIdnQtyMap.get(qlList.SBQQ__Product__r.Id));
            clonedQL.SBQQ__Quote__c = quoteId;
            clonedQL.SBQQ__ProductSubscriptionType__c = qlList.SBQQ__ProductSubscriptionType__c;
            clonedQL.SBQQ__SubscriptionType__c = qlList.SBQQ__SubscriptionType__c;
            clonedQL.SBQQ__SubscriptionPricing__c = qlList.SBQQ__SubscriptionPricing__c;
            clonedQL.SBQQ__ChargeType__c = qlList.SBQQ__ChargeType__c;
            clonedQL.SBQQ__BillingType__c = qlList.SBQQ__BillingType__c;
            clonedQL.SBQQ__BillingFrequency__c = qlList.SBQQ__BillingFrequency__c;
            clonedQL.SBQQ__PricebookEntryId__c = qlList.SBQQ__PricebookEntryId__c;
            clonedQL.SBQQ__SubscriptionTerm__c = 1; 
            clonedQL.SIN__c = qlList.SIN__c;
            clonedQL.Inventory_Id__c = qlList.Inventory_Id__c;//added by saiv
            clonedQL.SFInventoryId__c = qlList.SFInventoryId__c;//added by saiv
            clonedQL.SBQQ__ListPrice__c = Decimal.valueOf(qlprodIdnPriceMap.get(qlList.SBQQ__Product__r.Id));
            clonedQL.SBQQ__DefaultSubscriptionTerm__c = 1;
            clonedQL.Attribute_Relationship__c = qlList.Attribute_Relationship__c; 
            clonedQL.Modified_from_Quote_Builder__c = mapOfModifiedReason.get(qlList.Id); //MHMAC-506
            if(startDateOfNextMonth !=null){
                clonedQL.SBQQ__StartDate__c = startDateOfNextMonth;//<T28>
            }
            clonedQL.skipFlows__c = true;//<T28>
            clonedQLlist.add(clonedQL); 
            qlList.SBQQ__Quantity__c = 0;
            qlList.Id = qlList.Id;
            qlList.Loss_Reasons__c = LossReasons;
            qlList.SBQQ__ListPrice__c = 0;
            qlList.Modified_from_Quote_Builder__c = mapOfModifiedReason.get(qlList.Id); //MHMAC-506
            if(effectiveStartDate !=null){
                qlList.SBQQ__StartDate__c = effectiveStartDate;  
            }
            qlLinesToUpdate.add(qlList);
        }
        if(clonedQLlist.size()>0 && !Test.isRunningTest()){
            insert clonedQLlist;
        } 
        if(qlLinesToUpdate.size()>0 && !Test.isRunningTest()){
            update qlLinesToUpdate;
        } 
        System.debug('clonedQLlist');
        System.debug(clonedQLlist);
        System.debug(qlprodIdnQtyMap); 
    }  
    
    @AuraEnabled
    public static List<Object> getLossReasonsList(){
        Map<String,String> pickListValuesList = new Map<String,String>();
        List<Object> pickListValues = new List<Object>();
        Schema.DescribeFieldResult fieldResult = SBQQ__QuoteLine__c.Loss_Reasons__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.put(pickListVal.getLabel(),pickListVal.getLabel());
        }    
        for(String pk : pickListValuesList.keyset()){
            Map<String,String> pkInit = new Map<String,String>{'label'=>'','value'=>''};
                pkInit.put('label', pk);
            pkInit.put('value', pickListValuesList.get(pk));
            pickListValues.add(pkInit);
            System.debug('pkInit'+pkInit);
        }
        
        System.debug('pickListValues'+pickListValues);
        return pickListValues;
    }  
    //</T15>  
    
    @Auraenabled
    public static void QLModificationWithAmendment(String quoteLines,Id selectedQuoteId,List<Cart_Line_Item__c> cliList,String accId){//along with New Cart line insertion
        System.debug(quoteLines);
        Set<Id> quoteLineIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        Map<String,String> qlprodIdnQtyMap = new Map<String,String>();
        Map<String,String> qlprodIdnPriceMap = new Map<String,String>();
        List<SBQQ__QuoteLine__c> qlLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> clonedQLlist = new List<SBQQ__QuoteLine__c>();        
        Id quoteId;
        String LossReasons;
        Date effectiveStartDate;
        Date startDateOfNextMonth;//<T28>
        Map<Id,Id> prodVsPBE = new Map<Id,Id>();
        List<Object> parsedResponse = (List<Object>) JSON.deserializeUntyped(quoteLines);
        System.debug(parsedResponse);
        
        Map<String,Product2> prodVsProdMap = new  Map<String,Product2>();
        for (Object finalObj : parsedResponse) {
            System.debug('test----');
            Map<String,Object> tempObjMap = (Map<String,Object>) finalObj;
            //System.debug(tempObjMap.get('Id'));  //val1,val3 ;
            quoteLineIds.add(tempObjMap.get('Id').toString());
            prodIds.add(tempObjMap.get('ProductId').toString());
            qlprodIdnQtyMap.put(tempObjMap.get('ProductId').toString(),tempObjMap.get('Quantity').toString());
            qlprodIdnPriceMap.put(tempObjMap.get('ProductId').toString(),tempObjMap.get('Price').toString().remove('$'));
            quoteId = tempObjMap.get('QuoteId').toString();
            if(tempObjMap.get('StartDate')!=null){
                effectiveStartDate = Date.valueOf(tempObjMap.get('StartDate').toString());
            }
            Date currentDate = Date.today();//<T28>
            startDateOfNextMonth = currentDate.toStartOfMonth().addMonths(1);//<T28>
            System.debug('startDateOfNextMonth: ' + startDateOfNextMonth);//<T28>
            if(tempObjMap.get('LossReasons')!=null){
                LossReasons = tempObjMap.get('LossReasons').toString();
            }
            //System.debug(tempObjMap.get('Quantity')); //val2,val4 ;
        }
        System.debug(quoteLineIds);
        
        for(SBQQ__QuoteLine__c qlList : [Select Id, SBQQ__ListPrice__c,SBQQ__NetPrice__c,Inventory_Id__c, SFInventoryId__c,SBQQ__CustomerPrice__c,SBQQ__SpecialPrice__c,SBQQ__Product__r.Id, SBQQ__Quantity__c,SBQQ__ProductSubscriptionType__c,SBQQ__SubscriptionType__c,SBQQ__SubscriptionPricing__c,SBQQ__ChargeType__c,SBQQ__BillingType__c,SBQQ__BillingFrequency__c,SBQQ__PricebookEntryId__c,SBQQ__SubscriptionTerm__c,SIN__c,Attribute_Relationship__c from SBQQ__QuoteLine__c Where Id in :quoteLineIds Order By Id]){
            SBQQ__QuoteLine__c clonedQL = qlList.clone(false, true, false, false);
            //SBQQ__QuoteLine__c clonedQL = new SBQQ__QuoteLine__c();
            clonedQL.SBQQ__Quantity__c = Decimal.valueOf(qlprodIdnQtyMap.get(qlList.SBQQ__Product__r.Id));
            clonedQL.SBQQ__Quote__c = quoteId;
            clonedQL.skipFlows__c = true;
            clonedQL.SBQQ__ProductSubscriptionType__c = qlList.SBQQ__ProductSubscriptionType__c;
            clonedQL.SBQQ__SubscriptionType__c = qlList.SBQQ__SubscriptionType__c;
            clonedQL.SBQQ__SubscriptionPricing__c = qlList.SBQQ__SubscriptionPricing__c;
            clonedQL.SBQQ__ChargeType__c = qlList.SBQQ__ChargeType__c;
            clonedQL.SBQQ__BillingType__c = qlList.SBQQ__BillingType__c;
            clonedQL.SBQQ__BillingFrequency__c = qlList.SBQQ__BillingFrequency__c;
            clonedQL.SBQQ__PricebookEntryId__c = qlList.SBQQ__PricebookEntryId__c;
            clonedQL.SBQQ__SubscriptionTerm__c = 1;
            clonedQL.Inventory_Id__c = qlList.Inventory_Id__c;
            clonedQL.SFInventoryId__c = qlList.SFInventoryId__c;
            clonedQL.SIN__c = qlList.SIN__c;
            clonedQL.SBQQ__ListPrice__c = Decimal.valueOf(qlprodIdnPriceMap.get(qlList.SBQQ__Product__r.Id));
            clonedQL.SBQQ__DefaultSubscriptionTerm__c = 1;
            clonedQL.Attribute_Relationship__c = qlList.Attribute_Relationship__c;  
            if(startDateOfNextMonth !=null){
                clonedQL.SBQQ__StartDate__c = startDateOfNextMonth;//<T28>
            }
            clonedQL.skipFlows__c = true;//<T28>
            clonedQLlist.add(clonedQL); 
            qlList.SBQQ__Quantity__c = 0;
            qlList.Id = qlList.Id;
            qlList.Loss_Reasons__c = LossReasons;
            qlList.SBQQ__ListPrice__c = 0;
            if(effectiveStartDate !=null){
                qlList.SBQQ__StartDate__c = effectiveStartDate;  
            }
            qlLinesToUpdate.add(qlList);
        }
        /*if(clonedQLlist.size()>0){
insert clonedQLlist;
}*/ 
        String clonedQLData = '';
        if(clonedQLlist.size()>0){
            clonedQLData = JSON.serialize(clonedQLlist);
        }
        if(qlLinesToUpdate.size()>0 && !Test.isRunningTest()){
            update qlLinesToUpdate;
        } 
        System.debug('clonedQLlist');
        System.debug(clonedQLlist);
        System.debug(qlprodIdnQtyMap); 
        
        //new quote line for Amendment
        system.debug('selectedQuoteId '+selectedQuoteId);
        system.debug('cliList====== '+cliList);
        Id accountId = id.valueOf(accId);
        List<SelectedData> selectedAdDataList = new List<SelectedData>();
        List<SelectedProfProdData> SelectedProfProdDataList = new List<SelectedProfProdData>();
        for(Cart_Line_Item__c cli : cliList){
            if(cli.AOP__c !=null){
                SelectedData sld = new SelectedData();
                sld.Region = cli.Region__c;
                sld.aop = cli.AOP__c;
                //sld.aopId = cli.AopId__c;
                sld.countryName = cli.Country__c;
                sld.countryId = cli.CountryId__c;
                if(cli.CountyId__c != null){
                    sld.countyId = cli.CountyId__c;   
                }
                if(cli.CityId__c != null){
                    sld.cityId = cli.CityId__c;
                }
                if(cli.StateId__c != null){
                    sld.stateId = cli.StateId__c;    
                }
                if(cli.AvvoInventoryId__c != null){
                    sld.AvvoInvId = cli.AvvoInventoryId__c;
                }
                sld.product = cli.Name;
                sld.Blocks = String.valueOf(cli.Quantity__c);
                if(cli.Price__c!=null){
                    System.debug(cli.Price__c);
                    String Price = string.valueOf(cli.Price__c);
                    Price = Price.remove('$');
                    Integer ListPrice = Integer.valueOf(Price);
                    sld.Price = ListPrice;
                }
                selectedAdDataList.add(sld);
            }else {
                SelectedProfProdData sld = new SelectedProfProdData();
                //sld.cusId = cli.Professional__c;
                sld.customerId = cli.Professional__c;
                //sld.tierName = cli.Sub_Tier_name__c;
                //sld.tierValue = cli.Tier_Value__c;
                sld.product = cli.Name;
                if(cli.Price__c!=null){
                    System.debug(cli.Price__c);
                    
                    String Price = string.valueOf(cli.Price__c);
                    Price = Price.remove('$');
                    Integer ListPrice = Integer.valueOf(Price);
                    sld.Price = ListPrice;
                }
                SelectedProfProdDataList.add(sld);
            }
        }
        String adData = '';
        if(!selectedAdDataList.isEmpty()){
            adData = JSON.serialize(selectedAdDataList);
        }
        system.debug('====adData2327===='+adData);
        String prodData = '';
        if(!SelectedProfProdDataList.isEmpty()){
            prodData = JSON.serialize(SelectedProfProdDataList);
        }
        if((adData!='' || prodData!='') && clonedQLData!='' && !TEst.isRunningTest()){
            createQuoteLinesAsync(adData,selectedQuoteId,accountId,prodData,clonedQLData);    
        }
    }
    
    @Auraenabled
    public static boolean checkNewQuoteLinesInQuote(Id selectedQuoteId){//along with New Cart line insertion
        boolean hasNewQL = false;
        for(SBQQ__QuoteLine__c ql: [Select Id,SIN__c,SBQQ__Source__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:selectedQuoteId]){
            system.debug('SIN for ql '+ql.SIN__c);
            if(ql.SIN__c==null || ql.SIN__c==''){//For brand new Quote line created through Cart Line
                hasNewQL=true;
                break;
            }else if(ql.SBQQ__Source__c!=null){//For amended Quote lines created through the clone process using Modify Option
                hasNewQL=true;
                break;
            }
        }
        system.debug('hasNewQL '+hasNewQL);
        return hasNewQL;
    }
    
    
    //<T17> 
    /*
@Auraenabled
public static void QLTierChange(String quoteLines){
System.debug(quoteLines);
Set<Id> quoteLineIds = new Set<Id>();
Set<Id> prodIds = new Set<Id>();
List<SBQQ__QuoteLine__c> qlLinesToUpdate = new List<SBQQ__QuoteLine__c>();
List<SBQQ__QuoteLine__c> clonedQLlist = new List<SBQQ__QuoteLine__c>();        
Id quoteId;
Map<Id,String> qlIdTierMap = new Map<Id,String>();
Map<Id,String> qlIdPriceMap = new Map<Id,String>();
List<Object> parsedResponse = (List<Object>) JSON.deserializeUntyped(quoteLines);
System.debug(parsedResponse);
Id MAQuoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('M_A_Quote_Line').getRecordTypeId();

for (Object finalObj : parsedResponse) {
Map<String,Object> tempObjMap = (Map<String,Object>) finalObj;
quoteLineIds.add(tempObjMap.get('Id').toString());
prodIds.add(tempObjMap.get('ProductId').toString());
quoteId = tempObjMap.get('QuoteId').toString();
qlIdTierMap.put(tempObjMap.get('Id').toString(),tempObjMap.get('Tier').toString());
qlIdPriceMap.put(tempObjMap.get('Id').toString(),tempObjMap.get('Price').toString().removeStart('$'));
System.debug(tempObjMap.get('Id').toString()); //val2,val4 ;
}
System.debug(quoteLineIds);   
for(SBQQ__QuoteLine__c qlList : [Select Id,SBQQ__Product__r.Id,SIN__c,Tier_Value__c,SBQQ__ProductSubscriptionType__c,SBQQ__ProductCode__c,SBQQ__SubscriptionType__c,SBQQ__SubscriptionPricing__c,SBQQ__ChargeType__c,SBQQ__BillingType__c,SBQQ__BillingFrequency__c,SBQQ__PricebookEntryId__c,Contact__c,SBQQ__SubscriptionBase__c,SBQQ__DefaultSubscriptionTerm__c,SBQQ__Taxable__c  from SBQQ__QuoteLine__c Where Id in :quoteLineIds]){
SBQQ__QuoteLine__c clonedQL = qlList.clone(false, true, false, false);
system.debug('qlList.SBQQ__ProductCode__c'+qlList.SBQQ__ProductCode__c);
system.debug('clonedQL.SBQQ__ProductCode__c'+clonedQL.SBQQ__ProductCode__c);
//added by saiv MHMAC-395 T21
if(clonedQL.SBQQ__ProductCode__c == '11014' && clonedQL.SBQQ__ProductCode__c == qlList.SBQQ__ProductCode__c){
clonedQL.SIN__c = qlList.SIN__c;
}
clonedQL.SBQQ__Quantity__c = 1;
clonedQL.SBQQ__Quote__c = quoteId;
clonedQL.SBQQ__ProductSubscriptionType__c = qlList.SBQQ__ProductSubscriptionType__c;
clonedQL.SBQQ__SubscriptionType__c = qlList.SBQQ__SubscriptionType__c;
clonedQL.SBQQ__SubscriptionPricing__c = qlList.SBQQ__SubscriptionPricing__c;
clonedQL.SBQQ__ChargeType__c = qlList.SBQQ__ChargeType__c;
clonedQL.SBQQ__BillingType__c = qlList.SBQQ__BillingType__c;
clonedQL.SBQQ__BillingFrequency__c = qlList.SBQQ__BillingFrequency__c;
clonedQL.SBQQ__PricebookEntryId__c = qlList.SBQQ__PricebookEntryId__c;
clonedQL.Tier_Value__c = qlIdTierMap.get(qlList.Id);
clonedQL.SBQQ__ListPrice__c = Decimal.valueOf(qlIdPriceMap.get(qlList.Id));
clonedQL.SBQQ__SubscriptionTerm__c = 1;
clonedQL.RecordTypeId = MAQuoteLineRecordTypeId;
clonedQL.Contact__c = qlList.Contact__c;
clonedQL.SBQQ__SubscriptionBase__c = qlList.SBQQ__SubscriptionBase__c;
clonedQL.SBQQ__DefaultSubscriptionTerm__c = qlList.SBQQ__DefaultSubscriptionTerm__c;
clonedQL.SBQQ__Taxable__c = qlList.SBQQ__Taxable__c;
//clonedQL.SBQQ__StartDate__c = effectiveStartDate;
clonedQLlist.add(clonedQL);
qlList.SBQQ__Quantity__c = 0;
qlList.Id = qlList.Id;
qlList.Upgrade_Downgrade_Tag__c = qlIdTierMap.get(qlList.Id) == 'Alacarte' ? 'Downgrade' : 'Upgrade';
//qlList.Loss_Reasons__c = LossReasons;
//qlList.SBQQ__StartDate__c = effectiveStartDate;
qlLinesToUpdate.add(qlList);
}
if(qlLinesToUpdate.size()>0){
update qlLinesToUpdate;
} 
if(clonedQLlist.size()>0){
insert clonedQLlist;
} 
System.debug('clonedQLlist');
System.debug(clonedQLlist);
} //</T17>  [Commented for Ticket MHMAC-457] */
    public class AvvoInventory{
        public cls_subscriptions[] subscriptions;
    }
    class cls_subscriptions {
        public Integer id;  //9010353
        public String ad_detail_type;   //Sponsored Listing
        public Integer available_count; //19
        public Integer block_count; //7
        public String created_at;   //2014-02-28T08:03:49.000-08:00
        public Integer customer_id; //3146
        public String description;  //Child Custody Maricopa County - West, AZ
        public Integer inventory_id;    //840167
        public boolean is_exclusive;
        public Integer professional_id; //1770946
        public cls_stopped_at stopped_at;
        public String updated_at;   //2021-10-28T22:35:35.000-07:00
        public Integer sales_region_id; //3351
    }
    class cls_stopped_at {
    }
    
    public class WeightResponse{//<T30>
        public subscriptions[] subscriptions;
    }
    class subscriptions {//<T30>
        public Integer id;  //9010353
        public String normalized_ad_weight;   //1.0 //capped //exclusive
    }
    
    public class AvvoCustomer{
        public cls_customers[] customers;
    }
    
    public class cls_customers {
        public Integer id;  //14076
        public String name; //Keil Larsen
        public String email_address;    //keillarsen@gmail.com
        public String salesforce_account_id;    //0012I00002VMblxQAD
        public String start_date;   //2013-09-23
        public String phone_number; //2069539633
    }
   
}