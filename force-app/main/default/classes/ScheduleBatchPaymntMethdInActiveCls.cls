global class ScheduleBatchPaymntMethdInActiveCls implements Schedulable{
  global void execute(SchedulableContext SC) { 
    BatchPaymntMethdInActiveCls b = new BatchPaymntMethdInActiveCls();
    Database.executeBatch(b, 1);
  }
}