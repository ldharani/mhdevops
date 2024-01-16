/*******************************************************************************************************
 * Author      : Akash
 * Description : whenever a charge is created, we need to create Project --> Milestone(child of project) --> tasks(child of each milestone)
 * Date        : 27/03/2017
 * *****************************************************************************************************/


public class MileStoneHandler {
    public Milestone1_Project__c projObj{get;set;}
    public String selectedProjName{get;set;}
    public list<selectoption> projNamesList{get;set;}
    Map<id,Project__mdt> projects = new Map<id,Project__mdt>();
    //Map<Id,List<MileStone__mdt>> projectIdMilestones;
    Set<Id> projectIds{get;set;}
    Map<String,Project__mdt> projectMap = new Map<String,Project__mdt>();
    String insertedProjId{get;set;}    
    
    public MileStoneHandler(ApexPages.StandardController standardController) {
        projObj= new Milestone1_Project__c();
        projNamesList = new list<selectoption>();
        //projectIdMilestones = new Map<Id,List<MileStone__mdt>>();
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
            
    if(!projectsInner.isEmpty()){
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
                            
           /* if(QtoUserMap.containsKey(projectTOcreate.Owner_ID__c)){
                for(id uid : QtoUserMap.get(projectTOcreate.Owner_ID__c)){
                    if(OwnerprojCountMap.containsKey(uid)){
                        if(tempProject.OwnerId == projectTOcreate.Owner_ID__c){
                            tempProject.OwnerId = uid;
                        }
                        if(OwnerprojCountMap.get(uid) < OwnerprojCountMap.get(tempProject.OwnerId)){
                            tempProject.OwnerId = uid;
                            integer incrementCOunt = OwnerprojCountMap.get(uid) + 1;
                            OwnerprojCountMap.put(uid, incrementCOunt);
                        }
                    }
                }
                */
            }
        }                  
        
        tempProject.Project_External_ID__c    = userinfo.getuserid()+system.now()+projectTOcreate.DeveloperName;//charge.id + projectTOcreate.DeveloperName;
        tempProject.Order_Rate_Plan_Charge__c = projObj.Order_Rate_Plan_Charge__c;
        tempProject.Order__c                  = projObj.Order__c;
        tempProject.RecordTypeId              = projectTOcreate.RecordType__c;
        tempProject.Account__c                = projObj.Account__c;
        
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
                if(!milestone.MasterLabel.contains('Review Page Plus')){
                    tempMilestone.OwnerId                    = tempProject.OwnerId;
                  }
                else{
                   tempMilestone.OwnerId                    = milestone.Owner_ID__c;
                }
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
    
    
    public static void createProjects(Set<Id> chargeIds){
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> orderCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> orderChargestemp 
                 = [select id, Name,invoiceit_s__Accounting_Code__c,Account_Owner_Email__c,
                            Created_From_Charge__c, invoiceit_s__Order__c,Account_Id__c,Created_From_Charge__r.invoiceit_s__Accounting_Code__c,
                            Created_From_Charge__r.Name, RecordType.Name, invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Base_Package__c,
                            invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Package_Status__c, invoiceit_s__Order__r.invoiceit_crmx__Opportunity__r.Target_Package__c,
                            Live_Date__c, Created_From_Charge__r.Live_Date__c From invoiceit_s__Job_Rate_Plan_Charge__c
                             where Id IN:chargeIds];
        system.debug('==orderChargestemp=='+orderChargestemp);
        
        /********Handling Upgrade Scneario  Start: Sai : 30/08/2018****************************/
        Map<Id,Id> chargeIdVsOldprojectId = new Map<Id,Id>();
        //Map<Id,Id> chargeIdVsOldProjOwnerId = new Map<Id,Id>(); //added by saiv for MHBS-3638 01/02/2020
        //Map<Id,Id> chargeIdVsOldProjSEOStrategstId = new Map<Id,Id>(); //added by saiv for MHBS-3638 01/02/2020
        Map<Id,Id> createdFromChargeIdVschargeId = new Map<Id,Id>();
        Set<Id> upgradedOrderstoInclude = new Set<Id>();
        Set<Id> upgradeEligibleCharges  = new Set<Id>();
        Set<Id> upgradedToSEOGoldfromSEOPlat = new Set<Id>();
        List<Milestone1_Project__c> upgradeProjectstoUpdate     = new List<Milestone1_Project__c>();
        List<Milestone1_Milestone__c> upgradeMilestonestoUpdate = new List<Milestone1_Milestone__c>();
        List<Milestone1_Task__c> upgradedtaskstoUpdate          = new List<Milestone1_Task__c>();
        
        For (invoiceit_s__Job_Rate_Plan_Charge__c ordcharge : orderChargestemp) {
            system.debug('==upgradeEligibleCharges=='+upgradeEligibleCharges);
            system.debug('==ordcharge.Created_From_Charge__c=='+ordcharge.Created_From_Charge__c);
            system.debug('==ordcharge.invoiceit_s__Accounting_Code__c=='+ordcharge.invoiceit_s__Accounting_Code__c);
            system.debug('==ordcharge.Created_From_Charge__r.invoiceit_s__Accounting_Code__c=='+ordcharge.Created_From_Charge__r.invoiceit_s__Accounting_Code__c);
            system.debug('==ordcharge.Created_From_Charge__r.Name=='+ordcharge.Created_From_Charge__r.Name);
            system.debug('==ordcharge.Name=='+ordcharge.Name);
            if(ordcharge.Created_From_Charge__c != NULL  && ordcharge.Created_From_Charge__r.Name != ordcharge.Name
                 && ordcharge.RecordType.Name == 'M-H Order Rate Plan Charge'){
                createdFromChargeIdVschargeId.put(ordcharge.Created_From_Charge__c,ordcharge.id);
                upgradeEligibleCharges.add(ordcharge.id);
                system.debug('==upgradeEligibleCharges=='+upgradeEligibleCharges);
                system.debug('==createdFromChargeIdVschargeId=='+createdFromChargeIdVschargeId);
            }
            
            if(ordcharge.Created_From_Charge__c != NULL && ordcharge.Created_From_Charge__r.Name != ordcharge.Name
                 && ordcharge.RecordType.Name == 'M-H Order Rate Plan Charge' && ordcharge.invoiceit_s__Accounting_Code__c == '30055'
                 && ordcharge.Created_From_Charge__r.invoiceit_s__Accounting_Code__c == '30057'){
                     upgradedToSEOGoldfromSEOPlat.add(ordcharge.id);
                     system.debug('====upgradedToSEOGoldfromSEOPlat===='+upgradedToSEOGoldfromSEOPlat);
                 }
            
            
        }
        //previous project is null for seo gold when pkg downgrdaded to gold from platinum
        if (!createdFromChargeIdVschargeId.isEmpty()){
            For (Milestone1_Project__c proj : [Select id, Name,Order_Rate_Plan_Charge__c,
                                                  Status__c,
                                                  (select id,Status__c 
                                                    From Project_Milestones__r Where Status__c  != 'Cancelled' AND Status__c  != 'Completed' AND Status__c  != 'Not Needed')
                                                  From Milestone1_Project__c 
                                                  where Order_Rate_Plan_Charge__c != NULL
                                           AND Order_Rate_Plan_Charge__c IN:createdFromChargeIdVschargeId.keySet()
                                           AND Status__c != 'Completed' AND Status__c != 'Cancelled']){
                 system.debug('==proj=='+proj);                            
                 upgradedOrderstoInclude.add(createdFromChargeIdVschargeId.get(proj.Order_Rate_Plan_Charge__c)); 
                 //getting projects to update  
                       proj.Status__c = 'Migrated to new order project';                            
                 upgradeProjectstoUpdate.add(proj);
                 chargeIdVsOldprojectId.put(proj.Order_Rate_Plan_Charge__c,proj.id);
                 //chargeIdVsOldProjOwnerId.put(proj.Order_Rate_Plan_Charge__c,proj.OwnerId); //added by saiv for MHBS-3638 01/02/2020
                 //chargeIdVsOldProjSEOStrategstId.put(proj.Order_Rate_Plan_Charge__c,proj.SEO_Strategist__c); //added by saiv for MHBS-3638 01/02/2020
                 //system.debug('====chargeIdVsOldProjOwnerId===='+chargeIdVsOldProjOwnerId);
                 //system.debug('====chargeIdVsOldProjSEOStrategstId===='+chargeIdVsOldProjSEOStrategstId);
                 //getting milestones to update                              
                 for(Milestone1_Milestone__c ms : proj.Project_Milestones__r){
                       ms.Status__c = 'Migrated to new order milestone';
                       upgradeMilestonestoUpdate.add(ms);                            
                 }                              
                                               
            }
            
        }
        
        //getting tasks to update
        if(!upgradeMilestonestoUpdate.isEmpty()){
            for(Milestone1_Task__c  mt : [select id, Task_Stage__c 
                                                From Milestone1_Task__c 
                                          Where Project_Milestone__c  IN:upgradeMilestonestoUpdate  AND Task_Stage__c != 'Completed' AND Task_Stage__c != 'Not Required']){
                mt.Task_Stage__c =  'migrated to new order task';
                upgradedtaskstoUpdate.add(mt);                                 
            }
        }
        
        for (invoiceit_s__Job_Rate_Plan_Charge__c ordcharge : orderChargestemp){
            //checking eligible for upgrade
            if(!upgradeEligibleCharges.contains(ordcharge.id)){
                 orderCharges.add(ordcharge);
                 system.debug('===orderChargesinif=='+orderCharges);
            }
            //else{
                //checking for non-completion of previous charge project
            else if(upgradedOrderstoInclude.contains(ordcharge.id)){
                orderCharges.add(ordcharge);
                system.debug('===orderChargesinelse=='+orderCharges);
            }
            //}
            else if(upgradedToSEOGoldfromSEOPlat.contains(ordcharge.id)){
                orderCharges.add(ordcharge);
                system.debug('===orderChargesinLASTELSEIF===='+orderCharges);
            }
            
        }
        
     //T1   
     map<string,list<string>> mapofURLtoProductName = new map<string,list<string>>();
     list<Order_Charge_Attribute__c> listofatt = [select Id, Name,Order_Rate_Plan_Charge__c,Order_Rate_Plan_Charge__r.Name,Attribute_Name__c,String_Value__c,   
                                           Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,    
                                           Order_Rate_Plan_Charge__r.Created_From_Charge__r.Live_Date__c,Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c,   
                                           Order_Rate_Plan_Charge__r.Created_From_Charge__c     
                                           from Order_Charge_Attribute__c where     
                                           Order_Rate_Plan_Charge__c    
                                            in : orderChargestemp and Attribute_Name__c = 'URL'];   
                                     map<string,list<Order_Charge_Attribute__c>> mapofURLtoAtt = new map<string,list<Order_Charge_Attribute__c>>(); 
                        for(Order_Charge_Attribute__c att: listofatt ){ 
                        if(att.Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c!='01980'){
                             if(mapofURLtoAtt.containskey(att.String_Value__c)){    
                                list<Order_Charge_Attribute__c> templist = mapofURLtoAtt.get(att.String_Value__c);  
                                templist.add(att);  
                                mapofURLtoAtt.put(att.String_Value__c,templist);    
                             }else{ 
                                mapofURLtoAtt.put(att.String_Value__c,new list<Order_Charge_Attribute__c>{att});    
                             } 
                         }
                         //populate product list
                         string productname = att.Order_Rate_Plan_Charge__r.Name;
                         if(mapofURLtoProductName.containskey(att.String_Value__c)){  
                          list<string> templist = mapofURLtoProductName.get(att.String_Value__c);  
                            templist.add(productname);  
                            mapofURLtoProductName.put(att.String_Value__c,templist);    
                         }else{ 
                            mapofURLtoProductName.put(att.String_Value__c,new list<string>{productname});    
                         }                             
                        }   
        
        
        
       /****************** Handling Upgrade Scneario  End*************************************/
                             
   // public static void createProjects(List<invoiceit_s__Job_Rate_Plan_Charge__c> orderCharges){    
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
        //added by sai:28/06/2017
        Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> projectlookupCharges = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        //Intializing set of product codes 
        Map<String, Product_code_to_Project_Mapping__c> projectsMap = Product_code_to_Project_Mapping__c.getAll();
        System.debug('projectsMap here'+projectsMap );
        
        Boolean seoGoldFlag = false;
        Boolean webGoldFlag = false;
        Boolean seoPlatinumFlag = false;
        Boolean webPlatinumFlag = false;
        Boolean oldWebGoldFlag = false;//added new boolean by saiv 12/20/19
        Boolean oldWebPlatinumFlag = false;
        Boolean seoGoldFromPlatinumFlag = false;
        
        Boolean removeROF = false;  
            
        List<String> accountingCodes = new List<String>();  
        set<Id> updateMilestoneROF = new set<id>();
        set<Id> updateNotReqMilestoneROF = new set<id>();
        Set<id> removeOrderCharges = new Set<id>();
        Map<String, String> ChargeIdNAccountingCodeMap = new Map<String, String>();
        Map<Id, Date> ChargeIdVsLiveDateMap = new Map<Id, Date>();
        for(invoiceit_s__Job_Rate_Plan_Charge__c charge : orderCharges){
            if(charge.invoiceit_s__Accounting_Code__c != null){
                ChargeIdNAccountingCodeMap.put(charge.id, charge.invoiceit_s__Accounting_Code__c);
                accountingCodes.add(charge.invoiceit_s__Accounting_Code__c);
                System.debug('=========charge.Created_From_Charge__c========='+charge.Created_From_Charge__c);
                System.debug(LoggingLevel.INFO,'=========charge.invoiceit_s__Accounting_Code__c========='+charge.invoiceit_s__Accounting_Code__c);
                //System.debug('====contains===='+charge.Created_From_Charge__r.Name.contains('Platinum'));
                if(charge.invoiceit_s__Accounting_Code__c == '01972' && charge.Created_From_Charge__c!= NULL &&
                    charge.Created_From_Charge__r.Name.contains('Platinum') && charge.Created_From_Charge__r.Live_Date__c!=NULL){
                        ChargeIdVsLiveDateMap.put(charge.Created_From_Charge__r.Id, charge.Created_From_Charge__r.Live_Date__c);
                        //removeOrderCharges.add(charge.id);
                    }
                    system.debug('====ChargeIdVsLiveDateMap====='+ChargeIdVsLiveDateMap);
                    system.debug('mapofURLtoAtt'+mapofURLtoAtt);
                if(charge.invoiceit_s__Accounting_Code__c == '30055' && charge.Created_From_Charge__c== NULL){
                    seoGoldFlag = True;
                    removeOrderCharges.add(charge.id);
                }else if(charge.invoiceit_s__Accounting_Code__c == '01980'){    
                    for(Order_Charge_Attribute__c objatt: listofatt){   
                       if(objatt.Order_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c == '01980' && mapofURLtoAtt.containskey(objatt.String_Value__c) && 
                       objatt.Order_Rate_Plan_Charge__c == charge.id){ 
                        system.debug('enter ROF');
                      for(Order_Charge_Attribute__c att: mapofURLtoAtt.get(objatt.String_Value__c)){    
                      system.debug('att.Order_Rate_Plan_Charge__r.Name' + att.Order_Rate_Plan_Charge__r.Name + att.Order_Rate_Plan_Charge__c);
                       if(att.Order_Rate_Plan_Charge__r.Name.contains('Web Bronze') || att.Order_Rate_Plan_Charge__r.Name.contains('Web Silver')){    
                          if(att.Order_Rate_Plan_Charge__r.Created_From_Charge__c == NULL || (att.Order_Rate_Plan_Charge__r.Created_From_Charge__c != NULL &&   
                            att.Order_Rate_Plan_Charge__r.Created_From_Charge__r.Live_Date__c==NULL)){  
                           // system.debug('enter'+ att.Order_Rate_Plan_Charge__r.Created_From_Charge__r.Live_Date__c);
                            removeROF = true;   
                            updateMilestoneROF.add(att.Order_Rate_Plan_Charge__c);  
                             removeOrderCharges.add(charge.id);     
                          } 
                       }    
                    }   
                   }    
                    }  
                      } else if(charge.Name.contains('Web Bronze') || charge.Name.contains('Web Silver')){
                       for(Order_Charge_Attribute__c att: listofatt){ 
                           if(att.Order_Rate_Plan_Charge__r.Name.contains('Web Bronze') || att.Order_Rate_Plan_Charge__r.Name.contains('Web Silver')){    
                          if(att.Order_Rate_Plan_Charge__r.Created_From_Charge__c == NULL || (att.Order_Rate_Plan_Charge__r.Created_From_Charge__c != NULL &&   
                            att.Order_Rate_Plan_Charge__r.Created_From_Charge__r.Live_Date__c==NULL)){
                            string webURL = att.String_Value__c;
                            //system.debug('enter Iesh'); 
                        if(mapofURLtoProductName.containskey(webURL)){
                           list <string> productsName = mapofURLtoProductName.get(webURL);
                           //system.debug('productsName'+productsName);
                           if(!productsName.contains('Review Page Plus')){
                             updateNotReqMilestoneROF.add(att.Order_Rate_Plan_Charge__c);
                             //system.debug('check');  
                             }
                        }
                      }
                    }
                       
                 }  
                      
                      }else if(charge.invoiceit_s__Accounting_Code__c == '01972' && charge.Created_From_Charge__c== NULL){
                    webGoldFlag = True;
                }else if(charge.invoiceit_s__Accounting_Code__c == '30057' && charge.Created_From_Charge__c== NULL){
                    seoPlatinumFlag = True;
                    removeOrderCharges.add(charge.id);
                }else if(charge.invoiceit_s__Accounting_Code__c == '01809' && charge.Created_From_Charge__c== NULL){
                    webPlatinumFlag = True;
                }else if(charge.invoiceit_s__Accounting_Code__c == '01972' && charge.Created_From_Charge__c!= NULL && 
                         !charge.Created_From_Charge__r.Name.contains('Platinum') && charge.Created_From_Charge__r.Live_Date__c==NULL){
                         System.debug('====contains webplat===='+charge.Created_From_Charge__r.Name.contains('Platinum'));
                    oldWebGoldFlag = True;
                    //added else if by saiv 12/20/90
                }else if(charge.invoiceit_s__Accounting_Code__c == '01809' && charge.Created_From_Charge__c!= NULL){
                    oldWebPlatinumFlag = True;
                }else if(charge.invoiceit_s__Accounting_Code__c == '30055' && charge.Created_From_Charge__c!= NULL && !ChargeIdVsLiveDateMap.isEmpty()
                         && charge.Created_From_Charge__r.Name.contains('Platinum')){
                    System.debug('====contains seoplat===='+charge.Created_From_Charge__r.Name.contains('Platinum'));
                    seoGoldFromPlatinumFlag = True;
                }
                else if(charge.invoiceit_s__Accounting_Code__c == '01972' && charge.Created_From_Charge__c!= NULL && 
                         charge.Created_From_Charge__r.Name.contains('Platinum') && charge.Created_From_Charge__r.Live_Date__c!=NULL){
                         system.debug('====web gold removal===='+charge.Created_From_Charge__r.Live_Date__c);
                         removeOrderCharges.add(charge.id);
                }else if((charge.invoiceit_s__Accounting_Code__c == '12002' || charge.invoiceit_s__Accounting_Code__c == '12003'||
                            charge.invoiceit_s__Accounting_Code__c == '12011' || charge.invoiceit_s__Accounting_Code__c == '12012')
                            && charge.Created_From_Charge__c!= NULL){//added for repboost MHBS-3568 by saiv
                    system.debug('====Rep boost code=='+charge.invoiceit_s__Accounting_Code__c);        
                    removeOrderCharges.add(charge.id);
                }
            }
        }
        System.debug('==========Accounting Codes====='+accountingCodes);
        System.debug('==========seoGoldFlag====='+seoGoldFlag);
        System.debug('==========webGoldFlag====='+webGoldFlag);
        System.debug('==========seoGoldFromPlatinumFlag====='+seoGoldFromPlatinumFlag);
        System.debug('==========oldWebGoldFlag====='+oldWebGoldFlag);
        System.debug('==========removeOrderCharges====='+removeOrderCharges);
        
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> OrderRPCForProject = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        
        
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c charge : orderCharges){
            if(webGoldFlag && seoGoldFlag){
                system.debug('webGoldFlag'+webGoldFlag);
                system.debug('seoGoldFlag'+seoGoldFlag);
                if(!removeOrderCharges.contains(charge.id)){
                        OrderRPCForProject.add(charge);
                        system.debug('OrderRPCForProject'+OrderRPCForProject);
                }
            }else if(seoPlatinumFlag && webPlatinumFlag) {
                if(!removeOrderCharges.contains(charge.id)){
                    //if(!OrderRPCForProject.contains(charge)){
                        OrderRPCForProject.add(charge);
                    //}
                }
                
            }   
              else if( removeROF ){ 
              if(!removeOrderCharges.contains(charge.id)){  
                     OrderRPCForProject.add(charge);    
                }
              }
                else if(oldWebGoldFlag && seoGoldFlag){//added else if by saiv 12/20/19
                system.debug('oldWebGoldFlag'+oldWebGoldFlag);
                system.debug('seoGoldFlag'+seoGoldFlag);
                if(!removeOrderCharges.contains(charge.id)){
                        OrderRPCForProject.add(charge);
                        system.debug('OrderRPCForProject'+OrderRPCForProject);
                }
            }else if(oldWebPlatinumFlag && seoPlatinumFlag){//added else if by saiv 12/23/19
                system.debug('oldWebPlatinumFlag'+oldWebPlatinumFlag);
                system.debug('seoPlatinumFlag'+seoPlatinumFlag);
                if(!removeOrderCharges.contains(charge.id)){
                        OrderRPCForProject.add(charge);
                        system.debug('OrderRPCForProject'+OrderRPCForProject);
                }
            }else if(seoGoldFromPlatinumFlag){//added else if by saiv 12/27/19
                if(!removeOrderCharges.contains(charge.id)){
                    OrderRPCForProject.add(charge);
                    system.debug('===OrderRPCForProject==='+OrderRPCForProject);
                }
            }else{
                OrderRPCForProject.add(charge);
            }
        }
     
        System.debug('==============OrderRPCForProject======='+OrderRPCForProject.size());
        System.debug('==OrderRPCForProject=='+OrderRPCForProject);
      
        
        Set<String> prjectIdstoquery   = new Set<String>();
        
        //getting Project ids to 
        for(invoiceit_s__Job_Rate_Plan_Charge__c charge : OrderRPCForProject){
            system.debug('@@@@@@@charge Accounting Code'+charge.invoiceit_s__Accounting_Code__c);
            //condition added to create project only when it is first order    : Sai
            system.debug('contains Key:'+projectsMap.containsKey(charge.invoiceit_s__Accounting_Code__c));
            if(charge.invoiceit_s__Accounting_Code__c != null  && projectsMap.containsKey(charge.invoiceit_s__Accounting_Code__c)){
                if(charge.Created_From_Charge__c == NULL || charge.Created_From_Charge__r.Name != charge.name){
                    chargeIdVsProjectId.put(charge.id, Product_code_to_Project_Mapping__c.getValues(charge.invoiceit_s__Accounting_Code__c).Project_Record_ID__c );
                    prjectIdstoquery.add(Product_code_to_Project_Mapping__c.getValues(charge.invoiceit_s__Accounting_Code__c).Project_Record_ID__c);
                }
                else{
                    projectlookupCharges.put(charge.Created_From_Charge__c, charge);
                }
                
            }
        }
        
        system.debug('@@@@@@@prjectIdstoquery'+prjectIdstoquery);
        system.debug('@@@@projectlookupCharges'+projectlookupCharges);
        
        //added by sai:28/06/2017
        if(!projectlookupCharges.isEmpty()){
            projectlookups(projectlookupCharges);
        }
        
        
        Map<id,Set<id>> QtoUserMap = new Map<id,Set<id>>();
        //Map<string,integer> OwnerprojCountMap = new Map<string,integer> ();
          Map<Integer,set<string>> OwnerprojCountMap = new Map<Integer,set<string>> ();  
        
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
        for(invoiceit_s__Job_Rate_Plan_Charge__c charge : OrderRPCForProject){
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
                    // for populating old open projects on New project creation 
                    if(chargeIdVsOldprojectId.containsKey(charge.Created_From_Charge__r.id)){
                        tempProject.Related_to_previous_project__c = chargeIdVsOldprojectId.get(charge.Created_From_Charge__r.id);
                    }
                    /*if(chargeIdVsOldProjOwnerId.containsKey(charge.Created_From_Charge__r.id)){//added by saiv for MHBS-3638 01/02/2020
                        tempProject.OwnerId = chargeIdVsOldProjOwnerId.get(charge.Created_From_Charge__r.id);
                    }
                    if(chargeIdVsOldProjSEOStrategstId.containsKey(charge.Created_From_Charge__r.id)){//added by saiv for MHBS-3638 01/02/2020
                        tempProject.SEO_Strategist__c = chargeIdVsOldProjSEOStrategstId.get(charge.Created_From_Charge__r.id);
                    }                   
                    system.debug('====tempProject.OwnerId===='+tempProject.OwnerId);
                    system.debug('====tempProject.SEO_Strategist__c===='+tempProject.SEO_Strategist__c);*/
                    
                    
                    tempProject.Project_External_ID__c    = charge.id + projectTOcreate.DeveloperName;
                    tempProject.Order_Rate_Plan_Charge__c = charge.id;
                    tempProject.Order__c                  = charge.invoiceit_s__Order__c;
                    tempProject.RecordTypeId              = projectTOcreate.RecordType__c;
                    tempProject.Account__c                = charge.Account_Id__c;
                    tempProject.Account_Owner_Email__c    = charge.Account_Owner_Email__c;
                    
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
                             if(!milestone.MasterLabel.contains('Review Page Plus')){
                                tempMilestone.OwnerId                    = tempProject.OwnerId;
                              }
                            else{
                               tempMilestone.OwnerId                    = milestone.Owner_ID__c;
                            }
                            tempMilestone.Project__r                 = projectReference;
                            tempMilestone.RecordTypeId               = milestone.RecordType__c;
                            tempMilestone.Predecessor_Seq_No__c      = milestone.Predecessor_sequence__c;
                            tempMilestone.SNo__c                     = milestone.SNo__c;

                           /* if(previousMilestone != ''){
                                tempMilestone.Predecessor_Milestone__r = milestonetReferencetemp;
                            }*/
                            
                            tempMilestone.mileStone_Extenal_ID__c      = charge.id + projectTOcreate.DeveloperName + milestone.DeveloperName;
                            //tempMilestone.Predecessor_External_ID__c   = tempMilestone.mileStone_Extenal_ID__c + milestone.Predecessor_sequence__c;
                            
                            
                            Milestone1_Milestone__c milestoneReferece = new Milestone1_Milestone__c(mileStone_Extenal_ID__c = charge.id + projectTOcreate.DeveloperName + milestone.DeveloperName);
                            allRecords.add(tempMilestone);
                            milestoneList.add(tempMilestone);
                            allRecordsMap.put('2',milestoneList);                            
                            
                            //previousMilestone = tempMilestone.mileStone_Extenal_ID__c+ milestone.Predecessor_sequence__c;
                            //milestonetReferencetemp = new Milestone1_Milestone__c(Predecessor_External_ID__c = previousMilestone);
                            
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
                                    
                                    //if(milestonetask.Start_Date__c != NULL){  
                                    //milestonetask.Due_Date__c                = BusinessHours.add(businessHoursId,startDateTime, mins*60000 );            
                                    //milestonetask.Due_Date__c                = System.today() + duration ;
                                    //}
                                    if(tempTask.IsProjectManagerAssignment__c && tempTask.Owner_ID__c != null && string.valueof(tempTask.Owner_ID__c).startswith('00G')){
                                        milestonetask.Assigned_Onwer__c  = tempProject.OwnerId;
                                        milestonetask.assign_To_Type__c    = 'User';
                                    }else{
                                        milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                        milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                    }
                                    
                                    /* if(Previoustask !=''){
                                        milestonetask.Predecessor_Task__r       = milestonetasktemp;
                                    }*/
                                    
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
        
        /*System.debug('============allRecordsMap.keySet()============'+allRecordsMap.keySet());
        System.debug('============allRecordsMap.values()============'+allRecordsMap.values());
        System.debug('============allRecordsMap.values()============'+allRecordsMap.values().size());
        System.debug('============allRecordsMap.values(1)============'+allRecordsMap.get('1').size());
        System.debug('============allRecordsMap.values(2)============'+allRecordsMap.get('2').size());
        System.debug('============allRecordsMap.values(3)============'+allRecordsMap.get('3').size());*/
        
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
                         
                        //System.debug('=====sNoMilestoneMap======'+sNoMilestoneMap);
                        
                        
                        /* if(orpcSnoMilestoneMap.containsKey(mil.Order_RPC_Id__c)){
                             orpcSnoMilestoneMap.get(mil.Order_RPC_Id__c).get(mil.SNo__c);
                         }
                         else{
                             orpcSnoMilestoneMap.put(mil.Order_RPC_Id__c, new map<Decimal, Milestone1_Milestone__c>());
                             orpcSnoMilestoneMap.get(mil.Order_RPC_Id__c).put(mil.SNo__c, mil);
                         }
                        System.debug('=====orpcSnoMilestoneMap======'+orpcSnoMilestoneMap);
                         */
                         
                        for(Milestone1_Task__c tas : mil.Project_Tasks__r){
                             string tkey = tas.Project_Milestone__r.Id ;
                             System.debug('===========tas=============='+tas);
                             //taskListForPredecessr.add(tas);
                             //System.debug('===========taskListForPredecessr============='+taskListForPredecessr);
                             //System.debug('===========taskKey=============='+taskkey);
                             
                            if(milstIdVsTasksAfter.containsKey(tkey)){
                                 milstIdVsTasksAfter.get(tkey).add(tas);
                             }
                             else{
                                 milstIdVsTasksAfter.put(tkey, new List<Milestone1_Task__c>{tas});
                             }
                             
                            /* if(sNoTaskMap.containsKey(tas.SNo__c)){
                                 sNoTaskMap.get(tas.SNo__c);
                             }
                             else{
                                 sNoTaskMap.put(tas.SNo__c, tas);
                             }*/
                            string taskkey = tas.Project_Milestone__r.Id + string.valueOf(tas.SNo__c);
                            snoVsTaskMap.put(taskkey, tas);
                             System.debug('=====sNoTaskMap======'+sNoTaskMap);
                             
                             
                           //  if(orpcSnoTaskMap.containskey)
                         
                         
                         
                         }  
                     }   
                 }
                 
               /* for(Sobject obj : updateAllRecords){
                    if(obj instanceof Milestone1_Milestone__c){
                        
                        Milestone1_Milestone__c milst = (Milestone1_Milestone__c)obj;
                        system.debug('@@@@@ in milestone instance'+ milst.mileStone_Extenal_ID__c);
                        system.debug('=============milst===================='+milst.id);
                        mileListForPredecessr.add(milst);
                        mileSetForPredec.add(milst.id);
                        System.debug('==========mileListForPredecessr==========='+mileListForPredecessr);
                        string key = milst.Project_ID__c;
                        system.debug('@@@@@key'+ key);
                        if(projIdVsMilestonesAfter.containsKey(key)){
                            projIdVsMilestonesAfter.get(key).add(milst);
                        }
                        else{
                            projIdVsMilestonesAfter.put(key, new List<Milestone1_Milestone__c>{milst});
                        }
                        System.debug('============projIdVsMilestonesAfter========'+projIdVsMilestonesAfter);
                    }
                    
                    else if(obj instanceof Milestone1_Task__c){
                        Milestone1_Task__c mitask = (Milestone1_Task__c)obj;
                        string taskkey = mitask.Project_Milestone__r.Id;
                        System.debug('===========mitask=============='+mitask);
                        taskListForPredecessr.add(mitask);
                        System.debug('===========taskListForPredecessr============='+taskListForPredecessr);
                        System.debug('===========taskKey=============='+taskkey);
                        if(milstIdVsTasksAfter.containsKey(taskkey)){
                            milstIdVsTasksAfter.get(taskkey).add(mitask);
                        }
                        else{
                            milstIdVsTasksAfter.put(taskkey, new List<Milestone1_Task__c>{mitask});
                        }
                        System.debug('============milstIdVsTasksAfter========'+milstIdVsTasksAfter);
                    }
                }*/
                 
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
                                 //System.debug('========m.Predecessor_Seq_No__c======'+m.Predecessor_Seq_No__c);
                                 //System.debug('========sNoMilestoneMap.get(m.Predecessor_Seq_No__c)======'+sNoMilestoneMap.get(m.Predecessor_Seq_No__c));
                                
                                /* if(m.Predecessor_Seq_No__c !=Null){
                                     if(orpcSnoMilestoneMap.containskey(m.Order_RPC_Id__c)){
                                        m.Predecessor_Milestone__c = orpcSnoMilestoneMap.get(m.Order_RPC_Id__c).get(m.Predecessor_Seq_No__c).id;                                    
                                        allRecordtoUpdate.add(m);
                                    }    
                                 }*/
                                 if(m.Predecessor_Seq_No__c !=Null){
                                        if(sonVsMilestoneMap.containskey(projId + string.valueOf(m.Predecessor_Seq_No__c))){
                                            m.Predecessor_Milestone__c = sonVsMilestoneMap.get(projId + string.valueOf(m.Predecessor_Seq_No__c)).id;                                    
                                            allRecordtoUpdate.add(m);
                                        } 
                                 }
                                 
                             }
                             
                             /*for(Integer i=1; i< milestonesList.size(); i++ ){
                                 Milestone1_Milestone__c ms     = milestonesList.get(i);
                                 ms.Predecessor_Milestone__c = milestonesList.get(i-1).id;
                                 allRecordtoUpdate.add(ms);
                             }*/
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
                               /*  if(t.Assigned_Onwer__c!=Null && t.assign_To_Type__c!=Null){
                                     if(userIdMap.containskey(t.Assigned_Onwer__c)){
                                         System.debug('====userIdMap.get(t.Assigned_Onwer__c).Name====='+userIdMap.get(t.Assigned_Onwer__c).Name);
                                         System.debug('===========t.name in user==============='+t.name);
                                         t.Assigned_Onwer__c = userIdMap.get(t.Assigned_Onwer__c).Name;
                                         System.debug('======t.Assigned_Owner__c======'+t.Assigned_Onwer__c);
                                         //allRecordtoUpdate.add(t);
                                     }
                                         else if(queueIdMap.containsKey(t.Assigned_Onwer__c)){
                                             System.debug('===========t.assign_To_Type__c==============='+t.assign_To_Type__c);
                                             System.debug('===========t.name==============='+t.name);
                                             System.debug('===========inside queue map t.Assigned_Onwer__c==============='+t.Assigned_Onwer__c);
                                             t.Assigned_Onwer__c = queueIdMap.get(t.Assigned_Onwer__c).Name;
                                             System.debug('=======t.Assigned_Owner__c'+t.Assigned_Onwer__c);
                                             
                                         }
                                    }*/
                                     if(t.Predecessor_Seq_No__c !=Null){
                                         system.debug('@@@@@@msId + string.valueOf(t.Predecessor_Seq_No__c)'+msId + string.valueOf(t.Predecessor_Seq_No__c));
                                        if(snoVsTaskMap.containskey(msId + string.valueOf(t.Predecessor_Seq_No__c))){
                                            t.Predecessor_Task__c = snoVsTaskMap.get(msId + string.valueOf(t.Predecessor_Seq_No__c)).id;                                    
                                            allRecordtoUpdate.add(t);
                                        } 
                                    }
                                // allRecordtoUpdate.add(t);
                                 
                             }
                             
                             
                            /* for(Integer i=1; i< taskList.size(); i++ ){
                                 Milestone1_Task__c tk     = taskList.get(i);
                                 tk.Predecessor_Task__c    = taskList.get(i-1).id;
                                 allRecordtoUpdate.add(tk);
                             }*/
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
        
        try{
            if (!upgradeProjectstoUpdate.isEmpty()){
                update upgradeProjectstoUpdate;
            }
            if (!upgradeMilestonestoUpdate.isEmpty()){
                update upgradeMilestonestoUpdate;
            }
            if(!upgradedtaskstoUpdate.isEmpty()){
                update upgradedtaskstoUpdate;
            }
            set<Id> projectIds = new set<Id>();
            set<Id> NotReqProjectIds = new set<Id>(); 
            
            for(Milestone1_Project__c proj: [select Id,Order_Rate_Plan_Charge__c from Milestone1_Project__c where Order_Rate_Plan_Charge__c in: updateMilestoneROF]){   
              projectIds.add(proj.Id);  
            }
            for(Milestone1_Project__c proj: [select Id,Order_Rate_Plan_Charge__c from Milestone1_Project__c where Order_Rate_Plan_Charge__c in: updateNotReqMilestoneROF]){   
              NotReqProjectIds.add(proj.Id);  
            }   
                
            list<Milestone1_Milestone__c> UpdateROFMil = new list<Milestone1_Milestone__c>();   
            list<Milestone1_Milestone__c> UpdateNotReqROFMil = new list<Milestone1_Milestone__c>();   
            for(Milestone1_Milestone__c mil: [select Id,project__c,status__c from Milestone1_Milestone__c where project__c in:projectIds and Name = 'K - Review Page Plus']){    
              mil.status__c = 'New';    
              UpdateROFMil.add(mil);    
            } 
            system.debug('--NotReqProjectIds--'+NotReqProjectIds);
            for(Milestone1_Milestone__c mil: [select Id,project__c,status__c from Milestone1_Milestone__c where project__c in:NotReqProjectIds and Name = 'K - Review Page Plus']){    
              mil.status__c = 'Not Needed';    
              UpdateNotReqROFMil.add(mil);    
            }   
                
                
             list<Milestone1_Task__c> UpdateROFMilesTasks = new list<Milestone1_Task__c>(); 
                
             for(Milestone1_Task__c tasks: [select Id,Task_Stage__c,Project_Milestone__c from Milestone1_Task__c where Project_Milestone__c in: UpdateROFMil]){ 
             tasks.Task_Stage__c = 'Not Started';   
             UpdateROFMilesTasks.add(tasks);    
             }
             for(Milestone1_Task__c tasks: [select Id,Task_Stage__c,Project_Milestone__c from Milestone1_Task__c where Project_Milestone__c in: UpdateNotReqROFMil]){ 
             tasks.Task_Stage__c = 'Not Required';   
             UpdateROFMilesTasks.add(tasks);    
             }
             update UpdateROFMil;  
             update UpdateROFMilesTasks;
        }
        catch(exception ex){
            system.debug('@@@Exception '+ ex);
        }
            
    }
    
    
    
    
    public static void projectlookups(Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> createdChargeIdVsCharge){
        
        system.debug('@@@@@@createdChargeIdVsCharge'+createdChargeIdVsCharge);
        List<Milestone1_Project__c> projects = new List<Milestone1_Project__c> ();
        if(!createdChargeIdVsCharge.keySet().isempty()){
            for(Milestone1_Project__c proj : [select id, Order_Rate_Plan_Charge__c, Order__c,Status__c
                                              From Milestone1_Project__c 
                                              where (Status__c != 'Cancelled' AND Status__c != 'Completed') AND Order_Rate_Plan_Charge__c IN:createdChargeIdVsCharge.keySet()]){
                                                  system.debug('@@@@proj'+proj);
                                                  system.debug('@@@@proj Status'+proj.Status__c );
                                                  System.debug('=========proj.Order_Rate_Plan_Charge__c========'+proj.Order_Rate_Plan_Charge__c);
                                                  System.debug('=========createdChargeIdVsCharge.get(proj.Order_Rate_Plan_Charge__c).invoiceit_s__Order__c========'+createdChargeIdVsCharge.get(proj.Order_Rate_Plan_Charge__c).invoiceit_s__Order__c);
                                                  System.debug('=========createdChargeIdVsCharge.get(proj.Order_Rate_Plan_Charge__c).Id======='+createdChargeIdVsCharge.get(proj.Order_Rate_Plan_Charge__c).Id);
                                                  
                                                  if(createdChargeIdVsCharge.get(proj.Order_Rate_Plan_Charge__c).Id!= Null && createdChargeIdVsCharge.get(proj.Order_Rate_Plan_Charge__c).invoiceit_s__Order__c!=Null){
                                                     invoiceit_s__Job_Rate_Plan_Charge__c charge = createdChargeIdVsCharge.get(proj.Order_Rate_Plan_Charge__c);
                                                      proj.Order_Rate_Plan_Charge__c =  charge.Id;
                                                     
                                                          proj.Order__c                  =  charge.invoiceit_s__Order__c; 
                                                      
                                                      
                                                      projects.add(proj);                                
                                                  }
                                                  System.debug('=========proj.Order__c======='+proj.Order__c);
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
}