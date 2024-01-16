@isTest()
public class Test_Cls_PopulateBillToContactOnInvoice {
    @isTest
    public static void testRun(){
        Profile p;
        Profile p_admin;
        p = [SELECT Id FROM Profile LIMIT 1];
        p_admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuserrrr123@testorg.com');
        insert u2;
        
        Account a = new Account();
        a.Name = 'testAcc11'; 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        a.BillingState = 'NY';
        a.ShippingState = 'NY';
        a.ShippingPostalCode = '12356-2343'; a.BillingPostalCode = '12356-2343';
        a.ShippingLongitude = 12;a.BillingLongitude = 12;
        a.ShippingLatitude = 10 ;a.BillingLatitude = 10;
        a.ShippingCountry = 'USA';a.BillingCountry = 'USA';
        a.ShippingCity = 'California';a.BillingCity = 'California';
        a.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        a.Organization_Type__c = 'Corporation';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
        a.Payment_Terms__c = 'Net 10';
        User u = [select id from user where UserName='newuserrrr123@testorg.com'];
        a.Collector__c = u.Id;
        insert a;
        
        Id accId= [select id from account where name='testAcc11'].Id;
        Contact c = new Contact();
        c.LastName = 'Test Contact11';
        c.Email = 'testabc@gmail.com';
        c.AccountId = accId;
        insert c;
        
        Id conId = [select id from contact where email = 'testabc@gmail.com'].Id;
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.ContactId = conId;
        opp.StageName ='Prospecting';
        opp.CloseDate = Date.today();
        opp.Name = 'testOpp';        
        insert opp;
        
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = accId;
        invoice.blng__DueDate__c = date.Today().addDays(-90);
        invoice.blng__InvoiceDate__c = Date.newInstance(2021, 08, 01);
        invoice.blng__InvoiceStatus__c ='Posted';
        insert invoice;
        
        blng__Invoice__c invoice2 = new blng__Invoice__c();
        invoice2.blng__Account__c = accId;
        invoice2.blng__DueDate__c = date.Today().addDays(-90);
        invoice2.blng__InvoiceDate__c = Date.newInstance(2021, 08, 01);
        invoice2.blng__InvoiceStatus__c ='Draft';
        insert invoice2;
        
        Product2 prd = new Product2();
        prd.Name = 'test product';
        insert prd;
        
        Id prdId = [Select id from product2 where name='test product'].Id;
        insert new PriceBookEntry(Product2Id=prdId, Pricebook2Id=Test.getStandardPricebookId(), UnitPrice=0);
        
        
        Pricebook2 prb = new Pricebook2();
        prb.Name = 'test prb';
        prb.IsActive = true;
        //prb.IsStandard = true;
        insert prb;
        
        Id prbId = [select id from Pricebook2 where name='test prb'].Id;
        PricebookEntry prbEn = new PricebookEntry();
        prbEn.IsActive = true;
        prbEn.UnitPrice = 100;
        prbEn.Pricebook2Id = prbId;
        prbEn.Product2Id = prdId;
        //Pricebook2Id=
        //prbEn.UseStandardPrice = true;
        insert prbEn;
        
        //Id prbId = [select id from Pricebook2 where name='test prb'].Id;
        Order ord = new Order();
        ord.Name = 'Test Order';
        ord.AccountId = accId;
        ord.Status = 'Draft';
        ord.BillToContactId = conId;
        ord.Pricebook2Id = prbId;
        ord.EffectiveDate = Date.today();
        insert ord;
        
        blng__BillingRule__c objBR = new blng__BillingRule__c();
        objBR.Name = 'Test';
        objBR.blng__Active__c = TRUE;
        objBR.blng__AmendmentBillCycleDateAlignment__c = 'Do not align amended Order Product';
        objBR.blng__GenerateInvoices__c = 'Yes';
        objBR.blng__InitialBillingTrigger__c = 'Order Product Activation Date ';
        objBR.blng__Notes__c = 'Test';
        objBR.blng__PartialPeriodTreatment__c = 'Separate';
        insert objBR;
        
        blng__GLRule__c bllGlr = new blng__GLRule__c();
        bllGlr.Name = 'Post Invoice';
        bllGlr.blng__active__c = true;
        insert bllGlr;
        
        Id bllGlrId = [select id from blng__GLRule__c limit 1].Id;
        Id ordId = [select id from Order limit 1].Id;
        Id prbEnId = [select id from PricebookEntry where UnitPrice = 100 limit 1].Id;
        Id billrId = [select id from blng__BillingRule__c limit 1].id;
        OrderItem ordPrd = new OrderItem();
        ordPrd.OrderId = ordId;
        ordPrd.Quantity = 2.00;
        ordPrd.PricebookEntryId = prbEnId;
        ordPrd.SBQQ__ChargeType__c = 'One-Time';
        ordPrd.UnitPrice = 10;
        ordPrd.blng__BillingGLRule__c = bllGlrId;
        ordPrd.blng__BillingRule__c = billrId;
       // insert ordPrd;
        
        Id invId = [select id from blng__Invoice__c limit 1].Id;
      //  Id ordPrdId = [select id from OrderItem limit 1].Id;
        blng__InvoiceLine__c invLines = new blng__InvoiceLine__c();
        invLines.blng__Invoice__c = invId;        
        invLines.blng__UnitPrice__c = 100.00;
        invLines.blng__TotalAmount__c = 100.00;
       // invLines.blng__OrderProduct__c = ordPrdId;
        insert invLines;
        
         blng__InvoiceLine__c invLines2 = new blng__InvoiceLine__c();
        invLines2.blng__Invoice__c = invoice2.ID;        
        invLines2.blng__UnitPrice__c = 100.00;
        invLines2.blng__TotalAmount__c = 100.00;
       // invLines.blng__OrderProduct__c = ordPrdId;
        insert invLines2;
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(a, opp, quoteRecordTypeId, 1);
         Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        lstQuote[0].SBQQ__PrimaryContact__c =  DataFactory.createContact('Test Con1', a, conRecordTypeId, 1)[0].id;//[SELECT id FROM Contact WHERE LastName  ='Test Con'].id;
        UPDATE lstQuote;
        Contract objContract = new Contract();
        objContract.AccountId = opp.AccountId;
        objContract.SBQQ__Opportunity__c = opp.Id;
        objContract.SBQQ__Quote__c = lstQuote[0].Id;
        objContract.Status = 'Draft';
        objContract.StartDate = Date.today();
        objContract.ContractTerm = 2;
        
        INSERT objContract;
        
        Test.startTest();
            Batch_populateBillToContactOnInvoice obj = new Batch_populateBillToContactOnInvoice();
            Database.executeBatch(obj);
        Test.stopTest();
    }
}