//Author        : Akash
//Description   : Test Class for MDL_BatchChargesExpiry,MDL_BatchGenerateXMLforExpiredCharges classes
//created Date  : 01/11/2016

@isTest(seeAllData = true)
public class MDL_BatchChargesExpiryTest {
    
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass utilClass = new MDL_UtilClass_TestClass();
        
        //creating an account
        account acc = utilClass.getAccount();
        
        //creating currency
        invoiceit_s__Currency__c curr = utilClass.getCurrencyObject();
        
        //creating order
        invoiceit_s__Job__c order = utilClass.getOrder(acc.Id, Curr.Id);
        
        //creating product
        invoiceit_s__Product__c product = utilClass.getProduct('false');
        
        //creating job product
        invoiceit_s__Job_Product__c orderProduct = utilClass.getOrderProduct(order.Id, product.Id);
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c productRatePlan = utilClass.getProductRatePlan(product.Id);
        
        //creating order rate plan
        invoiceit_s__Job_Rate_Plan__c orderRatePlan  = utilClass.getOrderRatePlan(orderProduct.id, productRatePlan.id);
        
        //creating productRPC
        invoiceit_s__Product_Rate_Plan_Charge__c productRPC = utilClass.getProductRatePlanCharge(Curr.Id, productRatePlan.Id);
        
        Date previousmonthEndDate = Date.today().toStartofMonth().addDays(-1);
        
        //creating orderRPC
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = utilClass.getOrderRatePlanChargeWithoutInsert(orderRatePlan.id, productRPC.id);
        orderRPC.invoiceit_s__Service_End_Date__c     = previousmonthEndDate;
        orderRPC.invoiceit_s__Status__c               = 'Active';
        insert orderRPC;
        
        Test.startTest();
        	Database.executeBatch(new MDL_BatchChargesExpiry(), 20);
        Test.stopTest();
        
        
        
        
    }

}