public class STOWDTriggerHandler {
    
    public static void assignfieldsfromuser(List<STOWD__Status_Ownership_Duration__c> stowdlist){
        
        system.debug('@@ in assignfieldsfromuser' + stowdlist);
        Set<String> userNames = new Set<String>();
        map<String, user> nameVsUserMap = new map<String, user>();
        
        userNames = genericUtilityClass.formingsetIDsfromList(stowdlist, 'STOWD__Owner__c');
        system.debug('@@@userNames'+ userNames);
        
        for(user u : [select id,Name, Division from user where Name IN:(userNames)]){
            nameVsUserMap.put(u.Name, u);
        }
        
        for(STOWD__Status_Ownership_Duration__c stowd : stowdlist){
            if(nameVsUserMap.size() > 0 && nameVsUserMap.containsKey(stowd.STOWD__Owner__c)){
                stowd.User__c = nameVsUserMap.get(stowd.STOWD__Owner__c).id;
            }
        }
        
        
    }

}