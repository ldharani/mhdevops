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
private class MDL_Test_TriggerOnPaymentAlloc {

    static testMethod void testTrgPayAlloc() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        invoiceit_s__Job__c ord = testData.getOrder(acc.Id, Cur.Id);
        invoiceit_s__Payment__c pay = testData.getPayment(acc.Id, cur.Id);
        invoiceit_s__Invoice__c inv = testData.getInvoice(acc.Id);
        invoiceit_s__Invoice_Lines__c invLines = testData.getInvoiceLines(inv.Id, ord.Id);
        invoiceit_s__Payment_Allocation__c payAlloc = testData.getPaymentAlloc(pay.Id, inv.Id);
    }
}