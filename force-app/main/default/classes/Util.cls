/**********************************************************************************
Util Class contains methods and variables that can be reused anywhere in the code

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************  
*/
public without sharing class Util{

    /**
     * processException - PLEASE USE THIS METHOD!!!
     * @param  e           Exception to process
     * @param  insertFlag  Determine if the exception should be inserted
     * @param  description String description to add to the Exception (Optional)
     * @return             The Exception created
     */
    public static Exception__c processException(Exception e, Boolean insertFlag, String description,Map<Id,Id> ContractMap)
    {
        Exception__c excp = new Exception__c();
        if(e != null)
        {
            excp.Line_Number__c = e.getLineNumber();
            excp.Stack_Trace__c = e.getStackTraceString();
            excp.Type__c = e.getTypeName();
            excp.Exception_Message__c = e.getMessage();
            if(e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.EmailException')
            {
                Integer numErrors = e.getNumDml();
                String DMLDetails ='DML Num Errors: '+numErrors;
                for(Integer i=0;i<numErrors;i++)
                {
                    String ids = '';
                    if(ContractMap.containskey(e.getDmlId(i))){
                        ids = ContractMap.get(e.getDmlId(i));
                    }else{
                        ids = e.getDmlId(i);
                    }
                    DMLDetails = DMLDetails + ' - DML DmlFieldNames: '+e.getDmlFieldNames(i);
                    DMLDetails = DMLDetails + ' - DML DmlFields: '+e.getDmlFields(i);
                    DMLDetails = DMLDetails + ' - DML DmlId: '+ ids;                        
                    DMLDetails = DMLDetails + ' - DML DmlIndex: '+e.getDmlIndex(i);
                    DMLDetails = DMLDetails + ' - DML DmlMessage: '+e.getDmlMessage(i);
                    DMLDetails = DMLDetails + ' - DML DmlStatusCode: '+e.getDmlStatusCode(i);
                    DMLDetails = DMLDetails + ' - DML DmlType: '+e.getDmlType(i);
                }
                excp.Description__c = DMLDetails;
            }
        }
        if(null != description && !description.equals(''))
        {
            if(null != excp.Description__c && !excp.Description__c.equals(''))
            {
                excp.Description__c = excp.Description__c + ' - Description: ' +description;
            }
            else
            {
                excp.Description__c = description;
            }
            excp.Description__c = excp.Description__c.subString(0,255);
        }
        if(insertFlag)
        {
            insert excp;
        }
        System.debug('An exception occurred: ' + excp);
        return excp;
    }
    
    /**
     * processException - PLEASE USE THIS METHOD!!!
     * @param  e           Exception to process
     * @param  insertFlag  Determine if the exception should be inserted
     * @param  description String description to add to the Exception (Optional)
     * @return             The Exception created
     */
    public static Exception__c processException(Exception e, Boolean insertFlag, String description)
    {
        Exception__c excp = new Exception__c();
        if(e != null)
        {
            excp.Line_Number__c = e.getLineNumber();
            excp.Stack_Trace__c = e.getStackTraceString();
            excp.Type__c = e.getTypeName();
            excp.Exception_Message__c = e.getMessage();
            if(e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.EmailException')
            {
                Integer numErrors = e.getNumDml();
                String DMLDetails ='DML Num Errors: '+numErrors;
                for(Integer i=0;i<numErrors;i++)
                {                    
                    DMLDetails = DMLDetails + ' - DML DmlFieldNames: '+e.getDmlFieldNames(i);
                    DMLDetails = DMLDetails + ' - DML DmlFields: '+e.getDmlFields(i);
                    DMLDetails = DMLDetails + ' - DML DmlId: '+ e.getDmlId(i);                       
                    DMLDetails = DMLDetails + ' - DML DmlIndex: '+e.getDmlIndex(i);
                    DMLDetails = DMLDetails + ' - DML DmlMessage: '+e.getDmlMessage(i);
                    DMLDetails = DMLDetails + ' - DML DmlStatusCode: '+e.getDmlStatusCode(i);
                    DMLDetails = DMLDetails + ' - DML DmlType: '+e.getDmlType(i);
                }
                excp.Description__c = DMLDetails;
            }
        }
        if(null != description && !description.equals(''))
        {
            if(null != excp.Description__c && !excp.Description__c.equals(''))
            {
                excp.Description__c = excp.Description__c + ' - Description: ' +description;
            }
            else
            {
                excp.Description__c = description;
            }
            excp.Description__c = excp.Description__c.subString(0,255);
        }
        if(insertFlag)
        {
            insert excp;
        }
        System.debug('An exception occurred: ' + excp);
        return excp;
    }
}