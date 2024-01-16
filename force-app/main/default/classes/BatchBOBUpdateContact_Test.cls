/*Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description

************************************************************************************************************************/
@isTest
public class BatchBOBUpdateContact_Test {
	static testmethod void testMethod1() 
    {
        List<Contact> lstCont = new List<Contact>();
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        insert con;
        lstCont.add(con);
        Test.startTest();
        Database.executeBatch(new BatchBOBUpdateContact(lstCont),1);
        Test.stopTest();
    }
}