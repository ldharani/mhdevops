public class CaseProjectCreation {
  
    /**********************************************************************
* Author           : Sai C MHBS-2611
* Description      : To Create Project based on Case Area and Sub-Area
* Date             : 06/15/2018
* ********************************************************************/   
    public static boolean caseRecursionAfterUpdate = true;
    public static boolean caseRecursionBeforeUpdate = true;
    public static List<case>ProjectTOCreateCases = new List<Case>();
    public static List<case> caseToMilestone = new List<case>(); 
    
    //checking in before update for relevant case
    //because in After update due to other trigger, we are getting same old and new values
    public static void getProjectToCreateCases(List<case> caseList , Map<Id,Case> oldMap){
        for(Case cs : caseList){
            system.debug('@@@@cs.Status'+cs.Status);
            system.debug('@@@@oldMap.get(cs.id).Status'+oldMap.get(cs.id).Status);
            //checking for valid cases to create Projects here
             if(cs.Status =='Closed' && 
                  oldMap.get(cs.id).Status != cs.Status &&
                  cs.Sub_Area__c !=Null &&
                  cs.Area__c != Null &&
                  (cs.Sub_Area__c == 'Annual Custom Content' || cs.Sub_Area__c == 'Avvo Bronze' || cs.Sub_Area__c == 'Avvo Silver')&& 
                cs.Area__c == 'Create Project'){
                    
               ProjectTOCreateCases.add(cs); 
           }else if(oldMap.get(cs.id).Is_SEO_Related__c != cs.Is_SEO_Related__c && cs.Area__c != Null && cs.Is_SEO_Related__c!=NULL && cs.Is_SEO_Related__c=='In SEO Review'){
               caseToMilestone.add(cs);
            }           
        }
        
       system.debug('@@@@@getProjectToCreateCases'+ProjectTOCreateCases);
    
    }
    
     /**********************************************************************************************************
* Author           : Ronak Jain MHBS-2749
* Description      : To Create Milestone based on whether the Account is at risk or not - In SEO Review 
* Date             : 08/06/2018
* ***********************************************************************************************************/   
     
     public static void milestoneCreationFromCase(){
        
        
         system.debug('@@@ in milestoneCreationFromCase'+ trigger.newMap); 
         
        //Declaration Section
        Map<Id,String> caseIdVSSubAreaMap            = new Map<Id,String>();
        Set<Id> accountIds                           = new Set<Id>();
        List<Milestone1_Project__c> projList         = new List<Milestone1_Project__c>();
        set<id> insertMilestoneId                    = new set<id>();
        List<MileStone__mdt> milestones              = new List<MileStone__mdt>();
        
         Map<String, Product_code_to_Project_Mapping__c> MilestonesMap = new Map<String, Product_code_to_Project_Mapping__c>();
        
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
        String insertedMilestoneId;
        Set<String> seoProj = new Set<String>();
        Map<Id, List<Milestone1_Project__c>> activeProjAcctMap  = new Map<Id, List<Milestone1_Project__c>>();
        Map<Id, List<Milestone1_Project__c>> complProjAcctMap   = new Map<Id, List<Milestone1_Project__c>>();
        List<Milestone1_Project__c> finalProjList         = new List<Milestone1_Project__c>();

        MilestonesMap = Product_code_to_Project_Mapping__c.getAll();
        System.debug('@@@@@MilestonesMap'+MilestonesMap );
                
        System.debug('@@@@@@@caseToMilestone'+caseToMilestone);
        if(!caseToMilestone.isempty() || caseToMilestone!=NULL){
            for(Case cs : caseToMilestone){
                caseIdVSSubAreaMap.put(cs.Id, cs.Sub_Area__c); 
                System.debug('@@@@@@@@@ Case having account or not==='+cs.Account_Id__c);
                if(cs.Account_Id__c!=NULL){
                    accountIds.add(cs.Account_Id__c);
                } 
                
                if(MilestonesMap.containskey(cs.Sub_Area__c) && !MilestonesMap.isempty()){
                     if(MilestonesMap.get(cs.Sub_Area__c).Milestone_Id__c !='' || MilestonesMap.get(cs.Sub_Area__c).Milestone_Id__c !=NULL ){
                         insertMilestoneId.add(MilestonesMap.get(cs.Sub_Area__c).Milestone_Id__c);
                     }
                }     
            }
            System.debug('============insertMilestoneId==111====='+insertMilestoneId);//
            
            List<Product_code_to_Project_Mapping__c> seoProjList = Product_code_to_Project_Mapping__c.getAll().values();
            System.debug('@@@@seoProjList'+seoProjList);
            
            for(Product_code_to_Project_Mapping__c prj: seoProjList){
                if(prj.IsSEO__c == TRUE){
                    seoProj.add(prj.Label__c);
                }
            }
            System.debug('@@@@seoProj'+seoProj);
            
            System.debug('@@@@@@@caseIdVSSubAreaMap'+caseIdVSSubAreaMap);
            System.debug('@@@@@@@@@@@accountIds'+accountIds);
            if(!accountIds.isempty() && accountIds!=NULL){
                projList = [Select Id, name,SEO_Strategist__c,OwnerId,Status__c,Account__c From Milestone1_Project__c Where Account__c in: accountIds AND Name in: seoProj /*LIKE '%SEO%'*/ AND (Status__c='Optimization' OR Status__c='In Progress' OR Status__c='Completed') ];    
            }
            
            System.debug('@@@@@@@projList=================== '+projList );
            
            for(Milestone1_Project__c prj: projList){
                if(prj.Status__c == 'In Progress' || prj.Status__c == 'Optimization'){
                    if(activeProjAcctMap.containskey(prj.Account__c)){
                        activeProjAcctMap.get(prj.Account__c).add(prj);
                    }else{
                        activeProjAcctMap.put(prj.Account__c, new List<Milestone1_Project__c>{prj});
                    }
                }                
            }
            System.debug('All the active SEO projects where At Risk milestone needs to be inserted------->'+activeProjAcctMap.values());
            
            for(Milestone1_Project__c prj: projList){
                if(prj.Status__c == 'Completed'){
                    if(activeProjAcctMap.containskey(prj.Account__c)){
                        System.debug('There are active projects on this account----->');
                    }else{
                        if(complProjAcctMap.containskey(prj.Account__c)){
                            System.debug('Ignoring the second completed project here------>');
                        }else{
                            complProjAcctMap.put(prj.Account__c, new List<Milestone1_Project__c>{prj});
                            System.debug('Adding the completed project to the Map for milestone insertion------>'+complProjAcctMap.values());
                        }
                    }                   
                }
            }
            System.debug('All the completed projects to be inserted with At Risk Milestones list----->'+complProjAcctMap.values());
            
            if(!activeProjAcctMap.values().isempty()){
                for(List<Milestone1_Project__c> prj: activeProjAcctMap.values()){
                    finalProjList.addAll(prj);
                }    
            }
            
            if(!complProjAcctMap.values().isempty()){
                for(List<Milestone1_Project__c> prj: complProjAcctMap.values()){
                    finalProjList.addAll(prj);
                }    
            }
            System.debug('@@@@@@@Final Project List---------------->'+finalProjList);
            
            If(!caseIdVSSubAreaMap.isEmpty() && !finalProjList.isempty()){
                
                 System.debug('============insertMilestoneId======='+insertMilestoneId);//
                    
                    if(insertMilestoneId.size()>0){
                        milestones = [select id, DeveloperName,MasterLabel,Owner_ID__c,RecordType__c,SNo__c ,
                                      Owner_Type__c, Predecessor_sequence__c,Project__c,project__r.Id,Label,
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
                    }
                    
                    /*for(Project__mdt project : [select id, DeveloperName,MasterLabel,RecordType__c,IsQueueUserAssignment__c,
                                                             Owner_ID__c,Owner_Type__c, ProjectType__c, Status__c,
                                                    From Project__mdt where MasterLabel In : caseIdVSSubAreaMap.values()]){
                                                    
                    }*/
                    
                    for(Milestone1_Project__c proj: finalProjList){
                    
                        String projectId = String.valueOf(proj.Id).substring(0, 15);
                        
                         if(!milestones.isEmpty()){
                            for(MileStone__mdt milestone : milestones){
                                
                                MileStone__mdt milestoneToCreate                     = milestone;
                                Milestone1_Milestone__c tempMilestone    = new Milestone1_Milestone__c();
                                tempMilestone.Name                       = milestone.MasterLabel;
                                tempMilestone.Project__c                 = projectId;
                                tempMilestone.Status__c                  = 'Ready to Start';
                                //tempMilestone.Isnew__c                   = True;
                                tempMilestone.RecordTypeId               = milestone.RecordType__c;
                                tempMilestone.Predecessor_Seq_No__c      = milestone.Predecessor_sequence__c;
                                tempMilestone.SNo__c                     = milestone.SNo__c;
                                tempMilestone.Created_From_Case__c       = TRUE;       
                                
                                if(proj.SEO_Strategist__c != NULL){
                                    tempMilestone.OwnerId                   = proj.SEO_Strategist__c;
                                }else{
                                   tempMilestone.OwnerId                    = proj.OwnerId;
                                }
                                
                                allRecords.add(tempMilestone);
                                
                                Integer rand = Math.round(Math.random()*1000);

                                tempMilestone.mileStone_Extenal_ID__c      = proj.id + milestone.DeveloperName + milestone.id + rand  ;
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
                                        milestonetask.Project_Milestone__r      = milestoneReferece;
                                        milestonetask.Issystem__c = True;
                                        milestonetask.Task_Identifier__c   = tempTask.id + tempMilestone.mileStone_Extenal_ID__c;
                                        milestonetask.Layover_Days__c      = tempTask.Layover_Days__c;
                                        milestonetask.RecordTypeId         = tempTask.RecordType__c;
                                        milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                        //milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                        milestonetask.Predecessor_Seq_No__c      = tempTask.Predecessor_sequence__c;
                                        milestonetask.SNo__c                     = tempTask.SNo__c;
                                        milestonetask.Pln_Hrs__c                 = tempTask.Pln_Hrs__c;
                                        
                                        milestonetask.assign_To_Type__c          = 'User';
                                        
                                        if(proj.SEO_Strategist__c != NULL){
                                            milestonetask.Assigned_Onwer__c          = proj.SEO_Strategist__c;
                                        }else{
                                            milestonetask.Assigned_Onwer__c          = proj.OwnerId;
                                        }
                                        
                                        /*if(tempTask.IsProjectManagerAssignment__c && tempTask.Owner_ID__c != null && string.valueof(tempTask.Owner_ID__c).startswith('00G')){
                                                milestonetask.Assigned_Onwer__c  = tempMilestone.OwnerId;
                                                milestonetask.assign_To_Type__c    = 'User';
                                        }else{
                                                milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                                                milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                                        }*/
                                        
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
        System.debug('============allRecords============'+allRecords);
       
            try{
            if(!allRecords.isEmpty()){
                    insert allRecords;
                    system.debug('@@@@allRecords'+allRecords);
                    
                List<Milestone1_Milestone__c> mileListPred = [Select id, name, Project__r.Id,SNo__c,Predecessor_Seq_No__c,Order_RPC_Id__c,(Select id, name,Project_Milestone__r.Id,Predecessor_Seq_No__c,Assigned_Onwer__c,assign_To_Type__c,SNo__c From Project_Tasks__r) From Milestone1_Milestone__c WHERE id in : allRecords]; //Assign Owner to Tasks 
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
                     
                     if(!mileListPred.isEmpty()){
                         for(Milestone1_Milestone__c mil : mileListPred){
                             
                             insertedMilestoneId  = mil.Id;
                             system.debug('=============mil===================='+mil.id);
                                                     
                             if(sNoMilestoneMap.containsKey(mil.SNo__c)){
                                 sNoMilestoneMap.get(mil.SNo__c);
                             }
                             else{
                                 sNoMilestoneMap.put(mil.SNo__c, mil);
                             }
                            System.debug('=====sNoMilestoneMap======'+sNoMilestoneMap);
                             
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
    
     
    public static void projectCreationFromCase(){
        
        
         system.debug('@@@ in ProjectCreationfromCase'+ trigger.newMap); 
        //Declaration Section
        Map<Id,String> caseIdVSSubAreaMap            = new Map<Id,String>();
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
          
        for(Case cs : ProjectTOCreateCases){
           
           
                    
               caseIdVSSubAreaMap.put(cs.Id, cs.Sub_Area__c); 
                  
        }
        
        system.debug('@@@@caseIdVSSubAreaMap'+caseIdVSSubAreaMap);
        
        //getting all projects and Milestones here
        If(!caseIdVSSubAreaMap.isEmpty()){
            for(Project__mdt project : [select id, DeveloperName,MasterLabel,RecordType__c,IsQueueUserAssignment__c,
                                                 Owner_ID__c,Owner_Type__c, ProjectType__c, Status__c,
                                                 (select id, DeveloperName,MasterLabel,Owner_ID__c,
                                                  Owner_Type__c, Predecessor_sequence__c,Project__c,RecordType__c,SNo__c
                                                  From MileStones__r
                                                 )
                                        From Project__mdt where MasterLabel In : caseIdVSSubAreaMap.values()]){
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
        If(!caseIdVSSubAreaMap.isEmpty()){
            system.debug('@@@ in SubAreaVsProject');
            for(case scase : ProjectTOCreateCases){
                if(caseIdVSSubAreaMap.containsKey(scase.id)){
                       
                    if(!subAreaVsProjectMap.isEmpty() && subAreaVsProjectMap.containsKey(scase.Sub_Area__c)){

                        Project__mdt projectTOcreate = subAreaVsProjectMap.get(scase.Sub_Area__c);
                        Milestone1_Project__c tempProject     = new Milestone1_Project__c();
                        tempProject.Name                      = projectTOcreate.MasterLabel;
                        tempProject.Status__c                 = projectTOcreate.Status__c;
                        tempProject.ProjectType__c            = projectTOcreate.ProjectType__c;
                        tempProject.OwnerId                   = projectTOcreate.Owner_ID__c;
                        tempProject.Created_from_Case__c      = True;              
                        tempProject.Project_External_ID__c    = userinfo.getuserid()+system.now()+projectTOcreate.DeveloperName;//charge.id + projectTOcreate.DeveloperName;
                        tempProject.RecordTypeId              = projectTOcreate.RecordType__c;
                        tempProject.Account__c                = scase.AccountId;
                        tempProject.Description__c            = scase.Description;
                        
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

}