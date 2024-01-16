/*
** Created by       : IJ
** Created Purpose  : MHBS-5460 Batch_PopulateDailyMRR
** Test class :  */

global class ScheduleBatch_PopulateDailyMRR implements Schedulable{
  global void execute(SchedulableContext SC) { 
    Batch_PopulateDailyMRR btc = new Batch_PopulateDailyMRR();
    Database.executeBatch(btc,10); 
  }
}