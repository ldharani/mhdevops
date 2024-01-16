@isTest
private class AOPControllerTest {
    @isTest
    static void fetchProfileAccessTest(){
        Test.startTest();
        Boolean bool = AOPController.fetchProfileAccess();
        Test.stopTest();
    }
    @isTest
    static void fetchRecordDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Account acc = util.getAccount_withoutInsert();
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Test.startTest();
        Object myObj = AOPController.fetchRecordDetails(acc.Id);
        Test.stopTest();
    }
    @isTest 
    static void  fetchOptionsTest(){
        Test.startTest();
        AOPController.fetchAOPOptions();
        Test.stopTest();
    }
    @isTest
    static void updateAOPValTest(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Account acc = util.getAccount_withoutInsert();
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Test.startTest();
        Object myObj = AOPController.updateAOPVal(acc.Id,'Administrative');
        Test.stopTest();
    }
}