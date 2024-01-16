/**************************************************************
  
 * Description : MH AE adding lead/contact to book of business
 * Class Name  : batchUpdateBOBOnContact
 * Test Class  : batchUpdateBOBOnContactTest 
 * Created Date : 04/07/2023
 * Created By : Lakshmi
 * 
 * Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/
@isTest
public class batchUpdateBOBOnContactTest {

    static testMethod void testContactUpdate(){
        Set<Id> accIds = new Set<Id>();
        List<String> accIdsString = new List<String>();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
        Account acc = new Account(Name = 'TestAccount', Book_Owner__c = UserInfo.getUserId());
        insert acc;
        
        Contact con = new Contact(LastName = 'TestContact', Book_Owner__c = UserInfo.getUserId(), AccountId = acc.Id);
        insert con;
        
        test.starttest();
        acc.Book_Owner__c = null;
        update acc;
        
        accIdsString = new List<String>{acc.Id};
        
        
        batchUpdateBOBOnContact.updateBOBOnContact(accIdsString);
        
        test.stoptest();
        
        
        
    }


}