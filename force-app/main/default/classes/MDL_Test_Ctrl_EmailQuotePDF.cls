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
@isTest(seeAllData=true)
private class MDL_Test_Ctrl_EmailQuotePDF {

    static testMethod void myUnitTest() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        Contact c = testData.getContact(acc.Id);
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        Opportunity opp = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        
        //creating single product
        invoiceit_s__Product__c singleproduct = testData.getProduct('true');
        
         //creating single product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = testData.getProductRatePlan(singleproduct.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c singleoppProd = testData.getOpportunityProduct(singleproduct.id, opp.Id);
        singleoppProd.Product_SIN__c = 'test';
        singleoppProd.InventoryId__c = 'test';
        update singleoppProd;
        
        invoiceit_crmx__Opportunity_Product__c singleoppProd1 = testData.getOpportunityProduct(singleproduct.id, opp.Id);
        singleoppProd1.InventoryId__c = 'test';
        update singleoppProd1;
        
        //creating single opp rate plan 
        invoiceit_crmx__Opportunity_Rate_Plan__c singleopprpl = testData.getOpportunityRatePlan(singleoppProd.id, singleprdrpl.id);
        
        //creating sigle prod rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singleprodrpc = testData.getProductRatePlanCharge(cur.id, singleprdrpl.id);
        insert singleprodrpc;
        
        //creating single opp rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c singlerpc = testData.getOppRatePlanCharge(singleopprpl.id, singleprodrpc.id);
        singlerpc.invoiceit_crmx__Price__c = 100;
        singlerpc.invoiceit_crmx__Discount_Value__c = 10;
        singlerpc.invoiceit_crmx__VAT__c = 10;
        singlerpc.invoiceit_crmx__Tax__c = 10;
        singlerpc.invoiceit_crmx__Price_Type__c = 'Monthly';
        singlerpc.Quote_Type__c = 'Modify';
        singlerpc.invoiceit_crmx__Net_Total__c = 10;
        singlerpc.Terms_Months__c = 10;
        update singlerpc;
        
        invoiceit_s__Quote__c q = testData.getQuote(acc.Id, opp.Id, c.Id, cur.Id);
        ApexPAges.StandardController sc = new ApexPages.StandardController(q);
        MDL_Ctrl_EmailQuotePDF eQuote = new MDL_Ctrl_EmailQuotePDF(sc);
        ApexPages.currentPage().getParameters().put('id',q.Id);
        Pagereference pr1 = eQuote.sendEmail();
        Pagereference pr2 = eQuote.returnToOpp();
        c.Email = 'venkatesan.lister@gmail.com';
        update c;
        Pagereference pr3 = eQuote.sendEmail();        
        Pagereference pr4 = eQuote.returnToOpp();
    }
    static testMethod void myUnitTest1() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        Contact c = testData.getContact(acc.Id);
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        Opportunity opp = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        
        //creating single product
        invoiceit_s__Product__c singleproduct = testData.getProduct('true');
        
         //creating single product rate plan
        invoiceit_s__Product_Rate_Plan__c singleprdrpl = testData.getProductRatePlan(singleproduct.id);
        
        //creating single opp Product
        invoiceit_crmx__Opportunity_Product__c singleoppProd = testData.getOpportunityProduct(singleproduct.id, opp.Id);
        singleoppProd.Product_SIN__c = 'test';
        singleoppProd.InventoryId__c = 'test';
        update singleoppProd;
        
        invoiceit_crmx__Opportunity_Product__c singleoppProd1 = testData.getOpportunityProduct(singleproduct.id, opp.Id);
        singleoppProd1.InventoryId__c = 'test';
        update singleoppProd1;
        
        //creating single opp rate plan 
        invoiceit_crmx__Opportunity_Rate_Plan__c singleopprpl = testData.getOpportunityRatePlan(singleoppProd.id, singleprdrpl.id);
        
        //creating sigle prod rate plan charge
        invoiceit_s__Product_Rate_Plan_Charge__c singleprodrpc = testData.getProductRatePlanCharge(cur.id, singleprdrpl.id);
        insert singleprodrpc;
        
        //creating single opp rate plan charge
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c singlerpc = testData.getOppRatePlanCharge(singleopprpl.id, singleprodrpc.id);
        singlerpc.invoiceit_crmx__Price__c = 100;
        singlerpc.invoiceit_crmx__Discount_Value__c = 10;
        singlerpc.invoiceit_crmx__VAT__c = 10;
        singlerpc.invoiceit_crmx__Tax__c = 10;
        singlerpc.invoiceit_crmx__Price_Type__c = 'One Time';
        singlerpc.Quote_Type__c = 'Modify';
        singlerpc.invoiceit_crmx__Net_Total__c = 10;
        singlerpc.Terms_Months__c = 1;
        update singlerpc;
        
        invoiceit_s__Quote__c q = testData.getQuote(acc.Id, opp.Id, c.Id, cur.Id);
        ApexPAges.StandardController sc = new ApexPages.StandardController(q);
        MDL_Ctrl_EmailQuotePDF eQuote = new MDL_Ctrl_EmailQuotePDF(sc);
        ApexPages.currentPage().getParameters().put('id',q.Id);
        Pagereference pr1 = eQuote.sendEmail();
        Pagereference pr2 = eQuote.returnToOpp();
        c.Email = 'venkatesan.lister@gmail.com';
        update c; 
        
        Pagereference pr3 = eQuote.sendEmail();        
        Pagereference pr4 = eQuote.returnToOpp();        
       
    }
}