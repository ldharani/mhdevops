public without sharing class AOPController {
    @AuraEnabled
    public static Boolean fetchProfileAccess(){
        try{
            Boolean bool = false;
            String profileId = System.UserInfo.getProfileId();
            for(Profile  prof : [Select Id,Name FROM Profile WHERE 
                                 	Name IN('System Administrator','Data Governor','CPQ MH Sales Rep','MH Sales Rep')AND Id=:profileId]){
                bool = true;
            }
            return bool;
        }catch(exception e){
             throw new AuraException(e.getMessage());
        } 
    }
    
    @AuraEnabled
    public static object fetchRecordDetails(String recordId){
        Account acc ;
        try{
            acc = [Select Id,Name,Area_of_Practice__c,Area_of_Practice1__c FROM Account WHERE Id =:recordId
                  		AND (RecordType.DeveloperName = 'Nolo_Account' OR RecordType.DeveloperName = 'M_N_Account')];//Modified for MHBS-7673
            System.debug('acc::'+acc);
            return acc;
        }catch(exception e){
            throw new AuraException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static List<String> fetchAOPOptions(){
        Schema.DescribeSObjectResult objSchema = Account.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        List<Schema.Picklistentry>fld =fieldmap.get('Area_of_Practice__c').getDescribe().getpicklistValues();
        System.debug('fld'+fld);
        List<String> pickList = new List<String>();
        
        for(Schema.Picklistentry pl : fld)
        {
            pickList.add(pl.getValue());
        }
        System.debug('pickList'+pickList);
        return pickList;
    }
    
    @AuraEnabled
    public static object updateAOPVal(String recordId,String aopStr){
       
        try{
            System.debug('aopStr:::'+aopStr);
            Account acc =  new Account();
            acc.Id = recordId;
            acc.Area_of_Practice__c = aopStr;
            update acc;
            System.debug('acc::: '+acc);
            return acc;
        }catch(exception e){
            throw new AuraException(e.getMessage());
        }
        
    }

}