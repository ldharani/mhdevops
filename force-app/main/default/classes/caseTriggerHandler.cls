// Author      : akash
// Date        : 18/6/2016
// Description : making assignment rules DeActive in case of case Creating from 3rd party Integration


public class caseTriggerHandler {
    
    public static boolean caseRecursionAfterUpdate = true;
    public static boolean caseRecursionBeforeUpdate = true;    
    
    public static void inActiveAssignmentRules(list<case> caselist){
        system.debug('@@@ in inActiveAssignmentRules');
        
         Map<String,Id> queNameVsId = new Map<String,Id>();
        List<Group> queuesList     = [select id, Name
                                             from Group
                                             where Type='Queue'];
        for(Group gr : queuesList){
             queNameVsId.put(gr.Name,gr.id);   
        }
        
        list<case> assignmentRulesDeactiveCases = new list<case>();
        
        for(case cs: caselist){
            if(cs.origin == 'OrderUpdate'){
                if(cs.Description__c != null){
                    if(cs.Description__c.contains('STUB_ERR_001')){ 
                        cs.OwnerId  = queNameVsId.get('Fulfillment Operations');
                    }
                    else if(cs.Description__c.contains('STUB_ERR_002') || cs.Description__c.contains('STUB_ERR_003')){
                        cs.OwnerId  = queNameVsId.get('MH System Admin');
                    }
                    else if(cs.Description__c.contains('STUB_ERR_004')){
                        cs.OwnerId  = queNameVsId.get('Data Governor Queue');
                    }
                    else if(cs.Description__c.contains('400') || cs.Description__c.contains('500') || cs.Description__c.contains('20011:Error Code')){
                        cs.OwnerId  = queNameVsId.get('IT Queue');
                    }
                
                    else{
                        cs.OwnerId  = queNameVsId.get('Fulfillment Operations');
                    }    
           
                }
                
            }
            
           
         
        }
        
        //system.debug('@@@@assignmentRulesDeactiveCases'+assignmentRulesDeactiveCases);
        // Database.DMLOptions dmo = new Database.DMLOptions();
        //dmo.assignmentRuleHeader.useDefaultRule = true;
        //Database.update(assignmentRulesDeactiveCases, dmo);
        
       
        
       
        
    }

}