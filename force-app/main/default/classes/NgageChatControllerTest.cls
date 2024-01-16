//Author      : Sai
//Date        : 17/10/2016
//Description : Test class for NgageChatController



@isTest(seeAllData = true)
public class NgageChatControllerTest {
  
    
    //to cover parent opportunity and child opportunity scenarios
    static testmethod void run2condition2(){
          MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        //creating account
        account accParent = testData.getAccount();
        account acc = testData.getAccount();
        acc.parentId = accParent.id;
        update acc;
        //creating currency
        invoiceit_s__Currency__c singlecurrency = testData.getCurrencyObject();
        
        //creating contact
        contact con = testData.getContact(acc.Id);
         Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();
        //creating opportunity
        System.debug('devRecordTypeId ---->'+devRecordTypeId );
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,RecordTypeId = devRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = singlecurrency.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
            invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
            invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
            invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
            invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
            invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
            invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
            Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
            Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
       
       
        insert opp;
         //creating product
        invoiceit_s__Product__c prod = testData.getProduct('false');
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c prodRP = testData.getProductRatePlan(prod.Id);
        
        //creating product rateplan charge
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC = testData.getProductRatePlanCharge(singlecurrency.Id, prodRP.Id);
        
        //creating opportunity Product
        List<invoiceit_crmx__Opportunity_Product__c> oppProductlist = new List<invoiceit_crmx__Opportunity_Product__c>();
        invoiceit_crmx__Opportunity_Product__c oppProduct = new invoiceit_crmx__Opportunity_Product__c();
        oppProduct.Name                            = 'Opp Product';
        oppProduct.invoiceit_crmx__Product_Code__c = '01808'; 
        oppProduct.invoiceit_crmx__Product__c      = prod.id ;
        oppProduct.invoiceit_crmx__Opportunity__c  = opp.Id;
        oppProduct.invoiceit_crmx__SequenceNumber__c = 1;
        oppProductlist.add(oppProduct);
        
        invoiceit_crmx__Opportunity_Product__c oppProduct1 = new invoiceit_crmx__Opportunity_Product__c();
        oppProduct1.Name                            = 'Opp Product1';
        oppProduct1.invoiceit_crmx__Product_Code__c = '01811'; 
        oppProduct1.invoiceit_crmx__Product__c      = prod.id ;
        oppProduct1.invoiceit_crmx__Opportunity__c  = opp.Id;
        oppProduct1.invoiceit_crmx__SequenceNumber__c = 2;
        oppProductlist.add(oppProduct1);
        insert oppProductlist;
        System.debug('oppProduct--->'+oppProduct);
        //System.assertNotEquals(oppProduct.id,null);
        
        //creating opportunity rate plan
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRP = testData.getOpportunityRatePlan(oppProductlist[0].id, prodRP.id);
         invoiceit_crmx__Opportunity_Rate_Plan__c oppRP1 = testData.getOpportunityRatePlan(oppProductlist[1].id, prodRP.id);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppRPClsit = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
        oppRPC.invoiceit_crmx__Price_Type__c = 'One Time'; 
        oppRPC.invoiceit_crmx__Unit_Price__c = 100;
        oppRPC.invoiceit_crmx__Opportunity_Rate_Plan__c = oppRP.id;
        oppRPC.invoiceit_crmx__Product_Rate_Plan_Charge__c = pRPC.id;
        oppRPC.invoiceit_crmx__Opportunity__c                  = opp.id;
        oppRPC.invoiceit_crmx__Accounting_Code__c              = '01808';
        oppRPC.Name  = 'Test';
        oppRPClsit.add(oppRPC);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPC1 = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
        oppRPC1.invoiceit_crmx__Price_Type__c = 'One Time'; 
        oppRPC1.invoiceit_crmx__Unit_Price__c = 100;
        oppRPC1.invoiceit_crmx__Opportunity_Rate_Plan__c = oppRP.id;
        oppRPC1.invoiceit_crmx__Product_Rate_Plan_Charge__c = pRPC.id;
        oppRPC1.invoiceit_crmx__Opportunity__c                  = opp.id;
        oppRPC1.invoiceit_crmx__Accounting_Code__c              = '01811';
        oppRPC1.Name  = 'Test1';
         oppRPClsit.add(oppRPC1);
        insert oppRPClsit;
        
        /*************Creating child otpy data here******************************************************/
        Opportunity childopp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,RecordTypeId = devRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = singlecurrency.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
            invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
            invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
            invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
            invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
            invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
            invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
            Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
            Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test',Parent_Opportunity__c=opp.id
        );
        
        insert childopp;
        
         invoiceit_crmx__Opportunity_Product__c oppProductc = new invoiceit_crmx__Opportunity_Product__c();
        oppProductc.Name                            = 'Opp Product123';
        oppProductc.invoiceit_crmx__Product_Code__c = '60010'; 
        oppProductc.invoiceit_crmx__Product__c      = prod.id ;
        oppProductc.invoiceit_crmx__Opportunity__c  = childopp.Id;
        oppProductc.invoiceit_crmx__SequenceNumber__c = 1;
        oppProductc.Created_From_MH_Opportunity_Product__c = oppProductlist[0].id;
        oppProductc.Created_From_Code__c  = true;
        insert oppProductc;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRPchild = testData.getOpportunityRatePlan(oppProductc.id, prodRP.id);
        
         invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRPchargehild= new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
        oppRPchargehild.invoiceit_crmx__Price_Type__c = 'One Time'; 
        oppRPchargehild.invoiceit_crmx__Unit_Price__c = 100;
        oppRPchargehild.invoiceit_crmx__Opportunity_Rate_Plan__c = oppRPchild.id;
        oppRPchargehild.invoiceit_crmx__Product_Rate_Plan_Charge__c = pRPC.id;
        oppRPchargehild.invoiceit_crmx__Opportunity__c                  = childopp.id;
        oppRPchargehild.invoiceit_crmx__Accounting_Code__c              = '60011';
        oppRPchargehild.Name  = 'Testchidl';
        oppRPchargehild.invoiceit_crmx__Status__c = 'Active';
        insert oppRPchargehild;
        system.debug('@@@@@oppRPchargehild in test class'+oppRPchargehild);
        
        Chat_Product_Opportunity_Charge__c cpoc = new Chat_Product_Opportunity_Charge__c();
        cpoc.Chat_Usage_Opp_Rate_Plan_Charge__c = oppRPchargehild.id;
        cpoc.Chat_Product_Opp_Rate_Plan_Charge__c = oppRPClsit[0].id;
        insert cpoc;
        
        
        Test.startTest();
           //ApexPages.currentPage().getParameters().put('orderid',order.id);
           NgageChatController ctrl = new NgageChatController(new apexPages.StandardController(opp));
        for(NgageChatController.AttributesWrapper atwrap : ctrl.ChatProdListFinal){
            atwrap.ChatCheck = true;
        }
        ctrl.Save();
        Test.stopTest();
            
         

        
        
        
    }
    
    //to cover parent order and child order scenarios
    static testmethod void run2condition3(){
          MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        //creating account
        account accParent = testData.getAccount();
        account acc = testData.getAccount();
        acc.parentId = accParent.id;
        update acc;
        //creating currency
        invoiceit_s__Currency__c singlecurrency = testData.getCurrencyObject();
        
        //creating contact
        contact con = testData.getContact(acc.Id);
         Id devRecordTypeId = Schema.SObjectType.invoiceit_s__Job__c.getRecordTypeInfosByName().get('M-H Order').getRecordTypeId();
        Id oppdevRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();

         //creating product
        invoiceit_s__Product__c prod = testData.getProduct('false');
        
        //creating product rate plan
        invoiceit_s__Product_Rate_Plan__c prodRP = testData.getProductRatePlan(prod.Id);
        
        //creating product rateplan charge
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC = testData.getProductRatePlanCharge(singlecurrency.Id, prodRP.Id);
        
        //creating opportunity
        System.debug('devRecordTypeId ---->'+devRecordTypeId );
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Prospecting' , Probability = 10 ,RecordTypeId = oppdevRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = singlecurrency.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
            invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
            invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
            invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
            invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
            invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
            invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
            Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
            Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test'
        );
       
       
        insert opp;
        
        //creating opportunity Product
        List<invoiceit_crmx__Opportunity_Product__c> oppProductlist = new List<invoiceit_crmx__Opportunity_Product__c>();
        invoiceit_crmx__Opportunity_Product__c oppProduct = new invoiceit_crmx__Opportunity_Product__c();
        oppProduct.Name                            = 'Opp Product';
        oppProduct.invoiceit_crmx__Product_Code__c = '01808'; 
        oppProduct.invoiceit_crmx__Product__c      = prod.id ;
        oppProduct.invoiceit_crmx__Opportunity__c  = opp.Id;
        oppProduct.invoiceit_crmx__SequenceNumber__c = 1;
        oppProductlist.add(oppProduct);
        
        insert oppProductlist;
        
        //creating order
        System.debug('devRecordTypeId ---->'+devRecordTypeId );
        invoiceit_s__Job__c  ord = new invoiceit_s__Job__c(Name = 'TestOrd', invoiceit_s__Account__c  = acc.Id,                                                       
            RecordTypeId = devRecordTypeId ,
            invoiceit_s__Billing_Contact__c  = con.Id ,invoiceit_crmx__Opportunity__c =opp.id,
            invoiceit_s__CurrencyL__c  = singlecurrency.Id , invoiceit_s__Shipping_Contact__c  = con.Id,
            invoiceit_s__VAT__c = 0,invoiceit_s__Total__c = 123 ,
            invoiceit_s__Recalculate__c  = false , invoiceit_s__Number_Of_Terms__c  = 12 
        );
       
       
        insert ord;
        
        
        //creating order Product
        List<invoiceit_s__Job_Product__c > ordProductlist = new List<invoiceit_s__Job_Product__c >();
        invoiceit_s__Job_Product__c  ordProduct = new invoiceit_s__Job_Product__c ();
        ordProduct.Name                            = 'Ord Product';
        ordProduct.invoiceit_s__Product_Code__c  = '01808'; 
        ordProduct.invoiceit_s__Product__c       = prod.id ;
        ordProduct.invoiceit_s__Job__c   = ord.Id;
        ordProduct.invoiceit_s__SequenceNumber__c  = 1;
        ordProductlist.add(ordProduct);
        
        invoiceit_s__Job_Product__c  ordProduct1 = new invoiceit_s__Job_Product__c ();
        ordProduct1.Name                            = 'Ord Product1';
        ordProduct1.invoiceit_s__Product_Code__c = '01811'; 
        ordProduct1.invoiceit_s__Product__c      = prod.id ;
        ordProduct1.invoiceit_s__Job__c  = ord.Id;
        ordProduct1.invoiceit_s__SequenceNumber__c = 2;
        ordProductlist.add(ordProduct1);
        insert ordProductlist;
        System.debug('ordProduct--->'+ordProduct);
        //System.assertNotEquals(ordProduct.id,null);
        
        //creating order rate plan
        invoiceit_s__Job_Rate_Plan__c  ordRP = testData.getOrderRatePlan(ordProductlist[0].id, prodRP.id);
         invoiceit_s__Job_Rate_Plan__c  ordRP1 = testData.getOrderRatePlan(ordProductlist[1].id, prodRP.id);
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c > ordRPClsit = new List<invoiceit_s__Job_Rate_Plan_Charge__c >();
        invoiceit_s__Job_Rate_Plan_Charge__c  ordRPC = new invoiceit_s__Job_Rate_Plan_Charge__c ();
        ordRPC.invoiceit_s__Price_Type__c  = 'One Time'; 
        ordRPC.invoiceit_s__Unit_Price__c  = 100;
        ordRPC.invoiceit_s__Job_Rate_Plan__c   = ordRP.id;
        ordRPC.invoiceit_s__Product_Rate_Plan_Charge__c  = pRPC.id;
        ordRPC.invoiceit_s__Order__c                   = ord.id;
        ordRPC.invoiceit_s__Accounting_Code__c               = '01808';
        ordRPC.invoiceit_s__Quantity__c = 1;
        ordRPC.Name  = 'Test';
        ordRPClsit.add(ordRPC);
        
        invoiceit_s__Job_Rate_Plan_Charge__c  ordRPC1 = new invoiceit_s__Job_Rate_Plan_Charge__c ();
        ordRPC1.invoiceit_s__Price_Type__c = 'One Time'; 
        ordRPC1.invoiceit_s__Unit_Price__c = 100;
        ordRPC1.invoiceit_s__Job_Rate_Plan__c  = ordRP.id;
        ordRPC1.invoiceit_s__Product_Rate_Plan_Charge__c  = pRPC.id;
        ordRPC1.invoiceit_s__Order__c                   = ord.id;
        ordRPC1.invoiceit_s__Accounting_Code__c               = '01811';
        ordRPC1.invoiceit_s__Quantity__c = 1;
        ordRPC1.Name  = 'Test1';
         ordRPClsit.add(ordRPC1);
        insert ordRPClsit;
        
        /*************Creating child ord data here******************************************************/
        invoiceit_s__Job__c  childOrd = new invoiceit_s__Job__c(Name = 'TestchildOrd', invoiceit_s__Account__c  = acc.Id,                                                       
            RecordTypeId = devRecordTypeId ,
            invoiceit_s__Billing_Contact__c  = con.Id ,invoiceit_crmx__Opportunity__c =opp.id,
            invoiceit_s__CurrencyL__c  = singlecurrency.Id , invoiceit_s__Shipping_Contact__c  = con.Id,
            invoiceit_s__VAT__c = 0,invoiceit_s__Total__c = 123 ,Parent_Order__c = ord.id,
            invoiceit_s__Recalculate__c  = false , invoiceit_s__Number_Of_Terms__c  = 12 
        );
        
        insert childOrd;
        
         invoiceit_s__Job_Product__c ordProductc = new invoiceit_s__Job_Product__c();
        ordProductc.Name                            = 'Opp Product123';
        ordProductc.invoiceit_s__Product_Code__c = '60010'; 
        ordProductc.invoiceit_s__Product__c      = prod.id ;
        ordProductc.invoiceit_s__Job__c  = childord.Id;
        ordProductc.invoiceit_s__SequenceNumber__c = 1;
        ordProductc.Created_From_Order_Product__c  = ordProductlist[0].id;
        insert ordProductc;
        
        invoiceit_s__Job_Rate_Plan__c  ordRPchild = testData.getOrderRatePlan(ordProductc.id, prodRP.id);
                
         invoiceit_s__Job_Rate_Plan_Charge__c ordRPchargehild= new invoiceit_s__Job_Rate_Plan_Charge__c();
        ordRPchargehild.invoiceit_s__Price_Type__c = 'One Time'; 
        ordRPchargehild.invoiceit_s__Unit_Price__c = 100;
        ordRPchargehild.invoiceit_s__Job_Rate_Plan__c = ordRPchild.id;
        ordRPchargehild.invoiceit_s__Product_Rate_Plan_Charge__c = pRPC.id;
        ordRPchargehild.invoiceit_s__Order__c                  = childord.id;
        ordRPchargehild.invoiceit_s__Accounting_Code__c              = '60011';
        ordRPchargehild.invoiceit_s__Quantity__c =1;
        ordRPchargehild.Name  = 'Testchidl';
        ordRPchargehild.invoiceit_s__Status__c  = 'Active';
        insert ordRPchargehild;
        system.debug('@@@@@ordRPchargehild in test class'+ordRPchargehild);
        
        Chat_Product_Order_Charge__c  cpoc = new Chat_Product_Order_Charge__c ();
        cpoc.Chat_Usage_Order_Rate_Plan_Charge__c  = ordRPchargehild.id;
        cpoc.Chat_Product_Order_Rate_Plan_Charge__c  = ordRPClsit[0].id;
        insert cpoc;
        
        Opportunity childopp2 = new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,RecordTypeId = oppdevRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = singlecurrency.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
            invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
            invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , Ngage_Upsell_Order__c =Ord.id,
            invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
            invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
            invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
            invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
            Discount__c = 18,Promotional_Credit_Reason__c ='Credit Card',Promotional_Credit__c = 0,
            Promotional_Credit_Payment__c = true,Truncated_Order_Charges__c ='Test',Parent_Opportunity__c=opp.id
        );
        
        insert childopp2;
        
        //creating opportunity Product
        //List<invoiceit_crmx__Opportunity_Product__c> childoppProductlist = new List<invoiceit_crmx__Opportunity_Product__c>();
        invoiceit_crmx__Opportunity_Product__c childoppProduct = new invoiceit_crmx__Opportunity_Product__c();
        childoppProduct.Name                            = 'Opp Product';
        childoppProduct.invoiceit_crmx__Product_Code__c = '01808'; 
        childoppProduct.invoiceit_crmx__Product__c      = prod.id ;
        childoppProduct.invoiceit_crmx__Opportunity__c  = childopp2.Id;
        childoppProduct.invoiceit_crmx__SequenceNumber__c = 1;
        //oppProductlist.add(oppProduct);
        childoppProduct.Created_From_order_Product__c = ordProductc.id;
        insert childoppProduct;
        
        Test.startTest();
        
           ApexPages.currentPage().getParameters().put('orderid',ord.id);
           NgageChatController ctrl = new NgageChatController(new apexPages.StandardController(opp));
        
        for(NgageChatController.AttributesWrapper atwrap : ctrl.ChatProdListFinal){
            atwrap.ChatCheck = true;
        }
        
         string quotetype= 'modify';
        String orderId = childOrd.id;
        String Orderid1 = childOrd.id;
        
        //NgageChatController ngageChat = new NgageChatController(new ApexPages.StandardController(opp));
        //ngageChat.Oppid = opp.id;
        
        JobClass jobClass1 = Childorderdetails.populatechildJobClass(childOrd);
         
        createMidtermOptyFromChildOrder.jobClass = jobClass1;
        //createMidtermOptyFromChildOrder Crm = new createMidtermOptyFromChildOrder();
        createMidtermOptyFromChildOrder.optyId = opp.id;
         createMidtermOptyFromChildOrder.createchildoptyfromorder('Mid-Term', childOrd.id);
        
       // createMidtermOptyFromChildOrder.createchildoptyfromorder('Mid-Term', childOrd.id);
        ctrl.Save();
        ctrl.FkMethod();
        Test.stopTest();
            
         

        
        
        
    }
    

}