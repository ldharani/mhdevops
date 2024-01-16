public class Helper {
 
    public static Exception__c processException(Exception e,boolean insertFlag,String description)
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
                    DMLDetails = DMLDetails + ' - DML DmlId: '+e.getDmlId(i);
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
        }
        if(insertFlag)
        {
            insert excp;
        }
        System.debug('An exception occurred: ' + excp);
        return excp;
    }
}