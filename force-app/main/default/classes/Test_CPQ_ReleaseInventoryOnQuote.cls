@isTest
public class Test_CPQ_ReleaseInventoryOnQuote {
    
    static testMethod void testMwthod1() {
        
       Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc =  util.getAccount();
        Contact con = util.getContact(acc.Id);
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=acc.Id;
        testopp.StageName='Prospecting';
        testopp.CloseDate = date.today();
        testopp.Marketing_Contact__c = con.Id;
        testopp.Billing_Contact__c = con.Id;
        testopp.Primary_Contact__c = con.Id;
        insert testopp;
        
        Product2  oppprod1 = new Product2(Name = 'Reputation Boost',ProductCode = '12000',IsInventoried__c =true);
        insert oppProd1; 
        
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=acc.Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        insert objquote;
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=oppProd1.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        quoteline.Inventory_Id__c = '123';
        insert quoteline;
        

        Set<Id> oppIds = new Set<Id>();
        oppIds.add(objquote.Id);
        

        Test.StartTest(); 
        CPQ_ReleaseInventoryOnQuote.releaseOrderProductInventories(oppIds);
        Test.StopTest();
    }

}