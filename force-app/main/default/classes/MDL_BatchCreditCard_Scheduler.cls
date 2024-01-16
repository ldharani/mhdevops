/******************************************************************************************************************
Created By : Lister Technologies
Created Date : July 13th 2015
Created Purpose : MHBS-16 Send Credit Card Expiry Notification (Scheduler for MDL_BatchCreditCardEmailNotification)  
*******************************************************************************************************************/
global class MDL_BatchCreditCard_Scheduler  implements Schedulable {
   global void execute(SchedulableContext sc) {
      MDL_BatchCreditCardEmailNotification b = new MDL_BatchCreditCardEmailNotification (); 
      database.executebatch(b,4);
   }
}