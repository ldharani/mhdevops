/**************************************************************************
 * Description  : until first activity created we need change the owner in roundrobin manner
 * Created Date : 26/09/2017
 * ************************************************************************/


global class LeadReassignmentBatch implements Schedulable, Database.Batchable<sObject>{
    global String query;
    global string businesshoursId;
    global Date leadCreateDate;
    global id queueId;
    global Map<Integer,User>ownerstoAssignMap;
    global Date todaysDate;
       

    global LeadReassignmentBatch(){
        businesshoursId = system.Label.MN_Business_hours;
        leadCreateDate = date.newInstance(2009, 09, 26);
        todaysDate = Date.today();
        queueId = [select Id from Group where Name = 'MN Unassigned Leads' and Type = 'Queue'].id;
        ownerstoAssignMap = new Map<Integer,User>();
        
        for(user u : [select id,LeadOwner_Number__c from user
                      where LeadOwner_Number__c != NULL]){
            ownerstoAssignMap.put(Integer.valueOf(u.LeadOwner_Number__c), u);                  
        }
        system.debug('@@@@@ownerstoAssignMap'+ownerstoAssignMap);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
         query = 'Select Id, Name, RecordType.DeveloperName, Lead_Owner_Change_Date__c,Lead_Owner_Number__c,  '+
                        ' createdbyId From Lead '+
                        ' where (RecordType.DeveloperName = \'M_N_Leads\' AND Lead_Owner_Number__c!= NULL AND (Status = \'In Progress - Do Not Nurture\' OR Status = \'In Progress - Nurture\' OR Status = \'Open\' ) AND First_Activity_Created__c=TRUE )'+
                        ' AND ( MN_Lead_Source__c = \'Attorneys.com\'OR MN_Lead_Source__c = \'Email Campaign\' OR MN_Lead_Source__c= \'Hunter (LinkedIn)\''+
                        ' OR MN_Lead_Source__c = \'Inbound Call\'OR MN_Lead_Source__c = \'LeadGen Email\' OR MN_Lead_Source__c= \'LinkedIn\''+
                        ' OR MN_Lead_Source__c = \'TotalAttorneys.com Organic\' OR MN_Lead_Source__c = \'Marketing\'OR MN_Lead_Source__c = \'MarketYourFirm\' OR MN_Lead_Source__c= \'MarketYourFirm Website\''+
                        ' OR MN_Lead_Source__c = \'MDC/LDC Inquiry\'OR MN_Lead_Source__c = \'MH - SEM\' OR MN_Lead_Source__c= \'NGAGE - SEM\''+
                        ' OR MN_Lead_Source__c = \'MYF Chat\'OR MN_Lead_Source__c = \'Nolo.com Organic\' OR MN_Lead_Source__c= \'OptinMonster\''+
                        ' OR MN_Lead_Source__c = \'Pardot Lead Nurture\'OR MN_Lead_Source__c = \'Peer Review Ratings\' OR MN_Lead_Source__c= \'Regional Events\''+
                        ' OR MN_Lead_Source__c = \'SEM\'OR MN_Lead_Source__c = \'Webinar\' OR MN_Lead_Source__c = \'TA.com Organic\' OR MN_Lead_Source__c= \'Trade Show\')'+
                         ' AND (CreatedDate >= :leadCreateDate AND Lead_Owner_Change_Date__c!= NULL AND OwnerId != :queueId) ';//+
                        
                       
                        //' AND ID=\'00Q0U0000029grm\'';
         if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
         }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        
        List<lead> leadstoUpdate   = new List<lead>();
        Map<Id,List<Task>> mapLeadIdToLstTask = new Map<Id,List<Task>>();
        List<Task> allTasks = new List<Task>();
        Set<Id> updateLeadIs = new Set<Id>();
        List<Lead> finalLeadList = new List<Lead>();
        
        Timezone tz = Timezone.getTimeZone('America/New_York');
        System.debug('===========Lead List======'+leadList);
        
        Date yesterdy = Date.Today()-1;
        Date today = Date.Today();
        System.debug('@@@@yesterdy'+yesterdy);
        
        for(Task objTask:[Select Id, Status,Subject, ActivityDate,WhoId 
                            FROM Task WHERE WhoId IN: leadList //AND Status!='Completed' AND ActivityDate>= today 
                            ]) 
        {   
            System.debug('=========Inside for=====');
            //Use a map to store all the child tasks related to Lead
            
            
            if(!mapLeadIdToLstTask.containsKey(objTask.WhoId))
                mapLeadIdToLstTask.put(objTask.WhoId, new List<Task>{objTask});
            else
                mapLeadIdToLstTask.get(objTask.WhoId).add(objTask);
        } 
            System.debug('@@@@@mapLeadIdToLstTask'+mapLeadIdToLstTask);
        
            for(Lead l : leadList){
                //converting lead owner change date to pst and finding the difference
                System.debug('==========Inside the lead===='+l);
                
                if(mapLeadIdToLstTask.containskey(l.id)){
                    allTasks = mapLeadIdToLstTask.get(l.id);
                }
            }
            System.debug('@@@@@@@@allTasks '+allTasks);
            
            for(Task t: allTasks ){
            System.debug('@@@t.ActivityDate == yesterdy'+t.ActivityDate);
                if(t.Status!='Completed' && t.ActivityDate<= yesterdy ){
                    updateLeadIs.add(t.WhoId);
                }else if(t.Status!='Completed' && t.ActivityDate>= today){
                    updateLeadIs.remove(t.WhoId);
                }
            }
            System.debug('==@@@@@@updateLeadIs'+updateLeadIs);
            
            if(!updateLeadIs.isempty()){
                finalLeadList = [Select id, name,Lead_Owner_Number__c From Lead Where id in: updateLeadIs];
            }
            
            System.debug('==@@@@@@finalLeadList'+finalLeadList);
            
            for(Lead l: finalLeadList ){
            
                Integer num;
                if(l.Lead_Owner_Number__c == ownerstoAssignMap.size()){
                    num =1;
                }
                else{
                    
                    num = Integer.valueOf(l.Lead_Owner_Number__c)+ 1;
                    //if created by user and first conversion user are same then assigning to next number 
                    if(Integer.valueOf(l.Lead_Owner_Number__c) == 0 && l.CreatedById == ownerstoAssignMap.get(num).id){
                        num = num + 1;
                    }
                }
                system.debug('@@@@@ num'+ num);
                If(ownerstoAssignMap.containsKey(num)){
                    l.OwnerId  = ownerstoAssignMap.get(num).id;
                    system.debug('@@@l ownerId'+ l.ownerId);
                    l.Lead_Owner_Number__c = num;
                    leadstoUpdate.add(l);
                }
            
        }
        
        If(!leadstoUpdate.isEmpty()){
            update leadstoUpdate;
        }
        
    }
    
     global void finish(Database.BatchableContext BC) {
        
    }
    
     global void execute(SchedulableContext sc) {
        LeadReassignmentBatch LeadReassignmentBatchsch = new LeadReassignmentBatch();
        Database.executebatch(LeadReassignmentBatchsch);
    } 
    
    
}