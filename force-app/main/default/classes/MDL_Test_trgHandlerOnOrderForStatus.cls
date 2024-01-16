@isTest(seealldata=true)
private class MDL_Test_trgHandlerOnOrderForStatus {
    static testMethod void testHandleBeforeInsertOnOrder(){
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        List<invoiceit_s__Job__c> lstOrders = new List<invoiceit_s__Job__c>();
        Account a = testData.getAccount();              
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        invoiceit_s__Job__c ordersample = testData.getOrder(a.Id , currencyObj.Id);
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id); 
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge1 = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id); 
        
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);  
        opportunity.Created_From_Order__c = ordersample.Id;
        opportunity.Quote_Type__c = 'Renew';
        update opportunity;
        
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id , currencyObj.Id);
        order.invoiceit_crmx__Opportunity__c = opportunity.Id;
        update order;
        
        lstOrders.add(order);
        Test.startTest();
        MDL_trgHandlerOnOrderForStatus trg = new MDL_trgHandlerOnOrderForStatus();
        trg.handleBeforeInsertOnOrder(lstOrders);
        
        opportunity.Quote_Type__c = 'Modify';
        update opportunity;
        
        trg.handleBeforeInsertOnOrder(lstOrders);
        Test.stopTest();
    }
  /*  static testmethod void testpopulateLossReason(){
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
         Account a = testData.getAccount();             
         Contact c = testData.getContact(a.Id);         
         invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
         
         invoiceit_s__Product__c prod1 = testData.getProductWithProvisioning('false','Manual Fulfillment');
         invoiceit_s__Job__c ordersample = testData.getOrder(a.Id , currencyObj.Id);
         ordersample.Renew_Rebase__c = 'Renew';
         update ordersample;
         
         Test.startTest();
         invoiceit_s__Job__c ordersamplerenew = testData.getOrder(a.Id , currencyObj.Id);
         ordersamplerenew.Created_From_Order__c = ordersample.Id;
         update ordersamplerenew;
         
         ordersample.invoiceit_s__Status__c = 'Cancelled';
         ordersample.Loss_Reasons__c = 'Price too high';
         ordersample.Cancellation_Date__c = Date.Today();
         update ordersample;
         Test.stopTest();        
         
    }*/
    
    
    static testmethod void testpopulateLossReason(){
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        List<invoiceit_s__Job__c> lstOrders = new List<invoiceit_s__Job__c>();
        Account a = testData.getAccount();              
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
       invoiceit_s__Job__c order1 = getOrderhere (a.id, currencyObj.id);
        invoiceit_s__Job__c order2 = getOrderhere (a.id, currencyObj.id);
        insert order1;
        
        order2.Created_From_Order__c = order1.id;
        insert order2;
      
         
         Test.startTest();
        
         
         order1.invoiceit_s__Status__c = 'Cancelled';
         order1.Loss_Reasons__c = 'Price too high';
         order1.Cancellation_Date__c = Date.Today();
        MDL_trgHandlerOnOrderForStatus.updateLossReasonRecursion = True;
         update order1;
         Test.stopTest();        
         
    }
    
    
    
    
    static testMethod void testMakeOtherOppsClosedLostWhenOppIsClosedWon(){
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        List<invoiceit_s__Job__c> lstOrders = new List<invoiceit_s__Job__c>();
        Account a = testData.getAccount();              
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
        
        invoiceit_s__Job__c ordersample = testData.getOrder(a.Id , currencyObj.Id);
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);  
        opportunity.Created_From_Order__c = ordersample.Id;
        opportunity.Quote_Type__c = 'Renew';
        opportunity.invoiceit_crmx__Discount_Percent__c = 0.0;
        update opportunity;
        
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        
        Opportunity opportunity1 = testData.getOpportunity(a.Id, c.Id, currencyObj.Id); 
        opportunity1.Created_From_Order__c = ordersample.Id;
        opportunity1.Quote_Type__c = 'Modify';
        opportunity1.invoiceit_crmx__Discount_Percent__c = 0.0;
        update opportunity1; 
        invoiceit_crmx__Opportunity_Product__c oppProduct1 = testData.getOpportunityProduct(Product.Id, opportunity1.Id);
        
        Opportunity opportunity2 = testData.getOpportunity(a.Id, c.Id, currencyObj.Id); 
        opportunity2.Parent_Opportunity__c = opportunity.Id;
        opportunity2.Quote_Type__c = 'Modify';
        opportunity2.invoiceit_crmx__Discount_Percent__c = 0.0;
        update opportunity2;      
        invoiceit_crmx__Opportunity_Product__c oppProduct2 = testData.getOpportunityProduct(Product.Id, opportunity2.Id);
        
        Opportunity opportunity3 = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);  
        opportunity3.Created_From_Order__c = ordersample.Id;
        opportunity3.Quote_Type__c = 'Renew';
        opportunity3.invoiceit_crmx__Discount_Percent__c = 0.0;
        update opportunity3;
        invoiceit_crmx__Opportunity_Product__c oppProduct3 = testData.getOpportunityProduct(Product.Id, opportunity3.Id);
        
        invoiceit_s__Job__c ordersample2 = testData.getOrder(a.Id , currencyObj.Id); 
        ordersample2.invoiceit_crmx__Opportunity__c = opportunity.Id;
        ordersample2.Created_From_Order__c = ordersample.Id;
        ordersample2.invoiceit_s__Status__c = 'Active';
        update ordersample2;
        lstOrders.add(ordersample2);
        
        Test.startTest();
        MDL_trgHandlerOnOrderForStatus b = new MDL_trgHandlerOnOrderForStatus();
        b.makeOtherOppsClosedLostWhenOppIsClosedWon(lstOrders);
        opportunity3.StageName= 'Closed Won';
        update opportunity3; 
        Test.stopTest();
    }
    /*static testMethod void testMakeOpptysClosedLostWhenOrderIsExpired(){
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account a = testData.getAccount();              
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
        
        invoiceit_s__Job__c ordersample = testData.getOrder(a.Id , currencyObj.Id);
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        //invoiceit_s__Job__c order = [Select Id, invoiceit_s__Status__c,Renew_Rebase__c from invoiceit_s__Job__c where Id=:ordersample.Id];
        System.debug('<=>'+ordersample);
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);  
        opportunity.Created_From_Order__c = ordersample.Id;
        opportunity.Quote_Type__c = 'Renew';
        opportunity.invoiceit_crmx__Discount_Percent__c = 0.0;
        update opportunity;
        
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        
        Opportunity opportunity1 = testData.getOpportunity(a.Id, c.Id, currencyObj.Id); 
        opportunity1.Created_From_Order__c = ordersample.Id;
        opportunity1.Quote_Type__c = 'Modify';        
        opportunity1.invoiceit_crmx__Discount_Percent__c = 0.0;
        update opportunity1;        
        
        invoiceit_crmx__Opportunity_Product__c oppProduct1 = testData.getOpportunityProduct(Product.Id, opportunity1.Id);
        
        Test.startTest();
        ordersample.invoiceit_s__Status__c = 'Cancelled';
        ordersample.Loss_Reasons__c = 'Price too High';
        update ordersample;
        Test.stopTest();
    }*/
    
    
    
    static testmethod void testupdateAccountNgageCustId(){
        
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        List<invoiceit_s__Job__c> lstOrders = new List<invoiceit_s__Job__c>();
        Account a = testData.getAccount();              
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
       invoiceit_s__Job__c order1 = getOrderhere (a.id, currencyObj.id);
        invoiceit_s__Job__c order2 = getOrderhere (a.id, currencyObj.id);
        lstOrders.add(order1);
        lstOrders.add(order2);
        
        Test.startTest();
          insert lstOrders;
          MDL_trgHandlerOnOrderForStatus.updateAccountNgageCustId(lstOrders);
        Test.stopTest();
        
        
        
    }
    
     public static invoiceit_s__Job__c getOrderhere(Id accId , Id CurrencyId){
        invoiceit_s__Job__c job = new invoiceit_s__Job__c();
        job.Name = 'Test Order';
        job.invoiceit_s__Account__c = accId;
        job.invoiceit_s__CurrencyL__c = CurrencyId;
        job.invoiceit_s__Status__c = 'In Progress';
         job.Ngage_Cust_ID__c = '4354535';
        
        //insert job;
        
        return job;
    }
    
    
    static testmethod void testLeastSEDonMhAccount(){
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        List<invoiceit_s__Job__c> lstOrders = new List<invoiceit_s__Job__c>();
        Account a = testData.getAccount();              
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        //invoiceit_s__Job__c ordersample = testData.getOrder(a.Id , currencyObj.Id);
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id); 
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge1 = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id); 
        
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);  
        //opportunity.Created_From_Order__c = ordersample.Id;
        //opportunity.Quote_Type__c = 'Renew';
        //update opportunity;
        
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id , currencyObj.Id);
        
         Test.startTest();    
         
         order.invoiceit_crmx__Opportunity__c = opportunity.Id;
        order.invoiceit_s__Status__c = 'Active';
        order.invoiceit_s__Service_End_Date__c = Date.Today();
        order.Renew_Rebase__c = NULL;
        update order;
         
         a.Least_Service_End_Date__c = order.invoiceit_s__Service_End_Date__c ;
         update a;
         Test.stopTest();
         
             
    }
    
}