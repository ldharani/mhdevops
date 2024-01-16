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
private class TestClassForDefineChargesValiditynew {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
           Account account = new Account(Name = 'Test Account for ClassForDefineChargesValiditynew');
        insert account;
        
        Contact contact =  new Contact(LastName = 'Laxman', AccountId = account.Id);                                 
        insert contact;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '�1');
        insert currencyObj;   
        invoiceit_s__Product__c product = new  invoiceit_s__Product__c(Name = 'Test Product', invoiceit_s__Valid_From_Date__c = system.today() - 100,invoiceit_s__Valid_To_Date__c = system.today() + 100,invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product');
        insert product;
        
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

        invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
        insert jobRP;

        invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Accounting_Code__c = '12345',invoiceit_s__Unit_Price__c = 12,invoiceit_s__Profit__c = 10,invoiceit_s__Cost__c = 100,invoiceit_s__Cost_Price__c = 150,invoiceit_s__Tax__c = 20,invoiceit_s__VAT__c = 10,invoiceit_s__Discount_Value__c = 1,invoiceit_s__Net_Total__c = 50,invoiceit_s__Price__c = 100);
        insert charge;
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Order_Charge_Attribute__c' LIMIT 1];
        
        
        list<Order_Charge_Attribute__c> listofOrderchargeattributeobj= new list<Order_Charge_Attribute__c>(); 
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'State', Picklist_Value__c = 'test'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'County', Picklist_Value__c = 'test'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'City', Picklist_Value__c = 'test'));
        listofOrderchargeattributeobj.add(new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c=charge.Id, Attribute_Type__c = 'Text', Maximum_No_Of_Characters_In_Text__c = 3, String_Value__c = 'test'));
       insert listofOrderchargeattributeobj;
        
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdobj=new ApexPages.StandardController(job);
        ClassForDefineChargesValiditynew ClassForDefineChargesValiditynewobj = new ClassForDefineChargesValiditynew(stdobj);
        ClassForDefineChargesValiditynew.InnerClassORPC innerClass = new ClassForDefineChargesValiditynew.InnerClassORPC();
        ClassForDefineChargesValiditynewobj.getvalues();
        ClassForDefineChargesValiditynewobj.changeValue();
        
        
        Apexpages.currentpage().getParameters().put('ChargeId',charge.Id );
        ClassForDefineChargesValiditynewobj.navigatingCharge();
        
        ClassForDefineChargesValiditynewobj.save();

        ClassForDefineChargesValiditynewobj.value = 'Extend';
        ClassForDefineChargesValiditynewobj.value = Null;
        ClassForDefineChargesValiditynewobj.value = 'Cancel';
        ClassForDefineChargesValiditynewobj.fetchORPC();
        ClassForDefineChargesValiditynewobj.save();          
        ClassForDefineChargesValiditynewobj.cancel();
        
        ApexPages.currentPage().getParameters().put('id',job.Id);
        ApexPages.StandardController stdobj1=new ApexPages.StandardController(job);
        ClassForDefineChargesValidity ClassForDefineChargesValidityobj=new ClassForDefineChargesValidity(stdobj1);
        ClassForDefineChargesValidityobj.getvalues();
        ClassForDefineChargesValidityobj.changeValue();
        

        ClassForDefineChargesValidityobj.value='Extend';
        ClassForDefineChargesValidityobj.value=Null;
        ClassForDefineChargesValidityobj.value='Cancel';
        ClassForDefineChargesValidityobj.fetchORPC();
        ClassForDefineChargesValidityobj.save();
        ClassForDefineChargesValidityobj.cancel();
       
        
        }
}