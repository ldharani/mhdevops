/*****
Class Name: CPQ_InventorySearch_API
Created by: 
****/
public class CPQ_InventorySearch_API{
    /*
    // Execution Code
    Map<String,String> productCodeMap = new Map<String,String>();
    productCodeMap.Put('National', '01933');
    CPQ_InventorySearch_API.retrieveResult('Accountants Liability', productCodeMap, 'United States of America');
    
    // Result
    System.HttpRequest[Endpoint=http://stg-back-office-services.lawyers.com/services/salestool/v1/inventory/byCountry?countryId=United States of America&productCode=01933&aop=Accountants LiabilitypageNumber=1&pageSize=100, Method=GET]
    |System.CalloutException: Read timed out
    */
    Public static void retrieveResult(String aop, Map<String,String> productCodeMap, String countryId){
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); //initiate HTTP request
        string strEndPoint = '';
        //http://stg-back-office-services.lawyers.com/services/salestool/v1/inventory/byCity?cityId=12493&productCode=1920&aop=630&pageNumber=1&pageSize=100';
        
        if(countryId != null && countryId != ''){
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCountry?countryId=' + countryId + '&productCode=' + productCodeMap.get('National') +'&aop='+ aop + 'pageNumber=1&pageSize=100';
            System.debug('Country endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            
            HTTPResponse res = http.send(req);
            System.debug('Country Response Body : '+res.getBody());
            System.debug('Country res.getStatusCode() : '+res.getStatusCode());
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                system.debug('########'+res.getBody());
            }
        }
    }
    /*
    // Execution Code
    CPQ_InventorySearch_API.retrieveSearchCount('Accountants Liability', 'United States of America');
    
    // Result
    System.HttpRequest[Endpoint=https://webstats-services-external.lawyers.com/services/reports/v1/searchTrafficByLocationAOP?site_id=both&aop_ids=Accountants Liability&country_id=United States of America, Method=GET]
    |System.HttpResponse[Status=Bad Request, StatusCode=400]
    */
    Public static void retrieveSearchCount(String aop, String countryId){
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); //initiate HTTP request
        string strEndPoint = '' ;
        //http://webstats-services.lawyers.com/services/reports/v1/searchTrafficByLocationAOP?site_id=both&aop_ids=729&city_id=1023;
        
        if(countryId != null && countryId != ''){
            strEndPoint = system.Label.Webstats_Endpoint + '&aop_ids=' + aop + '&country_id=' + countryId;
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000);            
            HTTPResponse res = http.send(req);           
            
            System.debug('res.getStatusCode() : '+res.getStatusCode());
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                System.debug('Response Body : '+res.getBody());
            }
        }
    }
}