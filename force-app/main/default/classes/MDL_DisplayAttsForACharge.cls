/*
 *
 * Created By 		:	Lister Technologies
 * Creation Date 	:	24/07/2014
 * Purpose			:	To show a attributes for charges
 *
*/
public with sharing class MDL_DisplayAttsForACharge {
	private ApexPages.StandardController standardController;
	public invoiceit_s__Job_Rate_Plan_Charge__c orderRPC{get;set;}
	public String orderRPCId{get;set;}
	public MDL_DisplayAttsForACharge(ApexPages.StandardController standardController) {
		this.standardController = standardController;
		orderRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
		orderRPCId = standardController.getId();
		orderRPC = [Select  i.Name,(Select Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, 
								LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Attribute_Name__c, Attribute_Order__c, 
								Attribute_Picklist_Values__c, Attribute_Type__c, Boolean_Value__c, Date_Value__c, Maximum_No_Of_Characters_In_Text__c, 
								Minimum_No_Of_Characters_In_Text__c, Number_Value__c, Order_Rate_Plan_Charge__c, Phone_Value__c, Picklist_Value__c, String_Value__c
								From Order_Charge_Attributes__r)
						From invoiceit_s__Job_Rate_Plan_Charge__c i
						Where i.Id =: orderRPCId];
	}
}