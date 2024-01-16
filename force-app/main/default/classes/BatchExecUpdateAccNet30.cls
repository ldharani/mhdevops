public class BatchExecUpdateAccNet30 implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id, RecordType.name, (SELECT Id FROM blng__AccountPaymentMethods__r) ';
        Query += ' FROM Account where ';
        Query += ' RecordType.name=\'M-H Account\' AND ';
        Query += ' Payment_Terms__c != \'Net 30\' ORDER BY Createddate DESC';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> lstAcc){
        List<Account> lstAccUpdate = new List<Account>();
        Account objAcc;
        for(Account acc: lstAcc){
            if(acc.blng__AccountPaymentMethods__r.isEmpty()){
                objAcc = new Account(Id=acc.Id);
                objAcc.Payment_Terms__c = 'Net 30';
                lstAccUpdate.add(objAcc);
            }
        }
        //system.assertEquals(lstAccUpdate.size(), 0);
        if(!lstAccUpdate.isEmpty()){
            update lstAccUpdate;
        }
    }

    public void finish(Database.BatchableContext BC){
    }
    /*
    // How to Execute?
    BatchExecUpdateAccNet30 objBatch = new BatchExecUpdateAccNet30();
    Database.executeBatch(objBatch, 200);
    */
}