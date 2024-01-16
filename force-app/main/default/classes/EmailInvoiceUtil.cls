/*

Change History 
********************************************************************************************************************
SCRUM/Jira  ModifiedBy      Date         Requested By    Tag      Description                             
********************************************************************************************************************
MHBS-8976	Lakshmi		   30-05-2023	 Nama			 T01	  Create Task on the Invoice If email is sent	
*/


public class EmailInvoiceUtil {
    public static Map<Id,string> emailInvoice(List<blng__Invoice__c> invoices)
    {
        List<String> toAddresses = new List<String>();
        List<blng__Invoice__c> invoiceListUpdate = new List<blng__Invoice__c>();
        List<Task> taskList = new List<Task>();//<T02>
        List<Attachment> attachmentList = new List<Attachment>();
        Map<Id,string> errorMap = new Map<Id,String>();
        Map<Id,Sobject> IdToSObjectMap = new Map<Id,Sobject>();
        
        for(blng__Invoice__c invoice : invoices)
        {
        
            PageReference ref = Page.InvoiceTemplate;
            ref.getParameters().put('Id', String.valueOf(invoice.Id));
            Blob b;
            if(Test.isRunningTest()) { 
              b = blob.valueOf('Unit.Test');
          } 
          else
            b = ref.getContentAsPDF();           
            
            /*Attachment attach = new Attachment();
             attach.Name = invoice.blng__Account__r.Name+' - '+Date.today().format()+'.pdf';
             attach.ParentId = invoice.id;
             attach.Body = b ;
             attachmentList.add(attach);*/
             
             invoice.Email_Sent__c = true;
             system.debug('Contact==>'+invoice.blng__BillToContact__r.Email);
             //errorMap.put(invoices[0].Id,'Sample');
             invoiceListUpdate.add(invoice);
             
        }
            //Savepoint sp = Database.setSavePoint();
            if(invoiceListUpdate != null && invoiceListUpdate.size() > 0)
            {
                try 
                {
                   List<Database.SaveResult> dsrs = Database.update(invoiceListUpdate,false);
                    Integer index = 0;
                    for(Database.SaveResult dsr : dsrs){
                        if(!dsr.isSuccess()){                        
                            String errMsg = dsr.getErrors()[0].getMessage();
                            errorMap.put(invoiceListUpdate[index].Id, errMsg);
                            IdToSObjectMap.put(invoiceListUpdate[index].Id, invoiceListUpdate[index]);                            
                        }
                        
                        index++;
                    }
					//<T01>
					for(blng__Invoice__c inv : invoiceListUpdate){
						if(!errorMap.containskey(inv.Id)){
							Task tsk = createTask(inv);
							taskList.add(tsk);
						}
					}
					//<T01>	
                  
                } catch(Exception e)
                {
                    Util.processException(e,true,'EmailInvoiceUtil class - emailInvoice method - taskList - for invoice ids : '+invoices);                    
                }
                
            }
            
            if(taskList != null && taskList.size() > 0)
            {
                try
                {
                   insert taskList;   
                } catch(Exception e)
                {
                    Util.processException(e,true,'EmailInvoiceUtil class - emailInvoice method - taskList - for invoice ids : '+invoices);
                    
                }
                
            }
            
            /* if(attachmentList!= null && attachmentList.size() > 0)
            {
                try
                {
                   insert attachmentList;   
                } catch(Exception e)
                {
                            
                    Util.processException(e,true,'EmailInvoiceUtil class - emailInvoice method - attachmentList- for invoice ids : '+invoices);
                    
                }
                
            }*/
            
            return errorMap;
            
        }
   
    public static Task createTask(blng__Invoice__c invoice )
    {
        Task taskObj = new Task();
        taskObj.Subject = 'MH E-Invoice emailed to the customer';
        taskObj.WhatId = invoice.id;
        taskObj.Status = 'Completed';
        taskObj.ActivityDate = invoice.blng__InvoiceDate__c;
        taskObj.Priority = 'Normal';
        return taskObj;
    }
   
    
}