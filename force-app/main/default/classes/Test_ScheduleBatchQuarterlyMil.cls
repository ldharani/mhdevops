@isTest
public class Test_ScheduleBatchQuarterlyMil {
	static testMethod void testscheduleBatch(){
        Test.startTest();
        ScheduleBatchQuarterlyMaintMilestone  sch = new ScheduleBatchQuarterlyMaintMilestone();
        String s = '0 0 23 * * ?';
    	system.schedule('Test quarterly', s, sch);
        Test.stopTest();
    }


}