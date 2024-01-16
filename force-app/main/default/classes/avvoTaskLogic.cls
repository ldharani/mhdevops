public class avvoTaskLogic{
    public static void avvoTaskFieldUpdates(List<Task>tasks){
        //getting custom settings
        List<Avvo_Task_Rollup_Settings__c> rollupSettings = new List<Avvo_Task_Rollup_Settings__c>();
        rollupSettings = [select id, Name, AELastActivityCompletedRoleId__c, LastActivityAERoleId__c, LastActivityAMCRMRoleId__c, LastAMConnectedCallRoleId__c,
                            LastAMConnectedCallSubject__c, LastAMEmailSentRoleId__c, LastAMEmailSentSubject__c, LastAMLeftMessageRoleId__c, LastAMLeftMessageSubject__c
                            FROM Avvo_Task_Rollup_Settings__c];
        system.debug('====rollupSettings===='+rollupSettings);
        //getting avvo Record types
        String avvoAcctExecRecTypId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Acct Exec Task').getRecordTypeId();
        String avvoAcctMgrRecTypId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Acct Mgr Task').getRecordTypeId();
        String avvoSalesDevRepRecTypId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Sales Dev Rep Task').getRecordTypeId();
        String avvoSalesTskRecTypId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Avvo Sales Task Type').getRecordTypeId();
        
        tasks = [SELECT Id, WhoId, ActivityDate, AssignedUserRole__c , Subject, IsDeleted, OwnerId, IsClosed, Status,
                AssignedUserName__c, RecordTypeID FROM Task WHERE Id in: trigger.new AND status = 'completed' AND 
                (RecordTypeID =:avvoAcctExecRecTypId OR RecordTypeID =:avvoAcctMgrRecTypId OR RecordTypeID =:avvoSalesDevRepRecTypId OR RecordTypeID =:avvoSalesTskRecTypId)];
        system.debug('====tasks===='+tasks);
        Map<Id, List<string>> whoIdVsTaskType = new Map<Id, List<string>>();
        Map<Id, Date> whoIdVsdueDate = new Map<Id, Date>();
        Map<Id, string> whoIdvsTaskAssignedUser = new Map<Id, string>();
        List<Contact> contactListToUpdate = new List<Contact>();
        List<Contact> contactUpdate = new List<Contact>();
        List<string> typeOfTask = new List<string>();
        Map<id,Contact> contIdVsConMap = new Map<Id, contact>();

        for(Task t:tasks){
            for(Avvo_Task_Rollup_Settings__c atrSettings: rollupSettings){
                List<string> concalSub = atrSettings.LastAMConnectedCallSubject__c.split(',');
                List<string> emailSub = atrSettings.LastAMEmailSentSubject__c.split(',');
                List<string> lftmsgSub = atrSettings.LastAMLeftMessageSubject__c.split(',');
                List<Id> amcrmRoleId = atrSettings.LastActivityAMCRMRoleId__c.split(',');
                List<Id> amemailRoleId = atrSettings.LastAMEmailSentRoleId__c.split(',');
                List<Id> amccRoleId = atrSettings.LastAMConnectedCallRoleId__c.split(',');
                List<Id> amlmRoleId = atrSettings.LastAMLeftMessageRoleId__c.split(',');
                List<Id> aecbyRoleId = atrSettings.AELastActivityCompletedRoleId__c.split(',');
                List<Id> aelactRoleId = atrSettings.LastActivityAERoleId__c.split(',');
                Boolean concalSubMatch = false;
                Boolean emailSubMatch = false;
                Boolean lftmsgSubMatch = false;
                Boolean amcrmRoleMatch = false;
                Boolean amemailRoleMatch = false;
                Boolean amccRoleMatch = false;
                Boolean amlmRoleMatch = false;
                Boolean aecbyRoleMatch = false;
                Boolean aelactRoleMatch = false;
                
                for(string cc: concalSub){
                    system.debug('===cc==='+cc.trim());
                    system.debug('===t.subject==='+t.subject);
                    if(t.subject.startsWithIgnoreCase(cc.trim())){
                        concalSubMatch = true;
                        break;
                    }
                }
                for(string em: emailSub){
                    system.debug('===cc==='+em.trim());
                    system.debug('===t.subject==='+t.subject);
                    if(t.subject.startsWithIgnoreCase(em.trim())){
                        emailSubMatch = true;
                        break;
                    }
                }
                for(string lm: lftmsgSub){
                    system.debug('===lm==='+lm.trim());
                    system.debug('===t.subject==='+t.subject);
                    if(t.subject.startsWithIgnoreCase(lm.trim())){
                        lftmsgSubMatch = true;
                        break;
                    }
                }
                for(string acrm: amcrmRoleId){
                    if(acrm.contains(t.AssignedUserRole__c)){
                        amcrmRoleMatch = true;
                        break;
                    }
                }
                for(string amem: amemailRoleId){
                    if(amem.contains(t.AssignedUserRole__c)){
                        amemailRoleMatch = true;
                        break;
                    }
                }
                for(string amcc: amccRoleId){
                    if(amcc.contains(t.AssignedUserRole__c)){
                        amccRoleMatch = true;
                        break;
                    }
                }
                for(string amlm: amlmRoleId){
                    if(amlm.contains(t.AssignedUserRole__c)){
                        amlmRoleMatch = true;
                        break;
                    }
                }
                for(string aec: aecbyRoleId){
                    if(aec.contains(t.AssignedUserRole__c)){
                        aecbyRoleMatch = true;
                        break;
                    }
                }
                for(string aea: aelactRoleId){
                    if(aea.contains(t.AssignedUserRole__c)){
                        aelactRoleMatch = true;
                        break;
                    }
                }
                //checking the current task's user role and subject conditions 
                if(concalSubMatch && amccRoleMatch){
                    //connectedcall task
                    typeOfTask.add('AMConnectedCallTask');
                    whoIdVsTaskType.put(t.WhoId, typeOfTask);
                    whoIdVsdueDate.put(t.WhoId, t.ActivityDate);
                }
                if(emailSubMatch && amemailRoleMatch){
                    //email task
                    typeOfTask.add('AMEmailSentTask');
                    whoIdVsTaskType.put(t.WhoId, typeOfTask);
                    whoIdVsdueDate.put(t.WhoId, t.ActivityDate);
                }
                if(lftmsgSubMatch && amlmRoleMatch){
                    //leftmsg task
                    typeOfTask.add('AMLeftMessageTask');
                    whoIdVsTaskType.put(t.WhoId, typeOfTask);
                    whoIdVsdueDate.put(t.WhoId, t.ActivityDate);
                }
                if(amcrmRoleMatch){
                    //AM/CRM task
                    typeOfTask.add('AMCRMActivityTask');
                    whoIdVsTaskType.put(t.WhoId, typeOfTask);
                    whoIdVsdueDate.put(t.WhoId, t.ActivityDate);
                }
                if(aecbyRoleMatch){
                    //AEcompletedby task
                    typeOfTask.add('AECompletedbyTask');
                    whoIdVsTaskType.put(t.WhoId, typeOfTask);
                    whoIdvsTaskAssignedUser.put(t.WhoId, t.AssignedUserName__c);
                }
                if(aelactRoleMatch){
                    //AElastactivity task
                    typeOfTask.add('AEActivityTask');
                    whoIdVsTaskType.put(t.WhoId, typeOfTask);
                    whoIdVsdueDate.put(t.WhoId, t.ActivityDate);
                }
            }
        }
        system.debug('===whoIdMap===='+whoIdVsTaskType);
        system.debug('===dueDateMap===='+whoIdVsdueDate);
        for(Contact con: [Select Id, Name, Professional_ID__c, Related_To_Account__c, Last_AM_Connected_Call__c, Last_AM_Email_sent__c, 
                         Last_AM_Left_Message__c, Last_Activity_AM_CRM__c, Last_Activity_AE__c, AE_Last_Activity_Completed_by__c,
                         Related_To_Account__r.AM_Book__c, Related_To_Account__r.Win_back__c, Related_To_Account__r.Customer_No_Book__c
                         from Contact where Id IN:whoIdVsTaskType.keySet()]){
        system.debug('===whoIdVsTaskType.values()==='+whoIdVsTaskType.values());                 
            for(List<String> s:whoIdVsTaskType.values()){
                if(s.contains('AMConnectedCallTask')){
                    if(whoIdVsdueDate.containskey(con.id) && (con.Related_To_Account__r.AM_Book__c == true || con.Related_To_Account__r.Win_back__c == true || con.Related_To_Account__r.Customer_No_Book__c == true)){
                            if(con.Last_AM_Connected_Call__c != Null && con.Last_AM_Connected_Call__c < whoIdVsdueDate.get(con.id)){
                            system.debug('===con.Last_AM_Connected_Call__c===='+con.Last_AM_Connected_Call__c);
                            con.Last_AM_Connected_Call__c = whoIdVsdueDate.get(con.id);
                        }
                        else if(con.Last_AM_Connected_Call__c == Null){
                            system.debug('===con.Last_AM_Connected_Call__c===='+con.Last_AM_Connected_Call__c);
                            con.Last_AM_Connected_Call__c = whoIdVsdueDate.get(con.id);
                        }
                            contactListToUpdate.add(con);
                    }
                }
                if(s.contains('AMCRMActivityTask')){
                    if(whoIdVsdueDate.containskey(con.id) && (con.Related_To_Account__r.AM_Book__c == true || con.Related_To_Account__r.Win_back__c == true || con.Related_To_Account__r.Customer_No_Book__c == true)){
                        system.debug('===con.Last_Activity_AM_CRM__c===='+con.Last_Activity_AM_CRM__c);
                        if(con.Last_Activity_AM_CRM__c != Null && con.Last_Activity_AM_CRM__c < whoIdVsdueDate.get(con.id)){
                            con.Last_Activity_AM_CRM__c = whoIdVsdueDate.get(con.id);
                            system.debug('===con.Last_Activity_AM_CRM__c===='+con.Last_Activity_AM_CRM__c);
                        }
                        else if(con.Last_Activity_AM_CRM__c == Null){
                            con.Last_Activity_AM_CRM__c = whoIdVsdueDate.get(con.id);
                            system.debug('===con.Last_Activity_AM_CRM__c===='+con.Last_Activity_AM_CRM__c);
                        }
                        contactListToUpdate.add(con);
                        
                    }
                }
                if(s.contains('AMEmailSentTask')){
                    if(whoIdVsdueDate.containskey(con.id) && (con.Related_To_Account__r.AM_Book__c == true || con.Related_To_Account__r.Win_back__c == true || con.Related_To_Account__r.Customer_No_Book__c == true)){
                        if(con.Last_AM_Email_sent__c != Null && con.Last_AM_Email_sent__c < whoIdVsdueDate.get(con.id)){
                            con.Last_AM_Email_sent__c = whoIdVsdueDate.get(con.id);
                        }
                        else if(con.Last_AM_Email_sent__c == Null){
                            con.Last_AM_Email_sent__c = whoIdVsdueDate.get(con.id);
                        }
                        contactListToUpdate.add(con);
                    }
                }
                if(s.contains('AMLeftMessageTask')){
                    if(whoIdVsdueDate.containskey(con.id) && (con.Related_To_Account__r.AM_Book__c == true || con.Related_To_Account__r.Win_back__c == true || con.Related_To_Account__r.Customer_No_Book__c == true)){
                        if(con.Last_AM_Left_Message__c != Null && con.Last_AM_Left_Message__c < whoIdVsdueDate.get(con.id)){
                            system.debug('===con.Last_AM_Left_Message__c===='+con.Last_AM_Left_Message__c);
                            con.Last_AM_Left_Message__c = whoIdVsdueDate.get(con.id);
                        }
                        else if(con.Last_AM_Left_Message__c == Null){
                            system.debug('===con.Last_AM_Left_Message__c===='+con.Last_AM_Left_Message__c);
                            con.Last_AM_Left_Message__c = whoIdVsdueDate.get(con.id);
                        }
                        contactListToUpdate.add(con);
                    }
                }
                if(s.contains('AEActivityTask')){
                    if(whoIdVsdueDate.containskey(con.id)){
                        if(con.Last_Activity_AE__c != Null && con.Last_Activity_AE__c < whoIdVsdueDate.get(con.id)){
                            con.Last_Activity_AE__c = whoIdVsdueDate.get(con.id);
                        }
                        else if(con.Last_Activity_AE__c == Null){
                            con.Last_Activity_AE__c = whoIdVsdueDate.get(con.id);
                        }
                        contactListToUpdate.add(con);
                    }
                }
                if(s.contains('AECompletedbyTask')){
                    if(whoIdvsTaskAssignedUser.containskey(con.id)){
                        system.debug('===con.AE_Last_Activity_Completed_by__c==='+con.AE_Last_Activity_Completed_by__c);
                        system.debug('===taskAssignedUserNameMap.get(con.id)==='+whoIdvsTaskAssignedUser.get(con.id));
                        system.debug('===con.AE_Last_Activity_Completed_by__c null cond==='+con.AE_Last_Activity_Completed_by__c != Null);
                        if((con.AE_Last_Activity_Completed_by__c != Null || con.AE_Last_Activity_Completed_by__c != whoIdvsTaskAssignedUser.get(con.id)) && 
                            con.Last_Activity_AE__c != Null && (con.Last_Activity_AE__c < whoIdVsdueDate.get(con.id) || con.Last_Activity_AE__c == whoIdVsdueDate.get(con.id))){
                            con.AE_Last_Activity_Completed_by__c = whoIdvsTaskAssignedUser.get(con.id);
                            system.debug('===taskAssignedUserNameMap.get(con.id)==='+whoIdvsTaskAssignedUser.get(con.id));
                        }
                        else if(con.AE_Last_Activity_Completed_by__c == Null){
                            con.AE_Last_Activity_Completed_by__c = whoIdvsTaskAssignedUser.get(con.id);
                            system.debug('===taskAssignedUserNameMap.get(con.id)==='+whoIdvsTaskAssignedUser.get(con.id));
                        }
                        //con.AE_Last_Activity_Completed_by__c = taskAssignedUserNameMap.get(con.id);
                        contactListToUpdate.add(con);
                    }
                }
            }
        }
        if(!contactListToUpdate.isempty()){
            for(Contact con: contactListToUpdate){
                if(!contIdVsConMap.containskey(con.id)){
                    contIdVsConMap.put(con.id,con);
                }
            }
        }
        
        system.debug('===contIdVsConMap==='+contIdVsConMap);
        if(!contIdVsConMap.Values().isempty()){
           system.debug('===contIdVsConMap.values()==='+contIdVsConMap.values());
           update contIdVsConMap.Values();
        }
    }
}