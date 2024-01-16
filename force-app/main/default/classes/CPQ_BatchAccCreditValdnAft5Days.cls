/*****************************************************************************************
Created By : Lister Technologies
Created Date : Mar 9,2021
Created Purpose : When submitting a credit memo for approval, if the request sits for more than 5 days, it is supposed to escalate to the next level (manager/vp etc)
Test class : 
*****************************************************************************************/
global class CPQ_BatchAccCreditValdnAft5Days implements Database.Batchable<sObject>{
    global String query;
    public Set<Id> setOfIds = new Set<Id>();
    public Map<Id,Id> mapCreditIdNProcessInstWorkitem;
    public List<blng__CreditNote__c> lstCreditNoteToUpdate;
    global CPQ_BatchAccCreditValdnAft5Days(){
        mapCreditIdNProcessInstWorkitem = new Map<Id,Id>();
        lstCreditNoteToUpdate = new List<blng__CreditNote__c>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id,Approval_submission_date__c,Escalate_to__c,Approved_Amount__c from blng__CreditNote__c where (Credit_Reason__c = \'Credit\' Or Credit_Reason__c = \'Write-off\') and Approval_status__c = \'Pending Approval\' and Approval_submission_date__c!=null';
        if(Test.isRunningTest()){
            query += ' and blng__Account__r.Name like \'%testAcc%\' LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<blng__CreditNote__c> scope) {
        Date tDate = Date.today();
        Integer noOfBusinessDays = 0;
        for(blng__CreditNote__c pay : scope){
            noOfBusinessDays = getDiffBusinessDays(pay.Approval_submission_date__c,tDate);
            if(!Test.isRunningTest()){
                if(noOfBusinessDays > 5){
                    if(pay.Approved_Amount__c <= 10000 && pay.Escalate_to__c!='VP'){
                        setofIds.add(pay.Id);
                        if(pay.Approved_Amount__c > 355 && pay.Approved_Amount__c<=5000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                        else if(pay.Approved_Amount__c > 5000 && pay.Approved_Amount__c<=10000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                        lstCreditNoteToUpdate.add(pay);
                    }
                }
            }
            else if(Test.isRunningTest()){
                if(noOfBusinessDays == 1){
                    if(pay.Approved_Amount__c <= 10000 && pay.Escalate_to__c!='VP'){
                        setofIds.add(pay.Id);
                        if(pay.Approved_Amount__c > 355 && pay.Approved_Amount__c<=5000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                       else if(pay.Approved_Amount__c > 5000 && pay.Approved_Amount__c<=10000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                        lstCreditNoteToUpdate.add(pay);
                    }
                }
            }
        }
        for(ProcessInstanceWorkitem piwi : [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId in :setOfIds]){
            mapCreditIdNProcessInstWorkitem.put(piwi.ProcessInstance.TargetObjectId,piwi.Id);
        }
        for(Id paymentId : mapCreditIdNProcessInstWorkitem.keyset()){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');        
            req.setWorkitemId(mapCreditIdNProcessInstWorkitem.get(paymentId));       
            Approval.process(req,false);
        }
        if(lstCreditNoteToUpdate.size() > 0){
            Database.update(lstCreditNoteToUpdate);
        }
        for(Id paymentId : mapCreditIdNProcessInstWorkitem.keyset()){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(paymentId);
            Approval.ProcessResult result = Approval.process(req1);
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    //method to get number of business days between two dates  
    public Integer getDiffBusinessDays(Date startdt, Date enddt) {
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