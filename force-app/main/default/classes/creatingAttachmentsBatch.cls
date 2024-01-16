// this class is used for creating attachments for each invoice and storing in its attachment 

// related list

global class creatingAttachmentsBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, database.stateful {
    
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
    
    
    
    public creatingAttachmentsBatch(boolean insertOrDeleteFlag,Integer year, Integer month){
        insertOrBooleanFlagCheck = insertOrDeleteFlag;
        yeartoSet = year;
        monthtoSet = month;
        rt.put('Email & Print', 0);
        rt.put('Print', 0);
        rt.put('Email', 0);
    }
    
    public creatingAttachmentsBatch(boolean insertOrDeleteFlag, id iinvrunid){
        system.debug('Insert Flag: ' + insertOrDeleteFlag + 'Inv Run id: ' + invrunid);
        insertOrBooleanFlagCheck = insertOrDeleteFlag;
        invrunid = iinvrunid;
        rt.put('Email & Print', 0);
        rt.put('Print', 0);
        rt.put('Email', 0);
        invrunname = [select name from invoiceit_s__Invoice_Run__c where id = :invrunid].name;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('@@@in start');
        system.debug('Invoice Run: ' + invrunid);
        if(!test.isRunningTest()){
            if (invrunid != null) {                   
                recordType = 'M-H Invoice';
                return Database.getQueryLocator([select id, Name, invoiceit_s__Delivery_Type__c ,invoiceit_s__Account__r.Logical_Doc__c,invoiceit_s__Account__r.Do_Not_Contact__c, invoiceit_s__Account__r.MH_Cust_Number__c,
                                                 invoiceit_s__Invoice_Run_Created_By__r.Name,invoiceit_s__Invoice_Date__c
                                                 from invoiceit_s__Invoice__c
                                                 where invoiceit_s__Invoice_Status__c = 'Posted'
                                                 and (invoiceit_s__Delivery_Type__c = 'Email & Print'
                                                      OR invoiceit_s__Delivery_Type__c = 'Email'
                                                      OR invoiceit_s__Delivery_Type__c = 'Print')
                                                 and RecordType.Name = 'M-H Invoice'
                                                 and invoiceit_s__Invoice_Run_Created_By__c = :invrunid]) ;
            }            
            else {
                recordType = 'M-H Invoice';
                creaatedDateFilter = date.newInstance(yeartoSet , monthtoSet , 01);
                Integer numberOfDays = Date.daysInMonth(creaatedDateFilter.year(), creaatedDateFilter.month());
                Date lastDayOfMonth = Date.newInstance(creaatedDateFilter.year(), creaatedDateFilter.month(), numberOfDays);
                return Database.getQueryLocator([select id, invoiceit_s__Account__r.Logical_Doc__c,invoiceit_s__Account__r.Do_Not_Contact__c,
                                                 Name,invoiceit_s__Delivery_Type__c , invoiceit_s__Account__r.MH_Cust_Number__c,
                                                 invoiceit_s__Invoice_Run_Created_By__r.Name,invoiceit_s__Invoice_Date__c
                                                 from invoiceit_s__Invoice__c
                                                 where invoiceit_s__Invoice_Status__c = 'Posted'
                                                 and (invoiceit_s__Delivery_Type__c = 'Email & Print'
                                                      OR invoiceit_s__Delivery_Type__c = 'Email'
                                                      OR invoiceit_s__Delivery_Type__c = 'Print')
                                                 and invoiceit_s__Invoice_Date__c >=: creaatedDateFilter
                                                 and invoiceit_s__Invoice_Date__c <=: lastDayOfMonth                                                  
                                                 and RecordType.Name = 'M-H Invoice']);
            }
            
        }
        
        else{
            recordType = 'M-H Invoice';
            creaatedDateFilter = date.newInstance(yeartoSet , monthtoSet , 01);
            Integer numberOfDays = Date.daysInMonth(creaatedDateFilter.year(), creaatedDateFilter.month());
            Date lastDayOfMonth = Date.newInstance(creaatedDateFilter.year(), creaatedDateFilter.month(), numberOfDays);
            
            return Database.getQueryLocator([select id, invoiceit_s__Account__r.Logical_Doc__c,
                                             
                                             Name, invoiceit_s__Delivery_Type__c , invoiceit_s__Account__r.MH_Cust_Number__c,
                                             
                                             invoiceit_s__Invoice_Run_Created_By__r.Name,invoiceit_s__Account__r.Do_Not_Contact__c,invoiceit_s__Invoice_Date__c
                                             
                                             from invoiceit_s__Invoice__c
                                             
                                             where invoiceit_s__Invoice_Status__c = 'Posted'
                                             
                                             and (invoiceit_s__Delivery_Type__c = 'Email & Print'
                                                  OR invoiceit_s__Delivery_Type__c = 'Email'
                                                  OR invoiceit_s__Delivery_Type__c = 'Print')
                                             
                                             and invoiceit_s__Invoice_Date__c >=: creaatedDateFilter LIMIT 1] 
                                            
                                           );
            
        }
        
        
    }
    
    
    
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Invoice__c> invoiceList){
        System.debug('@@@@Start  Execution');
        system.debug('@@@@@invoiceList' + invoiceList);
        totrecs += invoiceList.size();
        system.debug('Totrecs: ' + totrecs + ' invoiceList: ' + invoiceList.size());
        for(invoiceit_s__Invoice__c i : invoiceList){
            rt.put(i.invoiceit_s__Delivery_Type__c, rt.get(i.invoiceit_s__Delivery_Type__c) + 1);
        }
            
        
        if(insertOrBooleanFlagCheck){
            createAttachmentHandler.createAttachment(invoiceList,recordCount );
            recordCount +=invoiceList.size();
        }
        else{
            createAttachmentHandler.deleteAttachments(invoiceList);
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
                
/*        ar = [select invoiceit_s__Delivery_Type__c, count(id) cnt
              from invoiceit_s__Invoice__c
              where invoiceit_s__Invoice_Status__c = 'Posted'
              and (invoiceit_s__Delivery_Type__c = 'Email & Print'
//                   OR invoiceit_s__Delivery_Type__c = 'Email'
                   OR invoiceit_s__Delivery_Type__c = 'Print')
              and RecordType.Name = 'Nolo Invoice'
              and invoiceit_s__Invoice_Run_Created_By__c = :invrunid
              group by invoiceit_s__Delivery_Type__c] ;
*/        
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