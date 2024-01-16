public class voidDSTransactionClass implements Queueable, Database.AllowsCallouts {
    
    public String paymentTransIdsque{get;set;}
    public String charId{get;set;}
    
    //constructor
    public voidDSTransactionClass(String pmId, String ChargeId ){
        
        this.paymentTransIdsque            = pmId;
        this.charId            = ChargeId;
       
    }
    
    public void execute(QueueableContext context) {
        system.debug('===in execute method====');
        DocusignPaymentApi.voidDocuSignTransaction(paymentTransIdsque, charId);
    }
}