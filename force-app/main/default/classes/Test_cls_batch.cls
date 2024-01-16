@isTest
public class Test_cls_batch {
	@testsetup
    public static void setup(){
        Profile p; 
        //Profile p_admin;
        p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //p_admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
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
        
        blng__BillingRule__c objBR = new blng__BillingRule__c();
        objBR.Name = 'Test';
        objBR.blng__Active__c = TRUE;
        objBR.blng__AmendmentBillCycleDateAlignment__c = 'Do not align amended Order Product';
        objBR.blng__GenerateInvoices__c = 'Yes';
        objBR.blng__InitialBillingTrigger__c = 'Order Product Activation Date ';
        objBR.blng__Notes__c = 'Test';        
        objBR.blng__PartialPeriodTreatment__c = 'Separate';
        insert objBR;
        
        blng__RevenueRecognitionRule__c revRule = new blng__RevenueRecognitionRule__c();
        revRule.Name = 'test rev';
        revRule.blng__Active__c = true;
        revRule.blng__CreateRevenueSchedule__c = 'Yes';
        insert revRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c();
        taxRule.Name = 'test tax';
        taxRule.blng__Active__c = true;
        taxRule.blng__TaxableYesNo__c = 'Yes';
        insert taxRule;
        
        Product2 prd = new Product2();
        prd.Name = 'test product';
        prd.SBQQ__BillingType__c = 'Advance';
        prd.blng__BillingRule__c = objBR.Id;
        prd.blng__RevenueRecognitionRule__c = revRule.Id;
        prd.blng__TaxRule__c = taxRule.Id;
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
       
        
        blng__GLRule__c bllGlr = new blng__GLRule__c();
        bllGlr.Name = 'Post Invoice';
        bllGlr.blng__active__c = true;
        insert bllGlr;
        
        //blng__BillingRule__c objBR2 = DataFactory.createBillingRule();
        
        Id bllGlrId = [select id from blng__GLRule__c limit 1].Id;
        Id ordId = [select id from Order limit 1].Id;
        Id prbEnId = [select id from PricebookEntry where UnitPrice = 100 limit 1].Id;
        //Id billrId = [select id from blng__BillingRule__c where blng__Notes__c = 'Test'].id;
        OrderItem ordPrd = new OrderItem();
        ordPrd.OrderId = ordId;
        ordPrd.SBQQ__Activated__c = true;
        ordPrd.Quantity = 2.00;
        ordPrd.PricebookEntryId = prbEnId;
        ordPrd.SBQQ__ChargeType__c = 'Recurring';
        ordPrd.SBQQ__BillingFrequency__c = 'Monthly';
        ordPrd.UnitPrice = 10;
        ordPrd.Status__c = 'Active';
        ordPrd.blng__BillingGLRule__c = bllGlrId;
        ordPrd.SBQQ__BillingType__c = 'Advance';
        //system.debug('objBR.Id : '+objBR.Id);
        ordPrd.blng__BillingRule__c = objBR.Id;
        ordPrd.blng__RevenueRecognitionRule__c = revRule.Id;
        ordPrd.blng__TaxRule__c = taxRule.Id;
        insert ordPrd;
         
        Id invId = [select id from blng__Invoice__c limit 1].Id;
        Id ordPrdId = [select id from OrderItem limit 1].Id;
        blng__InvoiceLine__c invLines = new blng__InvoiceLine__c();
        invLines.blng__Invoice__c = invId;        
        invLines.blng__UnitPrice__c = 100.00;
        invLines.blng__TotalAmount__c = 100.00;
        invLines.blng__OrderProduct__c = ordPrdId;
        insert invLines;
        
    }
   
    @isTest
    public static void testRun1(){
        List<blng__invoice__c> sdf = [select id,blng__DueDate__c,blng__InvoiceDate__c,blng__Account__r.Invoice_Delivery_Type__c,blng__Account__r.Payment_Terms__c, (select blng__invoice__c,blng__OrderProduct__r.Status__c, blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Order.BillToContactId from blng__InvoiceInvoiceLines__r) from blng__invoice__c limit 1];
        
        Test.startTest();
            Batch_populateBillToContactOnInvoice cb = New Batch_populateBillToContactOnInvoice();
            Database.QueryLocator ql = cb.start(null);
            cb.execute(null,sdf);
        	cb.Finish(null); 
        Test.stopTest();
    }
}