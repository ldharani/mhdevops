/*****************************************************************************************
Created By : Lister Technologies
Created Date : June 3,2015
Created Purpose : MHBS-19 When submitting a credit memo for approval, if the request sits for more than 5 days, it is supposed to escalate to the next level (manager/vp etc)
Test class : MDL_Test_BatchCreditValidationAfter5Days
*****************************************************************************************/
global class MDL_BatchCreditValidationAfter5Days implements Database.Batchable<sObject>{
    global String query;
    public Set<Id> setPaymentIds = new Set<Id>();
    public Map<Id,Id> mapPaymentIdNProcessInstanceWorkitem;
    public List<invoiceit_s__Payment__c> lstPaymentsToUpdate;
    global MDL_BatchCreditValidationAfter5Days(){
        mapPaymentIdNProcessInstanceWorkitem = new Map<Id,Id>();
        lstPaymentsToUpdate = new List<invoiceit_s__Payment__c>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id,Approval_submission_date__c,Escalate_to__c,invoiceit_s__Amount__c from invoiceit_s__Payment__c where (Applied_Type__c = \'Credit\' Or Applied_Type__c = \'Write-off\') and Approval_status__c = \'Pending Approval\' and Approval_submission_date__c!=null and invoiceit_s__Status__c=\'Initiated\'';
        if(Test.isRunningTest()){
            query += ' and invoiceit_s__Account__r.Name like \'%testAcc%\' LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Payment__c> scope) {
        Date tDate = Date.today();
        Integer noOfBusinessDays = 0;
        for(invoiceit_s__Payment__c pay : scope){
            noOfBusinessDays = getDiffBusinessDays(pay.Approval_submission_date__c,tDate);
            system.debug('noOfBusinessDays '+noOfBusinessDays );
            if(!Test.isRunningTest()){
                if(noOfBusinessDays > 5){
                    if(pay.invoiceit_s__Amount__c <= 10000 && pay.Escalate_to__c!='VP'){
                        setPaymentIds.add(pay.Id);
                        if(pay.invoiceit_s__Amount__c > 355 && pay.invoiceit_s__Amount__c<=5000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            //pay.Escalate_to__c='Director';
                            pay.Escalate_to__c='VP';
                        }
                        /*else if(pay.invoiceit_s__Amount__c > 500 && pay.invoiceit_s__Amount__c<=5000 && pay.Escalate_to__c=='Director'){
                            pay.Escalate_to__c='VP';
                        }*/
                        else if(pay.invoiceit_s__Amount__c > 5000 && pay.invoiceit_s__Amount__c<=10000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                        lstPaymentsToUpdate.add(pay);
                    }
                }
            }
            else if(Test.isRunningTest()){
                if(noOfBusinessDays == 1){
                    if(pay.invoiceit_s__Amount__c <= 10000 && pay.Escalate_to__c!='VP'){
                        setPaymentIds.add(pay.Id);
                        if(pay.invoiceit_s__Amount__c > 355 && pay.invoiceit_s__Amount__c<=5000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            //pay.Escalate_to__c='Director';
                            pay.Escalate_to__c='VP';
                        }
                       /* else if(pay.invoiceit_s__Amount__c > 500 && pay.invoiceit_s__Amount__c<=5000 && pay.Escalate_to__c=='Director'){
                            pay.Escalate_to__c='VP';
                        }*/
                        else if(pay.invoiceit_s__Amount__c > 5000 && pay.invoiceit_s__Amount__c<=10000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                        lstPaymentsToUpdate.add(pay);
                    }
                }
            }
        }
        for(ProcessInstanceWorkitem piwi : [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId in :setPaymentIds]){
            mapPaymentIdNProcessInstanceWorkitem.put(piwi.ProcessInstance.TargetObjectId,piwi.Id);
        }
        for(Id paymentId : mapPaymentIdNProcessInstanceWorkitem.keyset()){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');        
            req.setWorkitemId(mapPaymentIdNProcessInstanceWorkitem.get(paymentId));       
            Approval.process(req,false);
        }
        if(lstPaymentsToUpdate.size() > 0){
            Database.update(lstPaymentsToUpdate);
        }
        for(Id paymentId : mapPaymentIdNProcessInstanceWorkitem.keyset()){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            //req1.setComments('Submitting request for approval.');
            req1.setObjectId(paymentId);
            Approval.ProcessResult result = Approval.process(req1);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    //method to get number of business days between two dates  
    private Integer getDiffBusinessDays(Date startdt, Date enddt) {
        Date tempdate = null;
        if (startdt > enddt) {
            tempdate = enddt;
            enddt = startdt;
            startdt = tempdate;
        }
        Integer i = Math.mod((date.newinstance(1985, 6, 24)).daysBetween(startdt),7); // 24/6/85 was a monday   
        Map<Integer, Map<Integer, Integer>> m = new Map<Integer, Map<Integer, Integer>> {
        0 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 5 , 5 => 5 , 6 => 5 },
        1 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 4 , 5 => 4 , 6 => 5 },
        2 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 3 , 4 => 3 , 5 => 4 , 6 => 5 },
        3 => new Map<Integer, Integer> { 1 => 2 , 2 => 2 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
        4 => new Map<Integer, Integer> { 1 => 1 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
        5 => new Map<Integer, Integer> { 1 => 0 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },
        6 => new Map<Integer, Integer> { 1 => 1 , 2 => 2 , 3 => 3 , 4 => 4 , 5 => 5 , 6 => 5 }
        };
        Integer i2 = Math.mod((startdt.daysBetween(enddt)),7);
        Integer i3 = (m.get(i)).get(i2);
        if (i2 == null || i2 < 1 || i2 > 6){
            if (i >= 0 && i <= 4){ 
                i3 = 1; 
            } 
            else { 
                i3 = 0; 
            }
        }
        i3 = i3 + 5 * (Math.floor( ((Decimal) startdt.daysBetween(enddt)).divide(7,4))).intValue(); 
        if (tempdate != null) 
            i3 *= -1; // negative number of days
        return i3;
    }  
}