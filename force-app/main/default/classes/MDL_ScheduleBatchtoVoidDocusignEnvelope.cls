global class MDL_ScheduleBatchtoVoidDocusignEnvelope implements Schedulable{
  global void execute(SchedulableContext SC) { 
    MDL_BatchtoVoidDocusignEnvelope b = new MDL_BatchtoVoidDocusignEnvelope();
    Database.executeBatch(b,1);
  }
}