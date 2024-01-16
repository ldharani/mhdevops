/***********************************************************************************
 * Author        : Sai
 * Description   : when all milestones are Completed, Not Needed, Cancelled update project
 *                 to Completed status
 * Created Date  : 20/07/2017
 * ***********************************************************************************/

public class MileStoneTriggerHandler {
    public static boolean milestoneBeforeUpdateRecursion = True;
    public static boolean milestoneAfterUpdateRecursion = True;
    public static boolean handleprojectStatusRecursion   = True;
    
    public static void handleProjectStatus(Map<id,Milestone1_Milestone__c >newMap, Map<id,Milestone1_Milestone__c >oldMap){
        
        system.debug('@@@In handleProjectStatus');
        Set<Id> projectIds                           =  new Set<Id>();
        List<Milestone1_Project__c> projectstoUpdate = new  List<Milestone1_Project__c>();
        for(Milestone1_Milestone__c ms : newMap.values()){
            system.debug('@@@@ms status'+ms.Status__c );
            system.debug('@@@@oldMap.get(ms.id).Status__c'+oldMap.get(ms.id).Status__c );
            if((ms.Status__c == 'Completed' || ms.Status__c == 'Not Needed' || ms.Status__c == 'Cancelled') && ms.Status__c != oldMap.get(ms.id).Status__c){
                projectIds.add(ms.Project__c);
            }
        }
        system.debug('@@@@projectIds'+projectIds);
        if(!projectIds.isEmpty()){
            for(Milestone1_Project__c mp : [select id,Status__c,IsMilestones_Completed__c,Created_from_Case__c, IsOrderRPCNull__c , (select id,Status__c from Project_Milestones__r 
                                                               where Status__c NOT IN ('Completed','Not Needed','Cancelled'))
                                                    from Milestone1_Project__c 
                                                        where Id IN:projectIds]){
                         system.debug('@@@@mp'+ mp.Project_Milestones__r);                                   
                         if(mp.Project_Milestones__r.isEmpty()){
                            //mp.Status__c                 = 'Completed'; 
                            //if(mp.IsOrderRPCNull__c == FALSE || mp.Created_from_Case__c == TRUE){
                                system.debug('in if milstn');
                                mp.IsMilestones_Completed__c  = true; 
                            //} //commented by saiv MHBS-6127
                            projectstoUpdate.add(mp); 
                         }                                        
                                                            
              }
        }
        
        
        if(!projectstoUpdate.isEmpty()){
            system.debug('@@@@ in Update');
            handleprojectStatusRecursion = false;
            update projectstoUpdate;
        }
        
        
    }
    
 

}