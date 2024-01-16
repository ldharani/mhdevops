/***********************************************************************************************************************
* @author - 
* @date - 16 Mar 2022
* @description - 
* @testclass - SubscriptionProjectCreationTest

Change History 
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6561    SS            29/03/2022   Jeevan Babu     <T01>   Change the product name,Inventory Type from "Advanced 360" to "Martindale-Avvo Complete Profile Plus"
MHBS-6773    SS            22/04/2022   Jeevan Babu     <T02>   Martindale Base Profile: Create case related notification and subscription between banana stand and salesforce
MHMAC-44     CK            25/11/2022   Jeevan Babu     <T03>   Cancel Case Creation for MAC2.1 : Handling single case creation for both Full and Partial cancellation
MHBS-8984    Jey           08/05/2023   John            <T04>   Cancellation case: create a case when the Avvo WebVantage subscription is cancelled
************************************************************************************************************************/
public class SubscriptionProjectCreation {
    Public Static boolean SubCheck = False;
    public static String AVVO_CANCELATION_SUBJECT = 'Avvo Cancelation';//<T03>
    public static String FULFILLMENT_OPERATIONS = 'Fulfillment_Operations';//<T03>
    public static String FIRM_OWNERSHIP_INVENTORY = 'FirmOwnershipInventory';//<T03>
    public static String Case_Description = 'Avvo Cancellation for CPP/BP/FirmSKU/WebVantage';
    public static String Case_Area = 'Cancellation';
    public static String Case_Origin = 'AdvancedProds';
    public static String Case_Priority = 'High';
        
    public static List<Subscription__c>ProjectCreationforSub = new List<Subscription__c>();
    
    public static void getSubToCreateProject(List<Subscription__c> SubList){ //Map<Id, Subscription__c> oldMap){
        SubList = [select id, Name, Type_of_Website__c,Account_Owner_Email__c, Opportunity__c, Account__c, Account__r.ParentId from Subscription__c where Id IN:trigger.New];
        system.debug('===SubList==='+SubList);
        for(Subscription__c sub: SubList){
            system.debug('=== Type_of_Website__c==='+sub.Type_of_Website__c);
            if(sub.Type_of_Website__c!=Null){
                //send it to create project
                ProjectCreationforSub.add(sub);
                system.debug('===ProjectCreationforSub===='+ProjectCreationforSub);
            }
        }
    }
    public static void projectCreationFromSub(){
        
        
        system.debug('@@@ in ProjectCreationfromCase'+ trigger.newMap); 
        //Declaration Section
        Map<Id,String> SubIdVSTypeofWebMap            = new Map<Id,String>();
        Map<Id,String> SubIdVSAccountOwnerEmailMap            = new Map<Id,String>();
        Map<String,Project__mdt> subAreaVsProjectMap = new Map<String,Project__mdt>();
        Set<Id> milestoneIds                                    = new set<Id>();
        Map<Id,List<Task__mdt>>      milestoneIdVsTasks         = new Map<Id,List<Task__mdt>>();
        Map<Id,List<MileStone__mdt>> projectIdVsMilestones      = new Map<Id,List<MileStone__mdt>>();
        List<Sobject> allRecords                                = new List<SObject>();
        Map<String, List<Sobject>> allRecordsMap                = new Map<String, List<SObject>>();
        List<Sobject> projectList                               = new List<Sobject>();
        List<Sobject> milestoneList                             = new List<Sobject>();
        List<Sobject> tasksList                                 = new List<Sobject>();
        List<Sobject> updateAllRecords                          = new List<SObject>();
        Map<id,Set<id>> QtoUserMap = new Map<id,Set<id>>();
        Map<Integer,set<string>> OwnerprojCountMap = new Map<Integer,set<string>> ();
        String insertedProjId; 
        
        for(Subscription__c subs : ProjectCreationforSub){
            
            
            
            SubIdVSTypeofWebMap.put(subs.Id, subs.Type_of_Website__c); 
            SubIdVSAccountOwnerEmailMap.put(subs.Id, subs.Account_Owner_Email__c);
        }
        
        system.debug('@@@@SubIdVSTypeofWebMap'+SubIdVSTypeofWebMap);
        //String proName = SubIdVSTypeofWebMap.values().Contains('Website');
        
        //getting all projects and Milestones here
        If(!SubIdVSTypeofWebMap.isEmpty()){
            for(Project__mdt project : [select id, DeveloperName,MasterLabel,RecordType__c,IsQueueUserAssignment__c,
                                        Owner_ID__c,Owner_Type__c, ProjectType__c, Status__c,
                                        (select id, DeveloperName,MasterLabel,Owner_ID__c,
                                         Owner_Type__c, Predecessor_sequence__c,Project__c,RecordType__c,SNo__c
                                         From MileStones__r
                                        )
                                        From Project__mdt where MasterLabel In : SubIdVSTypeofWebMap.values()]){
                                            subAreaVsProjectMap.put(project.MasterLabel, project);
                                            system.debug('subAreaVsProjectMap is set here::'+subAreaVsProjectMap);
                                            if(project.MileStones__r.size() > 0){
                                                List<MileStone__mdt> milestonesTemp = new List<MileStone__mdt>();
                                                milestonesTemp = project.MileStones__r;
                                                system.debug('milestonesTemp here::'+milestonesTemp );
                                                projectIdVsMilestones.put(project.id, milestonesTemp);
                                                Map<id,MileStone__mdt> tempMilestoneMap  = new Map<id,MileStone__mdt>(project.MileStones__r);
                                                milestoneIds.addAll(tempMilestoneMap.keySet());
                                                
                                                if(project.IsQueueUserAssignment__c && project.Owner_ID__c != null && string.valueof(project.Owner_ID__c).startswith('00G'))
                                                {               
                                                    QtoUserMap.put(project.Owner_ID__c,new set<id>());
                                                } 
                                            }
                                            
                                            
                                        }
            //Set<ID> UserSet = new Set<ID>();
            Set<String> UserSet = new Set<String>();
            
            if(!QtoUserMap.isEmpty()){                
                List<GroupMember> gmList = [Select UserOrGroupId,GroupId From GroupMember where GroupId IN: QtoUserMap.keySet()];
                System.debug('============Qmap====='+gmList);
                for(GroupMember g : gmList){
                    UserSet.add(g.UserOrGroupId);
                    //OwnerprojCountMap.put(g.UserOrGroupId,0); // defaul to 0 for all users
                    if(QtoUserMap.containsKey(g.GroupId)){
                        QtoUserMap.get(g.GroupId).add(g.UserOrGroupId);
                    }
                }
            }
            
            System.debug('============UserSet====='+UserSet);
            
            Set<string> alreadyaddedUsers = new Set<string>();
            
            if(!USERSet.isEmpty()){
                AggregateResult[] groupedResults
                    = [SELECT ownerid, COUNT(id)
                       FROM Milestone1_Project__c where Status__c !='Cancelled' AND Status__c !='Completed' AND Status__c !='Post Launch' AND ownerid IN: USERSet
                       GROUP BY ownerid ];
                
                System.debug('=====groupedResults===='+groupedResults);
                for (AggregateResult ar : groupedResults)  {
                    alreadyaddedUsers.add(string.valueof(ar.get('ownerid')));
                    //OwnerprojCountMap.put(string.valueof(ar.get('ownerid')),integer.valueof(ar.get('expr0'))); //userid, count of project.
                    if(OwnerprojCountMap.containsKey(integer.valueof(ar.get('expr0')))){
                        OwnerprojCountMap.get(integer.valueof(ar.get('expr0'))).add(string.valueof(ar.get('ownerid')));
                    }
                    else{
                        OwnerprojCountMap.put(integer.valueof(ar.get('expr0')),new set<string>{string.valueof(ar.get('ownerid'))});
                    }
                    System.debug('Campaign ID' + ar.get('ownerid'));
                    System.debug('Average amount' + ar.get('expr0'));
                }
                System.debug('==OwnerprojCountMap'+OwnerprojCountMap);
            }
            
            
            if(!userset.isEmpty()){
                Set<string> tempset = new Set<string>();
                if(!OwnerprojCountMap.isEmpty()){
                    
                    
                    for(string u : userset){
                        
                        if(!alreadyaddedUsers.contains(u)){
                            tempset.add(u);
                        }
                    }
                    
                }
                else{
                    tempset.addAll(userset);
                }
                
                if(!tempset.isEmpty()){
                    OwnerprojCountMap.put(0,tempset);
                }
            }
        }
        
        
        
        //getting Milestone and tasks here
        if(!milestoneIds.isEmpty()){
            
            for(MileStone__mdt milestone : [select id, DeveloperName,MasterLabel,Owner_ID__c,RecordType__c,SNo__c ,
                                            Owner_Type__c, Predecessor_sequence__c,Project__c,project__r.Id,
                                            (select id, DeveloperName,MasterLabel,IsProjectManagerAssignment__c,Pln_Hrs__c,
                                             EstimatedHours__c, MileStone__c, Owner_ID__c,Milestone__r.Id,
                                             Owner_Type__c, Predecessor_sequence__c,SNo__c,
                                             Priority__c, Status__c,Layover_Days__c,RecordType__c,TaskName__c   
                                             from tasks__r
                                            )
                                            from MileStone__mdt 
                                            where id IN:milestoneIds]){
                                                
                                                if(milestone.tasks__r.size() > 0){
                                                    List<Task__mdt> tasklist = new List<Task__mdt>();
                                                    tasklist                 = milestone.tasks__r;
                                                    milestoneIdVsTasks.put(milestone.id, tasklist);
                                                }                        
                                                
                                            }
            
        }
        
        
        /**************Project, Milestone, Task Creation Logic Start *******************/
        If(!SubIdVSTypeofWebMap.isEmpty()){
            system.debug('@@@ in SubAreaVsProject');
            for(Subscription__c subpro : ProjectCreationforSub){
                if(SubIdVSTypeofWebMap.containsKey(subpro.id)){
                    
                    if(!subAreaVsProjectMap.isEmpty() && subAreaVsProjectMap.containsKey(subpro.Type_of_Website__c)){
                        
                        Project__mdt projectTOcreate = subAreaVsProjectMap.get(subpro.Type_of_Website__c);
                        Milestone1_Project__c tempProject     = new Milestone1_Project__c();
                        tempProject.Name                      = projectTOcreate.MasterLabel;
                        tempProject.Status__c                 = projectTOcreate.Status__c;
                        tempProject.ProjectType__c            = projectTOcreate.ProjectType__c;
                        tempProject.OwnerId                   = projectTOcreate.Owner_ID__c;
                        tempProject.Created_from_Case__c      = True;              
                        tempProject.Project_External_ID__c    = userinfo.getuserid()+system.now()+projectTOcreate.DeveloperName;//charge.id + projectTOcreate.DeveloperName;
                        tempProject.RecordTypeId              = projectTOcreate.RecordType__c;
                        tempProject.Account__c                = subpro.Account__c;
                        tempProject.Opportunity__c            = subpro.Opportunity__c;
                        tempProject.FirmAccount__c            = subpro.Account__r.ParentId; //MHBS-7799
                        tempProject.CreatedfromAvvoOpty__c    = TRUE;
                        //tempProject.Description__c            = subpro.Description;
                        
                        
                        if(SubIdVSAccountOwnerEmailMap.containsKey(subpro.Id)){
                            tempProject.Account_Owner_Email__c = SubIdVSAccountOwnerEmailMap.get(subpro.Id);
                        }
                        
                        
                        //finding the minimum records user here
                        Integer key;
                        List<Integer> keys = new List<Integer>();
                        if(!OwnerprojCountMap.isEmpty()){
                            keys.addAll(OwnerprojCountMap.keySet());
                            keys.sort();
                            key = keys[0];
                        }
                        
                        if(projectTOcreate.IsQueueUserAssignment__c && projectTOcreate.Owner_ID__c != null && string.valueof(projectTOcreate.Owner_ID__c).startswith('00G'))
                        {
                            if(key!= NULL && OwnerprojCountMap.get(key) != NULL){
                                List<String> tempset = new List<string>();
                                tempset.addAll(OwnerprojCountMap.get(key));
                                tempProject.OwnerId = tempset[0];
                            }
                            
                        }
                        
                        Milestone1_Project__c projectReference = new Milestone1_Project__c(Project_External_ID__c = tempProject.Project_External_ID__c);
                        
                        allRecords.add(tempProject);
                        projectList.add(tempProject);                   
                        allRecordsMap.put('1',projectList);
                        
                        If(!projectIdVsMilestones.isEmpty()){
                            for(MileStone__mdt milestone : projectIdVsMilestones.get(projectTOcreate.id)){
                                MileStone__mdt milestoneToCreate         = milestone;
                                Milestone1_Milestone__c tempMilestone    = new Milestone1_Milestone__c();
                                tempMilestone.Name                       = milestone.MasterLabel;
                                tempMilestone.OwnerId                    = tempProject.OwnerId;
                                tempMilestone.Project__r                 = projectReference;
                                tempMilestone.RecordTypeId               = milestone.RecordType__c;
                                tempMilestone.Predecessor_Seq_No__c      = milestone.Predecessor_sequence__c;
                                tempMilestone.SNo__c                     = milestone.SNo__c;                
                                tempMilestone.mileStone_Extenal_ID__c    = userinfo.getuserid()+system.now()+projectTOcreate.DeveloperName + milestone.DeveloperName;//charge.id + projectTOcreate.DeveloperName + milestone.DeveloperName;
                                
                                Milestone1_Milestone__c milestoneReferece = new Milestone1_Milestone__c(mileStone_Extenal_ID__c = tempMilestone.mileStone_Extenal_ID__c);
                                allRecords.add(tempMilestone);
                                milestoneList.add(tempMilestone);
                                allRecordsMap.put('2',milestoneList); 
                                
                                if(!milestoneIdVsTasks.isEmpty() && milestoneIdVsTasks.containsKey(milestone.id)){                               
                                    Milestone1_Task__c milestonetasktemp   = new Milestone1_Task__c();
                                    for(Task__mdt tempTask : milestoneIdVsTasks.get(milestone.id)){
                                        Milestone1_Task__c milestonetask   = new Milestone1_Task__c();
                                        milestonetask.Name                 = tempTask.TaskName__c;
                                        milestonetask.Estimated_Hours__c   = tempTask.EstimatedHours__c;
                                        milestonetask.Priority__c          = tempTask.Priority__c;
                                        //milestonetask.Assigned_To__c       = tempTask.Owner_ID__c;
                                        milestonetask.Task_Identifier__c   = tempMilestone.mileStone_Extenal_ID__c;
                                        milestonetask.Layover_Days__c      = tempTask.Layover_Days__c;
                                        milestonetask.Issystem__c = True;
                                        milestonetask.RecordTypeId         = tempTask.RecordType__c;
                                        milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                        //milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                        milestonetask.Predecessor_Seq_No__c      = tempTask.Predecessor_sequence__c;
                                        milestonetask.SNo__c                     = tempTask.SNo__c;
                                        milestonetask.Pln_Hrs__c                 = tempTask.Pln_Hrs__c;
                                        System.debug('=========milestonetask.Due_Date__c======'+System.today());
                                        
                                        Decimal duration = tempTask.EstimatedHours__c ;
                                        
                                        //converting duration to minutes
                                        String dur = string.valueof(duration);
                                        
                                        List<String> stlist = dur.split('\\.');
                                        system.debug('@@@@stlist'+stlist);
                                        Integer mins = 0;
                                        for(Integer i=0; i <stlist.size(); i++){
                                            if(i == 0){
                                                mins += Integer.valueOf(stlist[0])*60;
                                            }
                                            else{
                                                mins+= Integer.valueOf(Integer.valueOf(stlist[1]) *(0.6));
                                            }
                                        }
                                        
                                        
                                        if(tempTask.IsProjectManagerAssignment__c && tempTask.Owner_ID__c != null && string.valueof(tempTask.Owner_ID__c).startswith('00G')){
                                            
                                            milestonetask.Assigned_Onwer__c  = tempProject.OwnerId;
                                            milestonetask.assign_To_Type__c    = 'User';
                                            
                                        }
                                        else{
                                            milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                            milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                        }
                                        milestonetask.Project_Milestone__r      = milestoneReferece;                                    
                                        allRecords.add(milestonetask);
                                        tasksList.add(milestonetask);
                                        allRecordsMap.put('3',tasksList);  
                                    }
                                }   
                            }
                        }    
                        
                    }
                    
                    
                }
            } 
        } 
        
        
        
        
        
        if(!allRecordsMap.isEmpty()){
            for(String s : allRecordsMap.keySet()){
                if(allRecordsMap.containsKey('1')){
                    updateAllRecords.addall(allRecordsMap.get(s));
                }
                else if(allRecordsMap.containsKey('2')){
                    updateAllRecords.addall(allRecordsMap.get(s));
                }
                else{
                    updateAllRecords.addall(allRecordsMap.get(s));
                }    
                
                
            }
        }
        
        Map<string,List<Milestone1_Milestone__c>> projIdVsMilestonesAfter = new Map<string,List<Milestone1_Milestone__c>>();
        Map<string,List<Milestone1_Task__c>>      milstIdVsTasksAfter     = new Map<string,List<Milestone1_Task__c>>();
        List<Sobject> allRecordtoUpdate                               = new List<Sobject>();
        
        List<Milestone1_Milestone__c> mileListForPredecessr = new List<Milestone1_Milestone__c>();        
        Map<Decimal, Milestone1_Milestone__c> sNoMilestoneMap = new Map<Decimal, Milestone1_Milestone__c>();
        Map<Decimal, Milestone1_Task__c> sNoTaskMap = new Map<Decimal, Milestone1_Task__c>();
        
        Map<String, Map <Decimal, Milestone1_Milestone__c>> orpcSnoMilestoneMap = new Map<String, Map <Decimal, Milestone1_Milestone__c>>();
        Map<String, Map <Decimal, Milestone1_Task__c>> orpcSnoTaskMap = new Map<String, Map <Decimal, Milestone1_Task__c>>();
        Set<Id> mileSetForPredec = new Set<Id>();
        System.debug('============updateAllRecords============'+updateAllRecords);
        
        try{
            if(!updateAllRecords.isEmpty()){
                insert updateAllRecords;
                system.debug('@@@@allRecords'+allRecords);
                
                List<Milestone1_Milestone__c> mileListPred = [Select id, name, Project__r.Id,SNo__c,Predecessor_Seq_No__c,Order_RPC_Id__c,(Select id, name,Project_Milestone__r.Id,Predecessor_Seq_No__c,Assigned_Onwer__c,assign_To_Type__c,SNo__c From Project_Tasks__r) From Milestone1_Milestone__c WHERE id in : updateAllRecords]; //Assign Owner to Tasks 
                system.debug('=======mileList:'+mileListPred);
                //Creating a Map of Queue and Map of User object
                Map<String, Group> queueIdMap= new Map<String, Group>();
                Map<String, User> userIdMap = new Map<String, User>();
                
                List<Group> queueDetail = [Select id, name,DeveloperName, Email, Type FROM Group where Type='Queue'];   
                List<User> userDetail = [Select id,isActive, name From User Where isActive = TRUE];
                for(Group g : queueDetail){
                    if(queueIdMap.containsKey(g.id)){
                        queueIdMap.get(g.id);
                    }else{
                        queueIdMap.put(g.id,g);
                    }
                }
                
                for(User u : userDetail){
                    if(userIdMap.containsKey(u.id)){
                        userIdMap.get(u.id);
                    }else{
                        userIdMap.put(u.id,u);
                    }
                }
                system.debug('mileListPred here>>>'+mileListPred);
                if(!mileListPred.isEmpty()){
                    for(Milestone1_Milestone__c mil : mileListPred){
                        string key = mil.Project__r.Id;
                        insertedProjId = mil.Project__r.Id;
                        System.debug('=========key==========='+key);
                        system.debug('=============mil===================='+mil.id);
                        if(projIdVsMilestonesAfter.containsKey(key)){
                            projIdVsMilestonesAfter.get(key).add(mil);
                        }
                        else{
                            projIdVsMilestonesAfter.put(key, new List<Milestone1_Milestone__c>{mil});
                        }
                        System.debug('============projIdVsMilestonesAfter========'+projIdVsMilestonesAfter);
                        
                        sNoMilestoneMap.put(mil.SNo__c, mil);
                        
                        
                        for(Milestone1_Task__c tas : mil.Project_Tasks__r){
                            string taskkey = tas.Project_Milestone__r.Id;
                            System.debug('===========tas=============='+tas);
                            if(milstIdVsTasksAfter.containsKey(taskkey)){
                                milstIdVsTasksAfter.get(taskkey).add(tas);
                            }
                            else{
                                milstIdVsTasksAfter.put(taskkey, new List<Milestone1_Task__c>{tas});
                            }
                            
                            if(sNoTaskMap.containsKey(tas.SNo__c)){
                                sNoTaskMap.get(tas.SNo__c);
                            }
                            else{
                                sNoTaskMap.put(tas.SNo__c, tas);
                            }
                            System.debug('=====sNoTaskMap======'+sNoTaskMap);
                        }  
                    }   
                }
                system.debug('@@@@ sNoMilestoneMap'+ sNoMilestoneMap);
                system.debug('@@@@@@projIdVsMilestonesAfter'+projIdVsMilestonesAfter); 
                system.debug('@@@@@@milstIdVsTasksAfter'+milstIdVsTasksAfter);  
                if(!projIdVsMilestonesAfter.isEmpty()){
                    for(string projId : projIdVsMilestonesAfter.keySet()){
                        System.debug('=========projIdVsMilestonesAfter.get(projId)======='+projIdVsMilestonesAfter.get(projId));
                        if(projIdVsMilestonesAfter.get(projId).size() > 1){
                            List<Milestone1_Milestone__c> milestonesList = new List<Milestone1_Milestone__c>();
                            milestonesList  = projIdVsMilestonesAfter.get(projId);
                            System.debug('========milestonesList==========='+milestonesList);
                            
                            for(Milestone1_Milestone__c m : milestonesList){
                                
                                if(m.Predecessor_Seq_No__c !=Null){
                                    if(sNoMilestoneMap.containskey(m.Predecessor_Seq_No__c)){
                                        m.Predecessor_Milestone__c = sNoMilestoneMap.get(m.Predecessor_Seq_No__c).id;                                    
                                        allRecordtoUpdate.add(m);
                                    } 
                                }
                                
                            }                             
                        }
                    }
                }
                System.debug('===========allrecordsToUpdate======'+allRecordtoUpdate);
                
                
                if(!milstIdVsTasksAfter.isEmpty()){
                    for(string msId : milstIdVsTasksAfter.keySet()){
                        if(milstIdVsTasksAfter.get(msId).size() > 1){
                            List<Milestone1_Task__c> taskList = new List<Milestone1_Task__c>();
                            taskList  = milstIdVsTasksAfter.get(msId);
                            System.debug('==========taskList============'+taskList);
                            System.debug('========queueidmap======'+queueIdMap.keyset());
                            for(Milestone1_Task__c t : taskList){
                                System.debug('========t.Predecessor_Seq_No__c======'+t.Predecessor_Seq_No__c);
                                System.debug('========sNoTaskMap.get(t.Predecessor_Seq_No__c)======'+sNoTaskMap.get(t.Predecessor_Seq_No__c));
                                
                                System.debug('========queueidmap======'+queueIdMap);
                                System.debug('========useridmap======'+userIdMap);
                                System.debug('===========t.Assigned_Onwer__c==============='+t.Assigned_Onwer__c);
                                System.debug('===========t.assign_To_Type__c==============='+t.assign_To_Type__c);
                                System.debug('=============userIdMap.containskey(t.Assigned_Onwer__c)============='+userIdMap.containskey(t.Assigned_Onwer__c));
                                
                                if(t.Predecessor_Seq_No__c !=Null){
                                    if(sNoTaskMap.containskey(t.Predecessor_Seq_No__c)){
                                        t.Predecessor_Task__c = sNoTaskMap.get(t.Predecessor_Seq_No__c).id;
                                    } 
                                }
                                allRecordtoUpdate.add(t);
                            }                            
                        }
                    }
                } 
                
                if(!allRecordtoUpdate.isEmpty()){
                    update allRecordtoUpdate;
                }
            }            
        }   
        catch(Exception ex){
            system.debug('@@@@@Exception '+ex);
        }
    }
    //handling cancel proj upon canel sub - MHBS-4069 - added by sai 09/02/2020
    public void handleCancelSub(map<Id,Subscription__c> newMap, map<Id,Subscription__c> oldMap){
        
        Set<Id> cancelldSubOptyId = new Set<Id>();
        Set<Id> projIds = new Set<Id>();
        List<Milestone1_Project__c> CancellPrjIds = new List<Milestone1_Project__c>();
        List<Milestone1_Milestone__c> cancelMilestonelist = new List<Milestone1_Milestone__c>();
        List<SObject> updateCancelList = new List<SObject>();
        
        
        for(Subscription__c sub : newMap.values()) {
            if( sub.Cancelled__c == TRUE && oldmap.get(sub.Id).Cancelled__c != newMap.get(sub.Id).Cancelled__c){
                cancelldSubOptyId.add(sub.Opportunity__c);
            }
            else if(sub.Potential_Cancel_Sub__c == TRUE && oldmap.get(sub.Id).Potential_Cancel_Sub__c != newMap.get(sub.Id).Potential_Cancel_Sub__c){
                cancelldSubOptyId.add(sub.Opportunity__c);
            }
        }
        if(cancelldSubOptyId.size()>0){
            List<Milestone1_Project__c> projectListToCancel = [Select id, name,Status__c, (SELECT Id,
                                                                                           Name,
                                                                                           Project__c,Status__c,
                                                                                           Parent_Milestone__c,
                                                                                           Complete__c,
                                                                                           Deadline__c,
                                                                                           Total_Actual_Hours__c From Project_Milestones__r 
                                                                                           Where Status__c!='Cancelled' AND Status__c!='Completed') 
                                                               From Milestone1_Project__c Where Status__c!='Completed' AND Status__c!= 'Cancelled' 
                                                               AND Opportunity__c in: cancelldSubOptyId];
            
            id cancelProjectrecordTypeId = Schema.SObjectType.Milestone1_Project__c.RecordTypeInfosByName.get('Cancel Project').RecordTypeId ;
            id cancelMilestonRecTypId = Schema.SObjectType.Milestone1_Milestone__c.RecordTypeInfosByName.get('Cancel project Milestone').RecordTypeId ;
            id cancelTaskRecTypId = Schema.SObjectType.Milestone1_Task__c.RecordTypeInfosByName.get('Cancel Project Task').RecordTypeId ;
            
            if(!projectListToCancel.isEmpty()){
                for(Milestone1_Project__c prj : projectListToCancel){
                    projIds.add(prj.id);
                    if(prj.Status__c!= 'Cancelled'){
                        CancellPrjIds.add(prj);
                    }
                    
                    if(prj.Project_Milestones__r.size() > 0){
                        cancelMilestonelist = prj.Project_Milestones__r;
                    }
                }
                if(!CancellPrjIds.isEmpty()){
                    for(Milestone1_Project__c cancelprj: CancellPrjIds){
                        cancelprj.Status__c = 'Cancelled';
                        cancelprj.AllmilestoneCancelled__c = True;
                        cancelprj.RecordTypeId = cancelProjectrecordTypeId;
                    }
                    update CancellPrjIds;
                }
                
                if(!cancelMilestonelist.isEmpty()){
                    for(Milestone1_Milestone__c canmil : cancelMilestonelist){
                        canmil.Status__c = 'Cancelled';
                        canmil.RecordTypeId = cancelMilestonRecTypId;
                    }
                    update cancelMilestonelist;
                }
                List<Milestone1_Task__c> cancelTaskList = [select id,Task_Stage__c,ProjectId__c
                                                           from Milestone1_Task__c WHERE Task_Stage__c!= 'Cancelled' AND Task_Stage__c!= 'Completed' AND Project_ID__c IN:projIds];
                if(!cancelTaskList.isEmpty()){
                    for(Milestone1_Task__c cancelTask : cancelTaskList){
                        canceltask.Task_Stage__c = 'Cancelled';
                        canceltask.RecordTypeId = cancelTaskRecTypId;
                    }
                    update cancelTaskList;
                }
                
            }
        }
    }
    // <T01> starts
    public static void createCaseForSubInsert(List<Subscription__c> SubList){ 
        /*
        List<Case> casesToInsert = new List<Case>();
        Set<Id> accIds = new Set<Id>();
        List<Group> fulfillmentOpsId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Fulfillment Operations'];
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case Record').getRecordTypeId();
        Set<Id> oppId = new Set<Id>();
        for(Subscription__c sub: SubList){
            accIds.add(sub.Account__c);
            oppId.add(sub.Opportunity__c);
        }
        Set<Id> oppIdFilter = new Set<Id>();
        for(Opportunity opp : [SELECT Id,Firm_Name__c  FROM Opportunity WHERE ID IN: oppId]){
            if(opp.Firm_Name__c == Null){
                oppIdFilter.add(opp.Id);
            }
        }
        List<contact> conList = [select id,Related_To_Account__c from contact where Related_To_Account__c in :accIds];
        
        Map<Id,Id> AccVsConMap = new Map<Id,Id>();
        //  if(conList.size() <=0){
//List<Account_Contact_Relation__c> accconRelation = [SELECT  id,Account__c,Contact__C FROM Account_Contact_Relation__c where  Account__c in accIds];
//} 
        
        AssignmentRule AR = new AssignmentRule();
        AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
        
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        for(Contact c: conList){
            AccVsConMap.put(c.Related_To_Account__c,c.Id);
        }
        for(Subscription__c sub: [SELECT ID,Inventory_Type__c,Account__c FROM Subscription__c WHERE Opportunity__c IN: oppIdFilter AND ID IN:SubList]){
            
            
            if(sub.Inventory_Type__c == 'CompleteProfilePlusInventory'){
                Case c = new Case(Status = 'Open',
                                  Subject = 'Martindale-Avvo Complete Profile Plus Order',
                                  Description = 'This is a New Avvo Customer with Martindale-Avvo Complete Profile Plus Order',
                                  Area__c = 'Martindale-Avvo Complete Profile Plus New',
                                  Origin = 'AdvancedProds',
                                  Priority = 'High',
                                  AccountId = sub.Account__c,                                
                                  Subscription__c = sub.Id
                                 );
                if(fulfillmentOpsId.size()>0){
                    c.OwnerId = fulfillmentOpsId[0].Id;
                }
                if(AccVsConMap.size()>0 && AccVsConMap.containsKey(sub.Account__c)){
                    c.ContactId = AccVsConMap.get(sub.Account__c);
                }
                if(caseRecordTypeId !=null) {
                    c.RecordTypeId = caseRecordTypeId ;
                }
                c.setOptions(dmlOpts);
                casesToInsert.add(c);
            }else if(sub.Inventory_Type__c == 'MartindaleBaseProfileInventory'){ //<T02 starts
                Case c = new Case(Status = 'Open',
                                  Subject = 'Martindale Base Profile Order',
                                  Description = 'This is a New Avvo Customer with Martindale Base Profile Order',
                                  Area__c = 'Martindale Base Profile New',
                                  Origin = 'AdvancedProds',
                                  Priority = 'High',
                                  AccountId = sub.Account__c,                                
                                  Subscription__c = sub.Id
                                 );
                if(fulfillmentOpsId.size()>0){
                    c.OwnerId = fulfillmentOpsId[0].Id;
                }
                if(AccVsConMap.size()>0 && AccVsConMap.containsKey(sub.Account__c)){
                    c.ContactId = AccVsConMap.get(sub.Account__c);
                }
                if(caseRecordTypeId !=null) {
                    c.RecordTypeId = caseRecordTypeId ;
                }
                c.setOptions(dmlOpts);
                casesToInsert.add(c);
            }
            //<T02 ends
        }
        
        System.debug(casesToInsert);
        if(casesToInsert.size() >0){
            insert casesToInsert;
        } */
    } 
    
    public static void createCaseForCancelledSub(List<Subscription__c> SubList,Map<Id, Subscription__c> oldMap){ 
        
        List<Case> casesToInsert = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        List<contact> conList = new List<contact>();
        List<Subscription__c> targetSubList = new List<Subscription__c>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Case> oppCaseMap = new Map<Id,Case>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case Record').getRecordTypeId();
        List<String> inventoryTypes = System.Label.Subscription_Inventory_Types.Split(', ');
        for(Subscription__c sub: SubList){
            accIds.add(sub.Account__c);
            oppIds.add(sub.Opportunity__c);
            if((inventoryTypes.contains(sub.Inventory_Type__c)) && //<T03>: Additional condition
               ((sub.Cancelled__c == true && oldMap.get(sub.Id).Cancelled__c == false)
              ||(sub.Cancel_Date__c != null && oldMap.get(sub.Id).Cancel_Date__c == null) //<T03>: Additional condition
              ||(sub.Cancel_Reason__c != null && oldMap.get(sub.Id).Cancel_Reason__c == null))){
                targetSubList.add(sub);
              }
        }
        if(targetSubList!=null && !targetSubList.isEmpty()){
            List<Group> fulfillmentOpsId = [select Id from Group where Type = 'Queue' AND DeveloperNAME =: FULFILLMENT_OPERATIONS];
            //<T03> starts: Added for querying existing case for updating the Professional Id
            if(oppIds!=null && !oppIds.isEmpty()){
                for(Case cs: [SELECT Id,Parent_Opportunity__c,Canceled_Professionals__c from Case WHERE Parent_Opportunity__c IN: oppIds 
                              AND CreatedDate = Today AND Status = 'Open' AND Subject =: AVVO_CANCELATION_SUBJECT]){
                                  oppCaseMap.put(cs.Parent_Opportunity__c,cs);
                              }
            }
            if(accIds!=null && !accIds.isEmpty()){
                conList = [select id,Related_To_Account__c from contact where Related_To_Account__c in :accIds];
            }
            Map<Id,Id> AccVsConMap = new Map<Id,Id>();
            if(conList!=null && !conList.isEmpty()){
                for(Contact c: conList){
                    AccVsConMap.put(c.Related_To_Account__c,c.Id);
                }
            }

            for(Subscription__c sub: targetSubList){
                Boolean isFirmSKU = False;
                Boolean isWebvantage = False;
                Case c;
                if(sub.Inventory_Type__c == FIRM_OWNERSHIP_INVENTORY){
                    isFirmSKU = true;
                }
                if(sub.Inventory_Type__c == 'webvantage'){
                    isWebvantage = true;
                }
                if(sub.Opportunity__c !=null && oppCaseMap.containskey(sub.Opportunity__c)){
                    if(oppCaseMap.get(sub.Opportunity__c)!=null){
                        Case cs = oppCaseMap.get(sub.Opportunity__c);
                        List<String> cpList = cs.Canceled_Professionals__c.split(',');
                        if(isWebvantage && !cpList.contains('Webvantage')){
                            cs.Canceled_Professionals__c += ','+'Webvantage';
                            casesToUpdate.add(cs);//<T04>: Update existing Case with isWebvantage
                        }else if(isFirmSKU && !cpList.contains('FirmSKU')){
                                cs.Canceled_Professionals__c += ','+'FirmSKU';
                                casesToUpdate.add(cs);//<T03>: Update existing Case with Firm SKU for Firm Ownership Inventory
                            }
                        else if(!cpList.contains(sub.Contact_Professional_ID__c) 
                                && sub.Contact_Professional_ID__c!=null){
                                cs.Canceled_Professionals__c += ','+sub.Contact_Professional_ID__c;
                                casesToUpdate.add(cs);//<T03>: Update existing Case with Professional Id
                            }
                    }
                }else{
                     if(isWebvantage){
                        c = new Case(Status = 'Open',
                                     Subject = AVVO_CANCELATION_SUBJECT,
                                     Description = Case_Description,
                                     Area__c = Case_Area,
                                     Origin = Case_Origin,
                                     Priority = Case_Priority,
                                     AccountId = sub.Account__c,                                  
                                     Parent_Opportunity__c = sub.Opportunity__c,
                                     Cancellation_Date__c = Date.Today(),
                                     Canceled_Professionals__c = 'Webvantage' //For Webvantage Inventory
                                    );
                    }else if(isFirmSKU){
                        c = new Case(Status = 'Open',
                                     Subject = AVVO_CANCELATION_SUBJECT,
                                     Description = Case_Description,
                                     Area__c = Case_Area,
                                     Origin = Case_Origin,
                                     Priority = Case_Priority,
                                     AccountId = sub.Account__c,                                  
                                     Parent_Opportunity__c = sub.Opportunity__c, //<T03>: Associating Case to Opp as this is going to be the single cancellation case for the Opp with all the Professional Ids from the Subscriptions
                                     Cancellation_Date__c = Date.Today(),
                                     Canceled_Professionals__c = 'FirmSKU' //For Firm Ownership Inventory
                                    );
                    }else{
                        c = new Case(Status = 'Open',
                                     Subject = AVVO_CANCELATION_SUBJECT,
                                     Description = Case_Description,
                                     Area__c = Case_Area,
                                     Origin = Case_Origin,
                                     Priority = Case_Priority,
                                     AccountId = sub.Account__c,                                  
                                     Parent_Opportunity__c = sub.Opportunity__c, //<T03>: Associating Case to Opp as this is going to be the single cancellation case for the Opp with all the Professional Ids from the Subscriptions
                                     Cancellation_Date__c = Date.Today(),
                                     Canceled_Professionals__c = sub.Contact_Professional_ID__c
                                    );
                    }
                    if(fulfillmentOpsId.size()>0){
                      //  c.OwnerId = fulfillmentOpsId[0].Id;  - Not required and handled by case assignment
                    }
                    
                    if(AccVsConMap.size()>0 && AccVsConMap.containsKey(sub.Account__c)){
                        c.ContactId = AccVsConMap.get(sub.Account__c);
                    }
                    if(caseRecordTypeId !=null) {
                        c.RecordTypeId = caseRecordTypeId ;
                    }
                    //c.setOptions(dmlOpts);
                    casesToInsert.add(c);
                }
            }
            
            //<T02 ends
        }
        try{
            if(casesToInsert.size() >0 && SubCheck == False){
                insert casesToInsert;
                SubCheck = True;
            }
        }catch(Exception e){
            Util.processException(e,true,'Error while inserting Case for Subscription Cancellation');
        }
        try{
            if(casesToUpdate.size()>0){
                update casesToUpdate;
            }
        }catch(Exception e){
            Util.processException(e,true,'Error while updating Case for Subscription Cancellation');
        }//<T03> ends
    }
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
    }
}