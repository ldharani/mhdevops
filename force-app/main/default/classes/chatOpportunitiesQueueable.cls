public class chatOpportunitiesQueueable implements Queueable, Database.AllowsCallouts {
    
    public List<Id> setOppIds{get;set;}
    
    public chatOpportunitiesQueueable(List<Id>oppIds){
        this.setOppIds = oppIds;
        
    }
    
    public void execute(QueueableContext context) {
        ChatOpportunitiesStatusUpdates.updatechildopps(setOppIds);
    }

}