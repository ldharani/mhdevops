public with sharing class JobRatePlanClass {
    public invoiceit_s__Job_Rate_Plan__c jobrateplan {get;set;}
    public JobRatePlanChargeClass [] jobRatePlanCharges = new List<JobRatePlanChargeClass>();
    public Integer jobRatePlanCounter {get;set;}
    public List<JobRatePlanChargeClass> getJobRatePlanCharges() {
        return jobRatePlanCharges;
    }
}