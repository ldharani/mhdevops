@isTest(seeALLData=true)
public with sharing class MDL_Test_ClassOnOrderrp{
          
        static testmethod void Test_ClassOnOrderrp(){
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
                invoiceit_s__Price_Type__c = 'Monthly'
                //Renewable__c = true                                                                                                       
        ); 
        insert  ProductRatePlanCharge;   
        
        Opportunity opportunity = new Opportunity(Name = ' TestOpp', AccountId = a.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = c.Id ,
                invoiceit_crmx__CurrencyL__c = currencyObj.id , invoiceit_crmx__Shipping_Contact__c = c.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 20 , Type = 'New Business',
                Discount__c = 18 ,Quote_Type__c = 'new ',Reason_Won_Lost__c ='Auto Evergreen'
                );
         insert  opportunity; 
        
        
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity.Id);     
        oppproduct.product_sin__c = '12345';
        update oppproduct;
         
         invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProduct.Id, productRatePlan.Id);      
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = testData.getOppRatePlanCharge(OppRatePlan.Id, ProductratePlanCharge.Id);    
        oppRatePlanCharge.sin__c = '12345';
        update oppRatePlanCharge; 
            
            //created from order data forming
            invoiceit_s__Job__c temp_order = new invoiceit_s__Job__c();
            
        temp_order.Name = 'Test Order' + 'xyz123';
        temp_order.invoiceit_s__Account__c = a.Id;
        temp_order.invoiceit_s__CurrencyL__c = currencyObj.id;
        temp_order.invoiceit_s__Status__c = 'Active';
        //temp_order.Renew_Rebase__c = 'Renew';
        insert temp_order;    
             invoiceit_s__Job_Product__c temp_orderProduct = testdata.getOrderProduct(temp_order.Id, product.Id);
            invoiceit_s__Job_Rate_Plan__c temp_orderRatePlan = testdata.getOrderRatePlan(temp_orderProduct.Id, productRatePlan.Id);
             invoiceit_s__Job_Rate_Plan_Charge__c temp_orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(temp_orderRatePlan.Id, ProductRatePlanCharge.Id);
            //temp_orderRatePlanCharge.Renewable__c=true;
            temp_orderRatePlanCharge.invoiceit_s__Price_Type__c = 'Monthly';
            temp_orderRatePlanCharge.invoiceit_s__Status__c = 'Active';
            insert temp_orderRatePlanCharge;
           
            List<Id> orderRPIdLst = new List<Id>();
             orderRPIdLst.add(temp_orderRatePlan.Id);
            
            invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        order.invoiceit_crmx__Opportunity__c = opportunity.Id;
        order.Created_From_Order__c = temp_order.Id;
        //order.invoiceit_s__Service_Activation_Date__c  = system.today() -1;    
        update order;
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge = testdata.getOrderRatePlanChargeWithoutInsert(OrderRatePlan.Id, ProductRatePlanCharge.Id);
        system.debug('@@@@@@@in testorder.invoiceit_s__Service_Activation_Date__c'+order.invoiceit_s__Service_Activation_Date__c);    
        
         orderRatePlan.name =  orderRatePlanCharge.Name;
         update  orderRatePlan;
         Test.startTest();
            
         ClassOnOrderRatePlan.ratePlanUpdate(orderRPIdLst);
         Test.stopTest();
        
            
            
        }
        
        
  }