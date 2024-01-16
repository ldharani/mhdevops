@isTest
public with sharing class MDL_Test_TriggerHandlerOnOrderRPC {
    
    static testMethod void Test_TriggerHandlerOnOrderRPC() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();      
        Contact c = testData.getContact(a.Id);          
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();        
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);     
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);      
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);     
        oppproduct.product_sin__c = '12345';
        update oppproduct;
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        oppRatePlanCharge.sin__c = '12345';
        update oppRatePlanCharge;
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge2 = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);   
        oppRatePlanCharge2.sin__c = '67890';
        update oppRatePlanCharge2;
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        order.invoiceit_crmx__Opportunity__c = opportunity.Id;
        update order;
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        orderRatePlanCharge.Opportunity_Rate_Plan_Charge__c = oppRatePlanCharge.id;
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge2 = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        orderRatePlanCharge2.Opportunity_Rate_Plan_Charge__c = oppRatePlanCharge2.id;
        orderRatePlanCharge.invoiceit_s__Order__c = order.Id;
        orderRatePlanCharge2.invoiceit_s__Order__c = order.Id;
        orderRatePlanCharge2.invoiceit_s__Status__c = 'Cancelled';
        orderRatePlanCharge2.invoiceit_s__Price__c = 100;
        //orderRatePlanCharge2.Product_Provisioning__c = 'Manual Fulfillment';
        orderRatePlanCharge2.invoiceit_s__Service_Activation_Date__c = system.today().addDays(-1);
        orderRatePlanCharge2.invoiceit_s__Service_End_Date__c = system.today();
        orderRatePlanCharge2.Loss_Reasons__c = 'Price too high';
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge3 = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        orderRatePlanCharge3.invoiceit_s__Order__c = order.Id;
        orderRatePlanCharge3.invoiceit_s__Status__c = 'Cancelled';
        orderRatePlanCharge3.invoiceit_s__Price__c = 100;
        orderRatePlanCharge3.invoiceit_s__Service_Activation_Date__c = system.today().addDays(-1);
        orderRatePlanCharge3.invoiceit_s__Service_End_Date__c = system.today();
        orderRatePlanCharge3.Loss_Reasons__c = 'Price too high';
        test.startTest();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> list_orderRPC = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        list_orderRPC.add(orderRatePlanCharge);
        list_orderRPC.add(orderRatePlanCharge2);
        list_orderRPC.add(orderRatePlanCharge3);
        insert list_orderRPC;
        
        Order_Charge_Attribute__c orderCharge1 = testdata.getOrderCharges(orderRatePlanCharge.Id , 'Text' ,'State');
        
        set<Id> set_orderRPCId = new set<Id>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c iter : list_orderRPC){
            set_orderRPCId.add(iter.Id);
        }
        
        
        MDL_trgHandlerForOrderRPC.eventsForCharges(list_orderRPC , 'Test User');
        //MDL_trgHandlerForOrderRPC.rollupECF(list_orderRPC);
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge4 = [Select Id, Product_Provisioning__c from invoiceit_s__Job_Rate_Plan_Charge__c
                                                                      where id =: orderRatePlanCharge2.Id]; 
       // MDL_trgHandlerForOrderRPC.createCaseForManuallyFulfilledProducts(new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderRatePlanCharge4});
        
        invoiceit_s__Job__c renewed_order = testData.getOrder(a.Id, CurrencyObj.Id);
        renewed_order.Created_From_Order__c = order.Id;
        update renewed_order;
        invoiceit_s__Job_Product__c orderProduct1 = testdata.getOrderProduct(renewed_order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan1 = testdata.getOrderRatePlan(OrderProduct1.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge_1 = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan1.Id, ProductRatePlanCharge.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge2_1 = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan1.Id, ProductRatePlanCharge.Id);
       
        orderRatePlanCharge_1.invoiceit_s__Order__c = renewed_order.Id;
        orderRatePlanCharge2_1.invoiceit_s__Order__c = renewed_order.Id;
        orderRatePlanCharge2_1.invoiceit_s__Mid_Term_Status__c = 'New';
        List<invoiceit_s__Job_Rate_Plan_Charge__c> list_orderRPC1 = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        list_orderRPC1.add(orderRatePlanCharge_1);
        list_orderRPC1.add(orderRatePlanCharge2_1);
        
        insert list_orderRPC1;
        
        //MDL_trgHandlerForOrderRPC.handleBeforeOnOrderRatePlanChargeforRenew(list<invoiceit_s__Job_Rate_Plan_Charge__c> newCharges, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> newMap, map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> oldMap);
        
        
        invoiceit_s__Job__c order1 = testData.getOrder(a.Id, currencyObj.Id);
        order1.Do_Not_Renew__c = false;
        order1.invoiceit_s__Number_Of_Terms__c = 4;
        order1.invoiceit_s__Discount_Percent__c = 0.0;
        update order1;
        
        RecordType r = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Case' and r.Name = 'MDL Oppty Renew' LIMIT 1];
        Case c1 = new Case();
        c1.AccountId = a.Id;
        c1.RecordTypeId = r.Id;
        c1.Subject = 'Subscription Renewal for '+a.Name;
        c1.Description = 'Account is due for renewal within 120 days';
        c1.Priority = 'Medium';
        c1.Area__c = 'Opportunity';
        c1.Sub_Area__c = 'Renewal';
        c1.Reason = 'Midterm Adjustment';
        //c1.AccountId = order1
        c1.Parent_Order__c = order1.Id;
        insert c1;
        
        
        MDL_trgHandlerForOrderRPC.createCaseDuringMidTermAdjustment(list_orderRPC1);
        Test.stopTest();    
    }
    
    
}