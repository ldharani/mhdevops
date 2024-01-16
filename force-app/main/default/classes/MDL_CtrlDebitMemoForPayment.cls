public with sharing class MDL_CtrlDebitMemoForPayment {
    public invoiceit_s__Payment__c payment {get;set;}
    public invoiceit_s__Payment__c clonedPayment {get;set;}
    public boolean haspermission {get;set;}
    public boolean dispbutton {get;set;}
        public MDL_CtrlDebitMemoForPayment(ApexPages.StandardController standardController){
            
                Id paymentId;   
                paymentId = standardController.getId();
                
                payment = [Select invoiceit_s__Unallocated_Amount__c, invoiceit_s__Transaction__c, 
                            invoiceit_s__Status__c, invoiceit_s__Payment_Type__c, invoiceit_s__Payment_Description__c, 
                            invoiceit_s__Payment_Date__c, invoiceit_s__Paid_by__c, invoiceit_s__Exchange_Rate_Applied__c, 
                            invoiceit_s__Currency__c, invoiceit_s__Cheque_Number__c, Record_Lock__c ,
                            invoiceit_s__Cheque_Date__c, invoiceit_s__Bank_Name__c, invoiceit_s__Amount__c, 
                            invoiceit_s__Allocated_Amount__c, invoiceit_s__Account__c, Total_Pay_Amt__c, Original_Payment__c,
                            SystemModstamp, Related_to_Case__c, RecordTypeId, Raw_Info__c, Payment_Related_to_Case__c, 
                            Name, LastModifiedDate, LastModifiedById, LastActivityDate, IsDeleted, 
                            Invoice__c, Id, FileName__c, Credit_Amount__c, Created_From_Account__c, CreatedDate, 
                            CreatedById, Bank_Deposit_Date__c, Approval_submission_date__c, Approval_status__c, 
                            Approval_Escalation__c, Applied_Type__c, Adjustment_Reason__c, Adjustment_Amount__c,
                                (Select invoiceit_s__Status__c, invoiceit_s__Payment__c, invoiceit_s__Invoice__c, invoiceit_s__Amount__c, 
                                    Unallocated_credits__c, Unallocated_Amount__c, RecordTypeId, Payment_Type__c, Payment_Completed_Date__c, 
                                    PaymentType__c, Name, Month__c, Id, Applied_Type__c, AppliedType__c, Adjustment_Reason__c, Original_Payment_Allocation__c,
                                    AdjustmentReason__c From invoiceit_s__Payment_Allocations__r ) 
                            From invoiceit_s__Payment__c 
                            where Id =: paymentId];
                
                //payment.invoiceit_s__Payment_Type__c = 'Adjustment';
                //payment.Applied_Type__c = 'DM (Debit-Memo)';
                clonedPayment = payment.clone();
                clonedPayment.invoiceit_s__Payment_Type__c = 'Adjustment';
                clonedPayment.invoiceit_s__Payment_Date__c = Date.today();
                clonedPayment.Applied_Type__c = 'DM (Debit-Memo)';
                
                List<PermissionSetAssignment> listperassign = [select Assignee.Id, PermissionSet.Name, Assignee.Name, PermissionSet.Id from PermissionSetAssignment where PermissionSet.Label like '%finance%process%permissions'];
                Id userid = UserInfo.getUserId();
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
                if(haspermission == false) {	                
	                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You don\'t have permission to create a debit memo',''); 
	                ApexPages.addMessage(errMsg);   
	           		return;
                }
        }   
        
        
        public PageReference cancel(){
                PageReference p = new PageReference('/' + payment.Id);
                p.setRedirect(true);
                return p;
        }
        
        public PageReference debitMemoForPayment(){
                List<invoiceit_s__Payment_Allocation__c> List_PayAlloc = new List<invoiceit_s__Payment_Allocation__c>();
                List<invoiceit_s__Payment_Allocation__c> List_UpdateOldPayAlloc = new List<invoiceit_s__Payment_Allocation__c>();
                
                for(invoiceit_s__Payment_Allocation__c payalloc : payment.invoiceit_s__Payment_Allocations__r){
                        invoiceit_s__Payment_Allocation__c tempPA = new invoiceit_s__Payment_Allocation__c();
                        tempPA = payAlloc.clone();
                        tempPA.invoiceit_s__Amount__c = payAlloc.invoiceit_s__Amount__c * (-1);
                        tempPA.Record_Lock__c = true;
                        tempPA.Original_Payment_Allocation__c = payAlloc.Id;
                        List_PayAlloc.add(tempPA);  
                        payalloc.Record_Lock__c = true;
                        List_UpdateOldPayAlloc.add(payalloc);
                }
                
                if(List_PayAlloc.size() > 0){
                        insert List_PayAlloc;   
                }
                if(List_UpdateOldPayAlloc.size() > 0){
                       update List_UpdateOldPayAlloc;   
                }
                
                
                clonedPayment.invoiceit_s__Amount__c =  (payment.invoiceit_s__Amount__c)*(-1);
                clonedPayment.invoiceit_s__Cheque_Number__c = '';
                clonedPayment.invoiceit_s__Cheque_Date__c = null ; 
                clonedPayment.Original_Payment__c = payment.Id;
                clonedPayment.invoiceit_s__Bank_Name__c = '' ;
                if(!(clonedPayment.Adjustment_Reason__c == 'COR(To reverse a payment or a credit which was applied to an invoice so that the invoice is unpaid again)')){
                    clonedPayment.Record_Lock__c = true;
                    payment.Record_Lock__c = true;
                    update payment;
                }                   
                insert clonedPayment;
                
                
                PageReference p = new PageReference('/' + payment.invoiceit_s__Account__c);
                p.setRedirect(true);
                return p;
        }
}