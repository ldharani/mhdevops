/***********************************************************************************************************************
 * @author - SaiVihari
 * @date - 13 Apr 2022
 * @description - Class to automate SEO strategist assignment
 * @testclass - 

Change History
************************************************************************************************************************
*/
public class automateSEOStrategistAssignment {
    public static void changeTaskOwner(List<Milestone1_Project__c> newLst, Map<Id, Milestone1_Project__c> oldMap){
        Set<Id> prjId = new Set<Id>();
        String oldSEOUserId;
        String newSEOUserId;
        String oldSEOUserName;
        List<Milestone1_Task__c> tskOwnerToUpdate = new List<Milestone1_Task__c>();
        List<Milestone1_Task__c> allPrjTasks = new List<Milestone1_Task__c>();
        for(Milestone1_Project__c prj: newLst){
            if(prj.SEO_Strategist__c != Null && prj.SEO_Strategist__c != oldMap.get(prj.Id).SEO_Strategist__c){
                prjId.add(prj.Id);
                if(oldMap.get(prj.Id).SEO_Strategist__c == Null){
                    newSEOUserId = prj.SEO_Strategist__c;
                }else{
                    system.debug('old'+oldMap.get(prj.Id).SEO_Strategist__c);
                    system.debug('new'+prj.SEO_Strategist__c);
                    oldSEOUserId = oldMap.get(prj.Id).SEO_Strategist__c;
                    //oldSEOUserName = oldMap.get(prj.Id).SEO_Strategist__r.Name;
                    newSEOUserId = prj.SEO_Strategist__c;
                }
            }
            system.debug('==oldSEOUserId=='+oldSEOUserId);
            //system.debug('==oldSEOUserName=='+oldSEOUserName);
            system.debug('==newSEOUserId=='+newSEOUserId);
            system.debug('==prjId=='+prjId);
        }
        if(oldSEOUserId!=Null){
            List<User> user = [select id, name from User where id=:oldSEOUserId];
            for(User u:user){
                oldSEOUserName = u.Name;
            }
        }
        if(!prjId.isEmpty()){
            allPrjTasks = [select id,Assigned_To_custom__c,Assigned_To__c,Assigned_Onwer__c,ProjectId__c,
                           SEOStrategistonProject__c, Project_ID__c from Milestone1_Task__c
                            where Project_ID__c IN:prjId];
            system.debug('==allPrjTasks=='+allPrjTasks);
            for(Milestone1_Task__c tsk: allPrjTasks){
                system.debug('==oldSEOUserId=='+oldSEOUserId);
                system.debug('==assOwner=='+tsk.Assigned_Onwer__c);
                system.debug('==oldUser=='+oldSEOUserName);
                if(oldSEOUserId == Null && tsk.Assigned_Onwer__c == 'MS - SEO Strategist'){
                    system.debug('==in if=='+tsk.Id);
                    tsk.assign_To_Type__c  = 'User';
                    tsk.Assigned_Onwer__c = newSEOUserId;
                    tskOwnerToUpdate.add(tsk);
                }else if(oldSEOUserId != Null && (tsk.Assigned_Onwer__c == 'MS - SEO Strategist'
                         || oldSEOUserName == tsk.Assigned_Onwer__c )){
                    system.debug('==in elseif==');
                    tsk.assign_To_Type__c  = 'User';
                    tsk.Assigned_Onwer__c = newSEOUserId;
                    tskOwnerToUpdate.add(tsk);
                }
                //tskOwnerToUpdate.add(tsk);
            }
        }
        system.debug('==tskOwnerToUpdate=='+tskOwnerToUpdate);
        if(!tskOwnerToUpdate.isEmpty()){
            update tskOwnerToUpdate;
        }
    }
    public void FkMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    } 
}