@isTest(seealldata=true)
private class MDL_Test_BatchOrderExpiry {
    static testMethod void testorderExpiry(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc = util.getAccount();		
		Contact con = util.getContact(acc.Id);  		
		invoiceit_s__Currency__c cur = util.getCurrencyObject();
        
        invoiceit_s__Product__c prod = util.getProduct('false');
        prod.Product_Provisioning__c = 'Manual Fulfillment';
		update prod;
        
        invoiceit_s__Product_Rate_Plan__c pRP = util.getProductRatePlan(prod.Id);		
		invoiceit_s__Product_Rate_Plan_Charge__c pRPC = util.getProductRatePlanCharge(cur.Id, pRP.Id);
        
        invoiceit_s__Job__c order = util.getOrder(acc.Id , cur.Id);
        invoiceit_s__Job_Product__c oProd = util.getOrderProduct(order.Id ,prod.Id);
        invoiceit_s__Job_Rate_Plan__c oRP = util.getOrderRatePlan(oProd.Id , pRP.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c oRPC = util.getOrderRatePlanCharge(oRP.Id , pRPC.Id);
        oRPC.invoiceit_s__Service_End_Date__c = Date.Today().addDays(-2);
        oRPC.invoiceit_s__Status__c = 'Active';        
        update oRPC;  
                       
        Test.startTest();
        MDL_BatchOrderExpiry b = new MDL_BatchOrderExpiry(); 
        Database.executeBatch(b);
        Test.stopTest(); 
        /*Database.QueryLocator QL;
        Database.BatchableContext BC;
        
        QL = b.start(BC);
        Database.QueryLocatorIterator QIT =  QL.iterator();
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> list_orderRPC = new List<invoiceit_s__Job_Rate_Plan_Charge__c>(); 
        while (QIT.hasNext()){
               invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = (invoiceit_s__Job_Rate_Plan_Charge__c)QIT.next();           
               list_orderRPC.add(orderRPC);
        } 
                
       b.execute(BC, list_orderRPC);
       b.finish(BC);*/
                
          
       
        
    }  
        
}