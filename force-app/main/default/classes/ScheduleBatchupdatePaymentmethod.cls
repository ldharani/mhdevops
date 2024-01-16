global class ScheduleBatchupdatePaymentmethod  implements Schedulable{
  global void execute(SchedulableContext SC) { 
    BatchupdatePaymentmethod b = new BatchupdatePaymentmethod();
    Database.executeBatch(b,5); 
  }
}