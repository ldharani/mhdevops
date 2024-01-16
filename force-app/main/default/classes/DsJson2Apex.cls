public class DsJson2Apex {
    //public List<FormulaTabs> formulaTabs {get;set;} 
    public cls_formulaTabs[] formulaTabs;
    //public class FormulaTabs{
    public class cls_formulaTabs {
        //public List<paymentDetails> paymentDetails {get;set;}
        public cls_paymentDetails paymentDetails;
    }
    //public class PaymentDetails {
    public class cls_paymentDetails {
        public String chargeId {get;set;}
        public String customerId {get;set;} 
		public String paymentSourceId {get;set;}
    }
     public static DsJson2Apex parse(String json) {
        return (DsJson2Apex) System.JSON.deserialize(json, DsJson2Apex.class);
    }
    //[formulaTabs=(cls_formulaTabs:[paymentDetails=cls_paymentDetails:[chargeId=120010498248, customerId=916489874, paymentSourceId=915989756]])]
}