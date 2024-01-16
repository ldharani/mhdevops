public with sharing class OpportunityLogic {

    public void doBeforeInsert(List<Opportunity> newOpportunities) {
        system.debug('hitting insert'+newOpportunities);
        updateOwnerField(newOpportunities);
    }

    public void doBeforeUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
        List<Opportunity> changelist = new List<Opportunity>();
        system.debug('hitting update new'+newOpportunities);
        system.debug('hitting update old'+oldOpportunityMap);
        for (Opportunity o : newOpportunities) {
        //&& o.recordType.name == 'M-A Opportunity'
            if (o.Sales_Person_Email__c!= null && o.Sales_Person_Email__c != oldOpportunityMap.get(o.Id).Sales_Person_Email__c ) {
                changelist.add(o);
            }
        }
        system.debug('===OptyID==='+changelist);
        updateOwnerField(changeList);
    }

    private void updateOwnerField(List<Opportunity> opportunities) {
        Map<String,List<Opportunity>> emailOppListMap = new Map<String,List<Opportunity>>();
        system.debug('==optys=='+opportunities);
        
        //Id RecordTypeId_avvoAttrny = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Opportunity').getRecordTypeId();
        
        for (Opportunity o : opportunities) {
        system.debug('==opty Sales Email=='+o.Sales_Person_Email__c);
        system.debug('==opty RT=='+o.RecordtypeId);
            if (o.Sales_Person_Email__c != null){ //&& o.RecordtypeId == RecordTypeId_avvoAttrny) {
                if (emailOppListMap.get(o.Sales_Person_Email__c) == null) {
                    emailOppListMap.put(o.Sales_Person_Email__c,new List<Opportunity>());
                }
                emailOppListMap.get(o.Sales_Person_Email__c).add(o);
                system.debug('==emailList=='+emailOppListMap);
            }
        }
        
        List<User> userList = [SELECT Id,Email FROM User WHERE Email IN :emailOppListMap.keySet() ORDER BY LastName
        DESC];
        system.debug('==userList=='+userList);
        for (User u : userList) {
            List<Opportunity> oppList = emailOppListMap.get(u.Email);
            for (Opportunity o : oppList) {
                o.OwnerId = u.Id;
            }
        }
    }
    
    public void preventStageOrReasonChange(List<Opportunity> newMap,Map<Id, Opportunity> oldMap){
        system.debug('inside preventStageOrReasonChange');
        String profileName = [select name from profile where id = :UserInfo.getProfileId()].Name; 
        system.debug('profileName : '+profileName);
        Set<ID> opIds = new Set<ID>();
        for(Opportunity op : newMap){
            opIds.add(op.Id);
        }
        Map<Id, SBQQ__Quote__c> oppIdToQuoteMap = new Map<Id, SBQQ__Quote__c>(); 
        List<SBQQ__Quote__c> quoteList = [select id, SBQQ__Status__c, Reason_Won_Lost__c, SBQQ__Opportunity2__c from SBQQ__Quote__c where SBQQ__Primary__c = true and SBQQ__Opportunity2__c = :opIds];
        for(SBQQ__Quote__c qt : quoteList){
           oppIdToQuoteMap.put(qt.SBQQ__Opportunity2__c, qt);
        }
       system.debug('oppIdToQuoteMap : '+oppIdToQuoteMap);
        for(Opportunity opp : newMap){
            //if(oppIdToQuoteMap != null){
                if((opp.StageName != oldMap.get(opp.Id).StageName || opp.Reason_Won_Lost__c != oldMap.get(opp.Id).Reason_Won_Lost__c)
                   && (profileName == 'CPQ MH Sales Rep' || profileName == 'M-A Intake Sales' || profileName == 'MH Avvo Sales Rep' || profileName == 'MN Sales Reps' ||
                      profileName == 'Ngage Sales' || profileName == 'Ngage Sales Management' || profileName == 'Nolo Acct Mgrs')
                   && oppIdToQuoteMap.containsKey(opp.Id) && ((oppIdToQuoteMap.get(opp.Id).SBQQ__Status__c != opp.StageName)
                   || (oppIdToQuoteMap.get(opp.Id).Reason_Won_Lost__c != opp.Reason_Won_Lost__c))
                  ){
                    system.debug('inside : :');     
                    opp.addError('You cannot change Stage or Reason Won lost field in Opportunity !');
                   } 
            //}
        }
    }

}