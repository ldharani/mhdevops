// Author           : Sushmidha
// Description      : Test class for CPQ_BatchesRunController

@isTest
public class Test_CPQ_BatchesRunController {
        static testmethod void testRun1(){
        
         Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount(); 
        acc.Name ='testtInvStatus';
        acc.Credit_Status__c ='Good Standing';
        acc.Finance_Class__c = 'Elite';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('JV Account').getRecordTypeId();
        update acc;
         
         blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = acc.Id;
        pmRec.blng__PaymentType__c = 'ACH';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.blng__BankAccountType__c = 'Checking';
        pmRec.blng__BankName__c ='US Bank';
        pmRec.blng__BankAccountName__c = 'US Bank';
        pmRec.blng__BankRoutingCode__c = '122105155';
        pmRec.blng__BankAccountNumber__c = '123456';
        pmRec.blng__BillingFirstName__c='John';
        pmRec.blng__BillingLastName__c='Matt';
        pmRec.blng__BillingEmail__c='test@testgmail.com';
        insert pmRec;
         
        System.debug(acc.RecordTypeId);
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        
        
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
        
        blng__Invoice__c invoice = util.getInvoice(acc.Id);
        
        
        blng__InvoiceLine__c invLines = util.getInvoiceLines(invoice.Id, Ord.Id);
        system.debug(invLines.blng__TotalAmount__c+'invLines'+invLines.blng__TotalAmount__c);
        blng__InvoiceLine__c invLines1 = util.getInvoiceLines(invoice.Id, Ord.Id);
        system.debug('invLines11'+invLines1);
        
        
        
        CPQ_BatchesRunController classinstance = new CPQ_BatchesRunController(); 
        List<CPQ_BatchesRunController.classWrapp> wrapp = new List<CPQ_BatchesRunController.classWrapp>();
        wrapp = classinstance.getClassNames();
        
        //making checkboxes true here
        for(CPQ_BatchesRunController.classWrapp singlewrap : wrapp){
            singlewrap.selected = true;
        }
        
        Test.startTest();
        classinstance.processSelected();
        classinstance.ok();
        CPQ_CreateNewPayments batch = new CPQ_CreateNewPayments('MH_Invoice');
        Database.executebatch(batch);
        Test.stopTest();
        
    }
}