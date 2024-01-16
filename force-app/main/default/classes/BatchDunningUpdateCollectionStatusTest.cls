/***********************************************************************************************************************
 * @author - Lakshmi
 * @date - 27 Nov 20223
 * @description - Batch class to update Collection Status on Account when past due amount is updated
 * @testclass - BatchDunningUpdateCollectionStatusTest

Change History
************************************************************************************************************************
*/

@isTest
public class BatchDunningUpdateCollectionStatusTest{

    static List<RecordType> MHAccountRT;
    static Account acc1;
    

    static{
        
        MHAccountRT = [Select Id from RecordType where DeveloperName = 'Nolo_Account' Limit 1];
               
        acc1 = new Account(Name = 'Nolo Account');
        acc1.RecordTypeId = MHAccountRT[0].Id;
        acc1.Is_Combined_Profile_Product_added__c = true;
        insert acc1;
    }

    static testMethod void testMethodOne(){    
        
        Test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        BatchDunningUpdateCollectionStatus b = new BatchDunningUpdateCollectionStatus(acc1.Id);
        database.executebatch(b,1);
        Test.stoptest();
        
        //added by saiv - 04/12/2022
        Sch_BatchDunningUpdateCollectionStatus m1 = new  Sch_BatchDunningUpdateCollectionStatus();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, m1);
        
        
    }
}