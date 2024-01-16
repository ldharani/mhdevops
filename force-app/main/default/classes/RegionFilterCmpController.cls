public class RegionFilterCmpController {

    @AuraEnabled
    public static List<String> getStateList(){
        List<String> StateList = new List<String>();
        for(AggregateResult ar : [Select AOP_Name__c from GEO_Location__c group by AOP_Name__c]){
            StateList.add((String)ar.get('AOP_Name__c'));
        }
        return StateList;
    }
}