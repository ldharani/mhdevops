/*
 *
 * Created By 		:	Lister Technologies
 * Creation Date 	:	23/07/2014
 * Purpose			:	To send pendinventory request on button click from Order for products added during Mid Term Adjustments
 *
*/
public with sharing class MDL_ClsPendnventoryForMidTermProducts {
	private ApexPages.StandardController standardController;
	public invoiceit_s__Job__c orderRecord;
	public String orderId{get;set;}
	public List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList;
	public List<invoiceit_s__Job_Rate_Plan_Charge__c> newOrderRPCList;
	public Set<Id> setOrderProductids;
	public MDL_ClsPendnventoryForMidTermProducts(ApexPages.StandardController standardController) {
		this.standardController = standardController;
		orderid=standardController.getId();
		orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
		newOrderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
		setOrderProductids = new Set<Id>();
		orderRecord = new invoiceit_s__Job__c();
	}
	public Pagereference sendPendRequest() {
		
		Restrict_Integration_Calls__c endPts = Restrict_Integration_Calls__c.getValues('Restrict');
		System.debug('**'+endPts);
		Boolean a = Boolean.valueOf(endPts.Restrict_Callouts__c);
		System.debug('a values is **'+a);
		
		orderRecord = [Select o.Id, o.invoiceit_s__Account__r.MH_Cust_Number__c ,o.invoiceit_s__Account__c From invoiceit_s__Job__c o where o.Id =: orderid];
		User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        String userName = u.Username;
        Map<String,String> mapAttributeNameAndValue = new Map<String,String>();
        orderRPCList = [Select  invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c  , invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Family__c , 
								invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product_Code__c,
								invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name,invoiceit_s__Mid_Term_Status__c ,
								(Select Id, OwnerId, IsDeleted, Name, RecordTypeId, 
								Attribute_Name__c, Attribute_Order__c, Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c, 
								Date_Value__c, Maximum_No_Of_Characters_In_Text__c, Minimum_No_Of_Characters_In_Text__c, Number_Value__c, 
								Order_Rate_Plan_Charge__c, Phone_Value__c, Picklist_Value__c, String_Value__c From Order_Charge_Attributes__r),
								invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c,
								invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c,
								invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Id,invoiceit_s__Order__c 
						from invoiceit_s__Job_Rate_Plan_Charge__c
						where invoiceit_s__Order__c =: orderId and (RecordType.DeveloperName = 'MDL_Order_Rate_Plan_Charge' or RecordType.DeveloperName = 'Nolo_Order_Rate_Plan_Charge') and invoiceit_s__Mid_Term_Status__c = 'New'
						and invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.IsInventoried__c = 'true'];
		
		for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC : orderRPCList) {
			if(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c == '' || oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Inventory_Id__c == null) {
				newOrderRPCList.add(oRPC);
			}
		}
		
		for(invoiceit_s__Job_Rate_Plan_Charge__c oRPC : orderRPCList) {	
			setOrderProductids.add(oRPC.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c);			
			for(Order_Charge_Attribute__c att : oRPC.Order_Charge_Attributes__r) {
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
		}
		System.debug('MapAttributes'+mapAttributeNameAndValue);
		
		//if restrict integration custom setting is set to true , error will be thrown 
		if(a==true) {
			apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'No callouts will be sent because Custom Setting for restricting callouts is enabled.Please disable that and then proceed to pend the products');
        	apexpages.addMessage(am);	
        	return null;
		}
		
		if(orderRPCList.size() == 0) {
			apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'No inventorable products exists in the Order currently.Please add inventorable products to pend them ');
            apexpages.addMessage(am);	
            return null;
		}
		
		else {
			for(String attValue : mapAttributeNameAndValue.values()) {
				System.debug('attValue is :::'+attValue);
					if(attValue == null || attValue == '') {
						apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Inventory cannot be pended if any of the attribute values are null.Please fill in attribute values before pending the inventory');
	                	apexpages.addMessage(am);	
	                	return null;
					}
			}
			MDL_Integration_Vim_Efs.pendInventoryForMidTermProducts(userName,newOrderRPCList,mapAttributeNameAndValue,orderRecord); 
		}
		return new PageReference('/'+orderid);
	}
	public Pagereference cancel() {
		
		return new PageReference('/'+orderId);
	}
}