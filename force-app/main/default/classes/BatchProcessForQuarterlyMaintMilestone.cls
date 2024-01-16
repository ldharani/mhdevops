/*****************************************************************************************
Created By : Ronak Jain
Created Date : July 27,2017
Created Purpose : Platinum Project Quarterly Maintenance Milestone process
*****************************************************************************************/

global class BatchProcessForQuarterlyMaintMilestone implements Database.Batchable<sObject>{
    global String query;
    public Date todayDate;
    public set<Id> projectIds;
    public Map<String, Product_code_to_Project_Mapping__c> MilestonesMap;
    public set<id> insertMilestoneId;
    public List<MileStone__mdt> milestones;
    public List<Milestone1_Project__c> listProjectsToUpdate;
    public Set<Milestone1_Project__c> setProjectsToUpdate;
    public List<Milestone1_Project__c> actualProjectsToUpdate;
    public List<SObject> updateTasksNMilestone;
    public Map<Id,List<Task__mdt>> milestoneIdVsTasks;
    public List<Sobject> allRecords;         
    
    global BatchProcessForQuarterlyMaintMilestone(){
        query='';
        insertMilestoneId = new Set<Id>();
        milestoneIdVsTasks = new Map<Id,List<Task__mdt>>();
        projectIds = new set<Id>();
        allRecords = new List<SObject>();
        listProjectsToUpdate = new List<Milestone1_Project__c>();
        actualProjectsToUpdate = new List<Milestone1_Project__c>();
        setProjectsToUpdate = new Set<Milestone1_Project__c>();
        updateTasksNMilestone = new List<SObject>();
        //allRecordsMap = new Map<String, List<SObject>>(); 
        todayDate = Date.today();
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        query ='Select Id, name, Status__c,OwnerId,RecordTypeId,No_of_Quarterly_Main_Milestone__c,Next_Quarterly_Milestone_Maint_Date__c '+
            'From Milestone1_Project__c '+
            'where Status__c!=\'Cancelled\' AND Status__c!=\'Migrated to new order project\' AND (RecordType.DeveloperName = \'Platinum_Project\' or RecordType.DeveloperName = \'SEO_Platinum\') AND Next_Quarterly_Milestone_Maint_Date__c=:todayDate';
        return Database.getQueryLocator(query); //updated by saiv - 01/08/2020 - MHBS-3638
    }
    global void execute(Database.BatchableContext BC, List<Milestone1_Project__c> scope){
        System.debug('@@@@@List of projects in execute'+scope);
        
        MilestonesMap = Product_code_to_Project_Mapping__c.getAll();
        System.debug('======================milestonesMap===='+milestonesMap);
        System.debug('====MilestonesMap.containske'+MilestonesMap.containskey('SEO Quarterly Report Web Platinum'));
        System.debug('====MilestonesIDs==========='+MilestonesMap.get('SEO Quarterly Report Web Platinum').Milestone_Id__c);
        
        if(MilestonesMap.containskey('SEO Quarterly Report Web Platinum') && !MilestonesMap.isempty()){
            if(MilestonesMap.get('SEO Quarterly Report Web Platinum').Milestone_Id__c !='' || MilestonesMap.get('SEO Quarterly Report Web Platinum').Milestone_Id__c !=NULL ){
                insertMilestoneId.add(MilestonesMap.get('SEO Quarterly Report Web Platinum').Milestone_Id__c);
            }
        }
        System.debug('============insertMilestoneId======='+insertMilestoneId);//
        if(insertMilestoneId.size()>0){
            milestones = [select id, DeveloperName,MasterLabel,Owner_ID__c,RecordType__c,SNo__c ,
                          Owner_Type__c, Predecessor_sequence__c,Project__c,project__r.Id,
                          (select id, DeveloperName,MasterLabel,IsProjectManagerAssignment__c,Pln_Hrs__c,
                           EstimatedHours__c, MileStone__c, Owner_ID__c,Milestone__r.Id,
                           Owner_Type__c, Predecessor_sequence__c,SNo__c,
                           Priority__c, Status__c,Layover_Days__c,RecordType__c,TaskName__c   
                           from tasks__r
                          )
                          from MileStone__mdt 
                          where id IN:insertMilestoneId ];
            if(!milestones.isEmpty()){
                for(MileStone__mdt singleMilestone : milestones){
                    System.debug('=========Tasks under each Milestone=========='+singleMilestone.tasks__r);
                    System.debug('==========singleMilestone.tasks__r.size()====================='+singleMilestone.tasks__r.size());
                    if(singleMilestone.tasks__r.size() > 0){
                        List<Task__mdt> takslist = new List<Task__mdt>();
                        takslist                 = singleMilestone.tasks__r;
                        if(!takslist.isEmpty()){
                            if(!milestoneIdVsTasks.containskey(singleMilestone.id)){
                                milestoneIdVsTasks.put(singleMilestone.id, takslist);
                            }
                        }
                    }
                    
                }
            }
            for(Milestone1_Project__c proj : scope){
                projectIds.add(proj.Id);
                String projectId = String.valueOf(proj.Id).substring(0, 15);
                String noOfQuartMainMiles = String.valueOf(proj.No_of_Quarterly_Main_Milestone__c);
                String updatedNoOfMainMiles;
                System.debug('=========projectId'+projectId);
                if(proj.No_of_Quarterly_Main_Milestone__c!=NULL ){
                    proj.No_of_Quarterly_Main_Milestone__c = proj.No_of_Quarterly_Main_Milestone__c + 1 ;
                    updatedNoOfMainMiles = String.valueOf(proj.No_of_Quarterly_Main_Milestone__c);
                    listProjectsToUpdate.add(proj);
                }
                if(proj.Next_Quarterly_Milestone_Maint_Date__c !=NULL){
                    proj.Next_Quarterly_Milestone_Maint_Date__c = proj.Next_Quarterly_Milestone_Maint_Date__c + 90;
                    listProjectsToUpdate.add(proj);
                }
                setProjectsToUpdate.addALL(listProjectsToUpdate);
                actualProjectsToUpdate.addALL(setProjectsToUpdate);
                
                if(!milestones.isEmpty()){
                    for(MileStone__mdt milestone : milestones){
                        
                        MileStone__mdt milestoneToCreate                     = milestone;
                        Milestone1_Milestone__c tempMilestone    = new Milestone1_Milestone__c();
                        tempMilestone.Name                       = 'SEO Quarterly Report | '+proj.No_of_Quarterly_Main_Milestone__c;//milestone.MasterLabel;
                        tempMilestone.OwnerId                   = proj.OwnerId;
                        tempMilestone.Project__c                 = projectId;
                        tempMilestone.RecordTypeId               = milestone.RecordType__c;
                        tempMilestone.Predecessor_Seq_No__c      = milestone.Predecessor_sequence__c;
                        tempMilestone.SNo__c                     = milestone.SNo__c;
                        tempMilestone.Status__c                  = 'Ready to Start';
                        allRecords.add(tempMilestone);
                        
                        tempMilestone.mileStone_Extenal_ID__c      = proj.id + noOfQuartMainMiles + milestone.id + milestone.DeveloperName;
                        Milestone1_Milestone__c milestoneReferece = new Milestone1_Milestone__c(mileStone_Extenal_ID__c = tempMilestone.mileStone_Extenal_ID__c);
                        
                        if(!milestoneIdVsTasks.isEmpty()){
                            Milestone1_Task__c milestonetasktemp   = new Milestone1_Task__c();
                            for(Task__mdt tempTask : milestoneIdVsTasks.get(milestone.id)){
                                System.debug('==========Inside for Tasks==========='+tempTask);
                                Milestone1_Task__c milestonetask   = new Milestone1_Task__c();
                                milestonetask.Name                 = tempTask.TaskName__c;
                                milestonetask.Estimated_Hours__c   = tempTask.EstimatedHours__c;
                                milestonetask.Priority__c          = tempTask.Priority__c;
                                //milestonetask.Assigned_To__c       = tempTask.Owner_ID__c;
                                milestonetask.Project_Milestone__r      =milestoneReferece;
                                milestonetask.Task_Identifier__c   = tempMilestone.mileStone_Extenal_ID__c;
                                milestonetask.Issystem__c          = True;
                                milestonetask.Layover_Days__c      = tempTask.Layover_Days__c;
                                milestonetask.RecordTypeId         = tempTask.RecordType__c;
                                milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                //milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                milestonetask.Predecessor_Seq_No__c      = tempTask.Predecessor_sequence__c;
                                milestonetask.SNo__c                     = tempTask.SNo__c;
                                milestonetask.Pln_Hrs__c                 = tempTask.Pln_Hrs__c;
                                
                                if(tempTask.IsProjectManagerAssignment__c && tempTask.Owner_ID__c != null && string.valueof(tempTask.Owner_ID__c).startswith('00G')){
                                        milestonetask.Assigned_Onwer__c  = tempMilestone.OwnerId;
                                        milestonetask.assign_To_Type__c    = 'User';
                                }else{
                                        milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                        milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                }
                                if(milestonetask.Predecessor_Seq_No__c == Null){
                                    milestonetask.Task_Stage__c = 'Ready to Start';
                                }
                                allRecords.add(milestonetask);
                            }
                        }
                    }
                }
            }
            
        }
        
        if(!allRecords.isempty()){
            insert allRecords;
            system.debug('@@@@allRecords'+allRecords);
                
            List<Milestone1_Milestone__c> mileListPred = [Select id, name, Project__r.Id,SNo__c,Predecessor_Seq_No__c,Order_RPC_Id__c,(Select id, name,Project_Milestone__r.Id,Predecessor_Seq_No__c,Assigned_Onwer__c,assign_To_Type__c,SNo__c From Project_Tasks__r) From Milestone1_Milestone__c WHERE id in : allRecords]; //Assign Owner to Tasks 
        
            Map<String, Milestone1_Milestone__c> sonVsMilestoneMap =  new Map<String, Milestone1_Milestone__c>();
            Map<String, Milestone1_Task__c> snoVsTaskMap =  new Map<String, Milestone1_Task__c>();
            Map<string,List<Milestone1_Milestone__c>> projIdVsMilestonesAfter = new Map<string,List<Milestone1_Milestone__c>>();
            Map<string,List<Milestone1_Task__c>>      milstIdVsTasksAfter     = new Map<string,List<Milestone1_Task__c>>();
            
            if(!mileListPred.isEmpty()){
                for(Milestone1_Milestone__c mil : mileListPred){
                    string key = mil.Project__r.Id;
                    System.debug('=========key==========='+key);
                    system.debug('=============mil===================='+mil.id);
                    if(projIdVsMilestonesAfter.containsKey(key)){
                        projIdVsMilestonesAfter.get(key).add(mil);
                    }
                    else{
                        projIdVsMilestonesAfter.put(key, new List<Milestone1_Milestone__c>{mil});
                    }
                    System.debug('============projIdVsMilestonesAfter========'+projIdVsMilestonesAfter);
                    string snokey = mil.Project__r.Id + string.valueOf(mil.SNo__c);
                    sonVsMilestoneMap.put(snokey, mil);
                    
                    for(Milestone1_Task__c tas : mil.Project_Tasks__r){
                        string tkey = tas.Project_Milestone__r.Id ;                        
                        if(milstIdVsTasksAfter.containsKey(tkey)){
                            milstIdVsTasksAfter.get(tkey).add(tas);
                        }else{
                            milstIdVsTasksAfter.put(tkey, new List<Milestone1_Task__c>{tas});
                        }
                        string taskkey = tas.Project_Milestone__r.Id + string.valueOf(tas.SNo__c);
                        snoVsTaskMap.put(taskkey, tas);
                    } 
                }
            }
                if(!projIdVsMilestonesAfter.isEmpty()){
                     for(string projId : projIdVsMilestonesAfter.keySet()){
                         
                         if(projIdVsMilestonesAfter.get(projId).size() > 1){
                             List<Milestone1_Milestone__c> milestonesList = new List<Milestone1_Milestone__c>();
                             milestonesList  = projIdVsMilestonesAfter.get(projId);
                            
                             for(Milestone1_Milestone__c m : milestonesList){
                                 if(m.Predecessor_Seq_No__c !=Null){
                                        if(sonVsMilestoneMap.containskey(projId + string.valueOf(m.Predecessor_Seq_No__c))){
                                            m.Predecessor_Milestone__c = sonVsMilestoneMap.get(projId + string.valueOf(m.Predecessor_Seq_No__c)).id;                                    
                                            updateTasksNMilestone.add(m);
                                        } 
                                 }
                                 
                             }
                         }
                     }
                }
                if(!milstIdVsTasksAfter.isEmpty()){
                     for(string msId : milstIdVsTasksAfter.keySet()){
                         if(milstIdVsTasksAfter.get(msId).size() > 1){
                             List<Milestone1_Task__c> taskList = new List<Milestone1_Task__c>();
                             taskList  = milstIdVsTasksAfter.get(msId);
                             for(Milestone1_Task__c t : taskList){
                                 if(t.Predecessor_Seq_No__c !=Null){
                                     system.debug('@@@@@@msId + string.valueOf(t.Predecessor_Seq_No__c)'+msId + string.valueOf(t.Predecessor_Seq_No__c));
                                     if(snoVsTaskMap.containskey(msId + string.valueOf(t.Predecessor_Seq_No__c))){
                                         t.Predecessor_Task__c = snoVsTaskMap.get(msId + string.valueOf(t.Predecessor_Seq_No__c)).id;                                    
                                         updateTasksNMilestone.add(t);
                                     } 
                                 }   
                             }
                         }
                     }
                 }
            
        }
        if(!actualProjectsToUpdate.isempty()){
            update actualProjectsToUpdate;
        }
        if(!updateTasksNMilestone.isempty()){
            update updateTasksNMilestone;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}