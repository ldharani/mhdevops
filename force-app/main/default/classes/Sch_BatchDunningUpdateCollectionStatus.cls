/***********************************************************************************************************************
 * @author - SaiV
 * @date - 27 Nov 2023
 * @description - Schedule class to schedule the batch update Collection Status on Account
 * @testclass - BatchDunningUpdateCollectionStatusTest

Change History
************************************************************************************************************************
*/
global class Sch_BatchDunningUpdateCollectionStatus implements Schedulable{
  global void execute(SchedulableContext SC) { 
    BatchDunningUpdateCollectionStatus b = new BatchDunningUpdateCollectionStatus();
    Database.executeBatch(b, 1);
  }
}