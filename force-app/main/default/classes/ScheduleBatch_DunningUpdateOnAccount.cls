global class ScheduleBatch_DunningUpdateOnAccount implements Schedulable{

    global void execute(SchedulableContext SC) {
   
        Batch_DunningUpdateOnAccount btc = new Batch_DunningUpdateOnAccount();
        Database.executeBatch(btc,10); 
    }

}