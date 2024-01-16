public with sharing class OpportunityRatePlanChargeClass {
    public invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opportunityRatePlanCharge {get; set;}
    public Integer opportunityRatePlanChargeCounter {get; set;}
    public OpportunityAttributeClass[] opptChargeAttributes = new List<OpportunityAttributeClass>();
    public Boolean isChecked{get;set;}
    public List<OpportunityAttributeClass> getopptChargeAttributes()
    {
        return opptChargeAttributes;
    }
}