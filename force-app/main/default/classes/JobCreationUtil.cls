/* apex class responsible for querying order information 
 * 
 */
public with sharing class JobCreationUtil {

    public JobCreationUtil(){

    }
    public static invoiceit_s__Job__c getJob(Id id)
    {
        String query = CommonUtilClass.getObjectSelectQuery('invoiceit_s__Job__c');
        query = query + ' WHERE Id =\'' + String.escapeSingleQuotes(id) + '\'';
        query = String.escapeSingleQuotes(query);
        query = query.replace('\\','');
        invoiceit_s__Job__c job = Database.query(query);
        return job;
    }

    public static List<invoiceit_s__Job_Product__c> getListJobProducts(Id jobId)
    {
        // String queryString = CommonUtilClass.getObjectSelectQuery('Job_Product__c') + 'where  Job__c = \'' + jobId + '\' order by SequenceNumber__c';
        string queryString ='SELECT invoiceit_s__Product__r.Name, ' + CommonUtilClass.getObjectFields('invoiceit_s__Job_Product__c') + ' From invoiceit_s__Job_Product__c where  invoiceit_s__Job__c = \'' + jobId + '\' order by invoiceit_s__SequenceNumber__c';
        queryString = String.escapeSingleQuotes(queryString);
        queryString = queryString.replace('\\','');

        invoiceit_s__Job_Product__c  [] jobProducts = database.query(queryString);                                  
        return jobproducts;
    }

    public static Map<Id,JobProductClass> getMapJobProducts(List<invoiceit_s__Job_Product__c> listJobProducts)
    {
        Map<Id,JobProductClass> mapJobProducts = new Map<Id,JobProductClass>();
        for(invoiceit_s__Job_Product__c qp : listJobProducts)
        {
            JobProductClass jobProductClass = new JobProductClass();
            jobProductClass.jobproduct = qp;

            mapJobProducts.put(qp.id,jobProductClass);
        }
        return mapJobProducts;
    }

    /**
     * This method get ListJobRatePlans
     * @return charges
     */
    public static List<invoiceit_s__Job_Rate_Plan__c> getListJobRatePlans(List<Id> jobProductIds)
    {
        if(jobProductIds.size() > 0){
            string sQuoteProductIds = CommonUtilClass.convertListOfIdsIntoString(jobProductIds);
            String sQuery =  'SELECT ' + CommonUtilClass.getObjectFields('invoiceit_s__Job_Rate_Plan__c') + ',' 
            + '(SELECT ' + CommonUtilClass.getObjectFields('invoiceit_s__Job_Rate_Plan_Charge__c') +  'from invoiceit_s__Job_Rate_Plan_Charge__r Order by invoiceit_s__Sequence_No__c)'
            + 'from invoiceit_s__Job_Rate_Plan__c where invoiceit_s__Job_Product__c IN (' + sQuoteProductIds  + ') Order By invoiceit_s__Job_Rate_Plan__c.invoiceit_s__Job_Product__r.invoiceit_s__SequenceNumber__c,invoiceit_s__SequenceNumber__c';

            //system.debug('sQuery is '+ sQuery);
            invoiceit_s__Job_Rate_Plan__c [] jobRatePlans = Database.query(sQuery);

            return jobRatePlans;  
        }
        else {
            return null;
        }                                             
    }

    public static map<Id, list<Order_Charge_Attribute__c>> queryattributesBasedJobId(string jobId) 
    {
        map<Id, list<Order_Charge_Attribute__c>> map_JobCharge_Attribute = new map<Id, list<Order_Charge_Attribute__c>>();
        list<Order_Charge_Attribute__c> jobAttributes = [SELECT Attribute_Order__c, Order_Rate_Plan_Charge__c,Attribute_Type__c, Attribute_Name__c,Attr_Name__c, Boolean_Value__c,Long_text_value__c, Date_Value__c,Number_Value__c,Phone_Value__c,Picklist_Value__c,String_Value__c
                                                         FROM Order_Charge_Attribute__c
                                                         WHERE  Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c  =: jobId
                                                         ORDER BY Address_Order__c ASC,Attribute_Order__c DESC NULLS LAST];

        list<Order_Charge_Attribute__c> OrderAttributesLocalVar;
        for(Order_Charge_Attribute__c orderAttribute : jobAttributes) {
            if(map_JobCharge_Attribute.containsKey(orderAttribute.Order_Rate_Plan_Charge__c)) {
                OrderAttributesLocalVar = map_JobCharge_Attribute.get(orderAttribute.Order_Rate_Plan_Charge__c);
            } else {
                OrderAttributesLocalVar = new list<Order_Charge_Attribute__c>();
            }

            OrderAttributesLocalVar.add(orderAttribute);
            map_JobCharge_Attribute.put(orderAttribute.Order_Rate_Plan_Charge__c, OrderAttributesLocalVar);
        }

        return map_JobCharge_Attribute;
    }    



}