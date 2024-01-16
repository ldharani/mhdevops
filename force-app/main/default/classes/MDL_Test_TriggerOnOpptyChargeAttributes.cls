@isTest(seealldata=true)
public with sharing class MDL_Test_TriggerOnOpptyChargeAttributes {
    static testmethod void testblankInventoryId(){
        List<Opportunity_Charge_Attribute__c> optyChargeAttrList = new List<Opportunity_Charge_Attribute__c>();
        Map<Id, Opportunity_Charge_Attribute__c> oldMap = new Map<Id, Opportunity_Charge_Attribute__c>();
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod1 = util.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        Test.startTest();
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
        oppprod1.InventoryId__c = '110111';
        update oppprod1;
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc.Id);
        
        Opportunity_Charge_Attribute__c oppCharge1 = util.getOppCharges(opprpc.Id,'Text','Country');
        optyChargeAttrList.add(oppCharge1);
        Opportunity_Charge_Attribute__c oppCharge2 = util.getOppCharges(opprpc.Id,'Text','State');  
        optyChargeAttrList.add(oppCharge2);
        /*Opportunity_Charge_Attribute__c oppCharge3 = util.getOppCharges(opprpc.Id,'Picklist','City');   
        optyChargeAttrList.add(oppCharge3);
        Opportunity_Charge_Attribute__c oppCharge4 = util.getOppCharges(opprpc.Id,'Picklist','AOP');    
        optyChargeAttrList.add(oppCharge4);*/
        
        oppprod1.InventoryId__c = '';
        update oppprod1;
        for(Opportunity_Charge_Attribute__c optyAttr:optyChargeAttrList){
            if(optyAttr.Attr_Name__c == 'Country'){
                optyAttr.String_Value__c = 'Country1';
            }
            /*if(optyAttr.Attr_Name__c == 'State'){
                optyAttr.Picklist_Value__c = 'NJ';
            }
            if(optyAttr.Attr_Name__c == 'City'){
                optyAttr.Picklist_Value__c = 'Iselin';
            }
            if(optyAttr.Attr_Name__c == 'AOP'){
                optyAttr.Picklist_Value__c = 'Mail Fraud';
            }*/
        }
        update optyChargeAttrList;
        opprpc.Country_Attribute__c = 'Country1';
        update opprpc;
        /*opprpc.State_Attribute__c = 'NJ';
        update opprpc;
        opprpc.City_County_attribute__c = 'Iselin';
        update opprpc;
        opprpc.AOP_Name__c = 'Mail Fraud';
        update opprpc;*/
        MDL_TrgHandlerForOpptyChargeAttributes.populateGeoLocationValonOptyRPC(optyChargeAttrList, oldMap);
        //MDL_TrgHandlerForOpptyChargeAttributes.blankInventoryId(optyChargeAttrList, oldMap);
             
        MDL_TrgHandlerForOpptyChargeAttributes oppHandlr = new MDL_TrgHandlerForOpptyChargeAttributes();
        
        oppHandlr.FkMethod();
        Test.stopTest();
        
    }
}