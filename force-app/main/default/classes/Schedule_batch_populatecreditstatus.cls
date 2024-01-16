/** Scheduler class for Batch_populateAccPrevBalance
Test class : Test_Batch_populateAccPrevBalance.apxc
**/ 
global class Schedule_batch_populatecreditstatus implements Schedulable{
  
    global void execute(SchedulableContext SC){ 
        Batch_CheckAccountCreditStatus obj = new Batch_CheckAccountCreditStatus();
        Database.executeBatch(obj ,1); 
    }
    
}