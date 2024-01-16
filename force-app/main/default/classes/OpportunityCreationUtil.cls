/*Apex class responsible for fetching opportunity information 
 * 
 */
public with sharing class OpportunityCreationUtil {

    public OpportunityCreationUtil(){

    }
    public static Opportunity getOpportunity(Id id)
    {
        String query = CommonUtilClass.getObjectSelectQuery('Opportunity');
        query = query + ' WHERE Id =\'' + String.escapeSingleQuotes(id) + '\'';
        query = String.escapeSingleQuotes(query);
        query = query.replace('\\','');
        Opportunity oppt = Database.query(query);
        return oppt;
    }

    public static List<invoiceit_crmx__Opportunity_Product__c> getListOpportunityProducts(Id opptId)
    {

        string queryString ='SELECT invoiceit_crmx__Product__r.Name, ' + CommonUtilClass.getObjectFields('invoiceit_crmx__Opportunity_Product__c') + ' From invoiceit_crmx__Opportunity_Product__c where  invoiceit_crmx__Opportunity__c = \'' + opptId + '\' order by invoiceit_crmx__SequenceNumber__c';
        queryString = String.escapeSingleQuotes(queryString);
        queryString = queryString.replace('\\','');

        invoiceit_crmx__Opportunity_Product__c  [] opptProducts = database.query(queryString);                                  
        return opptProducts;
    }

    public static Map<Id,OpportunityProductClass> getMapOpptProducts(List<invoiceit_crmx__Opportunity_Product__c> listOpptProducts)
    {
        Map<Id,OpportunityProductClass> mapOpptProducts = new Map<Id,OpportunityProductClass>();
        for(invoiceit_crmx__Opportunity_Product__c qp : listOpptProducts)
        {
            OpportunityProductClass OpptProductClass = new OpportunityProductClass();
            OpptProductClass.Opportunityproduct = qp;

            mapOpptProducts.put(qp.id,OpptProductClass);
        }
        return mapOpptProducts;
    }

    /**
     * This method get ListJobRatePlans
     * @return charges
     */
    public static List<invoiceit_crmx__Opportunity_Rate_Plan__c> getListOpptRatePlans(List<Id> OpptProductIds)
    {
        if(OpptProductIds.size() > 0){
            string sQuoteProductIds = CommonUtilClass.convertListOfIdsIntoString(OpptProductIds);
            String sQuery =  'SELECT ' + CommonUtilClass.getObjectFields('invoiceit_crmx__Opportunity_Rate_Plan__c') + ',' 
            + '(SELECT ' + CommonUtilClass.getObjectFields('invoiceit_crmx__Opportunity_Rate_Plan_Charge__c') +  'from invoiceit_crmx__Opportunity_Rate_Plan_Charges__r Order by invoiceit_crmx__Sequence_No__c)'
            + 'FROM invoiceit_crmx__Opportunity_Rate_Plan__c where invoiceit_crmx__Opportunity_Product__c IN (' + sQuoteProductIds  + ') Order By invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__SequenceNumber__c ,invoiceit_crmx__SequenceNumber__c';

            //system.debug('sQuery is '+ sQuery);
            invoiceit_crmx__Opportunity_Rate_Plan__c [] OpptRatePlans = Database.query(sQuery);

            return OpptRatePlans;  
        }
        else {
            return null;
        }                                             
    }


    public static map<Id, list<Opportunity_Charge_Attribute__c>> queryattributesBasedOpptId(string OpptId) 
    {
        map<Id, list<Opportunity_Charge_Attribute__c>> map_OpptCharge_Attribute = new map<Id, list<Opportunity_Charge_Attribute__c>>();
        list<Opportunity_Charge_Attribute__c> opptAttributes = [SELECT Attribute_Order__c, Opportunity_Rate_Plan_Charge__c,Attribute_Type__c, Attribute_Name__c,Long_text_value__c,Attr_Name__c, Boolean_Value__c, Date_Value__c,Number_Value__c,Phone_Value__c,Picklist_Value__c,String_Value__c
                                                                FROM Opportunity_Charge_Attribute__c
                                                                WHERE   Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c   =: OpptId
                                                                ORDER BY Address_Order__c ASC,Attribute_Order__c DESC NULLS LAST];

        list<Opportunity_Charge_Attribute__c> opptAttributesLocalVar;
        for(Opportunity_Charge_Attribute__c opptAttribute : opptAttributes) {
            if(map_OpptCharge_Attribute.containsKey(opptAttribute.Opportunity_Rate_Plan_Charge__c)) {
                opptAttributesLocalVar = map_OpptCharge_Attribute.get(opptAttribute.Opportunity_Rate_Plan_Charge__c);
            } else {
                opptAttributesLocalVar = new list<Opportunity_Charge_Attribute__c>();
            }

            opptAttributesLocalVar.add(opptAttribute);
            map_OpptCharge_Attribute.put(opptAttribute.Opportunity_Rate_Plan_Charge__c, opptAttributesLocalVar);
        }

        return map_OpptCharge_Attribute;
    }    


}