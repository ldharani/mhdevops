@isTest(seealldata=true)
public class BatchDataLdOrderRPCtoQuoteLineTest {
    
    static testMethod void myUnitTest() {    
        
        // Load Custom settings
      //  DataFactory.loadCustomSettings();
        
        List<Geo_location__c>geoList = new List<Geo_location__c>();
        GEO_Location__c geo = new GEO_Location__c(CountryName__c = 'USA', State_Abbrevation__c = 'NY',
                                                  County_Name__c = 'Albany', City_Name__c = 'Albany',
                                                  CountryID__c ='1', StateID__c='2',
                                                  County_ID__c = '3', City_ID__c='4');
        geo.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo.State_Inv_Flag__c       = 'Yes';
         geo.City_Inv_Flag__c       = 'Yes';
         geo.County_Inv_Flag__c       = 'Yes';
         GEO_Location__c geo1 = new GEO_Location__c(CountryName__c = 'USA', State_Abbrevation__c = 'AC',
                                                  County_Name__c = 'test', City_Name__c = 'Ajij',
                                                  CountryID__c ='1', StateID__c='2',
                                                  County_ID__c = '3', City_ID__c='4');
        geo1.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo1.State_Inv_Flag__c       = 'Yes';
         geo1.City_Inv_Flag__c       = 'Yes';
         geo1.County_Inv_Flag__c       = 'Yes';
       
        geoList.add(geo);
        geoList.add(geo1);
        
        //creating AOP Record here
        Id aopRecordTypeId    = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
        Geo_location__c geoaop = new Geo_location__c(AOP_List_value__c = '01667',AOP_Name__c = 'Administrative',
                                                       RecordTypeId = aopRecordTypeId);
         geoList.add(geoaop);
        insert geoList;

        blng__LegalEntity__c legal = new blng__LegalEntity__c();
        legal.blng__Active__c = TRUE;
        legal.Name = 'MARTINDALEHUBBELL';
        insert legal;
        
       // List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Lawyers.com Preferred State Results', objBR, objRR, objTR, 1);
        Product2 objProd = new Product2();
            objProd.Name = 'Nolo Leads';
            objProd.Productcode = '40010';
            objProd.IsActive = true;
            objProd.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            objProd.SBQQ__SubscriptionTerm__c = 12;
            objProd.SBQQ__SubscriptionType__c = 'Evergreen';
            objProd.SBQQ__SubscriptionType__c = 'Renewable';
            objProd.SBQQ__ChargeType__c = 'Recurring';
            objProd.SBQQ__BillingFrequency__c = 'Monthly';
            objProd.SBQQ__BillingType__c = 'Arrears';
            objProd.SBQQ__PricingMethod__c = 'List';
            objProd.blng__BillingRule__c = objBR.Id;
            objProd.blng__RevenueRecognitionRule__c = objRR.Id;
            objProd.blng__TaxRule__c = objTR.Id;
         
         insert objProd;
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();    
        Account account = util.getAccount();        
        
        Contact contact = util.getContact(account.Id);
        
        Date validtodate = Date.today();
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj;
        invoiceit_s__Product__c product = new invoiceit_s__Product__c(Name = 'Nolo Leads',invoiceit_s__Valid_From_Date__c = validtodate,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = '40010',invoiceit_s__Description__c = 'Product',Shippable__c = 'Yes');
        insert product;
        list<invoiceit_s__Product_Rate_Plan__c> listProductRatePlans = new list<invoiceit_s__Product_Rate_Plan__c>();
        invoiceit_s__Product_Rate_Plan__c productRatePlan;
        for(Integer x = 0;x< 2;x++){
            productRatePlan = new  invoiceit_s__Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,invoiceit_s__Product__c = product.Id,invoiceit_s__Valid_From_Date__c = validtodate,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2));
            listProductRatePlans.add(productRatePlan);
        }
        insert listProductRatePlans;
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                              invoiceit_s__Unit_price__c = 1000,
                                                              invoiceit_s__Cost_Price__c = 500,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'One Time'
                                                              );
        listProductRatePlanCharges.add(productRatePlanCharge_SetUp);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj.ID,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                              invoiceit_s__Unit_price__c = 500,
                                                              invoiceit_s__Cost_Price__c = 250,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'Monthly'
                                                              );                                                       
        listProductRatePlanCharges.add(productRatePlanCharge_Monthly);
        insert listProductRatePlanCharges;
        
        
        
        Attribute_Config__c  attributeConfug= new Attribute_Config__c (Attribute_Picklist_Values__c ='Text' ,Attribute_Type__c ='Text' );
        insert attributeConfug ; 
        
           
        list<Product_Charge_Attribute__c> listofproductAttribute = new list<Product_Charge_Attribute__c>();
        Product_Charge_Attribute__c  productAttribute =  new Product_Charge_Attribute__c(AttributeName__c = attributeConfug.id ,Attribute_Name__c = 'Text',Attribute_Order__c = 1,Attribute_Type__c = 'String',Default_Boolean__c = false , Default_Date__c = system.today(),Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].id);       
        listofproductAttribute.add(productAttribute);
        listofproductAttribute.add(new Product_Charge_Attribute__c(AttributeName__c = attributeConfug.id ,Attribute_Name__c = 'Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Text',Default_Boolean__c = false , Default_Date__c = system.today(),Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].id));
        insert listofproductAttribute;
        
        
        Opportunity Opportunityobj = new Opportunity(AccountId=account.Id,Name ='testoopty',StageName ='Declined', CloseDate =system.today(),Type='New Business',invoiceit_crmx__Shipping_Contact__c=contact.Id ,invoiceit_crmx__Billing_Contact__c=contact.Id,Auth_By_Contact__c=contact.Id );
        insert Opportunityobj;
        
        
        invoiceit_crmx__Opportunity_Product__c opportunityproductobj= new invoiceit_crmx__Opportunity_Product__c(Name='Product', invoiceit_crmx__SequenceNumber__c=1,invoiceit_crmx__Opportunity__c=Opportunityobj.Id ,invoiceit_crmx__Product__c = product.Id);
        insert opportunityproductobj;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opportunityproductrateplanobj=new invoiceit_crmx__Opportunity_Rate_Plan__c(Name='Rate plan',invoiceit_crmx__Opportunity_Product__c=opportunityproductobj.Id ,invoiceit_crmx__Product_Rate_Plan__c = listProductRatePlans[0].id);
        insert opportunityproductrateplanobj;
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Opportunityrateplanchargeobj= new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name='SEO Advanced',invoiceit_crmx__Opportunity_Rate_Plan__c=opportunityproductrateplanobj.Id ,invoiceit_crmx__Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].id);
        insert Opportunityrateplanchargeobj;
        
        Opportunity_Charge_Attribute__c Opportunitychargeattributeobj=new Opportunity_Charge_Attribute__c(Attribute_Name__c='Ring to Number',Attribute_Order__c=2,Attribute_Picklist_Values__c='1',Picklist_Value__c='1',Required__c=true,Maximum_No_Of_Characters_In_Text__c=18,Minimum_No_Of_Characters_In_Text__c=25,Attribute_Type__c='Picklist',Boolean_Value__c=true,
                                                                                                          Date_Value__c=system.today(),Phone_Value__c='12345',Number_Value__c=12,String_Value__c='40',Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id);
        insert Opportunitychargeattributeobj;        
        
        
        list<Opportunity_Charge_Attribute__c> listofOpportunitychargeattributeobj = new list<Opportunity_Charge_Attribute__c>();
        //Commented by Sai C for county id code
        
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'State', Picklist_Value__c = 'test'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'County', Picklist_Value__c = 'test'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'City', Picklist_Value__c = 'test'));
        //listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Text', Attribute_Name__c  = 'Test', String_Value__c = 'te'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'String', Attribute_Name__c = 'AOP/Geo 1', String_Value__c = 'E-Commerce ; GU ; N/A ; Happy Jack ;'));
        //listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'String', Attribute_Name__c = 'Service State', String_Value__c = 'test'));
        
        insert listofOpportunitychargeattributeobj;
                
        State_County__c countyobj=new State_County__c(City__c='Bangalore',County__c='India',State__c='Karnataka');
        insert countyobj;               
        
        ApexPages.currentPage().getParameters().put('id',Opportunityobj.id);
        ApexPages.StandardController stdobj =new ApexPages.StandardController(Opportunityobj);
        AddingOpptChargeExten2Duplicate AddingOpptChargeExten2obj= new AddingOpptChargeExten2Duplicate(stdobj);
        AddingOpptChargeExten2obj.save();        
        AddingOpptChargeExten2obj.fromRowNum = '4';
        AddingOpptChargeExten2obj.addChargeObj = Opportunityrateplanchargeobj.id;
        AddingOpptChargeExten2obj.addNewRow();
        AddingOpptChargeExten2obj.save(); 
        AddingOpptChargeExten2obj.deleteRowNum= '5';
        AddingOpptChargeExten2obj.deleteRow();       
        AddingOpptChargeExten2obj.refreshPageCalled();
        State_County__c state = new State_County__c(City__c ='KA',County__c = 'KA' ,State__c = 'test');
        insert  state;
        

        Test.startTest();         
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id,invoiceit_s__Billing_Contact__c = contact.Id,
                invoiceit_s__Shipping_Contact__c = contact.Id,
                invoiceit_s__Number_Of_Terms__c = 24,
                invoiceit_s__CurrencyL__c = currencyObj.Id,
                invoiceit_s__Start_Date__c = system.today(), 
                invoiceit_s__Service_Activation_Date__c = system.today(), 
                invoiceit_s__Service_End_Date__c = system.today().addMonths(10),
                invoiceit_s__Preferred_Billing_Day__c = '1',invoiceit_s__Status__c = 'Active');
        insert job;  
        invoiceit_s__Job__c job1 = new invoiceit_s__Job__c(invoiceit_s__Account__c = account.id,invoiceit_s__CurrencyL__c = currencyObj.Id,invoiceit_s__Service_End_Date__c = validtodate.addMonths(10),invoiceit_s__Service_Activation_Date__c = validtodate,invoiceit_s__Status__c = 'Active');
        insert job1;
        job.Quote_Type__c = 'Renew' ;
       job.Recalculate_Date__c = true;
       update job;  
       invoiceit_s__Job_Product__c jobProduct = new invoiceit_s__Job_Product__c (invoiceit_s__Product__c=product.id,invoiceit_s__Job__c = job.id);
       insert jobProduct;   
        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;
        
        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Modify' ,invoiceit_s__Service_Activation_Date__c = validtodate);
        insert charge;
        invoiceit_s__Job_Rate_Plan_Charge__c charge1 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Renew' ,Created_From_Charge__c = charge.id,invoiceit_s__Service_Activation_Date__c = validtodate,invoiceit_s__Order__c =job.id,Opportunity_Rate_Plan_Charge__c =Opportunityrateplanchargeobj.id );
        insert charge1; 
         
        invoiceit_s__Job_Rate_Plan_Charge__c charge2 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Modify' ,invoiceit_s__Service_Activation_Date__c = validtodate,Created_From_Charge__c = charge.id,invoiceit_s__Order__c =job.id ,invoiceit_s__Product_Rate_Plan_Charge__c =listProductRatePlanCharges[0].id);
        insert charge2;
        
         BatchDataLdOrderRPCtoQuoteLine batch = new BatchDataLdOrderRPCtoQuoteLine();
        Database.executebatch(new BatchDataLdOrderRPCtoQuoteLine());
                
        test.stopTest();       
       
    } 
}