@isTest(seeAllData = true)
public class UpdatNgagePriceTest {
  
    
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
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c > chargelist = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c >();
        
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
        
        Opportunity childopp= new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
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
        
          //product creation
        invoiceit_s__Product__c prod                                = testData.getProduct('isInventorable');        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = testData.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = testData.getProductRatePlanCharge(singlecurrency.Id, prodrateplan.id); 
        prodRatePlanCharge.Package_Wrapper__c = false;
        insert prodRatePlanCharge;
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = testData.getOpportunityProduct(prod.Id,childopp.Id);
        oppprod1.Name = 'Ngage Live Chat';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = testData.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = testData.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
         opprpc.invoiceit_crmx__Accounting_Code__c              = '60011';
         opprpc.invoiceit_crmx__Unit_Price__c  = 50.00;
         opprpc.invoiceit_crmx__Net_Total__c =  opprpc.invoiceit_crmx__Unit_Price__c ;
         opprpc.invoiceit_crmx__Opportunity__c                  = childopp.id;
         //chargelist.add(opprpc); 
         update opprpc;
        
        
        Test.startTest();
        
           ApexPages.currentPage().getParameters().put('id',childopp.id);
           ApexPages.StandardController stdobj1 =new ApexPages.StandardController(childopp);
           UpdatNgagePrice ctrl = new UpdatNgagePrice (stdobj1);
           //UpdatNgagePrice ctrl = new UpdatNgagePrice(new apexPages.StandardController(childopp));
           ctrl.Save();
           
        Test.stopTest();
        
        }
        
         //to cover parent opportunity 
    static testmethod void run2condition3(){
          MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        //creating account
        account accParent = testData.getAccount();
        account acc = testData.getAccount();
        acc.parentId = accParent.id;
        update acc;
        //creating currency
        invoiceit_s__Currency__c singlecurrency = testData.getCurrencyObject();
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c > chargelist = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c >();
         
        //creating contact
        contact con = testData.getContact(acc.Id);
         Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();
        //creating opportunity
        System.debug('devRecordTypeId ---->'+devRecordTypeId );
        
      
        Opportunity childopp= new Opportunity(Name = 'TestOpp', AccountId = acc.Id, Amount = 123,                                                      
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
            //Parent_Opportunity__c=opp.id
        );
       
       
        insert childopp;
        
          //product creation
        invoiceit_s__Product__c prod                                = testData.getProduct('isInventorable');        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = testData.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = testData.getProductRatePlanCharge(singlecurrency.Id, prodrateplan.id); 
        prodRatePlanCharge.Package_Wrapper__c = false;
        insert prodRatePlanCharge;
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = testData.getOpportunityProduct(prod.Id,childopp.Id);
        oppprod1.Name = 'Preferred city results';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = testData.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = testData.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
         opprpc.invoiceit_crmx__Accounting_Code__c              = '34332';
         opprpc.invoiceit_crmx__Unit_Price__c  = null;
         //opprpc.invoiceit_crmx__Net_Total__c =  opprpc.invoiceit_crmx__Unit_Price__c ;
         opprpc.invoiceit_crmx__Opportunity__c                  = childopp.id;
         //chargelist.add(opprpc);
         
         update opprpc;
        
        Test.startTest();
        
           ApexPages.currentPage().getParameters().put('id',childopp.id);
           ApexPages.StandardController stdobj1 =new ApexPages.StandardController(childopp);
           UpdatNgagePrice ctrl = new UpdatNgagePrice (stdobj1);
           //UpdatNgagePrice ctrl = new UpdatNgagePrice(new apexPages.StandardController(childopp));
           ctrl.Save();
        Test.stopTest();
        
        }
   }