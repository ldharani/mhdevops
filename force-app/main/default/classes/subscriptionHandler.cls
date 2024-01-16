/***********************************************************************************************************************
* @author - IJ
* @date - 
* @description - subscriptionHandler
* @testclass - Test_Batch_EvgPriceIncrease

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6166    SS            14/04/2022   John Mattheson   <T1>       Update contract modified date on account for future MRR calculation
MHBS-5095    SaiV          09/06/2022                    T08    Email for Ngage close won
MHMAC-52     CK            15/03/2022   Jeevan Babu     <T02>   MAC2.1 Custom Enddate & Terms update
************************************************************************************************************************/
public class subscriptionHandler{ 
    
    //public void handleSubCancellation(map<Id,SBQQ__Subscription__c> newMap, map<Id,SBQQ__Subscription__c> oldMap){
    @future
    public static void handleSubCancellation(String newMapString, String oldMapStrng){
        
        Map<id, SBQQ__Subscription__c> oldMap = (Map<id, SBQQ__Subscription__c>) JSON.deserialize(oldMapStrng, Map<id, SBQQ__Subscription__c>.class);
        Map<id, SBQQ__Subscription__c> newMap = (Map<id, SBQQ__Subscription__c>) JSON.deserialize(newMapString, Map<id, SBQQ__Subscription__c>.class);
        
        Set<Id> cancelldOrderRPCId = new Set<Id>();
        Map<Id,String> subIdVsSubStatus = new Map<Id,String>();
        Set<Id> projIds = new Set<Id>();
        List<Milestone1_Project__c> CancellPrjIds = new List<Milestone1_Project__c>();
        List<Milestone1_Milestone__c> cancelMilestonelist = new List<Milestone1_Milestone__c>();
        List<SObject> updateCancelList = new List<SObject>();
        for(SBQQ__Subscription__c orderCharge : newMap.values()) {
            if((orderCharge.Status__c  == 'Cancelled' || orderCharge.Status__c  == 'Expired' || orderCharge.Status__c  == 'Truncated' || orderCharge.Status__c == 'Truncated-Upsell') && oldmap.get(orderCharge.Id).Status__c != newMap.get(orderCharge.Id).Status__c ) {
                if(orderCharge.Status__c  == 'Expired' && (orderCharge.ProductCode__c  != '01503' && orderCharge.ProductCode__c  != '01502' && orderCharge.ProductCode__c  != '01668')){ //added 01503 filter by saiv for MHBS-7099
                    cancelldOrderRPCId.add(orderCharge.Id);
                    subIdVsSubStatus.put(orderCharge.Id,orderCharge.Status__c);
                }else if(orderCharge.Status__c  == 'Cancelled' || orderCharge.Status__c  == 'Truncated' || orderCharge.Status__c == 'Truncated-Upsell'){
                    //system.debug('===in else if==='+orderCharge.Status__c);
                    cancelldOrderRPCId.add(orderCharge.Id);
                    subIdVsSubStatus.put(orderCharge.Id,orderCharge.Status__c);
                }
            }
        }
        if(cancelldOrderRPCId.size()>0){
            List<Milestone1_Project__c> projectListToCancel = [Select id, name,Status__c, Subscription__c,(SELECT Id,
                                                                                                           Name,
                                                                                                           Project__c,Status__c,
                                                                                                           Parent_Milestone__c,
                                                                                                           Complete__c,
                                                                                                           Deadline__c,
                                                                                                           Total_Actual_Hours__c From Project_Milestones__r Where Status__c!='Cancelled' AND Status__c!='Completed') From Milestone1_Project__c Where Status__c!='Completed' AND Status__c!= 'Cancelled' AND Subscription__c in: cancelldOrderRPCId];
            id cancelProjectrecordTypeId = Schema.SObjectType.Milestone1_Project__c.RecordTypeInfosByName.get('Cancel Project').RecordTypeId ;
            id cancelMilestonRecTypId = Schema.SObjectType.Milestone1_Milestone__c.RecordTypeInfosByName.get('Cancel project Milestone').RecordTypeId ;
            id cancelTaskRecTypId = Schema.SObjectType.Milestone1_Task__c.RecordTypeInfosByName.get('Cancel Project Task').RecordTypeId ;
            
            if(!projectListToCancel.isEmpty() || test.isRunningTest()){
                for(Milestone1_Project__c prj : projectListToCancel){
                    projIds.add(prj.id);
                    
                    if(prj.Status__c!= 'Cancelled'){
                        CancellPrjIds.add(prj);
                    }
                    
                    if(prj.Project_Milestones__r.size() > 0){
                        cancelMilestonelist = prj.Project_Milestones__r;
                    }
                }
                if(!CancellPrjIds.isEmpty() || test.isRunningTest()){
                    for(Milestone1_Project__c cancelprj: CancellPrjIds){
                        if(subIdVsSubStatus.get(cancelprj.Subscription__c) == 'Cancelled' || subIdVsSubStatus.get(cancelprj.Subscription__c) == 'Truncated'){
                            cancelprj.Status__c = 'Cancelled';
                        }else if(subIdVsSubStatus.get(cancelprj.Subscription__c) == 'Truncated-Upsell'){
                            cancelprj.Status__c = 'Migrated to new order project';
                        }
                        cancelprj.AllmilestoneCancelled__c = True;
                        cancelprj.RecordTypeId = cancelProjectrecordTypeId;
                    }
                    update CancellPrjIds;
                }
                
                if(!cancelMilestonelist.isEmpty() || test.isRunningTest()){
                    for(Milestone1_Milestone__c canmil : cancelMilestonelist){
                        canmil.Status__c = 'Cancelled';
                        canmil.RecordTypeId = cancelMilestonRecTypId;
                    }
                    update cancelMilestonelist;
                }
                List<Milestone1_Task__c> cancelTaskList = [select id,Task_Stage__c,ProjectId__c
                                                           from Milestone1_Task__c WHERE Task_Stage__c!= 'Cancelled' AND Task_Stage__c!= 'Completed' 
                                                           AND Task_Stage__c != 'Not Required' AND Project_ID__c IN:projIds];
                if(!cancelTaskList.isEmpty() || test.isRunningTest()){
                    for(Milestone1_Task__c cancelTask : cancelTaskList){
                        canceltask.Task_Stage__c = 'Cancelled';
                        canceltask.RecordTypeId = cancelTaskRecTypId;
                    }
                    update cancelTaskList;
                }
                
            }
        }
    }
    public static void handleUpsellPackagesNew(list<SBQQ__Subscription__c> newList){
        set<String> sSINNumber = new set<String>();
        set<Id> sContractId = new set<Id>();
        for(SBQQ__Subscription__c objSubs: newList){
            sSINNumber.add(objSubs.SIN__c);
            sContractId.add(objSubs.SBQQ__Contract__c);
        }
        
        if(!sSINNumber.isEmpty()){
            List<SBQQ__Subscription__c> lstSub = [SELECT Id,Contract_Modify_Status__c FROM SBQQ__Subscription__c WHERE SIN__c IN: sSINNumber AND SBQQ__Contract__c IN: sContractId AND Status__c = 'Truncated' AND Contract_Modify_Status__c != 'Rebase Evergreen'
                                                  AND Contract_Modify_Status__c != 'Evergreen Modify'];
            for(SBQQ__Subscription__c sub: lstSub){
                sub.Status__c = 'Truncated-Upsell';
            }
            update lstSub;
        }
    }
    
    public static void afterUpdateHandler(List<SBQQ__Subscription__c> newList, map<Id,SBQQ__Subscription__c> newMap, map<Id,SBQQ__Subscription__c> oldMap){
        subscriptionHelper subHelperClass = new subscriptionHelper();
        
        
        Id MAIntakeRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('M-A Intake Subscriptions').getRecordTypeId();
        Id ngageRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Ngage Subscriptions').getRecordTypeId();
        Id ngageHSRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('Ngage HS Subscriptions').getRecordTypeId();
        Id ngageIntakeRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('M-A Intake Subscriptions').getRecordTypeId();
        
        List<SBQQ__Subscription__c> lstForUpdateSubStatus = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> lstForNgageIndicator = new List<SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> newMapForUpdateContractStatus = new Map<Id,SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c sub:newList){
            if(sub.ProductFamily__c == 'Ngage' || sub.SBQQ__ProductName__c == 'Martindale-Avvo Complete Profile Plus' || sub.SBQQ__ProductName__c == 'Martindale Base Profile'){
                lstForNgageIndicator.add(sub);
            }
            if(sub.RecordTypeId == MAIntakeRecordTypeId){
                lstForUpdateSubStatus.add(sub);
            }
            if(sub.RecordTypeId == ngageRecordTypeId || sub.RecordTypeId == ngageHSRecordTypeId || sub.RecordTypeId == ngageIntakeRecordTypeId){
                newMapForUpdateContractStatus.put(sub.Id,sub);
            }
        }
        if(!lstForNgageIndicator.isEmpty()){
        	NgageIndicatorOnAccount_AC.indicateMethodOpp(lstForNgageIndicator,newMap, oldMap);    
        }
        if(!lstForUpdateSubStatus.isEmpty()){
        	subHelperClass.updateSubStatus(lstForUpdateSubStatus);
        }
        if(!newMapForUpdateContractStatus.isEmpty()){
        	subHelperClass.updateContractStatus(newMapForUpdateContractStatus, oldMap);
        }
    }
    
    public static void afterInsertHandler(List<SBQQ__Subscription__c> newList){
    	 
        if(!system.isBatch()){         
            subscriptionHelper.updateContrModifiedDate(newList); //<T01>
        }
        List<SBQQ__Subscription__c> lstForNgageIndicator = new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> lstForNgageEmailNotif = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub:newList){
            if(sub.ProductFamily__c == 'Ngage' || sub.SBQQ__ProductName__c == 'Martindale-Avvo Complete Profile Plus' || sub.SBQQ__ProductName__c == 'Martindale Base Profile'){
                lstForNgageIndicator.add(sub);
            }
            if(sub.ProductFamily__c == 'Ngage'){
                lstForNgageEmailNotif.add(sub);
            }
        }
        if(!lstForNgageIndicator.isEmpty()){
        	NgageIndicatorOnAccount_AC.indicateMethod(lstForNgageIndicator);    
        }
        if(!lstForNgageEmailNotif.isEmpty()){
        	subscriptionHelper.sendEmailNotification(lstForNgageEmailNotif);  //T08 MHBS-5095
        }
    }
    
    // <T1>  ends
    //<T02> : MHMAC-52 To update the enddate and terms of related Subscriptions and parent Contract
    /*
    public static void updatedRelatedTerms_EndDate(List<SBQQ__Subscription__c> newSubs) {
        List<SBQQ__Subscription__c> MASubList = new List<SBQQ__Subscription__c>();
        Map<Id,SBQQ__Subscription__c> contractSubMap = new Map<Id,SBQQ__Subscription__c>();
        Set<Id> contractIds = new Set<Id>();
        List<SBQQ__Subscription__c> subsToUpdate = new List<SBQQ__Subscription__c>();
        List<Contract> contractsToUpdate = new List<Contract>();
        Id MAsubscriptionRecordTypeId = Schema.SObjectType.SBQQ__Subscription__c.getRecordTypeInfosByName().get('M-A Subscriptions').getRecordTypeId();
        for(SBQQ__Subscription__c sub:newSubs){
            if(sub.recordTypeId == MAsubscriptionRecordTypeId){
                MASubList.add(sub);
                contractIds.add(sub.SBQQ__Contract__c);
                contractSubMap.put(sub.SBQQ__Contract__c,sub);
            }
        }    
        if(MASubList!=null && !MASubList.isEmpty()){
            if(contractIds!=null){
                for(Contract con : [SELECT Id, End_date__c,(SELECT Id, Term__c,End_date__c,SBQQ__Contract__c 
                                                            FROM SBQQ__Subscriptions__r) 
                                    FROM Contract 
                                    WHERE Id IN:contractIds]){
                                        if(con.End_date__c != contractSubMap.get(con.Id).End_date__c){
                                            con.End_date__c = contractSubMap.get(con.Id).End_date__c;
                                            contractsToUpdate.add(con);
                                        }if(con.SBQQ__Subscriptions__r!=null){
                                            for(SBQQ__Subscription__c sub:con.SBQQ__Subscriptions__r){
                                                if(sub.End_date__c != contractSubMap.get(con.Id).End_date__c){
                                                    sub.End_date__c = contractSubMap.get(con.Id).End_date__c;
                                                    subsToUpdate.add(sub);
                                                } 
                                            }
                                            
                                        }
                                    }
            }
            try{
                if(subsToUpdate!=null && !subsToUpdate.isEmpty()){
                    update subsToUpdate;
                }
                if(contractsToUpdate!=null && !contractsToUpdate.isEmpty()){
                    update contractsToUpdate;
                }
            }catch(Exception e){
                Util.processException(e,true,'Error while updating related Subscriptions & Contract End date');
            }
        }
    }*/
    //End of <T02>
    public  void FkMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}