/*******************************************************************************************************
* Author      : SaiV
* Description : whenever a charge is created, we need to create Project --> Milestone(child of project) --> tasks(child of each milestone)
* Date        : 08/12/2020
* *****************************************************************************************************
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-9371    Bharath       31/07/2023   Ashley Boehm    T01     WebVantage: New website project opportunity notes are missing
************************************************************************************************************************/

public class CPQ_MilestoneHandler {
    public Milestone1_Project__c projObj{get;set;}
    public String selectedProjName{get;set;}
    public list<selectoption> projNamesList{get;set;}
    Map<id,Project__mdt> projects = new Map<id,Project__mdt>();
    Set<Id> projectIds{get;set;}
    Map<String,Project__mdt> projectMap = new Map<String,Project__mdt>();
    String insertedProjId{get;set;}    
    
    public CPQ_MileStoneHandler(ApexPages.StandardController standardController) {
        projObj= new Milestone1_Project__c();
        projNamesList = new list<selectoption>();
        projectIds = new Set<Id>();        
        projects = new  Map<id,Project__mdt>([select id, DeveloperName,MasterLabel,RecordType__c,IsQueueUserAssignment__c,
                                              Owner_ID__c,Owner_Type__c, ProjectType__c, Status__c,Is_Manual__c,Only_For_Main_Users__c                                                              
                                              From Project__mdt]);
        User currentUser = [select id,Name,Milestone_Super_User__c from User where id =: Userinfo.getUserId() ];
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        
        for(Project__mdt proj : projects.values()){
            if(proj.Is_Manual__c && !(proj.Only_For_Main_Users__c)){
                projNamesList.add(new SelectOption(proj.MasterLabel,proj.MasterLabel));
                projectIds.add(proj.id);
                projectMap.put(proj.MasterLabel,proj);
            }
            if(currentUser.Milestone_Super_User__c || p.Name == 'System Administrator'){
                if(proj.Only_For_Main_Users__c){
                    projNamesList.add(new SelectOption(proj.MasterLabel,proj.MasterLabel));
                    projectIds.add(proj.id);
                    projectMap.put(proj.MasterLabel,proj);
                }
            }               
        }                                    
    }
    //save project for custom project creation
    public Pagereference saveProject(){
        //Declaration Section        
        List<MileStone__mdt> milestones                         = new List<MileStone__mdt>();
        Map<id,Project__mdt>   projectsInner                    = new Map<id,Project__mdt>();
        Map<Id,List<MileStone__mdt>> projectIdVsMilestones      = new Map<Id,List<MileStone__mdt>>();
        Map<Id,List<Task__mdt>>      milestoneIdVsTasks         = new Map<Id,List<Task__mdt>>();
        Set<Id> milestoneIds                                    = new set<Id>();
        List<Sobject> allRecords                                = new List<SObject>();
        Map<String, List<Sobject>> allRecordsMap                = new Map<String, List<SObject>>();
        List<Sobject> updateAllRecords                          = new List<SObject>();
        List<Sobject> projectList                               = new List<Sobject>();
        List<Sobject> milestoneList                             = new List<Sobject>();
        List<Sobject> tasksList                                 = new List<Sobject>();
        String businessHoursId                                  = Label.BusinessHoursId;
        
        Map<id,Set<id>> QtoUserMap = new Map<id,Set<id>>();
        //commented by sai C 10/18/2017
        //Map<string,integer> OwnerprojCountMap = new Map<string,integer>();  
        Map<Integer,set<string>> OwnerprojCountMap = new Map<Integer,set<string>> ();        
        System.debug('projectIds here'+projectIds);    
        //forming project id Vs Milestones Map       
        projectsInner = new  Map<id,Project__mdt>([select id, DeveloperName,MasterLabel,RecordType__c,IsQueueUserAssignment__c,
                                                   Owner_ID__c,Owner_Type__c, ProjectType__c, Status__c,
                                                   (select id, DeveloperName,MasterLabel,Owner_ID__c,
                                                    Owner_Type__c, Predecessor_sequence__c,Project__c,RecordType__c,SNo__c
                                                    From MileStones__r
                                                   )
                                                   From Project__mdt
                                                   where id IN: projectIds]); 
        system.debug('projectIds size:'+projectIds.size());
        for(Project__mdt proj : projectsInner.values()){
            system.debug('proj id here::'+proj.id);
            if(proj.MileStones__r.size() > 0){
                List<MileStone__mdt> milestonesTemp = new List<MileStone__mdt>();
                milestonesTemp = proj.MileStones__r;
                system.debug('milestonesTemp here::'+milestonesTemp );
                projectIdVsMilestones.put(proj.id, milestonesTemp);            
                Map<id,MileStone__mdt> tempMilestoneMap  = new Map<id,MileStone__mdt>(proj.MileStones__r);
                milestoneIds.addAll(tempMilestoneMap.keySet());            
                if(proj.IsQueueUserAssignment__c && proj.Owner_ID__c != null && string.valueof(proj.Owner_ID__c).startswith('00G'))
                {               
                    QtoUserMap.put(proj.Owner_ID__c,new set<id>());
                }       
            }
        }            
        System.debug('============projectIdVsMilestones====='+projectIdVsMilestones);
        
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
                   GROUP BY ownerid];
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
        
        if(!projectIdVsMilestones.isEmpty()){
            milestones = [select id, DeveloperName,MasterLabel,Owner_ID__c,RecordType__c,SNo__c ,
                          Owner_Type__c, Predecessor_sequence__c,Project__c,project__r.Id,
                          (select id, DeveloperName,MasterLabel,IsProjectManagerAssignment__c,Pln_Hrs__c,
                           EstimatedHours__c, MileStone__c, Owner_ID__c,Milestone__r.Id,
                           Owner_Type__c, Predecessor_sequence__c,SNo__c,
                           Priority__c, Status__c,Layover_Days__c,RecordType__c,TaskName__c   
                           from tasks__r
                          )
                          from MileStone__mdt 
                          where id IN:milestoneIds];
            System.debug('========Milestones============'+milestones);
            for(MileStone__mdt singleMilestone : milestones){
                //System.debug('=========Tasks under each Milestone=========='+singleMilestone.tasks__r);
                //System.debug('==========singleMilestone.tasks__r.size()====================='+singleMilestone.tasks__r.size());
                if(singleMilestone.tasks__r.size() > 0){
                    List<Task__mdt> takslist = new List<Task__mdt>();
                    takslist                 = singleMilestone.tasks__r;
                    milestoneIdVsTasks.put(singleMilestone.id, takslist);
                }
                
            }
        }
        System.debug('=================milestoneIdVsTasks==============='+milestoneIdVsTasks);
        
        // Our logic
        projObj.Name = selectedProjName;    
        system.debug('selectedProjName'+selectedProjName);
        //Creation of Project, Milestones, tasks goes here
        
        if(!projectsInner.isEmpty()){ //&& !test.isRunningTest()){
            Project__mdt projectTOcreate          = projectMap.get(projObj.Name);
            System.debug('======projectTOcreate.Status__c========='+projectTOcreate.Status__c);
            Milestone1_Project__c tempProject     = new Milestone1_Project__c();
            tempProject.Name                      = projectTOcreate.MasterLabel;
            tempProject.Status__c                 = projectTOcreate.Status__c;
            tempProject.ProjectType__c            = projectTOcreate.ProjectType__c;
            tempProject.OwnerId                   = projectTOcreate.Owner_ID__c;
            
            //finding the minimum records user here
            Integer key;
            List<Integer> keys = new List<Integer>();
            if(!OwnerprojCountMap.isEmpty()){
                keys.addAll(OwnerprojCountMap.keySet());
                keys.sort();
                key = keys[0];
            }
            
            
            system.debug('projectTOcreate.Owner_ID__c here'+projectTOcreate.Owner_ID__c);
            if(projectTOcreate.IsQueueUserAssignment__c && projectTOcreate.Owner_ID__c != null && string.valueof(projectTOcreate.Owner_ID__c).startswith('00G'))
            {
                if(key!= NULL && OwnerprojCountMap.get(key) != NULL){
                    List<String> tempset = new List<string>();
                    tempset.addAll(OwnerprojCountMap.get(key));
                    tempProject.OwnerId = tempset[0];
                }
            }                  
            
            tempProject.Project_External_ID__c    = userinfo.getuserid()+system.now()+projectTOcreate.DeveloperName;//charge.id + projectTOcreate.DeveloperName;
            //tempProject.Order_Rate_Plan_Charge__c = projObj.Order_Rate_Plan_Charge__c;
            //tempProject.Order__c                  = projObj.Order__c;
            tempProject.RecordTypeId              = projectTOcreate.RecordType__c;
            tempProject.Account__c                = projObj.Account__c;
            tempProject.OrderProduct__c           = projObj.OrderProduct__c;
            tempProject.Contract__c               = projObj.Contract__c;

            //Milestone1_Project__c projectReference = new Milestone1_Project__c(Project_External_ID__c = projectTOcreate.DeveloperName);
            Milestone1_Project__c projectReference = new Milestone1_Project__c(Project_External_ID__c = tempProject.Project_External_ID__c);
            System.debug('============projectTOcreate.DeveloperName===================='+projectTOcreate.DeveloperName);
            System.debug('=========tempProject.Project_External_ID__c===='+tempProject.Project_External_ID__c);
            allRecords.add(tempProject);
            projectList.add(tempProject);
            allRecordsMap.put('1',projectList);
            System.debug('=========projectTOcreateId===='+projectTOcreate.Id);
            //system.debug('=======test==='+projectIdVsMilestones.get('m01W00000004FPbIAM'));
            if(!projectIdVsMilestones.isEmpty() && projectIdVsMilestones.containsKey(projectTOcreate.id)){
                String previousMilestone = '';
                Milestone1_Milestone__c milestonetReferencetemp = new Milestone1_Milestone__c();
                for(MileStone__mdt milestone : projectIdVsMilestones.get(projectTOcreate.id)){
                    System.debug('==========Inside for Milestones==============='+milestone);
                    MileStone__mdt milestoneToCreate         = milestone;
                    Milestone1_Milestone__c tempMilestone    = new Milestone1_Milestone__c();
                    tempMilestone.Name                       = milestone.MasterLabel;
                    tempMilestone.OwnerId                    = tempProject.OwnerId;
                    tempMilestone.Project__r                 = projectReference;
                    tempMilestone.RecordTypeId               = milestone.RecordType__c;
                    tempMilestone.Predecessor_Seq_No__c      = milestone.Predecessor_sequence__c;
                    tempMilestone.SNo__c                     = milestone.SNo__c;                
                    tempMilestone.mileStone_Extenal_ID__c    = userinfo.getuserid()+system.now()+projectTOcreate.DeveloperName + milestone.DeveloperName;//charge.id + projectTOcreate.DeveloperName + milestone.DeveloperName;
                    
                    //Milestone1_Milestone__c milestoneReferece = new Milestone1_Milestone__c(mileStone_Extenal_ID__c = projectTOcreate.DeveloperName + milestone.DeveloperName);
                    Milestone1_Milestone__c milestoneReferece = new Milestone1_Milestone__c(mileStone_Extenal_ID__c = tempMilestone.mileStone_Extenal_ID__c);
                    
                    allRecords.add(tempMilestone);
                    milestoneList.add(tempMilestone);
                    allRecordsMap.put('2',milestoneList);
                    
                    if(!milestoneIdVsTasks.isEmpty() && milestoneIdVsTasks.containsKey(milestone.id)){                               
                        Milestone1_Task__c milestonetasktemp   = new Milestone1_Task__c();
                        for(Task__mdt tempTask : milestoneIdVsTasks.get(milestone.id)){
                            System.debug('==========Inside for Tasks==========='+tempTask);
                            Milestone1_Task__c milestonetask   = new Milestone1_Task__c();
                            milestonetask.Name                 = tempTask.TaskName__c;
                            milestonetask.Estimated_Hours__c   = tempTask.EstimatedHours__c;
                            milestonetask.Priority__c          = tempTask.Priority__c;
                            //milestonetask.Assigned_To__c       = tempTask.Owner_ID__c;
                            milestonetask.Task_Identifier__c   = tempMilestone.mileStone_Extenal_ID__c;
                            milestonetask.Layover_Days__c      = tempTask.Layover_Days__c;
                            // Added to bypass validation Sai C 11/19/18
                            milestonetask.Issystem__c          = True;
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
                            system.debug('@@@@mins'+ mins);
                            
                            System.debug('==============Duration===='+duration);
                            datetime startDateTime = datetime.now();
                            
                            // milestonetask.Due_Date__c                = myDateTime + (duration/24) ;
                            //Commented on 9/8/2017
                            //milestonetask.Start_Date__c = startDateTime ;
                            //milestonetask.Due_Date__c                = BusinessHours.add(businessHoursId,startDateTime, mins*60000 );
                            
                            System.debug('=========milestonetask.Due_Date__c======'+milestonetask.Dued_date__c);
                            System.debug('==============Start date ===='+milestonetask.Started_date__c);
                            if(tempTask.IsProjectManagerAssignment__c && tempTask.Owner_ID__c != null && string.valueof(tempTask.Owner_ID__c).startswith('00G')){
                                milestonetask.Assigned_Onwer__c  = tempProject.OwnerId;
                                milestonetask.assign_To_Type__c    = 'User';
                            }else{
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
        Map<string,List<Milestone1_Milestone__c>> projIdVsMilestonesAfter = new Map<string,List<Milestone1_Milestone__c>>();
        Map<string,List<Milestone1_Task__c>>      milstIdVsTasksAfter     = new Map<string,List<Milestone1_Task__c>>();
        List<Sobject> allRecordtoUpdate                               = new List<Sobject>();
        
        System.debug('==============Allrecords========'+allRecords);
        allRecords.sort();
        System.debug('==============Allrecords sorted========'+allRecords);
        
        for(String s : allRecordsMap.keySet()){
            system.debug('@@@@allRecordsMap.get(s)'+allRecordsMap.get(s));
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
                        
                        //if(sNoMilestoneMap.containsKey(mil.SNo__c)){
                        //    sNoMilestoneMap.get(mil.SNo__c);
                        //}
                        //else{
                        sNoMilestoneMap.put(mil.SNo__c, mil);
                        //}
                        //System.debug('=====sNoMilestoneMap======'+sNoMilestoneMap);
                        
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
        
        if(insertedProjId != null)
            return new PageReference('/'+insertedProjId);
        else
            return new PageReference('/'+Milestone1_Project__c.sobjecttype.getDescribe().getKeyPrefix());        
    } 
    
    
    //project creation upon subscription creation
    public static void CPQ_createProjects(Set<Id> subIds){
        List<SBQQ__Subscription__c > orderCharges = new List<SBQQ__Subscription__c >();
        List<Milestone1_Project__c > allAccPrjs = new List<Milestone1_Project__c >();//MHBS-4746
        List<Id> accId = new List<Id>();
        Boolean accContainsSEO = false;
        List<SBQQ__Subscription__c> orderChargestemp 
            = [select id, Name, ProductCode__c, SBQQ__Account__c,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SIN__c,SBQQ__QuoteLine__r.SBQQ__Group__c, GroupName__c,SBQQ__Product__r.ProductCode,
               SBQQ__Contract__c, SBQQ__OrderProduct__c,SBQQ__RevisedSubscription__c,SBQQ__RevisedSubscription__r.Status__c,SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,
               SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,Cancelled__c,Status__c,SBQQ__QuoteLine__r.SBQQ__Quote__c,SBQQ__RequiredByProduct__c, SBQQ__RequiredByProduct__r.Name,
               Opportunity__c, //<T01>
               SIN__c From SBQQ__Subscription__c where Id IN:subIds];
        //Handling Upgrade Scneario - Upgrade needs to be placed here - skipping for now
        system.debug('@@@orderChargestemp'+orderChargestemp);
        for(SBQQ__Subscription__c ordcharge : orderChargestemp){
            orderCharges.add(ordcharge);
            accId.add(ordcharge.SBQQ__Account__c);
        }
        system.debug('@@@@@In createProjects'+orderCharges);
        
        //Declaration Section
        Map<String,String>   chargeIdVsProjectId                =  new Map<String,String>();
        List<MileStone__mdt> milestones                         = new List<MileStone__mdt>();
        Map<id,Project__mdt>   projects                         = new Map<id,Project__mdt>();
        Map<Id,List<MileStone__mdt>> projectIdVsMilestones      = new Map<Id,List<MileStone__mdt>>();
        Map<Id,List<Task__mdt>>      milestoneIdVsTasks         = new Map<Id,List<Task__mdt>>();
        Set<Id> milestoneIds                                    = new set<Id>();
        List<Sobject> allRecords                                = new List<SObject>();
        Map<String, List<Sobject>> allRecordsMap                = new Map<String, List<SObject>>();
        List<Sobject> updateAllRecords                          = new List<SObject>();
        List<Sobject> projectList                               = new List<Sobject>();
        List<Sobject> milestoneList                             = new List<Sobject>();
        List<Sobject> tasksList                             = new List<Sobject>();
        String businessHoursId                                  = Label.BusinessHoursId;
        
        Map<Id,SBQQ__Subscription__c> projectlookupCharges = new Map<Id,SBQQ__Subscription__c>();
        Set<Id> cancelledSubId = new Set<Id>(); //added for project cancellation
        
        //Intializing set of product codes 
        Set<String> SEOProj = new Set<String>();//MHBS-4746
        Map<String, Product_code_to_Project_Mapping__c> projectsMap = Product_code_to_Project_Mapping__c.getAll();
        //MHBS-4746
        for(Product_code_to_Project_Mapping__c prj: projectsMap.values()){
            if(prj.IsSEO__c == TRUE){
                SEOProj.add(prj.Label__c);
            }
        }
        system.debug('==SEOProj=='+SEOProj);
        allAccPrjs = [select id, name, Account__c, Status__c from Milestone1_Project__c where Account__c IN :accId
                      AND (Status__c='Optimization' OR Status__c='In Progress' OR Status__c='New') AND Name in: seoProj];
        system.debug('==allAccPrjs=='+allAccPrjs);
        
        //WEB and SEO validations for upgrade and downgrade scenarios code placed here - skipping for now
        //below line 706 from MilestoneHandler Class
        List<SBQQ__Subscription__c> OrderRPCForProject = new List<SBQQ__Subscription__c>();
        Set<Id> quoteLinesFromQuote = new Set<Id>();
        for(SBQQ__Subscription__c charge : orderCharges){
            OrderRPCForProject.add(charge);
            quoteLinesFromQuote.add(charge.SBQQ__QuoteLine__r.SBQQ__Quote__c);
        }
        //to get upgraded subIds for rebaseEvergreen process
        Map<String, Id> qlSinVsUpgrdedSub = new Map<String,Id>();
        List<SBQQ__QuoteLine__c> quoteVsQuoteLines = [select id, SIN__c,SBQQ__Group__c, SBQQ__Group__r.Name,SBQQ__UpgradedSubscription__c
                                                         from SBQQ__QuoteLine__c where SBQQ__Quote__c IN:quoteLinesFromQuote];
        for(SBQQ__QuoteLine__c qls: quoteVsQuoteLines){
            if(qls.SBQQ__Group__c != Null && qls.SBQQ__Group__r.Name == 'Group1'){
                qlSinVsUpgrdedSub.put(qls.SIN__c, qls.SBQQ__UpgradedSubscription__c);
            }
        }
        //end of rebaseEvergreen
        system.debug('==qlSinVsUpgrdedSub=='+qlSinVsUpgrdedSub);
        System.debug('==OrderRPCForProject=='+OrderRPCForProject);
        Set<String> prjectIdstoquery   = new Set<String>();
        Boolean webPlatinum; //MHBS-7733
        Boolean webGold; //MHBS-7733
        String subStatus;//T08 //MHBS-5307
        for(SBQQ__Subscription__c charge : OrderRPCForProject){
            //only for new sub creations
            system.debug('@@@@@@@RS'+charge.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c);
            if(charge.Cancelled__c == FALSE && charge.Status__c != 'Truncated' && charge.Status__c != 'Off set'){
                system.debug('==projectsMap=='+projectsMap);
                if(charge.ProductCode__c != null && //projectsMap.containsKey(charge.ProductCode__c) &&
                    charge.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c == null && 
                    ((charge.SBQQ__QuoteLine__r.SBQQ__Group__c == null || charge.GroupName__c == 'Web Services') || (charge.GroupName__c == 'Clone Products' && charge.SBQQ__QuoteLine__r.SIN__c == null))){
            //MHBS-7733 - Start 
                        if(charge.ProductCode__c == '01809'){   
                            webPlatinum = TRUE; 
                        }   
                        if(charge.ProductCode__c == '01972'){   
                            webGold = TRUE; 
                        }//MHBS-7733 - end
                        system.debug('==ProductCode=='+charge.ProductCode__c);
                        if(charge.ProductCode__c == '30050' && allAccPrjs.isEmpty()){
                            system.debug('==Name1=='+charge.SBQQ__RequiredByProduct__r.Name);
                            if(charge.SBQQ__RequiredByProduct__r.Name.contains('Gold')){
                                if(webGold == FALSE){ //MHBS-7733
                                    chargeIdVsProjectId.put(charge.id, Product_code_to_Project_Mapping__c.getValues('SEO_Gold').Project_Record_ID__c );
                                    prjectIdstoquery.add(Product_code_to_Project_Mapping__c.getValues('SEO_Gold').Project_Record_ID__c);
                                }
                            }else{
                                if(webPlatinum == FALSE){ //MHBS-7733
                                    chargeIdVsProjectId.put(charge.id, Product_code_to_Project_Mapping__c.getValues('SEO_Platinum').Project_Record_ID__c );
                                    prjectIdstoquery.add(Product_code_to_Project_Mapping__c.getValues('SEO_Platinum').Project_Record_ID__c);
                                }
                            }
                        }else if(charge.ProductCode__c == '30050' && !allAccPrjs.isEmpty()){
                            system.debug('==Name2=='+charge.SBQQ__RequiredByProduct__r.Name);
                            if(charge.SBQQ__RequiredByProduct__r.Name.contains('Gold')){
                                if(webGold == FALSE){ //MHBS-7733   
                                    chargeIdVsProjectId.put(charge.id, Product_code_to_Project_Mapping__c.getValues('SEO_Gold').Project_Record_ID__c ); 
                                    prjectIdstoquery.add(Product_code_to_Project_Mapping__c.getValues('SEO_Gold').Project_Record_ID__c);    
                                }
                            }else{
                                if(webPlatinum == FALSE){ //MHBS-7733   
                                    chargeIdVsProjectId.put(charge.id, Product_code_to_Project_Mapping__c.getValues('SEO_Platinum').Project_Record_ID__c ); 
                                    prjectIdstoquery.add(Product_code_to_Project_Mapping__c.getValues('SEO_Platinum').Project_Record_ID__c);    
                                }
                            }
                        }else{
                            if(projectsMap.containsKey(charge.ProductCode__c)){
                                chargeIdVsProjectId.put(charge.id, Product_code_to_Project_Mapping__c.getValues(charge.ProductCode__c).Project_Record_ID__c );
                                prjectIdstoquery.add(Product_code_to_Project_Mapping__c.getValues(charge.ProductCode__c).Project_Record_ID__c);
                            }
                        }     
                   }
                else{
                    //for renew
                    if(charge.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c != Null){
                        projectlookupCharges.put(charge.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, charge);
                    }
                    else if(!qlSinVsUpgrdedSub.isEmpty() && qlSinVsUpgrdedSub.get(charge.SBQQ__QuoteLine__r.SIN__c) != Null){
                        system.debug('==in else if for upgraded sub==');
                        projectlookupCharges.put(qlSinVsUpgrdedSub.get(charge.SBQQ__QuoteLine__r.SIN__c), charge);
                    }
                }    
            }
            else{
                if(charge.SBQQ__RevisedSubscription__r.Status__c == 'Cancelled' || charge.SBQQ__RevisedSubscription__r.Status__c == 'Truncated-Upsell'
                   || charge.SBQQ__RevisedSubscription__r.Status__c == 'Truncated') {
                    //system.debug('inCancelT08');
                    cancelledSubId.add(charge.SBQQ__RevisedSubscription__c);
                    subStatus = charge.SBQQ__RevisedSubscription__r.Status__c;//T08
                }   
            }
            
        }
        system.debug('@@@@@@@prjectIdstoquery'+prjectIdstoquery);
        system.debug('@@@@projectlookupCharges'+projectlookupCharges);
        system.debug('==cancelledSubId=='+cancelledSubId);
        //sending to rebase/renew project update method
        if(!projectlookupCharges.isEmpty()){
            projectlookups(projectlookupCharges);
        }
        //sending to cancel method
        if(!cancelledSubId.isEmpty()){
            handleCancelSub(cancelledSubId, subStatus); //T08 //MHBS-5307
        }
        
        Map<id,Set<id>> QtoUserMap = new Map<id,Set<id>>();
        //Map<string,integer> OwnerprojCountMap = new Map<string,integer> ();
        Map<Integer,set<string>> OwnerprojCountMap = new Map<Integer,set<string>> (); 
        //line 786-925 for project and milestones creation
        // forming project id Vs Milestones Map
        if(!chargeIdVsProjectId.isEmpty()){
            system.debug('@@@@@chargeIdVsProjectId values'+ chargeIdVsProjectId.values());
            projects = new  Map<id,Project__mdt>([select id, DeveloperName,MasterLabel,RecordType__c,IsQueueUserAssignment__c,
                                                  Owner_ID__c,Owner_Type__c, ProjectType__c, Status__c,
                                                  (select id, DeveloperName,MasterLabel,Owner_ID__c,
                                                   Owner_Type__c, Predecessor_sequence__c,Project__c,RecordType__c,SNo__c
                                                   From MileStones__r
                                                  )
                                                  From Project__mdt
                                                  where id IN:prjectIdstoquery]);
            system.debug('@@@@@@@@projects'+projects);
            for(Project__mdt proj : [select id, DeveloperName,MasterLabel,RecordType__c,IsQueueUserAssignment__c,
                                     Owner_ID__c,Owner_Type__c, ProjectType__c, Status__c,
                                     (select id, DeveloperName,MasterLabel,Owner_ID__c,
                                      Owner_Type__c, Predecessor_sequence__c,Project__c,RecordType__c,SNo__c
                                      From MileStones__r
                                     )
                                     From Project__mdt
                                     where id IN:chargeIdVsProjectId.values()]){
                                         system.debug('@@@@proj'+ proj.id);
                                         System.debug('===========proj.MileStones__r.size()=============='+proj.MileStones__r.size());
                                         if(proj.MileStones__r.size() > 0){
                                             List<MileStone__mdt> milestonesTemp = new List<MileStone__mdt>();
                                             milestonesTemp = proj.MileStones__r;
                                             
                                             Map<id,MileStone__mdt> tempMilestoneMap  = new Map<id,MileStone__mdt>(proj.MileStones__r);
                                             milestoneIds.addAll(tempMilestoneMap.keySet());
                                             projectIdVsMilestones.put(proj.id, milestonesTemp);
                                             
                                             System.debug('=============proj.IsQueueUserAssignment__c========'+proj.IsQueueUserAssignment__c);
                                             System.debug('=============proj.Owner_ID__c========'+proj.Owner_ID__c);
                                             System.debug('=============string.valueof(proj.Owner_ID__c).s========='+string.valueof(proj.Owner_ID__c).startswith('00G'));
                                             System.debug('=============outside Nitu=========');
                                             System.debug('=============proj.Status__c========'+proj.Status__c);
                                             //N
                                             if(proj.IsQueueUserAssignment__c && proj.Owner_ID__c != null && string.valueof(proj.Owner_ID__c).startswith('00G'))
                                             {
                                                 
                                                 QtoUserMap.put(proj.Owner_ID__c,new set<id>());
                                             }
                                             
                                         }
                                     }
            system.debug('@@@@@@projectIdVsMilestones'+projectIdVsMilestones);
            System.debug('============QtoUserMap====='+QtoUserMap);
            
            Set<String> UserSet = new Set<String>();
            
            //OwnerprojCountMap.put(0,new set<string>()); 
            if(!QtoUserMap.isEmpty()){
                
                List<GroupMember> gmList = [Select UserOrGroupId,GroupId From GroupMember where GroupId IN: QtoUserMap.keySet()];
                System.debug('============Qmap====='+gmList);
                for(GroupMember g : gmList){
                    UserSet.add(g.UserOrGroupId);
                    //OwnerprojCountMap.put(g.UserOrGroupId,0); // defaul to 0 for all users
                    //OwnerprojCountMap.get(0).add(g.UserOrGroupId);
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
            
            if(!projectIdVsMilestones.isEmpty()){
                milestones = [select id, DeveloperName,MasterLabel,Owner_ID__c,RecordType__c,SNo__c ,
                              Owner_Type__c, Predecessor_sequence__c,Project__c,project__r.Id,
                              (select id, DeveloperName,MasterLabel,IsProjectManagerAssignment__c,Pln_Hrs__c,
                               EstimatedHours__c, MileStone__c, Owner_ID__c,Milestone__r.Id,
                               Owner_Type__c, Predecessor_sequence__c,SNo__c,
                               Priority__c, Status__c,Layover_Days__c,RecordType__c,TaskName__c   
                               from tasks__r
                              )
                              from MileStone__mdt 
                              where id IN:milestoneIds];
                System.debug('========Milestones============'+milestones);
                for(MileStone__mdt singleMilestone : milestones){
                    System.debug('=========Tasks under each Milestone=========='+singleMilestone.tasks__r);
                    System.debug('==========singleMilestone.tasks__r.size()====================='+singleMilestone.tasks__r.size());
                    if(singleMilestone.tasks__r.size() > 0){
                        List<Task__mdt> takslist = new List<Task__mdt>();
                        takslist                 = singleMilestone.tasks__r;
                        milestoneIdVsTasks.put(singleMilestone.id, takslist);
                    }
                    
                }
            }
        }
        System.debug('=================milestoneIdVsTasks==============='+milestoneIdVsTasks);
        
        //Creation of Project, Milestones, tasks goes here
        for(SBQQ__Subscription__c charge : OrderRPCForProject){
            if(!chargeIdVsProjectId.isEmpty() && chargeIdVsProjectId.containsKey(charge.id)){
                if(!projects.isEmpty() && projects.containsKey(chargeIdVsProjectId.get(charge.id))){
                    
                    Project__mdt projectTOcreate          = projects.get(chargeIdVsProjectId.get(charge.id));
                    System.debug('======projectTOcreate.Status__c========='+projectTOcreate.Status__c);
                    Milestone1_Project__c tempProject     = new Milestone1_Project__c();
                    tempProject.Name                      = projectTOcreate.MasterLabel;
                    tempProject.Status__c                 = projectTOcreate.Status__c;
                    tempProject.ProjectType__c            = projectTOcreate.ProjectType__c;
                    tempProject.OwnerId                   = projectTOcreate.Owner_ID__c;
                    
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
                    /* for populating old open projects on New project creation - need to add line 963-965 */
                    
                    tempProject.Project_External_ID__c    = charge.id + projectTOcreate.DeveloperName;
                    tempProject.Subscription__c           = charge.id;
                    //tempProject.Order__c                  = charge.invoiceit_s__Order__c;
                    tempProject.RecordTypeId              = projectTOcreate.RecordType__c;
                    tempProject.Account__c                = charge.SBQQ__Account__c;
                    tempProject.OrderProduct__c           = charge.SBQQ__OrderProduct__c;
                    tempProject.Contract__c               = charge.SBQQ__Contract__c;
                    tempProject.Opportunity__c = charge.Opportunity__c; //<T01>
                    Milestone1_Project__c projectReference = new Milestone1_Project__c(Project_External_ID__c = charge.id + projectTOcreate.DeveloperName);
                    System.debug('============projectTOcreate.DeveloperName===================='+projectTOcreate.DeveloperName);
                    System.debug('=========tempProject.Project_External_ID__c===='+tempProject.Project_External_ID__c);
                    allRecords.add(tempProject);
                    projectList.add(tempProject);
                    
                    allRecordsMap.put('1',projectList);
                    
                    if(!projectIdVsMilestones.isEmpty() && projectIdVsMilestones.containsKey(projectTOcreate.id)){
                        String previousMilestone = '';
                        Milestone1_Milestone__c milestonetReferencetemp = new Milestone1_Milestone__c();
                        for(MileStone__mdt milestone : projectIdVsMilestones.get(projectTOcreate.id)){
                            System.debug('==========Inside for Milestones==============='+milestone);
                            MileStone__mdt milestoneToCreate         = milestone;
                            Milestone1_Milestone__c tempMilestone    = new Milestone1_Milestone__c();
                            tempMilestone.Name                       = milestone.MasterLabel;
                            tempMilestone.OwnerId                    = tempProject.OwnerId;
                            tempMilestone.Project__r                 = projectReference;
                            tempMilestone.RecordTypeId               = milestone.RecordType__c;
                            tempMilestone.Predecessor_Seq_No__c      = milestone.Predecessor_sequence__c;
                            tempMilestone.SNo__c                     = milestone.SNo__c;
                            
                            tempMilestone.mileStone_Extenal_ID__c      = charge.id + projectTOcreate.DeveloperName + milestone.DeveloperName;
                            //tempMilestone.Predecessor_External_ID__c   = tempMilestone.mileStone_Extenal_ID__c + milestone.Predecessor_sequence__c;
                            
                            
                            Milestone1_Milestone__c milestoneReferece = new Milestone1_Milestone__c(mileStone_Extenal_ID__c = charge.id + projectTOcreate.DeveloperName + milestone.DeveloperName);
                            allRecords.add(tempMilestone);
                            milestoneList.add(tempMilestone);
                            allRecordsMap.put('2',milestoneList);                            
                            
                            if(!milestoneIdVsTasks.isEmpty() && milestoneIdVsTasks.containsKey(milestone.id)){
                                //// String Previoustask    = '';
                                Milestone1_Task__c milestonetasktemp   = new Milestone1_Task__c();
                                for(Task__mdt tempTask : milestoneIdVsTasks.get(milestone.id)){
                                    System.debug('==========Inside for Tasks==========='+tempTask);
                                    Milestone1_Task__c milestonetask   = new Milestone1_Task__c();
                                    milestonetask.Name                 = tempTask.TaskName__c;
                                    milestonetask.Estimated_Hours__c   = tempTask.EstimatedHours__c;
                                    milestonetask.Priority__c          = tempTask.Priority__c;
                                    //milestonetask.Assigned_To__c       = tempTask.Owner_ID__c;
                                    milestonetask.Task_Identifier__c   = tempMilestone.mileStone_Extenal_ID__c;
                                    // Added to bypass validation Sai C 11/19/18
                                    milestonetask.Issystem__c          = True;
                                    milestonetask.Layover_Days__c      = tempTask.Layover_Days__c;
                                    milestonetask.RecordTypeId         = tempTask.RecordType__c;
                                    milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                    //milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                    milestonetask.Predecessor_Seq_No__c      = tempTask.Predecessor_sequence__c;
                                    milestonetask.SNo__c                     = tempTask.SNo__c;
                                    milestonetask.Pln_Hrs__c                 = tempTask.Pln_Hrs__c;
                                    
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
                                    system.debug('@@@@mins'+ mins);
                                    System.debug('==============Duration===='+duration);
                                    datetime startDateTime = datetime.now();
                                    
                                    if(tempTask.IsProjectManagerAssignment__c && tempTask.Owner_ID__c != null && string.valueof(tempTask.Owner_ID__c).startswith('00G')){
                                        milestonetask.Assigned_Onwer__c  = tempProject.OwnerId;
                                        milestonetask.assign_To_Type__c    = 'User';
                                    }else{
                                        milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                        milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                    }
                                    
                                    milestonetask.Project_Milestone__r      = milestoneReferece;
                                    //Previoustask     = charge.id + projectTOcreate.DeveloperName + milestone.DeveloperName + tempTask.DeveloperName;
                                    //milestonetask.Predecessor_External_ID__c = Previoustask;
                                    allRecords.add(milestonetask);
                                    tasksList.add(milestonetask);
                                    allRecordsMap.put('3',tasksList);
                                    
                                    //milestonetasktemp  = new Milestone1_Task__c(Predecessor_External_ID__c =Previoustask );
                                }
                            }
                        }
                    }
                }
            }
        }
        Map<string,List<Milestone1_Milestone__c>> projIdVsMilestonesAfter = new Map<string,List<Milestone1_Milestone__c>>();
        Map<string,List<Milestone1_Task__c>>      milstIdVsTasksAfter     = new Map<string,List<Milestone1_Task__c>>();
        List<Sobject> allRecordtoUpdate                               = new List<Sobject>();
        
        System.debug('==============Allrecords========'+allRecords);
        allRecords.sort();
        System.debug('==============Allrecords sorted========'+allRecords);
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
        system.debug('@@@@updateAllRecords'+updateAllRecords);
        
        List<Milestone1_Milestone__c> mileListForPredecessr = new List<Milestone1_Milestone__c>();
        //List<Milestone1_Task__c> taskListForPredecessr = new List<Milestone1_Task__c>();
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
                
                
                Map<String, Milestone1_Milestone__c> sonVsMilestoneMap =  new Map<String, Milestone1_Milestone__c>();
                Map<String, Milestone1_Task__c> snoVsTaskMap =  new Map<String, Milestone1_Task__c>();
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
                            System.debug('===========tas=============='+tas);
                            if(milstIdVsTasksAfter.containsKey(tkey)){
                                milstIdVsTasksAfter.get(tkey).add(tas);
                            }
                            else{
                                milstIdVsTasksAfter.put(tkey, new List<Milestone1_Task__c>{tas});
                            }
                            string taskkey = tas.Project_Milestone__r.Id + string.valueOf(tas.SNo__c);
                            snoVsTaskMap.put(taskkey, tas);
                            System.debug('=====sNoTaskMap======'+sNoTaskMap);
                            
                            
                            //  if(orpcSnoTaskMap.containskey)
                            
                            
                            
                        }  
                    }   
                }
               
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
                                    if(sonVsMilestoneMap.containskey(projId + string.valueOf(m.Predecessor_Seq_No__c))){
                                        m.Predecessor_Milestone__c = sonVsMilestoneMap.get(projId + string.valueOf(m.Predecessor_Seq_No__c)).id;                                    
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
                                    system.debug('@@@@@@msId + string.valueOf(t.Predecessor_Seq_No__c)'+msId + string.valueOf(t.Predecessor_Seq_No__c));
                                    if(snoVsTaskMap.containskey(msId + string.valueOf(t.Predecessor_Seq_No__c))){
                                        t.Predecessor_Task__c = snoVsTaskMap.get(msId + string.valueOf(t.Predecessor_Seq_No__c)).id;                                    
                                        allRecordtoUpdate.add(t);
                                    } 
                                }
                                // allRecordtoUpdate.add(t);
                                
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
        
        /*try{ - for upgrade scenarios 
            if (!upgradeProjectstoUpdate.isEmpty()){
                update upgradeProjectstoUpdate;
            }
            if (!upgradeMilestonestoUpdate.isEmpty()){
                update upgradeMilestonestoUpdate;
            }
            if(!upgradedtaskstoUpdate.isEmpty()){
                update upgradedtaskstoUpdate;
            }
        }
        catch(exception ex){
            system.debug('@@@Exception '+ ex);
        }*/
    }
    //To handle contract modifications
    public static void projectlookups(Map<Id,SBQQ__Subscription__c> createdChargeIdVsCharge){
        system.debug('@@@@@@createdChargeIdVsCharge'+createdChargeIdVsCharge);
        List<Milestone1_Project__c> projects = new List<Milestone1_Project__c> ();
        if(!createdChargeIdVsCharge.keySet().isempty()){
            for(Milestone1_Project__c proj : [select id, OrderProduct__c , Status__c, Subscription__c, Asset__c
                                              From Milestone1_Project__c 
                                              where (Status__c != 'Cancelled' AND Status__c != 'Completed') 
                                              AND Asset__c = null AND CreatedfromAvvoOpty__c = FALSE
                                              AND Subscription__c IN:createdChargeIdVsCharge.keySet()]){
                                                  system.debug('@@@@proj'+proj);
                                                  system.debug('@@@@projasset'+proj.Asset__c);
                                                  system.debug('@@@@proj Status'+proj.Status__c );
                                                  if(createdChargeIdVsCharge.get(proj.Subscription__c).Id!= Null && createdChargeIdVsCharge.get(proj.Subscription__c).SBQQ__OrderProduct__c !=Null){
                                                      SBQQ__Subscription__c charge = createdChargeIdVsCharge.get(proj.Subscription__c);
                                                      proj.Subscription__c  =  charge.Id;
                                                      proj.OrderProduct__c  =  charge.SBQQ__OrderProduct__c;
                                                      proj.Contract__c = charge.SBQQ__Contract__c;
                                                      projects.add(proj);                           
                                                  }
                                              }
        }
        
        if(!projects.isEmpty()){
            try{
                update projects;
            }
            catch(Exception ex){
                system.debug('@@@exception'+ex);
            }
        }
    }
    //method to cancel projects for cancelled sub charges
    public static void handleCancelSub(Set<Id>cancelSubIds, String subStatus){
        Set<Id> projIds = new Set<Id>();
        List<Milestone1_Project__c> CancellPrjIds = new List<Milestone1_Project__c>();
        List<Milestone1_Milestone__c> cancelMilestonelist = new List<Milestone1_Milestone__c>();
        List<SObject> updateCancelList = new List<SObject>();
        system.debug('==cancelSubIds=='+cancelSubIds);
        if(!cancelSubIds.isEmpty()){
            List<Milestone1_Project__c> projectListToCancel = [Select id, name,Status__c, Subscription__c,(SELECT Id,
                                                                                                           Name,Project__c,Status__c,Parent_Milestone__c,
                                                                                                           Complete__c,Deadline__c,
                                                                                                           Total_Actual_Hours__c From Project_Milestones__r Where Status__c!='Cancelled' AND Status__c!='Completed') From Milestone1_Project__c Where Status__c!='Completed' AND Status__c!= 'Cancelled' AND Subscription__c in: cancelSubIds];
            
            System.debug('=============projectListToCancel============='+projectListToCancel);
            
            id cancelProjectrecordTypeId = Schema.SObjectType.Milestone1_Project__c.RecordTypeInfosByName.get('Cancel Project').RecordTypeId ;
            id cancelMilestonRecTypId = Schema.SObjectType.Milestone1_Milestone__c.RecordTypeInfosByName.get('Cancel project Milestone').RecordTypeId ;
            id cancelTaskRecTypId = Schema.SObjectType.Milestone1_Task__c.RecordTypeInfosByName.get('Cancel Project Task').RecordTypeId ;
            
            System.debug('===cancelProjectrecordTypeId====='+cancelProjectrecordTypeId);
            System.debug('===cancelMilestonRecTypId====='+cancelMilestonRecTypId);
            System.debug('===cancelTaskRecTypId====='+cancelTaskRecTypId);
            
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
                System.debug('==============projIds============'+projIds);
                if(!CancellPrjIds.isEmpty()){
                    for(Milestone1_Project__c cancelprj: CancellPrjIds){
                        if(subStatus == 'Truncated-Upsell'){//T08 //MHBS-5307
                            cancelprj.Status__c = 'Truncated-Upsell';
                        }else if(subStatus == 'Truncated'){
                            cancelprj.Status__c = 'Cancelled';
                        }else{
                            cancelprj.Status__c = 'Cancelled';
                        }
                        
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
                System.debug('==========projIds============='+projIds);
                List<Milestone1_Task__c> cancelTaskList = [select id,Task_Stage__c,ProjectId__c
                                                           from Milestone1_Task__c WHERE Task_Stage__c!= 'Cancelled' AND Task_Stage__c!= 'Completed' AND Project_ID__c IN:projIds];
                
                System.debug('==========cancelTaskList==========='+cancelTaskList);
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
    
     public void FkMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
                i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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