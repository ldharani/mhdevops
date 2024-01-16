// To Validate the Address on Lead to match with Geo Loaction.
/***********************************************************************************************************************
 * @author - 
 * @date - 
 * @description - Validate Lead Address Before Lead to Account Conversion 
 * @testclass - ValidateLeadAddressTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6252    VR            07/02/2022                   T01     Update "Avalara Address Validation Error" Field
MHBS-6861    VR            28/04/2022                   T02     Added changes for Street Line 2 Field
************************************************************************************************************************/

global class ValidateLeadAddress {
        @AuraEnabled
        webservice static string validateaddress(Lead lead){
       /* 
        Lead lead = [select id,name,
                           City,Country,State,
                           PostalCode
                           From Lead
                           where id=:leadId];*/
         List<GEO_Location__c> geolocationlist;
        boolean error = false;
        string errorString = '';
         system.debug('@@@@@lead.Country '+lead.Country );   
        if(lead.Country != null && lead.Country !=''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:lead.Country Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                //acc.BillingCountry.addError('Not a valid Country');
                errorString += '* Not a valid Country  \n';
                
            }
        }
        if(lead.State != null && lead.State != ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         //where CountryName__c =:lead.Country  and
                                           where RecordType.DeveloperName = 'M_H_GEO_Locations' and State_Abbrevation__c =:lead.State Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                //acc.BillingState.addError('Not a valid State');
                errorString += '* Not a valid State \n';
                //return errorString;
                
            }
        }
        
      /*  if(!error && acc.County__c!= null && acc.County__c != ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where CountryName__c =:acc.BillingCountry 
                                              and State_Abbrevation__c =:acc.BillingState
                                              and County_Name__c =:acc.County__c Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                acc.County__c.addError('Not a valid County');
                return null;
            }
        }*/
        
        if(lead.City!= null && lead.City!= ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         //where CountryName__c =:lead.Country
                                         //     and State_Abbrevation__c =:lead.State and
                                              //and County_Name__c =:acc.County__c
                                              where RecordType.DeveloperName = 'M_H_GEO_Locations' and City_Name__c =:lead.City Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                //acc.BillingCity.addError('Not a valid City');
                errorString += '* Not a valid City \n';
                //return errorString;
            }
        }
        
        // Not Required
        /*if(lead.PostalCode!= null && lead.PostalCode!= ''){
          //if(!error && (acc.BillingPostalCode == null || acc.BillingPostalCode!= '')){  
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         //where CountryName__c =:lead.Country 
                                             // and State_Abbrevation__c =:lead.State
                                              //and County_Name__c =:acc.County__c
                                             // and City_Name__c =:lead.City and
                                              where Zipcode__c =:lead.PostalCode Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                //acc.BillingPostalCode.addError('Not a valid Zip Code');
                errorString += '* Not a valid Zip Code  ';
                return errorString;
            }
        }*/

        //T01 
         if(lead.Country == 'USA' && lead.RecordType.DeveloperName == 'Nolo_Leads' && lead.Avalara_Address_Validation_Error__c!=null && lead.Avalara_Address_Validation_Error__c!='SUCCESS'  && lead.Avalara_Address_Validation_Error__c!='')
             
       
        {
            error = true;
            errorString += '* Not a valid Address \n';
            //T02
            if(lead.Avalara_Address_Validation_Error__c.contains('between 0 and 50'))
            {
                errorString = errorString + ' Please split the street in address into line1 and line2. \n';
            }
            else
                errorString += '* Please check Avalara_Address_Validation_Error field for more information \n';
        }
            
            if(lead.Country == 'USA' &&  lead.RecordType.DeveloperName == 'Nolo_Leads' && (lead.Avalara_Address_Validation_Error__c == Null || lead.Avalara_Address_Validation_Error__c =='') && !test.isRunningTest()){
                error = true;
                errorString += '* Not a valid Address \n';
                errorString += '* Please check Avalara_Address_Validation_Error field for more information \n';
            }

        
        if(error){
            system.debug('@@@@errorString'+errorString);
            return errorString;
        }
        else{
            geolocationlist = new List<GEO_Location__c>();
            if(lead.Country != null  && (lead.State != null || lead.City != null)){
                geolocationlist = [select id From GEO_Location__c
                                         where CountryName__c =:lead.Country 
                                              and State_Abbrevation__c =:lead.State
                                              and RecordType.DeveloperName = 'M_H_GEO_Locations'
                                              and City_Name__c =:lead.City Limit 1];
                                               //Commented 
                                               //Zipcode__c =:lead.PostalCode Limit 1];
              if(geolocationlist.isEmpty()){
                    //error = true;
                    //acc.BillingPostalCode.addError('Not a valid Zip Code');
                    errorString += '* Not a valid Location ';
                    return errorString;
              }
            
            }
            return 'no Errors found';
        }
        
        
    }

}