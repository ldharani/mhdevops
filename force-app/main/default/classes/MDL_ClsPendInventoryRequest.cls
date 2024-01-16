/*
 *
 * Created By 		:	Lister Technologies
 * Creation Date 	:	17/04/2014
 * Purpose			:	To send pendinventory request on button click from Opportunity
 *
*/
public with sharing class MDL_ClsPendInventoryRequest {
	private ApexPages.StandardController standardController;
	//opportunity object
	public Opportunity oppRecord;
	//string to get opportunity id
	public String oppid{get;set;}
	public List<invoiceit_crmx__Opportunity_Product__c> oppProductList;
	public Set<Id> setOppProductids;
	public MDL_ClsPendInventoryRequest(ApexPages.StandardController standardController) {
		this.standardController = standardController;
		oppid=standardController.getId();
		oppProductList = new List<invoiceit_crmx__Opportunity_Product__c>();
		setOppProductids = new Set<Id>();
		oppRecord = new Opportunity();
	}
	public PageReference sendPendInventoryRequest() {
		Restrict_Integration_Calls__c endPts = Restrict_Integration_Calls__c.getValues('Restrict');
		System.debug('**'+endPts);
		Boolean a = Boolean.valueOf(endPts.Restrict_Callouts__c);
		System.debug('a values is **'+a);
		oppRecord = [Select o.Id, o.Account.MH_Cust_Number__c ,o.AccountId From Opportunity o where o.Id =: oppid];
		User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        String userName = u.Username;
		oppProductList = [Select i.invoiceit_crmx__Product__c, i.invoiceit_crmx__Product_Family__c, i.invoiceit_crmx__Product_Code__c, 
							 	 i.invoiceit_crmx__Opportunity__c, i.invoiceit_crmx__Description__c, i.Name, i.IsInventoried__c, i.InventoryId__c, 
							 	 i.Id From invoiceit_crmx__Opportunity_Product__c i where i.invoiceit_crmx__Opportunity__c =:oppid and RecordType.DeveloperName = 'MDL_Opportunity_Product'];
		for(invoiceit_crmx__Opportunity_Product__c oppProducts : oppProductList) {
			if(oppProducts.IsInventoried__c == 'true' && (oppProducts.InventoryId__c == null || oppProducts.InventoryId__c == '')) {
				setOppProductids.add(oppProducts.Id);
			}
		}
		System.debug('$$$size of inventorable prod list is $$$'+setOppProductids.size());
		System.debug('###set of inventorable products###'+setOppProductids);
		//getting attributes values
        List<Opportunity_Charge_Attribute__c> lstAttributes = new List<Opportunity_Charge_Attribute__c>();
		Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
		List<Id> lstRatePlanIDs = new List<Id>();
		List<Id> lstRatePlanChargeIDs = new List<Id>();
		List<invoiceit_crmx__Opportunity_Rate_Plan__c> lstOppRatePlans = [Select i.invoiceit_crmx__Opportunity_Product__c, i.Name, i.Id From invoiceit_crmx__Opportunity_Rate_Plan__c i where i.invoiceit_crmx__Opportunity_Product__c =: setOppProductids and RecordType.DeveloperName = 'MDL_Opportunity_Rate_Plan'];
		for(invoiceit_crmx__Opportunity_Rate_Plan__c rp : lstOppRatePlans) {
			lstRatePlanIDs.add(rp.Id);
		}
		List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> lstOppRatePlanCharges = [Select i.invoiceit_crmx__Opportunity_Rate_Plan__c, i.Name, i.Id From invoiceit_crmx__Opportunity_Rate_Plan_Charge__c i where i.invoiceit_crmx__Opportunity_Rate_Plan__c in : lstRatePlanIDs and RecordType.DeveloperName = 'MDL_Opportunity_Rate_Plan_Charge'];
		System.debug('Opportunity Rate plan charge query:'+lstOppRatePlanCharges);
		for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c ch : lstOppRatePlanCharges) {
			lstRatePlanChargeIDs.add(ch.Id);
		}
		for(Opportunity_Charge_Attribute__c oppAttributes : [Select o.String_Value__c, o.Boolean_Value__c, o.Date_Value__c, o.Number_Value__c, o.Phone_Value__c, o.Picklist_Value__c, o.Opportunity_Rate_Plan_Charge__c, o.Name, o.Id, o.Attribute_Name__c,o.Attribute_Type__c From Opportunity_Charge_Attribute__c o where o.Opportunity_Rate_Plan_Charge__c in : lstRatePlanChargeIDs and RecordType.DeveloperName = 'MDL_Opportunity_Charge_Attribute']) {
			lstAttributes.add(oppAttributes);
		}
		System.debug('Opportunity Charge Attributes:'+lstAttributes);
		for(Opportunity_Charge_Attribute__c att: lstAttributes) {
			if(att.Attribute_Type__c == 'Text')
				mapAttributeNameAndValue.put(att.Attribute_Name__c,att.String_Value__c);
			else if(att.Attribute_Type__c == 'Picklist')
				mapAttributeNameAndValue.put(att.Attribute_Name__c,att.Picklist_Value__c);
			else if(att.Attribute_Type__c == 'Number')
				mapAttributeNameAndValue.put(att.Attribute_Name__c,String.valueOf(att.Number_Value__c));
			else if(att.Attribute_Type__c == 'Boolean')
				mapAttributeNameAndValue.put(att.Attribute_Name__c,String.valueOf(att.Boolean_Value__c));
			else if(att.Attribute_Type__c == 'Date')
				mapAttributeNameAndValue.put(att.Attribute_Name__c,String.valueOf(att.Date_Value__c));
		}
		System.debug('MapAttributes'+mapAttributeNameAndValue);
		//end of atributes value
		
		//if restrict integration custom setting is set to true , error will be thrown 
		if(a==true) {
			apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'No callouts will be sent because Custom Setting for restricting callouts is enabled.Please disable that and then proceed to pend the products');
        	apexpages.addMessage(am);	
        	return null;
		}
		
		
		if(setOppProductids.size() > 0) {
			for(String attValue : mapAttributeNameAndValue.values()) {System.debug('attValue is :::'+attValue);
				if(attValue == null || attValue == '') {
					apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Inventory cannot be pended if any of the attribute values are null.Please fill in attribute values before pending the inventory');
                	apexpages.addMessage(am);	
                	return null;
				}
			}
			//if(oppRecord.Account.MH_Cust_Number__c != null)
				if(!Test.isRunningTest())
					MDL_Integration_Vim_Efs.pendInventoryRequest(setOppProductIds,oppRecord.Account.MH_Cust_Number__c,userName,oppRecord.Account.Id);
			/*else {
				apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Customer Number cannot be null.Please enter customer number for the account');
                apexpages.addMessage(am);	
                return null;			
			}*/
		}
		else {
				apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'No inventorable products exists in the opportunity currently.Please add inventorable products to pend them ');
                apexpages.addMessage(am);	
                return null;
		}
		return new PageReference('/'+oppid);
	}
	public PageReference cancel() {
		return new PageReference('/'+oppid);
	}
}