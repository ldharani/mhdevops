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
private class MDL_Test_Ctrl_GenerateQuote {

    static testMethod void testGenQuote() {
        
        Test.Starttest();
        MDL_Ctrl_GenerateQuote testCtrl = new MDL_Ctrl_GenerateQuote();
        Test.Stoptest();
        /*MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        Contact c = testData.getContact(acc.Id);
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        invoiceit_s__Product__c prod = testData.getProduct('false');
        invoiceit_s__Product_Rate_Plan__c pRatePlan = testData.getProductRatePlan(prod.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC = testData.getProductRatePlanCharge(Cur.Id, pRatePlan.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC1 = testData.getProductRatePlanCharge(Cur.Id, pRatePlan.Id);
        pRPC1.invoiceit_s__Price_Type__c = 'One Time';
        insert pRPC1;
        Opportunity opp = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        invoiceit_crmx__Opportunity_Product__c oppProd = testData.getOpportunityProduct(Prod.Id, opp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = testData.getOpportunityRatePlan(oppProd.Id, pRatePlan.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC = testData.getOppRatePlanCharge(OppRatePlan.Id, pRPC.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC1 = testData.getOppRatePlanCharge(OppRatePlan.Id, pRPC1.Id);
        oRPC.invoiceit_crmx__Net_Total__c = 122.22;
        update oRPC;
        oRPC1.invoiceit_crmx__Net_Total__c = 222.12;
        update oRPC1;
        invoiceit_s__Quote__c quote = testData.getQuote(acc.Id, opp.Id, c.Id, cur.Id);
        ApexPAges.StandardController sc = new ApexPages.StandardController(quote);
        ApexPages.currentPage().getParameters().put('id',quote.Id);
        MDL_Ctrl_GenerateQuote genQuote = new MDL_Ctrl_GenerateQuote(sc);*/
    }
}