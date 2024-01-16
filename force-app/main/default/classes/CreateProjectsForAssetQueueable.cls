// Author       : SaiV
// Date         : 09/20/2021
// Descritption : to work release Inventory concept both in trigger as well as batch class

public class CreateProjectsForAssetQueueable implements Queueable, Database.AllowsCallouts {
    
    public Set<Id> setOppchargeIdsque{get;set;}
    
    //constructor
    public CreateProjectsForAssetQueueable(Set<Id> setOppchargeIds){
        
        this.setOppchargeIdsque            = setOppchargeIds;
       
    }
    
    public void execute(QueueableContext context) {
         //MileStoneHandler.createProjects(setOppchargeIdsque);  
         CPQ_MilestoneHandler_Assets.CPQ_createProjectsForAssets(setOppchargeIdsque); 
    }
}