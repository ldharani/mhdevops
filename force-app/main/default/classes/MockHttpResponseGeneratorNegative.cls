/*
Test Class   : MockHttpResponseGeneratorNegative 
Description  : This is Mock generation class for Tokenization API
Created date : 05-12-2021
*/
@isTest
global class MockHttpResponseGeneratorNegative implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        if(req.getEndpoint() == 'https://apitest.authorize.net/xml/v1/request.api'){
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(' {"customerProfileId":"","customerPaymentProfileIdList":[""],"customerShippingAddressIdList":[],"validationDirectResponseList":["1,1,1,This transaction has been approved.,AV5G9A,Y,60167471338,none,Test transaction for ValidateCustomerPaymentProfile.,0.00,CC,auth_only,test 2,test 2,serge 2,,123 main street,null,NY,NY,12345,United States,310-280-5549,,testabc22@test.com,,,,,,,,,0.00,0.00,0.00,FALSE,none,,P,2,,,,,,,,,,,XXXX5556,Visa,,,,,,,024B2MWAST94VS1PIMPVZSB,,,,,,,,,,"],"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}');
            res.setStatusCode(200);
            return res;
            
        }else{
          // Optionally, only send a mock response for a specific endpoint
            // and method.
            System.assertEquals('http://example.com/example/test', req.getEndpoint());
            System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;    
        }
        
    }
}