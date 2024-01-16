@istest(seealldata=true)
public class BatchOrderConfirmation_Test {
        public static testmethod void runmethod1()
    {
        MDL_UtilClass_TestClass utlclass = new MDL_UtilClass_TestClass();
        account a = utlclass.getAccount();
        list<invoiceit_s__Job__c> jl = new list<invoiceit_s__Job__c>();
        system.debug(a.MH_Cust_Number__c);
        contact c = utlclass.getContact(a.id);
        invoiceit_s__Currency__c cur = utlclass.getCurrencyObject();
        invoiceit_s__Product__c prod =  utlclass.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c prt = utlclass.getProductRatePlan(prod.id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc =  utlclass.getProductRatePlanCharge(cur.id, prt.id);
        invoiceit_s__Job__c job = utlclass.getOrder(a.id, cur.id);
        job.Auth_By_Contact__c=c.id;
        update job;
        jl.add(job);
        invoiceit_s__Job_Product__c jp = utlclass.getOrderProduct(job.id, prod.id);
        invoiceit_s__Job_Rate_Plan__c ort = utlclass.getOrderRatePlan(jp.id, prt.id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc =  utlclass.getOrderRatePlanCharge(ort.id, prpc.id);
        
        system.debug('Job created Date: ' + job.CreatedDate + ' : ' + job.LastModifiedDate);
        Test.startTest();
            id batchid = database.executebatch(new BatchOrderConfirmation());
            BatchOrderConfirmation bo = new BatchOrderConfirmation();
            Database.BatchableContext bc;
            bo.execute(bc, jl);
        Test.stopTest();
    }
}