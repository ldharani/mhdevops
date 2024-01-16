@isTest
public class Test_ValidateCreditAmt_Cntrl {
   
    static testmethod void testRun1(){
         
        
    
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount(); 
        acc.Name ='testtInvStatus';
        acc.Credit_Status__c ='Good Standing';
        acc.Finance_Class__c = 'Elite';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('JV Account').getRecordTypeId();
        update acc;
         
        System.debug(acc.RecordTypeId);
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
         
         blng__Invoice__c invoice = util.getInvoice(acc.Id);
         invoice.blng__InvoiceStatus__c = 'Posted';
         update invoice;
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';   
        ord.EffectiveDate = Date.today();
        insert ord;
        
        Order ord2 = new Order();
        ord2.Name = 'Test Order';
        ord2.AccountId = acc.Id;
        ord2.Status = 'Draft';   
        ord2.EffectiveDate = Date.today();
        insert ord2;
        
        blng__InvoiceLine__c invLines = util.getInvoiceLines(invoice.Id, Ord.Id);
        blng__InvoiceLine__c invLines1 = util.getInvoiceLines(invoice.Id, Ord.Id);
         
        Test.startTest();
        ValidateCreditAmt_Cntrl.getRecordtypeName(invoice.Id);
        ValidateCreditAmt_Cntrl.getRecTypeId(invoice.ID);
        Test.stopTest();
     }
}