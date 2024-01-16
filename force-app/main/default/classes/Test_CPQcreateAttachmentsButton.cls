@isTest
public class Test_CPQcreateAttachmentsButton {

    @isTest
    public static void testMethod1(){
        
        blng__InvoiceRun__c invoicerun = new blng__InvoiceRun__c ();
        invoicerun.blng__TargetDate__c = System.Today();
        insert invoicerun;
        CPQcreateAttachmentsButton.CPQcreateAttachments(invoicerun.Id,false);
    }
}