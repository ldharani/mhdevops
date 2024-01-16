@isTest(seeallData=true)

public class TestcreateMidtermOptyFromChildOrder{
     static testMethod void myUnitTest() {
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
         Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;
        
        Contact con = util.getContact(account.Id);
        
         list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '$');
        insert currencyObj;

        Opportunity opportunity1 = new Opportunity(Name = 'Acertis Cloud Test Oppty', AccountId = account.id, Amount = 123.50,                                                      
                CloseDate = system.today(), StageName = 'Needs Analysis'
                
        );
        insert opportunity1;
        
        invoiceit_s__Product__c product = new  invoiceit_s__Product__c(Name = 'Test Product',
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90,
                invoiceit_s__Product_Family__c = 'Default',
                invoiceit_s__Product_Code__c = 'Code1',
                invoiceit_s__Description__c = 'Product'
        );
        insert product;

        invoiceit_s__Product_Rate_Plan__c productRatePlan = new  invoiceit_s__Product_Rate_Plan__c(Name = 'Test ProductRatePlan',
                invoiceit_s__Product__c = product.Id,
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90
        );
        insert productRatePlan;

        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id,invoiceit_crmx__SequenceNumber__c =1,  invoiceit_crmx__Product_Code__c = '1234', invoiceit_crmx__Product__c   = product.id );
        insert oppProduct;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan',  invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;

       
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name = 'OptyRPC', invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Accounting_Code__c  = '01808', invoiceit_crmx__Opportunity__c = opportunity1.id, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;
            
        //creating orderCharge Attributes
        /*List<Opportunity_Charge_Attribute__c> optychargeattrib = new  List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes_noInsert(OppCharge.id, 'Picklist', 'AOP', 'Administrative Law');
        //aop.Product_Type__c                                    = 'Lawyers.com Preferred National Results';
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes_noInsert(OppCharge.id, 'Picklist', 'County', 'TestCounty');
        optychargeattrib.add(aop);
        optychargeattrib.add(county);
        insert optychargeattrib;
         */ 
         
         
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();       
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge1 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                invoiceit_s__CurrencyL__c = currencyObj.Id,
                invoiceit_s__Product_Rate_Plan__c = productRatePlan.Id,
                invoiceit_s__Unit_Price__c = 1000,
                invoiceit_s__Cost_Price__c = 500,                                                                  
                invoiceit_s__Price_Type__c = 'One Time',
                Renewable__c = true    
        );

        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge2 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                invoiceit_s__CurrencyL__c = currencyObj.Id,
                invoiceit_s__Product_Rate_Plan__c = productRatePlan.Id,
                invoiceit_s__Unit_Price__c = 1000,
                invoiceit_s__Cost_Price__c = 500,                                                                  
                invoiceit_s__Price_Type__c = 'Monthly',
                Renewable__c = true,
                Package_Wrapper__c = true                       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;
        
        //Opp Creation
        //product creation
        invoiceit_s__Product__c prod                                = util.getProduct('isInventorable');        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = util.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = util.getProductRatePlanCharge(currencyObj.Id, prodrateplan.id);       
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = account .Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,RecordTypeId = devRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = currencyObj.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
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
        //invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        //oppprod1.Name = 'Preferred National Links';
        //oppprod1.invoiceit_crmx__SequenceNumber__c = 1; 
        invoiceit_crmx__Opportunity_Product__c  oppprod1= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__SequenceNumber__c = 1, invoiceit_crmx__Opportunity__c = opp.Id);
        insert oppprod1;
        //update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        //invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
       /* invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name = 'Test Order';
        order.invoiceit_s__Account__c = account.Id;
        order.invoiceit_s__CurrencyL__c = currencyObj.id;
        order.invoiceit_s__Status__c = 'In Progress';
        order.invoiceit_crmx__Opportunity__c = opp.id;
        insert order;
        */
        Test.startTest();
         invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Billing_Contact__c = listContacts.get(0).Id, invoiceit_s__Shipping_Contact__c = listContacts.get(1).Id, invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0,invoiceit_crmx__Opportunity__c = opp.id, invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12, invoiceit_s__Service_End_Date__c = system.today() +1,invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge2.Id);
        insert charge;
        /*
         Order_Charge_Attribute__c orderChargeAttribute = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'Picklist',Attribute_Picklist_Values__c = 'Select' );
        //insert orderChargeAttribute;
        Order_Charge_Attribute__c orderChargeAttribute1 = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'String',Attribute_Picklist_Values__c = 'Select' );
        //insert orderChargeAttribute1;
        list<Order_Charge_Attribute__c> jobAttributes = new list<Order_Charge_Attribute__c>();
        jobAttributes.add(orderChargeAttribute);
        jobAttributes.add(orderChargeAttribute1);
        insert jobAttributes;
        */
        string quotetype= 'modify';
        String orderId = job.id;
        String Orderid1 = job.id;
        
        //NgageChatController ngageChat = new NgageChatController(new ApexPages.StandardController(opp));
        //ngageChat.Oppid = opp.id;
        
        JobClass jobClass1 = Childorderdetails.populatechildJobClass(job);
         
        createMidtermOptyFromChildOrder.jobClass = jobClass1;
        //createMidtermOptyFromChildOrder Crm = new createMidtermOptyFromChildOrder();
        createMidtermOptyFromChildOrder.optyId = opportunity1.id;
         createMidtermOptyFromChildOrder.createchildoptyfromorder('Mid-Term', job.id);
         //createMidtermOptyFromChildOrder.createchildoptyfromorder('Renew', Orderid1 );
        
        //crm.createchildoptyfromorder('Renew', orderId);
       /* oppProduct.Created_From_Opportunity_Product__c  = jobProduct.id;
        update oppProduct;
        
        oppProductRatePlan.Created_From_Order_Rate_Plan__c = jobRP.id;
        update oppProductRatePlan;
        
        OppCharge.Created_From_Charge__c = charge.id;
        update OppCharge;
        */
        
         Opportunity opportunity2 = new Opportunity(Name = 'Acertis Cloud Test Oppty', AccountId = account.id, Amount = 123.50,                                                      
                CloseDate = system.today(), StageName = 'Needs Analysis'
                
        );
        insert opportunity2;
        
        invoiceit_s__Product__c product1 = new  invoiceit_s__Product__c(Name = 'Test Product',
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90,
                invoiceit_s__Product_Family__c = 'Default',
                invoiceit_s__Product_Code__c = 'Code1',
                invoiceit_s__Description__c = 'Product'
        );
        insert product1;

        invoiceit_s__Product_Rate_Plan__c productRatePlan1 = new  invoiceit_s__Product_Rate_Plan__c(Name = 'Test ProductRatePlan',
                invoiceit_s__Product__c = product1.Id,
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90
        );
        insert productRatePlan1;

        invoiceit_crmx__Opportunity_Product__c  oppProduct1= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id,invoiceit_crmx__SequenceNumber__c =1,  invoiceit_crmx__Product_Code__c = '1234', invoiceit_crmx__Product__c   = product1.id, Created_From_Order_Product__c = jobProduct.id );
        insert oppProduct1;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan1 = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan',  invoiceit_crmx__Opportunity_Product__c = oppProduct1.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan1.Id, Created_From_Order_Rate_Plan__c = jobRP.id);
        insert oppProductRatePlan1;

       
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge1 = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name = 'OptyRPC', invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Accounting_Code__c  = '01808', invoiceit_crmx__Opportunity__c = opportunity2.id, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan1.id, Created_From_Charge__c = charge.id);          
        insert OppCharge1;
        
        List<invoiceit_crmx__Opportunity_Product__c> listOppProd = new List<invoiceit_crmx__Opportunity_Product__c>();
        listOppProd.add(oppProduct1);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> listOppRP = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        listOppRP.add(oppProductRatePlan1);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOppRPC = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        listOppRPC.add(OppCharge1);
        
        
        createMidtermOptyFromChildOrder.createoppPoductRateplans(listOppProd);
        createMidtermOptyFromChildOrder.createOpprateplancharges(listOppRP);
        
        createMidtermOptyFromChildOrder.insertoptychargeattributes(listOppRPC);
       
        
        Test.stopTest();
        
    
    }
    
      static testMethod void myUnitTest1() {
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
         Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;
        
        Contact con = util.getContact(account.Id);
        
         list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '$');
        insert currencyObj;

        Opportunity opportunity1 = new Opportunity(Name = 'Acertis Cloud Test Oppty', AccountId = account.id, Amount = 123.50,                                                      
                CloseDate = system.today(), StageName = 'Needs Analysis'
                
        );
        insert opportunity1;
        
        invoiceit_s__Product__c product = new  invoiceit_s__Product__c(Name = 'Test Product',
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90,
                invoiceit_s__Product_Family__c = 'Default',
                invoiceit_s__Product_Code__c = 'Code1',
                invoiceit_s__Description__c = 'Product'
        );
        insert product;

        invoiceit_s__Product_Rate_Plan__c productRatePlan = new  invoiceit_s__Product_Rate_Plan__c(Name = 'Test ProductRatePlan',
                invoiceit_s__Product__c = product.Id,
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90
        );
        insert productRatePlan;

        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id,invoiceit_crmx__SequenceNumber__c =1,  invoiceit_crmx__Product_Code__c = '1234', invoiceit_crmx__Product__c   = product.id );
        insert oppProduct;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan',  invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;

       
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name = 'OptyRPC', invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Accounting_Code__c  = '01808', invoiceit_crmx__Opportunity__c = opportunity1.id, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;
     
         
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();       
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge1 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                invoiceit_s__CurrencyL__c = currencyObj.Id,
                invoiceit_s__Product_Rate_Plan__c = productRatePlan.Id,
                invoiceit_s__Unit_Price__c = 1000,
                invoiceit_s__Cost_Price__c = 500,                                                                  
                invoiceit_s__Price_Type__c = 'One Time',
                Renewable__c = true    
        );

        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge2 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                invoiceit_s__CurrencyL__c = currencyObj.Id,
                invoiceit_s__Product_Rate_Plan__c = productRatePlan.Id,
                invoiceit_s__Unit_Price__c = 1000,
                invoiceit_s__Cost_Price__c = 500,                                                                  
                invoiceit_s__Price_Type__c = 'Monthly',
                Renewable__c = true,
                Package_Wrapper__c = true                       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;
        
        //Opp Creation
        //product creation
        invoiceit_s__Product__c prod                                = util.getProduct('isInventorable');        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = util.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = util.getProductRatePlanCharge(currencyObj.Id, prodrateplan.id);       
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-H Opportunity').getRecordTypeId();
        Opportunity opp = new Opportunity(Name = 'TestOpp', AccountId = account .Id, Amount = 123,                                                      
            CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,RecordTypeId = devRecordTypeId ,
            ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con.Id ,
            invoiceit_crmx__CurrencyL__c = currencyObj.Id , invoiceit_crmx__Shipping_Contact__c = con.Id,
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
       
        invoiceit_crmx__Opportunity_Product__c  oppprod1= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__SequenceNumber__c = 1, invoiceit_crmx__Opportunity__c = opp.Id);
        insert oppprod1;
        //update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
      
        Test.startTest();
         invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Billing_Contact__c = listContacts.get(0).Id, invoiceit_s__Shipping_Contact__c = listContacts.get(1).Id, invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0,invoiceit_crmx__Opportunity__c = opp.id, invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12, invoiceit_s__Service_End_Date__c = system.today() +1,invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge2.Id);
        insert charge;
       
        string quotetype= 'modify';
        String orderId = job.id;
        String Orderid1 = job.id;
        
        
        
        JobClass jobClass1 = Childorderdetails.populatechildJobClass(job);
         
        createMidtermOptyFromChildOrder.jobClass = jobClass1;
        //createMidtermOptyFromChildOrder Crm = new createMidtermOptyFromChildOrder();
        createMidtermOptyFromChildOrder.optyId = opportunity1.id;
         createMidtermOptyFromChildOrder.createchildoptyfromorder('Renew', job.id);
         //createMidtermOptyFromChildOrder.createchildoptyfromorder('Renew', Orderid1 );
     
        
         Opportunity opportunity2 = new Opportunity(Name = 'Acertis Cloud Test Oppty', AccountId = account.id, Amount = 123.50,                                                      
                CloseDate = system.today(), StageName = 'Needs Analysis'
                
        );
        insert opportunity2;
        
        invoiceit_s__Product__c product1 = new  invoiceit_s__Product__c(Name = 'Test Product',
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90,
                invoiceit_s__Product_Family__c = 'Default',
                invoiceit_s__Product_Code__c = 'Code1',
                invoiceit_s__Description__c = 'Product'
        );
        insert product1;

        invoiceit_s__Product_Rate_Plan__c productRatePlan1 = new  invoiceit_s__Product_Rate_Plan__c(Name = 'Test ProductRatePlan',
                invoiceit_s__Product__c = product1.Id,
                invoiceit_s__Valid_From_Date__c = Date.today(),
                invoiceit_s__Valid_To_Date__c = Date.today()+90
        );
        insert productRatePlan1;

        invoiceit_crmx__Opportunity_Product__c  oppProduct1= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id,invoiceit_crmx__SequenceNumber__c =1,  invoiceit_crmx__Product_Code__c = '1234', invoiceit_crmx__Product__c   = product1.id, Created_From_Order_Product__c = jobProduct.id );
        insert oppProduct1;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan1 = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan',  invoiceit_crmx__Opportunity_Product__c = oppProduct1.Id,
        invoiceit_crmx__Product_Rate_Plan__c = productRatePlan1.Id, Created_From_Order_Rate_Plan__c = jobRP.id,MidTerm__c=true);
        insert oppProductRatePlan1;

       
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge1 = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name = 'OptyRPC', invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Accounting_Code__c  = '01808', invoiceit_crmx__Opportunity__c = opportunity2.id, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan1.id, Created_From_Charge__c = charge.id);          
        insert OppCharge1;
        
        List<invoiceit_crmx__Opportunity_Product__c> listOppProd = new List<invoiceit_crmx__Opportunity_Product__c>();
        listOppProd.add(oppProduct1);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> listOppRP = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        listOppRP.add(oppProductRatePlan1);
        
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOppRPC = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        listOppRPC.add(OppCharge1);
        
        
        createMidtermOptyFromChildOrder.createoppPoductRateplans(listOppProd);
        createMidtermOptyFromChildOrder.createOpprateplancharges(listOppRP);
        
        createMidtermOptyFromChildOrder.insertoptychargeattributes(listOppRPC);
        createMidtermOptyFromChildOrder.oppProductsRelationship(listOppProd);
        
        Test.stopTest();
        
    
    }
}