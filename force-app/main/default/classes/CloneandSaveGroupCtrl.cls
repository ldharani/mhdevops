/*
Class Name  - CloneandSaveGroupCtrl
Description - This apex class is used to clone group
*/
Public class CloneandSaveGroupCtrl{
    public id quoteid;
    public boolean showSpinner {get; set;}
    Public CloneandSaveGroupCtrl(){
        showSpinner = true;
    }
    
    Public pagereference cloneandSave(){
        quoteid = ApexPages.currentPage().getParameters().get('Id');
        system.debug('Quote Id'+quoteid);
        if(quoteid != null){
            // Clone Group 1 -- START
            String soql = 'SELECT ';
            soql += queryAllFields('SBQQ__QuoteLine__c') + ', ';
            soql += 'SBQQ__Quote__r.SBQQ__Status__c, SBQQ__Quote__r.Subscription_type__c, ';
            soql += 'SBQQ__Quote__r.SBQQ__Account__c';
            soql += ' FROM SBQQ__QuoteLine__c ';
            soql += ' WHERE SBQQ__Quote__c =: quoteid and SBQQ__Quantity__c > 0';
            system.debug('@@@@@@@@@'+soql);
            List<SBQQ__QuoteLine__c> lstQLI = database.query(soql);
            
            string strGroupId;
            string strAccId;
            for(SBQQ__QuoteLine__c quotLine : lstQLI){
                if(quotLine.SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won' && 
                   quotLine.SBQQ__Quote__r.Subscription_type__c == 'Rebase Evergreen' && 
                   quotLine.SBQQ__SubscriptionType__c != 'Renewable' && 
                   quotLine.SBQQ__ProductSubscriptionType__c == 'Renewable/Evergreen'){
                       strGroupId = quotLine.SBQQ__Group__c;
                       strAccId = quotLine.SBQQ__Quote__r.SBQQ__Account__c;
               }
            }
            
            if(strGroupId == null){
                SBQQ__QuoteLineGroup__c objQLG = new SBQQ__QuoteLineGroup__c();
                objQLG.Name = 'Group 1';
                objQLG.SBQQ__Account__c = strAccId;
                objQLG.SBQQ__Quote__c = quoteid;
                insert objQLG;
                
                List<SBQQ__QuoteLine__c> lstExistingQLIUpdate = new List<SBQQ__QuoteLine__c>();
                for(SBQQ__QuoteLine__c quotLine : lstQLI){
                    if(quotLine.SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won' && 
                       quotLine.SBQQ__Quote__r.Subscription_type__c == 'Rebase Evergreen' && 
                       quotLine.SBQQ__SubscriptionType__c != 'Renewable' && 
                       quotLine.SBQQ__ProductSubscriptionType__c == 'Renewable/Evergreen'){
                           SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c(Id=quotLine.Id);
                           objQLI.SBQQ__Group__c = objQLG.Id;
                           lstExistingQLIUpdate.add(objQLI);
                    }
                }
                
                if(!lstExistingQLIUpdate.isEmpty()){
                    update lstExistingQLIUpdate;
                }
                strGroupId = objQLG.Id;
            }
            
            String strSOQL = 'SELECT ';
            strSOQL += queryAllFields('SBQQ__QuoteLineGroup__c') + ', ';
            strSOQL += ' SBQQ__Quote__r.Name';
            strSOQL += ' FROM SBQQ__QuoteLineGroup__c ';
            
            strSOQL += ' WHERE Id =: strGroupId';
            system.debug('########'+strSOQL);
            List<SBQQ__QuoteLineGroup__c> lstQLG = database.query(strSOQL);
            List<SBQQ__QuoteLineGroup__c> lstQLGIsert = new List<SBQQ__QuoteLineGroup__c>();
            for(SBQQ__QuoteLineGroup__c qlg: lstQLG){
                SBQQ__QuoteLineGroup__c objQLG = new SBQQ__QuoteLineGroup__c();
                objQLG = qlg.clone(false, false, false, false);
                objQLG.Name = 'Cloned Products';
                objQLG.SBQQ__Source__c = strGroupId;
                lstQLGIsert.add(objQLG);
            }
            if(!lstQLGIsert.isEmpty()){
                insert lstQLGIsert;
            }
            // Clone Group 1 -- END
            
                                        
                                               
            // Clone Existing QLI with Subscription Type as 'Renewable' -- START
            SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
            List<SBQQ__QuoteLine__c> lstQLIUpdate = new List<SBQQ__QuoteLine__c>();
                
            List<SBQQ__QuoteLine__c> lstQLIInsert = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quotLine : lstQLI){
                if(quotLine.SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won' && 
                   quotLine.SBQQ__Quote__r.Subscription_type__c == 'Rebase Evergreen' && 
                   quotLine.SBQQ__SubscriptionType__c != 'Renewable' && 
                   quotLine.SBQQ__ProductSubscriptionType__c == 'Renewable/Evergreen'){
                    
                    SBQQ__QuoteLine__c objCloneQLI = new SBQQ__QuoteLine__c();
                    objCloneQLI = quotLine.clone(false, false, false, false);
                    objCloneQLI.SBQQ__Group__c = lstQLGIsert[0].Id;
                    objCloneQLI.SBQQ__SubscriptionType__c = 'Renewable';
                    objCloneQLI.SBQQ__UpgradedSubscription__c = null;
                    objCloneQLI.SBQQ__PriorQuantity__c = null;
                    //objCloneQLI.SBQQ__Quantity__c = 1;
                    lstQLIInsert.add(objCloneQLI);
                }
            }
            Map<Id, Id> mapProductIdwithRequiredByQLI = new Map<Id, Id>();
            if(!lstQLIInsert.isEmpty()){
                insert lstQLIInsert;
                for(SBQQ__QuoteLine__c quotLine : lstQLIInsert){
                    mapProductIdwithRequiredByQLI.Put(quotLine.SBQQ__Product__c, quotLine.Id);
                }
                
                lstQLIInsert = [SELECT Id, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE Id IN: lstQLIInsert];
                lstQLIUpdate = new List<SBQQ__QuoteLine__c>();
                for(SBQQ__QuoteLine__c quotLine : lstQLIInsert){
                    if(quotLine.SBQQ__RequiredBy__c != null){
                        objQLI = new SBQQ__QuoteLine__c(Id=quotLine.Id);
                        objQLI.SBQQ__RequiredBy__c = mapProductIdwithRequiredByQLI.get(quotLine.SBQQ__RequiredBy__r.SBQQ__Product__c);
                        lstQLIUpdate.add(objQLI);
                    }
                }
                if(!lstQLIUpdate.isEmpty()){
                    update lstQLIUpdate;
                }
            }
            // Clone Existing QLI with Subscription Type as 'Renewable' -- END
            
            
            // Set Quantity to 0 for existing QLI -- START
            lstQLIUpdate = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quotLine : lstQLI){
                if(quotLine.SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won' && 
                   quotLine.SBQQ__Quote__r.Subscription_type__c == 'Rebase Evergreen' && 
                   quotLine.SBQQ__SubscriptionType__c != 'Renewable' && 
                   quotLine.SBQQ__ProductSubscriptionType__c == 'Renewable/Evergreen' && 
                   quotLine.SBQQ__Group__c != lstQLGIsert[0].Id){
                        system.debug('quotLine '+quotLine);
                        objQLI = new SBQQ__QuoteLine__c(Id=quotLine.Id);
                        objQLI.SBQQ__Quantity__c = 0;
                        lstQLIUpdate.add(objQLI);
               }
            }
            if(!lstQLIUpdate.isEmpty()){
                update lstQLIUpdate;
            }
            // Set Quantity to 0 for existing QLI -- END     
        }
        showSpinner = false;
        PageReference retURL = Page.SBQQ__SB;
        retURL.getParameters().put('scontrolCaching', 'l');
        retURL.getParameters().put('id', quoteId);
        retURL.setRedirect(true);
        
        return retURL;
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