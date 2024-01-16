public with sharing class Childorderdetails{ 
 
 
    public static JobClass populatechildJobClass(invoiceit_s__Job__c order) {
        Map<Id,JobProductClass> mapJobProducts = new  Map<Id,JobProductClass>();
        JobClass jobClass = new JobClass();
        Integer jobProductCounter = 0;
        Integer jobRatePlanCounter = 0;
        Integer jobRateplanChargeCounter = 0;
        Integer jobRatePlanChargeTierCounter = 0;
        Integer iJobProductSequenceNo = 1;
        Integer iJobRatePlanSequenceNo = 1;
        List<invoiceit_s__Job_Product__c> listJobProducts = new List<invoiceit_s__Job_Product__c>();
        List<invoiceit_s__Job_Rate_Plan__c> listJobRatePlans = new List<invoiceit_s__Job_Rate_Plan__c>();
        JobProductClass jobProductClass;
        JobRatePlanClass jobRatePlanClass;
        JobRatePlanChargeClass jobRatePlanChargeClass;

        jobClass.job = order;
        system.debug('@@@@order.id'+order.id);
        string queryStringJP ='SELECT ' + getObjectFields('invoiceit_s__Job_Product__c') + ' From invoiceit_s__Job_Product__c WHERE invoiceit_s__Job__c = \'' + order.Id + '\' order by invoiceit_s__SequenceNumber__c';
        System.Debug('====queryStringJP======'+queryStringJP);
        listJobProducts = Database.query(queryStringJP);

        //add listJobProducts to jobProductClass
        for(invoiceit_s__Job_Product__c qp : listJobProducts) {
            jobProductClass = new JobProductClass();
            jobProductClass.jobProductCounter = ++jobProductCounter;
            jobProductClass.jobproduct = qp;
            jobClass.jobProducts.add(jobProductClass);

            mapJobProducts.put(qp.Id, jobProductClass);
        }
        //get the list of jobProduct Ids in to Map
        Set<Id> mapJobProductKeyset = new Set<Id>();
        mapJobProductKeyset = mapJobProducts.keySet();
        List<Id> jobProductIds = new List<Id>();
        Integer mapJobProductKeysetSize = mapJobProductKeyset.size();

        //Add all the ids to list jobProductIds
        jobProductIds.addAll(mapJobProductKeyset);

        date todaysDate = system.today();
        String sQueryJRPs = 'SELECT ' + getObjectFields('invoiceit_s__Job_Rate_Plan__c') + ',' 
        + '(SELECT ' + getObjectFields('invoiceit_s__Job_Rate_Plan_Charge__c') + 
            ', RecordType.DeveloperName,invoiceit_s__Order__r.invoiceit_s__Status__c, ' +
             ' Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c '+
              ' FROM invoiceit_s__Job_Rate_Plan_Charge__r WHERE  invoiceit_s__Status__c = \'Active\' Order by invoiceit_s__Sequence_No__c) '
        + 'FROM invoiceit_s__Job_Rate_Plan__c WHERE invoiceit_s__Job_Product__c IN: jobProductIds Order By invoiceit_s__Job_Rate_Plan__c.invoiceit_s__Job_Product__r.invoiceit_s__SequenceNumber__c, invoiceit_s__SequenceNumber__c';

        system.debug('sQueryJRPs is ' + sQueryJRPs);
        //getListJobRatePlans returns listJobRatePlans 
        listJobRatePlans = Database.query(sQueryJRPs);
        
        System.Debug('listJobRatePlans'+listJobRatePlans);
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

                    jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);
                }

                jobRatePlanClass.jobRatePlanCounter = ++jobRatePlanCounter;
                jobProductClass.jobRatePlans.add(jobRatePlanClass);

                mapJobProducts.put(qr.invoiceit_s__Job_Product__c, jobProductClass);
            }

            jobClass = new JobClass();
            jobClass.job = order;
            Integer iJobProductSize = listJobProducts.size();
            for(integer i = 0; i < iJobProductSize; i++) {
                Id jobProductId = listJobProducts.get(i).Id;
                JobProductClass qpc = mapJobProducts.get(jobProductId); 
                qpc.jobProductCounter = ++jobProductCounter;
                jobClass.jobProducts.add(qpc);
            }                   

            iJobProductSequenceNo = 1;
            for(JobProductClass jobProductClas : jobClass.jobProducts) {
                jobProductClas.jobproduct.invoiceit_s__SequenceNumber__c = iJobProductSequenceNo;
                iJobProductSequenceNo ++;
            }

            iJobRatePlanSequenceNo = 1;
            for(JobProductClass jobProductClas : jobClass.jobProducts) {
                for(JobRatePlanClass jobrateplan : jobProductClas.jobRatePlans) {
                    jobrateplan.jobrateplan.invoiceit_s__SequenceNumber__c = iJobRatePlanSequenceNo;
                    iJobRatePlanSequenceNo ++;
                }
            }
        }

        return jobClass; 
    }
    
    
    public static String getObjectSelectQuery(String objectName) {
        String sQuery = 'SELECT ';
        sQuery += getObjectFields(objectName);
        sQuery += ' FROM '+ objectName + ' ';
        return sQuery;
    }

    public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            //system.debug('column Name is ' + column + 'column permission' + column.getDescribe().isUpdateable());
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
    }
 }