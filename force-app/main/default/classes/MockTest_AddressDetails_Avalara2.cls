/***********************************************************************************************************************
 * @author - VR
 * @date - 03 Feb 2022
 * @description - Api callout for Avalara Address Endpoint.
 * @MockClass of - AvalaraAddressValidationAPI

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/

@isTest
global class MockTest_AddressDetails_Avalara2 implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        string strEndPoint = 'https://admin.avalara.com/api/v2/addresses/resolve?line1=street&city=Jacksonville';
        

        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setTimeout(120000);   
        res.setHeader('Content-Type', 'application/json');
       
        String text = '{' +
	'    "error": {' +
	'        "code": "InvalidAddress",' +
	'        "message": "The address value was incomplete.",' +
	'        "target": "IncorrectData",' +
	'        "details": [' +
	'            {' +
	'                "code": "InvalidAddress",' +
	'                "number": 309,' +
	'                "message": "The address value was incomplete.",' +
	'                "description": "The address value NULL was incomplete. You must provide either a valid postal code, line1 + city + region, or line1 + postal code.",' +
	'                "faultCode": "Client",' +
	'                "helpLink": "http://developer.avalara.com/avatax/errors/InvalidAddress",' +
	'                "severity": "Error"' +
	'            }' +
	'        ]' +
	'    }' +
	'}';
        res.setBody(text);
        res.setStatusCode(400);
        return res;
    }
}