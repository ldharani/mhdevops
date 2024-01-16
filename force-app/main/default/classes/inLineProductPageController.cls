/*Apex class responsible for displaying product and charge in information in line page of order layout
 * 
 */

public with sharing class inLineProductPageController {
    private ApexPages.StandardController controller {get;set;}
    public invoiceit_s__Job__c job{get;set;}
    public JobProductClass jobProductClass {get;set;}
    public JobClass jobClass {get;set;}
    public JobRatePlanClass jobRatePlanClass {get;set;}
    public OrderChargeAttributeClass orderChargeAttributeclsObj{get;set;}
    public JobRatePlanChargeClass jobRatePlanChargeClass = new JobRatePlanChargeClass();
    public List<invoiceit_s__Job_Product__c> listJobProducts = new List<invoiceit_s__Job_Product__c>();
    public List<invoiceit_s__Job_Rate_Plan__c> listJobRatePlans = new  List<invoiceit_s__Job_Rate_Plan__c>();
    public Map<Id,JobProductClass> mapJobProducts = new  Map<Id,JobProductClass>();
    public String sRedColor {get;set;} 
    private Integer jobProductCounter = 0;
    private Integer jobRatePlanCounter = 0;
    private Integer jobRateplanChargeCounter = 0;
    private Integer orderChargeAttributeCounter = 0;

    public inLineProductPageController(ApexPages.StandardController stdController) {
        try {
            //string which is used to diaplay if their is no value present in attribute value
            sRedColor ='<b><font size="2" color="red">NULL</font><b>';
            this.controller = stdController;
            this.job = (invoiceit_s__Job__c)stdController.getRecord();
            jobClass = new JobClass();
            jobClass.job = job;
            if(job.id != null) {
                this.job = JobCreationUtil.getJob(job.id);
                System.debug('Printing job'+job);
                jobClass.job = job;
                listJobProducts = JobCreationUtil.getListJobProducts(job.id);
                //iterating jobproducats and assigning to the variable of job product class
                for(invoiceit_s__Job_Product__c qp : listJobProducts) {
                    jobProductClass = new JobProductClass();
                    jobProductClass.jobProductCounter = ++jobProductCounter;
                    jobProductClass.jobproduct = qp;
                    jobClass.jobProducts.add(jobProductClass);
                }
                //get the list of jobProduct Ids in to Map
                mapJobProducts = JobCreationUtil.getMapJobProducts(listJobProducts);
                Set<Id> mapJobProductKeyset = new Set<Id>();
                mapJobProductKeyset = mapJobProducts.keySet();
                List<Id> jobProductIds = new List<Id>();
                Integer mapJobProductKeysetSize = mapJobProductKeyset.size();

                //Add all the ids to list jobProductIds
                jobProductIds.addAll(mapJobProductKeyset);

                //getting map of charge id with list of attributes
                map<Id, list<Order_Charge_Attribute__c>> map_JobChargeId_Attributes = JobCreationUtil.queryattributesBasedJobId(job.Id);

                listJobRatePlans = JobCreationUtil.getListJobRatePlans(jobProductIds);
                System.debug('Printing listJobRatePlans '+listJobRatePlans .size()+'pring product details'+listJobRatePlans);
                if(listJobRatePlans != null) {
                    //get the listJobRatePlanCharges from the listJobRatePlans 
                    for(invoiceit_s__Job_Rate_Plan__c qr:listJobRatePlans ) {
                        jobProductClass = mapJobProducts.get(qr.invoiceit_s__Job_Product__c);
                        jobRatePlanClass = new JobRatePlanClass();
                        jobRatePlanClass.jobrateplan = qr;
                        for(invoiceit_s__Job_Rate_Plan_Charge__c qrpc : qr.invoiceit_s__Job_Rate_Plan_Charge__r) {
                            jobRatePlanChargeClass = new JobRatePlanChargeClass();
                            jobRatePlanChargeClass.jobrateplancharge = qrpc;
                            jobRatePlanChargeClass.jobRatePlanChargeCounter = ++jobRateplanChargeCounter;

                            //add attributes
                            if(map_JobChargeId_Attributes.containsKey(qrpc.Id)) {
                                System.debug('Inside if');   
                                for(Order_Charge_Attribute__c orderAtribute : map_JobChargeId_Attributes.get(qrpc.Id)) {
                                    if(orderAtribute.String_Value__c == null && orderAtribute.Number_Value__c == null
                                            && orderAtribute.Phone_Value__c == null && orderAtribute.Date_Value__c == null &&
                                            orderAtribute.Picklist_Value__c == null && orderAtribute.Long_text_value__c == Null &&
                                            orderAtribute.Boolean_Value__c == false){
                                        jobRatePlanChargeClass.isChecked = true;
                                    }
                                    orderChargeAttributeclsObj = new OrderChargeAttributeClass(); 
                                    orderChargeAttributeclsObj.orderChargeAttribute = orderAtribute;
                                    orderChargeAttributeclsObj.orderChargeAttributeCounter = ++orderChargeAttributeCounter;
                                    jobRatePlanChargeClass.orderChargeAttributes.add(orderChargeAttributeclsObj);
                                }
                            }
                            jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);
                        }
                        jobRatePlanClass.jobRatePlanCounter = ++jobRatePlanCounter;
                        jobProductClass.jobRatePlans.add(jobRatePlanClass);
                        mapJobProducts.put(qr.invoiceit_s__Job_Product__c,jobProductClass);  
                    }
                    Integer iJobProductSize = listJobProducts.size();
                    for(integer i = 0; i < iJobProductSize; i++) {
                        Id jobProductId = listJobProducts.get(i).Id;
                        JobProductClass qpc = mapJobProducts.get(jobProductId); 
                        qpc.jobProductCounter = ++jobProductCounter;
                        jobClass.jobProducts.add(qpc);
                    }   
                }
            }
        }catch(Exception ex){
        }
    }

}