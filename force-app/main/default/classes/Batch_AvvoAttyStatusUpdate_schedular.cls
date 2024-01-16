/***************
 * Class Name: Batch_AvvoAttyStatusUpdate_schedular
 * Test Class: Test_AvvoAttyStatusUpdate_cls
 * Description: This schedular class updates the customer status and order status 
 *         on the Avvo Atty accounts based on the Advertising status field.
 * Developed By: Ieswarya J
 * Modification History : Created on Aug 21,2020
 * 
 * 
 * ******/
 global class Batch_AvvoAttyStatusUpdate_schedular implements Schedulable{
  global void execute(SchedulableContext SC) { 
    Batch_AvvoAttyStatusUpdate_Cls btc = new Batch_AvvoAttyStatusUpdate_Cls();
    Database.executeBatch(btc,10); 
   }
  }