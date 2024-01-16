/***************
* Class Name: BatchToCreateAttyQuoteProcess_Test
* Description: MHMAC-14 : [Discovery] : Automating Quote/Quote line creation from Avvo subscription lines
* Developed By: Jeyamugundan
* Modification History : Created on Jan 13,2023* 
* ******/
@isTest
public class BatchToCreateAttyQuoteProcess_Test {
    static testMethod void testMethodOne(){ 
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();  
        acc.Org_Id__c = '98798676';
        Update acc;
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
        opp.numofActiveMartindaleBaseProfileSub__c = 2;
        opp.Line_Item_Count__c = 2;
        opp.CloseDate = System.today();
        opp.Org_Id__c = null;
        Update opp;
        
        Product2 prd = new Product2();
        prd.Name = 'test product';
        prd.ProductCode = '11011';
        insert prd;
        
        Id prdId = [Select id from product2 where name='test product'].Id;
        insert new PriceBookEntry(Product2Id=prdId, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);
        
        Pricebook2 prb = new Pricebook2();
        prb.Name = '4. Martindale-Avvo Price Book';
        prb.IsActive = true;
        //prb.IsStandard = true;
        insert prb;
        
        Id prbId = [select id from Pricebook2 where name='4. Martindale-Avvo Price Book'].Id;
        PricebookEntry prbEn = new PricebookEntry();
        prbEn.IsActive = true;
        prbEn.UnitPrice = 100;
        prbEn.Pricebook2Id = prbId;
        prbEn.Product2Id = prdId;
        //Pricebook2Id=
        //prbEn.UseStandardPrice = true;
        insert prbEn;
        
        Test.starttest();
        BatchToCreateAttyQuoteProcess batchpp = new BatchToCreateAttyQuoteProcess();
        database.executebatch(batchpp,1);
        Test.stoptest();
    }
    static testMethod void testMethodOneAAA(){ 
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();  
        acc.Org_Id__c = '98798676';
        Update acc;
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
        opp.numofActiveMartindaleBaseProfileSub__c = 2;
        opp.Line_Item_Count__c= 2;
        opp.CloseDate = System.today();
        opp.Org_Id__c = '98798676234';
        opp.CaseCheck__c = True;
        Update opp;
        
        Product2 prd = new Product2();
        prd.Name = 'test product';
        prd.ProductCode = '11011';
        insert prd;
        
        Id prdId = [Select id from product2 where name='test product'].Id;
        insert new PriceBookEntry(Product2Id=prdId, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);
        
        Pricebook2 prb = new Pricebook2();
        prb.Name = '4. Martindale-Avvo Price Book';
        prb.IsActive = true;
        //prb.IsStandard = true;
        insert prb;
        
        Id prbId = [select id from Pricebook2 where name='4. Martindale-Avvo Price Book'].Id;
        PricebookEntry prbEn = new PricebookEntry();
        prbEn.IsActive = true;
        prbEn.UnitPrice = 100;
        prbEn.Pricebook2Id = prbId;
        prbEn.Product2Id = prdId;
        //Pricebook2Id=
        //prbEn.UseStandardPrice = true;
        insert prbEn;
        
        Test.starttest();
        BatchToCreateAttyQuoteProcess batchpp = new BatchToCreateAttyQuoteProcess();
        database.executebatch(batchpp,1);
                ScheduleBatchToClosedWonQuote testScSh = new ScheduleBatchToClosedWonQuote();
        String schs = '20 30 8 10 2 ?';
        String jobIDs = System.schedule('Merge Job', schs, testScSh);
        Test.stoptest();
    }
    static testMethod void testMethodOneBBB(){ 
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();  
        acc.Org_Id__c = '98798676';
        Update acc; 
        Contact con = util.getContact(acc.Id);
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
        opp.numofActiveMartindaleBaseProfileSub__c = 2;
        opp.Line_Item_Count__c = 2;
        opp.CloseDate = System.today();
        opp.Org_Id__c = '98798676234';
        opp.CaseCheck__c = True;
        Update opp;
        
        Product2 prd = new Product2();
        prd.Name = 'Martindale Attorney Base Profile';
        prd.ProductCode = '11015';
        insert prd;
        
        Id prdId = [Select id from product2 where name='Martindale Attorney Base Profile'].Id;
        insert new PriceBookEntry(Product2Id=prdId, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);
        
        Pricebook2 prb = new Pricebook2();
        prb.Name = '4. Martindale-Avvo Price Book';
        prb.IsActive = true;
        //prb.IsStandard = true;
        insert prb;
        
        Id prbId = [select id from Pricebook2 where name='4. Martindale-Avvo Price Book'].Id;
        PricebookEntry prbEn = new PricebookEntry();
        prbEn.IsActive = true;
        prbEn.UnitPrice = 100;
        prbEn.Pricebook2Id = prbId;
        prbEn.Product2Id = prdId;
        //Pricebook2Id=
        //prbEn.UseStandardPrice = true;
        insert prbEn;
        
        Subscription__c sub = new Subscription__c();
        sub .Account__c = acc.Id;
        sub .Opportunity__c = opp.Id;
        sub .Subscription_Id__c = '111111221';
        sub .Cancelled__c = false;
        sub .External_Id__c = '00000010';
        sub .Name  = 'test Subscription2';
        sub.Inventory_Type__c = 'MartindaleBaseProfileInventory';
        insert sub;
        
        List<Account> lstAcc = new List<Account>();
        lstAcc.add(acc);
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp.add(opp);
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        lstQuote[0].QuoteLineCheck__c = True;
        lstQuote[0].Is_Quote_Created_By_Batch__c = True;
        Update lstQuote;
        Test.starttest();
        BatchToCreateAttyQuoteLineProcess batchpp = new BatchToCreateAttyQuoteLineProcess();
        ScheduleBatchToCreateAttyQuoteProcess testSch = new ScheduleBatchToCreateAttyQuoteProcess();
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('Merge Job', sch, testSch);
        database.executebatch(batchpp,1);
        
        Cls_UtilTestClass ccc = new Cls_UtilTestClass();
        ccc.getOrder(lstAcc[0].Id);
        
        BatchToClosedWonQuote batchppA = new BatchToClosedWonQuote();
        database.executebatch(batchppA,1);
        Test.stoptest();
    }
}