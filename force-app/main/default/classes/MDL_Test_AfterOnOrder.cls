@isTest(seealldata=true)
public class MDL_Test_AfterOnOrder{
    static testmethod void updatestatus(){
        List<invoiceit_s__Job__c> orderlist = new List<invoiceit_s__Job__c>();
                MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
                Account account2 = util.getAccount();
                Contact contact2 = util.getContact(account2.Id);
                invoiceit_s__Currency__c currency2 = util.getCurrencyObject();
                invoiceit_s__Job__c order2 = util.getOrder(account2.Id , currency2.Id);
                orderlist.add(order2);
                invoiceit_s__Product__c product2 = util.getProduct('false');
                invoiceit_s__Product_Rate_Plan__c productrateplan2 = util.getProductRatePlan(product2.Id);
                invoiceit_s__Product_Rate_Plan_Charge__c productrateplancharge2 = util.getProductRatePlanCharge(currency2.Id ,productrateplan2.Id);
                invoiceit_s__Job_Product__c jobproduct2 = util.getOrderProduct(order2.Id,product2.Id);
                invoiceit_s__Job_Rate_Plan__c jobrateplan2 = util.getOrderRatePlan(jobproduct2.Id, productrateplan2.Id);
                invoiceit_s__Job_Rate_Plan_Charge__c jobrateplancharge2 = util.getOrderRatePlanCharge(jobrateplan2.Id , productrateplancharge2.Id);
               // order1.invoiceit_s__Status__c = 'Expired';
              //  update orderlist;
               // System.debug(order1.invoiceit_s__Status__c);
    }
}