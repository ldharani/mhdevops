/**************************************************************
  
 * Description : Updating Collection Status on Account when Past Due Amount is Modified
 * Class Name  : batchUpdateCollectionStatusOnAccount
 * Test Class  : batchUpdateCollectionStatusAccountTest
 * Created Date : 28/08/2023
 * Created By : Lakshmi
 * 
 * Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/
@isTest
public class batchUpdateCollectionStatusAccountTest {
	static testMethod void testAccountUpdate(){
        Set<Id> accIds = new Set<Id>();
        List<String> accIdsString = new List<String>();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
        Account acc = new Account(Name = 'TestAccount', Book_Owner__c = UserInfo.getUserId());
        insert acc;
        
        test.starttest();
        
        accIdsString = new List<String>{acc.Id};
        
        
        batchUpdateCollectionStatusOnAccount.updateCollectionStatus(accIdsString);
        
        test.stoptest();
        
    }
}