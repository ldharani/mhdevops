public class atRiskOnAccount{

    public static boolean validateRiskActivityRecursion = true;
    public static void validateRiskActivity(list<account> acclist, map<id,account>oldmap, map<id,account>newmap){
         
        Set<Id> accountIds = new Set<Id>();
        Set<Id> UserIds = new Set<Id>();
        List<Task> taskListOnAccount = new List<Task>();
        List<Milestone1_Project__c> listSEOProjects = new List<Milestone1_Project__c>();
        Date thirtyDaysFromToday = Date.Today().addDays(-30);
        
        Set<String> seoProj = new Set<String>();
        //seoProj.add('SEO_Gold');
        //seoProj.add('SEO_Local_Boost');
        //seoProj.add('Content_SEO_Onsite_Blog');
        //seoProj.add('Content (SEO Press Release)');
        //seoProj.add('Content_w_SEO_PostLaunch');
        //seoProj.add('SEO_Gold');
        //seoProj.add('SEO_Platinum');
        //seoProj.add('SEO_Local_Boost');
        
        List<Product_code_to_Project_Mapping__c> projList = Product_code_to_Project_Mapping__c.getAll().values();
        System.debug('@@@@projList'+projList);
        
        for(Product_code_to_Project_Mapping__c prj: projList ){
            if(prj.IsSEO__c == TRUE){
                seoProj.add(prj.Label__c);
            }
        }
        System.debug('@@@@seoProj'+seoProj);
        System.debug('@@@@@@@@thirtyDaysFromToday '+thirtyDaysFromToday );
        
        for(Account acc: acclist){
            System.debug('@@@@@@acc.Is_Account_At_Risk__c'+newmap.get(acc.id).Is_Account_At_Risk__c);
            System.debug('@@@@Old Value '+oldmap.get(acc.id).Is_Account_At_Risk__c);
            if(newmap.get(acc.id).Is_Account_At_Risk__c == TRUE && oldmap.get(acc.id).Is_Account_At_Risk__c!= newmap.get(acc.id).Is_Account_At_Risk__c ){
                accountIds.add(acc.id);
            }
            else if(newmap.get(acc.id).Is_Account_At_Risk__c == False && oldmap.get(acc.id).Is_Account_At_Risk__c!= newmap.get(acc.id).Is_Account_At_Risk__c ){
                //atRiskFalseAccountIds.add(acc.Id);
            }    
        }
        
        System.debug('@@@@@@accountIds'+accountIds);
        
        if(!accountIds.isempty() && accountIds!=NULL){
            
            List<GroupMember> gmList = [Select UserOrGroupId,GroupId From GroupMember where GroupId = '00G0G0000077HB8'];
            
            System.debug('Group members======'+gmList );
            
            if(gmList.isempty() || gmList!=NULL){
                for(GroupMember g : gmList){
                    UserIds.add(g.UserOrGroupId); 
                }    
            }
            
            System.debug('@@@@User Ids'+UserIds);
            if(!UserIds.isempty() || UserIds!=NULL){
                taskListOnAccount = [Select id, WhoId, WhatId, AccountId, createdDate From Task Where AccountId in: accountIds AND CreatedDate >=: thirtyDaysFromToday AND CreatedById in: UserIds];        
            }
            
            System.debug('@@@@@@SEO List'+seoProj );
            listSEOProjects = [Select id, name From Milestone1_Project__c Where Account__c in :accountIds AND Name in: seoProj /*LIKE '%SEO%' Name in: seoProj*/ AND (Status__c='Optimization' OR Status__c='In Progress' OR Status__c='Completed') ]; 
            System.debug('=========SEO Projects'+listSEOProjects );
            
            for(Account acc: accList){  
                if(taskListOnAccount.isempty() || taskListOnAccount == NULL){
                    trigger.newMap.get(acc.id).addError('There has been no account activity in the past month, can not proceed.');
                }
                else if(listSEOProjects.isempty() || listSEOProjects == NULL){
                    trigger.newMap.get(acc.id).addError('There is no active SEO Project on the account');
                }
             }
         } 
             
         
        
         System.debug('@@@TaskListOnAccount'+taskListOnAccount );
    }
}