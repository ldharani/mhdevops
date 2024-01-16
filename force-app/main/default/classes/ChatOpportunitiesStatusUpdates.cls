public class ChatOpportunitiesStatusUpdates {
    
     @InvocableMethod 
    public static void childoptiesStatusUpdate(List<ID> oppIds) {
        system.debug('@@@@invocable method calling');
      // updatechildopps(oppIds);
      system.enqueueJob(new chatOpportunitiesQueueable(oppIds));
    }
    
    
    public static void updatechildopps(List<ID> oppIds){
        List<Opportunity> opplist = new List<Opportunity>(); 
        for(Opportunity opp: [select id, Name,Parent_Opportunity__r.stageName, Parent_Stage_Change__c,stageName from opportunity
                                               where Parent_Opportunity__c IN: oppIds AND stageName != 'Closed Lost'
                              AND Parent_Opportunity__c != NULL]){
            system.debug('@@@in closed won'+ opp);                      
          //If( opp.StageName == 'QA Review'|| opp.StageName =='QA Rejected'||opp.StageName == 'Closed Won')
            opp.StageName = opp.Parent_Opportunity__r.stageName;
            opp.Parent_Stage_Change__c = system.now(); 
            opp.IsUpsellOppty__c = True;                    
           // opp.StageName = 'Closed Won';  
            opplist.add(opp);
                                  
         }
        if(!opplist.isEmpty()){
             update opplist;
        }
       
        
    }

}