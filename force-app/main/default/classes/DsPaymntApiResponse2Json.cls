public class DsPaymntApiResponse2Json {
    public class PaymentDetails {
        public List<object> formulaTabs {get;set;} 
        public String customerId {get;set;} 
		public String paymentSourceId {get;set;}
        /* 
        public JSON2Apex(JSONParser parser) {
          
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'formulaTabs') {
						signHereTabs = arrayOfFormulaTabs(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
                }
            }
		}*/
    }
}