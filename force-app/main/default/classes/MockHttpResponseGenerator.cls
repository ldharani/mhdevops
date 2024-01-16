@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    
        if(req.getBody().contains('getCustomerPaymentProfileRequest')){
            HttpResponse res = new HttpResponse();
           res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "paymentProfile": { "customerProfileId": "39598611", "customerPaymentProfileId": "35936989", "payment": { "creditCard": { "cardNumber": "XXXX1111", "expirationDate": "2027-04", "cardType": "Visa", "issuerNumber": "411111", "isPaymentToken": true } }, "subscriptionIds": [ "3078153", "3078154" ], "customerType": "individual", "billTo": { "firstName": "John", "lastName": "Smith" } }, "messages": { "resultCode": "Ok", "message": [ { "code": "I00001", "text": "Successful." } ] } }\uFEFF');   res.setStatusCode(200); 
        res.setStatusCode(200);
            return res;
        }
        
        if(req.getEndpoint() == 'https://apitest.authorize.net/xml/v1/request.api'){
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(' {"customerProfileId":"1931463861","customerPaymentProfileIdList":["1843538321"],"customerShippingAddressIdList":[],"validationDirectResponseList":["1,1,1,This transaction has been approved.,AV5G9A,Y,60167471338,none,Test transaction for ValidateCustomerPaymentProfile.,0.00,CC,auth_only,test 2,test 2,serge 2,,123 main street,null,NY,NY,12345,United States,310-280-5549,,testabc22@test.com,,,,,,,,,0.00,0.00,0.00,FALSE,none,,P,2,,,,,,,,,,,XXXX5556,Visa,,,,,,,024B2MWAST94VS1PIMPVZSB,,,,,,,,,,"],"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}');
            res.setStatusCode(200);
            return res;
            
        }
        else if(req.getEndpoint().contains('account-d.docusign.com')){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test","access_token":"12345"}');
            res.setStatusCode(200);
            return res;    
        }
        else if(req.getEndpoint().contains('/recipients/1/tabs')){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"formulaTabs": [{"paymentDetails": {"chargeId": "samplestring6","paymentOption": "samplestring7","customMetadataRequired": true,   "customMetadata": "samplestring9","customerId": "samplestring10","paymentSourceId": "samplestring11"}}]}');
            res.setStatusCode(200);
            return res;
        }
        else{
          // Optionally, only send a mock response for a specific endpoint
            // and method.
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;    
        }
        
    }
}