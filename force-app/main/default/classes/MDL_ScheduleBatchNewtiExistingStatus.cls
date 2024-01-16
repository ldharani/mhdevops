// author      : sai
// Description : Schedule Class for MDL_BatchNewtoExistingStatus


global class MDL_ScheduleBatchNewtiExistingStatus implements Schedulable {
    global void execute(SchedulableContext sc) {
    	MDL_BatchNewtoExistingStatus batchcalling = new MDL_BatchNewtoExistingStatus();
    	database.executebatch(batchcalling, 100); 
    }
}