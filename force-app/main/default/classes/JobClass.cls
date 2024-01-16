public with sharing class JobClass {
    public invoiceit_s__Job__c job;
    public JobProductClass [] jobProducts = new List<JobProductClass>();

    public List<JobProductClass> getJobProducts() {
        return jobProducts;
    }

    public invoiceit_s__Job__c getJob() {
        return job;
    }
}