// this class is used for creating attachments for each invoice and storing in its attachment 

// related list

global class CPQcreatingAttachmentsBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, database.stateful {
    
    public Date creaatedDateFilter;
    
    public boolean insertOrBooleanFlagCheck;
    public Integer yeartoSet;
    Public Integer monthtoSet;
    public integer TotRecs=0;
    public list<aggregateResult> ar = new list<aggregateResult>();
    public map<string, integer> rt = new map<string, integer>();
    public String recordType;
    public id invrunid;
    public string invrunname = '';
    public Integer recordCount = 0;
    
    
    
    public CPQcreatingAttachmentsBatch(boolean insertOrDeleteFlag,Integer year, Integer month){
        insertOrBooleanFlagCheck = insertOrDeleteFlag;
        yeartoSet = year;
        monthtoSet = month;
        rt.put('Email & Print', 0);
        rt.put('Print', 0);
        rt.put('Email', 0);
    }
    
    public CPQcreatingAttachmentsBatch(boolean insertOrDeleteFlag, id iinvrunid){
        system.debug('Insert Flag: ' + insertOrDeleteFlag + 'Inv Run id: ' + invrunid);
        insertOrBooleanFlagCheck = insertOrDeleteFlag;
        invrunid = iinvrunid;
        rt.put('Email & Print', 0);
        rt.put('Print', 0);
        rt.put('Email', 0);
        if(!test.isRunningTest()){
        invrunname = [select name from blng__InvoiceRun__c where id = :invrunid].name;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@in start');
        system.debug('Invoice Run: ' + invrunid);
        if(!test.isRunningTest()){
            if (invrunid != null) {                   
                recordType = 'M-A Intake Invoice';
                return Database.getQueryLocator([select id,blng__InvoiceStatus__c, Name, Delivery_Type__c, blng__Account__r.Do_Not_Contact__c,blng__Account__r.MH_Cust_Number__c,
                                                 blng__InvoiceRunCreatedBy__r.Name,blng__InvoiceDate__c
                                                 from blng__Invoice__c
                                                 where blng__InvoiceStatus__c = 'Posted'
                                                 and (Delivery_Type__c= 'Email & Print'
                                                      OR Delivery_Type__c = 'Email'
                                                      OR Delivery_Type__c = 'Print')
                                                 
                                                 and blng__InvoiceRunCreatedBy__c= :invrunid]) ;
            }            
            else {
                recordType = 'M-A Intake Invoice';
                creaatedDateFilter = date.newInstance(yeartoSet , monthtoSet , 01);
                Integer numberOfDays = Date.daysInMonth(creaatedDateFilter.year(), creaatedDateFilter.month());
                Date lastDayOfMonth = Date.newInstance(creaatedDateFilter.year(), creaatedDateFilter.month(), numberOfDays);
                return Database.getQueryLocator([select id, blng__InvoiceStatus__c, Name, Delivery_Type__c, blng__Account__r.MH_Cust_Number__c,
                                                 blng__InvoiceRunCreatedBy__r.Name,blng__InvoiceDate__c,blng__Account__r.Do_Not_Contact__c
                                                 from blng__Invoice__c
                                                 
                                                 where blng__InvoiceStatus__c = 'Posted'
                                                 and (Delivery_Type__c = 'Email & Print'
                                                      OR Delivery_Type__c = 'Email'
                                                      OR Delivery_Type__c = 'Print')]);  
                                                // and blng__InvoiceDate__c >=: creaatedDateFilter
                                                // and blng__InvoiceDate__c <=: lastDayOfMonth ]);                                                 
                                             
                                                // and RecordType.Name = 'M-H Invoice']);
            }
            
        }
        
        else{
            recordType = 'M-A Intake Invoice';
            creaatedDateFilter = date.newInstance(yeartoSet , monthtoSet , 01);
            Integer numberOfDays = Date.daysInMonth(creaatedDateFilter.year(), creaatedDateFilter.month());
            Date lastDayOfMonth = Date.newInstance(creaatedDateFilter.year(), creaatedDateFilter.month(), numberOfDays);
            
            return Database.getQueryLocator([select id, blng__InvoiceStatus__c, Name, Delivery_Type__c, blng__Account__r.MH_Cust_Number__c,
                                                 blng__InvoiceRunCreatedBy__r.Name,blng__InvoiceDate__c,blng__Account__r.Do_Not_Contact__c
                                                 from blng__Invoice__c
                                             
                                             where blng__InvoiceStatus__c = 'Posted'
                                             
                                             and (Delivery_Type__c = 'Email & Print'
                                                  OR Delivery_Type__c = 'Email'
                                                  OR Delivery_Type__c = 'Print') LIMIT 1] 
                                             
                                            // and blng__InvoiceDate__c >=: creaatedDateFilter LIMIT 1] 
                                            
                                           );
            
        }
        
        
    }
    
    
    
    global void execute(Database.BatchableContext BC, List<blng__Invoice__c> invoiceList){
        System.debug('@@@@Start  Execution');
        system.debug('@@@@@invoiceList' + invoiceList);
        totrecs += invoiceList.size();
        system.debug('Totrecs: ' + totrecs + ' invoiceList: ' + invoiceList.size());
        for(blng__Invoice__c i : invoiceList){
            rt.put(i.Delivery_Type__c , rt.get(i.Delivery_Type__c ) + 1);
        }
            
        
        if(insertOrBooleanFlagCheck){
            createAttachmentHandler.CPQcreateAttachment(invoiceList,recordCount );
            recordCount +=invoiceList.size();
        }
        else{
            createAttachmentHandler.CPQdeleteAttachment(invoiceList);
        }
        
    }
    
    
    
    global void finish(Database.BatchableContext BC){
        Create_Delete_Attachments_process__c create_del_attach = Create_Delete_Attachments_process__c.getValues('Create Attachments');
        String emailAddressString = create_del_attach.Emails_For_Attachment_Process__c;
        List<String> sendTo = new List<String>();   
        List<String> toEmailAddress = new List<String>();   
        String sendText='';
        String headText;
        if (insertOrBooleanFlagCheck) 
            headtext = 'Created Attachements ';
        else
            headtext = 'Deleted Attachements ';
                
      
        String rowtext = '<tr>'+ '<td>' + recordtype + '</td><td>' +  totrecs + '</td><td>' + '    Posted</td>' ;
//        for (AggregateResult a : ar) {
//            sendText+= rowtext + '<td>' + (String) a.get('invoiceit_s__Delivery_Type__c') + '</td><td>' + (Integer) a.get('cnt') + '</td></tr>';
//        }
        system.debug('@@@@Rama rt: ' + rt);
        for (String a : rt.keySet()) {
            sendText+= rowtext + '<td>' + a + '</td><td>' + (Integer) rt.get(a) + '</td></tr>';
        }
        
        if(emailAddressString.contains(',')){
            sendTo = emailAddressString.split(',');
            for(String s : sendTo){
                if(s!='' && s!=null){
                    toEmailAddress.add(s);
                }
            }
        }
        else{
            toEmailAddress.add(emailAddressString);
        }
        try{
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setSubject(  headText +  ' for  Invoice Run: ' + invRunname );      
            mail.setToAddresses(toEmailAddress);
            string headstr = '<head><style>   th, td { padding: 5px;  text-align: left;}</style></head>';
            String body = '<html>' + headstr+'<body><table style="width:100%;text-align: left;"><tr><th>Record Type</th><th>Total Recs</th><th>Status</th><th>Delivery Type</th><th>Count</th></tr>' + sendtext;
            body += '</table></body></html>';
            
            mail.setHtmlBody(body);
            mails.add(mail);
            Messaging.sendEmail(mails);
        }
        catch(Exception e){
            System.debug('An exception occured' + e.getMessage());
        }        
        
    }
        
    
}