/*******************************************************************************************************
* Author      : SaiV 
* Description : whenever a charge is created, we need to create Project --> Milestone(child of project) --> tasks(child of each milestone)
* Date        : 11/28/2021
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHMAC-44     CK            25/11/2022   Jeevan Babu     <T01>   Cancel Case Creation for MAC2.1 : Handling single case creation for both Full and Partial cancellation. So removing full cancellation(CancelcaseCreation) logic from here.
************************************************************************************************************************
********************************************************************************************************/

public class CPQ_MilestoneHandler_AvvoOptys {
    public Milestone1_Project__c projObj{get;set;}
    public String selectedProjName{get;set;}
    public list<selectoption> projNamesList{get;set;}
    Map<id,Project__mdt> projects = new Map<id,Project__mdt>();
    Set<Id> projectIds{get;set;}
    Map<String,Project__mdt> projectMap = new Map<String,Project__mdt>();
    String insertedProjId{get;set;}    
    Public Static boolean SubCheck = False;
    //project creation upon subscription creation
    //@future
    public static void CPQ_createProjectsForAvvoOptys(List<Opportunity> optyIds, Map<Id,Opportunity> oldMap){
    //public static void CPQ_createProjectsForAvvoOptys(String optyIdsStrng, String oldMapStrng){
        
        //Map<id, Opportunity> oldMap = (Map<id, Opportunity>) JSON.deserialize(oldMapStrng, Map<id, Opportunity>.class);
        //List<Opportunity> optyIds = (List<Opportunity>) JSON.deserialize(optyIdsStrng, List<Opportunity>.class);
        system.debug('===1optyIds==='+optyIds);
        system.debug('===1optyIdsoldMap==='+oldMap);
        List<Opportunity> orderCharges = new List<Opportunity>();
        Id MAOptyRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
        //Id MAMscOptyGeoRecTypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-A Misc Fee Opportunity').getRecordTypeId();
        List<Opportunity> orderChargestemp 
            = [select id,Name,AccountId,Avvo_Website_Redesign_Request__c, Avvo_Website_Redesign_Request_Date__c, RecordTypeId,
                AvvoProductCodeForProject__c, Account.ParentId from Opportunity where Id IN:optyIds and RecordTypeId=:MAOptyRecTypeId];
        //Handling Upgrade Scneario - Upgrade needs to be placed here - skipping for now
        system.debug('@@@orderChargestemp'+orderChargestemp);
        
        for(Opportunity ordcharge : orderChargestemp){
            system.debug('==1oldMap.get=='+oldMap.get(ordcharge.id).Avvo_Website_Redesign_Request__c);
            system.debug('==1oldMap.getnew=='+ordcharge.Avvo_Website_Redesign_Request__c);
            system.debug('==1oldMap.get=='+oldMap.get(ordcharge.id).Avvo_Website_Redesign_Request_Date__c);
            system.debug('==1oldMap.getnew=='+ordcharge.Avvo_Website_Redesign_Request_Date__c);
            system.debug('==1oldMap.get=='+oldMap.get(ordcharge.id).AvvoProductCodeForProject__c);
            system.debug('==1oldMap.getnew=='+ordcharge.AvvoProductCodeForProject__c);
            if(oldMap.get(ordcharge.id).Avvo_Website_Redesign_Request__c != ordcharge.Avvo_Website_Redesign_Request__c
                && ordcharge.Avvo_Website_Redesign_Request__c == TRUE){
                orderCharges.add(ordcharge);
            }
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
        
        Map<Id,Opportunity> projectlookupCharges = new Map<Id,Opportunity>();
        Set<Id> cancelledSubId = new Set<Id>(); //added for project cancellation
        
        //Intializing set of product codes 
        Map<String, Product_code_to_Project_Mapping__c> projectsMap = Product_code_to_Project_Mapping__c.getAll();
        
        //WEB and SEO validations for upgrade and downgrade scenarios code placed here - skipping for now
        //below line 706 from MilestoneHandler Class
        List<Opportunity> OrderRPCForProject = new List<Opportunity>();
        for(Opportunity charge : orderCharges){
            OrderRPCForProject.add(charge);
        }
        System.debug('==OrderRPCForProject=='+OrderRPCForProject);
        Set<String> prjectIdstoquery   = new Set<String>();
        for(Opportunity charge : OrderRPCForProject){
            //only for new sub creations
            system.debug('===avvoprodcode==='+charge.AvvoProductCodeForProject__c);
            //if(charge.Cancelled__c == FALSE && charge.Status__c != 'Truncated' && charge.Status__c != 'Off set'){
            if(charge.AvvoProductCodeForProject__c != null && projectsMap.containsKey(charge.AvvoProductCodeForProject__c)){
                chargeIdVsProjectId.put(charge.id, Product_code_to_Project_Mapping__c.getValues(charge.AvvoProductCodeForProject__c).Project_Record_ID__c );
                prjectIdstoquery.add(Product_code_to_Project_Mapping__c.getValues(charge.AvvoProductCodeForProject__c).Project_Record_ID__c);
            }
                    
            //}
            
        }
        system.debug('@@@@@@@prjectIdstoquery'+prjectIdstoquery);
        system.debug('@@@@projectlookupCharges'+projectlookupCharges);
        //sending to rebase/renew project update method
        /*
        if(!projectlookupCharges.isEmpty()){
            projectlookups(projectlookupCharges);
        }
        //sending to cancel method
        if(!cancelledSubId.isEmpty()){
            handleCancelSub(cancelledSubId);
        }
        */
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
        for(Opportunity charge : OrderRPCForProject){
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
                    system.debug('test08firmacc'+charge.Account.ParentId);
                    tempProject.Project_External_ID__c    = charge.id + projectTOcreate.DeveloperName;
                    tempProject.Opportunity__c            = charge.id;
                    tempProject.RecordTypeId              = projectTOcreate.RecordType__c;
                    tempProject.Account__c                = charge.AccountId;
                    tempProject.CreatedfromAvvoOpty__c    = TRUE;
                    tempProject.FirmAccount__c            = charge.Account.ParentId; //MHBS-7799
                    
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
        
        MDL_RecursionHandler.handleAvvoProjectCreation = False;
    }
    public static void caseCreationOnInsert(List<Opportunity> optyIds, Map<Id,Opportunity> oldMap){
      /*  System.debug('AAAXZ ');
        List<Case> casesToInsert = new List<Case>();
        List<Group> fulfillmentOpsId = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'Fulfillment_Operations'];
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case Record').getRecordTypeId();
        for(Opportunity opp : optyIds){
            if(opp.Firm_Name__c != Null){
                System.debug('CCCXZ ' + opp.num_of_Active_Advanced_360_Subscriptions__c + ' ' + oldMap.get(opp.Id).num_of_Active_Advanced_360_Subscriptions__c);
                System.debug('EEEXZ ' + opp.num_of_Active_Base_Profile_Subscriptions__c + ' ' + oldMap.get(opp.Id).num_of_Active_Base_Profile_Subscriptions__c);
                
                if((opp.numofActiveMartindaleBaseProfileSub__c == 0 && opp.num_of_Active_Advanced_360_Subscriptions__c == 1 && oldMap.get(opp.Id).num_of_Active_Advanced_360_Subscriptions__c == 0) || test.isRunningTest()) {
                       System.debug('DDDXZ ');
                       Case crec = new Case(Status = 'Open',
                                            Subject = 'Martindale-Avvo Complete Profile Plus Order',
                                            Description = 'This is a New Avvo Customer with Martindale-Avvo Complete Profile Plus Order',
                                            Area__c = 'Martindale-Avvo Complete Profile Plus New',
                                            Origin = 'AdvancedProds',
                                            Priority = 'High',
                                            AccountId = opp.AccountId,                                
                                            //Subscription__c = sub.Id,
                                            Parent_Opportunity__c = opp.Id
                                           );
                       if(fulfillmentOpsId.size()>0){
                           crec.OwnerId = fulfillmentOpsId[0].Id;
                       }
                    if(caseRecordTypeId !=null) {
                        crec.RecordTypeId = caseRecordTypeId ;
                    }
                       casesToInsert.add(crec);
                   }else if(opp.num_of_Active_Advanced_360_Subscriptions__c == 0 &&
                            opp.numofActiveMartindaleBaseProfileSub__c == 1 && oldMap.get(opp.Id).numofActiveMartindaleBaseProfileSub__c == 0){
                                System.debug('FFFXZ ');
                                Case crec = new Case(Status = 'Open',
                                                     Subject = 'Martindale Base Profile Order',
                                                     Description = 'This is a New Avvo Customer with Martindale Base Profile Order',
                                                     Area__c = 'Martindale Base Profile New',
                                                     Origin = 'AdvancedProds',
                                                     Priority = 'High',
                                                     AccountId = opp.AccountId,                                
                                                     //Subscription__c = sub.Id,
                                                     Parent_Opportunity__c = opp.Id
                                                    );
                                if(fulfillmentOpsId.size()>0){
                                    crec.OwnerId = fulfillmentOpsId[0].Id;
                                }
                                if(caseRecordTypeId !=null) {
                                    crec.RecordTypeId = caseRecordTypeId ;
                                }
                                casesToInsert.add(crec);
                            }
            }
        }
        System.debug('GGGGXZ ' +casesToInsert.size() );
        if(casesToInsert.size() >0){
            System.debug('HHHXZ' );
            insert casesToInsert;
        } */
    } 
}