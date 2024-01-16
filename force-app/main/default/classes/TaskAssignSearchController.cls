public with sharing class TaskAssignSearchController{
    
    public List<User> usersList{get;set;} // search results
    public List<Group>queuesList{get;set;}
    public string searchString{get;set;} // search keyword
    public string errormessage;
    public String userOrQueue{get;set;}
    
    public TaskAssignSearchController() {
        errormessage = 'Please enter at least three characters to search for User or Queue.  You can search by Name:'+'<br/>';
       
        
        // get the current search string
        
        searchString = System.currentPageReference().getParameters().get('lksrch');
        userOrQueue = System.currentPageReference().getParameters().get('u');
        if(searchString.length() > 2)
            runSearch();
        else
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errormessage));
    }
    
    // performs the keyword search
    public PageReference search() {
        usersList = new List<User>();
        queuesList = new List<Group>();
        if(searchString.length() > 2)
            runSearch();
        else
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errormessage));
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        if(userOrQueue == 'True'){
            usersList = performSearchForUsers(searchString);
        }
        else if(userOrQueue == 'false'){
            queuesList = performSearchforQueue(searchString);
        }
           
    } 
    
    // run the search and return the records found. 
    private List<Group> performSearchforQueue(string searchString) {
        
        String soql = 'Select Id,Name from Group Where type = \'Queue\'';
        if(searchString != '' && searchString != null){
            soql = soql +' AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
         }
        system.debug('@@@@query'+ soql);
        return database.query(soql); 
    }
    
    
     // run the search and return the records found. 
    private List<user> performSearchForUsers(string searchString) {
        
        String soql = 'Select Id, Name from User';
        if(searchString != '' && searchString != null){
            soql = soql +' where Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\' LIMIT 100';
         }
        system.debug('@@@@query'+ soql);
        return database.query(soql); 
    }
    
    
    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
}