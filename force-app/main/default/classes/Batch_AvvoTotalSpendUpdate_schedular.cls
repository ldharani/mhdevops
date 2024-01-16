global class Batch_AvvoTotalSpendUpdate_schedular implements Schedulable{
  global void execute(SchedulableContext SC) { 
    Batch_AvvoTotalSpendUpdate_Cls btc = new Batch_AvvoTotalSpendUpdate_Cls();
    Database.executeBatch(btc,10); 
   }
  }