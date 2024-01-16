@isTest
public class CascadeQuoteContact_Test {
    @testSetup static void setup() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> lstCon = DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        lstQuote[0].Marketing_Contact__c = lstCon[0].Id;
        lstQuote[0].Billing_Contact__c = lstCon[0].Id;
        lstQuote[0].SBQQ__PrimaryContact__c = lstCon[0].Id;
        update lstQuote;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today().adddays(6);
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        objOrder.SBQQ__Quote__c = lstQuote[0].Id;
        insert objOrder;
    }
    
    public static testmethod void testMethodA() {
        List<SBQQ__Quote__c> lstQuote = [SELECT ID FROM SBQQ__Quote__c];
        lstQuote[0].SBQQ__Status__c = 'QA Review';
        update lstQuote;
    }
    
    public static testmethod void testMethodB() {
        
        Contact con = new Contact();
        con.FirstName= 'test';
        con.LastName = 'test@abc.com';
        con.Email = 'test@abc.com';
        con.Phone = '123456789';
        insert con;
        
        List<SBQQ__Quote__c> lstQuote = [SELECT ID FROM SBQQ__Quote__c];
        lstQuote[0].Marketing_Contact__c = con.Id;
        lstQuote[0].Billing_Contact__c = con.Id;
        lstQuote[0].SBQQ__PrimaryContact__c = con.Id;
        update lstQuote;
    }
    
    public static testmethod void testMethodC() {
        List<Order> lstord = [SELECT ID,SBQQ__Quote__c FROM Order];
        CascadeQuoteContact.CascadeQuoteContactToOrderIn(lstord);
    }
    public static testmethod void testMethodD() {
        List<Account> lstAcc = [SELECT ID FROM Account];
        List<SBQQ__Quote__c> lstQuote = [SELECT ID FROM SBQQ__Quote__c];
        
        List<Contract> conlist = new List<Contract>();
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Active';
        con.StartDate = Date.today();
        con.SBQQ__Quote__c = lstQuote[0].Id;
        con.ContractTerm = 12;
        insert con;
        conlist.add(con);
        
        CascadeQuoteContact.CascadeQuoteContactToContractIn(conlist);
        
    }
    
}