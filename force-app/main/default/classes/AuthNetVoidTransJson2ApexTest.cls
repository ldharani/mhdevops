@isTest
public class AuthNetVoidTransJson2ApexTest {
	public static testMethod void testParse() {
		String json='{"transactionResponse":{"responseCode":"1","authCode":"","avsResultCode":"P","cvvResultCode":"","cavvResultCode":"","transId":"0","refTransID":"120004731744","transHash":"","testRequest":"0","accountNumber":"","accountType":"Visa","messages":[{"code":"310","description":"This transaction has already been voided."}],"transHashSha2":"","SupplementalDataQualificationIndicator":0},"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';
		AuthNetVoidTransJson2Apex.parse(json);
		//System.assert(obj != null);
	}
}