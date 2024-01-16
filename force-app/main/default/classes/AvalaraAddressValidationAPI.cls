/***********************************************************************************************************************
 * @author - VR
 * @date - 03 Feb 2022
 * @description - Api callout for Avalara Address Endpoint.
 * @testclass - AvalaraAddressValidationAPI_Test

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6861    VR            28/04/2022                   T01     Added changes for Street Line 2 Field
MHBS-6341    VR            21/07/2022                   T02     Bypass Errors 
************************************************************************************************************************/

public class AvalaraAddressValidationAPI {
    
    public static String BypassError1 = 'The address was found but the street number in the input address was not between the low and high range of the post office database.';
    public static String BypassError2 = 'An exact street name match could not be found and phonetically matching the street name resulted in either no matches or matches to more than one street name.';
    public static String BypassError3 = 'The physical location exists but there are no homes on this street. One reason might be railroad tracks or rivers running alongside this street, as they would prevent construction of homes in this location.';
    public static String BypassError4 = 'Multiple matches for the address are all in the same ZIP/Postal Code and carrier route. No +4 information is available.';
    public static String BypassError5 = 'Unable to validate the address. LACSLinkHit';
      
     @future(callout=true)
     public static void validateLeadAddressAndUpdateInvalidAddress(List<String> leads)
     {
         System.debug(leads);
         //Street=street, City=Jacksonville, State=FL, PostalCode=32256, Country=USA, StateCode=FL, CountryCode=US,
        
        // List<Lead> LeadList = [SELECT ID,Street,City,StateCode,CountryCode,PostalCode,Invalid_Address__c from LEAD where ID IN :IDs];
         List<Lead> LeadsToBeUpdated = new List<Lead>();
        
         
         Http http = new Http();
         HttpRequest request = new HttpRequest();
         String ENDPOINT = null , TOKEN = null , LINE1_PARAM =null , LINE2_PARAM = null , CITY_PARAM =null , REGION_PARAM=null , COUNTRY_PARAM=null, POSTALCODE_PARAM=null ;
         
         //CUSTOM SETTING - AvalaraAddressEndpoint
         if(AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiEndPoint')!=null)
         ENDPOINT = AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiEndPoint').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiToken')!=null)
         TOKEN = AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiToken').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('line1')!=null)
         LINE1_PARAM = AvalaraAddressEndpoint__c.getValues('line1').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('line2')!=null)
         LINE2_PARAM = AvalaraAddressEndpoint__c.getValues('line2').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('city')!=null)
         CITY_PARAM = AvalaraAddressEndpoint__c.getValues('city').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('region')!=null)
         REGION_PARAM = AvalaraAddressEndpoint__c.getValues('region').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('country')!=null)
         COUNTRY_PARAM = AvalaraAddressEndpoint__c.getValues('country').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('postalCode')!=null)
         POSTALCODE_PARAM = AvalaraAddressEndpoint__c.getValues('postalCode').AvalaraAddressAPITextValue__c;

         request.setMethod('GET');
         if(TOKEN!=null)
         request.setHeader('Authorization', TOKEN);
         request.setHeader('Accept','application/json');
         
         for(String  leadStr:leads )
         {
              if(AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiEndPoint')!=null)
                    ENDPOINT = AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiEndPoint').AvalaraAddressAPITextValue__c;
             
             //DATA IN STRING FORM - TO AVOID QUERYING AGAIN
             List<String> leadInfo = leadStr.split(' ');
             System.debug('leadInfo : '+leadInfo);
             String streetline1 = '' ,streetline2='', city = '' , region = '' , country ='' ,  postalCode='';
             Lead obj=new Lead();
             
             if(leadInfo!=null && !leadInfo.isEmpty()){
                if(leadInfo.size()>=1)
                    obj.ID=leadInfo[0]; 
                if(leadInfo.size()>=2)
                    streetline1 = leadInfo[1];
                if(leadInfo.size()>=3)
                    streetline2 = leadInfo[2]; //T01
                if(leadInfo.size()>=4)
                    city = leadInfo[3];
                if(leadInfo.size()>=5)
                    region = leadInfo[4];
                if(leadInfo.size()>=6)
                    country = leadInfo[5];
                if(leadInfo.size()>=7)
                    postalCode = leadInfo[6];
             }
             
             
             
             if(streetline1=='null')     streetline1='';
             if(streetline2=='null')     streetline2=''; //T01
             if(city=='null') city='';
             if(region=='null') region='';
             if(country=='null')    country='';
             if(postalCode=='null')     postalCode='';
             
             //AVALARA SUPPORTS ONLY USA
             IF(country=='' || country=='US' || country=='USA'){
                 
             //ENDPOINT = ENDPOINT + '?line1=' + street + '&city=' + city + '&region=' + region + '&country=' + country + + '&postalCode=' + postalCode;
             ENDPOINT = ENDPOINT + '?'+LINE1_PARAM+'=' + streetline1 + '&'+ LINE2_PARAM+'=' + streetline2 + '&' +CITY_PARAM+'=' + city + '&'+REGION_PARAM+'=' + region + '&'+COUNTRY_PARAM+'=' + country + + '&'+POSTALCODE_PARAM+'=' + postalCode;
             
             request.setEndpoint(ENDPOINT);
             System.debug('Avalara address endpoint = '+ENDPOINT);
             
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            System.debug(response.getStatusCode());
            //ERROR FORMATS - 
            //200 - IF SEVERITY == ERROR
            //400 - ERROR OBJECT
            if (response.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Object error = result.get('messages');
                System.debug('200-'+error);
                if(error!=null)
                {
                    List<Object> MessagesList = (List<Object>)(error);
                    Object MessagesObj = null;
                    if(MessagesList.size()>=2)
                        MessagesObj=MessagesList[1];
                    else
                        MessagesObj=MessagesList[0];
                    
                    Map<String, Object> DescriptionResult = (Map<String, Object>)(MessagesObj);
                    Object severity = DescriptionResult.get('severity');
                    Object description = DescriptionResult.get('details');
                    if(severity.toString()=='Error')
                    {
                        String errmsg = description.toString();
                        obj.Avalara_Address_Validation_Error_2__c = errmsg;
                        if(errmsg.contains('between 0 and 50'))
                        {
                            errmsg = errmsg + ' Please split the street in address into line1 and line2.';
                        }
                        else if(errmsg.contains(BypassError1) || errmsg.contains(BypassError2) 
                        || errmsg.contains(BypassError3) || errmsg.contains(BypassError4) || errmsg.contains(BypassError5))
                        {
                            errmsg = 'SUCCESS'; //Bypassing error messages as these errors are produced for correct addresses //T02
                        }
                        obj.Avalara_Address_Validation_Error__c = errmsg;
                        if(errmsg=='')
                        {
                            Object summary = DescriptionResult.get('summary');
                            String summarymsg = summary.toString();
                            obj.Avalara_Address_Validation_Error_2__c = summarymsg;
                            if(summarymsg.contains('between 0 and 50'))
                            {
                                summarymsg = summarymsg + ' Please split the street in address into line1 and line2.';
                            }
                            else if(summarymsg.contains(BypassError1) || summarymsg.contains(BypassError2) 
                            || summarymsg.contains(BypassError3) || summarymsg.contains(BypassError4) || summarymsg.contains(BypassError5))
                            {
                                summarymsg = 'SUCCESS'; //Bypassing error messages as these errors are produced for correct addresses //T02
                            }
                            obj.Avalara_Address_Validation_Error__c = summarymsg;
                        }
                    }
                }
                else
                {
                    obj.Avalara_Address_Validation_Error__c = 'SUCCESS';
                    obj.Avalara_Address_Validation_Error_2__c = 'SUCCESS';
                }
                LeadsToBeUpdated.add(obj);
            }
            else if(response.getStatusCode() == 400)
            {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Object error = result.get('error');
            
                Map<String, Object> DetailsResult = (Map<String, Object>)(error);
                Object details = DetailsResult.get('details');
         
                List<Object> DetailsList = (List<Object>)(details);
                Object DetailsObj = DetailsList[0];
             
                Map<String, Object> DescriptionResult = (Map<String, Object>)(DetailsObj);
                Object description = DescriptionResult.get('description');
             
                System.debug(description);
                System.debug(obj);
             
                String errmsg = description.toString();
                obj.Avalara_Address_Validation_Error__c = errmsg;
                obj.Avalara_Address_Validation_Error_2__c = errmsg;
                LeadsToBeUpdated.add(obj);
            }
           
            }//END OF COUNTRY CHECK IF
            else
            {
                obj.Avalara_Address_Validation_Error__c = '';
                LeadsToBeUpdated.add(obj);
            }
         
        }//END OF FOR LOOP
            System.debug('LeadsToBeUpdated :'+LeadsToBeUpdated);
            if(!LeadsToBeUpdated.isEmpty())
            {
                try{
                update LeadsToBeUpdated;
                }
                catch(Exception e){
                    System.debug('EXCEPTION OCCURRED '+e.getMessage());
                    Util.processException(e,true,'Exception occurred while updating Avalara_Address_Validation_Error__c field.');
               
                }
            }
         
     }
    
    
    

     @future(callout=true)
     public static void validateAccountAddressAndUpdateInvalidAddress(List<String> Accounts)
     {
         System.debug(Accounts);
         //BillingStreet,BillingCity,BillingStateCode,BillingCountryCode
        
         //List<Account> AccountList = [SELECT ID,BillingStreet,BillingCity,BillingStateCode,BillingCountryCode from Account where ID IN :IDs];
         List<Account> AccountsToBeUpdated = new List<Account>();
         
         Http http = new Http();
         HttpRequest request = new HttpRequest();
         
         String ENDPOINT = null , TOKEN = null , LINE1_PARAM =null , LINE2_PARAM =null , LINE3_PARAM =null , CITY_PARAM =null , REGION_PARAM=null , COUNTRY_PARAM=null, POSTALCODE_PARAM=null ;
         
         //CUSTOM SETTING - AvalaraAddressEndpoint
         if(AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiEndPoint')!=null)
         ENDPOINT = AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiEndPoint').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiToken')!=null)
         TOKEN = AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiToken').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('line1')!=null)
         LINE1_PARAM = AvalaraAddressEndpoint__c.getValues('line1').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('line2')!=null)
         LINE2_PARAM = AvalaraAddressEndpoint__c.getValues('line2').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('line3')!=null)
         LINE3_PARAM = AvalaraAddressEndpoint__c.getValues('line3').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('city')!=null)
         CITY_PARAM = AvalaraAddressEndpoint__c.getValues('city').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('region')!=null)
         REGION_PARAM = AvalaraAddressEndpoint__c.getValues('region').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('country')!=null)
         COUNTRY_PARAM = AvalaraAddressEndpoint__c.getValues('country').AvalaraAddressAPITextValue__c;
         if(AvalaraAddressEndpoint__c.getValues('postalCode')!=null)
         POSTALCODE_PARAM = AvalaraAddressEndpoint__c.getValues('postalCode').AvalaraAddressAPITextValue__c;


         request.setMethod('GET');
          if(TOKEN!=null)
         request.setHeader('Authorization', TOKEN);
         request.setHeader('Accept','application/json');
         
         for(String  AccountStr:Accounts )
         {
             if(AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiEndPoint')!=null)
                ENDPOINT = AvalaraAddressEndpoint__c.getValues('AvalaraAddressApiEndPoint').AvalaraAddressAPITextValue__c;
             
             //DATA IN STRING FORM - TO AVOID QUERYING AGAIN
             List<String> AccountInfo = AccountStr.split(' ');
             System.debug('AccountInfo : '+AccountInfo);
             Account obj = new Account();
             String streetline1 = '' ,streetline2='', city = '' , region = '' , country ='' ,  postalCode='';
             
             if(AccountInfo!=null && !AccountInfo.isEmpty()){
                if(AccountInfo.size()>=1)
                    obj.ID=AccountInfo[0]; 
                if(AccountInfo.size()>=2)
                    streetline1 = AccountInfo[1];
                if(AccountInfo.size()>=3)
                    streetline2 = AccountInfo[2]; //T01
                if(AccountInfo.size()>=4)
                    city = AccountInfo[3];
                if(AccountInfo.size()>=5)
                    region = AccountInfo[4];
                if(AccountInfo.size()>=6)
                    country = AccountInfo[5];
                if(AccountInfo.size()>=7)
                    postalCode = AccountInfo[6];
             }
             
             
             if(streetline1=='null')     streetline1='';
             if(streetline2=='null')     streetline2=''; //T01
             if(city=='null') city='';
             if(region=='null') region='';
             if(country=='null')    country='';
             if(postalCode=='null')     postalCode='';
             
             IF(country=='' || country=='US' || country=='USA'){
                 
             
             if(streetline1.length() > 50)
             {
                 List<String> lines = splitPath(streetline1);
                 String ln1='-',ln2='-',ln3='-';
                 if(lines.size()>=1) ln1 = EncodingUtil.urlEncode(lines[0],'UTF-8');
                 if(lines.size()>=2) ln2 = EncodingUtil.urlEncode(lines[1],'UTF-8');
                 if(lines.size()>=3) ln3 = EncodingUtil.urlEncode(lines[2],'UTF-8');
                 ENDPOINT = ENDPOINT + '?'+LINE1_PARAM+'=' + ln1 + '&'+LINE2_PARAM+'=' + ln2 + '&'+LINE3_PARAM+'=' + ln3 + '&'+CITY_PARAM+'=' + city + '&'+REGION_PARAM+'=' + region + '&'+COUNTRY_PARAM+'=' + country + + '&'+POSTALCODE_PARAM+'=' + postalCode;
            	 
             }
             else
			 
             {
                 //ENDPOINT = ENDPOINT + '?'+LINE1_PARAM+'=' + street + '&'+CITY_PARAM+'=' + city + '&'+REGION_PARAM+'=' + region + '&'+COUNTRY_PARAM+'=' + country + + '&'+POSTALCODE_PARAM+'=' + postalCode;
             	ENDPOINT = ENDPOINT + '?'+LINE1_PARAM+'=' + streetline1 + '&'+ LINE2_PARAM+'=' + streetline2 + '&' +CITY_PARAM+'=' + city + '&'+REGION_PARAM+'=' + region + '&'+COUNTRY_PARAM+'=' + country + + '&'+POSTALCODE_PARAM+'=' + postalCode;
             }
             //ENDPOINT = ENDPOINT + '?line1=' + street + '&city=' + city + '&region=' + region + '&country=' + country + + '&postalCode=' + postalCode;
             request.setEndpoint(ENDPOINT);
             System.debug('Avalara address endpoint = '+ENDPOINT);
             
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            System.debug(response.getStatusCode());
            //ERROR FORMATS - 
            //200 - IF SEVERITY == ERROR
            //400 - ERROR OBJECT
            if (response.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Object error = result.get('messages');
                System.debug('200-'+error);
                if(error!=null)
                {
                    List<Object> MessagesList = (List<Object>)(error);
                    Object MessagesObj = null;
                    if(MessagesList.size()>=2)
                        MessagesObj=MessagesList[1];
                    else
                        MessagesObj=MessagesList[0];
                    
                    Map<String, Object> DescriptionResult = (Map<String, Object>)(MessagesObj);
                    Object severity = DescriptionResult.get('severity');
                    Object description = DescriptionResult.get('details');
                    if(severity.toString()=='Error')
                    {
                        String errmsg = description.toString();
                        obj.Avalara_Address_Validation_Error_2__c = errmsg;
                        if(errmsg.contains('between 0 and 50'))
                        {
                            errmsg = errmsg + ' Please split the street in address into line1 and line2.';
                        }
                        else if(errmsg.contains(BypassError1) || errmsg.contains(BypassError2) 
                        || errmsg.contains(BypassError3) || errmsg.contains(BypassError4) || errmsg.contains(BypassError5))
                        {
                            errmsg = 'SUCCESS'; //Bypassing error messages as these errors are produced for correct addresses //T02
                        }
                        obj.Avalara_Address_Validation_Error__c = errmsg;
                        if(errmsg=='')
                        {
                            Object summary = DescriptionResult.get('summary');
                            String summarymsg = summary.toString();
                            obj.Avalara_Address_Validation_Error_2__c = summarymsg;
                            if(summarymsg.contains('between 0 and 50'))
                            {
                                summarymsg = summarymsg + ' Please split the street in address into line1 and line2.';
                            }
                            else if(summarymsg.contains(BypassError1) || summarymsg.contains(BypassError2) 
                            || summarymsg.contains(BypassError3) || summarymsg.contains(BypassError4) || summarymsg.contains(BypassError5))
                            {
                                summarymsg = 'SUCCESS'; //Bypassing error messages as these errors are produced for correct addresses //T02
                            }
                            obj.Avalara_Address_Validation_Error__c = summarymsg;
                        }
                        
                    }
                }
                else
                {
                    obj.Avalara_Address_Validation_Error__c = 'SUCCESS';
                    obj.Avalara_Address_Validation_Error_2__c = 'SUCCESS';
                }
                AccountsToBeUpdated.add(obj);
            }
            else if(response.getStatusCode() == 400)
            {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Object error = result.get('error');
            
                Map<String, Object> DetailsResult = (Map<String, Object>)(error);
                Object details = DetailsResult.get('details');
         
                List<Object> DetailsList = (List<Object>)(details);
                Object DetailsObj = DetailsList[0];
             
                Map<String, Object> DescriptionResult = (Map<String, Object>)(DetailsObj);
                Object description = DescriptionResult.get('description');
             
                System.debug(description);
                System.debug(obj);
             
                String errmsg = description.toString();
                obj.Avalara_Address_Validation_Error__c = errmsg;
                obj.Avalara_Address_Validation_Error_2__c = errmsg;
                AccountsToBeUpdated.add(obj);
            }
            
            }//END OF COUNTRY CHECK IF
            else
            {
                obj.Avalara_Address_Validation_Error__c = '';
                AccountsToBeUpdated.add(obj);
            }
             
        } // END OF FOR LOOP
         
            System.debug('Accounts-validateavalara'+AccountsToBeUpdated);
            if(!AccountsToBeUpdated.isEmpty())
            {
                try{
                    update AccountsToBeUpdated;
                
                }
                catch(Exception e)
                {
                    System.debug('EXCEPTION OCCURRED '+e.getMessage());
                    Util.processException(e,true,'Exception occurred while updating Avalara_Address_Validation_Error__c field.');
                }
            }
         
     }
    
    
    @AuraEnabled
     public static SObject getObjectById(ID ObjectID)
     {
         try{
              String objectName = ObjectID.getSObjectType().getDescribe().getName();
              String query = 'SELECT ID,Avalara_Address_Validation_Error__c,RecordType.DeveloperName,RecordTypeId FROM '+objectName+' WHERE ID = :ObjectID ';
              Sobject[] objects = Database.query(query);
              System.debug(' objects '+ objects);
              return objects[0];
         }
         catch(Exception e)
         {
             System.debug('Exception Occurred'+e.getMessage());
         }
         return null;
     }
    
    public static List<String> splitPath(String streetname) {
        streetname = EncodingUtil.urlDecode(streetname,'UTF-8');
        streetname = streetname.trim().replaceAll('\\s+',' ');  //In case of blank lines in string
        System.debug('ENTERED splitPath and decoded = '+streetname);
        System.debug('ENTERED .length() and decoded = '+streetname.length());
        Integer by3 = streetname.length() / 3;
        
        if (streetname == null)
            return null;
        
        List<String> parts = streetname.split(',');
        if(!streetname.contains(','))
        {
            parts = streetname.split(' ');
        }
        System.debug('parts'+parts+'  '+parts.size()+' by3 = '+by3);
        List<String> result = new List<String>();
        boolean cannotdividebybasicrule = false;
        // aaa,bbb,ccc -> basic ; 
        // aaa,bb.....b,ccc -> basic but line2>50 ; 
        // aaa,bbb,ccc,ddd,eee -> all <50 but more than 3 lines
        // aaa,bb.....b,ccc,ddd,eee -> line2>50 AND more than 3 lines
        {
            for(Integer i=0;i<parts.size();i++)
            {
                if(parts[i].length()>=50)
                {
                    cannotdividebybasicrule = true; break;
                }
                else 
                {
                    result.add(parts[i]);
                }
            }
        }
        System.debug('cannotdividebybasicrule = '+cannotdividebybasicrule);
        if(cannotdividebybasicrule || parts.size()>3)
        {
             if(cannotdividebybasicrule)
             {
                 parts = streetname.split(' ');
                 System.debug('parts - cannotdividebybasicrule '+parts);
             }
            result = new List<String>();
            Integer c=0;
            String str='';
            
            for(Integer i=0;i<parts.size();i++)
            {
                if(c+parts[i].length()<by3)
                {
                    str=str+parts[i];
                    str=str+'+';
                    c=c+parts[i].length();
                }
                else
                {
                    result.add(str);
                    c=parts[i].length();
                    str=parts[i]+'+';
                }
                System.debug(i+'----'+c+' - '+str+' - '+result);
            }
            if(c<by3)
            result.add(str);
        }
        
        System.debug('RESULT AFTER SPLITTING BY 3 result - AVALARA - ADDR '+result+' '+result.size());
        return result;
    }
}