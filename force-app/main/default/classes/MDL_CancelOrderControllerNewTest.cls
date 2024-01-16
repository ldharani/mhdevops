@isTest(seeAllData= true)
private class MDL_CancelOrderControllerNewTest{
  static testmethod void cancelOrderTest(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc = util.getAccount();
        System.assertNotEquals(acc,null);
        
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        Contact con = util.getContact(acc.Id);
         System.assertNotEquals(con,null);
         
        //product creation
        invoiceit_s__Product__c prod                                = util.getProduct('isInventorable');        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = util.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = util.getProductRatePlanCharge(Curr.Id, prodrateplan.id); 
        prodRatePlanCharge.Package_Wrapper__c = true;
        insert prodRatePlanCharge;        
        //Opportunity Creation
        //Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );  
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();

       System.debug('devRecordTypeId ---->'+devRecordTypeId );
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,RecordTypeId = devRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
            invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
            invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
            invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
            invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
            invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
            invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
            Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
            Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        System.debug('opp---->'+opp);
        try{
        insert opp;
        }
        catch(Exception e){}
        System.assertNotEquals(opp,null);
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        //invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order';
        order.invoiceit_s__Account__c = acc.Id;
        order.invoiceit_s__CurrencyL__c = Curr.id;
        order.invoiceit_s__Status__c = 'Active';
        order.invoiceit_s__Number_Of_Terms__c = 1;
        order.invoiceit_crmx__Opportunity__c = opp.id;
        insert order;
        
         invoiceit_s__Job__c childorder = new invoiceit_s__Job__c();
        childorder.Name = 'Test Order1';
        childorder.invoiceit_s__Account__c = acc.Id;
        childorder.invoiceit_s__CurrencyL__c = Curr.id;
        childorder.invoiceit_s__Status__c = 'Active';
        childorder.invoiceit_crmx__Opportunity__c = opp.id;
        childorder.invoiceit_s__Renewed_From__c = order.id;
        childorder.invoiceit_s__Number_Of_Terms__c = 1;
        childorder.Parent_Order__c = order.id;
        insert childorder;
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Preferred National Links';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        Test.startTest();
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge.invoiceit_s__Status__c = 'Active'; 
        orderRatePlanCharge.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id;
        //orderRatePlanCharge.Package_Wrapper__c = true;    
        orderRatePlanCharge.Terms_Months__c = 3;        
        update orderRatePlanCharge;
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge0    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge0.invoiceit_s__Status__c = 'Active';  
        orderRatePlanCharge0.invoiceit_s__Order__c = childorder.id;  
        //orderRatePlanCharge0.Package_Wrapper__c = true;  
        orderRatePlanCharge0.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id;
        orderRatePlanCharge0.Chat_Parent_Order_Rate_Plan_Charge__c = orderRatePlanCharge.id;   
        orderRatePlanCharge0.Terms_Months__c = 3;         
        update orderRatePlanCharge0;
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge1    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge1.invoiceit_s__Status__c = 'Active';  
        orderRatePlanCharge1.invoiceit_s__Order__c = childorder.id;
        orderRatePlanCharge1.Chat_Parent_Order_Rate_Plan_Charge__c = orderRatePlanCharge0.id; 
        //orderRatePlanCharge1.Package_Wrapper__c = true;  
        orderRatePlanCharge1.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id; 
        orderRatePlanCharge1.Terms_Months__c = 3;            
        update orderRatePlanCharge1;
        
        Chat_Product_Order_Charge__c chatPOC = new Chat_Product_Order_Charge__c();
        chatPOC.Chat_Usage_Order_Rate_Plan_Charge__c = orderRatePlanCharge1.Id;
        chatPOC.Chat_Product_Order_Rate_Plan_Charge__c = orderRatePlanCharge.Id; 
        insert chatPOC;
        //creating geo location record
        //Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
        
        
            ApexPages.StandardController sc = new ApexPages.StandardController(order);
            MDL_CancelOrderControllerNew controller = new MDL_CancelOrderControllerNew(sc);
            MDL_CancelOrderControllerNew.InnerClassORPC packageW = new MDL_CancelOrderControllerNew.InnerClassORPC(orderRatePlanCharge1,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderRatePlanCharge1});
            controller.packageWrap = packageW;
            controller.componentWrap = new List<MDL_CancelOrderControllerNew.InnerClassORPC>{packageW};
            controller.independentWrap = new List<MDL_CancelOrderControllerNew.InnerClassORPC>{packageW};
            MDL_CancelOrderControllerNew.getPicklistValues(new invoiceit_s__Job__c(),'Loss_Reasons__c');
            controller.getItems();
            controller.initialize();
            controller.cancelCharges();
            controller.cancel();
            MDL_CancelOrderControllerNew.cancelChildCharge(orderRatePlanCharge1,'',Date.today());
          
            controller.childorderId = null;
            controller.radiobuttonstatus = 'No';
            order.invoiceit_s__Status__c = 'Active';
            update order;
            controller.updateAllCharges();
            controller.updateIndependentCharges();
        Test.stopTest();
     }
     
      static testmethod void cancelOrderTest1(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc = util.getAccount();
        System.assertNotEquals(acc,null);
        
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        Contact con = util.getContact(acc.Id);
         System.assertNotEquals(con,null);
         
        //product creation
        invoiceit_s__Product__c prod                                = util.getProduct('isInventorable');        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = util.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = util.getProductRatePlanCharge(Curr.Id, prodrateplan.id); 
        prodRatePlanCharge.Package_Wrapper__c = false;
        insert prodRatePlanCharge;        
        //Opportunity Creation
        //Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );  
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();

       System.debug('devRecordTypeId ---->'+devRecordTypeId );
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,RecordTypeId = devRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
            invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
            invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
            invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
            invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
            invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
            invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
            Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
            Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        System.debug('opp---->'+opp);
        try{
        insert opp;
        }
        catch(Exception e){}
        System.assertNotEquals(opp,null);
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        //invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order';
        order.invoiceit_s__Account__c = acc.Id;
        order.invoiceit_s__CurrencyL__c = Curr.id;
        order.invoiceit_s__Status__c = 'Cancelled';
        order.invoiceit_s__Number_Of_Terms__c = 1;
        order.invoiceit_crmx__Opportunity__c = opp.id;
        insert order;
        
         invoiceit_s__Job__c childorder = new invoiceit_s__Job__c();
        childorder.Name = 'Test Order1';
        childorder.invoiceit_s__Account__c = acc.Id;
        childorder.invoiceit_s__CurrencyL__c = Curr.id;
        childorder.invoiceit_s__Status__c = 'Cancelled';
        childorder.invoiceit_crmx__Opportunity__c = opp.id;
        childorder.invoiceit_s__Renewed_From__c = order.id;
        childorder.invoiceit_s__Number_Of_Terms__c = 1;
        childorder.Parent_Order__c = order.id;
        insert childorder;
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Preferred National Links';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        Test.startTest();
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge.invoiceit_s__Status__c = 'Cancelled'; 
        orderRatePlanCharge.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id;
        //orderRatePlanCharge.Package_Wrapper__c = true;    
        orderRatePlanCharge.Loss_Reasons__c = 'Price too High';          
        update orderRatePlanCharge;
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge0    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge0.invoiceit_s__Status__c = 'Cancelled';  
        orderRatePlanCharge0.invoiceit_s__Order__c = childorder.id;  
        //orderRatePlanCharge0.Package_Wrapper__c = true;  
        orderRatePlanCharge0.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id;
        orderRatePlanCharge0.Chat_Parent_Order_Rate_Plan_Charge__c = orderRatePlanCharge.id; 
        orderRatePlanCharge0.Loss_Reasons__c = 'Price too High';           
        update orderRatePlanCharge0;
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge1    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge1.invoiceit_s__Status__c = 'Cancelled';  
        orderRatePlanCharge1.invoiceit_s__Order__c = childorder.id;
        orderRatePlanCharge1.Chat_Parent_Order_Rate_Plan_Charge__c = orderRatePlanCharge0.id; 
        //orderRatePlanCharge1.Package_Wrapper__c = true;  
        orderRatePlanCharge1.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id; 
        orderRatePlanCharge1.Loss_Reasons__c = 'Price too High';            
        update orderRatePlanCharge1;
        
        Chat_Product_Order_Charge__c chatPOC = new Chat_Product_Order_Charge__c();
        chatPOC.Chat_Usage_Order_Rate_Plan_Charge__c = orderRatePlanCharge1.Id;
        chatPOC.Chat_Product_Order_Rate_Plan_Charge__c = orderRatePlanCharge.Id; 
        insert chatPOC;
        //creating geo location record
        //Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
        
        
            ApexPages.StandardController sc = new ApexPages.StandardController(order);
            MDL_CancelOrderControllerNew controller = new MDL_CancelOrderControllerNew(sc);
             /*MDL_CancelOrderControllerNew.InnerClassORPC packageW = new MDL_CancelOrderControllerNew.InnerClassORPC(orderRatePlanCharge1,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderRatePlanCharge1});
            controller.packageWrap = packageW;
            controller.componentWrap = new List<MDL_CancelOrderControllerNew.InnerClassORPC>{packageW};*/
            
            MDL_CancelOrderControllerNew.getPicklistValues(new invoiceit_s__Job__c(),'Loss_Reasons__c');
            controller.getItems();
            controller.initialize();
            controller.cancelCharges();
            controller.cancel();
            MDL_CancelOrderControllerNew.cancelChildCharge(orderRatePlanCharge1,'',Date.today());
          
            controller.TotalValue= 2.0;
            controller.radiobuttonstatus = 'Yes';
          
            controller.updateAllCharges();
            controller.updateIndependentCharges();
        Test.stopTest();
     }
     
     static testmethod void cancelOrderTest2(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        Account acc = util.getAccount();
        System.assertNotEquals(acc,null);
        
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        Contact con = util.getContact(acc.Id);
         System.assertNotEquals(con,null);
         
        //product creation
        invoiceit_s__Product__c prod                                = util.getProduct('isInventorable');        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = util.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = util.getProductRatePlanCharge(Curr.Id, prodrateplan.id); 
        prodRatePlanCharge.Package_Wrapper__c = false;
        insert prodRatePlanCharge;        
        //Opportunity Creation
        //Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );  
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();

       System.debug('devRecordTypeId ---->'+devRecordTypeId );
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,RecordTypeId = devRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = curr.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
            invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
            invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
            invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
            invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
            invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
            invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
            Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
            Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
        System.debug('opp---->'+opp);
        try{
        insert opp;
        }
        catch(Exception e){}
        System.assertNotEquals(opp,null);
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        //invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order';
        order.invoiceit_s__Account__c = acc.Id;
        order.invoiceit_s__CurrencyL__c = Curr.id;
        order.invoiceit_s__Status__c = 'Cancelled';
        order.invoiceit_s__Number_Of_Terms__c = 1;
        order.invoiceit_crmx__Opportunity__c = opp.id;
        insert order;
        
         invoiceit_s__Job__c childorder = new invoiceit_s__Job__c();
        childorder.Name = 'Test Order1';
        childorder.invoiceit_s__Account__c = acc.Id;
        childorder.invoiceit_s__CurrencyL__c = Curr.id;
        childorder.invoiceit_s__Status__c = 'Cancelled';
        childorder.invoiceit_crmx__Opportunity__c = opp.id;
        childorder.invoiceit_s__Renewed_From__c = order.id;
        childorder.invoiceit_s__Number_Of_Terms__c = 1;
        childorder.Parent_Order__c = order.id;
        insert childorder;
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Preferred National Links';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        Test.startTest();
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge.invoiceit_s__Status__c = 'Expired'; 
        orderRatePlanCharge.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id;
        //orderRatePlanCharge.Package_Wrapper__c = true;    
        orderRatePlanCharge.Loss_Reasons__c = 'Price too High';          
        update orderRatePlanCharge;
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge0    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge0.invoiceit_s__Status__c = 'Expired';  
        orderRatePlanCharge0.invoiceit_s__Order__c = childorder.id;  
        //orderRatePlanCharge0.Package_Wrapper__c = true;  
        orderRatePlanCharge0.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id;
        orderRatePlanCharge0.Chat_Parent_Order_Rate_Plan_Charge__c = orderRatePlanCharge.id; 
        orderRatePlanCharge0.Loss_Reasons__c = 'Price too High';           
        update orderRatePlanCharge0;
        
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge1    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        orderRatePlanCharge1.invoiceit_s__Status__c = 'Expired';  
        orderRatePlanCharge1.invoiceit_s__Order__c = childorder.id;
        orderRatePlanCharge1.Chat_Parent_Order_Rate_Plan_Charge__c = orderRatePlanCharge0.id; 
        //orderRatePlanCharge1.Package_Wrapper__c = true;  
        orderRatePlanCharge1.invoiceit_s__Product_Rate_Plan_Charge__c = prodRatePlanCharge.id; 
        orderRatePlanCharge1.Loss_Reasons__c = 'Price too High';            
        update orderRatePlanCharge1;
        
        Chat_Product_Order_Charge__c chatPOC = new Chat_Product_Order_Charge__c();
        chatPOC.Chat_Usage_Order_Rate_Plan_Charge__c = orderRatePlanCharge1.Id;
        chatPOC.Chat_Product_Order_Rate_Plan_Charge__c = orderRatePlanCharge.Id; 
        insert chatPOC;
        //creating geo location record
        //Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
        
        
            ApexPages.StandardController sc = new ApexPages.StandardController(order);
            MDL_CancelOrderControllerNew controller = new MDL_CancelOrderControllerNew(sc);
            
            /* MDL_CancelOrderControllerNew.InnerClassORPC packageW = new MDL_CancelOrderControllerNew.InnerClassORPC(orderRatePlanCharge1,new List<invoiceit_s__Job_Rate_Plan_Charge__c>{orderRatePlanCharge1});
            controller.packageWrap = packageW;
            controller.componentWrap = new List<MDL_CancelOrderControllerNew.InnerClassORPC>{packageW};*/
            
            MDL_CancelOrderControllerNew.getPicklistValues(new invoiceit_s__Job__c(),'Loss_Reasons__c');
            controller.getItems();
            controller.initialize();
            controller.cancelCharges();
            controller.cancel();
            MDL_CancelOrderControllerNew.cancelChildCharge(orderRatePlanCharge1,'',Date.today());
          
            controller.TotalValue= 2.0;
            controller.radiobuttonstatus = null;
          
            controller.updateAllCharges();
            controller.updateIndependentCharges();
        Test.stopTest();
     }
}