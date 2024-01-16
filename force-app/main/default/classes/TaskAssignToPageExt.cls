public class TaskAssignToPageExt {
    
    public string selectedownertype    {get;set;}
    public Milestone1_Task__c mtask {get;set;}
    public string previousOwner;
    
    public TaskAssignToPageExt(ApexPages.StandardController controller){
        
       mtask = (Milestone1_Task__c)controller.getRecord();
       mtask = [select id, Name, Assigned_Onwer__c,Assigned_To__c,
                      assign_To_Type__c
                      From Milestone1_Task__c
                      where id=: mtask.id];
        previousOwner = mtask.Assigned_To__c;
        
    }
    
    public list<SelectOption> getownerTypes(){
        list<SelectOption> options = new list<SelectOption>();
         // Fetch options for the owner types filter dynamically.
         Schema.DescribeFieldResult fieldResult = Milestone1_Task__c.assign_To_Type__c.getDescribe();
         list<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        
         

         //Reading from the object definition to allow dynamic values to be added later        
         for(Schema.PicklistEntry pickVal : picklistValues){
             options.add(new SelectOption(pickVal.getLabel(), pickVal.getValue()));
         } 
         return options;
     }
    
    public pageReference Save(){
        
        PageReference pageRef;
        mtask.Assigned_Onwer__c  = mtask.Assigned_To__c;
        mtask.Assigned_To__c     = previousOwner;
        mtask.assign_To_Type__c = selectedownertype;
        update mtask;
        pageRef = new PageReference('/'+mtask.id);
        
        return pageRef;
        
    }

}