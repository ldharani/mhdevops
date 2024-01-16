/*Apex class responsible for displaying product and charge in information in line page of opportunity layout
 * 
 */
public with sharing class inLineProductPageForOpportunityCls {
    private ApexPages.StandardController controller {get;set;}
    public Opportunity oppt{get;set;}
    public OpportunityProductClass opptProductClass {get;set;}
    public OpportunityClass opptClass {get;set;}
    public OpportunityRatePlanClass opptRatePlanClass {get;set;}
    public OpportunityAttributeClass opptAttributeclsObj{get;set;}
    public OpportunityRatePlanChargeClass opptRatePlanChargeClass = new OpportunityRatePlanChargeClass();
    public List<invoiceit_crmx__Opportunity_Product__c> listOpptProducts = new List<invoiceit_crmx__Opportunity_Product__c>();
    public List<invoiceit_crmx__Opportunity_Rate_Plan__c> listOpptRatePlans = new  List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
    public Map<Id,OpportunityProductClass> mapOpptProducts = new  Map<Id,OpportunityProductClass>();
    public String sRedColor {get;set;} 



    private Integer opptProductCounter = 0;
    private Integer opptRatePlanCounter = 0;
    private Integer opptRateplanChargeCounter = 0;
    private Integer opptAttributeCounter = 0;
    public inLineProductPageForOpportunityCls(ApexPages.StandardController stdController) {

        try {
            sRedColor ='<b><font size="2" color="red">NULL</font><b>';
            this.controller = stdController;
            this.oppt = (Opportunity)stdController.getRecord();
            opptClass = new OpportunityClass();
            opptClass.opportunity = oppt;
            if(oppt.id != null) {
                this.oppt = OpportunityCreationUtil.getOpportunity(oppt.id);
                System.debug('Printing job'+oppt);
                opptClass.opportunity = oppt;
                listOpptProducts = OpportunityCreationUtil.getListOpportunityProducts(oppt.id);
                System.debug('Printing listJobProducts '+listOpptProducts.size()+'pring product details'+listOpptProducts);
                for(invoiceit_crmx__Opportunity_Product__c qp : listOpptProducts) {
                    opptProductClass = new OpportunityProductClass();
                    opptProductClass.OpportunityProductCounter = ++opptProductCounter;
                    opptProductClass.Opportunityproduct = qp;
                    opptClass.opportunityProducts.add(opptProductClass);
                }
                //get the list of opptProduct Ids in to Map
                mapOpptProducts = OpportunityCreationUtil.getMapOpptProducts(listOpptProducts);
                Set<Id> mapOpptProductKeyset = new Set<Id>();
                mapOpptProductKeyset = mapOpptProducts.keySet();
                List<Id> opptProductIds = new List<Id>();
                Integer mapJobProductKeysetSize = mapOpptProductKeyset.size();

                //Add all the ids to list opptProductIds
                opptProductIds.addAll(mapOpptProductKeyset);
                System.debug('Printing opptProductIds '+opptProductIds.size()+'pring opptProductIds details'+opptProductIds);
                //getting map of charge id with list of attributes
                map<Id, list<Opportunity_Charge_Attribute__c>> map_OpptChargeId_Attributes = OpportunityCreationUtil.queryattributesBasedOpptId(oppt.Id);

                listOpptRatePlans = OpportunityCreationUtil.getListOpptRatePlans(opptProductIds);
                System.debug('Printing listJobRatePlans '+listOpptRatePlans.size()+'pring product details'+listOpptRatePlans);
                if(listOpptRatePlans != null) {
                    //get the listJobRatePlanCharges from the listJobRatePlans 
                    for(invoiceit_crmx__Opportunity_Rate_Plan__c qr:listOpptRatePlans ) {
                        opptProductClass = mapOpptProducts.get(qr.invoiceit_crmx__Opportunity_Product__c);
                        opptRatePlanClass = new OpportunityRatePlanClass();
                        opptRatePlanClass.opportunityRatePlan = qr;
                        System.debug('Printing charge list '+qr.invoiceit_crmx__Opportunity_Rate_Plan_Charges__r.size()+'pring charge details--->'+qr.invoiceit_crmx__Opportunity_Rate_Plan_Charges__r);
                        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c qrpc : qr.invoiceit_crmx__Opportunity_Rate_Plan_Charges__r) {
                            opptRatePlanChargeClass = new OpportunityRatePlanChargeClass();
                            opptRatePlanChargeClass.opportunityRatePlanCharge = qrpc;
                            opptRatePlanChargeClass.opportunityRatePlanChargeCounter = ++opptRateplanChargeCounter;

                            //add attributes

                            if(map_OpptChargeId_Attributes.containsKey(qrpc.Id)) {
                            System.debug('Printing all attributes--->'+map_OpptChargeId_Attributes.get(qrpc.Id));
                                for(Opportunity_Charge_Attribute__c opptAtribute : map_OpptChargeId_Attributes.get(qrpc.Id)) {
                                    if(opptAtribute.String_Value__c == null && opptAtribute.Number_Value__c == null
                                        && opptAtribute.Phone_Value__c == null && opptAtribute.Date_Value__c == null &&
                                        opptAtribute.Picklist_Value__c == null &&
                                        opptAtribute.Boolean_Value__c == false && opptAtribute.Long_text_value__c == null){
  
                                            opptRatePlanChargeClass.isChecked = true;
                                    }else if(opptAtribute.Attribute_Name__c == 'AOP/Geo 1' && (opptAtribute.String_Value__c == ';  ;   N/A   ;  ;' || opptAtribute.String_Value__c == ';  ;  N/A  ;  ;' || opptAtribute.String_Value__c == ';  ;    N/A    ;  ;')){
                                     //else if(opptAtribute.Attribute_Name__c == 'AOP/Geo 1' && opptAtribute.Picklist_Value__c == '' && opptAtribute.CountryState_String__c == 'N/A' && opptAtribute.Address_String__c == ''){
                                        system.debug('in else if');
                                        opptRatePlanChargeClass.isChecked = true;
                                    }
                                    system.debug('opptAtribute.String_Value__c'+opptAtribute.String_Value__c);
                                    opptAttributeclsObj = new OpportunityAttributeClass(); 
                                    opptAttributeclsObj.opptChargeAttribute = opptAtribute;
                                    opptAttributeclsObj.opptChargeAttributeCounter = ++opptAttributeCounter;
                                    opptRatePlanChargeClass.opptChargeAttributes.add(opptAttributeclsObj);
                                }
                            }
                            opptRatePlanClass.opportunityRatePlanCharges.add(opptRatePlanChargeClass);

                        }
                        opptRatePlanClass.opportunityRatePlanCounter = ++opptRatePlanCounter;
                        opptProductClass.OpportunityRatePlans.add(opptRatePlanClass);
                        mapOpptProducts.put(qr.invoiceit_crmx__Opportunity_Product__c,opptProductClass);

                    }

                    Integer iOpptProductSize = listOpptProducts.size();
                    for(integer i = 0; i < iOpptProductSize; i++) {
                        Id opptProductId = listOpptProducts.get(i).Id;
                        OpportunityProductClass qpc = mapOpptProducts.get(opptProductId); 
                        qpc.OpportunityProductCounter = ++opptProductCounter;
                        opptClass.opportunityProducts.add(qpc);
                    }   
                }
            }
        }catch(Exception ex){
        }
    }

}