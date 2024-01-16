@isTest
public class CPQ_ContractHandler_Test {
    public static testmethod void testMethod1(){
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        Contact ccccc = new Contact();
        ccccc.FirstName = 'Test';
        ccccc.LastName = 'Test';
        ccccc.AccountId = lstAcc[0].Id;
        ccccc.Email = 'test@abc.com';
        ccccc.Phone = '123456789';
        insert ccccc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Rebased OppTest'; 
        opp.AccountId = lstAcc[0].Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.today();
        insert opp;
        
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>(); 
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
        quoteRec.SBQQ__Account__c = lstAcc[0].Id;
        quoteRec.State__c = 'Draft';
        insert quoteRec;
        
        quoteRec.Billing_Contact__c = ccccc.Id;
        quoteRec.Marketing_Contact__c = ccccc.Id;
        quoteRec.SBQQ__PrimaryContact__c = ccccc.Id;
        Update quoteRec;
        
        lstQuote.add(quoteRec);
        
        List<SBQQ__Quote__c> lstQuoteAA = [SELECT ID,SBQQ__Account__c,State__c,Billing_Contact__c,Marketing_Contact__c,SBQQ__PrimaryContact__c,SBQQ__PrimaryContact__r.Email FROM SBQQ__Quote__c LIMIT 1];
        System.debug('lstQuoteAA ' + lstQuoteAA[0].SBQQ__PrimaryContact__r.Email);

        test.startTest();        
        List<Contract> conList = new List<Contract>();
        Contract conA = new Contract();
        conA.AccountId = lstAcc[0].Id;
        conA.Amend_Quote__c = lstQuoteAA[0].Id;
        conA.SBQQ__Opportunity__c = opp.Id;
        conA.SBQQ__RenewalOpportunity__c = opp.Id;
        //Status__c = 'Rebased'
        
        insert conA;
        
        conA.Status = 'Activated';
        conA.Status__c = 'Rebased';
        update conA;
        
        conList.add(conA);
        
        Contract conB = new Contract();
        conB.AccountId = lstAcc[0].Id;
        conB.Amend_Quote__c = lstQuoteAA[0].Id;
        conB.SBQQ__Opportunity__c = opp.Id;
        insert conB;
        
        opp.SBQQ__RenewedContract__c = conList[0].Id;
        Update opp;
        
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
        
      //  SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuoteAA[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
        
        List<Contract> conListAA = [SELECT ID,IsCancelQuoteCreated__c,Created_from_Contract__c,AccountId,Amend_Quote__c,SBQQ__Opportunity__c,Status,Status__c,SBQQ__Opportunity__r.SBQQ__RenewedContract__c,SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Amend_Quote__c FROM Contract WHERE Status = 'Activated'];
        conListAA[0].Created_from_Contract__c = conB.Id;
        Update conListAA;
        System.debug('0!!!!!!!!! ' + conListAA);
        Map<Id,Contract> mapCon = new Map<Id,Contract>();
        for(Contract ccc : conListAA){
            mapCon.put(ccc.Id, ccc);
        }
        
        //SBQQ__Subscription__c objSub = DataFactory.createSubscription(lstAcc[0], conListAA[0], lstProd[0], objQLI);   
        
        CPQ_ContractHandler ccc = new CPQ_ContractHandler();
        ccc.FkMethod();
        CPQ_ContractHelper.CreateOrderforAmend(conListAA);
        CPQ_ContractHelper.updateFutureContract(conListAA,mapCon);
        CPQ_ContractHelper classinstance = new CPQ_ContractHelper();
        classinstance.FkMethod();
        Contract_UtilityClass util = new Contract_UtilityClass();
        util.FkMethod();
        test.stopTest();
        
    }
}