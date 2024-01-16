public with sharing class OpportunityProductClass {
    public invoiceit_crmx__Opportunity_Product__c Opportunityproduct {get; set;}
    public OpportunityRatePlanClass[] OpportunityRatePlans = new List<OpportunityRatePlanClass>();
    public Integer OpportunityProductCounter{get; set;}
    
    public List<OpportunityRatePlanClass> getOpportunityRatePlans() {
        return OpportunityRatePlans;
    }
}