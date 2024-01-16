/**@@
#TRIGGER NAME        :    InvoiceLineTrigger
#HANDLER CLASS NAME  :    Trigger_InvoiceLine_Handler
#HELPER CLASS NAME   :    Trigger_InvoiceLine_Helper
#TEST CLASS          :    InvoiceLineTriggerTest
#CREATED BY          :    Serge Kandukuri
#DESCRIPTION         :    This Helper class will handles all the trigger events and handling the appropriate logic.   
@@**/
public class Trigger_InvoiceLine_Helper{

    /**@@
    #DESCRIPTION   : 
    #Paramaters    : trigger.new
    @@**/
    public static void createBiWeeklyInvoiceLines(List<blng__InvoiceLine__c> newList){ 
        string strSOQL = 'SELECT ';
        strSOQL += queryAllFields('blng__InvoiceLine__c');
        strSOQL += ' FROM blng__InvoiceLine__c WHERE Id IN: newList order by blng__StartDate__c ASC';
        
        // Update Existing Usage Summaries
        List<blng__InvoiceLine__c> lstILDel = new List<blng__InvoiceLine__c>();
        blng__InvoiceLine__c objILDel;
        
        List<blng__InvoiceLine__c> lstIL = database.Query(strSOQL );
        List<blng__InvoiceLine__c> lstILInsert = new List<blng__InvoiceLine__c>();
        blng__InvoiceLine__c objIL;
        integer i = 0;
        for(blng__InvoiceLine__c invl: lstIL){
           // system.assertEquals(us.blng__StartDate__c.daysbetween(us.blng__EndDate__c),2);
            //system.assertEquals(1,2);
            if(invl.blng__StartDate__c.daysbetween(invl.blng__EndDate__c) > 15){
                objILDel = new blng__InvoiceLine__c(id=invl.Id);
                lstILDel.add(objILDel);
                
                objIL = new blng__InvoiceLine__c();
                objIL = invl.clone();
                objIL.blng__StartDate__c = invl.blng__StartDate__c;
                objIL.blng__EndDate__c = invl.blng__StartDate__c.adddays(14);
                objIL.blng__UniqueId__c = null;
                lstILInsert.add(objIL);
                
                
                objIL = new blng__InvoiceLine__c();
                objIL = invl.clone();
                objIL.blng__StartDate__c = invl.blng__StartDate__c.adddays(15);
                objIL.blng__EndDate__c = invl.blng__EndDate__c;
                objIL.blng__UniqueId__c = null;
                lstILInsert.add(objIL);
            }
            
        }
        
        if(!lstILDel.isEmpty()){
            // delete lstILDel;
        }
        
        if(!lstILInsert.isEmpty()){
            insert lstILInsert;
        }
        
    }
    
      /*
        Method Name: queryAllFields
        Description: This method is used to return all fields of sObject 
        Parameter  : sObject API Name
    */
    Public static string queryAllFields(String strObjectAPIName){
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String queryFields = String.join( fieldNames, ',' );
        return queryFields;
    }// END OF METHOD - queryAllFields
}