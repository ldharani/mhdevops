global class  ScheduleBatchOrderConfirmation implements Schedulable{
  global void execute(SchedulableContext SC) { 
    BatchOrderConfirmation b = new BatchOrderConfirmation();
    Database.executeBatch(b); 
  }
}