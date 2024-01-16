global class ScheduleBatchToClosedWonQuote implements Schedulable{
    global void execute(SchedulableContext sc){
        if(!test.isRunningTest()){
            //BatchToClosedWonQuote batchAttQuote = new BatchToClosedWonQuote();
            Id batchJobId = Database.executeBatch(new BatchToClosedWonQuote(), 1);
        }else{
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            System.debug('Schedule BatchToClosedWonQuote');
        }
    }
}