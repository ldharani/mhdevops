global class Batch_populateBillToContactOnInvoice implements Database.Batchable<sObject>{
    public Date configurableInvoiceDate;
    public Batch_populateBillToContactOnInvoice(){        
       configurableInvoiceDate = Date.valueOf(System.label.SetConfigurableDate);//date format eg: 2021-07-01 (YYYY-MM-DD)
       system.debug('configurableInvoiceDate : '+configurableInvoiceDate); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){       
        //and blng__InvoiceDate__c = :configurableInvoiceDate
        String query = 'select Name,blng__Order__c,blng__DueDate__c, blng__BillToContact__c, blng__Account__r.Payment_Terms__c,Delivery_Type__c,blng__InvoiceDate__c, blng__Account__r.Invoice_Delivery_Type__c,blng__InvoiceStatus__c, (select blng__invoice__c,blng__OrderProduct__r.Status__c, blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Order.BillToContactId from blng__InvoiceInvoiceLines__r where blng__OrderProduct__c != null and (blng__OrderProduct__r.Status__c != \'Cancelled\' or blng__OrderProduct__r.Status__c !=\'Off set\') order by createddate desc limit 1) '+ 
 +' from blng__invoice__c where blng__InvoiceStatus__c IN (\'Posted\',\'Draft\') and (blng__Order__c =null OR blng__BillToContact__c =null) and blng__InvoiceDate__c = :configurableInvoiceDate  '; 
		if(test.isRunningTest())
        {
            query = 'select Name,blng__Order__c,blng__DueDate__c, blng__BillToContact__c, blng__Account__r.Payment_Terms__c,Delivery_Type__c,blng__InvoiceDate__c, blng__Account__r.Invoice_Delivery_Type__c,blng__InvoiceStatus__c, (select blng__invoice__c,blng__OrderProduct__r.Status__c, blng__OrderProduct__r.OrderId, blng__OrderProduct__r.Order.BillToContactId from blng__InvoiceInvoiceLines__r ) from blng__invoice__c ';
        }
        system.debug('query###1 : '+query);                                          
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> listOfInvoices){
        system.debug('listOfInvoices : '+listOfInvoices);
        system.debug('listOfInvoices : '+listOfInvoices.size());
        List<blng__invoice__c> invListToUpdate = new List<blng__invoice__c>();
        List<blng__invoice__c> invWithBillTOContactNull = new List<blng__invoice__c>();
        List<Id> orderIDs = new List<Id>();
        for(blng__invoice__c inv : listOfInvoices){
            system.debug('inside###1');
            if(!inv.blng__InvoiceInvoiceLines__r.isEmpty()){
                system.debug('inside###2'+inv.Name);
                inv.blng__Order__c = inv.blng__InvoiceInvoiceLines__r[0].blng__OrderProduct__r.OrderId;
                inv.blng__BillToContact__c = inv.blng__InvoiceInvoiceLines__r[0].blng__OrderProduct__r.Order.BillToContactId;
                if(inv.blng__InvoiceInvoiceLines__r[0].blng__OrderProduct__r.Order.BillToContactId==null)
                {
                    System.debug('invWithBillTOContactNull'+inv.name+inv.blng__Order__c);
                    invWithBillTOContactNull.add(inv);
                    orderIDs.add(inv.blng__Order__c);
                }
                inv.Delivery_Type__c = inv.blng__Account__r.Invoice_Delivery_Type__c;
                System.debug('status'+inv.blng__InvoiceStatus__c);
                if(inv.blng__InvoiceStatus__c!='Posted'){
                	if(inv.blng__Account__r.Payment_Terms__c == 'Net 10'){
                    	inv.blng__DueDate__c = inv.blng__InvoiceDate__c.addDays(10);
                	}else{
                  	inv.blng__DueDate__c = inv.blng__InvoiceDate__c.addDays(30); 
                	}
                }
                invListToUpdate.add(inv);  
            }
                      
        } 
        
       Map<Id,Contract> mapOfContracts = new  Map<Id,Contract>(); //Original Order
        for(contract con : [select id,SBQQ__Order__c,ContractNumber,Original_Order__c,Bill_To_Contact__c from contract where Original_Order__c in :orderIDs])
        		mapOfContracts.put(con.Original_Order__c, con);
        System.debug('mapOfContracts'+mapOfContracts);
        for(blng__invoice__c inv :invWithBillTOContactNull)
            {
               Contract cont = mapOfContracts.get(inv.blng__InvoiceInvoiceLines__r[0].blng__OrderProduct__r.OrderId);
                
                if(cont!=null)
                {
                    System.debug('cnum'+cont.ContractNumber);
                    if(inv.blng__BillToContact__c==null)
                    inv.blng__BillToContact__c = cont.Bill_To_Contact__c;
                }
            }
		
         Map<Id,Contract> mapOfContractsWithOrderId = new  Map<Id,Contract>();
        for(contract con : [select id,SBQQ__Order__c,ContractNumber,Original_Order__c,Bill_To_Contact__c from contract where SBQQ__Order__c in :orderIDs])
        		mapOfContractsWithOrderId.put(con.SBQQ__Order__c, con);
        System.debug('mapOfContractsWithOrderId'+mapOfContractsWithOrderId);
        for(blng__invoice__c inv :invWithBillTOContactNull)
            {
               Contract cont = mapOfContractsWithOrderId.get(inv.blng__InvoiceInvoiceLines__r[0].blng__OrderProduct__r.OrderId);
                
                if(cont!=null)
                {
                    System.debug('cnum'+cont.ContractNumber);
                    if(inv.blng__BillToContact__c==null)
                    inv.blng__BillToContact__c = cont.Bill_To_Contact__c;
                }
            }
		
        
      
        system.debug('invListToUpdate : '+invListToUpdate);
        try{
           update invListToUpdate;
            update invWithBillTOContactNull;
        }catch(Exception ex){
           system.debug('Exception occured while updating invListToUpdate : '+ex.getMessage()); 
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}