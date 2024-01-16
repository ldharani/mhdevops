//Author       : Sai
//Description  : Schedule class for BatchChangeaccountOrderStatusCancelled
//               which is schedule at everymonth end
//code to run for Schedule
// String sch = '0 0 20 L * ?';
//system.schedule('Update Account Order Status', new ScheduleOrderStatusCancelledbatch(), sch); 

global class ScheduleOrderStatusCancelledbatch implements Schedulable {
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new BatchChangeaccountOrderStatusCancelled(),10);
   }
}