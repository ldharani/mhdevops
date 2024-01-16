/* This is class is used to validate the lead field before Lead convert 

*/


global class ValidateLead {
    webservice static string validate(string leadId){
         Lead lead = [select id, Email,FirstName, LastName, Company, Demo_Status__c,Country, RecordType.DeveloperName, MN_Lead_Source__c, State, City, PostalCode, Avalara_Address_Validation_Error__c, Avalara_Address_Validation_Error_2__c     
                           From Lead
                           where id=:leadId];
        boolean error = false;
        string errorString = 'Lead cannot be converted since\n\n';
        
        if(lead.FirstName == NULL || lead.FirstName =='' || lead.FirstName.containsIgnoreCase('unknown') || lead.FirstName =='add' || lead.FirstName =='Add' || lead.FirstName =='ADD' ||  lead.FirstName =='Me' || lead.FirstName =='me'|| lead.FirstName =='ME'|| lead.FirstName.containsIgnoreCase('add me') || lead.FirstName.containsIgnoreCase('not provided')){
            error = true;
            errorString+= 'First Name is Invalid \n ';
        }
        
        if(lead.LastName == NULL || lead.LastName ==''|| (lead.LastName.containsIgnoreCase('unknown') || lead.LastName =='Add' ||lead.LastName =='add' || lead.LastName == 'ADD' || lead.LastName == 'Me' ||lead.LastName == 'me' || lead.LastName == 'ME' || lead.LastName.containsIgnoreCase('add me') || lead.LastName.containsIgnoreCase('not provided'))){
            error = true;
            errorString += 'Last Name is Invalid \n ';
        }
        
        if((lead.Company == NULL || lead.Company =='') || (lead.Company.containsIgnoreCase('unknown') || lead.Company =='add'|| lead.Company =='Add'||lead.Company =='ADD'|| lead.Company == 'Me'|| lead.Company == 'me'|| lead.Company == 'ME'|| lead.Company.containsIgnoreCase('add me') || lead.Company.containsIgnoreCase('not provided'))){
            error = true;
            errorString += 'Company Name is Invalid \n';
        }
        
        if((lead.Country == NULL || lead.Country =='') || (lead.State == NULL || lead.State =='')
           || (lead.City == NULL || lead.City =='') || (lead.PostalCode == NULL || lead.PostalCode =='')){
            error = true;
            errorString += 'Address Information is Invalid \n ';
        }
        
        if(lead.RecordType.DeveloperName =='M_A_Claimed_Leads' && (lead.Email == '' || lead.Email == NULL)){
            error = true;
            errorString += 'You cannot convert Since Avvo.com Email is Blank \n ';
        }
        
        if(lead.RecordType.DeveloperName =='Captorra_Lead' && (lead.Email == '' || lead.Email == NULL)){
            error = true;
            errorString += 'You cannot convert lead since Email is blank \n ';
        }
        
        if(lead.RecordType.DeveloperName =='M_N_Leads' && (lead.MN_Lead_Source__c == '' || lead.MN_Lead_Source__c == NULL)){
            error = true;
            errorString += 'MN Lead Source is Blank \n ';
        }
        
        if(lead.RecordType.DeveloperName =='M_A_Unclaimed_Leads'){
            error = true;
            errorString += 'You cannot convert an Unclaimed lead \n ';
        }
        
        if(lead.RecordType.DeveloperName =='Captorra_Lead' && lead.Demo_Status__c !='Completed'){
            error = true;
            errorString += ' Demo status is not marked as completed \n ';
        }
        
        
        
        if(error){
            return errorString;
        }
        
        //validate address method calling
        string addresserrorstring = '';
        addresserrorstring = ValidateLeadAddress.validateaddress(lead);
        if( addresserrorstring != 'no Errors found'){
            return addresserrorstring;
        }
        
        
        return 'no Errors';
        
    }

}