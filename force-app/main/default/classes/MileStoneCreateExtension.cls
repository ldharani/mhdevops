/*****
Class Name: MileStoneCreateExtension 
* @testclass - MileStoneCreateExtensionTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-9369    Bharath       25/09/2023   Michael O’Grady T01     Need Permissions to Create At Risk milestone
************************************************************************************************************************/
public class MileStoneCreateExtension {
    //Milestone Page attributes
    public static List<string> users_email = new List<String>{'don.romanek@martindale.com','alexandria.costa@martindale.com','rosanne.clemente@martindale.com','peter.paslis@martindale.com','sean.mcgee@martindale.com','michael.ogrady@martindale.com','delson.dandoy@martindale.com','sean.maridbarsolaso@martindale.com','diana.ovalles@martindale.com'}; //<T01>
    public Milestone1_Milestone__c milestoneObj{get;set;}
    public String selectedMilestoneName{get;set;}
    public list<selectoption> mileStoneNamesList{get;set;}
    Map<id,MileStone__mdt> milestones= new Map<id,MileStone__mdt>();
    List<String> initialProjects {get;set;}
    List<String> secondProjects {get;set;}
    public Map<String,MileStone__mdt> MilestoneMap = new Map<String,MileStone__mdt>();
    public Map<String,MileStone__mdt> MilestoneIDNameMap {get;set;}
    public Set<Id> milestoneIds  = new set<Id>();
    public MileStoneCreateExtension(ApexPages.StandardController standardController) {
		Boolean flag = users_email.contains(userinfo.getUserEmail()); //<T01>
        System.debug('@@@@flag'+flag);
        MilestoneIDNameMap = new Map<String,MileStone__mdt>();
        milestoneObj= new Milestone1_Milestone__c();
        mileStoneNamesList = new list<selectoption>();
        milestones = new Map<id,MileStone__mdt>([select id, DeveloperName,MasterLabel,Owner_ID__c,RecordType__c,SNo__c ,IsCreatedByOwner__c,
                               Owner_Type__c, Predecessor_sequence__c,Project__c,project__r.Id
                               From MileStone__mdt]);
        for(MileStone__mdt mile:milestones.values()){
            if(mile.DeveloperName.contains('Content')){
            mileStoneNamesList.add(new SelectOption(mile.DeveloperName,mile.DeveloperName));
            MilestoneMap.put(mile.id,mile);
            MilestoneIDNameMap.put(mile.DeveloperName,mile);
            milestoneIds.add(mile.Id);                
            }
            if(mile.MasterLabel.equalsIgnoreCase('SEO_Audit/Account Review') || mile.MasterLabel.equalsIgnoreCase('SEO_Renewal')){
            mileStoneNamesList.add(new SelectOption(mile.MasterLabel,mile.MasterLabel));
            MilestoneMap.put(mile.id,mile);
            MilestoneIDNameMap.put(mile.MasterLabel,mile);
            milestoneIds.add(mile.Id);                
            }
            if(mile.DeveloperName == 'Miscellaneous'){    //.equalsIgnoreCase('SEO_Audit/Account Review') || mile.MasterLabel.equalsIgnoreCase('SEO_Renewal')){
            mileStoneNamesList.add(new SelectOption(mile.MasterLabel,mile.MasterLabel));
            MilestoneMap.put(mile.id,mile);
            MilestoneIDNameMap.put(mile.MasterLabel,mile);
            milestoneIds.add(mile.Id);                
            }  
            if(mile.DeveloperName == 'SEO_Audit_Account_Review_At_Risk' && flag){ //<T01>
            mileStoneNamesList.add(new SelectOption(mile.MasterLabel,mile.MasterLabel));
            MilestoneMap.put(mile.id,mile);
            MilestoneIDNameMap.put(mile.MasterLabel,mile);
            milestoneIds.add(mile.Id);
            }
        }
        milestoneObj = (Milestone1_Milestone__c )standardController.getRecord();
        system.debug('milestoneObj project here:::>'+milestoneObj );
        initialProjects = new List<String>();
        initialProjects.add('SEO_Gold');
        initialProjects.add('SEO_Platinum');
        initialProjects.add('SEO_Local_Boost');
        //initialProjects.add('SEO_Local_Boost_Top_Tier');
        //initialProjects.add('SEO_Local_Boost_Second_Tier');
        
        secondProjects = new List<String>();
        secondProjects.add('Content (General)');
        system.debug('===============secondproject==========:'+secondProjects);                  
    }
    public boolean ListFind(List<String> a, String b){
        Set<String> tempSet = new Set<String>();
        tempSet.addAll(a);
        return tempSet.contains(b);
    }
    public Pagereference saveMilestone(){
        String insertedMilestoneId;
        milestoneObj.Name = selectedMilestoneName;
        system.debug('milestoneObj :::>'+milestoneObj);        
        //String projectName = [select id,Name from Milestone1_Project__c where id =: milestoneObj.Project__c].Name;
        String projectId = [select OwnerId, Name from Milestone1_Project__c where id =: milestoneObj.Project__c].OwnerId;
        String projectStatus = [select OwnerId, Name,Status__c from Milestone1_Project__c where id =: milestoneObj.Project__c].Status__c;
        //system.debug('milestoneObj projectName :::>'+projectName);
        system.debug('milestone project ownerid::::'+projectId);
        boolean containsFlag = false;
        
        //commented on 8/3/17 for SFMS-204
        /*if(milestoneObj.Name.equalsIgnoreCase('SEO_Audit/Account Review') || milestoneObj.Name.equalsIgnoreCase('SEO_Renewal')){
            containsFlag = ListFind(initialProjects,projectName);
            if(containsFlag == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Selected Milestone cannot be created with this Project'));
                return null;
            }
        }
        else if(milestoneObj.Name.equalsIgnoreCase('Content_SEO_Onsite_Blog_w_Order') || milestoneObj.Name.equalsIgnoreCase('Content_no_SEO_PostLaunch_w_Order')
          || milestoneObj.Name.equalsIgnoreCase('Content_no_SEO_PreLaunch_w_Order') || milestoneObj.Name.equalsIgnoreCase('Content_w_SEO_PostLaunch_w_Order')
          || milestoneObj.Name.equalsIgnoreCase('Content_w_SEO_PreLaunch_w_Order')){
             containsFlag = ListFind(secondProjects,projectName);
            if(containsFlag == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Selected Milestone cannot be created with this Project'));
                return null;
            } 
        }*/
        
        //Declaration Section        
        List<MileStone__mdt> milestones                         = new List<MileStone__mdt>();
        Map<Id,List<Task__mdt>>      milestoneIdVsTasks         = new Map<Id,List<Task__mdt>>();    
        List<Sobject> allRecords                                = new List<SObject>();
        Map<String, List<Sobject>> allRecordsMap                = new Map<String, List<SObject>>();
        List<Sobject> updateAllRecords                          = new List<SObject>();    
        List<Sobject> milestoneList                             = new List<Sobject>();
        List<Sobject> tasksList                                 = new List<Sobject>();        
        milestones = [select id, DeveloperName,MasterLabel,Owner_ID__c,RecordType__c,SNo__c ,IsCreatedByOwner__c,
                               Owner_Type__c, Predecessor_sequence__c,Project__c,project__r.Id,
                             (select id, DeveloperName,MasterLabel,IsProjectManagerAssignment__c,Pln_Hrs__c,IsCreatedByOwner__c,
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
        
        //List<Group> prjmngr = [select id, name from Group where DeveloperName = 'MS_Project_Manager' AND Type = 'Queue'];  
        System.debug('=================milestoneIdVsTasks==============='+milestoneIdVsTasks);
        //Creation of Milestone, tasks goes here
                
        MileStone__mdt milestone = MilestoneIDNameMap.get(milestoneObj.Name); 
        System.debug('==========Inside for Milestones==============='+milestone);
        MileStone__mdt milestoneToCreate         = milestone;
        Milestone1_Milestone__c tempMilestone    = new Milestone1_Milestone__c();
        tempMilestone.Name                       = milestoneObj.Name;
        //tempMilestone.OwnerId                    = Milestone1_Milestone__c.Owner;
        tempMilestone.Project__c                 = milestoneObj.Project__c;
        tempMilestone.RecordTypeId               = milestone.RecordType__c;
        tempMilestone.Predecessor_Seq_No__c      = milestone.Predecessor_sequence__c;
        tempMilestone.SNo__c                     = milestone.SNo__c;                
        tempMilestone.mileStone_Extenal_ID__c    = userinfo.getuserid()+system.now()+ milestone.DeveloperName;
        
        if(projectStatus!='New' && projectStatus!='Cancelled' && projectStatus!='Completed'){
            tempMilestone.Status__c                  = 'Ready to Start';
        }
        if(milestone.Owner_ID__c != NULL && milestone.Owner_ID__c !=''){
            tempMilestone.OwnerId = milestone.Owner_ID__c;
        }else if(milestone.IsCreatedByOwner__c){
            tempMilestone.OwnerId = userinfo.getUserId();
        }else{
            tempMilestone.OwnerId = projectId;
        }
        
        
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
                milestonetask.Issystem__c          = True;
                milestonetask.RecordTypeId         = tempTask.RecordType__c;
                milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                //milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                milestonetask.Predecessor_Seq_No__c      = tempTask.Predecessor_sequence__c;
                milestonetask.SNo__c                     = tempTask.SNo__c;
                milestonetask.Pln_Hrs__c                 = tempTask.Pln_Hrs__c;
                //milestonetask.Assigned_Onwer__c = tempMilestone.OwnerId;
                if(tempTask.Owner_ID__c != null){
                milestonetask.Assigned_Onwer__c = tempTask.Owner_ID__c;
                }else if(tempTask.IsCreatedByOwner__c){
                milestonetask.Assigned_Onwer__c = Userinfo.getuserid();
                milestonetask.assign_To_Type__c = 'User';
                }
                else{
                milestonetask.Assigned_Onwer__c = projectId ;
                milestonetask.assign_To_Type__c = 'User';
                }
                if(milestonetask.Predecessor_Seq_No__c == Null){  
                    if(projectStatus!= Null && projectStatus!='New' && projectStatus!='Cancelled' && projectStatus!='Completed')
                    milestonetask.Task_Stage__c = 'Ready to Start';
                }
                
                //commented on 8/3/17 for SFMS-204
                /*if(tempTask.IsProjectManagerAssignment__c && tempTask.Owner_ID__c != null && string.valueof(tempTask.Owner_ID__c).startswith('00G')){
                    milestonetask.Assigned_Onwer__c  = tempTask.Owner_ID__c;
                    milestonetask.assign_To_Type__c    = 'Queue';
                }else{
                    milestonetask.Assigned_Onwer__c    = tempTask.Owner_ID__c;
                    milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;
                }*/
                
                milestonetask.Project_Milestone__r      = milestoneReferece;                                    
                allRecords.add(milestonetask);
                tasksList.add(milestonetask);
                allRecordsMap.put('3',tasksList);
            }
        }
        Map<string,List<Milestone1_Milestone__c>> projIdVsMilestonesAfter = new Map<string,List<Milestone1_Milestone__c>>();
        Map<string,List<Milestone1_Task__c>>      milstIdVsTasksAfter     = new Map<string,List<Milestone1_Task__c>>();
        List<Sobject> allRecordtoUpdate                               = new List<Sobject>();
        
        System.debug('==============Allrecords========'+allRecords);
        allRecords.sort();
        System.debug('==============Allrecords sorted========'+allRecords);
        
        for(String s : allRecordsMap.keySet()){        
            if(allRecordsMap.containsKey('2')){
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
        
        if(insertedMilestoneId != null)
        return new PageReference('/'+insertedMilestoneId);
        else
        return new PageReference('/'+milestoneObj.Project__c);    
    }
    /*public Pagereference saveMilestone(){
        milestoneObj.Name = selectedMilestoneName;
        system.debug('milestoneObj :::>'+milestoneObj);        
        String projectName = [select id,Name from Milestone1_Project__c where id =: milestoneObj.Project__c].Name;
        system.debug('milestoneObj projectName :::>'+projectName);
        boolean containsFlag = false;
        if(milestoneObj.Name.equalsIgnoreCase('SEO_Audit/Account Review') || milestoneObj.Name.equalsIgnoreCase('SEO_Renewal')){
            containsFlag = ListFind(initialProjects,projectName);
            if(containsFlag == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Selected Milestone cannot be created with this Project'));
                return null;
            }
        }
        else if(milestoneObj.Name.equalsIgnoreCase('Content_SEO_Onsite_Blog_w_Order') || milestoneObj.Name.equalsIgnoreCase('Content_no_SEO_PostLaunch_w_Order')
          || milestoneObj.Name.equalsIgnoreCase('Content_no_SEO_PreLaunch_w_Order') || milestoneObj.Name.equalsIgnoreCase('Content_w_SEO_PostLaunch_w_Order')
          || milestoneObj.Name.equalsIgnoreCase('Content_w_SEO_PreLaunch_w_Order')){
             containsFlag = ListFind(secondProjects,projectName);
            if(containsFlag == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Selected Milestone cannot be created with this Project'));
                return null;
            } 
        }
        List<Task__mdt> taskMDTList = new List<Task__mdt>();
        taskMDTList = [select id, DeveloperName,MasterLabel,IsProjectManagerAssignment__c,Pln_Hrs__c,
                                 EstimatedHours__c, MileStone__c, Owner_ID__c,Milestone__r.Id,
                                 Owner_Type__c, Predecessor_sequence__c,SNo__c,
                                 Priority__c, Status__c,Layover_Days__c,RecordType__c,TaskName__c   
                                 from Task__mdt where MileStone__c IN: MilestoneMap.keyset()];
        Map<Id,List<Task__mdt>> taskMap = new Map<Id,List<Task__mdt>>();
        for(Task__mdt t:taskMDTList){
            List<Task__mdt > tempList = new List<Task__mdt >();
            if(taskMap.containsKey(t.MileStone__c)){            
                tempList = taskMap.get(t.MileStone__c);
                tempList.add(t);
                taskMap.put(t.MileStone__c,tempList);
            }else{
                tempList.add(t);
                taskMap.put(t.MileStone__c,tempList);
            }
        }
        List<Milestone1_Task__c> milestonetaskList   = new List<Milestone1_Task__c>();                         
        String customMileStoneId = MilestoneIDNameMap.get(milestoneObj.Name);
        system.debug('customMileStoneId here::'+customMileStoneId);
        List<Milestone1_Milestone__c> miles = new List<Milestone1_Milestone__c>{milestoneObj};
        Database.SaveResult[] mlList= Database.insert(miles, false);
        String insertedMilestoneId;
        for (Database.SaveResult ml : mlList) {
            insertedMilestoneId = ml.getId();
            for(Task__mdt tempTask:taskMap.get(customMileStoneId)){
                Milestone1_Task__c milestonetask   = new Milestone1_Task__c();
                milestonetask.Name                 = tempTask.TaskName__c;
                milestonetask.Estimated_Hours__c   = tempTask.EstimatedHours__c;
                milestonetask.Priority__c          = tempTask.Priority__c;          
                milestonetask.Project_Milestone__c = ml.getId();
                milestonetask.Layover_Days__c      = tempTask.Layover_Days__c;
                milestonetask.RecordTypeId         = tempTask.RecordType__c;
                milestonetask.assign_To_Type__c    = tempTask.Owner_Type__c;            
                milestonetask.Predecessor_Seq_No__c = tempTask.Predecessor_sequence__c;
                milestonetask.SNo__c               = tempTask.SNo__c;
                milestonetask.Pln_Hrs__c           = tempTask.Pln_Hrs__c;
                //milestonetask.TaskName__c          = tempTask.TaskName__c;
                //milestonetask.Predecessor_Task__c = 
                milestonetask.Assigned_To__c       = tempTask.Owner_ID__c;
               
                
                milestonetaskList.add(milestonetask);
            }
            
        } 
        if(milestonetaskList.size() > 0)
        insert milestonetaskList;       
        if(insertedMilestoneId != null)
        return new PageReference('/'+insertedMilestoneId);
        else
        return new PageReference('/'+milestoneObj.Project__c);  
    }*/
}