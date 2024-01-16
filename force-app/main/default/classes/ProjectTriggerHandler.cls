public class ProjectTriggerHandler {
    
    public static Boolean projectAfterUpdateRecurstion = True;
    
    /************************************************************************
     * Description      :  when owner changes on project and the user is in project manager queue
     *                     then we need to change the ownership of milestones and projects as well
     * *********************************************************************/
    
    public static void ownershipassignment(Map<id,Milestone1_Project__c> newMap , Map<Id,Milestone1_Project__c> oldMap ){
          system.debug('@@@@ In ownershipassignment');
        
        Map<Id,Id> updatedProjects   = new Map<Id,Id>();
        Set<Id> validowners          = new Set<Id>();
        List<Sobject> recordstoUpdate = new List<Sobject>();        
        List<Id> seoQOwners = new List<Id>();
        Set<Id> projQOwners = new Set<Id>();
        //checking for owner change here
        for(Milestone1_Project__c project : newMap.values()){
            if(project.ownerId != NULL && (project.ownerId != oldMap.get(project.id).ownerId)
               && oldMap.get(project.id).ownerId != NULL){
                   updatedProjects.put(project.id,project.OwnerId);
                   projQOwners.add(project.OwnerId);
               }
        }
        
        if(!updatedProjects.isEmpty()){
            
            //checking if the changed owners are in Project manger queue or not
            for(GroupMember gm :[SELECT UserOrGroupId, Group.Name, Group.DeveloperName
                                       FROM GroupMember 
                                         //WHERE UserOrGroupId IN: updatedProjects.values() 
                                              WHERE Group.Type = 'Queue']){
                //AND Group.DeveloperName = 'MS_Project_Manager']){
                    if(gm.Group.DeveloperName == 'MS_Project_Manager' && projQOwners.contains(gm.UserOrGroupId)){
                        validowners.add(gm.UserOrGroupId);
                    }
                    if(gm.Group.DeveloperName == 'MS_SEO_Strategist'){
                        seoQOwners.add(gm.UserOrGroupId);
                    }
                }
                system.debug('==validowners=='+validowners);
                system.debug('==seoQOwners=='+seoQOwners);
            List<String> seoUserNames = new List<String>();
            List<User> seoUsers = [select id, name from User where Id IN: seoQOwners];
            for(User su: seoUsers){
                seoUserNames.add(su.name);
            }
            system.debug('==seoUserNames=='+seoUserNames);
            // if valid onwers found then updating milestones here
            if(!validowners.isEmpty()){
                for(Milestone1_Milestone__c milestone : [select id,Name,ownerId,Project__c,Status__c,
                                                               (select id,Name ,Assigned_Onwer__c,Task_Stage__c , assign_To_Type__c,Assigned_To__c,Project_Milestone__r.Name,Assigned_To_custom__c from Project_Tasks__r 
                                                               where Task_Stage__c != 'Completed' AND Task_Stage__c != 'Not Required') 
                                                               From Milestone1_Milestone__c
                                                         where Project__c IN:updatedProjects.keySet() AND Status__c != 'Cancelled' AND Status__c != 'Completed' AND Status__c != 'Not Needed']){
                      if(updatedProjects.containsKey(milestone.Project__c) && validowners.contains(updatedProjects.get(milestone.Project__c)) 
                      //&&  validowners.contains(milestone.ownerId)
                      ){
                            if(!milestone.Name.contains('SEO')){
                                system.debug('==seo=='+milestone.Name.contains('SEO'));
                                milestone.OwnerId   =  updatedProjects.get(milestone.Project__c); 
                                system.debug('@@@@milestone owner id'+ milestone.OwnerId);
                                recordstoUpdate.add(milestone);
                            
                            }
                          for(Milestone1_Task__c milestonetask : milestone.Project_Tasks__r){
                              system.debug('==milestonetask.Assigned_Onwer__c=='+milestonetask.Assigned_Onwer__c);
                              if((milestonetask.assign_To_Type__c  == 'User' && !seoUserNames.contains(milestonetask.Assigned_Onwer__c)) //!milestonetask.Project_Milestone__r.Name.contains('SEO')) 
                                        || (milestonetask.assign_To_Type__c  == 'Queue' && milestonetask.Assigned_Onwer__c  == 'MS - Project Manager') ){
                                      milestonetask.assign_To_Type__c  = 'User';
                                      milestonetask.Assigned_Onwer__c  = updatedProjects.get(milestone.Project__c);
                                      recordstoUpdate.add(milestonetask);
                              }
                          }
                      }                                             
                }
            }
        }
        
        if(!recordstoUpdate.isEmpty()){
            recordstoUpdate.sort();
            try{
                system.debug('@@@@@recordstoUpdate'+recordstoUpdate);
                update recordstoUpdate;
                
            }
            catch(exception ex){
                system.debug('@@@ exception '+ex);
            }
            
        }
        
    }
    
    public static void handleCancelProject(Map<id,Milestone1_Project__c> newMap, Map<id,Milestone1_Project__c> oldMap){
        
        Set<Id> projIds = new Set<Id>();
        //List<Milestone1_Project__c> CancellPrjIds = new List<Milestone1_Project__c>();
        List<SObject> updateCancelList = new List<SObject>();
        List<Milestone1_Project__c> cancelProjList = new List<Milestone1_Project__c>();
        
        id cancelProjectrecordTypeId = Schema.SObjectType.Milestone1_Project__c.RecordTypeInfosByName.get('Cancel Project').RecordTypeId ;
        id cancelMilestonRecTypId = Schema.SObjectType.Milestone1_Milestone__c.RecordTypeInfosByName.get('Cancel project Milestone').RecordTypeId ;
        id cancelTaskRecTypId = Schema.SObjectType.Milestone1_Task__c.RecordTypeInfosByName.get('Cancel Project Task').RecordTypeId ;
        
        for(Milestone1_Project__c pro : newMap.values()) {
            if(pro.Status__c == 'Cancelled' && oldmap.get(pro.Id).Status__c!= newMap.get(pro.Id).Status__c){ //&& pro.Order_Rate_Plan_Charge__c == NULL){ //changed by saiv MHBS-3761
                cancelProjList.add(pro);        
            }    
        }
        if(!cancelProjList.isEmpty()){
        List<Milestone1_Milestone__c> cancelMilestonelist = [SELECT Id,
                Name,
                Project__c,Status__c,
                Parent_Milestone__c,
                Complete__c,
                Deadline__c,
                Total_Actual_Hours__c From Milestone1_Milestone__c Where Status__c!='Cancelled' AND Status__c!='Completed' and Project__c in:cancelProjList];
            
            
            for(Milestone1_Project__c prj: cancelProjList){
                projIds.add(prj.id);
                //CancellPrjIds.add(prj);

                System.debug('======prj.Project_Milestones__r.size()======'+prj.Project_Milestones__r.size());
                System.debug('======cancelMilestonelist======'+cancelMilestonelist);
            }
            
            
            if(!cancelMilestonelist.isEmpty()){
                    for(Milestone1_Milestone__c canmil : cancelMilestonelist){
                        canmil.Status__c = 'Cancelled';
                        canmil.RecordTypeId = cancelMilestonRecTypId;
                    }
                    update cancelMilestonelist;
            }
            List<Milestone1_Task__c> cancelTaskList = [select id,Task_Stage__c,ProjectId__c
                                                       from Milestone1_Task__c WHERE Task_Stage__c!= 'Cancelled' AND Task_Stage__c!= 'Completed' AND Task_Stage__c!= 'Not Required' AND Project_ID__c IN:projIds];
            
            System.debug('==========cancelTaskList==========='+cancelTaskList);
            if(!cancelTaskList.isEmpty()){
                for(Milestone1_Task__c cancelTask : cancelTaskList){
                    canceltask.Task_Stage__c = 'Cancelled';
                    canceltask.RecordTypeId = cancelTaskRecTypId;
                }
                update cancelTaskList;
            }
            
            List<Milestone1_Project__c> CancellPrjIds = [Select id, name From Milestone1_Project__c where id in:projIds];
            for(Milestone1_Project__c cancelprj: CancellPrjIds){
                    cancelprj.Status__c = 'Cancelled';
                    cancelprj.AllmilestoneCancelled__c = True;
                    cancelprj.RecordTypeId = cancelProjectrecordTypeId;
                    //https://cs97.salesforce.com/a2j0U0000004LifQAE
                }
            
            if(!CancellPrjIds.isEmpty()){ 
                update CancellPrjIds;
            }
        }
        
    }
    
   public static void updateProjectDeadline(Map<id,Milestone1_Project__c >newMap, Map<id,Milestone1_Project__c >oldMap){
    
        system.debug('@@@In updatePrjectDeadline');
        Set<Id> projectIds                           =  new Set<Id>();
        String businessHoursId                                  = Label.BusinessHoursId;
        List<Milestone1_Project__c> projectstoUpdate = new  List<Milestone1_Project__c>();
        for(Milestone1_Project__c pm: newMap.values()){
            if((pm.Status__c == 'In Progress'||pm.Status__c == 'Optimization') && pm.Status__c != oldMap.get(pm.id).Status__c && pm.Kickoff_date__c == Null ){
                projectIds.add(pm.id);
            }
            
         }
            
          if(!projectIds.isEmpty()){
          
             for(Milestone1_Project__c pro: [select id,Status__c,Kickoff_date__c, Deadline_Date__c, Deadline_Check__c, Total_Hours_Estimate__c from Milestone1_Project__c 
                                                        where Id IN:projectIds]){
                                                        
              Decimal totalhours= pro.Total_Hours_Estimate__c  ;                                          
              //converting duration to minutes
              String tot= string.valueof(totalhours);

              List<String> stlist = tot.split('\\.');
              system.debug('@@@@ total stlist'+stlist);
              Integer mins = 0;
              for(Integer i=0; i <stlist.size(); i++){
                  if(i == 0){
                    mins += Integer.valueOf(stlist[0])*60;
                }
                else{
                    mins+= Integer.valueOf(Integer.valueOf(stlist[1]) *(0.6));
                }
              }
              system.debug('@@@@ total mins'+ mins);
              
                        
              datetime startDateTime = datetime.now();
              pro.Kickoff_date__c = startDateTime ;
              pro.Deadline_Date__c =  startDateTime;    
              long x = mins;                                              
             if(mins > 35000){
                 long i = 35000;
                 long remaining = 0;
                while(i <= mins){
                    pro.Deadline_Date__c = BusinessHours.add(businessHoursId,pro.Deadline_Date__c , 35000*60000 ); 
                    system.debug('@@@ for loop deadline'+ pro.Deadline_Date__c );
                    i = i+35000;
                    system.debug('@@@@i'+ i);
                    x= x-35000;
                    remaining = x;
                    system.debug('@@@@reaminging'+remaining);
                }
                if(remaining > 0 && remaining < 35000){
                    pro.Deadline_Date__c = BusinessHours.add(businessHoursId,pro.Deadline_Date__c , remaining*60000 ); 
                }
             }
             else{
                  pro.Deadline_Date__c = BusinessHours.add(businessHoursId,startDateTime, mins*60000 );                                                 
             }                                               
                                                            
                                                            
              
              pro.Deadline_Check__c = TRUE;
              System.debug('@@@@@@@pro.Kickoff_date__c '+pro.Kickoff_date__c );
              System.debug('@@@@@@@pro.Deadline_Date__c '+pro.Deadline_Date__c );                                              
              projectstoUpdate.add(pro);
              }     
          
          } 
          
           if(!projectstoUpdate.isEmpty()){
                update projectstoUpdate;
          }
                     
    }
    //rep boost project creation update when seo is active on same account MHBS-3568
    public static void checkExistingSEOonAccount(List<Milestone1_Project__c> Projects){
        List<Id> accountId = new List<Id>();
        List<Milestone1_Project__c> existingSEOProj = new List<Milestone1_Project__c>();
        Set<String> SEOProj = new Set<String>();
        List<Milestone1_Milestone__c > getMilestonesFromProject = new List<Milestone1_Milestone__c >();
        List<Milestone1_Milestone__c > MilestonesStatusUpdate = new List<Milestone1_Milestone__c >();
        List<Milestone1_Project__c > ProjectStatusUpdate = new List<Milestone1_Project__c >();
        Set<Id> UpdatedProjId = new Set<Id>();
        List<Product_code_to_Project_Mapping__c> projList = Product_code_to_Project_Mapping__c.getAll().values();
        
        System.debug('@@@@projList'+projList);
        
        for(Product_code_to_Project_Mapping__c prj: projList ){
            if(prj.IsSEO__c == TRUE){
                SEOProj.add(prj.Label__c);
            }
            if(prj.IsRepBoost__c == TRUE){
                SEOProj.add(prj.Label__c);
            }
        }
        system.debug('==SEOProj=='+SEOProj);
        system.debug('===allProject==='+Projects);
        for(Milestone1_Project__c rb: Projects){
            accountId.add(rb.Account__c);
        }
        
        if(!SEOProj.isEmpty()){
            existingSEOProj = [select id,Account__c, Name, Order__c, Order_Rate_Plan_Charge__c, RepBoostCreatedwSEO__c, Status__c, RecordTypeId, RecordType.Createddate FROM Milestone1_Project__c WHERE Account__c IN:accountId
                                   AND Name in: seoProj AND (Status__c='Optimization' OR Status__c='In Progress' OR Status__c='New') ORDER BY RecordType.Createddate];
            //system.debug('===existingSEOProj==='+existingSEOProj);
            Boolean accountContainsSEO;
            for(Milestone1_Project__c proj: existingSEOProj){
                if(proj.Name.contains('SEO')){ //|| proj.Name=='Web Gold' || proj.Name=='Web Platinum'){
                    accountContainsSEO = TRUE;
                }
                //system.debug('==accountContainsSEO=='+accountContainsSEO);
                if(proj.Name.contains('Reputation_Boost') && accountContainsSEO == TRUE && proj.Status__c == 'New'){ //added for MHBS-4371
                    //system.debug('==in if==');
                    proj.Status__c = 'In Progress';
                    proj.RepBoostCreatedwSEO__c = TRUE;
                    ProjectStatusUpdate.add(proj);
                }
            }
        }
        system.debug('===ProjectStatusUpdate==='+ProjectStatusUpdate);
        if(!ProjectStatusUpdate.isEmpty()){
            update ProjectStatusUpdate;
        } 
    }
}