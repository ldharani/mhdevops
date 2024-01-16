/***********************************************************************************************************************
 * @author - CK
 * @date - 15 Sep 2022
 * @description - To expire Subscriptions & Contracts that have end date older than a month from today. 
 					Also marks related quote as closed won and cancels related Project & Milestone.
 * @testclass - BatchToExpireOrdersContracts_Test
 * JIRA - MHBS-5341

Change History
************************************************************************************************************************

************************************************************************************************************************/

global class BatchToExpireContractsOfLastMonth implements Database.Batchable<sObject>,Database.Stateful{
    private Boolean simulateSubscriptionDmlFailure = false;
    private Boolean simulateContractDmlFailure = false;
    private Boolean simulateQuoteDmlFailure = false;
    global string csvBodySubscription;
    global string headerValueSubscription;
    global string csvBodyContract;
    global string headerValueContract;
    global string csvBodyQuote;
    global string headerValueQuote;
    global List<Id> oItemIdList = new List<Id>();
    global List<Id> subscriptionIdList = new List<Id>();
    List<id> subscriptionIds;
    // Constructor1 to run the job for a list of Subscriptions
    public BatchToExpireContractsOfLastMonth(List<id> subscriptionIds){
        system.debug('In C1');
        this.subscriptionIds = subscriptionIds;
        csvBodySubscription = '';
        headerValueSubscription = 'Subscription Id, Error Message \n';
        csvBodyContract = '';
        headerValueContract = 'Subscription Id, Error Message \n';
        csvBodyQuote = '';
        headerValueQuote = 'Quote Id, Error Message \n';
    } //End of Constructor1
    // Constructor to run the job once the Order Products are Expired
    public BatchToExpireContractsOfLastMonth(List<id> orderItemIds,Boolean isCalledfromOrderBatch){
        system.debug('In C2');
        this.oItemIdList=orderItemIds;
        headerValueSubscription = 'Subscription Id, Error Message \n';
        csvBodyContract = '';
        headerValueContract = 'Subscription Id, Error Message \n';
        csvBodyQuote = '';
        headerValueQuote = 'Quote Id, Error Message \n';
    }//End of Constructor2
    //Default constructor runs when the class is scheduled
    public BatchToExpireContractsOfLastMonth(){
        system.debug('In C3');
        csvBodySubscription = '';
        headerValueSubscription = 'Subscription Id, Error Message \n';
        csvBodyContract = '';
        headerValueContract = 'Subscription Id, Error Message \n';
        csvBodyQuote = '';
        headerValueQuote = 'Quote Id, Error Message \n';
    }//End of Constructor3
    //Constructor runs when the class is scheduled from test class for validating DML failure scenario
    public BatchToExpireContractsOfLastMonth(Boolean simulateSubscriptionDmlFailure,Boolean simulateContractDmlFailure, Boolean simulateQuoteDmlFailure){
        this.simulateSubscriptionDmlFailure = simulateSubscriptionDmlFailure;
        this.simulateContractDmlFailure = simulateContractDmlFailure;
        this.simulateQuoteDmlFailure = simulateQuoteDmlFailure;
    }//End of Constructor4
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        if(oItemIdList!=null && !oItemIdList.isEmpty()){
            query = 'SELECT Id, SBQQ__Contract__c, SBQQ__Contract__r.Status__c, Status__c FROM SBQQ__Subscription__c WHERE SBQQ__OrderProduct__c IN: oItemIdList AND SBQQ__EndDate__c = LAST_N_MONTHS:1 AND Status__c = \'Active\'';
        }
        else if(subscriptionIds!=null && !subscriptionIds.isEmpty()){
            system.debug('subscriptionIds '+subscriptionIds);
            Set<id> subIds = new Set<Id>();
            subIds.addAll(subscriptionIds);
            query = 'SELECT Id, SBQQ__Contract__c, SBQQ__Contract__r.Status__c, Status__c FROM SBQQ__Subscription__c WHERE Id IN: subIds AND SBQQ__EndDate__c = LAST_N_MONTHS:1 AND Status__c = \'Active\'';
        }else{
            query = 'SELECT Id, SBQQ__Contract__c, SBQQ__Contract__r.Status__c, Status__c FROM SBQQ__Subscription__c WHERE SBQQ__EndDate__c = LAST_N_MONTHS:1 AND Status__c = \'Active\'';
        }
        system.debug('Query '+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<SBQQ__Subscription__c> subsciptionList){
        system.debug('subsciptionList '+subsciptionList);
        List<SBQQ__Subscription__c> subscriptionUpdateList = new List<SBQQ__Subscription__c>();
        Set<Id> contractstoExpire =  new Set<Id>();
        List<Contract> contractUpdateList =  new List<Contract>();
        List<SBQQ__Quote__c> quoteUpdateList =  new List<SBQQ__Quote__c>();
        Set<Id> quotesToCloseLost = new Set<Id>();
        Set<Id> subIdsForProjectCancellation = new Set<Id>();
        try{
            //Setting & Updating Subscription status as Expired
            if(subsciptionList!=null && !subsciptionList.isEmpty()){
                for(SBQQ__Subscription__c sub : subsciptionList){
                    if (Test.isRunningTest() && simulateSubscriptionDmlFailure){
                        // Simulate a DML failure
                        sub.SBQQ__Account__c = sub.Id;
                        subscriptionUpdateList.add(sub); // This will cause a DML exception
                        if(sub.SBQQ__Contract__r.Status__c!='Expired'){
                            contractstoExpire.add(sub.SBQQ__Contract__c);
                        }
                    }else{
                        sub.Status__c = 'Expired';
                        subscriptionUpdateList.add(sub);
                        subIdsForProjectCancellation.add(sub.id);
                        if(sub.SBQQ__Contract__r.Status__c!='Expired'){
                            contractstoExpire.add(sub.SBQQ__Contract__c);
                        }
                    }
                }
            }
            if(subscriptionUpdateList!=null && !subscriptionUpdateList.isEmpty()){
                Database.SaveResult[] srListSubscription = Database.update(subscriptionUpdateList, false);
                system.debug('srListSubscription '+srListSubscription);
                for (Database.SaveResult sr : srListSubscription) {
                    if(sr.isSuccess()){
                        system.debug('Successfully Updated Subscription!');
                        subscriptionIdList.add(sr.getId());
                    }else{
                        system.debug('sr '+sr);
                        string errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            system.debug('Failed ID '+sr.getId());
                            csvBodySubscription += sr.getId() + ',';
                            errorMsg += err.getMessage() + ',';
                            
                        }
                        errorMsg = errorMsg.removeEnd(',');
                        csvBodySubscription += '"'+errorMsg + '"' + ','; 
                        csvBodySubscription += '\n';
                    }
                }
            }
            if(contractstoExpire!=null && !contractstoExpire.isEmpty()){
                for(SBQQ__Subscription__c subs : [Select Id,Status__c,SBQQ__Contract__c From SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: contractstoExpire]){
                    if(subs.Status__c != 'Expired'){
                        contractstoExpire.remove(subs.SBQQ__Contract__c);
                    } 
                }
            }//End of subscription expiration
            //Setting & Updating Contract status as Expired
            if(contractstoExpire!=null && !contractstoExpire.isEmpty()){
                for(Contract contrct : [SELECT Id, Status__c,SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Status__c,AccountId FROM Contract WHERE Id IN:contractstoExpire]){
                    if (Test.isRunningTest() && simulateContractDmlFailure){
                        // Simulate a DML failure
                        contrct.AccountId = contrct.Id;
                        contractUpdateList.add(contrct); // This will cause a DML exception
                        
                    }else{
                        contrct.Status__c = 'Expired';
                        contractUpdateList.add(contrct);
                    }
                }
                for(SBQQ__Quote__c quo : [SELECT Id,Modified_Contract__c from SBQQ__Quote__c where SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Id IN:contractstoExpire]){
                    if (Test.isRunningTest() && simulateQuoteDmlFailure){
                        // Simulate a DML failure
                        //quo.SBQQ__BookingsIndicator__c = 'SBQQ__BookingsIndicator__c';
                        quotesToCloseLost.add(quo.Id); // This will cause a DML exception
                        }else{
                        quotesToCloseLost.add(quo.Id);
                    }
                }
            }
            if(contractUpdateList!=null && !contractUpdateList.isEmpty()){
                Database.SaveResult[] srListContract = Database.update(contractUpdateList, false);
                system.debug('srListContract '+srListContract);
                for (Database.SaveResult sr : srListContract) {
                    if(sr.isSuccess()){
                        system.debug('Successfully Updated Contract!');
                    }else{
                        system.debug('sr '+sr);
                        string errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            system.debug('Failed ID '+sr.getId());
                            csvBodyContract += sr.getId() + ',';
                            errorMsg += err.getMessage() + ',';
                            
                        }
                        errorMsg = errorMsg.removeEnd(',');
                        csvBodyContract += '"'+errorMsg + '"' + ','; 
                        csvBodyContract += '\n';                
                    }
                }
            }//End of Contract expiration
            //Setting & Updating corresponding Quote status as Closed 
            if(quotesToCloseLost!=null && !quotesToCloseLost.isEmpty()){
                for(Id quoteID: quotesToCloseLost){
                    SBQQ__Quote__c quote = new SBQQ__Quote__c(id=quoteID);
                    if(quote.SBQQ__Status__c != 'Closed Lost'){
                        quote.SBQQ__Status__c = 'Closed Lost';
                        quote.Reason_Won_Lost__c = 'Order Expired';
                        quoteUpdateList.add(quote);
                    }
                }
                Database.SaveResult[] srListQuote = Database.update(quoteUpdateList, false);
                system.debug('srListContract '+srListQuote);
                for (Database.SaveResult sr : srListQuote) {
                    if(sr.isSuccess()){
                        system.debug('Successfully Updated Quote!');
                    }else{
                        system.debug('sr '+sr);
                        string errorMsg = '';
                        for(Database.Error err : sr.getErrors()) {
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            system.debug('Failed ID '+sr.getId());
                            csvBodyQuote += sr.getId() + ',';
                            errorMsg += err.getMessage() + ',';
                            
                        }
                        errorMsg = errorMsg.removeEnd(',');
                        csvBodyQuote += '"'+errorMsg + '"' + ','; 
                        csvBodyQuote += '\n';                  
                    }
                }
            }
            //Sets the Project and Milestone status to Cancelled
            if(subIdsForProjectCancellation!=null && !subIdsForProjectCancellation.isEmpty()){
                CPQ_MilestoneHandler.handleCancelSub(subIdsForProjectCancellation,'Cancelled');
            }
        }catch(Exception e){
            Util.processException(e,true,'Error during Expiration process of Subscription & Contracts: '+ subscriptionUpdateList + contractUpdateList);
        }
    }
    public void finish(Database.BatchableContext BC){
        try{
            //Sends email whenever there is a failure in Contract/Subscription/Quote update
            String finalCsvSubscription = '';
            String finalCsvContract = '';
            String finalCsvQuote = '';
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            List<Month_end_expiration_email__c> emailSettingList = Month_end_expiration_email__c.getAll().values();
            if(csvBodySubscription != null && csvBodySubscription != ''){finalCsvSubscription = headerValueSubscription + csvBodySubscription;}
            if(csvBodyContract != null && csvBodyContract != ''){finalCsvContract = headerValueContract + csvBodyContract;}
            if(csvBodyQuote != null && csvBodyQuote != ''){finalCsvQuote = headerValueQuote + csvBodyQuote;}
            if((finalCsvSubscription != null && finalCsvSubscription != '')){
                String subscriptionCsvName= 'Subscription_Update_Errors.csv';
                Messaging.EmailFileAttachment csvAttcSubscription = new Messaging.EmailFileAttachment();
                csvAttcSubscription.setFileName(subscriptionCsvName);
                csvAttcSubscription.setBody(Blob.valueOf(finalCsvSubscription));
                efaList.add(csvAttcSubscription);
            }
            if((finalCsvContract != null && finalCsvContract != '')){
                String contractCsvName= 'Order_Update_Errors.csv';
                Messaging.EmailFileAttachment csvAttcContract = new Messaging.EmailFileAttachment();
                csvAttcContract.setFileName(contractCsvName);
                csvAttcContract.setBody(Blob.valueOf(finalCsvContract));
                efaList.add(csvAttcContract);
            }
            if((finalCsvQuote!= null && finalCsvQuote != '')){
                String quoteCsvName= 'Quote_Update_Errors.csv';
                Messaging.EmailFileAttachment csvAttcQuote = new Messaging.EmailFileAttachment();
                csvAttcQuote.setFileName(quoteCsvName);
                csvAttcQuote.setBody(Blob.valueOf(finalCsvQuote));
                efaList.add(csvAttcQuote);
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{};
                for(Month_end_expiration_email__c email : emailSettingList){
                    String e1 = (String)email.Email__c;
                    toAddresses.add(e1);
                }
            if(toAddresses!=null && !toAddresses.isEmpty()){mail.setToAddresses(toAddresses);}
            mail.setSubject('Contracts Month End Expiration Errors ');
            mail.setPlainTextBody('Please check the attachments for Contract and/or Subscription errors encountered: ');
            if(!efaList.isEmpty()){        
                mail.setFileAttachments(efaList);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }catch(Exception e){
            Util.processException(e,true,'Error while sending Failure email from Contract Month End expiration');
        }
    }
}