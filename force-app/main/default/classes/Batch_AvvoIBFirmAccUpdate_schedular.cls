/***************
 * Class Name: Batch_AvvoIBFirmAccUpdate_schedular
 * Test Class: Test_AvvoAttyStatusUpdate_cls
 * Description: This schedular class updates the customer status and order status 
 *         on the Avvo Firm accounts with >19 child accounts based on the Advertising status field.
 * Developed By: Ieswarya J
 * Modification History : Created on Aug 21,2020
 * 
 * 
 * ******/
 global class Batch_AvvoIBFirmAccUpdate_schedular implements Schedulable{
  global void execute(SchedulableContext SC) { 
    Batch_AvvoIBFirmAccUpdate_Cls btc = new Batch_AvvoIBFirmAccUpdate_Cls();
    Database.executeBatch(btc,1); 
   }
  }