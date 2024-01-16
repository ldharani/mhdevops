/***********************************************************************************************************************
 * @author - SaiV
 * @date - 12 Apr 2022
 * @description - Batch class to populate MH Account and MH Subscription
 * @testclass - Batch_PopulateMHAccOnAvvoSub_Test

Change History
************************************************************************************************************************
*/
global class Schedule_PopulateMHAccOnAvvoSub implements Schedulable{
  global void execute(SchedulableContext SC) { 
    Batch_PopulateMHAccOnAvvoSub b = new Batch_PopulateMHAccOnAvvoSub();
    Database.executeBatch(b, 1);
  }
}