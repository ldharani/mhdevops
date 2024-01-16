public with sharing class MDL_UtilClass_TestClass {
    public Profile p;
    public Profile p_admin;
    
    public MDL_UtilClass_TestClass(){
        p = [SELECT Id FROM Profile LIMIT 1];
        p_admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];  
        system.debug('@@@@ p_admin'+ p_admin);
    }
        
    public String randomise(){
        String append = '';
        Integer i = 6;
        while(i > 0){
            append += string.valueOf((Integer)Math.ceil(Math.random()*10));
            i--; 
        }
        return append;
    }
    
    public User getUser(){
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+randomise()+'@testorg.com');
         insert u2;
         
        return u2;     
    }
    
    
    public User getUser_admin(){
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p_admin.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+randomise()+'@testorg.com');
         insert u2;
         
        return u2;     
    }
    
    public Account getAccount(){
        Account a = new Account();
        a.Name = 'testAcc' + randomise(); 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        a.BillingState = 'NY';
        a.ShippingState = 'NY';
        a.ShippingPostalCode = '12356-2343'; a.BillingPostalCode = '12356-2343';
        a.ShippingLongitude = 12;a.BillingLongitude = 12;
        a.ShippingLatitude = 10 ;a.BillingLatitude = 10;
        a.ShippingCountry = 'USA';a.BillingCountry = 'USA';
        a.ShippingCity = 'California';a.BillingCity = 'California';
        a.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        a.Organization_Type__c = 'Corporation';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
        User u = getUser();
        a.Collector__c = u.Id;
        insert a;
        
        return a;       
    }
    
    
     public Account getAccount_withoutInsert(){
        Account a = new Account();
        a.Name = 'testAcc' + randomise(); 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        a.BillingState = 'NY';
        a.ShippingState = 'NY';
        a.ShippingPostalCode = '12356-2343'; a.BillingPostalCode = '12356-2343';
        a.ShippingLongitude = 12;a.BillingLongitude = 12;
        a.ShippingLatitude = 10 ;a.BillingLatitude = 10;
        a.ShippingCountry = 'USA';a.BillingCountry = 'USA';
        a.ShippingCity = 'California';a.BillingCity = 'California';
        a.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        a.Organization_Type__c = 'Corporation';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
       
        
        return a;       
    }
    
    
     public Account getAccount_adminuser(){
        Account a = new Account();
        a.Name = 'testAcc' + randomise(); 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        a.BillingState = 'NY';
        a.ShippingState = 'NY';
        a.ShippingPostalCode = '12356-2343'; a.BillingPostalCode = '12356-2343';
        a.ShippingLongitude = 12;a.BillingLongitude = 12;
        a.ShippingLatitude = 10 ;a.BillingLatitude = 10;
        a.ShippingCountry = 'USA';a.BillingCountry = 'USA';
        a.ShippingCity = 'California';a.BillingCity = 'California';
        a.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        a.Organization_Type__c = 'Corporation';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
        User u = getUser_admin();
        //a.OwnerId = u.id;
        system.debug('@@@@profileid in util'+ u.ProfileId);
        a.Collector__c = u.Id;
        insert a;
        
        return a;       
    }
    
    
    
    
    public Contact getContact(Id accId){
        Contact c = new Contact();
        c.LastName = 'Test Contact' + randomise();
        c.Email = 'testabc@gmail.com';
        c.AccountId = accId;
        insert c;
        
        return c;
    }
    
    public invoiceit_s__Currency__c getCurrencyObject(){
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '$');
        insert currencyObj;
        
        return currencyObj;
    }
    
    
    
    public invoiceit_s__Product__c getProduct(String isInventorable){
        invoiceit_s__Product__c product = new  invoiceit_s__Product__c(Name = 'Test Product' + randomise(),
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90,
                invoiceit_s__Product_Family__c = 'Default',
                invoiceit_s__Product_Code__c = '1234',
                invoiceit_s__Description__c = 'Product',
                IsInventoried__c = isInventorable
        );
        insert product;
        
        return product; 
    }
    
    public invoiceit_s__Product__c getProductWithProvisioning(String isInventorable,String provisioning){
        invoiceit_s__Product__c product = new  invoiceit_s__Product__c(Name = 'Test Product' + randomise(),
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90,
                invoiceit_s__Product_Family__c = 'Default',
                invoiceit_s__Product_Code__c = '1234',
                invoiceit_s__Description__c = 'Product',
                IsInventoried__c = isInventorable,
                Product_Provisioning__c = provisioning
        );
        insert product;
        
        return product; 
    }
    
    public invoiceit_s__Product_Rate_Plan__c getProductRatePlan(Id productId){      
        invoiceit_s__Product_Rate_Plan__c productRatePlan = new  invoiceit_s__Product_Rate_Plan__c(Name = 'Test ProductRatePlan' + randomise(),
                invoiceit_s__Product__c = productId,
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90
        );
        insert productRatePlan;
        
        return productRatePlan;
    }
    
    
    
    public invoiceit_s__Product_Rate_Plan_Charge__c getProductRatePlanCharge(Id CurrencyId , Id productRatePlanId){         
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge2 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges' + randomise(),
                invoiceit_s__CurrencyL__c = CurrencyId,
                invoiceit_s__Product_Rate_Plan__c = productRatePlanId,
                invoiceit_s__Unit_Price__c = 1000,
                invoiceit_s__Cost_Price__c = 500,                                                                  
                invoiceit_s__Price_Type__c = 'Monthly'
        );
        
        return productRatePlanCharge2;
    }
    
    
    public Opportunity getOpportunity(Id accId , Id conId , Id currencyId ){        
        Opportunity opportunity1 = new Opportunity(Name = 'TestOpp', AccountId = accId, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = conId ,
                invoiceit_crmx__CurrencyL__c = currencyId , invoiceit_crmx__Shipping_Contact__c = conId,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 20 , Type = 'New Business',
                Discount__c = 18 
        );
        insert opportunity1;
        
        return opportunity1;
    } 
    
     public Opportunity getOpportunitywithoutInsert(Id accId , Id conId , Id currencyId ){        
        Opportunity opportunity1 = new Opportunity(Name = 'TestOpp', AccountId = accId, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = conId ,
                invoiceit_crmx__CurrencyL__c = currencyId , invoiceit_crmx__Shipping_Contact__c = conId,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 20 , Type = 'New Business',
                Discount__c = 18 
        );
        
        
        return opportunity1;
    } 
    
    
    public invoiceit_crmx__Opportunity_Product__c getOpportunityProduct(Id ProductId, Id oppId){                
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product',invoiceit_crmx__Product_Code__c = '1234', invoiceit_crmx__SequenceNumber__c =1, invoiceit_crmx__Product__c = ProductId ,invoiceit_crmx__Opportunity__c = oppId);
        insert oppProduct;
        
        return oppProduct;
    }
    
    public invoiceit_crmx__Opportunity_Product__c getOpportunityProductWithoutInsert(Id ProductId, Id oppId){                
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product',invoiceit_crmx__Product_Code__c = '1234', invoiceit_crmx__SequenceNumber__c =1, invoiceit_crmx__Product__c = ProductId ,invoiceit_crmx__Opportunity__c = oppId);
       
        
        return oppProduct;
    }
    
    public invoiceit_crmx__Opportunity_Rate_Plan__c getOpportunityRatePlan(Id oppProdId , Id ProductId){
        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', 
                                                                                                    invoiceit_crmx__Opportunity_Product__c = oppProdId , 
                                                                                                    invoiceit_crmx__Product_Rate_Plan__c = ProductId);
        insert oppProductRatePlan;
        
        return oppProductRatePlan;
    }
    
    
    
    public invoiceit_crmx__Opportunity_Rate_Plan_Charge__c getOppRatePlanCharge(Id OppProductRatePlanId , Id ProductratePlanChargeId){
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name='Test_OppRPC',invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = OppProductRatePlanId , invoiceit_crmx__Product_Rate_Plan_Charge__c = ProductratePlanChargeId);          
        insert OppCharge;
        
        return OppCharge;
    }
    
    public Opportunity_Charge_Attribute__c getOppCharges(Id OppRPCId,String attType,String attName) {
        Opportunity_Charge_Attribute__c oppCharge;
        if(attType == 'Text') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,String_Value__c='ABC');
        }
        else if(attType == 'Number') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,Number_Value__c=123);
        }
        else if(attType == 'Picklist') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,Attribute_Picklist_Values__c='Criminal Law,Civil Law,Consumer Law',Picklist_Value__c='Civil Law');
        }
        else if(attType == 'Date') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,Date_Value__c= Date.today());
        }
        else if(attType == 'Boolean') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,Boolean_Value__c= true);
        }
        else if(attType == 'phone'){
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName, Phone_Value__c = '1234567890');
        
        }
        insert oppCharge;
        
        return oppCharge;
    }
    
    public Opportunity_Charge_Attribute__c getOppChargeswithoutInsert(Id OppRPCId,String attType,String attName) {
        Opportunity_Charge_Attribute__c oppCharge;
        if(attType == 'Text') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,String_Value__c='ABC');
        }
        else if(attType == 'Number') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,Number_Value__c=123);
        }
        else if(attType == 'Picklist') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,Attribute_Picklist_Values__c='Criminal Law,Civil Law,Consumer Law',Picklist_Value__c='Civil Law');
        }
        else if(attType == 'Date') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,Date_Value__c= Date.today());
        }
        else if(attType == 'Boolean') {
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName,Boolean_Value__c= true);
        }
        else if(attType == 'phone'){
            oppCharge = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName, Phone_Value__c = '1234567890');
        
        }
        //insert oppCharge;
        
        return oppCharge;
    }
    
    
    public invoiceit_s__Job__c getOrder(Id accId , Id CurrencyId){
        invoiceit_s__Job__c job = new invoiceit_s__Job__c();
        job.Name = 'Test Order' + randomise();
        job.invoiceit_s__Account__c = accId;
        job.invoiceit_s__CurrencyL__c = CurrencyId;
        job.invoiceit_s__Status__c = 'In Progress';
        
        insert job;
        
        return job;
    }
    
    
    public invoiceit_s__Job_Product__c getOrderProduct(Id orderId , Id productId){
        invoiceit_s__Job_Product__c jobProd = new   invoiceit_s__Job_Product__c();
        jobProd.Name = 'Test Order Product ' + randomise();
        jobProd.invoiceit_s__Job__c = orderId ;
        jobProd.invoiceit_s__Product__c = productId;
        jobProd.invoiceit_s__Product_Code__c = '1234';
        insert jobProd;
        
        return jobProd;
    }
    
    public invoiceit_s__Job_Rate_Plan__c getOrderRatePlan(Id OrderProductId , Id productRatePlanId){
        invoiceit_s__Job_Rate_Plan__c jobRatePlan = new invoiceit_s__Job_Rate_Plan__c();
        jobRatePlan.Name = 'Test Rate Plan' + randomise();
        jobRatePlan.invoiceit_s__Product_Rate_Plan__c = productRatePlanId;  
        jobRatePlan.invoiceit_s__Job_Product__c = OrderProductId;
        insert jobRatePlan;
        
        return jobRatePlan; 
    }
    
    public invoiceit_s__Job_Rate_Plan_Charge__c getOrderRatePlanCharge(Id OrderRatePlanId , Id ProductRPCId){
        invoiceit_s__Job_Rate_Plan_Charge__c jobRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
        jobRPC.Name = 'Test RPC ' + randomise();
        jobRPC.invoiceit_s__Job_Rate_Plan__c = OrderRatePlanId;
        jobRPC.invoiceit_s__Product_Rate_Plan_Charge__c = ProductRPCId  ;
        jobRPC.invoiceit_s__Quantity__c = 1;
        jobRPC.invoiceit_s__Status__c = 'In Progress';
        insert jobRPC;
        
        return jobRPC;
    }
    
    public invoiceit_s__Job_Rate_Plan_Charge__c getOrderRatePlanChargeWithoutInsert(Id OrderRatePlanId , Id ProductRPCId){
        invoiceit_s__Job_Rate_Plan_Charge__c jobRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
        jobRPC.Name = 'Test RPC ' + randomise();
        jobRPC.invoiceit_s__Job_Rate_Plan__c = OrderRatePlanId;
        jobRPC.invoiceit_s__Product_Rate_Plan_Charge__c = ProductRPCId  ;
        jobRPC.invoiceit_s__Quantity__c = 1;
        //insert jobRPC;
        
        return jobRPC;
    }
    
    public Order_Charge_Attribute__c getOrderCharges(Id OrderRPCId , String attType , String attName) {
        Order_Charge_Attribute__c oChargeAtt;
        if(attType == 'Text') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , String_Value__c = 'Test123');
        }
        else if(attType == 'Picklist') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Picklist_Value__c = 'ABC');
        }
        else if(attType == 'Number') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Number_Value__c = 123);
        }
        else if(attType == 'Date') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Date_Value__c = Date.today());
        }
        else if(attType == 'Boolean') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Boolean_Value__c = true);
        }
         else if(attType == 'phone'){
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName, Phone_Value__c = '1234567890');
        
        }
        insert oChargeAtt;
        
        return oChargeAtt;
    }
    
     public Order_Charge_Attribute__c getOrderChargeswithoutInsert(Id OrderRPCId , String attType , String attName) {
        Order_Charge_Attribute__c oChargeAtt;
        if(attType == 'Text') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , String_Value__c = 'Test123');
        }
        else if(attType == 'Picklist') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Picklist_Value__c = 'ABC');
        }
        else if(attType == 'Number') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Number_Value__c = 123);
        }
        else if(attType == 'Date') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Date_Value__c = Date.today());
        }
        else if(attType == 'Boolean') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Boolean_Value__c = true);
        }
         else if(attType == 'phone'){
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c=attName, Phone_Value__c = '1234567890');
        
        }
        //insert oChargeAtt;
        
        return oChargeAtt;
    }
    
     public Order_Charge_Attribute__c getOrderChargeAttributes(Id OrderRPCId , String attType , String attName, string value) {
        Order_Charge_Attribute__c oChargeAtt;
        if(attType == 'Text') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , String_Value__c = value);
        }
        else if(attType == 'Picklist') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Picklist_Value__c = value);
        }
       
        insert oChargeAtt;
        
        return oChargeAtt;
    }
    
    
    
     public Order_Charge_Attribute__c getOrderChargeAttributes_noInsert(Id OrderRPCId , String attType , String attName, string value) {
        Order_Charge_Attribute__c oChargeAtt;
        if(attType == 'Text') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , String_Value__c = value);
        }
        else if(attType == 'Picklist') {
            oChargeAtt = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = OrderRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Picklist_Value__c = value);
        }
       
        //insert oChargeAtt;
        
        return oChargeAtt;
    }
    
    
    
    
    
     public Opportunity_Charge_Attribute__c getOpportunityChargeAttributes(Id OpptyRPCId , String attType , String attName, string value) {
        Opportunity_Charge_Attribute__c oChargeAtt;
        if(attType == 'Text') {
            oChargeAtt = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OpptyRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , String_Value__c = value);
        }
        else if(attType == 'Picklist') {
            oChargeAtt = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OpptyRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Picklist_Value__c = value);
        }
       
        insert oChargeAtt;
        
        return oChargeAtt;
    }
    
    
     public Opportunity_Charge_Attribute__c getOpportunityChargeAttributes_noInsert(Id OpptyRPCId , String attType , String attName, string value) {
        Opportunity_Charge_Attribute__c oChargeAtt;
        if(attType == 'Text') {
            oChargeAtt = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OpptyRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , String_Value__c = value);
        }
        else if(attType == 'Picklist') {
            oChargeAtt = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OpptyRPCId, Attribute_Type__c = attType, Attribute_Name__c = attName , Picklist_Value__c = value);
        }
       
       
        return oChargeAtt;
    }
    
    public invoiceit_s__Invoice__c getInvoice(Id accId){
        invoiceit_s__Invoice__c invoice = new invoiceit_s__Invoice__c();
        invoice.invoiceit_s__Account__c = accId;    
        invoice.invoiceit_s__Due_Date__c = date.Today().addDays(-90);
        invoice.invoiceit_s__Invoice_Date__c = date.Today().addDays(-10);
        insert invoice;
        
        return invoice;
    }
    
    public invoiceit_s__Payment__c getPayment(Id accId,Id curId) {
        invoiceit_s__Payment__c pay = new invoiceit_s__Payment__c();
        pay.invoiceit_s__Account__c = accId;
        pay.invoiceit_s__Currency__c = curId;
        pay.invoiceit_s__Amount__c = 200.00;
        pay.invoiceit_s__Payment_Date__c = Date.today();
        pay.invoiceit_s__Payment_Type__c = 'ACH';
        pay.invoiceit_s__Status__c = 'Completed';
        
        insert pay;
        
        return pay;
    }
    
    public invoiceit_s__Payment_Allocation__c getPaymentAlloc(Id payId,Id invId) {
        invoiceit_s__Payment_Allocation__c payAlloc = new invoiceit_s__Payment_Allocation__c();
        payAlloc.invoiceit_s__Amount__c = 31.00;
        payAlloc.invoiceit_s__Status__c = 'Completed';
        payAlloc.invoiceit_s__Payment__c = payId;
        payAlloc.invoiceit_s__Invoice__c = invId;
        payAlloc.Unallocated_Amount__c = 54.00;
        payAlloc.RecordTypeId = Schema.SObjectType.invoiceit_s__Payment_Allocation__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_JV_Payment_Allocation).getRecordTypeId();
        insert payAlloc;
        return payAlloc;
    }
    
    public invoiceit_s__Invoice_Lines__c getInvoiceLines(Id inv,Id orderId) {
        invoiceit_s__Invoice_Lines__c invLines = new invoiceit_s__Invoice_Lines__c();
        invLines.invoiceit_s__Invoice__c = inv;
        invLines.invoiceit_s__Job__c = orderId;
        invLines.invoiceit_s__Unit_Price__c = 100.00;
        invLines.invoiceit_s__Line_Amount__c = 100.00;
        insert invLines;
        
        return invLines;
    }
    
    public invoiceit_s__Quote__c getQuote(Id accId,Id oppId,Id conId,Id curId) {
        invoiceit_s__Quote__c quoteObj = new invoiceit_s__Quote__c();
        quoteObj.Name = 'TestQuote';
        quoteObj.invoiceit_crmx__Opportunity__c = oppId;
        quoteObj.invoiceit_s__Account__c = accId;
        quoteObj.invoiceit_s__Billing_Contact__c = conId;
        quoteObj.invoiceit_s__Shipping_Contact__c = conId;
        quoteObj.invoiceit_s__CurrencyL__c = curId;
        insert quoteObj;
        
        return quoteObj;
    }
    public invoiceit_s__Payment_Method__c getPaymentMethod(Id accId){
        invoiceit_s__Payment_Method__c p = new invoiceit_s__Payment_Method__c();
        p.invoiceit_s__Account__c=accId;
        p.invoiceit_s__Default__c=true;
        p.invoiceit_s__Name_on_Card__c='Murali';
        p.Rank__c='1';
        p.invoiceit_s__Card_Number__c = string.valueOf(1234567890);
        p.invoiceit_s__CVV__c = string.valueOf(1234);
        p.invoiceit_s__Bank_Account_Number__c = string.valueOf(1234567890);
        p.invoiceit_s__Billing_City__c    = 'alaska';
        p.invoiceit_s__Billing_Country__c = 'atlanta';
        p.invoiceit_s__Billing_State_Province__c = 'mexico';
        insert p;
        return p;       
    }
    
    
    public invoiceit_s__Payment_Method__c getPaymentMethodActive(Id accId){
        invoiceit_s__Payment_Method__c p = new invoiceit_s__Payment_Method__c();
        p.invoiceit_s__Account__c=accId;
        //p.invoiceit_s__Default__c=true;
        p.invoiceit_s__Name_on_Card__c='Murali1';
        //p.Rank__c='1';
        p.invoiceit_s__Card_Number__c = string.valueOf(1234567890);
        p.invoiceit_s__CVV__c = string.valueOf(1234);
        p.invoiceit_s__Bank_Account_Number__c = string.valueOf(1234567890);
        p.invoiceit_s__Billing_City__c    = 'alaska';
        p.invoiceit_s__Billing_Country__c = 'atlanta';
        p.invoiceit_s__Billing_State_Province__c = 'mexico';
        insert p;
        return p;       
    }
    public invoiceit_s__Transaction__c getTransactionObj(Id payMethId,Id invId,Id currencyId,Id PaymentGatewayId){
        invoiceit_s__Transaction__c t = new invoiceit_s__Transaction__c();
        t.invoiceit_s__Payment_Method__c = payMethId;
        t.invoiceit_s__Currency__c = currencyId;
        t.invoiceit_s__Payment_Gateway__c = PaymentGatewayId;
        t.invoiceit_s__Request_Invoice__c = invId;
        //t.invoiceit_s__Is_Payment_Processed_Successfully__c = true;
        insert t;
        return t;
    }
    public invoiceit_s__Gateway__c getGateway(){
        invoiceit_s__Gateway__c g = new invoiceit_s__Gateway__c();
        g.Name = 'Autorize.net Sample';
        g.invoiceit_s__Merchant_ID__c = '123456789';
        g.invoiceit_s__Security_Key__c = '987654321';
        g.invoiceit_s__Gateway_Type__c = 'Authorize.net';
        g.invoiceit_s__Test_Mode__c = true;
        //g.invoiceit_s__Default__c = true;
        g.invoiceit_s__Active__c = true;
        insert g;
        return g;
    }
    
    public List<account> creatingbulkAccounts(Integer size){
        
        List<account> acclist = new List<account>();
        for(Integer i=0; i<= size; i++){
            Account a = new Account();
            a.Name = 'testAcc' + i; 
            a.Phone='122-34345-654';
            a.invoiceit_s__Preferred_Billing_Day__c = '1';
            a.Type = 'Customer';
            a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
            a.ShippingStreet = '111 Train Ave';
            a.BillingStreet = '111 Train Ave';
            a.BillingState = 'NY';
            a.ShippingState = 'NY';
            a.ShippingPostalCode = '12356-2343'; a.BillingPostalCode = '12356-2343';
            a.ShippingLongitude = 12;a.BillingLongitude = 12;
            a.ShippingLatitude = 10 ;a.BillingLatitude = 10;
            a.ShippingCountry = 'USA';a.BillingCountry = 'USA';
            a.ShippingCity = 'California';a.BillingCity = 'California';
            a.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
            a.Organization_Type__c = 'Corporation';
            a.Firm_Email__c = 'sbender@brirllp.com';
            a.Evergreen_Contract_Status__c = 'NA';
            //User u = getUser_admin();
            //a.OwnerId = u.id;
            //system.debug('@@@@profileid in util'+ u.ProfileId);
            //a.Collector__c = u.Id;
            acclist.add(a);
        }
        
        return acclist;
        
    }
    
    
    public list<invoiceit_s__Job__c> creatingbulkOrders(List<account> acclist, id currencyObjId){
        list<invoiceit_s__Job__c> orders = new list<invoiceit_s__Job__c>();
        
        integer i = 0;
        for(account acc : acclist){
             
             invoiceit_s__Job__c job = new invoiceit_s__Job__c();
            job.Name = 'Test Order' + i;
            job.invoiceit_s__Account__c = acc.Id;
            job.invoiceit_s__CurrencyL__c = currencyObjId;
            job.invoiceit_s__Status__c = 'In Progress';
            orders.add(job);
            i++;
        }
        return orders;
    }
    
    
    public list<invoiceit_s__Invoice__c> creatingbulkinvoices(List<account> acclist){
        list<invoiceit_s__Invoice__c> invoices = new list<invoiceit_s__Invoice__c>();
        
        integer i = acclist.size()/3;
        integer j = 0;
        
       
        
        for(account acc: acclist){
            invoiceit_s__Invoice__c inv         =  new invoiceit_s__Invoice__c();
            inv.invoiceit_s__Account__c         = acc.id;
            inv.RecordTypeId                    = Schema.SObjectType.invoiceit_s__Invoice__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_JV_Invoice).getRecordTypeId();
            inv.invoiceit_s__Due_Date__c        = date.Today().addDays(-90);
            inv.invoiceit_s__Invoice_Date__c    = date.Today().addDays(-10);
            inv.invoiceit_s__Invoice_Status__c  = 'Posted';
            invoices.add(inv);
        }
        
        return invoices;
        
        
    }
    
    
    public GEO_Location__c getGeolocation(string country,string state,string county, string city){
        GEO_Location__c geo = new GEO_Location__c(CountryName__c = country, State_Abbrevation__c = state,
                                                  County_Name__c = county, City_Name__c = city,
                                                  CountryID__c ='1', StateID__c='2',
                                                  County_ID__c = '3', City_ID__c='4');
        insert geo;
        return geo;
        
        
    }
    
     public GEO_Location__c getGeolocationWithoutInsert(string country,string state,string county, string city){
        GEO_Location__c geo = new GEO_Location__c(CountryName__c = country, State_Abbrevation__c = state,
                                                  County_Name__c = county, City_Name__c = city,
                                                  CountryID__c ='1', StateID__c='2',
                                                  County_ID__c = '3', City_ID__c='4');
       
        return geo;
        
        
    }
    public Chat_Product_Order_Charge__c createChatProduct(Id chatorpcId, Id chatusageorpcId){
        Chat_Product_Order_Charge__c  chatorpc = new Chat_Product_Order_Charge__c(Chat_Product_Order_Rate_Plan_Charge__c = chatorpcId,
                                                                                   Chat_Usage_Order_Rate_Plan_Charge__c = chatusageorpcId);
        return chatorpc;
    }
    
    public task createTask(Id relatedToId, Id rectypeId){
        task tsk = new task();
        tsk.Subject  = 'Email';
        tsk.RecordTypeId = rectypeId;
        tsk.OwnerId    = UserInfo.getUserId();
        tsk.Status='In Progress';
        tsk.WhatId  = relatedToId;
        return tsk;
        
        
    }
    
    public Lead Createlead(id conid ){
            lead l = new lead();
            l.email = 'random@gmail.com';
            l.LastName             ='random';
            l.Status               = 'Open';
            l.LeadSource           = 'Contact';
            l.Company              = 'test';
            l.Contact__c           = conid ; // company name TODO
          return l;
    }
   
    public Event createEvent(Id relatedId){
        Event ev = new Event();
        ev.Subject  = 'Test';
        ev.StartDateTime  = System.now();
        ev.EndDateTime    = system.now() + 10;
        ev.WhatId  = relatedId;
        return ev;
         
    }
    
    //single product Bundle creation method
    public static invoiceit_s__Product_Bundle__c createProductBundle(string bundlecode, string currencyId){
        invoiceit_s__Product_Bundle__c prdbundle = new invoiceit_s__Product_Bundle__c();
        prdbundle.Name   = 'Test Package';
        prdbundle.invoiceit_s__Product_Bundle_Code__c = '05000';
        prdbundle.invoiceit_s__Bundle_Type__c = 'Line';
        prdbundle.invoiceit_s__Start_Date__c  = date.today();
        prdbundle.invoiceit_s__Currency__c   = currencyId;
        return prdbundle;
        
        
    }
    
    
    //single product bundle plan creation
    public static invoiceit_s__Product_Bundle_Line__c createproductbundleline(string producbundleId){
        invoiceit_s__Product_Bundle_Line__c prodbundleline = new invoiceit_s__Product_Bundle_Line__c();
        prodbundleline.invoiceit_s__Product_Bundle__c  = producbundleId;
        
        return prodbundleline;
        
        
    }
    
}