@isTest
public class Test_RebaseAmendQueueCalling {
    static testMethod void testMethod1() {
        
        Method_specific_Deactivate_trigger__c obj = new Method_specific_Deactivate_trigger__c(SetupOwnerId=Userinfo.getProfileId(), Activate__c=true);
        insert obj;
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
        
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = acc.Id;
        ord.Status = 'Draft';   
        ord.EffectiveDate = Date.today();
        insert ord;
        
        Contract contr = new Contract();
        contr.AccountId = acc.Id;
        contr.SBQQ__Quote__c =objquote.Id;
        contr.SBQQ__Opportunity__c = testopp.ID;
        contr.SBQQ__Order__c = ord.Id;
        contr.StartDate = Date.today();
        insert contr;
        
        Test.startTest();
        RebaseAmendQueueCalling.RebaseAmendQueue(contr.Id);
        RebaseAmendQueueCalling.EvergreenAmendQueue(contr.Id);
        RebaseAmendQueueCalling.saveContract(contr);
        RebaseAmendQueueCalling.validationQ(contr.Id);
        //RebaseAmendQueueCalling.getBooleanBlock(contr.Id);
        Test.stopTest();
    }

}