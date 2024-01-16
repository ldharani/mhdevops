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
@isTest(seealldata=true)
private class TestAddingOrderChargeAttributeExtension {

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

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100,invoiceit_s__Product_Rate_Plan_Charge__c= listProductRatePlanCharges[0].id);
        insert charge;
        
        
        
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
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Service City', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Service City', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Xref Country', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te',PickList_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Xref Country', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Xref State', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te',PickList_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Xref State', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'tebbbb',PickList_Value__c = 'tebbbb'));
        
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Xref County', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te',PickList_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Xref County', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'tebbbb',PickList_Value__c = 'tebbbb'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text',Attribute_Name__c='Xref City', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te',PickList_Value__c = 'te'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='Xref City', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'tebbbb',PickList_Value__c = 'tebbbb'));
         
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist',Attribute_Name__c='test', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'te',Attribute_Picklist_Values__c='test1,test2,test3'));
        insert listofOrderchargeattributeobj;
        
        State_County__c stateobj= new State_County__c(City__c='Test',County__c='1',State__c='Karnataka');
        insert stateobj;
        
        
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdorder=new ApexPages.StandardController(job);
        AddingOrderChargeAttributeExtension AddingOrderChargeAttributeExtensionobj=new AddingOrderChargeAttributeExtension(stdorder);
        AddingOrderChargeAttributeExtensionobj.save();
        ApexPages.currentPage().getParameters().put('id',charge.Id);
        AddingOrderChargeAttributeExtensionobj.populatingCountyCityValue();
        AddingOrderChargeAttributeExtensionobj.onChangeCountry();
         ApexPages.currentPage().getParameters().put('selectValue', listofOrderchargeattributeobj[0].id);
         
          ApexPages.currentPage().getParameters().put('chargeId', charge.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOrderchargeattributeobj[1].id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOrderchargeattributeobj[2].id);
        
        AddingOrderChargeAttributeExtensionobj.populatingCountyCityValue();
        
         ApexPages.currentPage().getParameters().put('chargeId', charge.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOrderchargeattributeobj[2].id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOrderchargeattributeobj[3].id);
         
        AddingOrderChargeAttributeExtensionobj.onChangeCountry();
        ApexPages.currentPage().getParameters().put('chargeId', charge.Id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOrderchargeattributeobj[4].id);
        ApexPages.currentPage().getParameters().put('selectValue', listofOrderchargeattributeobj[5].id);
        
         AddingOrderChargeAttributeExtensionobj.next();
         AddingOrderChargeAttributeExtensionobj.quickSave();
         AddingOrderChargeAttributeExtensionobj.previous();
        AddingOrderChargeAttributeExtensionobj.first();
         AddingOrderChargeAttributeExtensionobj.last();
         boolean val1 =AddingOrderChargeAttributeExtensionobj.hasNext;
        boolean val2= AddingOrderChargeAttributeExtensionobj.hasPrevious;
        
  
    }
}