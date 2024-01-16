// Author           : Sushmidha
// Description      : Test class for CPQ_BatchCreditValdnAft5Days

@isTest
public class Test_CPQ_BatchCreditValdnAft5Days {
    
    static testmethod void testRun1(){
        Account acc = new Account();
        acc.Name = 'testAcc' ; 
        acc.Phone='122-34345-654';
        insert acc; 
        
        Product2 prd= new Product2();
        prd.name='Professional Profile';
        prd.productcode='123';
        insert prd;
        
        blng__Invoice__c Inv= new blng__Invoice__c();
        Inv.blng__Account__c = acc.Id;
        insert Inv;
        
        blng__InvoiceLine__c invline = new blng__InvoiceLine__c();
        invline.blng__Product__c=prd.Id;
        invline.blng__Invoice__c = inv.Id;
        invline.blng__Quantity__c=1;   
        invline.blng__TotalAmount__c=10; 
        invline.blng__Subtotal__c=10; 
        invline.blng__TaxAmount__c=2; 
        insert invline;
        
        Inv.Credit_Reason__c = 'Write-off'; 
        Inv.Approval_status__c = 'Pending Approval';
        Inv.Approval_submission_date__c = System.today();
        Inv.Credit_Status__c = 'Initiated';
        Inv.Sub_Reason__c = 'Agency Fees';
        Inv.Amt_to_be_credited__c = 1;
        Inv.Approval_submission_date__c = System.today();
        Update Inv;
        
        blng__Invoice__c InvAA = [SELECT ID, Amt_to_be_credited__c , blng__TotalAmount__c FROM blng__Invoice__c];
        System.debug('aaza' + InvAA.Amt_to_be_credited__c + ' ' + InvAA.blng__TotalAmount__c);
        
        
        Test.startTest();
        
        CPQ_BatchCreditValdnAft5Days obj = new CPQ_BatchCreditValdnAft5Days();
        DataBase.executeBatch(obj); 
        obj.getDiffBusinessDays(System.today() , System.today().adddays(10));
        
        Test.stopTest();
    }
    static testmethod void testRun2(){
        Account acc = new Account();
        acc.Name = 'testAcc' ; 
        acc.Phone='122-34345-654';
        insert acc; 
        
        Product2 prd= new Product2();
        prd.name='Professional Profile';
        prd.productcode='123';
        insert prd;
        
        blng__Invoice__c Inv= new blng__Invoice__c();
        Inv.blng__Account__c = acc.Id;
        insert Inv;
        
        blng__InvoiceLine__c invline = new blng__InvoiceLine__c();
        invline.blng__Product__c=prd.Id;
        invline.blng__Invoice__c = inv.Id;
        invline.blng__Quantity__c=1;   
        invline.blng__TotalAmount__c=10; 
        invline.blng__Subtotal__c=10; 
        invline.blng__TaxAmount__c=2; 
        insert invline;
        
        Inv.Credit_Reason__c = 'Write-off'; 
        Inv.Approval_status__c = 'Pending Approval';
        Inv.Approval_submission_date__c = System.today();
        Inv.Credit_Status__c = 'Initiated';
        Inv.Sub_Reason__c = 'Agency Fees';
        Inv.Amt_to_be_credited__c = 1;
        Inv.Approval_submission_date__c = System.today();
        Update Inv;
        
        blng__Invoice__c InvAA = [SELECT ID, Amt_to_be_credited__c , blng__TotalAmount__c FROM blng__Invoice__c];
        System.debug('aaza' + InvAA.Amt_to_be_credited__c + ' ' + InvAA.blng__TotalAmount__c);
        
        
        Test.startTest();
        
        CPQ_BatchCreditValdnAft5Days obj = new CPQ_BatchCreditValdnAft5Days();
        DataBase.executeBatch(obj); 
        obj.getDiffBusinessDays(System.today().adddays(10) , System.today());
        
        Test.stopTest();
    }
    static testmethod void testRun3(){
        Account acc = new Account();
        acc.Name = 'testAcc' ; 
        acc.Phone='122-34345-777';
        insert acc; 
        
        Product2 prd= new Product2();
        prd.name='Professional Profile';
        prd.productcode='123';
        insert prd;
        
        blng__Invoice__c Inv= new blng__Invoice__c();
        Inv.blng__Account__c = acc.Id;
        Inv.Historical_SFDC_ID__c = 'ABC';
        insert Inv;
        
        blng__InvoiceLine__c invline = new blng__InvoiceLine__c();
        invline.blng__Product__c=prd.Id;
        invline.blng__Invoice__c = inv.Id;
        invline.blng__Quantity__c=1;   
        invline.blng__TotalAmount__c=10; 
        invline.blng__Subtotal__c=10; 
        invline.blng__TaxAmount__c=2; 
        insert invline;
        
        Inv.Credit_Reason__c = 'Write-off'; 
        Inv.Approval_status__c = 'Pending Approval';
        Inv.Approval_submission_date__c = System.today();
        Inv.Credit_Status__c = 'Initiated';
        Inv.Sub_Reason__c = 'Agency Fees';
        Inv.Amt_to_be_credited__c = 1;
        Inv.Approval_submission_date__c = System.today();
        Update Inv;
        
        blng__Invoice__c InvAA = [SELECT ID, Amt_to_be_credited__c , blng__TotalAmount__c FROM blng__Invoice__c];
        System.debug('aaza' + InvAA.Amt_to_be_credited__c + ' ' + InvAA.blng__TotalAmount__c);
        
        
        Test.startTest();
        
        CPQ_BatchCreditValdnAft5Days obj = new CPQ_BatchCreditValdnAft5Days();
        DataBase.executeBatch(obj); 
        obj.getDiffBusinessDays(System.today().addmonths(100) , System.today());
        String sch = '0 0 23 * * ?';
        system.schedule('Test check'+Date.today(), sch, new CPQ_ScheduleCreditValdnAft5Days());
        
        Test.stopTest();
    }
}