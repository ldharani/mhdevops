public with sharing class ClassForNavigation {
    public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOpptToDisplay;
    public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOpptRequested;  
    public Integer i {get; set;} // Here i point to the index (or) position of elements
    public Integer setPageSize; // No of records to display in page
    public integer size;
    
    
    public ClassForNavigation(list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>  listOfWrapper) { 
        listOpptToDisplay = listOfWrapper;
        // Were getting the value from custom settings, based on value we are displaying the records
        setPageSize =  integer.valueOf(invoiceit_s__Configuration__c.getValues('NAVIGATION FOR ATTRIBUTES').invoiceit_s__Number_Value__c);
        i = 0; 
        size = listOpptToDisplay.size();
    } 
    
     // Method will verify does it has next set of records
    public boolean hasNext(){ 
       if(i >= listOpptToDisplay.size()) {
           return false; 
       } else {
           return true; 
       }
   }
   
   // Method will verify does it has next set of records
   public boolean hasPrevious(){ 
       if(i <= setPageSize) {
           return false; 
       } else {
           return true; 
       }
   }  
   
   // This will display the last set of records
    public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> last(){
        size = listOpptToDisplay.size();
        i = size; 
        listOpptRequested = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>(); 
        
        integer max;

        if(i >= setPageSize) {
            max = i - setPageSize;
        } else {
            max = i;
        }
        
        for(integer start = max; start < i; ++start)
        {
           listOpptRequested.add(listOpptToDisplay[start]);
        }         

       return listOpptRequested;
    }
    
   // This will display the next set of records
   public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> next(){       
       size = listOpptToDisplay.size();
       listOpptRequested = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>(); 
       integer startNumber;
       integer iDisplaySize;
       if(hasNext())
       {  
           if(size <= (i + setPageSize))
           {
               startNumber = i;
               i = size;
           }
           else
           {
               i = (i + setPageSize);
               startNumber = (i - setPageSize);
           }
           
           // If the size of the display elemets are less below code is excuted
           iDisplaySize = i - startNumber;
           integer iloc = i;
           if(iDisplaySize < setPageSize) {
             i = i + setPageSize - iDisplaySize;
             if(i > size) {
                i = iloc;
             }
           }
           
           for(integer start = startNumber; start < i; start++)
           {
               listOpptRequested.add(listOpptToDisplay[start]);
           }
       } 
       //listofVenuesRequestedUpdate = getListOfRatePlansNew(listofVenuesRequested);
       return listOpptRequested;
   } 
   
   // This will display the previous set of records
   public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> previous(){ 
       size = listOpptToDisplay.size();     
       listOpptRequested = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>(); 
       
       if(i == size)
       {
           if(math.mod(size, setPageSize) > 0)
           {    
               i = size - math.mod(size, setPageSize);
           }
           else
           {
               i = (size - setPageSize);
           }         
       }
       else
       {
           i = (i - setPageSize);
       }
       // If the pointer index exceeds the size return the first elements
       if((i - setPageSize) > 0) {
            for(integer start = (i - setPageSize); start < i; ++start)
           {
               listOpptRequested.add(listOpptToDisplay[start]);
           }
       } else {
          return first();
       }
       
       return listOpptRequested;
   }
   
    public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> first(){
        i = 0;
        return next();
    }
    
}