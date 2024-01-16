/****************************************************************
 * Author       :Sai
 * Description  : To find the Recent task of account in reports
 * Created Date : 13/07/2017
 * **************************************************************
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date          Requested By    Tag     Description
MHBS-6830    Jey           31/05/20222   Kimberly Rudy   T01     To Update Task Due Date
MHBS-8659    Lakshmi       08/03/2023    Kimberly Rudy   T02     To Update Last Sales Activity on Lead
MHBS-8532    Chetna        02/03/2022    John Mattheson  T03     Track email and call activity/tasks on Lead records
************************************************************************************************************************/
public class TaskTriggerHandler {
    Public static boolean leadcoversionflag = false;
    
    public static string SalesTaskRecordType = 'Sales Task Type';
    public static string MHLeadRecordType = 'M-H lead';
    public static void updateRecentTasks(List<task>tasksList){
        String account_prefix    = Schema.SObjectType.Account.getKeyPrefix();
        String salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        for(task tsk: tasksList){
            string taskID = tsk.WhatId;
            system.debug('@@@@task accountId'+ tsk.accountID);
            if(tsk.WhatId != NULL && taskID.startswith(account_prefix)  && tsk.RecordTypeId == salesTaskRectypeId){
                //tsk.Recent_Task__c  = True;
            }   
        }
    }
    
    
    /***************************************************************************
     * Author        : Sai
     * Description   : To populate recent task checkbox true when a task is related to account
     *                 Here we are updating the Same inserted record, main reason for this not to go with
     *                 before insert is AccountId field on task is only populating in after triggers
     *                 so, as accountId is populated when taks is created from account, opportunity of same account, contact of same account.
     * *************************************************************************/
    
    public static void updatenotRecentTasks(List<Task> taskslist){
        
        system.debug('@@@@@ in updatenotRecentTasks');
        String account_prefix    = Schema.SObjectType.Account.getKeyPrefix();
        
        system.debug('@@@@@account_prefix'+account_prefix);
        //List<task> AccountTasks  = new List<task>(); 
        Set<Id> accids           = new Set<Id>();
        List<task> taskstoUpdate = new  List<task>();
        String salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        Set<Id> taskIds         = new Set<Id>();
        
        for(task tsk  : taskslist){
            //string taskID = tsk.WhatId;
            system.debug('@@@@@taskId in after'+ tsk.AccountId);
                       
            if(tsk.AccountId !=NULL  &&  tsk.RecordTypeId == salesTaskRectypeId && !tsk.Subject.contains('Email send to customer for credit card expiration')){
                accids.add(tsk.AccountId);
                taskIds.add(tsk.id);
            }
        }
        
        for(task singletask : [select id,Subject,Credit_Exp__c,Recent_Task__c from task 
                                        where AccountId IN:accids AND Credit_Exp__c = FALSE
                                AND RecordTypeID =:salesTaskRectypeId]){
               if(taskIds.contains(singletask.id)){
                     singletask.Recent_Task__c = True;
                     taskstoUpdate.add(singletask);   
                } 
                else{
                   if(singletask.Recent_Task__c == True){
                       singletask.Recent_Task__c = false;
                       taskstoUpdate.add(singletask);   
                }
          }
                                    
            
                                
        }
        
      
        
        if(!taskstoUpdate.isEmpty()){
            for(Task t: taskstoUpdate){
               System.debug(t);
            }
           // LeadTriggerHandler.BypassTaskTrig = true;
            update taskstoUpdate;
        }
        
    }
/***************************************************************************************
 * Author       :Ronak 
 * Description  : To relate the tasks created on the contact to the Avvo Accounts
 * Created Date : 13/07/2017
 * ***********************************************************************************/
    public static void updateRelatedToOnAvvoTasksOnContact(List<Task> taskList){
        
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, Id> taskIdVscontactIdMap = new Map<Id, Id>();
        List<Contact> contactList = new List<Contact>();
        Map<Id, Id> contactIdVsAcctMap = new Map<Id, Id>(); 
        List<Task> updateTaskList = new List<Task>();
        
        String avvoExecTaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Acct Exec Task').getRecordTypeId();
        String avvoAcctMgrTaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Acct Mgr Task').getRecordTypeId();
        String avvoSalesDecTaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Sales Dev Rep Task').getRecordTypeId();
        String avvoSalesTaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Sales Task Type').getRecordTypeId();
        String defaultTaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Default Task Record Type').getRecordTypeId();
        
        
        for(Task t: taskList){
            System.debug('AAAA');
            String contId= t.WhoId;
            String contactIsPresent= '003';
            if(t.WhoId!=NULL && contId.contains(contactIsPresent) && (t.RecordtypeId == avvoExecTaskTypeId || t.RecordtypeId == avvoAcctMgrTaskTypeId 
            || t.RecordtypeId == avvoSalesDecTaskTypeId || t.RecordtypeId == avvoSalesTaskTypeId 
                                                                   //   || t.RecordtypeId == defaultTaskTypeId
                                                                     )){
                System.debug('BBBB');
                contactIdSet.add(t.WhoId);
                if(!taskIdVscontactIdMap.containskey(t.Id)){
                    System.debug('CCC');
                    taskIdVscontactIdMap.put(t.Id, t.WhoId); 
                }
                
            }
        }
        System.debug('@@@@@@@taskIdVscontactIdMap------>'+taskIdVscontactIdMap);
        System.debug('@@@@@@@contactIdSet-------->'+contactIdSet);
        if(contactIdSet!=NULL){
            System.debug('DDD');
            contactList = [Select id, name, Related_To_Account__c From Contact Where Id in: contactIdSet];
            
            if(!contactList.isempty() && contactList!=NULL){
                System.debug('EEE');
                for(Contact c: contactList ){
                    System.debug('FFF');
                    System.debug('@@@@@@Contact Account id=-==.>>>'+c.Related_To_Account__c);
                    if(c.Related_To_Account__c!= NULL){
                         System.debug('GGG');
                        if(!contactIdVsAcctMap.containskey(c.Id)){
                            System.debug('HHH');
                            contactIdVsAcctMap.put(c.Id, c.Related_To_Account__c);
                        }
                    }
                }
            }
            System.debug('@@@@@Contact ID --->>>>>AccountMpa---->'+contactIdVsAcctMap);
            for(task t: taskList){
                System.debug('III');
                String conid;
                if(taskIdVscontactIdMap.containskey(t.id)){
                    System.debug('JJJ');
                    conId = taskIdVscontactIdMap.get(t.id);
                    if(contactIdVsAcctMap.containskey(conId)){
                        System.debug('KKK');
                        t.WhatId = contactIdVsAcctMap.get(conId);
                    }
                }
            }    
        }
        
     
    }
    
    public static void firstTaskCreatedonLead(List<task>taskList){
        
        Set<String> leadIds = new Set<String>();
        Map<Id,Lead> idVsLead = new Map<Id,Lead>();
        List<lead> leadstoUpdate = new List<lead>();
        for(task singleTask : taskList){
            
            if(singleTask.WhoId != NULL ){
                string whoIdtemp = string.valueOf(singleTask.WhoId);
                if(whoIdtemp.startsWith('00Q')){
                    leadIds.add(whoIdtemp);
                }
            }
        }
        
        if(!leadIds.isEmpty()){
            idVsLead = new Map<Id,Lead>([select id, Name , OwnerId,First_Activity_Created__c from Lead
                                                      where Id IN:leadIds AND First_Activity_Created__c= FALSE AND RecordType.DeveloperName = 'M_N_Leads']);
            if(!idVsLead.isEmpty()){
                for(task singleTask : taskList){
                    if(idVsLead.containsKey(singleTask.WhoId)){
                          lead l = idVsLead.get(singleTask.WhoId);
                        if(singleTask.CreatedById == l.OwnerId && 
                        !singleTask.subject.contains('This Lead Has Been Assigned to You - Action Required' )
                          && !singleTask.subject.contains('Try Again Follow Up Call - Action Required')){
                           
                            l.First_Activity_Created__c = true;
                            leadstoUpdate.add(l);
                        }
                       
                    }
                }
            }
        }
        
        if(!leadstoUpdate.isEmpty()){
            update leadstoUpdate;
        }
        
        
        
        
    }
    
    /**************************************************************************************************
 * Author       :Ronak 
 * Description  : To append a break in the task description for Avvo related tasks as part of data load
 * Created Date : 13/07/2017
 * ***************************************************************************************************/
    public static void taskDescripUpdate(List<task> taskList){
    
        String breakTag = '<br>';
        String breakReplacement = '\n';
        for(Task t: taskList){
            if(t.Description !=NUll){
                String tas = t.Description;
                
                System.debug('Task String--------->'+tas);
                
                tas = tas.replaceAll(breakTag, breakReplacement);
                t.Description = tas;
                System.debug('Task replacement------>'+t.Description);
            }
        
        }
    }
    
    
    /**************************************************************************************************
 * Author       :Ronak 
 * Description  : This logic is added to make sure the task created through outreach gets associated to the correct Oppty
 * Created Date : 13/07/2017
 * ***************************************************************************************************/
    public static void taskOpptyUpdate(List<Task> taskList){
        
        Map<String, Task> opptyIdNTaskMap = new Map<String, Task>();
        Set<Id> contactIds = new Set<Id>();
        Map<String, String> taskIdNopptyIdMap = new Map<String, String>();
        
        String salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        String noloTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MN Sales Task Type').getRecordTypeId();
        
        for(Task t: taskList){            
            if(t.WhoId!= NULL && t.WhoId.getSObjectType() == Contact.sObjectType){
                System.debug('Inside the final if condition---------'+t);
                if(t.WhatId!=Null && t.WhatId.getSObjectType() == Opportunity.sObjectType){
                    contactIds.add(t.WhoId);
                    
                    if(!opptyIdNTaskMap.containskey(t.WhatId)){
                        opptyIdNTaskMap.put(t.WhatId, t); 
                    } 
                }    
                
            }
        }
        System.debug('@@@@@@@@@@opptyIdNTaskMap----------->'+opptyIdNTaskMap);
        
        List<Opportunity> opptyList = [Select id, name,StageName,RecordType.Name From Opportunity Where StageName!='Closed Won' AND StageName!='Closed Lost' AND Auth_By_Contact__c  in: contactIds ORDER BY CreatedDate DESC];    
        
        System.debug('List of open opportunities from the system---------------->'+opptyList);
        
        if(!opptyList.isempty()){
            
                
                for(Task t: opptyIdNTaskMap.values()){
                    for(Opportunity opp: opptyList){
                        //System.debug('@@@@@@@@@@salesTaskRectypeId------>'+salesTaskRectypeId );
                        //System.debug('@@@@@@@@@@opportunity Record Type----->'+opp.RecordType.Name);
                       // System.debug('@@@@@@@@@@task record type id------>'+t.RecordTypeId);
                    
                        if(t.RecordTypeId == salesTaskRectypeId && opp.RecordType.Name == 'M-H Opportunity'){
                            if(!taskIdNopptyIdMap.containskey(t.id)){
                                taskIdNopptyIdMap.put(t.Id, opp.Id); 
                            }
                        }
                        else if(t.RecordTypeId == noloTaskRecordTypeId && opp.RecordType.Name == 'M-N Opportunity'){
                            if(!taskIdNopptyIdMap.containskey(t.id)){
                                taskIdNopptyIdMap.put(t.Id, opp.Id); 
                            }
                        }
                    } 
                }
            
            System.debug('@@@@@@@@@Task ids and opportunity map-------------->'+taskIdNopptyIdMap);
        }
        if(!leadcoversionflag){        
       
        for(Task tas: opptyIdNTaskMap.values()){
            if(taskIdNopptyIdMap.containskey(tas.id)){
                tas.WhatId = taskIdNopptyIdMap.get(tas.id);
                system.debug('Tasks which are associated to opty'+ tas.id);
            }
            else{
                tas.WhatId = Null;
                system.debug('Tasks for which association made blank'+ tas.id);
            }
        
        }
        }    
    }
    
    
     /**************************************************************************************************
 * Author       :Ronak 
 * Description  : This logic is added to make sure the Last sales activity is captured for MH, Ngage, Nolo and Avvo for Rules of Enagagement
 * Created Date : 01/02/2020
 * ***************************************************************************************************/
    public static void updateTaskDateOnContact(List<Task> taskList){
        
        Map<String, String> ContactIdNmhtaskIdMap = new Map<String, String>();
        Map<String, String> ContactIdNNolotaskIdMap = new Map<String, String>();
        Map<String, String> ContactIdNNgagetaskIdMap = new Map<String, String>();
        
        Set<Id> contactIds = new Set<Id>();
        List<Account> parentAccts = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<Contact> updateContactList = new List<Contact>();
        
        Set<Contact> contactSet = new Set<Contact>();
        List<Contact> finalContactList = new List<Contact>();
        

        
        Map<String, String> taskIdNConIdMap = new Map<String, String>();
                
        String salesTaskRectypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task Type').getRecordTypeId();
        String noloTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MN Sales Task Type').getRecordTypeId();
        String ngageTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('M-NG Sales Task').getRecordTypeId();
        
        for(Task t: taskList){            
            if(t.WhoId!= NULL && t.WhoId.getSObjectType() == Contact.sObjectType){
                System.debug('Contact Ids----------------->>>>'+t.whoId);
                contactIds.add(t.WhoId);
                if(t.RecordTypeId == salesTaskRectypeId && (t.Purpose__c == 'Sales/New' || t.Purpose__c == 'Sales/Retention' || t.Purpose__c == 'Sales/Upsell' || t.Purpose__c == 'Service' || t.Purpose__c == 'Quarterly Call')  ){
                    ContactIdNmhtaskIdMap.put(t.WhoId, t.Id);
                }
                else if(t.RecordTypeId == noloTaskRecordTypeId){
                    ContactIdNNolotaskIdMap.put(t.WhoId, t.Id);
                }
                else if(t.RecordTypeId == ngageTaskRecordTypeId && (t.Purpose__c == 'Sales/New' || t.Purpose__c == 'Sales/Retention' || t.Purpose__c == 'Sales/Upsell' || t.Purpose__c == 'Service' || t.Purpose__c == 'Quarterly Call') ){
                    ContactIdNNgagetaskIdMap.put(t.WhoId, t.Id);
                }
            }
         }
         
             
         contactList = [Select id, name From Contact where id in: contactIds];

        for(Contact con: contactList ){
            if(ContactIdNmhtaskIdMap.containskey(con.id)){
                con.Last_MH_Sales_Activity_Date__c = Date.Today();
                updateContactList.add(con);
            }
            
            if(ContactIdNNolotaskIdMap.containskey(con.id)){
                con.Last_Nolo_Sales_Activity_Date__c = Date.Today();
                updateContactList.add(con);
            }
            
            if(ContactIdNNgagetaskIdMap.containskey(con.id)){
                con.Last_Ngage_Sales_Activity_Date__c = Date.Today();
                updateContactList.add(con);
            }
        }
        
        
         
        if(!updateContactList.isempty()){
            contactSet.addAll(updateContactList);
            finalContactList.addAll(contactSet);
            update finalContactList;
        }
        
        
     }


    //MHBS-5200 - To update the Task Record Type

    public static void updateTasksDueDate(List<task> tasksList){
       // String activityTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Activity').getRecordTypeId();
        //find all Opportunity record types
        List<Schema.RecordTypeInfo> infos = Schema.SObjectType.Task.RecordTypeInfos;
        Id defaultRecordTypeId;
        
        //check each one
        for (Schema.RecordTypeInfo info : infos) {
            if (info.DefaultRecordTypeMapping) {
                defaultRecordTypeId = info.RecordTypeId;
            }
        }
        
        //here is the default Opportunity RecordType Id for the current user
        System.debug('defaultRecordTypeId ' + defaultRecordTypeId);

        for(task tsk: tasksList){

            If(tsk.ActivityDate == System.today()){ //Tag - T01
            system.debug('defaultRecordTypeIdAAAAA');
          //  if(tsk.RecordTypeId == activityTaskRecordTypeId){
          if(tsk.Subject == 'Call' || tsk.Subject == 'Call - Inbound' || tsk.Subject == 'Call - Outbound'){ 
                system.debug('defaultRecordTypeIdBBBBB');
                tsk.RecordTypeId = defaultRecordTypeId;
                tsk.ActivityDate = System.today();
            }
            }
        }
        }
    
    
    //MHBS-5456-prevent the user who is not task owner from editing the task record
     
    public static void restrictRecordEdit(List<task> tasksList,map<id,task>mapofoldtasks){
      System.debug('inside restrictRecordEdit');
     List<String> ProfileNameList = new list<string>{'MN Ad Services','Nolo Acct Mgrs','MN Sales Reps','CPQ MH Sales Rep','MH Avvo Sales Rep','Ngage Sales'};
     List<string> ProfileIds = new list<string>();
     for(Profile objProf: [select Id from profile where Name in: ProfileNameList]){
      ProfileIds.add(objProf.Id);
     }
        System.debug(tasksList);
         System.debug(mapofoldtasks);
        System.debug(ProfileIds);
     for(Task objtask: tasksList){
      if(mapofoldtasks!=null){
          System.debug(UserInfo.getProfileId());
          System.debug((objtask.OwnerId!= mapofoldtasks.get(objtask.id).ownerid && ProfileIds.contains(UserInfo.getProfileId()))||(objtask.OwnerId!=UserInfo.getUserId() && (ProfileIds.contains(UserInfo.getProfileId()))));
          if((objtask.OwnerId!= mapofoldtasks.get(objtask.id).ownerid && ProfileIds.contains(UserInfo.getProfileId()))||(objtask.OwnerId!=UserInfo.getUserId() && (ProfileIds.contains(UserInfo.getProfileId())))){
              system.debug('error edit');
             objtask.adderror('You do not have permissions to edit/delete this record.');
          }
         
          }
         else{
             System.debug('inside else'+UserInfo.getProfileId());
          if(objtask.OwnerId!=UserInfo.getUserId() && (ProfileIds.contains(UserInfo.getProfileId()))){
          system.debug('error delete');
             objtask.adderror('You do not have permissions to edit/delete this record.');
          }
          }
      }
    
    }
    
    //<T02>
    public static void updateLSAOnLead (List<Task> newList){
        
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(SalesTaskRecordType).getRecordTypeId();
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(MHLeadRecordType).getRecordTypeId();
        Schema.DescribeSObjectResult leadDescribe = Lead.sObjectType.getDescribe();
        String leadkeyPrefix = leadDescribe.getKeyPrefix();     
        Set<Id> setofLeadIds = new Set<Id>();
        List<Lead> updateLeadRecords = new List<Lead>();
        
        for(Task tsk : newList){
            if(tsk.WhoId != null && tsk.RecordTypeId == taskRecordTypeId && String.valueOf(tsk.Whoid).startsWith(leadkeyPrefix)){
                    setofLeadIds.add(tsk.WhoId);
            }
        }
        
        if(setofLeadIds.size() > 0){
            system.debug('Leads==>'+setofLeadIds);
            system.debug('RecordTypeId==>'+LeadRecordTypeId);
            for(Lead ld : [Select Id, RecordTypeId,Last_Sales_Activity__c from Lead where Id in: setofLeadIds and RecordTypeId =: LeadRecordTypeId]){
                ld.Last_Sales_Activity__c = System.Today();
                updateLeadRecords.add(ld);
            }
        }
        
        if(updateLeadRecords.size() > 0){
            try{
                update updateLeadRecords;
            }
            catch(Exception e){
                Util.processException(e,true,'TaskTriggerHelper-updateLastActivityOnLead-Error during update of Last Sales Activity for Leads : '+updateLeadRecords);
            }
        }
    }
    //<T02>
    
     //<T03> Track email and call activity/tasks on Lead records
    public static void updateEmailCallActivityInfoOnLead(List<task> tasksList,map<id,task>mapOfOldTasks){
        Map<Id, Map<String, Object>> taskDetailsMap = new Map<Id, Map<String, Object>>();
        Schema.DescribeSObjectResult leadDescribe = Lead.sObjectType.getDescribe();
        String leadkeyPrefix = leadDescribe.getKeyPrefix();     
        String MHLeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(MHLeadRecordType).getRecordTypeId();
        system.debug('inside updateEmailCallActivityInfoOnLead ');
        for(Task tsk:tasksList){
            if((tsk.Type != null && tsk.WhoId !=null) 
               && (tsk.Type == 'Call' || tsk.Type == 'Email') 
               && String.valueOf(tsk.Whoid).startsWith(leadkeyPrefix)){//check if Type is Call / Email and if it belongs to a Lead
                   //leadIds.add(tsk.WhoId);
                   taskDetailsMap.put(tsk.WhoId, new Map<String, Object>{'CallCount' => 0, 'LastCallActivity' => null, 'EmailCount' => 0, 'LastEmailActivity' => null});
                   if(mapOfOldTasks!=null && mapOfOldTasks.get(tsk.Id) != null //If task update
                      && ((mapOfOldTasks.get(tsk.Id).Type != null && mapOfOldTasks.get(tsk.Id).Type != tsk.Type)
                          || (mapOfOldTasks.get(tsk.Id).WhoId !=null && mapOfOldTasks.get(tsk.Id).WhoId != tsk.WhoId))){ // Or If task update, check whether the Type is changed or the Lead is changed on the Task
                                taskDetailsMap.put(mapOfOldTasks.get(tsk.Id).WhoId, new Map<String, Object>{'CallCount' => 0, 'LastCallActivity' => null, 'EmailCount' => 0, 'LastEmailActivity' => null});
                            }
            }
        }
        for (AggregateResult taskDetail : [
            SELECT WhoId, Type, MAX(CreatedDate) latestActivity, COUNT(Id) taskCount
            FROM Task
            WHERE WhoId IN :taskDetailsMap.keySet() 
            AND Who.RecordTypeId =:MHLeadRectypeId //This condition can be removed in future if this functionality needs to be expanded for other recordtypes.
            AND Type IN ('Call', 'Email')
            GROUP BY WhoId, Type
        ]) {
            Id leadId = (Id)taskDetail.get('WhoId');
            String taskType = (String)taskDetail.get('Type');
            Integer taskCount = (Integer)taskDetail.get('taskCount');
            Datetime latestActivity = (Datetime)taskDetail.get('latestActivity');
            
            if (taskType == 'Call') {
                taskDetailsMap.get(leadId).put('CallCount', taskCount);
                if (taskDetailsMap.get(leadId).get('LastCallActivity') == null || latestActivity > (Datetime)taskDetailsMap.get(leadId).get('LastCallActivity')) {
                    taskDetailsMap.get(leadId).put('LastCallActivity', latestActivity);
                }
            }
            else if (taskType == 'Email') {
                taskDetailsMap.get(leadId).put('EmailCount', taskCount);
                if (taskDetailsMap.get(leadId).get('LastEmailActivity') == null || latestActivity > (Datetime)taskDetailsMap.get(leadId).get('LastEmailActivity')) {
                    taskDetailsMap.get(leadId).put('LastEmailActivity', latestActivity);
                }
            }
        }
        
        List<Lead> leadsToUpdate = new List<Lead>();
        
        // Loop through each Lead and update the fields
        for (Id leadId : taskDetailsMap.keySet()) {
            system.debug('taskDetailsMap for lead ' +taskDetailsMap.get(leadId));
            Map<String, Object> leadDetailsMap = taskDetailsMap.get(leadId);
            
            Lead leadToUpdate = new Lead(Id = leadId);
            leadToUpdate.Call_Activity_Count__c = (Integer)leadDetailsMap.get('CallCount');
            leadToUpdate.Last_Call_Activity_Date__c = (Datetime)leadDetailsMap.get('LastCallActivity');
            leadToUpdate.Email_Activity_Count__c = (Integer)leadDetailsMap.get('EmailCount');
            leadToUpdate.Last_Email_Activity_Date__c = (Datetime)leadDetailsMap.get('LastEmailActivity');
            
            leadsToUpdate.add(leadToUpdate);
        }
        if(leadsToUpdate!=null & !leadsToUpdate.isEmpty()){
            try{
                update leadsToUpdate;
            }catch(Exception e){
                Util.processException(e,true,'TaskTriggerHelper-updateEmailCallActivityInfoOnLead-Error during update of Call/Email Summary fields for Leads : '+leadsToUpdate);
            }
        }
    }//End of <T03>
    
}