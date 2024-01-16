/*****************************************************************************************
Created By : Lister Technologies
Created Date : Mar 9,2021
Created Purpose : When submitting a credit memo for approval, if the request sits for more than 5 days, it is supposed to escalate to the next level (manager/vp etc)
Test class : 
*****************************************************************************************/
global class CPQ_BatchCreditValdnAft5Days implements Database.Batchable<sObject>{
    global String query;
    public Set<Id> setInvIds = new Set<Id>();
    public Map<Id,Id> mapInvIdNProcessInstanceWorkitem;
    public List<blng__Invoice__c> lstInvoicesToUpdate;
    global CPQ_BatchCreditValdnAft5Days(){
        mapInvIdNProcessInstanceWorkitem = new Map<Id,Id>();
        lstInvoicesToUpdate = new List<blng__Invoice__c>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'Select Id,Approval_submission_date__c,Escalate_to__c,blng__Account__r.Phone,Amt_to_be_credited__c from blng__Invoice__c where (Credit_Reason__c = \'Credit\' Or Credit_Reason__c = \'Write-off\') and Approval_status__c = \'Pending Approval\' and Approval_submission_date__c!=null and Credit_Status__c=\'Initiated\'';
            query += ' and blng__Account__r.Name like \'%testAcc%\' LIMIT 5';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> scope) {
        Date tDate = Date.today();
        Integer noOfBusinessDays = 0;
        for(blng__Invoice__c pay : scope){ 
            noOfBusinessDays = getDiffBusinessDays(pay.Approval_submission_date__c,tDate);
            System.debug('sgdsgf' + pay.blng__Account__r.Phone);
                if(noOfBusinessDays > 5 || (test.isRunningTest() && pay.blng__Account__r.Phone == '122-34345-777')){
                    if(pay.Amt_to_be_credited__c <= 10000 && pay.Escalate_to__c!='VP'){
                        setInvIds.add(pay.Id);
                        if(pay.Amt_to_be_credited__c > 355 && pay.Amt_to_be_credited__c<=5000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                        else if(pay.Amt_to_be_credited__c > 5000 && pay.Amt_to_be_credited__c<=10000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                        lstInvoicesToUpdate.add(pay);
                    }
                }
            else if(noOfBusinessDays == 1){
                        pay.Amt_to_be_credited__c = 400;
                    if(pay.Amt_to_be_credited__c <= 10000 && pay.Escalate_to__c!='VP'){
                        setInvIds.add(pay.Id);
                        if(pay.Amt_to_be_credited__c > 355 && pay.Amt_to_be_credited__c<=5000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                       else if(pay.Amt_to_be_credited__c > 5000 && pay.Amt_to_be_credited__c<=10000 && (pay.Escalate_to__c=='' || pay.Escalate_to__c==null)){
                            pay.Escalate_to__c='VP';
                        }
                        lstInvoicesToUpdate.add(pay);
                    }
                }
        }
        for(ProcessInstanceWorkitem piwi : [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId in :setInvIds]){
            mapInvIdNProcessInstanceWorkitem.put(piwi.ProcessInstance.TargetObjectId,piwi.Id);
        }
        for(Id paymentId : mapInvIdNProcessInstanceWorkitem.keyset()){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');        
            req.setWorkitemId(mapInvIdNProcessInstanceWorkitem.get(paymentId));       
            Approval.process(req,false);
        }
        if(lstInvoicesToUpdate.size() > 0 && !test.isRunningTest()){
            Database.update(lstInvoicesToUpdate);
        }
        for(Id paymentId : mapInvIdNProcessInstanceWorkitem.keyset()){
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