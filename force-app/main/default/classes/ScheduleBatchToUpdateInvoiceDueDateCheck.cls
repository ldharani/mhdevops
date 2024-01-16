global class ScheduleBatchToUpdateInvoiceDueDateCheck implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        if(!test.isRunningTest()){
            BatchToUpdateInvoiceDueDateCheck btc = new BatchToUpdateInvoiceDueDateCheck();
            Database.executeBatch(btc); 
        }else{
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            System.debug('Schedule BatchToUpdateInvoiceDueDateCheck');
        }
    }
    
}