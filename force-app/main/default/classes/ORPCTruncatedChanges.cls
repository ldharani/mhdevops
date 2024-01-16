/**********************************************************************************
 * Author      : Sai
 * Description : if any orpc removed while making closed won of opty making that order orcp status to truncated
 * Test Class  : ORPCTruncatedChangesTest
 * ********************************************************************************/


public class ORPCTruncatedChanges {

    
    public static void changeORPCTruncatedStatus(Map<id,Opportunity>oldMap, Map<id,Opportunity>newMap ){
        
        system.debug('@@@in changeORPCTruncatedStatus');        
        set<Id> OrderRpcSet     = new Set<Id>();
        Set<Id> oppidstoProcess = new Set<Id>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> OppRpcList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        Set<String> availableOppRPC = new Set<String>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> OrderRpcList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Date selectedDate =  Date.today(); //Give your date
        Date firstDate = selectedDate.toStartOfMonth();
        Date lastDateOfTheMonth = firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
        
        //checking for closed won here
        //forming created from order set to fetch Order Rate Plan charges
        for(Opportunity opp: newMap.values()){
            system.debug('@@@@oldMap.get(opp.id).StageName'+oldMap.get(opp.id).StageName);
            system.debug('@@@@newMap.get(opp.id).StageName'+newMap.get(opp.id).StageName);
            if(oldMap.get(opp.id).StageName != newMap.get(opp.id).stageName && newMap.get(opp.id).stageName == 'Closed Won'){
            
                    system.debug('@@@@ in if condition orpc');
                    oppidstoProcess.add(opp.id);
                if(opp.Created_From_Order__c != null){
                    OrderRpcSet.add(opp.Created_From_Order__c);
                }
                    
                        
            }
        }
        
        system.debug('@@@oppidstoProcess'+oppidstoProcess);
        system.debug('@@@OrderRpcSet'+OrderRpcSet);
        
        if(!oppidstoProcess.isEmpty() && !OrderRpcSet.isEmpty()){
            
            //get Opportunity Rate Plan Charges in the opportunity
            OppRpcList = [select id, Name,
                                 Created_From_Charge__c
                                 From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                                 where invoiceit_crmx__Opportunity__c IN:oppidstoProcess];
            system.debug('@@@OppRpcList'+OppRpcList);
            
            //forming a set of Order Rate Plan charges 
            if(!OppRpcList.isEmpty()){
                availableOppRPC = genericUtilityClass.formingsetIDsfromList(OppRpcList,'Created_From_Charge__c');
            }
            system.debug('@@@availableOppRPC'+availableOppRPC);
            //querying not available ORPC and udpate it
            for(invoiceit_s__Job_Rate_Plan_Charge__c orpc: [select id,Name,
                                                                   invoiceit_s__Status__c,Renewable__c,
                                                                    invoiceit_s__Order__c,invoiceit_s__Service_End_Date__c,RecordType.DeveloperName
                                                                   from invoiceit_s__Job_Rate_Plan_Charge__c
                                                                    where Id NOT IN:availableOppRPC
                                                                          AND invoiceit_s__Order__c IN:OrderRpcSet
                                                           AND invoiceit_s__Status__c != 'Cancelled' AND invoiceit_s__Status__c != 'Truncated' AND Renewable__c=TRUE
                                                           limit : Limits.getLimitQueryRows()]){
                      system.debug('@@@in for loop orpc');                                           
                      orpc.invoiceit_s__Status__c = 'Truncated';
                     if(orpc.RecordType.DeveloperName == 'M_NG_Order_Rate_Plan_Charge')
                      {
                      orpc.invoiceit_s__Service_End_Date__c = lastDateOfTheMonth;
                      }
                      OrderRpcList.add(orpc);                                          
                }
            
            
        }
        system.debug('@@@OrderRpcList'+OrderRpcList);   
        if(!OrderRpcList.isEmpty()){
            try{
                update OrderRpcList;
            }
            catch(exception ex){
                system.debug('@@@@@ exception'+ex);
            }
        }
        
        
    }
    
     
    



}