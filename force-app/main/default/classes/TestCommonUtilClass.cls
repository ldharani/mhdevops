/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeallData=true)
private class TestCommonUtilClass {
    
    static testMethod void myUnitTest2() {
        CommonUtilClass.getObjectSelectQuery('Account');
        List<Id> ids = new List<Id>();
        ids.add('01pc0000000EBK8');
        CommonUtilClass.convertListOfIdsIntoString(ids);
        CommonUtilClass commonUtilClassObj = new CommonUtilClass();

        JobRatePlanChargeClass jobRatePlanChargeClass = new JobRatePlanChargeClass();
        jobRatePlanChargeClass.getorderChargeAttributes();
        
    }
    static testMethod void myUnitTest() {

        Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;

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

        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id);
        insert oppProduct;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;

       
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;
            
         List<Opportunity_Charge_Attribute__c> attributes = new List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c accessRight1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Picklist', Attribute_Name__c='Law',Attribute_Picklist_Values__c='Criminal Law,Civil Law,Consumer Law',Picklist_Value__c='Civil Law');
        //insert accessRight1;
        
        Opportunity_Charge_Attribute__c accessRight2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Text', Attribute_Name__c='State',String_Value__c='ABC');
        //insert accessRight2;
        attributes.add(accessRight1);
        attributes.add(accessRight2);
        insert attributes;

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

        OpportunityCreationUtil.getOpportunity(opportunity1.Id);
        list<invoiceit_crmx__Opportunity_Product__c> listofOppProducts = OpportunityCreationUtil.getListOpportunityProducts(opportunity1.Id);
        Map<Id,OpportunityProductClass> map_Id_OpportunityProductClass = OpportunityCreationUtil.getMapOpptProducts(listofOppProducts);
        OpportunityCreationUtil.queryattributesBasedOpptId(opportunity1.Id);
        list<Id> OpptProductIds = new list<Id>();
        OpptProductIds.add(oppProduct.Id);
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpptProductIds.clear();
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpportunityCreationUtil OpportunityCreationUtilObj = new OpportunityCreationUtil();
        
        OpportunityRatePlanChargeClass  opportunityRatePlanChargeClassObj = new OpportunityRatePlanChargeClass();
        opportunityRatePlanChargeClassObj.getopptChargeAttributes();
        
        list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
        System.debug('Prining all information-->'+account.id+'contact--'+listContacts.get(0).Id+'=='+listContacts.get(1).Id+'currencyObj-->'+currencyObj.id);
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Billing_Contact__c = listContacts.get(0).Id, invoiceit_s__Shipping_Contact__c = listContacts.get(1).Id, invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0, invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'Monthly',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12, invoiceit_s__Service_End_Date__c = system.today() +1,invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge2.Id);
        insert charge;
        
        JobCreationUtil.getJob(job.Id);
        JobCreationUtil.getListJobProducts(job.Id);
        list<invoiceit_s__Job_Product__c> listofJobProduct = new list<invoiceit_s__Job_Product__c>();
        listofJobProduct.add(jobProduct);
        JobCreationUtil.getMapJobProducts(listofJobProduct);
        list<Id> jobProductIds = new list<Id>();
        jobProductIds.add(jobProduct.Id);
        JobCreationUtil.getListJobRatePlans(jobProductIds);
        Order_Charge_Attribute__c orderChargeAttribute = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'Picklist',Attribute_Picklist_Values__c = 'Select' );
        //insert orderChargeAttribute;
        Order_Charge_Attribute__c orderChargeAttribute1 = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'String',Attribute_Picklist_Values__c = 'Select' );
        //insert orderChargeAttribute1;
        list<Order_Charge_Attribute__c> jobAttributes = new list<Order_Charge_Attribute__c>();
        jobAttributes.add(orderChargeAttribute);
        jobAttributes.add(orderChargeAttribute1);
        insert jobAttributes;
        JobCreationUtil.queryattributesBasedJobId(job.Id);
        Test.starttest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(job);
        inLineProductPageController inLineProductPageController = new inLineProductPageController(stdController);
        
        ApexPages.StandardController stdControllerOpp = new ApexPages.StandardController(opportunity1);
        inLineProductPageForOpportunityCls inLineProductPageForOpportunityClsObj = new inLineProductPageForOpportunityCls(stdControllerOpp);
        
        
        ApexPages.StandardController stdControllerOrder = new ApexPages.StandardController(job);
        system.currentPageReference().getParameters().put('id', ''+job.Id);
        AddingOrderChargeAttributeExtension addingOrderChargeAttributeExtensionObj = new AddingOrderChargeAttributeExtension(stdControllerOrder);
        addingOrderChargeAttributeExtensionObj.save();
        
          
        
        ApexPages.StandardController stdControllerOpportunity = new ApexPages.StandardController(opportunity1);
        system.currentPageReference().getParameters().put('id', ''+opportunity1.Id);
        AddingOpptChargeExten addingOpptChargeExtenObj = new  AddingOpptChargeExten(stdControllerOpportunity);
        addingOpptChargeExtenObj.save();
        Test.stopTest();
           
    }
   /* static testMethod void myUnitTestControllerSelectQuoteType(){
        Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;

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
        
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id);
        insert oppProduct;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;

        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;

        Opportunity_Charge_Attribute__c accessRight1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Picklist', Attribute_Name__c='Law',Attribute_Picklist_Values__c='Criminal Law,Civil Law,Consumer Law',Picklist_Value__c='Civil Law');
        insert accessRight1;
        
        Opportunity_Charge_Attribute__c accessRight2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Text', Attribute_Name__c='State',String_Value__c='ABC');
        insert accessRight2;        

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
                Renewable__c = true                       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;

        OpportunityCreationUtil.getOpportunity(opportunity1.Id);
        list<invoiceit_crmx__Opportunity_Product__c> listofOppProducts = OpportunityCreationUtil.getListOpportunityProducts(opportunity1.Id);
        Map<Id,OpportunityProductClass> map_Id_OpportunityProductClass = OpportunityCreationUtil.getMapOpptProducts(listofOppProducts);
        OpportunityCreationUtil.queryattributesBasedOpptId(opportunity1.Id);
        list<Id> OpptProductIds = new list<Id>();
        OpptProductIds.add(oppProduct.Id);
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpptProductIds.clear();
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpportunityCreationUtil OpportunityCreationUtilObj = new OpportunityCreationUtil();
        
        OpportunityRatePlanChargeClass  opportunityRatePlanChargeClassObj = new OpportunityRatePlanChargeClass();
        opportunityRatePlanChargeClassObj.getopptChargeAttributes();
        
        list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
        System.debug('Prining all information-->'+account.id+'contact--'+listContacts.get(0).Id+'=='+listContacts.get(1).Id+'currencyObj-->'+currencyObj.id);
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Billing_Contact__c = listContacts.get(0).Id, invoiceit_s__Shipping_Contact__c = listContacts.get(1).Id, invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0, invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12, invoiceit_s__Service_End_Date__c = system.today() +1,invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge2.Id);
        insert charge;
        
         Test.startTest();  
        JobCreationUtil.getJob(job.Id);
        JobCreationUtil.getListJobProducts(job.Id);
        list<invoiceit_s__Job_Product__c> listofJobProduct = new list<invoiceit_s__Job_Product__c>();
        listofJobProduct.add(jobProduct);
        JobCreationUtil.getMapJobProducts(listofJobProduct);
        list<Id> jobProductIds = new list<Id>();
        jobProductIds.add(jobProduct.Id);
        JobCreationUtil.getListJobRatePlans(jobProductIds);
        Order_Charge_Attribute__c orderChargeAttribute = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'Picklist',Attribute_Picklist_Values__c = 'Select' );
        insert orderChargeAttribute;
        Order_Charge_Attribute__c orderChargeAttribute1 = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'String',Attribute_Picklist_Values__c = 'Select' );
        insert orderChargeAttribute1;
        list<Order_Charge_Attribute__c> jobAttributes = new list<Order_Charge_Attribute__c>();
        jobAttributes.add(orderChargeAttribute);
        JobCreationUtil.queryattributesBasedJobId(job.Id);
        
             
        ApexPages.StandardController stdControllerOrderObj = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj = new ControllerSelectQuoteType(stdControllerOrderObj); 
        controllerSelectQuoteTypeObj.noOfTerms = 5;
        JobClass jobClass = controllerSelectQuoteType.populateJobClass(job);
        string quoteType = 'Test';
        controllerSelectQuoteType.getObjectSelectQuery('invoiceit_s__Job__c');
         
        controllerSelectQuoteTypeObj.onloadOfQuotePage();
        controllerSelectQuoteTypeObj.onloadOfCancelPage();
        controllerSelectQuoteTypeObj.renew();    
        controllerSelectQuoteTypeObj.modify();
        controllerSelectQuoteTypeObj.evergreen();
        controllerSelectQuoteTypeObj.noloMigration();
        controllerSelectQuoteTypeObj.MidTermAdjustment();
        //controllerSelectQuoteTypeObj.cancelBtn();
        //controllerSelectQuoteTypeObj.createOpportunity(jobClass, quoteType);
          
               
        job.invoiceit_s__Status__c = 'Expired';
        update job;
        ApexPages.StandardController stdControllerOrderObj1 = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj1 = new ControllerSelectQuoteType(stdControllerOrderObj1);
        
        job.invoiceit_s__Status__c = 'Cancelled';
        update job;
        ApexPages.StandardController stdControllerOrderObj4 = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj4 = new ControllerSelectQuoteType(stdControllerOrderObj4);
        
        system.Test.stopTest();
    }*/
    
    /*static testMethod void myUnitTestNgageController(){
        integer seqno = 1;
        Account account = new Account(name = 'Test Account 4', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;

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
        
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id, invoiceit_crmx__SequenceNumber__c = seqno);
        insert oppProduct;

        seqno++;
        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;

        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;

        Opportunity_Charge_Attribute__c accessRight1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Picklist', Attribute_Name__c='Law',Attribute_Picklist_Values__c='Criminal Law,Civil Law,Consumer Law',Picklist_Value__c='Civil Law');
        insert accessRight1;
        
        Opportunity_Charge_Attribute__c accessRight2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Text', Attribute_Name__c='State',String_Value__c='ABC');
        insert accessRight2;

        id Oppprodid = [select id, name from invoiceit_s__Product__c where name = 'Professional Profile'].id;
        oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Professional Profile', invoiceit_crmx__Product__c = Oppprodid, invoiceit_crmx__Product_Code__c = '11006', invoiceit_crmx__SequenceNumber__c = seqno, invoiceit_crmx__Opportunity__c = opportunity1.Id);
        insert oppProduct;
        
        seqno++;
        oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Professional Profile', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;
        
        OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'Monthly', invoiceit_crmx__Accounting_Code__c = '11006', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;
        
        Oppprodid = [select id, name from invoiceit_s__Product__c where name = 'Web Bronze'].id;
        oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Web Bronze', invoiceit_crmx__Product__c = Oppprodid, invoiceit_crmx__Product_Code__c = '11006', invoiceit_crmx__SequenceNumber__c = seqno, invoiceit_crmx__Opportunity__c = opportunity1.Id);
        insert oppProduct;
        
        seqno++;
        oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Web Bronze', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;
        
        OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'Monthly', invoiceit_crmx__Accounting_Code__c = '11006', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
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
                invoiceit_s__Price_Type__c = 'Monthly'                       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;

        OpportunityCreationUtil.getOpportunity(opportunity1.Id);
        list<invoiceit_crmx__Opportunity_Product__c> listofOppProducts = OpportunityCreationUtil.getListOpportunityProducts(opportunity1.Id);
        Map<Id,OpportunityProductClass> map_Id_OpportunityProductClass = OpportunityCreationUtil.getMapOpptProducts(listofOppProducts);
        OpportunityCreationUtil.queryattributesBasedOpptId(opportunity1.Id);
        list<Id> OpptProductIds = new list<Id>();
        OpptProductIds.add(oppProduct.Id);
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpptProductIds.clear();
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpportunityCreationUtil OpportunityCreationUtilObj = new OpportunityCreationUtil();
        
        OpportunityRatePlanChargeClass  opportunityRatePlanChargeClassObj = new OpportunityRatePlanChargeClass();
        opportunityRatePlanChargeClassObj.getopptChargeAttributes();
        
        list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
        System.debug('Prining all information-->'+account.id+'contact--'+listContacts.get(0).Id+'=='+listContacts.get(1).Id+'currencyObj-->'+currencyObj.id);
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id, invoiceit_s__Billing_Contact__c = listContacts.get(0).Id, invoiceit_s__Shipping_Contact__c = listContacts.get(1).Id, invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0, invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12, invoiceit_s__Service_End_Date__c = system.today() +1,invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge1.Id);
        insert charge;
        Test.startTest(); 
        JobCreationUtil.getJob(job.Id);
        JobCreationUtil.getListJobProducts(job.Id);
        list<invoiceit_s__Job_Product__c> listofJobProduct = new list<invoiceit_s__Job_Product__c>();
        listofJobProduct.add(jobProduct);
        JobCreationUtil.getMapJobProducts(listofJobProduct);
        list<Id> jobProductIds = new list<Id>();
        jobProductIds.add(jobProduct.Id);
        JobCreationUtil.getListJobRatePlans(jobProductIds);
        Order_Charge_Attribute__c orderChargeAttribute = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'Picklist',Attribute_Picklist_Values__c = 'Select' );
        insert orderChargeAttribute;
        Order_Charge_Attribute__c orderChargeAttribute1 = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'String',Attribute_Picklist_Values__c = 'Select' );
        insert orderChargeAttribute1;
        list<Order_Charge_Attribute__c> jobAttributes = new list<Order_Charge_Attribute__c>();
        jobAttributes.add(orderChargeAttribute);
        JobCreationUtil.queryattributesBasedJobId(job.Id);
        
               
        ApexPages.StandardController stdControllerOrderObj = new ApexPages.StandardController(opportunity1);
        NgageChatController NgageChatControllerObj = new NgageChatController(stdControllerOrderObj); 
        If(!NgageChatControllerObj.ChatProdList.isEmpty()){
            NgageChatControllerObj.ChatProdList[0].ChatCheck = true;
        }
//        NgageChatControllerObj.ChatProdList[0].chatexists = false;
        NgageChatControllerObj.save();
//        NgageChatControllerObj.noOfTerms = 5;
//        JobClass jobClass = controllerSelectQuoteType.populateJobClass(job);
        string quoteType = 'Test';
//        controllerSelectQuoteType.getObjectSelectQuery('invoiceit_s__Job__c');
         
//        controllerSelectQuoteTypeObj.onloadOfQuotePage();
//        controllerSelectQuoteTypeObj.onloadOfCancelPage();
//        controllerSelectQuoteTypeObj.renew();    
//        controllerSelectQuoteTypeObj.modify();
//        controllerSelectQuoteTypeObj.evergreen();
//        controllerSelectQuoteTypeObj.noloMigration();
        //controllerSelectQuoteTypeObj.cancelBtn();
        //controllerSelectQuoteTypeObj.createOpportunity(jobClass, quoteType);
          
               
        job.invoiceit_s__Status__c = 'Expired';
        update job;
        ApexPages.StandardController stdControllerOrderObj1 = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj1 = new ControllerSelectQuoteType(stdControllerOrderObj1);
        Test.stopTest();
    }*/
    

    static testMethod void myUnitTest1() {
        Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;

        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '$');
        insert currencyObj;
        
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
                Renewable__c = true                      
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;
        
        list<Attribute_Config__c> listOfAttributeConfig = new list<Attribute_Config__c>();
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Account Name' ,Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                        Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 10,
                                        Minimum_No_Of_Characters_In_Text__c = 2  
                                        ));
        listOfAttributeConfig.add(new Attribute_Config__c(Name = 'Service Account Name', Attribute_Order__c = 12, Attribute_Picklist_Values__c = 'test Values', 
                                        Attribute_Type__c = 'Picklist', Maximum_No_Of_Characters_In_Text__c = 10,
                                        Minimum_No_Of_Characters_In_Text__c = 2  
                                        ));
                                        
        list<Product_Charge_Attribute__c> listOfProductChargeAttribute = new list<Product_Charge_Attribute__c>();
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(0).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(1).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(1).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(1).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(1).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'Number', AttributeName__c = listOfAttributeConfig.get(1).id));
        listOfProductChargeAttribute.add(new Product_Charge_Attribute__c(Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(1).id, Attribute_Name__c = 'City', Attribute_Order__c = 1, Attribute_Type__c = 'String', AttributeName__c = listOfAttributeConfig.get(1).id));
        insert listOfProductChargeAttribute;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(productRatePlanCharge1);
        CreateProductChrgeAttributeExtension  createProductChrgeAttributeExtensionObj = new CreateProductChrgeAttributeExtension(controller);
        createProductChrgeAttributeExtensionObj.addingProductChargeAttribute();
        createProductChrgeAttributeExtensionObj.addingProductChargeAttribute();
        createProductChrgeAttributeExtensionObj.addingProductChargeAttribute();
        system.currentPageReference().getParameters().put('counterparameter', '1');
        createProductChrgeAttributeExtensionObj.removingAttribute();
        createProductChrgeAttributeExtensionObj.savingAttribute();
    }
    
    /*static testMethod void myUnitTestControllerSelectQuoteType1(){
        Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;

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
        
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id);
        insert oppProduct;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;

        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;

        Opportunity_Charge_Attribute__c accessRight1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Picklist', Attribute_Name__c='Law',Attribute_Picklist_Values__c='Criminal Law,Civil Law,Consumer Law',Picklist_Value__c='Civil Law');
        insert accessRight1;
        
        Opportunity_Charge_Attribute__c accessRight2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Text', Attribute_Name__c='State',String_Value__c='ABC');
        insert accessRight2;        

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
                Renewable__c = true                       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;

        OpportunityCreationUtil.getOpportunity(opportunity1.Id);
        list<invoiceit_crmx__Opportunity_Product__c> listofOppProducts = OpportunityCreationUtil.getListOpportunityProducts(opportunity1.Id);
        Map<Id,OpportunityProductClass> map_Id_OpportunityProductClass = OpportunityCreationUtil.getMapOpptProducts(listofOppProducts);
        OpportunityCreationUtil.queryattributesBasedOpptId(opportunity1.Id);
        list<Id> OpptProductIds = new list<Id>();
        OpptProductIds.add(oppProduct.Id);
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpptProductIds.clear();
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpportunityCreationUtil OpportunityCreationUtilObj = new OpportunityCreationUtil();
        
        OpportunityRatePlanChargeClass  opportunityRatePlanChargeClassObj = new OpportunityRatePlanChargeClass();
        opportunityRatePlanChargeClassObj.getopptChargeAttributes();
        
        list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
        System.debug('Prining all information-->'+account.id+'contact--'+listContacts.get(0).Id+'=='+listContacts.get(1).Id+'currencyObj-->'+currencyObj.id);
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(Renew_Rebase__c = 'Rebase',invoiceit_s__Account__c = account.id, invoiceit_s__Billing_Contact__c = listContacts.get(0).Id, invoiceit_s__Shipping_Contact__c = listContacts.get(1).Id, invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0, invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12, invoiceit_s__Service_End_Date__c = system.today() +1,invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge2.Id);
        insert charge;
        
        Test.startTest();
        JobCreationUtil.getJob(job.Id);
        JobCreationUtil.getListJobProducts(job.Id);
        list<invoiceit_s__Job_Product__c> listofJobProduct = new list<invoiceit_s__Job_Product__c>();
        listofJobProduct.add(jobProduct);
        JobCreationUtil.getMapJobProducts(listofJobProduct);
        list<Id> jobProductIds = new list<Id>();
        jobProductIds.add(jobProduct.Id);
        JobCreationUtil.getListJobRatePlans(jobProductIds);
        Order_Charge_Attribute__c orderChargeAttribute = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'Picklist',Attribute_Picklist_Values__c = 'Select' );
        insert orderChargeAttribute;
        Order_Charge_Attribute__c orderChargeAttribute1 = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'String',Attribute_Picklist_Values__c = 'Select' );
        insert orderChargeAttribute1;
        list<Order_Charge_Attribute__c> jobAttributes = new list<Order_Charge_Attribute__c>();
        jobAttributes.add(orderChargeAttribute);
        JobCreationUtil.queryattributesBasedJobId(job.Id);
        
                
        ApexPages.StandardController stdControllerOrderObj = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj = new ControllerSelectQuoteType(stdControllerOrderObj); 
        controllerSelectQuoteTypeObj.noOfTerms = 5;
        JobClass jobClass = controllerSelectQuoteType.populateJobClass(job);
        string quoteType = 'Test';
        controllerSelectQuoteType.getObjectSelectQuery('invoiceit_s__Job__c');
         
        controllerSelectQuoteTypeObj.onloadOfQuotePage();
        controllerSelectQuoteTypeObj.onloadOfCancelPage();
        controllerSelectQuoteTypeObj.renew();    
        controllerSelectQuoteTypeObj.modify();
        controllerSelectQuoteTypeObj.evergreen();
        controllerSelectQuoteTypeObj.noloMigration();
        controllerSelectQuoteTypeObj.MidTermAdjustment();
        //controllerSelectQuoteTypeObj.cancelBtn();
        //controllerSelectQuoteTypeObj.createOpportunity(jobClass, quoteType);
          
               
        job.invoiceit_s__Status__c = 'Expired';
        update job;
        ApexPages.StandardController stdControllerOrderObj1 = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj1 = new ControllerSelectQuoteType(stdControllerOrderObj1);
        
        Test.stopTest();
    }*/
    
    static testMethod void myUnitTestControllerSelectQuoteType2(){
        Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;

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
        
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id);
        insert oppProduct;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;

        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;

        List<Opportunity_Charge_Attribute__c> attributes = new List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c accessRight1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Picklist', Attribute_Name__c='Law',Attribute_Picklist_Values__c='Criminal Law,Civil Law,Consumer Law',Picklist_Value__c='Civil Law');
        //insert accessRight1;
        
        Opportunity_Charge_Attribute__c accessRight2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Text', Attribute_Name__c='State',String_Value__c='ABC');
        //insert accessRight2;
        attributes.add(accessRight1);
        attributes.add(accessRight2);  
        insert attributes;

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
                Renewable__c = true                       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;

      OpportunityCreationUtil.getOpportunity(opportunity1.Id);
        list<invoiceit_crmx__Opportunity_Product__c> listofOppProducts = OpportunityCreationUtil.getListOpportunityProducts(opportunity1.Id);
        Map<Id,OpportunityProductClass> map_Id_OpportunityProductClass = OpportunityCreationUtil.getMapOpptProducts(listofOppProducts);
        OpportunityCreationUtil.queryattributesBasedOpptId(opportunity1.Id);
        list<Id> OpptProductIds = new list<Id>();
        OpptProductIds.add(oppProduct.Id);
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpptProductIds.clear();
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpportunityCreationUtil OpportunityCreationUtilObj = new OpportunityCreationUtil();
        
        OpportunityRatePlanChargeClass  opportunityRatePlanChargeClassObj = new OpportunityRatePlanChargeClass();
        opportunityRatePlanChargeClassObj.getopptChargeAttributes();
        
        list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
        System.debug('Prining all information-->'+account.id+'contact--'+listContacts.get(0).Id+'=='+listContacts.get(1).Id+'currencyObj-->'+currencyObj.id);
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(Renew_Rebase__c = 'Renew',invoiceit_s__Account__c = account.id, invoiceit_s__Billing_Contact__c = listContacts.get(0).Id, invoiceit_s__Shipping_Contact__c = listContacts.get(1).Id, invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0, invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12, invoiceit_s__Service_End_Date__c = system.today() +1,invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge2.Id);
        insert charge;
        
       Test.startTest();
        JobCreationUtil.getJob(job.Id);
        JobCreationUtil.getListJobProducts(job.Id);
        list<invoiceit_s__Job_Product__c> listofJobProduct = new list<invoiceit_s__Job_Product__c>();
        listofJobProduct.add(jobProduct);
        JobCreationUtil.getMapJobProducts(listofJobProduct);
        list<Id> jobProductIds = new list<Id>();
        jobProductIds.add(jobProduct.Id);
        JobCreationUtil.getListJobRatePlans(jobProductIds);
        
        
        Order_Charge_Attribute__c orderChargeAttribute = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'Picklist',Attribute_Picklist_Values__c = 'Select' );
        //insert orderChargeAttribute;
        Order_Charge_Attribute__c orderChargeAttribute1 = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'String',Attribute_Picklist_Values__c = 'Select' );
        //insert orderChargeAttribute1;
        list<Order_Charge_Attribute__c> jobAttributes = new list<Order_Charge_Attribute__c>();
        jobAttributes.add(orderChargeAttribute);
         jobAttributes.add(orderChargeAttribute1);
        insert jobAttributes;
            
        JobCreationUtil.queryattributesBasedJobId(job.Id);       
                
        ApexPages.StandardController stdControllerOrderObj = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj = new ControllerSelectQuoteType(stdControllerOrderObj); 
        controllerSelectQuoteTypeObj.noOfTerms = 5;
        JobClass jobClass = controllerSelectQuoteType.populateJobClass(job);
        string quoteType = 'Test';
        controllerSelectQuoteType.getObjectSelectQuery('invoiceit_s__Job__c');
          
        controllerSelectQuoteTypeObj.onloadOfQuotePage();
        controllerSelectQuoteTypeObj.onloadOfCancelPage();
        controllerSelectQuoteTypeObj.renew();    
        controllerSelectQuoteTypeObj.modify();
        /*controllerSelectQuoteTypeObj.evergreen();
        controllerSelectQuoteTypeObj.noloMigration();
        controllerSelectQuoteTypeObj.MidTermAdjustment();
        //controllerSelectQuoteTypeObj.cancelBtn();
        //controllerSelectQuoteTypeObj.createOpportunity(jobClass, quoteType);
          
               
       /* job.invoiceit_s__Status__c = 'Expired';
        update job;
        ApexPages.StandardController stdControllerOrderObj1 = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj1 = new ControllerSelectQuoteType(stdControllerOrderObj1);
        
        job.invoiceit_s__Status__c = 'Cancelled';
        update job;
        ApexPages.StandardController stdControllerOrderObj4 = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj4 = new ControllerSelectQuoteType(stdControllerOrderObj4);*/
        
        Test.stopTest();
    }
    
    
    //dividing controller select quote type here as it is hitting soql 101
     static testMethod void myUnitTestControllerSelectQuoteType3(){
        Account account = new Account(name = 'Test Account', invoiceit_s__Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()));
        insert account;

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
        
        invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product', invoiceit_crmx__Opportunity__c = opportunity1.Id);
        insert oppProduct;

        invoiceit_crmx__Opportunity_Rate_Plan__c oppProductRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c(Name = 'Opp Product Rate Plan', invoiceit_crmx__Opportunity_Product__c = oppProduct.Id,invoiceit_crmx__Product_Rate_Plan__c = productRatePlan.Id);
        insert oppProductRatePlan;

        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c OppCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(invoiceit_crmx__Price_Type__c = 'One Time', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = oppProductRatePlan.id);          
        insert OppCharge;

        List<Opportunity_Charge_Attribute__c> attributes = new List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c accessRight1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Picklist', Attribute_Name__c='Law',Attribute_Picklist_Values__c='Criminal Law,Civil Law,Consumer Law',Picklist_Value__c='Civil Law');
        //insert accessRight1;
        
        Opportunity_Charge_Attribute__c accessRight2 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = OppCharge.id, Attribute_Type__c = 'Text', Attribute_Name__c='State',String_Value__c='ABC');
        //insert accessRight2;
        attributes.add(accessRight1);
        attributes.add(accessRight2);  
        insert attributes;

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
                Renewable__c = true                       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        insert listProductRatePlanCharges;

      OpportunityCreationUtil.getOpportunity(opportunity1.Id);
        list<invoiceit_crmx__Opportunity_Product__c> listofOppProducts = OpportunityCreationUtil.getListOpportunityProducts(opportunity1.Id);
        Map<Id,OpportunityProductClass> map_Id_OpportunityProductClass = OpportunityCreationUtil.getMapOpptProducts(listofOppProducts);
        OpportunityCreationUtil.queryattributesBasedOpptId(opportunity1.Id);
        list<Id> OpptProductIds = new list<Id>();
        OpptProductIds.add(oppProduct.Id);
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpptProductIds.clear();
        OpportunityCreationUtil.getListOpptRatePlans(OpptProductIds);
        OpportunityCreationUtil OpportunityCreationUtilObj = new OpportunityCreationUtil();
        
        OpportunityRatePlanChargeClass  opportunityRatePlanChargeClassObj = new OpportunityRatePlanChargeClass();
        opportunityRatePlanChargeClassObj.getopptChargeAttributes();
        
        list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
        System.debug('Prining all information-->'+account.id+'contact--'+listContacts.get(0).Id+'=='+listContacts.get(1).Id+'currencyObj-->'+currencyObj.id);
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(Renew_Rebase__c = 'Renew',invoiceit_s__Account__c = account.id, invoiceit_s__Billing_Contact__c = listContacts.get(0).Id, invoiceit_s__Shipping_Contact__c = listContacts.get(1).Id, invoiceit_s__Sub_Total__c = 100, invoiceit_s__Discount_Value__c = 0, invoiceit_s__CurrencyL__c = currencyObj.Id);
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12, invoiceit_s__Service_End_Date__c = system.today() +1,invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge2.Id);
        insert charge;
        
       
        JobCreationUtil.getJob(job.Id);
        JobCreationUtil.getListJobProducts(job.Id);
        list<invoiceit_s__Job_Product__c> listofJobProduct = new list<invoiceit_s__Job_Product__c>();
        listofJobProduct.add(jobProduct);
        JobCreationUtil.getMapJobProducts(listofJobProduct);
        list<Id> jobProductIds = new list<Id>();
        jobProductIds.add(jobProduct.Id);
        JobCreationUtil.getListJobRatePlans(jobProductIds);
        
       
        Order_Charge_Attribute__c orderChargeAttribute = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'Picklist',Attribute_Picklist_Values__c = 'Select' );
        //insert orderChargeAttribute;
        Order_Charge_Attribute__c orderChargeAttribute1 = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = charge.Id,Attribute_Type__c = 'String',Attribute_Picklist_Values__c = 'Select' );
        //insert orderChargeAttribute1;
        list<Order_Charge_Attribute__c> jobAttributes = new list<Order_Charge_Attribute__c>();
        jobAttributes.add(orderChargeAttribute);
         jobAttributes.add(orderChargeAttribute1);
        insert jobAttributes;
           
        JobCreationUtil.queryattributesBasedJobId(job.Id);       
        Test.startTest();          
        ApexPages.StandardController stdControllerOrderObj = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj = new ControllerSelectQuoteType(stdControllerOrderObj); 
        controllerSelectQuoteTypeObj.noOfTerms = 5;
        JobClass jobClass = controllerSelectQuoteType.populateJobClass(job);
        string quoteType = 'Test';
        controllerSelectQuoteType.getObjectSelectQuery('invoiceit_s__Job__c');
          
        /*controllerSelectQuoteTypeObj.onloadOfQuotePage();
        controllerSelectQuoteTypeObj.onloadOfCancelPage();
        controllerSelectQuoteTypeObj.renew();    
        controllerSelectQuoteTypeObj.modify();*/
        controllerSelectQuoteTypeObj.evergreen();
        controllerSelectQuoteTypeObj.noloMigration();
        controllerSelectQuoteTypeObj.MidTermAdjustment();
        controllerSelectQuoteTypeObj.FkMethod();
        //controllerSelectQuoteTypeObj.cancelBtn();
        //controllerSelectQuoteTypeObj.createOpportunity(jobClass, quoteType);
          
               
        job.invoiceit_s__Status__c = 'Expired';
        update job;
        ApexPages.StandardController stdControllerOrderObj1 = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj1 = new ControllerSelectQuoteType(stdControllerOrderObj1);
        
        job.invoiceit_s__Status__c = 'Cancelled';
        update job;
        ApexPages.StandardController stdControllerOrderObj4 = new ApexPages.StandardController(job);
        ControllerSelectQuoteType controllerSelectQuoteTypeObj4 = new ControllerSelectQuoteType(stdControllerOrderObj4);
        
        Test.stopTest();
    }
}