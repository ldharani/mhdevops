global class CPQ_MDL_ScheduleBatchtoVoidDocusign implements Schedulable{
  global void execute(SchedulableContext SC) { 
    CPQ_MDL_BatchtoVoidDocusignEnvelope b = new CPQ_MDL_BatchtoVoidDocusignEnvelope();
    Database.executeBatch(b,1);
  }
}