/***********************************************************************************************************************
 * @author - VR
 * @date - 03 Feb 2022
 * @description - Api callout for Avalara Address Endpoint.
 * Ticket - MHBS-6251
 * @testclass - ValidateAddressTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/

public class ValidateAddress {
    
    public static void validateAddressOnAccount(){
 
        Map<string,AvalaraAddressValidationDataFix__c> fieldMap = AvalaraAddressValidationDataFix__c.getAll();
        String SUCCESS = 'SUCCESS';
        
        String strSOQL;
        strSOQL = 'SELECT ID , Avalara_Address_Validation_Error__c,Validate_Address__c';
        strSOQL += ' FROM Account ';
        strSOQL += ' WHERE ';
        for (String fieldName : fieldMap.keySet()){
            String fv=fieldMap.get(fieldName).Field__c;
	    	if(fieldName=='BillingStreet')
            {
                strSOQL += ' '+fieldName+' LIKE \''+fv+'\' AND ';
            }
            else if(fieldName=='Customer_Status__c')
            {
                strSOQL += ' '+fieldName+' != \''+fv+'\' AND ';
            }
            else
            {
                strSOQL += ' '+fieldName+' = \''+fv+'\' AND ';
            }
            
		}
        strSOQL += '((Validate_Address__c=FALSE) OR (Validate_Address__c=TRUE AND Avalara_Address_Validation_Error__c!=:SUCCESS) )';
        strSOQL += ' LIMIT 50';
        system.debug('#######'+strSOQL);
        List<Account> AccList = database.query(strSOQL);
        
        /*List<Account> AccList = [Select ID , Avalara_Address_Validation_Error__c,Validate_Address__c FROM Account 
        WHERE BillingStreet LIKE '__________________________________________________%'   AND 
        RecordType.Name='M-H Account' AND 
        ((Validate_Address__c=FALSE) OR (Validate_Address__c=TRUE AND Avalara_Address_Validation_Error__c!='SUCCESS') )
        LIMIT 50 ];*/
        
    	
        for(Account acc:AccList)
        {
            acc.Validate_Address__c=TRUE;
        }
        
        UPDATE AccList;
    }

}