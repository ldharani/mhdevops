//:sai
public class OpportunityValidation {
    //this methods check for validation that
    //when opportunity change its status QA review and any of inventory Products doesn't have inventory ID's
    public static void checkforInventoryIds(List<opportunity> opplist, map<id,Opportunity> newmap, map<id,Opportunity> oldmap){
        system.debug('@@@ in checkforInventoryIds');
        
        boolean checkFlagforProfile = true;
        
        List<opportunity> opplistwithInvProducts = [select id,StageName,  
                                                    (select id,InventoryId__c, Name, IsInventoried__c
                                                       from invoiceit_crmx__Opportunity_Products__r
                                                         where IsInventoried__c = 'true')
                                                    from opportunity
                                                     where id IN:(newmap.keySet())];
        
        if(!opplistwithInvProducts.isEmpty() && opplistwithInvProducts !=null){
            for(opportunity opp : opplistwithInvProducts){
                
                if(newmap.get(opp.id).StageName != oldMap.get(opp.Id).StageName &&  newmap.get(opp.id).StageName== 'QA Review'){
                    for(invoiceit_crmx__Opportunity_Product__c oppPrdct : opp.invoiceit_crmx__Opportunity_Products__r){
                        if(oppPrdct.InventoryId__c == null){
                            system.debug('@@@ in inventory');
                            trigger.newMap.get(opp.id).addError('Opportunity cannot be  made QA Review since few Inventoried Products dont have Inventory Id');
                            
                        }
                    }
                }
                
                //else if(newmap.get(opp.id).StageName == oldMap.get(opp.Id).StageName &&
                  //      newmap.get(opp.id).StageName== 'QA Review'  && checkforProfile()){
                           // trigger.newMap.get(opp.id).addError('You do not have priveleges to modify this record in QA Review Stage contact your administrator');
                       // }
            }
        }
    }
    
    
    /*public static boolean checkforProfile(){
        system.debug('@@@in checkforProfile' );
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        
        if(profileName != 'System Administrator' && profileName != 'Fulfillment Ops Rep'){
            return true;
        }
        else{
            return false;
        }
    }*/
    
    // to change reviewer field to null and reviewer in progress to false every time when status changes
    public static void changereviewProgress(map<id,Opportunity> newmap, map<id,Opportunity> oldmap){
        
        system.debug('@@@in changereviewProgress');
        for(Opportunity opp: newmap.values()){
            if(newmap.get(opp.id).StageName != oldMap.get(opp.Id).StageName){
                newmap.get(opp.id).Reviewer__c = null;
                newmap.get(opp.id).Review_in_Progress__c = false;
                
            }
        }
    }

}