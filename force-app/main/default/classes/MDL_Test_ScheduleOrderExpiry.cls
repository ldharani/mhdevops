@isTest
private class MDL_Test_ScheduleOrderExpiry {
	static testMethod void testscheduleBatch(){
        Test.startTest();
        MDL_ScheduleOrderExpiry sch = new MDL_ScheduleOrderExpiry();
        String s = '0 0 23 * * ?';
    	system.schedule('Test check', s, sch);
    	Test.stopTest();
    }
}