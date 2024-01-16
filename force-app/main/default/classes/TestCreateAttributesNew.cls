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
private class TestCreateAttributesNew {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
       Account accountObj = new Account(Name='TestHappyOrNotAccount',BillingCity='Bangalore');
        insert accountObj;
        Date validtodate = Date.today();
        Contact contact = new Contact(lastname = 'testCon1',AccountId=accountObj.Id);
        insert contact;
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj;
        invoiceit_s__Product__c product = new invoiceit_s__Product__c(Name = 'Test Product for tiers',invoiceit_s__Valid_From_Date__c = validtodate,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product');
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
        
        Product_Charge_Attribute__c chargeattribute= new Product_Charge_Attribute__c (Attribute_Name__c='AOP',Default_Currency__c='USD',Product_Rate_Plan_Charge__c=productRatePlanCharge_Monthly.Id);
        insert chargeattribute;
        
        Attribute_Config__c attributeconfig= new Attribute_Config__c(Name='Test',Attribute_Type__c ='Text');
        insert attributeconfig; 
        
        ApexPages.currentPage().getParameters().put('id',productRatePlanCharge_Monthly.Id);
        ApexPages.StandardController stdtest=new ApexPages.StandardController(productRatePlanCharge_Monthly);
        CreateAttributesNew CreateAttributesNewobj= new CreateAttributesNew(stdtest);
        
      
        
        
        
        ApexPages.CurrentPage().getParameters().put('attributeId',chargeattribute.Id);
        ApexPages.CurrentPage().getParameters().put('counter','0');
        ApexPages.CurrentPage().getParameters().put('attributeId',attributeconfig.Id);
        CreateAttributesNewobj.populateDefaultValues();
        
        CreateAttributesNewobj.addingProductChargeAttribute();
        Apexpages.currentPage().getParameters().put('counterparameter','0');
        CreateAttributesNewobj.removingAttribute();
        CreateAttributesNewobj.savingAttribute();
        
        
    }
}