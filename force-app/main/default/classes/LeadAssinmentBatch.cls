/**************************************************************************
 * Description  : until first activity created we need change the owner in roundrobin manner
 * Created Date : 26/09/2017
 * ************************************************************************/


global class LeadAssinmentBatch implements Schedulable, Database.Batchable<sObject>{
    global String query;
    global string businesshoursId;
    global Date leadCreateDate;
    global id queueId;
    global Map<Integer,User>ownerstoAssignMap;
       

    global LeadAssinmentBatch(){
        businesshoursId = system.Label.MN_Business_hours;
        leadCreateDate = date.newInstance(2009, 09, 26);
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
                        ' where (RecordType.DeveloperName = \'M_N_Leads\' AND Lead_Owner_Number__c!= NULL AND (Status = \'In Progress - Do Not Nurture\' OR Status = \'In Progress - Nurture\' OR Status = \'Open\' )  AND First_Activity_Created__c= False) '+
                        ' AND ( MN_Lead_Source__c = \'Attorneys.com\'OR MN_Lead_Source__c = \'Email Campaign\' OR MN_Lead_Source__c= \'Hunter (LinkedIn)\''+
                        ' OR MN_Lead_Source__c = \'Inbound Call\'OR MN_Lead_Source__c = \'LeadGen Email\' OR MN_Lead_Source__c= \'LinkedIn\''+
                        ' OR MN_Lead_Source__c = \'TotalAttorneys.com Organic\' OR MN_Lead_Source__c = \'Marketing\'OR MN_Lead_Source__c = \'MarketYourFirm\' OR MN_Lead_Source__c= \'MarketYourFirm Website\''+
                        ' OR MN_Lead_Source__c = \'MDC/LDC Inquiry\'OR MN_Lead_Source__c = \'MH - SEM\' OR MN_Lead_Source__c= \'NGAGE - SEM\''+
                        ' OR MN_Lead_Source__c = \'MYF Chat\'OR MN_Lead_Source__c = \'Nolo.com Organic\' OR MN_Lead_Source__c= \'OptinMonster\''+
                        ' OR MN_Lead_Source__c = \'Pardot Lead Nurture\'OR MN_Lead_Source__c = \'Peer Review Ratings\' OR MN_Lead_Source__c= \'Regional Events\''+
                        ' OR MN_Lead_Source__c = \'SEM\'OR MN_Lead_Source__c = \'Webinar\' OR MN_Lead_Source__c = \'TA.com Organic\' OR MN_Lead_Source__c= \'Trade Show\')'+
                         ' AND (CreatedDate >= :leadCreateDate AND Lead_Owner_Change_Date__c!= NULL AND OwnerId != :queueId) ';
                        
                       
                       // ' AND ID=\'00Q2F00000281tC\'';
         if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
         }
        return Database.getQueryLocator(query);
        
        
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        
        List<lead> leadstoUpdate   = new List<lead>();
        Timezone tz = Timezone.getTimeZone('America/New_York');
        for(Lead l : leadList){
            //converting lead owner change date to pst and finding the difference
           
            DateTime difference = BusinessHours.add(businesshoursId,l.Lead_Owner_Change_Date__c, 7200000 );
            system.debug('@@@@@difference'+difference);
            dateTime differencepst = DateTime.newInstance(difference.getTime() + tz.getOffset(difference));
            system.debug('@@@@differencepst'+differencepst);
           
            DateTime currentTimePst =  DateTime.newInstance(system.now().getTime() + tz.getOffset(system.now()));
            system.debug('@@@@currentTimePst'+currentTimePst);
            
            If(differencepst <= currentTimePst && !ownerstoAssignMap.isEmpty()){
                
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
                /*
                Integer num;
                if(l.Lead_Owner_Number__c == 6){
                    num = 1;
                }
                else{
                    num = Integer.valueOf(l.Lead_Owner_Number__c)+ 1;
                }
                system.debug('@@@@@ num'+ num);
                If(Lead_Assignment_users__c.getValues(string.valueOf(num)).User_Id__c != NULL){
                    l.OwnerId  = Lead_Assignment_users__c.getValues(string.valueof(num)).User_Id__c;
                    system.debug('@@@l ownerId'+ l.ownerId);
                    l.Lead_Owner_Number__c = num;
                    leadstoUpdate.add(l);
                }*/
            }
            
        }
        
        If(!leadstoUpdate.isEmpty()){
            update leadstoUpdate;
        }
        
    }
    
     global void finish(Database.BatchableContext BC) {
        
    }
    
     global void execute(SchedulableContext sc) {
        LeadAssinmentBatch LeadAssinmentBatchsch = new LeadAssinmentBatch();
        Database.executebatch(LeadAssinmentBatchsch);
    } 
    
    
}