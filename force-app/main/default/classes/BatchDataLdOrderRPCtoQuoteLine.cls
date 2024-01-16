/*********
*Created By : ieswarya on Oct 7 
* Description : Batch to move the data from Order Rate plan charge to CPQ quote lineitem as part of data migration
* Ticket : 
* History : 
* 08-10-2020 - Lister V - Modified the code to insert the Quote Line Item. 
* 19-10-2020 - Lister V - Modified the code to map the Billing frequency.
* */
global class BatchDataLdOrderRPCtoQuoteLine implements Database.Batchable<sObject>{
    global Set<String> failedOrders = new Set<String>();
    global Set<String> errMessages = new Set<String>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        string RecordNolo = Schema.SObjectType.invoiceit_s__Job_Rate_Plan_Charge__c.getRecordTypeInfosByName().get('M-N Order Rate Plan Charge').getRecordTypeId();// '0120G000000zreHQAQ' ; 
        String query ='';
        
         List<SBQQ__Quote__c> q =[Select legacy_order_number__C from SBQQ__Quote__c where recordtype.Name like '%Nolo Quote%' and legacy_order_number__C != null and lastmodifieddate =2021-05-28T09:50:49.000+0000 and lastmodifiedbyid = '0053w0000099RPIAA2'];
        Set<String> legacyorders = new Set<String>();
        for(SBQQ__Quote__c quote:q){
            legacyorders.add(quote.legacy_order_number__C);
        }
       // list<string> listofIds = new list<string>{'3178021'};   
        list<string> listofstatus = new list<string>{'Active','Evergreen'};
            if(test.isRunningTest()){
                query = 'Select Id,Name,invoiceit_s__charge_Date__c,invoiceit_s__Next_Charge_Date__c,invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,';
                query +='Picked_for_Shipping__c,Shipping_Tracking_Number__c,Cancel_Date__c,invoiceit_s__Quantity__c,Renew_Rebase_Truncate_Date__c,invoiceit_s__Product_Charge_Category__c,';
                query +='Live_Date__c,Fulfilment_Start_Date__c,Fulfilment_End_Date__c,invoiceit_s__Product_Rate_Plan_Charge__c,invoiceit_s__Sequence_No__c,invoiceit_s__Row_Total__c,';
                query +='invoiceit_s__Price_Type__c,LastModifiedById,CreatedById,invoiceit_s__Order__c,invoiceit_s__Order__r.name,';
                query +='Shipper_Name__c,SIN__c,Loss_Reasons__c from invoiceit_s__Job_Rate_Plan_Charge__c limit 1';
            }else{
                query = 'Select Id,Name,invoiceit_s__charge_Date__c,invoiceit_s__Next_Charge_Date__c,invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__c,';
                query +='Picked_for_Shipping__c,Shipping_Tracking_Number__c,Cancel_Date__c,invoiceit_s__Quantity__c,Renew_Rebase_Truncate_Date__c,invoiceit_s__Product_Charge_Category__c,';
                query +='Live_Date__c,Fulfilment_Start_Date__c,Fulfilment_End_Date__c,invoiceit_s__Product_Rate_Plan_Charge__c,invoiceit_s__Sequence_No__c,invoiceit_s__Row_Total__c,';
                query +='invoiceit_s__Price_Type__c,LastModifiedById,CreatedById,invoiceit_s__Order__c,invoiceit_s__Order__r.name,';
                query +='Shipper_Name__c,SIN__c,Loss_Reasons__c from invoiceit_s__Job_Rate_Plan_Charge__c';
                query +=' where RecordtypeId=:RecordNolo and invoiceit_s__Order__r.invoiceit_s__Status__c in: listofstatus and invoiceit_s__Order__r.Name in :legacyorders';
                System.debug('Order Rate plan charge Query => '+query);
            }
        return Database.getQueryLocator(query);
        
    }
    public void execute(Database.BatchableContext BC, List<invoiceit_s__Job_Rate_Plan_Charge__c> ListofOrderRPC) {
        system.debug('ListofRPC'+ListofOrderRPC.size());
        list<SBQQ__QuoteLine__c> ListofCPQQuoteLines = new list<SBQQ__QuoteLine__c>();
        
        /** 1. Lister - 08-10-2020 To get the related Inventry Id from the Order Product**/ 
        Set<Id> orderRatePlanIds = new Set<Id>();
        Set <Id> PrdtRatePlanChargeIds = new Set<Id>();
        Set<String> ProductCodeSet = new Set<String>();
        Set <Id> OrderProductIds = new Set<Id>();
        Set<Id> OrderIdSet = new Set<Id>();
        Set<String> OrderNumberSet = new Set<String>();
      //  Map<SBQQ__Quote__c,String> failedORPCs = new Map<SBQQ__Quote__c,String>();
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c Ojob: ListofOrderRPC){
            orderRatePlanIds.add(Ojob.invoiceit_s__Job_Rate_Plan__c);
            PrdtRatePlanChargeIds.add(Ojob.invoiceit_s__Product_Rate_Plan_Charge__c);
            OrderIdSet.add(Ojob.invoiceit_s__Order__c);
        }
        
        Map<Id,invoiceit_s__Job_Rate_Plan__c> ORPMap = new Map<Id,invoiceit_s__Job_Rate_Plan__c>([SELECT Id,invoiceit_s__Job_Product__c 
                                                                                                  FROM invoiceit_s__Job_Rate_Plan__c 
                                                                                                  WHERE Id IN:orderRatePlanIds ]);
        
        for(invoiceit_s__Job_Rate_Plan__c Objorp : ORPMap.values()){
            OrderProductIds.add(Objorp.invoiceit_s__Job_Product__c);
        }
        
        Map<Id,invoiceit_s__Job_Product__c> OrdrProductMap = new Map<Id,invoiceit_s__Job_Product__c>([SELECT Id,Inventory_Id__c 
                                                                                                      FROM invoiceit_s__Job_Product__c
                                                                                                      WHERE Id IN:OrderProductIds]); 
        
        /** 2. Lister - 08-10-2020 To get the related Product field values**/
        Map<Id,invoiceit_s__Product_Rate_Plan_Charge__c> PrdRateplanMap = new Map<Id,invoiceit_s__Product_Rate_Plan_Charge__c>([SELECT Id,Product_Code__c
                                                                                                                                FROM invoiceit_s__Product_Rate_Plan_Charge__c
                                                                                                                                WHERE Id IN :PrdtRatePlanChargeIds]);
        
        for(invoiceit_s__Product_Rate_Plan_Charge__c ObRate: PrdRateplanMap.values()){
            ProductCodeSet.add(ObRate.Product_Code__c);
        }
        
        Map<String,Product2> ProductMap = new Map<String,Product2>();
        list<string> listofproductNames = new list<string>{'Nolo Leads','Nolo Profile'};
            for(Product2 Objprod : [SELECT Id,Name, IsActive ,ProductCode,SBQQ__SubscriptionType__c,SBQQ__SubscriptionPricing__c,
                                    SBQQ__SubscriptionTerm__c,SBQQ__SubscriptionBase__c,SBQQ__ChargeType__c
                                    FROM Product2 WHERE ProductCode IN :ProductCodeSet and Name in : listofproductNames and IsActive=true]){
                                        ProductMap.put(Objprod.ProductCode,Objprod);
                                    }
        
        /** 3. Lister - 08-10-2020 To get the related QuoteId **/
        Map<Id,invoiceit_s__Job__c> OrderMap = new Map<Id,invoiceit_s__Job__c>([SELECT Id,Name 
                                                                                FROM invoiceit_s__Job__c 
                                                                                WHERE ID IN:OrderIdSet]);
        for(invoiceit_s__Job__c objorder :OrderMap.values()){
            OrderNumberSet.add(objorder.Name);
        }
        System.debug(OrderNumberSet);
        Map <String,SBQQ__Quote__c> QuoteMap = new Map <String,SBQQ__Quote__c>();
        for(SBQQ__Quote__c objquote:[SELECT Id,Legacy_Order_Number__c FROM SBQQ__Quote__c WHERE Legacy_Order_Number__c IN :OrderNumberSet]){
            QuoteMap.put(objquote.Legacy_Order_Number__c,objquote);
        }
        System.debug(QuoteMap);
        /** 4. Lister - 08-10-2020 Create the QuotelineItems **/
        Map<String,Id> pbEntryMap = new Map<String,Id>();
            List<PriceBookEntry> pbentry = [Select Id,ProductCode from PriceBookEntry where Name like '%Nolo%'];
            
            for(PriceBookEntry pbe: pbentry){
                pbEntryMap.put(pbe.ProductCode,pbe.Id);
            }
        for(invoiceit_s__Job_Rate_Plan_Charge__c objob: ListofOrderRPC){
            System.debug('Current job id : '+ objob.Id);
            SBQQ__QuoteLine__c ObjQutLine = new SBQQ__QuoteLine__c();
            ObjQutLine.SBQQ__Taxable__c = objob.invoiceit_s__Product_Charge_Category__c == 'Taxable' ? true : false;
            if(QuoteMap != null  && QuoteMap.get(OrderMap.get(objob.invoiceit_s__Order__c).Name) != null){
            ObjQutLine.SBQQ__Quote__c = QuoteMap.get(OrderMap.get(objob.invoiceit_s__Order__c).Name).Id;
            }
            ObjQutLine.SBQQ__ProductSubscriptionType__c ='Renewable/Evergreen';
            if(!test.isRunningtest()){
                ObjQutLine.SBQQ__SubscriptionType__c = ProductMap.get(PrdRateplanMap.get(objob.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Code__c).SBQQ__SubscriptionType__c;
                if(ObjQutLine.SBQQ__SubscriptionType__c == 'Evergreen'){
                    ObjQutLine.SBQQ__SubscriptionTerm__c = 1;
                }
                ObjQutLine.SBQQ__SubscriptionPricing__c = ProductMap.get(PrdRateplanMap.get(objob.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Code__c).SBQQ__SubscriptionPricing__c;
                ObjQutLine.SBQQ__SubscriptionBase__c = ProductMap.get(PrdRateplanMap.get(objob.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Code__c).SBQQ__SubscriptionBase__c;
                ObjQutLine.SBQQ__DefaultSubscriptionTerm__c = ProductMap.get(PrdRateplanMap.get(objob.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Code__c).SBQQ__SubscriptionTerm__c;
                ObjQutLine.SBQQ__ChargeType__c = ProductMap.get(PrdRateplanMap.get(objob.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Code__c).SBQQ__ChargeType__c;
                ObjQutLine.SBQQ__Product__c = ProductMap.get(PrdRateplanMap.get(objob.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Code__c).Id;
            }
            ObjQutLine.SBQQ__Number__c = objob.invoiceit_s__Sequence_No__c;
            ObjQutLine.SBQQ__ListPrice__c = objob.invoiceit_s__Row_Total__c;
            ObjQutLine.SBQQ__Quantity__c = objob.invoiceit_s__Quantity__c ;
            /** 19-10-2020 - Lister- Modified the code to map the Billing frequency **/
            if(objob.invoiceit_s__Price_Type__c == 'Monthly'){
                ObjQutLine.SBQQ__BillingFrequency__c ='Monthly';
            }else if(objob.invoiceit_s__Price_Type__c == 'Annual'){
                ObjQutLine.SBQQ__BillingFrequency__c='Annual';
            }else if(objob.invoiceit_s__Price_Type__c == 'One Time'){
                ObjQutLine.SBQQ__BillingFrequency__c='';
            }else if(objob.invoiceit_s__Price_Type__c == 'Usage'){
                ObjQutLine.SBQQ__BillingFrequency__c='';
            }
            ObjQutLine.LastModifiedById = objob.LastModifiedById;
            ObjQutLine.CreatedById = objob.CreatedById;
            ObjQutLine.recordtypeid= Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('Nolo Quote Line').getRecordTypeId();//'0127f000000Gsjd';
            
            
            if(PrdRateplanMap.get(objob.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Code__c == '40020'){
                ObjQutLine.SBQQ__PricebookEntryId__c =pbEntryMap.get('40020');// '01t7f000003tYhx';               
            }else if(PrdRateplanMap.get(objob.invoiceit_s__Product_Rate_Plan_Charge__c).Product_Code__c == '40010'){
                ObjQutLine.SBQQ__PricebookEntryId__c = pbEntryMap.get('40010');//'01t7f000003tYhy'; 
            }
            ObjQutLine.Inventory_Id__c = OrdrProductMap.get(ORPMap.get(objob.invoiceit_s__Job_Rate_Plan__c).invoiceit_s__Job_Product__c).Inventory_Id__c;
            ObjQutLine.Live_Date__c = objob.Live_Date__c;
            ObjQutLine.Legacy_Current_Charge_Date__c = objob.invoiceit_s__Charge_Date__c;
            ObjQutLine.Legacy_Next_Charge_Date__c = objob.invoiceit_s__Next_Charge_Date__c;
            ObjQutLine.Shipping_Tracking_Number__c = objob.Shipping_Tracking_Number__c;
            ObjQutLine.Shipper_Name__c = objob.Shipper_Name__c;
            ObjQutLine.SIN__c = objob.SIN__c;
            ObjQutLine.Loss_Reasons__c = objob.Loss_Reasons__c;
            ObjQutLine.Isdataloaded__c = 'Y';
            ListofCPQQuoteLines.add(ObjQutLine);
            
        } 
        
      //  try{
              List<Database.SaveResult> insertResults = Database.insert(ListofCPQQuoteLines, false);
            for(Integer i=0;i<insertResults.size();i++){
                 if (!insertResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = insertResults.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    ListofCPQQuoteLines.get(i);//failed record from the list
                   // system.debug('Failed ID'+ListofCPQQuotes.get(i));
                  //   system.debug('Failed ID'+ListofCPQQuoteLines.get(i).legacy_order_number__C);
                //  failedOrders.add(ListofCPQQuotes.get(i).legacy_order_number__C);
              //  orderNameVsorderMap.get(ListofCPQQuotes.get(i).legacy_order_number__C).Data_Load_Error__c = failedDML;
                     System.debug(FailedDML);
                    // failedORPCs.put(ListofCPQQuoteLines.get(i).SBQQ_Quote__c)
                     failedOrders.add(ListofCPQQuoteLines.get(i).legacy_order_number__C);
                      errMessages.add(failedDML);
                }
                
            }

            //insert ListofCPQQuoteLines;
      //  }catch(Exception ex){
      //      system.debug('exception' + ex.getMessage());
     //       system.debug('exception' + ex.getLineNumber());
     //   }
    }
    
    public void finish(Database.BatchableContext BC) {
         List<String> toEmailAddress = new List<String>();
        toEmailAddress.add('sushmidha.sakthiveeran@internetbrands.com');
     //   toEmailAddress.add('lori.ashley@martindale.com');
     //   toEmailAddress.add('sai.chandan@martindale.com');
      //  toEmailAddress.add('niketan.badani.1@martindale.com');
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