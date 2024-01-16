global class MDL_Batch_CreateCaseForInvoice implements Database.Batchable<sObject>,Database.Stateful {
    global Date ValidDueDate;
    
    public MDL_Batch_CreateCaseForInvoice(){
        ValidDueDate = date.Today().addDays(-90);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id , invoiceit_s__Due_Date__c ,invoiceit_s__Account__c , invoiceit_s__Account__r.Name, ' +
                        'RecordType.DeveloperName '+
                        'from invoiceit_s__Invoice__c ' + 
                        'where  invoiceit_s__Due_Date__c =: ValidDueDate '+
                        'And RecordType.DeveloperName = \'MH_Invoices\' ';
        if(Test.isRunningTest())  {
            query +=' LIMIT 5';
        }                 
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Invoice__c> scope) {
        system.debug('batch run ' + scope);
        List<Case> listOfCasesToInsert = new List<Case>();
         for(invoiceit_s__Invoice__c iterInv : scope){
            if(iterInv.RecordType.DeveloperName == 'MH_Invoices'){
                    Case tempCase = new Case();
                    tempCase.Subject = iterInv.invoiceit_s__Account__r.Name +' - Delinquent payment';
                    tempCase.AccountId = iterInv.invoiceit_s__Account__c;
                    tempCase.Type = 'Delinquent payment';
                    tempCase.Invoice__c = iterInv.Id;
                    listOfCasesToInsert.add(tempCase);
            }
        }
        
        if(listOfCasesToInsert.size() > 0)
            insert listOfCasesToInsert; 
            
        system.debug('after insertoo ' + listOfCasesToInsert);  
    }
    
    global void finish(Database.BatchableContext BC) {
       
    }
}