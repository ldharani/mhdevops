public class MilestoneTaskHandler {
    
    public static Boolean TaskAfterUpdateRecurstion = True;
    public static Boolean taskBeforeUpdateRecursion = True;

    public static void getUserOrQueueName(List<Milestone1_Task__c > mtasksList, Map<id,Milestone1_Task__c >oldMap){
        
        Set<string> userIds         = new set<string>();
        Set<string> queueIds         = new set<string>();
        Map<id,User>usersMap        =  new Map<id,User>();
        Map<id,Group>queuesMap      = new Map<id,Group>();
        for(Milestone1_Task__c  mtask : mtasksList){
            System.debug('======================================'+oldMap);
            
                if(trigger.isInsert || (trigger.isUpdate &&
                                    mtask.Assigned_Onwer__c !=  oldMap.get(mtask.id).Assigned_Onwer__c)){
                                    
                       if(mtask.assign_To_Type__c == 'User'){
                              userIds.add(mtask.Assigned_Onwer__c);                   
                       } 
                       else if(mtask.assign_To_Type__c == 'Queue'){
                             queueIds.add(mtask.Assigned_Onwer__c);                    
                       }                  
            }
            
            
        }
        System.debug('=================userIds====================='+userIds);
        if(!userIds.isEmpty()){
            usersMap = new Map<id,user>([select id,Name from user 
                                                where id in:userIds]);
        }
        
        if(!queueIds.isEmpty()){
            queuesMap = new Map<id,Group>([select id,name from Group
                                                   where id in:queueIds]);
        }
        
        for(Milestone1_Task__c  mtask : mtasksList){
            
            if(mtask.assign_To_Type__c == 'User' && !userIds.isEmpty()){
                if(usersMap.containsKey(mtask.Assigned_Onwer__c)){
                    mtask.Assigned_Onwer__c = usersMap.get(mtask.Assigned_Onwer__c).Name;
                }
                
            }
            else if(mtask.assign_To_Type__c == 'Queue' && !queueIds.isEmpty()){
                if(queuesMap.containsKey(mtask.Assigned_Onwer__c)){
                    mtask.Assigned_Onwer__c = queuesMap.get(mtask.Assigned_Onwer__c).Name;
                }
            }
        }
        
    }
    
    /**********************************************************************************
     * To Update start date and due dates when stage = ready to start
     * *************************************************************************************/
    
     public static void updateTaskDeadline(Map<id,Milestone1_Task__c >newMap, Map<id,Milestone1_Task__c >oldMap){
     
      system.debug('@@@In updateTaskDeadline');
        
        String businessHoursId                    = Label.BusinessHoursId;
        List<Milestone1_Task__c > taskstoUpdate = new  List<Milestone1_Task__c >();
        for(Milestone1_Task__c milestonetask : newMap.values()){
             /*system.debug('@@@@@@milestonetask.Task_Stage__c'+milestonetask.Task_Stage__c);
             system.debug('@@@@@@milestonetask.Started_date__c'+milestonetask.Started_date__c);
             system.debug('@@@@@@milestonetask.Dued_date__c'+milestonetask.Dued_date__c);*/
            if((milestonetask.Task_Stage__c != 'Completed' &&  milestonetask.Task_Stage__c != 'Not Required' &&  milestonetask.Task_Stage__c != 'Not Started'
                 && milestonetask.Started_date__c == NULL && milestonetask.Dued_date__c == NULL)
                || (milestonetask.Task_Stage__c == 'Ready to Start' && milestonetask.Task_Stage__c != oldMap.get(milestonetask.id).Task_Stage__c && milestonetask.Dued_date__c == Null)){ //added or statement for MHBS-8341
                milestonetask.Started_date__c = system.now();
                string duration = string.valueOf(milestonetask.Estimated_Hours__c);
                if(duration != NULL){
                List<String> stlist = duration.split('\\.');
                Integer mins= 0;
                 for(Integer i=0; i <stlist.size(); i++){
                     if(i == 0){
                         mins += Integer.valueOf(stlist[0])*60;
                     }
                    else{
                         mins+= Integer.valueOf(Integer.valueOf(stlist[1]) *(0.6));
                    }
                }
                
                milestonetask.Dued_date__c = BusinessHours.add(businessHoursId,milestonetask.Started_date__c, mins*60000 );  
              }      
            }
            
         }
         
        
          
          
        }
}