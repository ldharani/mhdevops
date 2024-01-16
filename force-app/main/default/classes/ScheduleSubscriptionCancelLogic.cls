global class ScheduleSubscriptionCancelLogic    implements Schedulable{
  global void execute(SchedulableContext SC) { 
    SubscriptionCancelLogic b = new SubscriptionCancelLogic();
    Database.executeBatch(b,5); 
  }
}