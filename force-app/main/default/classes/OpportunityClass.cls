public with sharing class OpportunityClass {
    public Opportunity opportunity;
    public List<OpportunityProductClass> opportunityProducts = new List<OpportunityProductClass>();
    public List<OpportunityProductClass> getOpportunityProducts() {
        return opportunityProducts;
    }
    
    public Opportunity getOpportunity() {
        return opportunity;
    }
}