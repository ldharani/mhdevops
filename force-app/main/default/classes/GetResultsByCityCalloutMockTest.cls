@isTest
global class GetResultsByCityCalloutMockTest implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        string strEndPoint = 'http://stg-back-office-services.lawyers.com/services/salestool/v1/inventory/byCity?cityId=4&productCode=123451&aop=630pageNumber=1&pageSize=100';
        //http://stg-back-office-services.lawyers.com/services/salestool/v1/inventory/byCity?cityId=12493&productCode=1920&aop=630&pageNumber=1&pageSize=100';
        
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setTimeout(120000);   
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"data":[{"country_id":1,"country":"United States of America","product_id":1234511,"product":"Lawyers.com Preferred City Results","aop_id":630,"aop":"Beryllium Exposure","sold":0,"pended":0,"available":8},{"country_id":1,"country":"United States of America","product_id":1234512,"product":"Spanish Display Ads","aop_id":630,"aop":"Beryllium Exposure","sold":0,"pended":0,"available":8},{"country_id":1,"country":"United States of America","product_id":1234512,"product":"LDC Spanish Preferred City Results","aop_id":630,"aop":"Beryllium Exposure","sold":0,"pended":0,"available":8},{"country_id":1,"country":"United States of America","product_id":1234512,"product":"MDC Preferred City Result Sponsorship Links","aop_id":630,"aop":"Beryllium Exposure","sold":0,"pended":0,"available":8},{"country_id":1,"country":"United States of America","product_id":1234512,"product":"MDC Preferred City Result","aop_id":630,"aop":"Beryllium Exposure","sold":0,"pended":0,"available":8},{"country_id":1,"country":"United States of America","product_id":1234512,"product":"MDC Preferred County Result","aop_id":630,"aop":"Beryllium Exposure","sold":0,"pended":0,"available":8}],"errorMessage":null,"cacheable":false}');
        res.setStatusCode(200);
        return res;
    }
}