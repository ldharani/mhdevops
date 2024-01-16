@isTest
public class MDL_TriggerHandlerForAccount_Test {
    static testMethod void UseCase(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        List<Account> acclist = new List<Account>();
        Set<Id> accId = new Set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Account acc = new Account();
        acc.Name = 'TestRec';
        insert acc;
        acclist.add(acc);
        accId.add(acc.Id);
        accMap.put(acc.Id,acc);
        Test.startTest();
        MDL_TriggerHandlerForAccount accClass = new MDL_TriggerHandlerForAccount();
        accClass.createCaseOnAccountCreation(acclist);
        MDL_TriggerHandlerForAccount.createInvoiceFolderPath(accId);
        MDL_TriggerHandlerForAccount.updatepaymentMethods(accMap,accMap);
        MDL_TriggerHandlerForAccount.createAtRiskCase(acclist,accMap,accMap);
        accClass.populateOwnerEmailOnProj(acclist,accMap,accMap);
        MDL_TriggerHandlerForAccount.updateParentAccWChildAccFields(acclist,accMap);
        test.stopTest();
    }
    static testMethod void UseCaseA(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Id IBAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id MHAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Id MNGAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        Id MNAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        
        
        Account accParent = new Account();
        accParent.Name = 'TestRec Parent';
        accParent.RecordTypeId = IBAccRecordTypeId;
        insert accParent;
        
        
        List<Account> acclist = new List<Account>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Account acc = new Account();
        acc.Name = 'TestRec';
        acc.RecordTypeId = MHAccRecordTypeId;
        acc.ParentId = accParent.Id;
        insert acc;
        acclist.add(acc);
        accMap.put(acc.Id,acc);
        
        Account accA = new Account();
        accA.Name = 'TestRecA';
        accA.RecordTypeId = MNAccRecordTypeId;
        accA.ParentId = accParent.Id;
        insert accA;
        acclist.add(accA);
        accMap.put(accA.Id,accA);
        
        Account accB = new Account();
        accB.Name = 'TestRecA';
        accB.RecordTypeId = MNGAccRecordTypeId;
        accB.ParentId = accParent.Id;
        insert accB;
        
        
        
        acclist.add(accB);
        accMap.put(accB.Id,accB);
        
        Test.startTest();
        MDL_TriggerHandlerForAccount.updateParentAccWChildAccFields(acclist,accMap);
        test.stopTest();
    }
    static testMethod void UseCaseB(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Id IBAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id MHAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Id MNGAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        Id MNAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        
        List<Account> acclist = new List<Account>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        
        Account accB = new Account();
        accB.Name = 'TestRecA';
        accB.RecordTypeId = MNGAccRecordTypeId;
        insert accB;
        
        acclist.add(accB);
        accMap.put(accB.Id,accB);
        
        Test.startTest();
        MDL_TriggerHandlerForAccount.updateParentAccWChildAccFields(acclist,accMap);
        MDL_TriggerHandlerForAccount.updateOrderStatusOnPaymentMethod(acclist,accMap);
        MDL_TriggerHandlerForAccount.UpdateAttyAccountStatus(acclist,accMap,true,true);
        MDL_TriggerHandlerForAccount.updateAvvoFirmAccounts(acclist,accMap,true,true);
        test.stopTest();
    }
    public static List<Account> AccountLogic(){        
        Id IBAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id MHAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Id MNGAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        Id MNAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestRec';
        acc.RecordTypeId = MHAccRecordTypeId;
        insert acc;
        accList.add(acc);
        
        Account accA = new Account();
        accA.Name = 'TestRecA';
        accA.RecordTypeId = MNAccRecordTypeId;
        insert accA;
        accList.add(accA);
        
        Account accB = new Account();
        accB.Name = 'TestRecA';
        accB.RecordTypeId = MNGAccRecordTypeId;
        insert accB;
        accList.add(accB);
        return accList;         
    }
}