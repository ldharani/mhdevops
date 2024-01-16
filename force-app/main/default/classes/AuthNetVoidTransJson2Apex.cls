public class AuthNetVoidTransJson2Apex {
	public cls_transactionResponse transactionResponse;
	public cls_messages messages;
	public class cls_transactionResponse {
		public String responseCode;	//1
		public String authCode;	//
		public String avsResultCode;	//P
		public String cvvResultCode;	//
		public String cavvResultCode;	//
		public String transId;	//0
		public String refTransID;	//120004731744
		public String transHash;	//
		public String testRequest;	//0
		public String accountNumber;	//
		public String accountType;	//Visa
		public cls_messages[] messages;
		public String transHashSha2;	//
		public Integer SupplementalDataQualificationIndicator;	//0
	}
	public class cls_messages {
		public String resultCode;	//Ok
		public cls_message[] message;
	}
	public class cls_message {
		public String code;	//I00001
		public String text;	//Successful.
	}
	public static AuthNetVoidTransJson2Apex parse(String json){
		return (AuthNetVoidTransJson2Apex) System.JSON.deserialize(json, AuthNetVoidTransJson2Apex.class);
	}
	/* 
	static testMethod void testParse() {
		String json=		'{"transactionResponse":{"responseCode":"1","authCode":"","avsResultCode":"P","cvvResultCode":"","cavvResultCode":"","transId":"0","refTransID":"120004731744","transHash":"","testRequest":"0","accountNumber":"","accountType":"Visa","messages":[{"code":"310","description":"This transaction has already been voided."}],"transHashSha2":"","SupplementalDataQualificationIndicator":0},"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}'+
		'';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}*/
}