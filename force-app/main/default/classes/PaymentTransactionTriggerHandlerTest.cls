@isTest
public class PaymentTransactionTriggerHandlerTest {
    
 static testmethod void testme(){
Cls_UtilTestClass utiltest=new Cls_UtilTestClass();

account acc = utiltest.getAccount();

blng__Invoice__c inv=utiltest.getInvoice(acc.id);

blng__PaymentTransaction__c sol= new blng__PaymentTransaction__c();
sol.blng__PaymentGateway__c='testgatewayname1';
sol.blng__GatewayStatus__c='Success';
insert sol;

}
}