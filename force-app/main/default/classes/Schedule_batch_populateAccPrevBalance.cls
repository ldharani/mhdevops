/** Scheduler class for Batch_populateAccPrevBalance
Test class : Test_Batch_populateAccPrevBalance.apxc
**/ 
global class Schedule_batch_populateAccPrevBalance implements Schedulable{
  
    global void execute(SchedulableContext SC){ 
        Batch_populateAccPrevBalance obj = new Batch_populateAccPrevBalance();
        Database.executeBatch(obj); 
  	}
    
}