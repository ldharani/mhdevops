public class AuthNetJson2Apex{
	public cls_paymentProfile paymentProfile;
	//public cls_messages messages;
	public class cls_paymentProfile {
		public String customerProfileId;	//905660133
		public String customerPaymentProfileId;	//905339902
		public cls_payment payment;
		public String customerType;	//individual
		public cls_billTo billTo;
	}
	public class cls_payment {
		public cls_creditCard creditCard;
        public cls_bankAccount bankAccount;
	}
	public class cls_creditCard {
		public String cardNumber;	//XXXX4003
		public String expirationDate;	//XXXX
		public String cardType;	//AmericanExpress
		public String issuerNumber;	//371302
	}
    public class cls_bankAccount{
        public String accountType;
        public String routingNumber;
        public String accountNumber;
        public String nameOnAccount;
        public String echeckType;
    }
	public class cls_billTo {
		public String firstName;	//saivihari
		public String lastName;	//ravulapati
		public String address;	//609 limelight ct
		public String city;	//edison
		public String state;	//NJ
		public String zip;	//08820
		public String country;	//United States
	}
	public static AuthNetJson2Apex parse(String json){
		return (AuthNetJson2Apex) System.JSON.deserialize(json, AuthNetJson2Apex.class);
	}
    //for test class 
    /*
	static testMethod void testParse() {
		String json=		'{"paymentProfile":{"customerProfileId":"905660133","customerPaymentProfileId":"905339902","payment":{"creditCard":{"cardNumber":"XXXX4003","expirationDate":"XXXX","cardType":"AmericanExpress","issuerNumber":"371302"}},"customerType":"individual","billTo":{"firstName":"saivihari","lastName":"ravulapati","address":"609 limelight ct","city":"edison","state":"NJ","zip":"08820","country":"United States"}},"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}'+
		'';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}*/
}