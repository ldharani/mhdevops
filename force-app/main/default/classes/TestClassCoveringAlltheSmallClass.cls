@isTest(seeallData=true)
private class TestClassCoveringAlltheSmallClass {
    static testMethod void myUnitTest2() {
    
        OrderChargeAttributeClass ordeChargecls = new OrderChargeAttributeClass();
        
        JobRatePlanChargeClass jobRatePlanChargeClass = new JobRatePlanChargeClass();
        jobRatePlanChargeClass.orderChargeAttributes = new List<OrderChargeAttributeClass>();
        jobRatePlanChargeClass.orderChargeAttributes.add(ordeChargecls );
        jobRatePlanChargeClass .getorderChargeAttributes();
        
        JobRatePlanClass jobPlancls = new JobRatePlanClass();
        jobPlancls.jobRatePlanCharges = new List<JobRatePlanChargeClass>();
        jobPlancls.jobRatePlanCharges.add(jobRatePlanChargeClass);
        jobPlancls.getJobRatePlanCharges();
        
        JobProductClass jobProduct = new JobProductClass();
        jobProduct.jobRatePlans = new List<JobRatePlanClass>();
        jobProduct.jobRatePlans.add(jobPlancls );
        jobProduct.getJobRatePlans();
        
        JobClass jobclas = new JobClass();
        jobclas.jobProducts = new List<JobProductClass>();
        jobclas.getJob();
        jobclas.getJobProducts();
        
        //for oppt
        OpportunityAttributeClass optcls = new OpportunityAttributeClass();
        
        OpportunityRatePlanChargeClass opptPlanChargeClass = new OpportunityRatePlanChargeClass ();
        opptPlanChargeClass.opptChargeAttributes= new List<OpportunityAttributeClass>();
        opptPlanChargeClass.opptChargeAttributes.add(optcls);
        opptPlanChargeClass.getopptChargeAttributes();
        
        OpportunityRatePlanClass optPlancls = new OpportunityRatePlanClass();
        optPlancls.opportunityRatePlanCharges = new List<OpportunityRatePlanChargeClass>();
        optPlancls.opportunityRatePlanCharges.add(opptPlanChargeClass);
        optPlancls.getOpportunityRatePlanCharges();
        
        OpportunityProductClass optProduct = new OpportunityProductClass();
        optProduct.OpportunityRatePlans = new List<OpportunityRatePlanClass >();
        optProduct.OpportunityRatePlans.add(optPlancls );
        optProduct.getOpportunityRatePlans();
        
        OpportunityClass optclas = new OpportunityClass();
        optclas.opportunityProducts = new List<OpportunityProductClass>();
        optclas.getOpportunityProducts();
        optclas.getOpportunity();
        
    }
}