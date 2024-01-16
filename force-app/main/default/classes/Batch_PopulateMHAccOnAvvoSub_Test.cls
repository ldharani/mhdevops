/***********************************************************************************************************************
 * @author - Lakshmi
 * @date - 11 Apr 2022
 * @description - Batch class to populate MH Account and MH Subscription
 * @testclass - Batch_PopulateMHAccOnAvvoSub_Test

Change History
************************************************************************************************************************
*/

@isTest
public class Batch_PopulateMHAccOnAvvoSub_Test{

    static List<RecordType> IBAccountRT;
    static List<RecordType> MHAccountRT;
    static List<RecordType> AttyAccountRT;
    static List<RecordType> FirmAccountRT;
    static Product2 prod;
    static PriceBookEntry pbE;
    static Account acc;
    static Account acc1;
    static Account acc2;
    static Account acc3;
    static SBQQ__Subscription__c cpqSub;
    static Subscription__c sub;
    static Opportunity opp;
    static Order ord;
    static OrderItem ordItem;

    static{
        IBAccountRT = [Select Id from RecordType where DeveloperName = 'IB_Accounts' Limit 1];
        
        MHAccountRT = [Select Id from RecordType where DeveloperName = 'Nolo_Account' Limit 1];
        
        AttyAccountRT = [Select Id from RecordType where DeveloperName = 'M_A_Atty_Account' Limit 1];
        
        FirmAccountRT = [Select Id from RecordType where DeveloperName = 'M_A_Firm_Account' Limit 1];
        
        List<RecordType> OppRecordTypeIdMA = [Select Id from RecordType where DeveloperName = 'M_A_Opportunity' Limit 1];
        
        /*prod = new Product2();
        prod.Name = 'Martindale-Avvo Complete Profile Plus';
        insert prod;*/
        
        
        
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        prod = new Product2(Name='Martindale-Avvo Complete Profile Plus',ProductCode='NgProd',Family='Ngage',IsActive=true,
               SBQQ__ChargeType__c='Recurring',SBQQ__ConfigurationEvent__c='Always',SBQQ__BillingFrequency__c='Monthly',
               SBQQ__BillingType__c = 'Advance',SBQQ__SubscriptionTerm__c = 1,
               SBQQ__NonDiscountable__c=true,SBQQ__PricingMethod__c='List',SBQQ__QuantityEditable__c=false,
               SBQQ__SubscriptionType__c='Renewable',SBQQ__PriceEditable__c=false,
               blng__BillingRule__c=objBR.ID,blng__RevenueRecognitionRule__c=objRR.ID,blng__TaxRule__c=objTR.ID);
        insert prod;       
               
        pbE = new PriceBookEntry();
        pbE.Product2Id = prod.Id;
        pbE.PriceBook2Id = Test.getStandardPricebookId();
        //pbE.StandardPrice = 0;
        pbE.UnitPrice = 0;
        pbE.IsActive = true;
        pbE.UseStandardPrice = false;
        insert pbE;       
        
        acc = new Account(Name = 'IB Account');
        acc.RecordTypeId = IBAccountRT[0].Id;
        insert acc;
        
        acc1 = new Account(Name = 'Nolo Account');
        acc1.RecordTypeId = MHAccountRT[0].Id;
        acc1.Is_Combined_Profile_Product_added__c = true;
        acc1.ParentId = acc.Id;
        insert acc1;
        
        acc2 = new Account(Name = 'Atty Account');
        acc2.RecordTypeId = AttyAccountRT[0].Id;
        acc2.ParentId = acc.Id;
        insert acc2;
        
        acc3 = new Account(Name = 'Firm Account');
        acc3.RecordTypeId = FirmAccountRT[0].Id;
        acc3.ParentId = acc2.Id;
        insert acc3;
        
        cpqSub = new SBQQ__Subscription__c();
        cpqSub.SBQQ__Product__c = prod.Id;
        cpqSub.SBQQ__Quantity__c = 1;
        cpqSub.SBQQ__Account__c = acc1.Id;
        insert cpqSub;
        
        opp = new Opportunity();
        opp.AccountId = acc3.Id;
        opp.Name = 'Test Atty Opp Account';
        opp.StageName = 'Receipt';     
        opp.RecordTypeId = OppRecordTypeIdMA[0].Id; 
        opp.CloseDate = system.today();  
        insert opp;
        
        sub = new Subscription__c();
        sub.Account__c = acc3.Id;
        sub.Inventory_Type__c = 'CompleteProfilePlusInventory';
        sub.Opportunity__c = opp.Id;
        sub.External_Id__c = '1234565678000';
        sub.Subscription_Id__c = '1234565678001';
        insert sub;
        
        ord = new Order();
        ord.AccountId = acc1.Id;
        ord.EffectiveDate = system.today();
        ord.Status = 'Draft';
        ord.PriceBook2Id = Test.getStandardPricebookId();
        insert ord;
        
        ordItem = new OrderItem();
        ordItem.OrderId = ord.Id;
        ordItem.Product2Id = prod.Id;
        ordItem.PriceBookEntryId = pbE.Id;
        ordItem.Quantity = 1;
        ordItem.ServiceDate = system.today();
        ordItem.SBQQ__Status__c = 'Draft';
        ordItem.SBQQ__SubscriptionTerm__c = 1;
        ordItem.SBQQ__ChargeType__c = 'Recurring';
        ordItem.SBQQ__BillingFrequency__c = 'Monthly';
        ordItem.SBQQ__BillingType__c = 'Advance';
        ordItem.blng__BillingRule__c = objBR.Id;
        ordItem.blng__TaxRule__c = objTR.Id;
        ordItem.blng__RevenueRecognitionRule__c = objRR.Id;
        ordItem.UnitPrice = 0;
        insert ordItem;
        
    }

    static testMethod void testMethodOne(){    
        
        Test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Batch_PopulateMHAccOnAvvoSub b = new Batch_PopulateMHAccOnAvvoSub(sub.Id);
        database.executebatch(b,1);
        Test.stoptest();
        
        //added by saiv - 04/12/2022
        Schedule_PopulateMHAccOnAvvoSub m1 = new  Schedule_PopulateMHAccOnAvvoSub();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, m1);
        
        
    }
}