@isTest
global class GetSearchCountCalloutMockTest implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
         string strEndPoint = 'http://webstats-services.lawyers.com/services/reports/v1/searchTrafficByLocationAOP?site_id=both&aop_ids=729&city_id=102';

        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setTimeout(120000);   
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"cacheable":false,"report":{"search_traffic_by_location_aop_report":[{"site_id":"LDC","start_date":"2020-09-01 00:00:00","end_date":"2021-09-30 23:59:59.999999","aggregate_type":"city","city_id":1023,"city_name":"Los Angeles","county_id":0,"county_name":null,"state_id":5,"state_name":"California","country_id":1,"country_name":"United States of America","aop_id":729,"aop_name":"Bankruptcy","searches":628},{"site_id":"MDC","start_date":"2020-09-01 00:00:00","end_date":"2021-09-30 23:59:59.999999","aggregate_type":"city","city_id":1023,"city_name":"Los Angeles","county_id":0,"county_name":null,"state_id":5,"state_name":"California","country_id":1,"country_name":"United States of America","aop_id":729,"aop_name":"Bankruptcy","searches":636}]},"executionTimeMillis":18863.0}');
        res.setStatusCode(200);
        return res;
    }
}