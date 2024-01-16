public with sharing class OpportunityRatePlanClass {
    public invoiceit_crmx__Opportunity_Rate_Plan__c opportunityRatePlan {get; set;}
    public OpportunityRatePlanChargeClass [] opportunityRatePlanCharges = new List<OpportunityRatePlanChargeClass>();
    public List<OpportunityRatePlanChargeClass> getOpportunityRatePlanCharges()
    {
        return opportunityRatePlanCharges;
    }
    public Integer opportunityRatePlanCounter {get; set;}
}