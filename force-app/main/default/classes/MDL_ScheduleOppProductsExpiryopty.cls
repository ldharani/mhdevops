global class MDL_ScheduleOppProductsExpiryopty implements Schedulable{
  global void execute(SchedulableContext SC) { 
    MDL_BatchOppProductsExpiryopty b = new MDL_BatchOppProductsExpiryopty();
    Database.executeBatch(b,1);
  }
}