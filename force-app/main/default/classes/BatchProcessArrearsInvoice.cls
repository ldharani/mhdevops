global class BatchProcessArrearsInvoice implements Database.Batchable<sObject>,Database.Stateful {
    global String query;
    global set<Id> setofRun;

    global BatchProcessArrearsInvoice(set<Id> setofRunIDs) {
        this.setofRun = setofRunIDs; 
        query = '';
        query = 'SELECT Id,invoiceit_s__Number_Of_Invoice_Lines__c,invoiceit_s__Account__c,invoiceit_s__Billing_Contact__c,invoiceit_s__CurrencyL__c,invoiceit_s__Invoice_Currency_Symbol__c,invoiceit_s__Delivery_Type__c,invoiceit_s__Due_Date__c,invoiceit_s__Exchange_Rate_Applied__c,invoiceit_s__Invoice_Date__c,invoiceit_s__Invoice_Reference__c,invoiceit_s__Invoice_State__c,invoiceit_s__Invoice_Status__c,invoiceit_s__Custom_Invoice_Number__c,invoiceit_s__Order__c,invoiceit_s__Payment_Request_Amount__c,invoiceit_s__Regular_Invoice__c,invoiceit_s__Shipping_Contact__c,invoiceit_s__Target_Date__c,';
        query = query + ' (SELECT Id,invoiceit_s__Product__r.Billing_Schedule__c,invoiceit_s__Accounting_Code__c,invoiceit_s__Calculated_Quantity__c,invoiceit_s__Charge_Date__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Service_Start_Date__c,invoiceit_s__Discount_Value__c,invoiceit_s__Invoice__c,invoiceit_s__Line_Name__c,invoiceit_s__Job__c,invoiceit_s__Job_Rate_Plan_Charge__c,invoiceit_s__Product__c,invoiceit_s__Product_Name__c,invoiceit_s__Product_Rate_Plan_Charge__c,invoiceit_s__Quantity__c,invoiceit_s__Sequence_No__c,invoiceit_s__Status__c,invoiceit_s__Line_Amount__c,invoiceit_s__Tax__c,invoiceit_s__Tax_Code__c,invoiceit_s__Unit_Price__c,invoiceit_s__Unit_of_Measurement__c,invoiceit_s__VAT__c FROM invoiceit_s__Invoice_Lines__r WHERE invoiceit_s__Product__r.Billing_Schedule__c = \'' + 'Arrears\'' + ') FROM invoiceit_s__Invoice__c WHERE invoiceit_s__Invoice_Run_Created_By__c IN: setofRun AND  invoiceit_s__Account__r.Billing_Schedule__c=\'' + 'Arrears\'';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<invoiceit_s__Invoice__c> listofInvoices) {

        invoiceit_s__Invoice__c invLoc;
        invoiceit_s__Invoice_Lines__c invLineLoc;
        list<invoiceit_s__Invoice__c> listofInvoiceToInsert = new list<invoiceit_s__Invoice__c>();
        list<invoiceit_s__Invoice_Lines__c> InvLineToInsert = new list<invoiceit_s__Invoice_Lines__c>();
        list<invoiceit_s__Invoice_Lines__c> invLinesToDelete = new list<invoiceit_s__Invoice_Lines__c>();
        list<invoiceit_s__Invoice_Lines__c> listInvLineLoc;
        map<integer, list<invoiceit_s__Invoice_Lines__c> > map_Index_line = new map<integer, list<invoiceit_s__Invoice_Lines__c> >();
        Integer idaysBetween;
        for(invoiceit_s__Invoice__c inv : listofInvoices) {

            if(inv.invoiceit_s__Number_Of_Invoice_Lines__c == inv.invoiceit_s__Invoice_Lines__r.size()) {
                // if all are arreas charges dont delete the invoice line and only update the invoice
                //inv.invoiceit_s__Invoice_Run_Created_By__c = null;
                idaysBetween = inv.invoiceit_s__Invoice_Date__c.daysbetween(inv.invoiceit_s__Due_Date__c);
                inv.Arrears_Invoice__c = true;
                inv.invoiceit_s__Invoice_Status__c = 'Draft';
                Date dInvoiceDate;
                integer iIndex = 0;
                for(invoiceit_s__Invoice_Lines__c invline : inv.invoiceit_s__Invoice_Lines__r) {
                    if(dInvoiceDate == null) {
                        dInvoiceDate = invline.invoiceit_s__Service_End_Date__c;
                    } else if(dInvoiceDate > invline.invoiceit_s__Service_End_Date__c) {
                        dInvoiceDate = invline.invoiceit_s__Service_End_Date__c;
                    }
                }
                inv.invoiceit_s__Invoice_Date__c = dInvoiceDate;
                inv.invoiceit_s__Due_Date__c = inv.invoiceit_s__Invoice_Date__c.addDays(idaysBetween);
            } else if(inv.invoiceit_s__Invoice_Lines__r.size() != 0){
                // Delele the invoice lines
                invLoc = new invoiceit_s__Invoice__c();
                invLoc = inv.clone(false);
                idaysBetween = inv.invoiceit_s__Invoice_Date__c.daysbetween(inv.invoiceit_s__Due_Date__c);
                invLoc.invoiceit_s__Invoice_Run_Created_By__c = null;
                invLoc.invoiceit_s__Invoice_Status__c = 'Draft';
                invLoc.Arrears_Invoice__c = true;
                listInvLineLoc = new list<invoiceit_s__Invoice_Lines__c>();
                Date dInvoiceDate;
                integer iIndex = 0;
                for(invoiceit_s__Invoice_Lines__c invline : inv.invoiceit_s__Invoice_Lines__r) {
                    
                    if(dInvoiceDate == null) {
                        dInvoiceDate = invline.invoiceit_s__Service_End_Date__c;
                    } else if(dInvoiceDate > invline.invoiceit_s__Service_End_Date__c) {
                        dInvoiceDate = invline.invoiceit_s__Service_End_Date__c;
                    }
                    system.debug('dInvoiceDate--->'+dInvoiceDate);
                    invLineLoc = new invoiceit_s__Invoice_Lines__c();
                    invLineLoc = invline.clone(false);
                    invLineLoc.invoiceit_s__Invoice__c = null;
                    listInvLineLoc.add(invLineLoc);
                    invLinesToDelete.add(invline);
                }
                invLoc.invoiceit_s__Invoice_Date__c = dInvoiceDate;
                invLoc.invoiceit_s__Due_Date__c = invLoc.invoiceit_s__Invoice_Date__c.addDays(idaysBetween);
                listofInvoiceToInsert.add(invLoc);
                map_Index_line.put(iIndex, listInvLineLoc);
                iIndex++;
            }
        }
        
        if(listofInvoiceToInsert.isEmpty()) {
            update listofInvoices;
        }
        
        if(!listofInvoiceToInsert.isEmpty()) {
            insert listofInvoiceToInsert;
            for(integer i=0; i < map_Index_line.size(); i++ ) {
                listInvLineLoc = map_Index_line.get(i);
                for(invoiceit_s__Invoice_Lines__c invLine : listInvLineLoc) {
                    invLine.invoiceit_s__Invoice__c = listofInvoiceToInsert[i].Id;
                    InvLineToInsert.add(invLine);
                }
            }
            insert InvLineToInsert;
            delete invLinesToDelete;
        }
    }


    global void finish(Database.BatchableContext BC) {

    }
}