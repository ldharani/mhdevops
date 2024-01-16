// Author       : Sai
// Date         : 27/11/2017
// Descritption : to work release Inventory concept both in trigger as well as batch class

public class CreateProjectsQueueable implements Queueable, Database.AllowsCallouts {
    
    public Set<Id> setOppchargeIdsque{get;set;}
    
    //constructor
    public CreateProjectsQueueable(Set<Id> setOppchargeIds){
        
        this.setOppchargeIdsque            = setOppchargeIds;
       
    }
    
    public void execute(QueueableContext context) {
         //MileStoneHandler.createProjects(setOppchargeIdsque);  
         CPQ_MilestoneHandler.CPQ_createProjects(setOppchargeIdsque); 
    }
}