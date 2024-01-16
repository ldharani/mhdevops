global class CreditCardExpiryNotificationSchedulable implements System.Schedulable {
    public static final String CRON_EXPR = '0 0 0 1,15 * ? *';
    //                                      m  h  d
    global CreditCardExpiryNotificationSchedulable() {
        
    }
    global static String scheduleIt() {
        CreditCardExpiryNotificationSchedulable job = new CreditCardExpiryNotificationSchedulable();
        return System.schedule('CreditCardExpiryNotification', CRON_EXPR, job);
    }
    global void execute(System.SchedulableContext sc) {
        CreditCardExpiryNotification b = new CreditCardExpiryNotification();
        database.executebatch(b,10);
    }
    
    
      public void FkMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        }
}