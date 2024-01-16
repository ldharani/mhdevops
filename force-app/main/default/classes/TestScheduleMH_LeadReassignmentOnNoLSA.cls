/****************************************************************
 * Author       : Lakshmi
 * Description  : Test class for ScheduleMH_LeadReassignmentOnNoLSA 
 * Created Date : 04/25/2023
 * **************************************************************
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date          Requested By    Tag     Description
************************************************************************************************************************/

@isTest
private class TestScheduleMH_LeadReassignmentOnNoLSA{
  static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleMH_LeadReassignmentOnNoLSA sch = new ScheduleMH_LeadReassignmentOnNoLSA();
        String s = '0 0 23 * * ?';
      system.schedule('Test check', s, sch);
      Test.stopTest();
    }
}