@isTest(seealldata=true)
public class TestAddingOpptChargeExten2Duplicate {
    static testMethod void myUnitTest() {        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();    
        Account account = util.getAccount();        
        
        Contact contact = util.getContact(account.Id);
        
        Date validtodate = Date.today();
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj;
        invoiceit_s__Product__c product = new invoiceit_s__Product__c(Name = 'Test Product for tiers',invoiceit_s__Valid_From_Date__c = validtodate,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product',Shippable__c = 'Yes');
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
        ApexPages.currentPage().getParameters().put('attributeName', 'Test');
        ApexPages.currentPage().getParameters().put('chargeId', Opportunityrateplanchargeobj.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[0].id);
                
        AddingOpptChargeExten2obj.populatingCountyCityValue();
        
        ApexPages.currentPage().getParameters().put('attributeName', 'Test');
        ApexPages.currentPage().getParameters().put('chargeId', Opportunityrateplanchargeobj.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[1].id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[2].id);
            
        AddingOpptChargeExten2obj.onChangeCountry(); 
        ApexPages.currentPage().getParameters().put('attributeName', 'Test');
        ApexPages.currentPage().getParameters().put('chargeId', Opportunityrateplanchargeobj.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[2].id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[3].id);
            
        AddingOpptChargeExten2obj.onChangeCountry(); 
        AddingOpptChargeExten2obj.quickSave(); 
        AddingOpptChargeExten2obj.next();
        AddingOpptChargeExten2obj.previous();
        AddingOpptChargeExten2obj.last();

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
                
        test.stopTest();       
       
    } 
    
   
    static testMethod void myUnitTest1() {
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account account1 = new Account(Name = 'Test Account');
        insert account1;
        
        Contact contact1 =  new Contact(LastName = 'Laxman', AccountId = account1.Id);                                 
        insert contact1;
        Date validtodate1 = Date.today();
        invoiceit_s__Currency__c currencyObj1 = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj1;
        
        invoiceit_s__Product__c product1 = new invoiceit_s__Product__c(Name = 'Test Product for tiers',invoiceit_s__Valid_From_Date__c = validtodate1,invoiceit_s__Valid_To_Date__c = validtodate1.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product',Shippable__c = 'Yes');
        insert product1;
        
        list<invoiceit_s__Product_Rate_Plan__c> listProductRatePlans1 = new list<invoiceit_s__Product_Rate_Plan__c>();
        invoiceit_s__Product_Rate_Plan__c productRatePlan1;
        for(Integer x = 0;x< 2;x++){
            productRatePlan1 = new  invoiceit_s__Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,invoiceit_s__Product__c = product1.Id,invoiceit_s__Valid_From_Date__c = validtodate1,invoiceit_s__Valid_To_Date__c = validtodate1.addMonths(2));
            listProductRatePlans1.add(productRatePlan1);
        }
        insert listProductRatePlans1;
        
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges1 = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp1 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj1.Id,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans1[0].Id,
                                                              invoiceit_s__Unit_price__c = 1000,
                                                              invoiceit_s__Cost_Price__c = 500,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'One Time'
                                                              );
        listProductRatePlanCharges1.add(productRatePlanCharge_SetUp1);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly1 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj1.ID,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans1[0].Id,
                                                              invoiceit_s__Unit_price__c = 500,
                                                              invoiceit_s__Cost_Price__c = 250,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'Monthly'
                                                              );                                                       
        listProductRatePlanCharges1.add(productRatePlanCharge_Monthly1);
        insert listProductRatePlanCharges1;
        
        list<Attribute_Config__c> listofAttributeConfig = new list<Attribute_Config__c> ();
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service Account Name',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref Service Account Name',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service Street Address',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service Street Address',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service City',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service City',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service State',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service State',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service Country',Attribute_Picklist_Values__c ='Text',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service Country',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service Zip',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Service Zip',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref Country',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref Country',Attribute_Picklist_Values__c ='Text',Attribute_Type__c ='Text' ));        
        listofAttributeConfig.add(new Attribute_Config__c (Name ='AOP',Attribute_Picklist_Values__c ='Text',Attribute_Type__c ='Text'));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref City',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref City',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref County',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref County',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref State',Attribute_Type__c ='Text' ));
        listofAttributeConfig.add(new Attribute_Config__c (Name ='Xref State',Attribute_Type__c ='Picklist' ));
        
        insert listofAttributeConfig ; 
        
           
        list<Product_Charge_Attribute__c> listofproductAttribute1 = new list<Product_Charge_Attribute__c>();
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[0].Id, Attribute_Name__c = 'Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Text',Default_Boolean__c = false , Default_Date__c = system.today(),Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[1].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[2].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[3].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));     
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[4].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[5].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[6].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[7].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[8].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[9].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id)); 
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[10].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[11].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[11].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[12].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[13].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[14].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[15].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[16].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[17].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[18].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        listofproductAttribute1.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig[19].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id));          
        
        
        insert listofproductAttribute1;
        
        invoiceit_s__Job__c jobNew = new invoiceit_s__Job__c(invoiceit_s__Account__c = account1.id,invoiceit_s__Billing_Contact__c = contact1.Id,
                invoiceit_s__Shipping_Contact__c = contact1.Id,
                invoiceit_s__Number_Of_Terms__c = 24,
                invoiceit_s__CurrencyL__c = currencyObj1.Id,
                invoiceit_s__Start_Date__c = system.today(), 
                invoiceit_s__Service_Activation_Date__c = system.today(), 
                invoiceit_s__Service_End_Date__c = system.today().addMonths(10),
                invoiceit_s__Preferred_Billing_Day__c = '1',invoiceit_s__Status__c = 'Active');
        insert jobNew;
        invoiceit_s__Job_Product__c jobProduct1 = new invoiceit_s__Job_Product__c (invoiceit_s__Product__c=product1.id,invoiceit_s__Job__c = jobNew.id);
        insert jobProduct1; 
        invoiceit_s__Job_Rate_Plan__c jobRP1 = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct1.Id);
        insert jobRP1;
        invoiceit_s__Job_Rate_Plan_Charge__c charge21 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP1.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Modify' ,invoiceit_s__Service_Activation_Date__c = validtodate1,invoiceit_s__Order__c =jobNew.id,Billing_Milestones__c = '30,40,50');
        //insert charge21;
        invoiceit_s__Job_Rate_Plan_Charge__c charge2 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP1.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Modify' ,invoiceit_s__Service_Activation_Date__c = validtodate1,invoiceit_s__Order__c =jobNew.id ,invoiceit_s__Product_Rate_Plan_Charge__c =listProductRatePlanCharges1[0].id);
        //insert charge2;
        
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listofCharge = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        listofCharge.add(charge21);
        listofCharge.add(charge2);
        insert listofCharge;
        
        //oppt        
        Opportunity Opportunityobj122 = new Opportunity(AccountId = account1.id , Name ='testoopty',StageName ='Declined', CloseDate =system.today(),Type='New Business',invoiceit_crmx__Shipping_Contact__c=contact1.Id ,invoiceit_crmx__Billing_Contact__c=contact1.Id,Auth_By_Contact__c=contact1.Id );
        insert Opportunityobj122;        
        
        invoiceit_crmx__Opportunity_Product__c opportunityproductobj122= new invoiceit_crmx__Opportunity_Product__c(Name='Product', invoiceit_crmx__SequenceNumber__c=1,invoiceit_crmx__Opportunity__c=Opportunityobj122.Id ,invoiceit_crmx__Product__c = product1.Id);
        insert opportunityproductobj122;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opportunityproductrateplanobj122= util.getOpportunityRatePlan(opportunityproductobj122.id, listProductRatePlans1[0].Id);
        //invoiceit_crmx__Opportunity_Rate_Plan__c opportunityproductrateplanobj122=new invoiceit_crmx__Opportunity_Rate_Plan__c(Name='Rate plan',invoiceit_crmx__Opportunity_Product__c=opportunityproductobj122.Id );
        //insert opportunityproductrateplanobj122;
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Opportunityrateplanchargeobj122= new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Quote_Type__c = 'New', Name='charge',invoiceit_crmx__Opportunity_Rate_Plan__c=opportunityproductrateplanobj122.Id ,invoiceit_crmx__Product_Rate_Plan_Charge__c = listProductRatePlanCharges1[0].id,invoiceit_crmx__Opportunity__c = Opportunityobj122.id);
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listofoppCharge22 = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        listofoppCharge22.add(Opportunityrateplanchargeobj122);
        
        insert listofoppCharge22;        
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',Opportunityobj122.id);
        ApexPages.StandardController stdobj1 =new ApexPages.StandardController(Opportunityobj122);
        AddingOpptChargeExten2Duplicate AddingOpptChargeExten2obj= new AddingOpptChargeExten2Duplicate(stdobj1);
        AddingOpptChargeExten2obj.onChangeCountry(); 
        AddingOpptChargeExten2obj.quickSave(); 
        AddingOpptChargeExten2obj.next();
        AddingOpptChargeExten2obj.previous();
        AddingOpptChargeExten2obj.last();
        AddingOpptChargeExten2obj.updateChargesList();
        AddingOpptChargeExten2obj.cancel();
        Test.stopTest();
          
    }
    static testMethod void myUnitTest12() {
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();    
        Account account12 = new Account(Name = 'Test Account');
        insert account12;
        
        Contact contact12 =  new Contact(LastName = 'Laxman', AccountId = account12.Id);                                 
        insert contact12;
        Date validtodate12 = Date.today();
        invoiceit_s__Currency__c currencyObj12 = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj12;
        
        invoiceit_s__Product__c product12 = new invoiceit_s__Product__c(Name = 'Test Product for tiers',invoiceit_s__Valid_From_Date__c = validtodate12,invoiceit_s__Valid_To_Date__c = validtodate12.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product');
        insert product12;
        
        list<invoiceit_s__Product_Rate_Plan__c> listProductRatePlans12 = new list<invoiceit_s__Product_Rate_Plan__c>();
        invoiceit_s__Product_Rate_Plan__c productRatePlan12;
        for(Integer x = 0;x< 2;x++){
            productRatePlan12 = new  invoiceit_s__Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,invoiceit_s__Product__c = product12.Id,invoiceit_s__Valid_From_Date__c = validtodate12,invoiceit_s__Valid_To_Date__c = validtodate12.addMonths(2));
            listProductRatePlans12.add(productRatePlan12);
        }
        insert listProductRatePlans12;
        
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges12 = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp12 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj12.Id,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans12[0].Id,
                                                              invoiceit_s__Unit_price__c = 1000,
                                                              invoiceit_s__Cost_Price__c = 500,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'One Time'
                                                              );
        listProductRatePlanCharges12.add(productRatePlanCharge_SetUp12);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly12 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj12.ID,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans12[0].Id,
                                                              invoiceit_s__Unit_price__c = 500,
                                                              invoiceit_s__Cost_Price__c = 250,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'Monthly',
                                                              Package_Component__c = false,
                                                              Package_Wrapper__c = false                                                                  
                                                              );                                                       
        listProductRatePlanCharges12.add(productRatePlanCharge_Monthly12);

        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly123 = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj12.ID,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans12[1].Id,
                                                              invoiceit_s__Unit_price__c = 500,
                                                              invoiceit_s__Cost_Price__c = 250,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'Monthly'
                                                              );                                                       
        listProductRatePlanCharges12.add(productRatePlanCharge_Monthly123);
        insert listProductRatePlanCharges12;
        
        list<Attribute_Config__c> listofAttributeConfig2 = new list<Attribute_Config__c> ();
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Account Name',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Xref Service Account Name',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Street Address',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Street Address',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service City',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service City',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service State',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service State',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Country',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Country',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Zip',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Service Zip',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Date',Attribute_Type__c ='Date' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Boolean',Attribute_Type__c ='Boolean' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Date',Attribute_Type__c ='Date' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Number',Attribute_Type__c ='Number' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Currency',Attribute_Type__c ='Currency' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Language',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Call Tracking',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Call Tracking',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Phone Number Type',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Phone Number Type',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Primary Website',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Primary Website',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Call Firm Now',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Call Firm Now',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Direct Website Link',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Direct Website Link',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Starter Kit',Attribute_Type__c ='Text' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Starter Kit',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Country',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='City',Attribute_Type__c ='Picklist' ));
        listofAttributeConfig2.add(new Attribute_Config__c (Name ='Country',Attribute_Type__c ='Picklist' ));
        
        
        
        
        insert listofAttributeConfig2 ; 
        
           
        list<Product_Charge_Attribute__c> listofproductAttribute12 = new list<Product_Charge_Attribute__c>();
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[0].Id, Attribute_Name__c = 'Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Text',Default_Boolean__c = false , Default_Date__c = system.today(),Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[1].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[2].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[3].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));     
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[4].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[5].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[6].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[7].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[8].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[9].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id)); 
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[10].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[11].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id)); 
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[12].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[13].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[14].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[15].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[16].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[17].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[18].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[19].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[20].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[21].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[22].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[23].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[24].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[25].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[26].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[27].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[28].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[29].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[30].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id));         
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[31].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[2].id));
        listofproductAttribute12.add(new Product_Charge_Attribute__c(AttributeName__c = listofAttributeConfig2[32].Id, Attribute_Name__c = 'Xref Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Picklist',Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[2].id));
        insert listofproductAttribute12;
        
        invoiceit_s__Job__c jobNew2 = new invoiceit_s__Job__c(invoiceit_s__Account__c = account12.id,invoiceit_s__Billing_Contact__c = contact12.Id,
                invoiceit_s__Shipping_Contact__c = contact12.Id,
                invoiceit_s__Number_Of_Terms__c = 24,
                invoiceit_s__CurrencyL__c = currencyObj12.Id,
                invoiceit_s__Start_Date__c = system.today(), 
                invoiceit_s__Service_Activation_Date__c = system.today(), 
                invoiceit_s__Service_End_Date__c = system.today().addMonths(10),
                invoiceit_s__Preferred_Billing_Day__c = '1',invoiceit_s__Status__c = 'Active');
        insert jobNew2;
        invoiceit_s__Job_Product__c jobProduct12 = new invoiceit_s__Job_Product__c (invoiceit_s__Product__c=product12.id,invoiceit_s__Job__c = jobNew2.id);
        insert jobProduct12; 
        invoiceit_s__Job_Rate_Plan__c jobRP12 = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct12.Id);
        insert jobRP12;
        invoiceit_s__Job_Rate_Plan_Charge__c charge212 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP12.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Modify' ,invoiceit_s__Service_Activation_Date__c = validtodate12,invoiceit_s__Order__c =jobNew2.id,Billing_Milestones__c = '30,40,50');
        //insert charge21;
        invoiceit_s__Job_Rate_Plan_Charge__c charge22 = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP12.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,Quote_Type__c = 'Modify' ,invoiceit_s__Service_Activation_Date__c = validtodate12,invoiceit_s__Order__c =jobNew2.id ,invoiceit_s__Product_Rate_Plan_Charge__c =listProductRatePlanCharges12[0].id);
        //insert charge2;
        
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listofCharge2 = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        listofCharge2.add(charge212);
        listofCharge2.add(charge22);
        insert listofCharge2;  
        
        //Product Bundle Creation
        invoiceit_s__Product_Bundle__c prdbundle = MDL_UtilClass_TestClass.createProductBundle('12345',currencyObj12.id);
        insert prdbundle;
        
         //Product Bundle Line Creation
        invoiceit_s__Product_Bundle_Line__c prdbundleline = MDL_UtilClass_TestClass.createproductbundleline(prdbundle.id);
        insert prdbundleline;
        
        
        //Oppt
        
        Opportunity Opportunityobj12 = new Opportunity(AccountId = account12.id , Name ='testoopty',
                                                       StageName ='Declined', CloseDate =system.today(),
                                                       Type='New Business',invoiceit_crmx__Shipping_Contact__c=contact12.Id ,
                                                       invoiceit_crmx__Billing_Contact__c=contact12.Id,
                                                       Auth_By_Contact__c=contact12.Id,
                                                      Created_From_Order__c=jobNew2.id);
        insert Opportunityobj12;
        
        //invoiceit_crmx__Opportunity_Product__c opportunityproductobj12 = util.getOpportunityProduct(product12.Id, Opportunityobj12.Id);
        invoiceit_crmx__Opportunity_Product__c  opportunityproductobj12= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product',invoiceit_crmx__Product_Code__c = '1234', 
                                                                                                                    invoiceit_crmx__SequenceNumber__c =1, invoiceit_crmx__Product__c = product12.Id ,
                                                                                                                    invoiceit_crmx__Opportunity__c = Opportunityobj12.Id,
                                                                                                                   invoiceit_crmx__Product_Bundle__c =prdbundle.id);
        insert opportunityproductobj12;
        //invoiceit_crmx__Opportunity_Product__c opportunityproductobj12= new invoiceit_crmx__Opportunity_Product__c(Name='Product', invoiceit_crmx__SequenceNumber__c=1,invoiceit_crmx__Opportunity__c=Opportunityobj12.Id ,invoiceit_crmx__Product__c = product12.Id);
        //insert opportunityproductobj12;
        
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = util.getProductRatePlan(product12.id);
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opportunityproductrateplanobj12= util.getOpportunityRatePlan(opportunityproductobj12.id, singleprdrpl.Id);
        //invoiceit_crmx__Opportunity_Rate_Plan__c opportunityproductrateplanobj12=new invoiceit_crmx__Opportunity_Rate_Plan__c(Name='Rate plan',invoiceit_crmx__Opportunity_Product__c=opportunityproductobj12.Id );
        //insert opportunityproductrateplanobj12;
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Opportunityrateplanchargeobj12= new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Quote_Type__c = 'New', Name='charge',invoiceit_crmx__Opportunity_Rate_Plan__c=opportunityproductrateplanobj12.Id ,
                                                                                                                                            invoiceit_crmx__Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[0].id,
                                                                                                                                            invoiceit_crmx__Opportunity__c = Opportunityobj12.id,
                                                                                                                                           invoiceit_crmx__Product_Bundle_Line__c = prdbundleline.id
                                                                                                                                          );
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Opportunityrateplanchargeobj121= new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Quote_Type__c = 'New', Name='charge',invoiceit_crmx__Opportunity_Rate_Plan__c=opportunityproductrateplanobj12.Id ,invoiceit_crmx__Product_Rate_Plan_Charge__c = listProductRatePlanCharges12[2].id,invoiceit_crmx__Opportunity__c = Opportunityobj12.id);
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listofoppCharge2 = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        listofoppCharge2.add(Opportunityrateplanchargeobj12);
        listofoppCharge2.add(Opportunityrateplanchargeobj121);
        
        insert listofoppCharge2;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id',Opportunityobj12.id);
        ApexPages.StandardController stdobj1 =new ApexPages.StandardController(Opportunityobj12);
        AddingOpptChargeExten2Duplicate AddingOpptChargeExten2obj= new AddingOpptChargeExten2Duplicate(stdobj1);
        AddingOpptChargeExten2obj.onChangeCountry();        
        AddingOpptChargeExten2obj.quickSave(); 
        AddingOpptChargeExten2obj.next();
        AddingOpptChargeExten2obj.previous();
        AddingOpptChargeExten2obj.last();
        AddingOpptChargeExten2obj.updateChargesList();
        boolean testhasnext = AddingOpptChargeExten2obj.hasNext;
         boolean testhasprevious = AddingOpptChargeExten2obj.hasPrevious;
        boolean testhaserror  = AddingOpptChargeExten2obj.hasError;
        Test.stopTest();
          
    }
    
    static testMethod void myUnitTest123() {        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();    
        Account account = util.getAccount();        
        
        Contact contact = util.getContact(account.Id);
        
        Date validtodate = Date.today();
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj;
        invoiceit_s__Product__c product = new invoiceit_s__Product__c(Name = 'Test Product for tiers',invoiceit_s__Valid_From_Date__c = validtodate,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product',Shippable__c = 'Yes');
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
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Text', Attribute_Name__c  = 'Test', String_Value__c = 'te',Maximum_No_Of_Characters_In_Text__c = 1));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'String', Attribute_Name__c = 'Country', String_Value__c = 'USA'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'String', Attribute_Name__c = 'Xref Country', String_Value__c = 'test'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'String', Attribute_Name__c = 'Xref State', String_Value__c = 'test'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'String', Attribute_Name__c = 'Xref County', Picklist_Value__c = 'test'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'String', Attribute_Name__c = 'Service State', Picklist_Value__c = 'test'));        
        
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
        ApexPages.currentPage().getParameters().put('attributeName', 'Test');
        ApexPages.currentPage().getParameters().put('chargeId', Opportunityrateplanchargeobj.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[0].id);
                
        AddingOpptChargeExten2obj.populatingCountyCityValue();
        
        ApexPages.currentPage().getParameters().put('attributeName', 'Test');
        ApexPages.currentPage().getParameters().put('chargeId', Opportunityrateplanchargeobj.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[1].id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[2].id);
            
        AddingOpptChargeExten2obj.onChangeCountry(); 
        ApexPages.currentPage().getParameters().put('attributeName', 'Test');
        ApexPages.currentPage().getParameters().put('chargeId', Opportunityrateplanchargeobj.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[2].id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOpportunitychargeattributeobj[3].id);
            
        AddingOpptChargeExten2obj.onChangeCountry(); 
        AddingOpptChargeExten2obj.quickSave(); 
        AddingOpptChargeExten2obj.next();
        AddingOpptChargeExten2obj.previous();
        AddingOpptChargeExten2obj.last();

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
                
        test.stopTest();       
       
    }   
    
}