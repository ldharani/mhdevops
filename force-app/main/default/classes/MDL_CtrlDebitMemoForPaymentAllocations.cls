/*
 *
 * Created By 		:	Lister Technologies
 * Creation Date 	:	17/07/2014
 * Purpose			:	To perform debit memo for the selected payment allocations
 *
*/
public with sharing class MDL_CtrlDebitMemoForPaymentAllocations {
	private ApexPages.StandardController standardController;
	public invoiceit_s__Payment_Allocation__c payAlloc{get;set;}
	 public boolean haspermission {get;set;}
    public boolean dispbutton {get;set;}
	//string to get payment allocation id
	public String payAllocId{get;set;}
	public MDL_CtrlDebitMemoForPaymentAllocations(ApexPages.StandardController standardController) {
		this.standardController = standardController;
		payAllocId = standardController.getId();
		payAlloc = [Select i.invoiceit_s__Status__c, i.invoiceit_s__Payment__c, i.invoiceit_s__Invoice__c, i.invoiceit_s__Amount__c, 
																	  i.Unallocated_credits__c, i.Unallocated_Amount__c, i.RecordTypeId, i.Payment_Type__c, i.Payment_Completed_Date__c, 
																	  i.PaymentType__c, i.Name, i.Month__c, i.Id, i.Applied_Type__c, i.AppliedType__c, i.Adjustment_Reason__c, 
																	  i.AdjustmentReason__c From invoiceit_s__Payment_Allocation__c i where i.Id =: payAllocId];
		payAlloc.PaymentType__c = 'Adjustment';
		payAlloc.AppliedType__c = 'DM (Debit-Memo)';
		List<PermissionSetAssignment> listperassign = [select Assignee.Id, PermissionSet.Name, Assignee.Name, PermissionSet.Id from PermissionSetAssignment where PermissionSet.Label like '%finance%process%permissions'];
        Id userid = UserInfo.getUserId();
        if(listperassign.size()>0){
	        for(PermissionSetAssignment psa : listperassign){
	             	if(psa.Assignee.Id==userid){
	               		dispbutton = true;
	               		haspermission = true;
	               		break;
	               	}
	               	else{
	               		dispButton = false;
	               		haspermission = false;
	               	}
	        }
        }
                if(haspermission == false) {	                
	                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You don\'t have permission to create a debit memo',''); 
	                ApexPages.addMessage(errMsg);   
	           		return;
                }
	}
	public Pagereference debitMemoForPaymentAlloc() {
		System.debug('AdjustmentReason'+payAlloc.AdjustmentReason__c);
		if(payAlloc.AdjustmentReason__c != 'CCC(Credit card chargeback)' && payAlloc.AdjustmentReason__c != 'CCR(Credit card refund)' && payAlloc.AdjustmentReason__c != 'COR(To reverse a payment or a credit which was applied to an invoice so that the invoice is unpaid again)' && payAlloc.AdjustmentReason__c != 'DM(Manual Debits)' && payAlloc.AdjustmentReason__c != 'RCK(Returned check)') {
			apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Please enter some adjustment reason before clicking on Confirm');
            apexpages.addMessage(am);	
            return null;
		}
		else {
			/*invoiceit_s__Payment_Allocation__c paymentAlloc = [Select i.invoiceit_s__Status__c, i.invoiceit_s__Payment__c, i.invoiceit_s__Invoice__c, i.invoiceit_s__Amount__c, 
																	  i.Unallocated_credits__c, i.Unallocated_Amount__c, i.RecordTypeId, i.Payment_Type__c, i.Payment_Completed_Date__c, 
																	  i.PaymentType__c, i.Name, i.Month__c, i.Id, i.Applied_Type__c, i.AppliedType__c, i.Adjustment_Reason__c, 
																	  i.AdjustmentReason__c From invoiceit_s__Payment_Allocation__c i where i.Id =: payAllocId];*/
			invoiceit_s__Payment_Allocation__c reversedPayAlloc = new invoiceit_s__Payment_Allocation__c();
			reversedPayAlloc = payAlloc.clone();
			reversedPayAlloc.invoiceit_s__Amount__c = payAlloc.invoiceit_s__Amount__c * (-1);
			reversedPayAlloc.PaymentType__c = 'Adjustment';
			reversedPayAlloc.AppliedType__c = 'DM (Debit-Memo)';
			reversedPayAlloc.AdjustmentReason__c = payAlloc.AdjustmentReason__c;
			reversedPayAlloc.Original_Payment_Allocation__c = payAllocId;
			
			Database.insert(reversedPayAlloc);
			return new PageReference('/'+payAlloc.invoiceit_s__Payment__c);
		}
		
		//return new PageReference('/'+payAllocId);
	}
	public Pagereference cancel() {
		return new PageReference('/'+payAllocId);
	}
}