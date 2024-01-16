@isTest
public class Test_CreditNoteLineTriggerHelper {
    
    @isTest
    public static void testMethod1(){
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc =  util.getAccount();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        blng__CreditNote__c creditNote = new blng__CreditNote__c();
        creditNote.Credit_Reason__c = 'Already Retained';
        creditNote.blng__Account__c = acc.Id;
        creditNote.blng__CreditNoteDate__c = Date.today();
        creditNote.Approved_Amount__c = 400.00;
        creditNote.RecordTypeId = Schema.SObjectType.blng__CreditNote__c.getRecordTypeInfosByName().get('M-A Intake Credit Note').getRecordTypeId();            
        insert creditNote;
        
        blng__CreditNote__c creditNote1 = new blng__CreditNote__c();
        creditNote1.Credit_Reason__c = 'Billing Incorrect';
        creditNote1.blng__Account__c = acc.Id;
        creditNote1.blng__CreditNoteDate__c = Date.today();
        creditNote1.Approved_Amount__c = 200.00;
        insert creditNote1;
        
        List<blng__CreditNoteLine__c> cnLines = new List<blng__CreditNoteLine__c>();
        
        blng__CreditNoteLine__c credtNoteLine = new blng__CreditNoteLine__c();
        credtNoteLine.blng__Product__c = lstProd[0].Id;
        credtNoteLine.blng__CreditNote__c = creditNote1.Id;
        credtNoteLine.blng__Subtotal__c = 200.00;
        
        blng__CreditNoteLine__c credNoteLine1 = new blng__CreditNoteLine__c();
        credNoteLine1.blng__Product__c = lstProd[0].Id;
        credNoteLine1.blng__CreditNote__c = creditNote.Id;
        credNoteLine1.blng__Subtotal__c = 400.00;
        credNoteLine1.RecordTypeId = Schema.SObjectType.blng__CreditNoteLine__c.getRecordTypeInfosByName().get('M-A Intake Credit Note Lines').getRecordTypeId();            
        
        cnLines.add(credtNoteLine);
        cnLines.add(credNoteLine1);
        
        Test.startTest();
        insert cnLines;
        Test.stopTest();
        
        
    }

}