global class ScheduleBatchUpdateQuoteStartDate implements Schedulable{
  global void execute(SchedulableContext SC) { 
    BatchUpdateQuoteStartDate b = new BatchUpdateQuoteStartDate();
    Database.executeBatch(b,5); 
  }
}