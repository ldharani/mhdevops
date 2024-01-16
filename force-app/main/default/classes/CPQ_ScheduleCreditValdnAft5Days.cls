/*****************************************************************************************
Created By : Lister Technologies
Created Date : Mar 9,2021
Created Purpose : When submitting a credit memo for approval, if the request sits for more than 5 days, it is supposed to escalate to the next level (manager/vp etc)
Test class : 
*****************************************************************************************/
global class CPQ_ScheduleCreditValdnAft5Days implements Schedulable{
  global void execute(SchedulableContext SC) { 
    CPQ_BatchCreditValdnAft5Days b = new CPQ_BatchCreditValdnAft5Days();
    Database.executeBatch(b); 
  }
}