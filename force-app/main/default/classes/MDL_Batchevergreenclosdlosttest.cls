@isTest(seealldata=true)

Public class MDL_Batchevergreenclosdlosttest{
                
       static testMethod void MDL_Batchevergreenclosdlosttest(){
       
             MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
            List<invoiceit_s__Job__c> lstOrders = new List<invoiceit_s__Job__c>();
            set<id> orderids = new  set<id>();
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
           
           orderids.add(ordersample.id);
           
         Test.startTest();
        MDL_BatchAutomateEvergreenoppClosedLost b = new MDL_BatchAutomateEvergreenoppClosedLost (orderids); 
        Database.executeBatch(b,1);
        Test.stopTest(); 
 
 }
 
 
}