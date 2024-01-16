@isTest(seealldata=true)

Public class MDL_BatchAutoEvergreenHandlertest {
                
       static testMethod void testMakeOtherOppsClosedLostWhenOppIsClosedWon(){
       
             MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
            List<invoiceit_s__Job__c> lstOrders = new List<invoiceit_s__Job__c>();
            Account a = testData.getAccount();              
            Contact c = testData.getContact(a.Id);          
            invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
            
            invoiceit_s__Product__c product = testData.getProduct('true');
            
            invoiceit_s__Job__c ordersample = testData.getOrder(a.Id , currencyObj.Id);
            
            invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
            invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id); 
            invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge1 = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id); 
            
           List<Opportunity> opplist = new List<opportunity>();
            Opportunity opportunity = testData.getOpportunitywithoutInsert(a.Id, c.Id, currencyObj.Id);  
            opportunity.Created_From_Order__c = ordersample.Id;
            Opportunity opportunity1 = testData.getOpportunitywithoutInsert(a.Id, c.Id, currencyObj.Id);  
            opportunity1.Ngage_Upsell_Order__c = ordersample.Id;
            opplist.add(opportunity);
           opplist.add(opportunity1);
           insert opplist;
           
           
         invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProductWithoutInsert(Product.Id, opplist[0].Id);
         oppProduct.InventoryId__c ='abcxyz123';
           insert oppProduct;
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode 
        Test.setMock(HttpCalloutMock.class, mock);
           
           lstOrders.add(ordersample);
           Test.startTest();
           MDL_BatchAutoEvergreenHandler.OppsClosedLostWhenOppIsClosedWon(lstOrders);
           Test.stopTest();
    }
    
    
     static testMethod void testMakeOtherOppsClosedLostWhenOppIsClosedWonNegative(){
       
             MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
            List<invoiceit_s__Job__c> lstOrders = new List<invoiceit_s__Job__c>();
            Account a = testData.getAccount();              
            Contact c = testData.getContact(a.Id);          
            invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
            
            invoiceit_s__Product__c product = testData.getProduct('true');
            
            invoiceit_s__Job__c ordersample = testData.getOrder(a.Id , currencyObj.Id);
            
            invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
            invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id); 
            invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge1 = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id); 
            
           List<Opportunity> opplist = new List<opportunity>();
            Opportunity opportunity = testData.getOpportunitywithoutInsert(a.Id, c.Id, currencyObj.Id);  
            opportunity.Created_From_Order__c = ordersample.Id;
            Opportunity opportunity1 = testData.getOpportunitywithoutInsert(a.Id, c.Id, currencyObj.Id);  
            opportunity1.Ngage_Upsell_Order__c = ordersample.Id;
            opplist.add(opportunity);
           opplist.add(opportunity1);
           insert opplist;
           
           
         invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProductWithoutInsert(Product.Id, opplist[0].Id);
         oppProduct.InventoryId__c ='abcxyz123';
           insert oppProduct;
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('releaseResponse');
        mock.setStatusCode(502);
        mock.setHeader('Content-Type', 'application/xml');
        // Set the mock callout mode 
        Test.setMock(HttpCalloutMock.class, mock);
           
           lstOrders.add(ordersample);
           Test.startTest();
           MDL_BatchAutoEvergreenHandler.OppsClosedLostWhenOppIsClosedWon(lstOrders);
           Test.stopTest();
    }
        
}