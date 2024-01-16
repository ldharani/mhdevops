global class MDL_ScheduleCreditValidationAfter5Days implements Schedulable{
  global void execute(SchedulableContext SC) { 
    MDL_BatchCreditValidationAfter5Days b = new MDL_BatchCreditValidationAfter5Days();
    Database.executeBatch(b); 
  }
}