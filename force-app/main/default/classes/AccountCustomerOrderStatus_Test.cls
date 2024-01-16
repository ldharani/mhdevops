/**
@@*
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-9435    Bharath     16/08/2023     John Mattheson  T01     MN Order Status/Customer status badge issues
*************************************************************************************************************************/
@isTest
private class AccountCustomerOrderStatus_Test { 
    
    static testMethod void OrderStatusTestMethod() { 
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Active';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;

        con.Status__c = 'Amend in progress';
        update con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
    }
    static testMethod void OrderStatusTestMethodA() { 
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Amend in progress';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;

        con.Status__c = 'Amended';
        update con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
    }
    static testMethod void OrderStatusTestMethodB() { 
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Amended';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;

        con.Status__c = 'Renew in Progress';
        update con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
    }
    static testMethod void OrderStatusTestMethodC() { 
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Renew in Progress';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
    }
    static testMethod void OrderStatusTestMethodD() { 
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Active';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;

        con.Status__c = 'Rebase in progress';
        update con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
        
    }
    static testMethod void OrderStatusTestMethodE() { 
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Active';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;

        con.Status__c = 'Evergreen';
        update con;
        Test.stopTest();
    }
    static testMethod void OrderStatusTestMethodF() { 
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Active';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;

        con.Status__c = 'Evergreen in progress';
        update con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
    }
    static testMethod void OrderStatusTestMethodG() {
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Cancel in Progress';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;
        
        con.Status__c = 'Cancelled';
        Update con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
    }
    static testMethod void OrderStatusTestMethodH() { 
        Test.startTest();
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Active';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;
        
        con.Status__c = 'Expired';
        Update con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
    }
    static testMethod void OrderStatusTestMethodI() { 
        Test.startTest();
        // Create Test Account
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        acc.Acquisition_date__c = System.today();
        acc.Loss_Date__c = System.today();
        acc.Customer_Status__c = 'Former Sub';
        insert acc;
        
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = acc.Id;
        con.Status__c = 'Active';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        insert con;
        /*
        BatchToUpdateAccountOrderStatus_AC obj = new BatchToUpdateAccountOrderStatus_AC();
        DataBase.executeBatch(obj); 
        */
        Test.stopTest();
    }
    
    static testMethod void CustomerStatusTestMethod() {
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.startTest();   
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Order_Status__c = 'Cancelled';
        acc.Acquisition_date__c = System.today();
        acc.Re_acquisition_date__c = System.today();
        acc.LossDateCheck__c = System.today();
        insert acc;
        
        acc.Order_Status__c = 'Active';
        Update acc;    
        
        Account accA = new Account();
        accA.Name = 'TestA';
        accA.Order_Status__c = 'Active';
        insert accA;
        
        accA.Acquisition_date__c = System.today();
        accA.Order_Status__c = 'Cancelled';
        Update accA; 
        
        Account accB = new Account();
        accB.Name = 'TestB';
        accB.Order_Status__c = 'Cancelled';
        accB.Acquisition_date__c = System.today();
        accB.Re_acquisition_date__c = System.today().addYears(1);
        accB.LossDateCheck__c = System.today().addYears(1);
        insert accB;
        
        accB.Order_Status__c = 'Active';
        Update accB; 
        
        Account accC = new Account();
        accC.Name = 'TestC';
        accC.Order_Status__c = 'Cancelled';
        accC.Acquisition_date__c = System.today();
        accC.Re_acquisition_date__c = System.today().addYears(2);
        accC.LossDateCheck__c = System.today().addYears(1);
        insert accC;
        
        accC.Order_Status__c = 'Active';
        Update accC; 
        
        Opportunity opp = new Opportunity();
        opp.Name = 'OppTest'; 
        opp.AccountId = acc.Id;
        opp.StageName = 'Prospecting';
        opp.CloseDate = System.today();
        insert opp;
        
        opp.StageName = 'Closed Won';
        update opp;
        
        SBQQ__Quote__c quoteRec = new SBQQ__Quote__c();
        quoteRec.SBQQ__Account__c = acc.Id;
        quoteRec.State__c = 'Draft';
        // insert quoteRec;
        
        quoteRec.State__c = 'Closed Won';
        // Update quoteRec;
        
        Map<Id, SBQQ__Quote__c> newOppMap = new Map<Id, SBQQ__Quote__c>();
        
        AccountCutomerStatusLogic.updateAcquisitionDate(newOppMap,newOppMap);
        Test.stopTest();
        
        //
        /*
        test.startTest();   
        BatchToUpdateAccountCustomerStatus_AC obj = new BatchToUpdateAccountCustomerStatus_AC();
        DataBase.executeBatch(obj); 
        test.stopTest();
        */
    }

    static testMethod void BatchCustomerStatusTestMethod() {
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Order_Status__c = 'Cancelled';
        acc.Acquisition_date__c = System.today();
        acc.Re_acquisition_date__c = System.today();
        acc.LossDateCheck__c = System.today();
        insert acc;
        
        Account accA = new Account();
        accA.Name = 'Test';
        accA.Order_Status__c = 'Cancelled';
        accA.Acquisition_date__c = System.today().addDays(-500);
        accA.Re_acquisition_date__c = System.today().addDays(-500);
        accA.LossDateCheck__c = System.today();
        insert accA;
        /*
        test.startTest();   
        BatchToUpdateAccountCustomerStatus_AC obj = new BatchToUpdateAccountCustomerStatus_AC();
        DataBase.executeBatch(obj); 
        test.stopTest();
        */
    }
    
}