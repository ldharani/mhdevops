public with sharing class JobRatePlanChargeClass {
    public invoiceit_s__Job_Rate_Plan_Charge__c jobrateplancharge {get;set;}
    public Integer jobRatePlanChargeCounter {get;set;}
    public Boolean isChecked{get;set;}
    public OrderChargeAttributeClass[] orderChargeAttributes = new List<OrderChargeAttributeClass>();
    public List<OrderChargeAttributeClass> getorderChargeAttributes()
    {
        return orderChargeAttributes;
    }
}