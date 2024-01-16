@isTest(seealldata=true)
private class TestAddingOrderChargeAttributeExt2 {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
                   Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contact contact =  new Contact(LastName = 'Laxman', AccountId = account.Id);                                 
        insert contact;
        Date validtodate = Date.today();
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '£1');
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
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        GEO_Location__c  geo = util.getGeolocation('TE','TE','TE', 'TE');
        geo.Country_Inv_Flag__c ='Yes';
        geo.State_Inv_Flag__c = 'Yes';
        geo.recordTypeid= Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        update geo;
        system.debug('---geoooooo--'+geo.address_String__c);
        system.assert(geo.id != null);
       
        
        
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
        Product_Charge_Attribute__c  productAttribute =  new Product_Charge_Attribute__c(AttributeName__c = attributeConfug.id ,Attribute_Name__c = 'Text',Attribute_Order__c = 1,Attribute_Type__c = 'String',Default_Boolean__c = false , Default_Date__c = system.today());       
        listofproductAttribute.add(productAttribute);
        listofproductAttribute.add(new Product_Charge_Attribute__c(AttributeName__c = attributeConfug.id ,Attribute_Name__c = 'Service Account Name',Attribute_Order__c = 1,Attribute_Type__c = 'Text',Default_Boolean__c = false , Default_Date__c = system.today()));
        insert listofproductAttribute;
        
        invoiceit_s__Job__c job = new invoiceit_s__Job__c(Name = 'Test Job', 
                invoiceit_s__Account__c = account.Id,
                invoiceit_s__Billing_Contact__c = contact.Id,
                invoiceit_s__Shipping_Contact__c = contact.Id,
                invoiceit_s__Number_Of_Terms__c = 24,
                invoiceit_s__CurrencyL__c = currencyObj.Id,
                invoiceit_s__Start_Date__c = system.today(), 
                invoiceit_s__Service_Activation_Date__c = system.today(), 
                invoiceit_s__Service_End_Date__c = system.today().addMonths(10),
                invoiceit_s__Preferred_Billing_Day__c = '1'
        );
        insert job;
        
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = job.Id,invoiceit_s__Product__c = product.Id);
        insert jobProduct;

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id,invoiceit_s__Product_Rate_Plan__c = listProductRatePlans[0].id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'Preferred City Results - Unit 1',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,invoiceit_s__Product_Rate_Plan_Charge__c= listProductRatePlanCharges[0].id);
        insert charge;
        
        
        /*
        list<Order_Charge_Attribute__c> listofOrderchargeattributeobj= new list<Order_Charge_Attribute__c>(); 
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'State', Picklist_Value__c = 'test'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'County', Picklist_Value__c = 'test'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'City', Picklist_Value__c = 'test'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text', Attribute_Name__c='Country',Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Country', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text', Attribute_Name__c='State',Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='State', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Service Country', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Service Country', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Service State', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Service State', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Xref Country', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Xref Country', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Xref State', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Xref State', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'tebbbb'));
        
        
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='test', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te',Attribute_Picklist_Values__c='test1,test2,test3'));
        insert listofOrderchargeattributeobj;*/
        
        //creating orderCharge Attributes
        Order_Charge_Attribute__c serviceCountry                    = util.getOrderChargeAttributes(charge.id, 'Text', 'Service Country', 'TestUSA');
        Order_Charge_Attribute__c serviceState                      = util.getOrderChargeAttributes(charge.id, 'Picklist', 'Service State', 'TestNC');
        Order_Charge_Attribute__c serviceCounty                     = util.getOrderChargeAttributes(charge.id, 'Picklist', 'County', 'TestCounty');
        Order_Charge_Attribute__c serviceCounty2                    = util.getOrderChargeAttributes(charge.id, 'Text', 'County', 'TestCounty');
        Order_Charge_Attribute__c serviceCity                       = util.getOrderChargeAttributes(charge.id, 'Text', 'Service City', 'TestBoston');
        Order_Charge_Attribute__c xrefCountry                       = util.getOrderChargeAttributes(charge.id, 'Text', 'Xref Country', 'TestUSA');
        Order_Charge_Attribute__c xrefState                         = util.getOrderChargeAttributes(charge.id, 'Picklist', 'Xref State', 'TestNC');
        Order_Charge_Attribute__c xrefCity                          = util.getOrderChargeAttributes(charge.id, 'Text', 'Xref City', 'TestBoston');
        Order_Charge_Attribute__c country                           = util.getOrderChargeAttributes(charge.id, 'Text', 'Country', 'TestUSA');
        Order_Charge_Attribute__c state                             = util.getOrderChargeAttributes(charge.id, 'Picklist', 'State', 'TestNC');
        Order_Charge_Attribute__c city                              = util.getOrderChargeAttributes(charge.id, 'Text', 'City', 'TestBoston');
        //Order_Charge_Attribute__c oppCharges                        = util.getOrderCharges(charge.Id, 'Text', 'AOP');
        
        //creating geo location record
        Geo_location__c geo1                                         = util.getGeolocation('TestUSA','TestNC','','TestBoston');
        geo.recordTypeid= Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        update geo1;
        
        //creating geo location record for inv
        Geo_location__c geo2                                         = util.getGeolocation('TestUSA','TestNC','','TestBoston');
        geo2.recordTypeid= Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo2.Country_Inv_Flag__c  = 'Yes';
        geo2.State_Inv_Flag__c    = 'Yes';
        geo2.City_Inv_Flag__c     = 'Yes';
        update geo2;
        
        State_County__c stateobj= new State_County__c(City__c='Test',County__c='1',State__c='Karnataka');
        insert stateobj;
        
        
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj=new AddingOrderChargeAttributeExtension2(stdorder);
        AddingOrderChargeAttributeExtensionobj.save();
        
        Test.startTest();
        //service country error
        serviceCountry.String_Value__c = 'Test1';
        update serviceCountry;
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder1=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj1=new AddingOrderChargeAttributeExtension2(stdorder1);
         AddingOrderChargeAttributeExtensionobj1.save();
        
        List<Order_Charge_Attribute__c> tempList = new List<Order_Charge_Attribute__c>();
        //service state error
        serviceCountry.String_Value__c = 'TestUSA';
        tempList.add(serviceCountry);
        serviceState.Picklist_Value__c = 'Test1';
         tempList.add(serviceState);
         update tempList;
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder2=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj2=new AddingOrderChargeAttributeExtension2(stdorder1);
         AddingOrderChargeAttributeExtensionobj2.save();
        
        
         tempList = new List<Order_Charge_Attribute__c>();
        //service city error
        serviceCountry.String_Value__c = 'TestUSA';
        tempList.add(serviceCountry);
        serviceState.Picklist_Value__c = 'TestNC';
         tempList.add(serviceState);
        serviceCity.String_Value__c = 'Test1';
         tempList.add(serviceCity);
         update tempList;
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder3=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj3=new AddingOrderChargeAttributeExtension2(stdorder3);
         AddingOrderChargeAttributeExtensionobj3.save();
        
        //xref country error
         tempList = new List<Order_Charge_Attribute__c>();
         serviceCity.String_Value__c = 'TestBoston';
         tempList.add(serviceCity);
        xrefCountry.String_Value__c = 'Test1';
        tempList.add(xrefCountry);
         update tempList;
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder4=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj4=new AddingOrderChargeAttributeExtension2(stdorder4);
         AddingOrderChargeAttributeExtensionobj4.save();
        
        
        //xref State error
         tempList = new List<Order_Charge_Attribute__c>();
         xrefCountry.String_Value__c = 'TestUSA';
        tempList.add(xrefCountry);
        xrefState.Picklist_Value__c = 'Test1';
         tempList.add(xrefState);
         update tempList;
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder5=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj5=new AddingOrderChargeAttributeExtension2(stdorder5);
         AddingOrderChargeAttributeExtensionobj5.save();
        
         //xref city error
         tempList = new List<Order_Charge_Attribute__c>();
        xrefState.Picklist_Value__c = 'TestNC';
         tempList.add(xrefState);
        xrefCity.String_Value__c = 'Test1';
        tempList.add(xrefCity);
         update tempList;
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder6=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj6=new AddingOrderChargeAttributeExtension2(stdorder6);
         AddingOrderChargeAttributeExtensionobj6.save();
        
        
         //country error
         tempList = new List<Order_Charge_Attribute__c>();
         xrefCity.String_Value__c = 'TestBoston';
        tempList.add(xrefCity);
        country.String_Value__c  = 'Test1';
        tempList.add(country);
         update tempList;
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder7=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj7=new AddingOrderChargeAttributeExtension2(stdorder7);
         AddingOrderChargeAttributeExtensionobj7.save();
        
        
        //State error
         tempList = new List<Order_Charge_Attribute__c>();
         country.String_Value__c  = 'TestUSA';
        tempList.add(country);
        state.Picklist_Value__c = 'Test1';
         tempList.add(state);
         update tempList;
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder8=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension2 AddingOrderChargeAttributeExtensionobj8=new AddingOrderChargeAttributeExtension2(stdorder8);
         AddingOrderChargeAttributeExtensionobj8.save();
        
        
        
         AddingOrderChargeAttributeExtensionobj.next();
         AddingOrderChargeAttributeExtensionobj.quickSave();
         AddingOrderChargeAttributeExtensionobj.previous();
        AddingOrderChargeAttributeExtensionobj.first();
         AddingOrderChargeAttributeExtensionobj.last();
         boolean val1 =AddingOrderChargeAttributeExtensionobj.hasNext;
        boolean val2= AddingOrderChargeAttributeExtensionobj.hasPrevious;
        Test.stopTest();
        
  
    }
}