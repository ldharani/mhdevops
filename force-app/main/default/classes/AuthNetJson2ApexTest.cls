@isTest
public class AuthNetJson2ApexTest {
	public static testMethod Void testParse() {
		String json='{"paymentProfile":{"customerProfileId":"905660133","customerPaymentProfileId":"905339902","payment":{"creditCard":{"cardNumber":"XXXX4003","expirationDate":"XXXX","cardType":"AmericanExpress","issuerNumber":"371302"}},"customerType":"individual","billTo":{"firstName":"saivihari","lastName":"ravulapati","address":"609 limelight ct","city":"edison","state":"NJ","zip":"08820","country":"United States"}},"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';
		AuthNetJson2Apex.parse(json);
        //System.assert(obj != null);
	}
}