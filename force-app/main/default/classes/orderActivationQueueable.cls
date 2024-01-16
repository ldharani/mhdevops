/*Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/
public class orderActivationQueueable implements Queueable, Database.AllowsCallouts{
    public Set<Id> setquoteIds2{get;set;}
	public orderActivationQueueable(Set<Id> setquoteIds){
        this.setquoteIds2 = setquoteIds;
    }
    public void execute(QueueableContext context) {
        quoteHandler.activateOrderfromQuote(setquoteIds2);
    }
}