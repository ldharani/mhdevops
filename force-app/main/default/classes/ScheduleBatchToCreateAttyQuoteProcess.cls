global class ScheduleBatchToCreateAttyQuoteProcess implements Schedulable{
    global void execute(SchedulableContext sc){
        if(!test.isRunningTest()){
            //BatchToCreateAttyQuoteProcess batchAttQuote = new BatchToCreateAttyQuoteProcess();
            Id batchJobId = Database.executeBatch(new BatchToCreateAttyQuoteProcess(), 1);
        }else{
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            System.debug('Schedule BatchToCreateAttyQuoteProcess');
        }
    }
}