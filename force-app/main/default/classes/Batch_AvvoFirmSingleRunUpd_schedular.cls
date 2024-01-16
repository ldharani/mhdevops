/***************
 * Class Name: Batch_AvvoFirmSingleRunUpd_schedular
 * Test Class: Test_AvvoAttyStatusUpdate_cls
 * Description: This schedular class updates the customer status and order status 
 *         on the Avvo Firm accounts based on the Avvo atty accounts.
 * Developed By: Ieswarya J
 * Modification History : Created on Aug 21,2020
 * 
 * 
 * ******/
 global class Batch_AvvoFirmSingleRunUpd_schedular implements Schedulable{
  global void execute(SchedulableContext SC) { 
    Batch_AvvoFirmSingleRunUpdate_Cls btc = new Batch_AvvoFirmSingleRunUpdate_Cls();
    Database.executeBatch(btc,1); 
   }
  }