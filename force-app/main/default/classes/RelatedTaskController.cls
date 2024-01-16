public class RelatedTaskController {
 
    String currentRecordId;
    Public transient List<Task> TaskList{get;set;}
    public Account acc;
    public Account avvoParentAcc;
    public List<Contact> conList;
    Public transient List<Task> DisplayTaskList{get;set;}
    Public Set<String> objIds{get;set;}
    Public Set<String> taskIdsToDisplay {get;set;}
    public transient List<Task> fullTaskList {get;set;}
   
    private integer count=1;   //to track the function calling
    private integer counter=0;   //to keep track of offset
    private integer list_size=5; //to set the page size to show the rows/records
    public integer total_size; //used to show user the total size of the list
    
    private String soql {get;set;}
    
    // the current sort direction. defaults to asc
    public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
  
    // the current field to sort by. defaults to subject
    public String sortField {
        get  { if (sortField == null) {sortField = 'subject'; } return sortField;  }
        set;
    }
  
    public RelatedTaskController(ApexPages.StandardController controller) {
    
        DisplayTaskList = new List<Task>();
        conList = new List<Contact>();
        objIds = new Set<String>();
        taskIdsToDisplay  = new Set<String>();
        FullTaskList = new List<Task>();
        String accrecType;
        
        currentRecordId = ApexPages.CurrentPage().getparameters().get('id');
        
        System.debug('@current record id--->'+currentRecordId );
        acc = [Select Id, name,ParentId, RecordType.Name,(Select id, name From Opportunities) From Account Where id =: currentRecordId  LIMIT 1];

        
        System.debug('What is the parent Account id------------------'+acc.ParentId);
        if(acc.ParentId!=Null){
            conList = [Select id, name from Contact Where AccountId=: acc.ParentId];
        }
        
        if(acc!=NULL && acc.ParentId!=Null){
            //Including Avvo Accounts logic for getting the Avvo Account IB account ids
            /*avvoParentAcc = [Select id, name, ParentId,RecordType.Name From Account Where id =: acc.ParentId LIMIT 1];
            System.debug('@@@@@@@@@Avvo Parent Account Id----------->'+avvoParentAcc.ParentId);
            if(avvoParentAcc!=NULL && avvoParentAcc.ParentId!=NULL){
                objIds.add(avvoParentAcc.ParentId);
            }*/
            //End of Avvo related logic 
            objIds.add(acc.ParentId);
            objIds.add(acc.Id);
       }
        
        if(!acc.Opportunities.isempty()){
            for(Opportunity opp: acc.Opportunities){
                objIds.add(opp.id);
            }
        }
        if(!conList.isempty()){
            
            for(Contact c: conList){
                objIds.add(c.id);
            } 
        }
        
        System.debug('@@@@@@@Different object Ids----->'+objIds);
        //soql = 'Select subject,id,OwnerId,Type,WhatId, WhoId,ActivityDate,CreatedDate,Status,Priority,recordtype.name FROM Task WHERE Whatid in: objIds OR WhoId in: objIds';
        
        TaskList = [Select subject,id,OwnerId,Type,WhatId, WhoId,ActivityDate,CreatedDate,Status,Priority,recordtype.name,Recent_Task__c,Notes__c,Description FROM Task WHERE Whatid in: objIds OR WhoId in: objIds ORDER BY CreatedDate DESC]; 
        
        total_size= [select count() FROM Task WHERE Whatid in: objIds];  //set the total size in the constructor
        
        
       //Intializing set of task types
        Map<String, BU_Specific_Tasks_Mapping__mdt> taskTypeMap = new Map<String, BU_Specific_Tasks_Mapping__mdt>();
        
        
        
         for(BU_Specific_Tasks_Mapping__mdt tas: [select id, DeveloperName,MasterLabel,Account_Record_Type__c
                                        From BU_Specific_Tasks_Mapping__mdt where Account_Record_Type__c=: acc.RecordType.Name]){
             
             if(!taskTypeMap.containskey(tas.MasterLabel)){
                 taskTypeMap.put(tas.MasterLabel, tas);
             }
        }
        
        System.debug('tasksMap here'+taskTypeMap );
        
        if(!TaskList.isempty() && TaskList!=NULL){
            for(Task t: TaskList){
            
                System.debug('Task RT Name------>'+t.recordtype.name);
                
                if(taskTypeMap.containskey(t.recordtype.name)){
                    taskIdsToDisplay.add(t.id);
                    DisplayTaskList.add(t);
                    
                }
                System.debug('@@@@@@@displaying the tasks--------->'+displaytasklist);
            }
        }
        
        if(DisplayTaskList.size() == 0){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,''+'No Task to Display'));
        }
        runQuery();
    }
    
    // toggles the sorting of query from asc<-->desc
    public void toggleSort() {
        System.debug('@@@@@@@@@Inside Toogle Sort------>'+sortField );
    // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQuery();
    }
    
    // runs the actual query
    public void runQuery() {
        try {
        System.debug('@@@@@@@@sort Field logic---------->'+sortField);
        System.debug('@@@@@Sort Direction------>'+sortDir);
        System.debug('@@@@@@@@@@@@@@@taskIdsToDisplay '+taskIdsToDisplay );
        string sortFullExp = sortField + ' ' + sortDir;
        System.debug('@@@@@@@@@@@@@@@sortFullExp----->'+sortFullExp );
        System.debug('@@@@@Soql------->'+soql);
          //fullTaskList = Database.query(soql + ' order by ' + sortFullExp);

          fullTaskList = Database.query('Select subject,id,OwnerId,Type,WhatId, WhoId,ActivityDate,CreatedDate,Status,Priority,recordtype.name FROM Task WHERE Id=:taskIdsToDisplay ' + ' order by ' +sortFullExp);
          System.debug('FullTask List-------->'+fullTaskList);
          
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'));
        }
    }
  
    public PageReference gotoList() {    //user clicked the got to the list button
        counter += list_size;
        TaskList = DisplaytaskList; //[Select subject,id,OwnerId,Type,WhatId, WhoId,ActivityDate,CreatedDate,Status,Priority,recordtype.name FROM Task WHERE Whatid in: objIds Order By Subject Limit 5];
       
        PageReference pageRef = new PageReference('/apex/RelatedTaskListPage?id='+acc.Id);
        pageRef.setRedirect(true);
        return pageRef;

    }
      
    public PageReference viewAllActivity() {    //user clicked the got to the list button

        TaskList = DisplayTaskList; //[Select subject,id,OwnerId,Type,WhatId, WhoId,ActivityDate,CreatedDate,Status,Priority,recordtype.name FROM Task WHERE Whatid in: objIds Order By Subject Limit 5];
       
        PageReference pageRef = new PageReference('/apex/ViewAllActivityHistory?id='+acc.Id);
        pageRef.setRedirect(true);
        return pageRef;

    }
    
    public Pagereference Cancel()
    {  
        Pagereference pag =new Pagereference('/'+currentRecordId);
        return pag;  
    }

}