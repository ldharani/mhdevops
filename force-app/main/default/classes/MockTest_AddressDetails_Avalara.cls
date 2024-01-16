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
global class MockTest_AddressDetails_Avalara implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        string strEndPoint = 'https://admin.avalara.com/api/v2/addresses/resolve?line1=street&city=Jacksonville&region=FL&country=US&postalCode=32256';
        
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setTimeout(120000);   
        res.setHeader('Content-Type', 'application/json');
       
        String text = '{' +
	'    "address": {' +
	'        "line1": "street",' +
	'        "city": "Jacksonville",' +
	'        "region": "FL",' +
	'        "country": "US",' +
	'        "postalCode": "32256"' +
	'    },' +
	'    "validatedAddresses": [' +
	'        {' +
	'            "addressType": "UnknownAddressType",' +
	'            "line1": "street",' +
	'            "line2": "",' +
	'            "line3": "",' +
	'            "city": "Jacksonville",' +
	'            "region": "FL",' +
	'            "country": "US",' +
	'            "postalCode": "32256",' +
	'            "latitude": 30.21567,' +
	'            "longitude": -81.546266' +
	'        }' +
	'    ],' +
	'    "coordinates": {' +
	'        "latitude": 30.21567,' +
	'        "longitude": -81.546266' +
	'    },' +
	'    "resolutionQuality": "Intersection",' +
	'    "messages": [' +
	'        {' +
	'            "summary": "The address is not deliverable.",' +
	'            "details": "The physical location exists but there are no homes on this street. One reason might be railroad tracks or rivers running alongside this street, as they would prevent construction of homes in this location.",' +
	'            "refersTo": "Address",' +
	'            "severity": "Error",' +
	'            "source": "Avalara.AvaTax.Common"' +
	'        }' +
	'    ]' +
	'}';
        res.setBody(text);
        res.setStatusCode(200);
        return res;
    }
}