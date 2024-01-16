@isTest
public with sharing class MDL_Test_TriggerOnOrderRPC {
    
    static testMethod void Test_TriggerOnOrderRPC() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();
        
        Contact c = testData.getContact(a.Id);  
        
        Date validtodate = Date.today();
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
               
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('false', 'Manual Fulfillment');
       
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
        
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
       
        
        //invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);
        
        //invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);
        
        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);  
        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge2 = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id); 
        
        invoiceit_s__Job__c temp_order = testData.getOrder(a.Id, CurrencyObj.Id);
        invoiceit_s__Job_Product__c temp_orderProduct = testdata.getOrderProduct(temp_order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c temp_orderRatePlan = testdata.getOrderRatePlan(temp_orderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c temp_orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(temp_orderRatePlan.Id, ProductRatePlanCharge.Id);
        insert temp_orderRatePlanCharge; 
        
        opportunity.Truncated_Order_Charges__c = temp_orderRatePlanCharge.id+',';
        update opportunity;
        
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        order.invoiceit_crmx__Opportunity__c = opportunity.Id;
        order.Created_From_Order__c = temp_order.Id;
        update order;
        
        
        
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        
        invoiceit_s__Job_Rate_Plan_Charge__c charge1 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c = orderRatePlan .Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'Monthly',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Renew' ,Created_From_Charge__c = orderRatePlanCharge.id,invoiceit_s__Service_Activation_Date__c = validtodate,invoiceit_s__Order__c = order.id);
        insert charge1; 
        
        Test.startTest();
        invoiceit_s__Job__c orderNolo = testData.getOrder(a.Id, CurrencyObj.Id);
        orderNolo.RecordTypeId = Schema.SObjectType.invoiceit_s__Job__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Order).getRecordTypeId();
        update orderNolo;
        invoiceit_s__Job_Product__c orderProductNolo = testdata.getOrderProduct(orderNolo.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlanNolo = testdata.getOrderRatePlan(orderProductNolo.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanChargeNolo = testdata.getOrderRatePlanChargeWithoutInsert(orderRatePlanNolo.Id, ProductRatePlanCharge.Id);
        //orderRatePlanChargeNolo.invoiceit_s__Mid_Term_Status__c = 'New';
        orderRatePlanChargeNolo.invoiceit_s__Status__c = 'Active';
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanChargeNolo1 = testdata.getOrderRatePlanChargeWithoutInsert(orderRatePlanNolo.Id, ProductRatePlanCharge.Id);
        orderRatePlanChargeNolo1.invoiceit_s__Status__c = 'Active';
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> list_orderRPC = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        list_orderRPC.add(orderRatePlanCharge);
        list_orderRPC.add(orderRatePlanChargeNolo);
         MDL_RecursionHandler.firstRun = true;
        insert list_orderRPC;
        
        RecursionHandlerOrderRPC.beforeupdate = true;
        orderRatePlanCharge.invoiceit_s__Status__c='Cancelled';
        orderRatePlanCharge.Loss_Reasons__c ='Price too High';
        update orderRatePlanCharge;
        
         product.Shippable__c = 'Yes';
        product.Product_Provisioning__c = 'Manual Fulfillment';
        
        update product;
        System.debug('======================'+orderRatePlanChargeNolo.invoiceit_s__Status__c);
        RecursionHandlerOrderRPC.beforeupdate = true;
        orderRatePlanChargeNolo = [select id,Name, invoiceit_s__Price_Type__c, invoiceit_s__Status__c,Shippable__c,Product_Provisioning__c
                                               from invoiceit_s__Job_Rate_Plan_Charge__c
                                               where id=:orderRatePlanChargeNolo.id];
        orderRatePlanChargeNolo.invoiceit_s__Status__c = 'Truncated';
        orderRatePlanChargeNolo.invoiceit_s__Price_Type__c = 'Annual';
        //orderRatePlanChargeNolo.Product_Provisioning__c = 'Manual Fulfillment';
        //orderRatePlanChargeNolo.invoiceit_s__Price_Type__c ='One Time';
        //orderRatePlanChargeNolo.Shippable__c='Yes';
        //orderRatePlanChargeNolo.Shippable__c='Yes';
       
        update orderRatePlanChargeNolo;
        System.debug('======================1212121'+orderRatePlanChargeNolo.invoiceit_s__Status__c);
        
        
        
        delete orderRatePlanChargeNolo;
               // MDL_trgHandlerForOrderRPC.deletefromchat(list_orderRPC); 
        
        Test.stopTest();
    }    
        //orderRatePlanCharge.invoiceit_s__Status__c = 'Cancelled';
        //update orderRatePlanCharge;
    
        
        static testmethod void testchangeRenewedOrRebasedOrTruncatedStatus(){
             MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();
        
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
            
             invoiceit_s__Product__c product = testData.getProductWithProvisioning('false', 'Manual Fulfillment');
       
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        
        //invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
         invoiceit_s__Product_Rate_Plan_Charge__c ProductRatePlanCharge = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges' + testData.randomise(),
                invoiceit_s__CurrencyL__c = currencyObj.Id,
                invoiceit_s__Product_Rate_Plan__c = productRatePlan.Id,
                invoiceit_s__Unit_Price__c = 1000,
                invoiceit_s__Cost_Price__c = 500,                                                                  
                invoiceit_s__Price_Type__c = 'Monthly',
                Renewable__c = true                                                                                                       
        ); 
        insert  ProductRatePlanCharge;   
        
        Opportunity opportunity = new Opportunity(Name = 'Auto evergreen TestOpp', AccountId = a.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = c.Id ,
                invoiceit_crmx__CurrencyL__c = currencyObj.id , invoiceit_crmx__Shipping_Contact__c = c.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 20 , Type = 'New Business',
                Discount__c = 18 ,Quote_Type__c = 'Renew',Reason_Won_Lost__c ='Auto Evergreen'
                );
         insert  opportunity;  
            
            //created from order data forming
            invoiceit_s__Job__c temp_order = new invoiceit_s__Job__c();
            
        temp_order.Name = 'Test Order' + 'xyz123';
        temp_order.invoiceit_s__Account__c = a.Id;
        temp_order.invoiceit_s__CurrencyL__c = currencyObj.id;
        temp_order.invoiceit_s__Status__c = 'In Progress';
        temp_order.Renew_Rebase__c = 'Renew';
        insert temp_order;    
             invoiceit_s__Job_Product__c temp_orderProduct = testdata.getOrderProduct(temp_order.Id, product.Id);
            invoiceit_s__Job_Rate_Plan__c temp_orderRatePlan = testdata.getOrderRatePlan(temp_orderProduct.Id, productRatePlan.Id);
             invoiceit_s__Job_Rate_Plan_Charge__c temp_orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(temp_orderRatePlan.Id, ProductRatePlanCharge.Id);
            //temp_orderRatePlanCharge.Renewable__c=true;
            temp_orderRatePlanCharge.invoiceit_s__Price_Type__c = 'Monthly';
            temp_orderRatePlanCharge.invoiceit_s__Status__c = 'Active';
            insert temp_orderRatePlanCharge;
            
            
            
            invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        order.invoiceit_crmx__Opportunity__c = opportunity.Id;
        order.Created_From_Order__c = temp_order.Id;
        //order.invoiceit_s__Service_Activation_Date__c  = system.today() -1;    
        update order;
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        system.debug('@@@@@@@in testorder.invoiceit_s__Service_Activation_Date__c'+order.invoiceit_s__Service_Activation_Date__c);    
          
            Test.startTest();
                MDL_RecursionHandler.firstRun = true;
                insert orderRatePlanCharge;
            Test.stopTest();
        
            
            
        }
    
    
    static testmethod void testcreateCaseDuringMidTermAdjustment(){
        
         MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();
        
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProductWithProvisioning('false', 'Manual Fulfillment');
       
        
        invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);
        
        Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
        
        //invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
         invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order' + testData.randomise();
        order.invoiceit_s__Account__c = a.Id;
        order.invoiceit_s__CurrencyL__c = currencyObj.id;
        order.invoiceit_s__Status__c = 'In Progress';
        //order.Created_From_Order__c  = NULL;
        //order.invoiceit_s__Service_Activation_Date__c  = system.today() - 50;
        insert order;
        
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        orderRatePlanCharge.invoiceit_s__Mid_Term_Status__c = 'New';
        
        
        Test.startTest();
             invoiceit_s__Job__c orderq = [select id, Created_From_Order__c,invoiceit_s__Service_Activation_Date__c from invoiceit_s__Job__c where id=:order.id];
        system.debug('@@@@orderq'+orderq.Created_From_Order__c);
        
        insert orderRatePlanCharge;
        orderRatePlanCharge.Live_Date__c    = date.today();
        MDL_trgHandlerForOrderRPC.liveDateRecursion = true;
        update orderRatePlanCharge;
        
        Test.stopTest();
        
    }
    
    
    
    
    
}