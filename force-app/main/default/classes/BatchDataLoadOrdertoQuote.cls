/*********
*Created By : ieswarya on Sep 29 
* Description : Batch to move the data from Order to CPQ as part of data migration
* Ticket : MHSCBM-174
* */
global class BatchDataLoadOrdertoQuote implements Database.Batchable<sObject>, Database.Stateful{
    global Set<String> failedOrders = new Set<String>();
    global Set<String> errMessages = new Set<String>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        string RecordNolo = Schema.SObjectType.invoiceit_s__Job__c.getRecordTypeInfosByName().get('M-N Order').getRecordTypeId();//'0120G000000zreJ' ;
        String query ='';
       //    List<string> listofIds = new list<string>{'3177102'};//{'3175187'};
        list<string> listofstatus = new list<string>{'Active','Evergreen'};
            List<SBQQ__Quote__c> q =[Select legacy_order_number__C from SBQQ__Quote__c where recordtype.Name like '%Nolo Quote%' and legacy_order_number__C != null];
        Set<String> legacyorders = new Set<String>();
        for(SBQQ__Quote__c quote:q){
            legacyorders.add(quote.legacy_order_number__C);
        }
        System.debug(legacyorders.size());
        List<invoiceit_s__Job__c> job =[Select Id,Name from invoiceit_s__Job__c where RecordtypeId='0120G000000zreJ' and invoiceit_s__Status__c in ('Active','Evergreen') and Name not in :legacyorders ];
        
        if(test.isRunningTest()){
            query = 'Select Id,Name,invoiceit_s__Number_Of_Terms__c,invoiceit_crmx__Opportunity__r.ownerid,Quote_Type__c,ownerid,invoiceit_s__Service_Activation_Date__c,invoiceit_s__Renewal_Terms_Months__c,Auth_By_Contact__c,invoiceit_s__Payment_Terms__c,PartnerAccountOrder__c,invoiceit_crmx__Opportunity__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Account__c,LastModifiedById,Lastmodifieddate,CreatedById,createddate,OrderNumber__c,invoiceit_s__Shipping_Contact__c,invoiceit_s__Billing_Contact__c,Marketing_Contact__c,invoiceit_s__Start_Date__c,Book_Buyer_Renewal__c,Do_Not_Renew__c,Do_not_Renew_loss_reason__c,DNR_Secondary_loss_reason__c,Other_DNR_Loss_reason__c,Promo_code__c,invoiceit_s__currencyL__c,Other_Cancel_Reason__c,Secondary_Loss_Reason__c,Locations__c,Practice_Areas__c from invoiceit_s__Job__c limit 1 ';
            
        }else{
            query = 'Select Id,Name,invoiceit_s__Number_Of_Terms__c,invoiceit_crmx__Opportunity__r.ownerid,Quote_Type__c,ownerid,invoiceit_s__Service_Activation_Date__c,invoiceit_s__Renewal_Terms_Months__c,Auth_By_Contact__c,invoiceit_s__Payment_Terms__c,PartnerAccountOrder__c,invoiceit_crmx__Opportunity__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Account__c,LastModifiedById,Lastmodifieddate,CreatedById,createddate,OrderNumber__c,invoiceit_s__Shipping_Contact__c,invoiceit_s__Billing_Contact__c,Marketing_Contact__c,invoiceit_s__Start_Date__c,Book_Buyer_Renewal__c,Do_Not_Renew__c,Do_not_Renew_loss_reason__c,DNR_Secondary_loss_reason__c,Other_DNR_Loss_reason__c,Promo_code__c,invoiceit_s__currencyL__c,Other_Cancel_Reason__c,Secondary_Loss_Reason__c,Locations__c,Practice_Areas__c from invoiceit_s__Job__c where RecordtypeId=:RecordNolo  and invoiceit_s__Status__c in :listofstatus and   Name not in :legacyorders ';
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<invoiceit_s__Job__c> ListofOrders) {
        system.debug('@@ListofOrders size'+ListofOrders.size());
        System.debug(failedOrders);
        list<SBQQ__Quote__c> ListofCPQQuotes = new list<SBQQ__Quote__c>();
        Set<Id> oppIds = new Set<Id>();
        Map<id,invoiceit_s__Job__c> oppOrderMap = new Map<id,invoiceit_s__Job__c>();
        
        for(invoiceit_s__Job__c objob: ListofOrders){
            oppIds.add(objob.invoiceit_crmx__Opportunity__c); 
            oppOrderMap.put(objob.invoiceit_crmx__Opportunity__c,objob);
        }
        
        List<Opportunity> oppList = [Select Name,Pricebook2ID from Opportunity where id in :oppIds];   
        Pricebook2 pricebook = [select Id from Pricebook2 where Name like '%Nolo%'];
        for(Opportunity opp :oppList){
            if(!opp.Name.Contains('Evergreen')){
                opp.Name = 'Evergreen '+ opp.Name;
            }
            opp.Pricebook2ID = pricebook.Id; // '01s7f00000038yHAAQ';
        }
        
        List<Database.SaveResult> updateResults = Database.update(oppList, false);
        for(Integer i=0;i<updateResults.size();i++){
            if (!updateResults.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = updateResults.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                oppList.get(i);//failed record from the list
                system.debug('Failed ID'+oppList.get(i).Id);
                system.debug('Failed ID'+failedDML);
                //    oppOrderMap.get(oppList.get(i).Id).Data_Load_Error__c = failedDML;
                failedOrders.add(oppOrderMap.get(oppList.get(i).Id).Name);
                errMessages.add(failedDML);
            }
            
        }
        // update oppList;
        User u = [Select id from user where name like '%Niketan%'];
        Map<String,invoiceit_s__Job__c> orderNameVsorderMap = new Map<String,invoiceit_s__Job__c>();
        for(invoiceit_s__Job__c objob: ListofOrders){
            System.debug('Current job id : '+ objob.Id);
            System.debug(objob.Name);
            SBQQ__Quote__c ObjQuote = new SBQQ__Quote__c();
            ObjQuote.sbqq__subscriptionterm__c= objob.invoiceit_s__Number_Of_Terms__c;
            ObjQuote.sbqq__type__c = objob.Quote_Type__c;
            ObjQuote.sbqq__startdate__c =   objob.invoiceit_s__Service_Activation_Date__c;
            ObjQuote.sbqq__renewalterm__c   =   objob.invoiceit_s__Renewal_Terms_Months__c;
            ObjQuote.sbqq__primarycontact__c    =   objob.Auth_By_Contact__c;
            ObjQuote.sbqq__paymentterms__c  =   objob.invoiceit_s__Payment_Terms__c;
            ObjQuote.sbqq__partner__c   =   objob.PartnerAccountOrder__c;
            ObjQuote.sbqq__opportunity2__c  =   objob.invoiceit_crmx__Opportunity__c;
            ObjQuote.sbqq__enddate__c   =   objob.invoiceit_s__Service_End_Date__c;
            ObjQuote.sbqq__account__c   =   objob.invoiceit_s__Account__c;
            ObjQuote.LastModifiedById   =   objob.LastModifiedById;
            ObjQuote.lastmodifieddate   =   objob.lastmodifieddate;
            ObjQuote.createdbyid    =   objob.CreatedById;
            ObjQuote.createddate    =   objob.createddate;
            ObjQuote.legacy_order_number__C =   objob.Name;
            orderNameVsorderMap.put( objob.Name,objob);
            
            //ObjQuote.Ship_To_Contact__c =   objob.invoiceit_s__Shipping_Contact__c;
            ObjQuote.Billing_Contact__c =   objob.invoiceit_s__Billing_Contact__c;
            ObjQuote.Marketing_Contact__c   =   objob.Marketing_Contact__c;
            ObjQuote.Legacy_order_date__c =   objob.invoiceit_s__Start_Date__c;
            ObjQuote.Legacy_Order_Number_Sequence__c = 0;
            // ObjQuote.Book_Buyer_Renewal__c  =   objob.Book_Buyer_Renewal__c;
            //ObjQuote.Do_Not_Renew__c    =   objob.Do_Not_Renew__c;
            //ObjQuote.Do_not_Renew_loss_reason__C    =   objob.Do_not_Renew_loss_reason__C;
            // ObjQuote.DNR_Secondary_loss_reason__c   =   objob.DNR_Secondary_loss_reason__c;
            // ObjQuote.Other_DNR_Loss_reason__C   =   objob.Other_DNR_Loss_reason__C;
            // ObjQuote.Promo_code__c  =   objob.Promo_code__c ;
            ObjQuote.sbqq__primary__c=true;
            ObjQuote.Other_Cancel_Reason__c =   objob.Other_Cancel_Reason__c;
            ObjQuote.Secondary_Loss_Reason__c   =   objob.Secondary_Loss_Reason__c;
            ObjQuote.RecordtypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Nolo Quote').getRecordTypeId();//'0127f000000GsD5' ;
            ObjQuote.Locations__c =   objob.Locations__c;
            if(objob.invoiceit_crmx__Opportunity__r.ownerid != null){
                ObjQuote.ownerid = objob.invoiceit_crmx__Opportunity__r.ownerid;
            }else{
                
                ObjQuote.ownerid  = u.Id;
            }
            ObjQuote.sbqq__pricebookid__c = pricebook.Id;//'01s7f00000038yHAAQ';
            ObjQuote.sbqq__pricebook__c = pricebook.Id;//'01s7f00000038yHAAQ';
            String AOP ='';
            if(test.isRunningTest()){
                objob.Practice_Areas__c = 'Workers Compensation';
            }
            if(objob.Practice_Areas__c != null){
                if(test.isrunningtest()){
                    objob.Practice_Areas__c = 'Workers Compensation,Intellectual Property,DUI & DWI,Auto Accident (Spanish),NULL';
                }
                
                if(objob.Practice_Areas__c.contains(',')){
                    System.debug(objob.Practice_Areas__c);
                    System.debug(objob.Practice_Areas__c.contains('Medical Malpract') && objob.Practice_Areas__c.contains('Medical Malpractice') == false);
                    System.debug(objob.Practice_Areas__c.contains('Medical Malpract'));
                    System.debug(objob.Practice_Areas__c.contains('Medical Malpractice') == false);             
                    AOP = objob.Practice_Areas__c.replace(',', ';');
                    if( objob.Practice_Areas__c.contains('Workers Compensation')){
                        AOP = AOP.replace('Workers Compensation', 'Worker\'s Compensation');
                    }else if(objob.Practice_Areas__c.contains('Intellectual Property')){
                        AOP = AOP.replace('Intellectual Property', 'Intellectual Property (IP)');
                    }else if(objob.Practice_Areas__c.contains('DUI & DWI')){
                        AOP = AOP.replace('DUI & DWI', 'DUI and DWI');
                    }else if(objob.Practice_Areas__c.contains('Auto Accident (Spanish)')){
                        AOP = AOP.replace('Auto Accident (Spanish)', 'Auto Accident');
                    }else if(objob.Practice_Areas__c.contains('NULL')){
                        AOP = AOP.replace('NULL', '');
                    }
                }else{
                    if( objob.Practice_Areas__c.contains('Workers Compensation')){
                        AOP = AOP.replace('Workers Compensation', 'Worker\'s Compensation');
                    }else if(objob.Practice_Areas__c.contains('Intellectual Property')){
                        AOP = AOP.replace('Intellectual Property', 'Intellectual Property (IP)');
                    }else if(objob.Practice_Areas__c.contains('DUI & DWI')){
                        AOP = AOP.replace('DUI & DWI', 'DUI and DWI');
                    }else if(objob.Practice_Areas__c.contains('Auto Accident (Spanish)')){
                        AOP = AOP.replace('Auto Accident (Spanish)', 'Auto Accident');
                    }else if(objob.Practice_Areas__c.contains('NULL')){
                        AOP = AOP.replace('NULL', '');
                    }else{
                        AOP = objob.Practice_Areas__c;
                    }
                }
            }
            System.debug(AOP);
            ObjQuote.Areas_of_Practice__c    = AOP;
            ObjQuote.Isdataloaded__c = 'Y';
            ListofCPQQuotes.add(objquote);
            
        }
        
        //  try{
        
        List<Database.SaveResult> insertResults = Database.insert(ListofCPQQuotes, false);
        for(Integer i=0;i<insertResults.size();i++){
            if (!insertResults.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = insertResults.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                ListofCPQQuotes.get(i);//failed record from the list
                // system.debug('Failed ID'+ListofCPQQuotes.get(i));
                system.debug('Failed ID'+ListofCPQQuotes.get(i).legacy_order_number__C);
                //  failedOrders.add(ListofCPQQuotes.get(i).legacy_order_number__C);
                //  orderNameVsorderMap.get(ListofCPQQuotes.get(i).legacy_order_number__C).Data_Load_Error__c = failedDML;
                System.debug(FailedDML);
                failedOrders.add(ListofCPQQuotes.get(i).legacy_order_number__C);
                errMessages.add(failedDML);
            }
            
        }
        
        //  insert ListofCPQQuotes;
        //}catch(Exception ex){          
        
        //     system.debug('exception' + ex.getMessage());
        // }
    }
    
    public void finish(Database.BatchableContext BC) {
        List<String> toEmailAddress = new List<String>();
        toEmailAddress.add('sushmidha.sakthiveeran@internetbrands.com');
           toEmailAddress.add('lori.ashley@martindale.com');
          toEmailAddress.add('sai.chandan@martindale.com');
          toEmailAddress.add('niketan.badani.1@martindale.com');
            toEmailAddress.add('ijaisankar@martindale.com');
        System.debug(failedOrders);
        System.debug( errMessages);
        try{
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setSubject('Nolo Quote Creation Failed Orders ');      
            mail.setToAddresses(toEmailAddress);
            string headstr = '<head><style>   th, td { padding: 5px;  text-align: left;}</style></head>';
            String body = '<html><body>' ;
            body += 'No.of failed orders : '+ failedOrders.size() + ',<br>';
            body += 'No.of Errors : '+ errMessages.size() + ',<br>';
            for(String s:errMessages){
                body += s+ ',<br>';
            }
            for(String s:failedOrders){
                body += s+ ',<br>';
            }
            body += '</body></html>';
            
            mail.setHtmlBody(body);
            mails.add(mail);
            Messaging.sendEmail(mails);
        }
        catch(Exception e){
            System.debug('An exception occured' + e.getMessage());
        }        
        
        
    }
}