public class OpportunityNeedApprovalFromProcess{
    @InvocableMethod
    public static void opptyUpdateFromProcess(List<Id> OpportunityIds){
        Set<id> salesRepOppIds = new Set<id>();
        Set<id> salesManagerOppIds = new Set<id>();
        Set<id> salesVPOppIds = new Set<id>();
        Set<id> salesFinanceOppIds = new Set<id>();
        Set<id> OppIds = new Set<id>();
        List<Opportunity> opptysToUpdateList = new List<Opportunity>();
        boolean checkPackageExists = false;        
        if(ClassOnOpportunityRatePlanCharge.runOnceNeedApproval()){
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppchrg : [select id,Name,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c,invoiceit_crmx__Unit_Price__c, Floor_Price__c,Package_Wrapper__c from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where invoiceit_crmx__Opportunity__c IN: OpportunityIds]){
            if((oppchrg.Package_Wrapper__c == TRUE && oppchrg.invoiceit_crmx__Unit_Price__c > oppchrg.Floor_Price__c)){
                    if(oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c <= 20)
                    salesRepOppIds.add(oppchrg.invoiceit_crmx__Opportunity__c);
            }else if(oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c <= 20){
                    system.debug('unit price::::'+oppchrg.invoiceit_crmx__Unit_Price__c);
                    system.debug('floor price::::'+oppchrg.Floor_Price__c);
                    if(oppchrg.Package_Wrapper__c == TRUE && oppchrg.invoiceit_crmx__Unit_Price__c < oppchrg.Floor_Price__c){
                        checkPackageExists = true;
                        salesManagerOppIds.add(oppchrg.invoiceit_crmx__Opportunity__c);                        
                    }else{
                        salesRepOppIds.add(oppchrg.invoiceit_crmx__Opportunity__c);
                    }
                    
                    if(checkPackageExists)
                    salesRepOppIds = new Set<id>();
            }
            
            if((oppchrg.Package_Wrapper__c == TRUE && oppchrg.invoiceit_crmx__Unit_Price__c < oppchrg.Floor_Price__c)){                
                    if(oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c > 20 && oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c <= 30)
                    salesManagerOppIds.add(oppchrg.invoiceit_crmx__Opportunity__c);
            }
            else if(oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c > 20 && oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c <= 30){
                    salesManagerOppIds.add(oppchrg.invoiceit_crmx__Opportunity__c);
            }
            system.debug('discount percent::::'+oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c);   
            if(oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c > 30 && oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c <= 50){
                    salesVPOppIds.add(oppchrg.invoiceit_crmx__Opportunity__c);
            }
            
            if(oppchrg.invoiceit_crmx__Opportunity__r.invoiceit_crmx__Discount_Percent__c > 50){
                    salesFinanceOppIds.add(oppchrg.invoiceit_crmx__Opportunity__c);
            }
               
        }
        system.debug('salesRepOppIds:::'+salesRepOppIds);
        system.debug('salesManagerOppIds:::'+salesManagerOppIds);
        system.debug('salesVPOppIds:::'+salesVPOppIds);
        system.debug('salesFinanceOppIds:::'+salesFinanceOppIds);
            
         if(salesRepOppIds.size() > 0)
            OppIds.addAll(salesRepOppIds);
            else if(salesManagerOppIds.size() > 0)
            OppIds.addAll(salesManagerOppIds);
            else if(salesVPOppIds.size() > 0)
            OppIds.addAll(salesVPOppIds);
            else if(salesFinanceOppIds.size() > 0)
            OppIds.addAll(salesFinanceOppIds);
            
         Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
            for(Opportunity op:[select id,Need_Approval__c from Opportunity where Id IN: OppIds]){
                oppMap.put(op.Id,op);
            }
            
            if(salesRepOppIds.size() > 0){
                for(Id oid:salesRepOppIds){
                    Opportunity opp = oppMap.get(oid);
                    opp.Need_Approval__c = 'Sales Reps';
                    opptysToUpdateList.add(opp);
                }
            }
            else if(salesManagerOppIds.size() > 0){
                for(Id oid:salesManagerOppIds){
                    Opportunity opp = oppMap.get(oid);
                    opp.Need_Approval__c = 'Sales Manager';
                    opptysToUpdateList.add(opp);
                }
            }
            else if(salesVPOppIds.size() > 0){
                for(Id oid:salesVPOppIds){
                    Opportunity opp = oppMap.get(oid);
                    opp.Need_Approval__c = 'Sales VP';
                    opptysToUpdateList.add(opp);
                }
            }            
            else if(salesFinanceOppIds.size() > 0){
                for(Id oid:salesFinanceOppIds){
                    Opportunity opp = oppMap.get(oid);
                    opp.Need_Approval__c = 'Finance Director';
                    opptysToUpdateList.add(opp);
                }
            }
            system.debug('opptysToUpdateList::::'+opptysToUpdateList);            
            if(opptysToUpdateList.size() > 0){
                update opptysToUpdateList;
            }
          } 
    }
}