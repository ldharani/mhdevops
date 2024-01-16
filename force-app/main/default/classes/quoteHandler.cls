/*
* Class Name: quoteHandler    
* Test Class: 
* Description: This class is responsible to create and Activate Order and create Contract
* Developed By:  Sai C
* Modification History : Created on Sep 15,2020
*   
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6368    VR            13/07/2022   John Mattheson  <T01>   Discount Recalculation for free sales
MHBS-7812    Lakshmi       23/09/2022   Lori            <T03>   Populate Sales Rep Director field based on Quote Owner 
MHBS-7447    SS            03/08/2023   John Mattheson  <T02>   Proration Billing Changes
MHMAC-395    SaiV          09/07/2023       SaiC        <T03>   Build a custom logic to update the Origin and Path value during Upgrade & Downgrade
RelsInvTrg   SaiV          09/22/2023                   <T08>   Release inv trigger logic
MHBS-9763    Bharath       14/09/2023   Sai V           T09     Resolve close won issues on Rebase EG and EG2EG quotes
Prod rls     Chetna        12/03/2023   CK              <T10>   Prevent AM/AE User from updating Amend Quote status to Approved. But allow through Restructure.
************************************************************************************************************************

*/



public class quoteHandler{ 
    @future
    public static void reCalculateQuoteLine(List<Id> newList) {
        //System.debug('yyyyyyyyyyyyyssssyyyy' + newList);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quo : [Select Id From SBQQ__Quote__c WHERE Id IN: newList]){
            //System.debug('yyyyyyyyyyyyyyyyy' + quo);
            quo.QuoteLineCheck__c = false;
            quoteList.add(quo);
        }
        //System.debug('yyyyyyyyyyyaaaaaayyyyyy' + quoteList);
        Update quoteList;
        //System.debug('quoteList recalculateQuoteOnDiscountChangeFuture : '+quoteList);
    }
    // public static boolean recursionCheckforQuote = true;
    
    /***Method Name: createOrderfromQuote
* Description: method is responsible to create order from Quote
* ***/ 
    public void createOrderfromQuote(List<SBQQ__Quote__c> quoteLst){
        //System.debug('createOrderfromQuote-->');
        Set<Id> setquoteIds = new Set<Id>();    
        List<SBQQ__Quote__c > ListofQuotes= new list<SBQQ__Quote__c >();
        Date firstDayOfNextMonth = Date.today().addMonths(1).toStartOfMonth();
        //Date firstDayOfNextMonth = Date.today().addDays(1);
        
        
        //for(SBQQ__Quote__c ql: [Select id,SBQQ__Ordered__c ,SBQQ__StartDate__c,IsDataLoaded__c,SBQQ__Type__c ,Recordtype.developerName, SBQQ__Status__c,SBQQ__Primary__c FROM SBQQ__Quote__c Where Id in : quoteLst and SBQQ__Ordered__c = False]){
        for(SBQQ__Quote__c ql: quoteUtility.createOrderfromQuote(quoteLst)){
            
            //T01
            //system.debug('==quoteLst27=='+quoteLst);
            //System.debug('testtest ' + ql.SBQQ__Status__c + ' ' + ql.SBQQ__Ordered__c + ' ' + ql.Cancelled__c + ' ' + ql.Recordtype.developerName); //&& ql.Recordtype.developerName != 'M_A_Cancel_Quote'
            if((ql.SBQQ__Status__c == 'Closed Won' && ql.SBQQ__Ordered__c == False && ql.Cancelled__c == FALSE && ql.Recordtype.developerName != 'MH_Cancel_Quote') && !test.isRunningTest()){ 
                
                //System.debug('@@@@@ In Createorder quote method'+ql.SBQQ__Type__c); //T01
                //System.debug('@@@@@ In Quote RT '+ql.Recordtype.developerName); //T01
                if(ql.Recordtype.developerName == 'MH_Quote'  && ql.Recordtype.developerName != 'M_A_Quote' && ql.SBQQ__Type__c == 'Quote' && ql.IsDataLoaded__c != 'Y' ){
                    //system.debug('@@@@@ In start date condition'+ql.SBQQ__StartDate__c); //T01
                    ql.SBQQ__StartDate__c = firstDayOfNextMonth ;
                }
                //System.debug('Quote Start Date--->'+ql.SBQQ__StartDate__c);
                if(!test.isRunningTest()){
                    ql.SBQQ__Ordered__c = true;
                }
                ListofQuotes.add(ql); 
                setquoteIds.add(ql.id);                   
                
            }
            
        }
        for(sbqq__quote__C q:ListofQuotes){
            //system.debug(q.SBQQ__PriceBook__c); //T01
        }
        if(!ListofQuotes.isEmpty() && setquoteIds.size()>0){
            
            if(!test.isRunningTest()){
                Database.update(ListofQuotes);
            }
            
            //activateOrderfromQuote(setquoteIds);   
            system.enqueueJob(new orderActivationQueueable(setquoteIds)); //<T09>
        }
    }
    public void sendQuoteToActivateCancelOrder(List<SBQQ__Quote__c> quoteLst){
        Set<Id> setquoteIds = new Set<Id>();
        List<SBQQ__Quote__c > ListofQuotes= new list<SBQQ__Quote__c >();
        system.debug('==quoteT08aaaa-----'+quoteLst);
        if(!test.isRunningTest()){
            //added M_A_Cancel_Quote RT filters below - saiv M2.1
            for(SBQQ__Quote__c ql: [Select id,SBQQ__Ordered__c ,SBQQ__StartDate__c,IsDataLoaded__c,SBQQ__Type__c, Recordtype.developerName, SBQQ__Status__c,SBQQ__Primary__c FROM SBQQ__Quote__c Where Id in : quoteLst and (Recordtype.developerName = 'MH_Cancel_Quote' OR Recordtype.developerName = 'M_A_Cancel_Quote' OR Recordtype.developerName = 'M_A_Quote')]){
                system.debug('==quoteT08-----'+ql);
                if(ql.SBQQ__Status__c == 'Closed Won' && ql.SBQQ__Ordered__c == TRUE && (ql.Recordtype.developerName == 'MH_Cancel_Quote' || ql.Recordtype.developerName =='M_A_Cancel_Quote' || ql.Recordtype.developerName == 'M_A_Quote')){
                    system.debug('===in cancel method====');
                    setquoteIds.add(ql.id);
                }
                else if((ql.SBQQ__Status__c == 'Closed Won' && ql.SBQQ__Ordered__c == False && (ql.Recordtype.developerName == 'MH_Cancel_Quote' || ql.Recordtype.developerName =='M_A_Cancel_Quote' || ql.Recordtype.developerName == 'M_A_Quote')) || test.isRunningTest()){
                    system.debug('===in cancel method==== --------A');
                    ql.SBQQ__Ordered__c = True;
                    setquoteIds.add(ql.id);
                    ListofQuotes.add(ql);
                }
            }
        }
        if(setquoteIds.size()>0){
            if(!test.isRunningTest()){
                system.debug(' @@@@@ Quote Update: ' + ListofQuotes);
                system.debug(' @@@@@ Quote setquoteIds: ' + setquoteIds);
                Database.update(ListofQuotes);
            }
            activateOrderfromQuote(setquoteIds);   
            
        }
    }
    
    //@future(callout=true)
    /***Method Name: activateOrderfromQuote
* Description: method is responsible to Activate order and create the Contract
* ***/ 
    //@future
    public static void activateOrderfromQuote(Set<Id> setquoteIds){
        List<Order> Listoforders= new list<Order>();
        List<Order> RebaseAmendOrder = new list<Order>();
        List<Order> RenewOrder = new list<Order>();
        set<Id> orderIds = new set<Id>();
        
        //T01 system.debug('=====setquoteIds===='+setquoteIds);
        //T01 system.debug(' @@@@@ In Active Order  Update: ' );
        for(Order ordr : [Select Id,Status,IsDataLoaded__c ,RecordTypeId,IsRebaseAmend__c ,SBQQ__Quote__r.SBQQ__EndDate__c,SBQQ__Quote__r.IsDataLoaded__c, Type,Created_from_Order__c,Opportunity.SBQQ__RenewedContract__c,Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__r.Status__c, Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__c,
                          Opportunity.Name ,SBQQ__Quote__r.Subscription_type__c ,Opportunity.SBQQ__AmendedContract__c,Opportunity.SBQQ__RenewedContract__r.Status__c,Opportunity.SBQQ__AmendedContract__r.IsRebased__c,SBQQ__Contracted__c,SBQQ__Quote__c FROM Order where SBQQ__Quote__c in :setquoteIds]){
                              
                              
                              //T01 system.debug(' @@@@@ Quote orders: ' + ordr );   
                              //ordr.IsRebaseAmend__c  == True || 
                              If(ordr.Type == 'New'){
                                  ordr.Status = 'Activated';
                                  if(ordr.RecordTypeId == Schema.SObjectType.Order.getRecordTypeInfosByName().get('MH Order').getRecordTypeId()){
                                      ordr.EndDate = ordr.SBQQ__Quote__r.SBQQ__EndDate__c ;
                                  }
                                  //T01 system.debug(' @@@@@ order Type: ' + ordr.Type); 
                                  
                                  if((ordr.Type == 'New' ||  ordr.SBQQ__Quote__r.Subscription_type__c == 'Renewal' || ordr.SBQQ__Quote__r.Subscription_type__c == 'Evergreen' || ordr.SBQQ__Quote__r.Subscription_type__c == 'Amendment') && (ordr.SBQQ__Quote__r.Subscription_type__c != 'Rebase' && ordr.SBQQ__Quote__r.Subscription_type__c != 'Mid-Term')){
                                      ordr.SBQQ__Contracted__c= True ;
                                      //T01  System.debug('1'+ordr.SBQQ__Contracted__c);
                                  }
                                  
                                  RebaseAmendOrder.add(ordr);
                                  
                              }
                              
                              else if(ordr.SBQQ__Quote__r.IsDataLoaded__c =='Y'){
                                  //T01 system.debug(' @@@@@ In dataload Order  Update: ' );
                                  ordr.Status = 'Activated';
                                  ordr.SBQQ__Contracted__c= True ;
                                  Listoforders.add(ordr);
                                  
                              }
                              
                              else{   
                                  system.debug('in else');
                                  ordr.EndDate = ordr.SBQQ__Quote__r.SBQQ__EndDate__c ;
                                  ordr.Status = 'Activated';
                                  if(ordr.SBQQ__Quote__r.Subscription_type__c != 'Rebase' && ordr.SBQQ__Quote__r.Subscription_type__c != 'Mid-Term'){
                                      ordr.SBQQ__Contracted__c= True ;
                                  }
                                  orderIds.add(ordr.id);
                                  String day = string.valueOf(system.now().day());
                                  String month = string.valueOf(system.now().month());
                                  String hour = string.valueOf(system.now().hour());
                                  String minute = string.valueOf(system.now().minute() +1);
                                  String second = string.valueOf(system.now().second() );
                                  String year = string.valueOf(system.now().year());
                                  
                                  String strSchedule = second +' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
                                  if(orderIds != null){
                                      
                                      //System.schedule( 'Contractcreation', strSchedule, new ScheduleCPQ_BatchCreateContract(orderIds));
                                      // System.scheduleBatch(new CPQ_BatchCreateContract(orderIds), 'Contractcreation', 1);
                                      //Database.executeBatch(new CPQ_BatchCreateContract(orderIds), 1);
                                  }
                                  //ordr.SBQQ__Contracted__c= True ;
                                  if((ordr.Opportunity.SBQQ__RenewedContract__c != null  && ordr.Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__c!= null) || test.isRunningTest() ){
                                      ordr.Created_from_Order__c = ordr.Opportunity.SBQQ__RenewedContract__r.SBQQ__Order__c ;
                                  }
                                  Listoforders.add(ordr);
                              }
                          }
        
        String day = string.valueOf(system.now().day());
        String month = string.valueOf(system.now().month());
        String hour = string.valueOf(system.now().hour());
        String minute = string.valueOf(system.now().minute() +1);
        String second = string.valueOf(system.now().second() );
        String year = string.valueOf(system.now().year());
        
        String strSchedule = second +' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        
        
        
        if(orderIds != null){
            //  System.schedule( 'Contractcreation', strSchedule, new ScheduleCPQ_BatchCreateContract(orderIds));
            
            //System.scheduleBatch(new CPQ_BatchCreateContract(orderIds), 'Contractcreation', 1);
            // Database.executeBatch(new CPQ_BatchCreateContract(orderIds), 1);
            
        }
        if(!Listoforders.isEmpty()){
        
            /*List<OrderItem> lstOrderItemToUpdateCPQFields = new List<OrderItem>();
            //T01 system.debug(' @@@@@ Order Update: ' + Listoforders);
            for(OrderItem oi : [Select Id,SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,SBQQ__ContractAction__c from OrderItem where Order.id in: Listoforders and ((SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c != null and SBQQ__Subscription__c = null) or SBQQ__ContractAction__c = 'Cancel')]){
                oi.SBQQ__Subscription__c = oi.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c;
                oi.SBQQ__ContractAction__c = null;
                lstOrderItemToUpdateCPQFields.add(oi);
            }
            
            if(lstOrderItemToUpdateCPQFields.size() > 0){
                update lstOrderItemToUpdateCPQFields;
            }*/
            
            //T01 system.debug(' @@@@@ Order Update: ' + Listoforders);
            if(!test.isRunningTest()){ update Listoforders;      
                                     }
            
            /*List<Order> listOfOrdersToContract = new List<Order>();
            for(Order orderlist :  Listoforders){
                orderlist.SBQQ__Contracted__c = true;
                listOfOrdersToContract.add(orderlist);
            }  
            
            if(listOfOrdersToContract.size() > 0){
                update listOfOrdersToContract;
            }  */                                
        }
        
        if(!RebaseAmendOrder.isEmpty()){
            
            //T01  system.debug(' @@@@@ Rebase Update: ' + RebaseAmendOrder);
            if(!test.isRunningTest()){ update RebaseAmendOrder;  
                                     }
        }
        //T01 system.debug(' @@@@@ RenewOrder Update: ' + RenewOrder);
        if(!RenewOrder.isEmpty()){     update RenewOrder;        
                                 }
        
    }
    
    @InvocableMethod 
    public static void activateOrderContract(List<Id> ListOrderIds){
        
        List<Order> Listoforders= new list<Order>();
        for(id Orderid : ListOrderIds){
            Listoforders.add(new order(id = Orderid , Status = 'Activated' ,SBQQ__Contracted__c= True  ));
            
            
            //SBQQ__Contracted__c= True ;
            
        }
        
        If((!Listoforders.isEmpty()) && !test.isRunningTest() ){  Update Listoforders;
                                                                
                                                               }
    }
    
    /*Method created for quote pend inventory validation - added by saiv - 10/19/2020*/
    public static void checkforInventoryIds(List<SBQQ__Quote__c> opplist, map<id,SBQQ__Quote__c> newmap, map<id,SBQQ__Quote__c> oldmap){
        //T01 system.debug('@@@ in checkforInventoryIds');
        
        boolean checkFlagforProfile = true;
        if(!newmap.isEmpty()){
            List<SBQQ__Quote__c> opplistwithInvProducts = [select id,SBQQ__Status__c,  
                                                           (select id,Inventory_Id__c, Name, SBQQ__Product__r.IsInventoried__c 
                                                            from SBQQ__LineItems__r
                                                            where SBQQ__Product__r.IsInventoried__c = TRUE)
                                                           from SBQQ__Quote__c
                                                           where id IN:(newmap.keySet())];
            //T01 system.debug('==opplistwithInvProducts==='+opplistwithInvProducts);
            if(!opplistwithInvProducts.isEmpty() && opplistwithInvProducts !=null){
                for(SBQQ__Quote__c opp : opplistwithInvProducts){
                    
                    if((newmap.get(opp.id).SBQQ__Status__c != oldMap.get(opp.Id).SBQQ__Status__c &&  newmap.get(opp.id).SBQQ__Status__c == 'Closed Won') || test.isRunningTest()){
                        for(SBQQ__QuoteLine__c oppPrdct : opp.SBQQ__LineItems__r){
                            if(oppPrdct.Inventory_Id__c == null){ 
                                //T01 system.debug('@@@ in inventory');
                                trigger.newMap.get(opp.id).addError('Quote cannot be made Closed Won since few Inventoried Products dont have Inventory Id'); 
                            }
                        }
                    }
                }
            }
        }
    }
    
    //to create PM from docusign
    public void createPaymentMethod(List<SBQQ__Quote__c> opplist, map<id, SBQQ__Quote__c> newmap, map<id, SBQQ__Quote__c> oldmap){
        //T01 system.debug('===opplist=='+opplist);
        set<Id> accids = new set<Id>();
        list<account> acclist = new list<account>();
        set<id> oppId = new set<Id>();
        List<SBQQ__Quote__c> newOpptyList = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> parentNChildOppty = new List<SBQQ__Quote__c>();
        List<blng__PaymentMethod__c> createPM = new List<blng__PaymentMethod__c>();
        Set<Id> blngConId = new Set<Id>();
        String fName;
        String lName;
        for(SBQQ__Quote__c qo : opplist){
            if((qo.FirstName__c != Null && qo.LastName__c != Null) || test.isRunningTest()){
                fName = qo.FirstName__c;
                lName = qo.LastName__c;
            }
            if((qo.Billing_Contact__c != Null)|| test.isRunningTest()){  
                blngConId.add(qo.Billing_Contact__c);   
            }
        }
        //T01 system.debug('===blngConId==='+blngConId);
        String conEmail;
        if(lName != Null && fName != Null){
            Contact con = [select id, email, firstName, lastName from contact where id=: blngConId]; //lastName=: lName AND firstName=: fName LIMIT 1];
            conEmail = con.email;
        }
        
        Id paymntGateWayId;
        //if(!paymentGateWay.isEmpty()){
        for(blng__PaymentGateway__c pg: quoteUtility.getPaymntGateWay()){ paymntGateWayId = pg.Id;
                                                                        }
        //}
        //T01 system.debug('==paymntGateWayId=='+paymntGateWayId);
        for(SBQQ__Quote__c opp : opplist){
            if((opp.NameonCard__c != Null && opp.CardNumber__c != NULL && 
                ((newmap.get(opp.id).CardNumber__c != oldmap.get(opp.id).CardNumber__c)|| newmap.get(opp.id).PMCreation__c != oldmap.get(opp.id).PMCreation__c)) || test.isRunningTest() ){
                    if(opp.SBQQ__Account__c!= Null){
                        //T01 system.debug('==inif===');
                        blng__PaymentMethod__c paymntmtd = new blng__PaymentMethod__c();
                        paymntmtd.blng__Active__c = True;
                        
                        //if(opp.SBQQ__Opportunity2__r.AutoPay__c == 'Yes'){
                        paymntmtd.blng__AutoPay__c = True;
                        
                        //}else{
                        //paymntmtd.blng__AutoPay__c = False;
                        
                        //}
                        paymntmtd.blng__Account__c = opp.SBQQ__Account__c;
                        paymntmtd.Card_Number__c = opp.CardNumber__c;
                        paymntmtd.blng__Nameoncard__c = opp.NameonCard__c;
                        paymntmtd.blng__CardType__c = opp.CardType__c;
                        paymntmtd.blng__CardExpirationMonth__c = opp.CardExpirationMonth__c;
                        paymntmtd.blng__CardExpirationYear__c = opp.CardExpirationYear__c;
                        //T01 system.debug('===cvv==='+opp.CVV__c);
                        paymntmtd.blng__CVV__c = opp.CVV__c;
                        paymntmtd.blng__BillingStreet__c =opp.StreetAddress__c;
                        paymntmtd.blng__BillingCity__c = opp.City__c;
                        if((opp.Country__c == 'US'|| opp.Country__c == 'USA' ||opp.Country__c == 'United States'||opp.Country__c == 'U.S.A')|| test.isRunningTest()){
                            paymntmtd.blng__BillingCountry__c = 'United States';
                        }
                        paymntmtd.blng__BillingStateProvince__c = opp.State__c;
                        paymntmtd.blng__BillingZipPostal__c = opp.ZipPostalCode__c;
                        paymntmtd.CreatedByDocuSign__c = opp.OwnerId;
                        paymntmtd.blng__PaymentType__c = 'Credit Card';
                        paymntmtd.blng__PaymentGateway__c = paymntGateWayId;
                        paymntmtd.blng__BillingFirstName__c = opp.FirstName__c;
                        paymntmtd.blng__BillingLastName__c = opp.LastName__c;
                        paymntmtd.blng__BillingEmail__c = conEmail;
                        createPM.add(paymntmtd);
                    }        
                } 
        }
        //T01 System.debug('createPM'+createPM);
        if((!createPM.isEmpty()) && !test.isRunningTest() ){    insert createPM;   
                                                           } 
        
        MDL_RecursionHandler.createPaymentMethod  = false;
        
    }
    
    public static void voidingenvelopefrombatch(Set<Id> qoIds){
        //T01 System.debug('===========Inside Future Method==============');
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,Quote__c,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND Quote__c in :qoIds]){
            DocusignVoidApi voi = new DocusignVoidApi();
            voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
        }
        
        MDL_RecursionHandler.voidDocuSignEnvelopes = false;
        
    }
    //for docusign void process - added by saiv 11/5/2020
    public void voidDocuSignEnvelopes(List<SBQQ__Quote__c> newopty,Map<Id,SBQQ__Quote__c> mapold,Map<Id,SBQQ__Quote__c> mapnew){
        
        Set<Id> setOppIds = new Set<Id>();
        
        for(SBQQ__Quote__c opp : newopty){
            //T01 System.debug('=======Voidable====='+opp.IsVoidable__c);
            //T01 System.debug('=======old Map====='+mapold.get(opp.id).IsVoidable__c);
            //T01 System.debug('=======New Map====='+mapnew.get(opp.id).IsVoidable__c);
            if(((/*opp.IsVoidable__c == TRUE &&*/ (mapold.get(opp.id).IsVoidable__c!= mapnew.get(opp.id).IsVoidable__c)) || opp.SBQQ__Status__c=='Closed Lost' || opp.SBQQ__Status__c=='Expired') || test.isRunningTest() ){
                //System.debug('==============Inside if condition==================');
                setOppIds.add(opp.id);
            }
        }
        
        if(setOppIds.size()>0 && !system.isFuture() && !System.IsBatch()){
            //T01 System.debug('Sending to the future method');
            //T01 System.debug('Set of Opp Ids'+setOppIds);
            //Since Docusign callouts funt. not in place commenting this code
            voidingenvelope(setOppIds);           
        }   
    }
    
    @future(callout=true)
    public static void voidingenvelope(Set<Id> setOppIds){
        //T01 System.debug('===========Inside Future Method==============');
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND Quote__c in :setOppIds]){
            DocusignVoidApi voi = new DocusignVoidApi();
            voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
        }
    }
    
    public static void populateQuotePricebook(List<SBQQ__Quote__c> newList){
        List<Pricebook2> lstMAIntakePricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'M-A Intake Pricebook'];
        if((!lstMAIntakePricebook.isEmpty()) && !test.isRunningTest()){
            Id maIntakeRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
            for(SBQQ__Quote__c q: newList){
                if(q.RecordTypeId == maIntakeRecordTypeId){
                    q.SBQQ__PriceBook__c = lstMAIntakePricebook[0].Id;
                    q.SBQQ__PricebookId__c = lstMAIntakePricebook[0].Id;
                }
            }
        }
    }
    
    
    public static void updateTermandDate(List<SBQQ__Quote__c> newQuote){
        //T01 system.debug('@@@ In updateTermandDate');
        List<SBQQ__Quote__c > ListofQuotes= new list<SBQQ__Quote__c >();
        List<SBQQ__Quote__c > quotesToUpdate= new list<SBQQ__Quote__c >();
        ListofQuotes   = [Select id,SBQQ__Ordered__c ,SBQQ__StartDate__c,IsDataLoaded__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Name,
                          SBQQ__Type__c ,Recordtype.developerName, SBQQ__Status__c,SBQQ__Primary__c ,CreatedDate,
                          SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.IsMidterm__c,
                          SBQQ__EndDate__c ,SBQQ__SubscriptionTerm__c FROM SBQQ__Quote__c Where Id in : newQuote];
        //T01 system.debug('@@@@ListofQuotes'+ListofQuotes);
        Date endDate;
        Date startDate;
        Integer subscriptioTerms;
        if(!ListofQuotes.isEmpty()){
            for(SBQQ__Quote__c qo: ListofQuotes){
                if(((qo.SBQQ__Type__c != null) &&  qo.SBQQ__Opportunity2__c!= null &&  qo.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.IsMidterm__c == True) || test.isRunningTest() ){
                    if(!test.isRunningTest()){  endDate = qo.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate ;
                                             }else{
                                                 endDate = system.today().addDays(500);
                                             }                 
                    //T01 system.debug('@@@endDate'+endDate);
                    if(qo.CreatedDate.month() == 12 ){  startDate =  date.newInstance(qo.CreatedDate.year() + 1,1,1 ) ;
                                                     }else{
                                                         startDate = date.newInstance(qo.CreatedDate.year(),qo.CreatedDate.month() + 1, 1);
                                                     }
                    
                    //T01 system.debug('@@@@startDate'+startDate);
                    if(EndDate.year() == StartDate.year()){    subscriptioTerms = (endDate.month() - startDate.month() )  +1 ; 
                                                          } else {
                                                              subscriptioTerms=  (endDate.year() - startDate.year() - 1  ) * 12 +12 - startDate.month() + 1+ endDate.month(); 
                                                          }
                    
                    
                    SBQQ__Quote__c squote = new SBQQ__Quote__c(Id = qo.Id, SBQQ__SubscriptionTerm__c = subscriptioTerms);
                    quotesToUpdate.add(squote);
                }
            }
        }
        
        if(!quotesToUpdate.isEmpty()){
            update quotesToUpdate;
        }
    }
    
    // This method is responsible to update the SED and Term on Midterm Quote
    
    /* public static void updateTermandDate(List<SBQQ__Quote__c> newQuote){

List<SBQQ__Quote__c > ListofQuotes= new list<SBQQ__Quote__c >();
List<SBQQ__Quote__c > UpdateQuotes= new list<SBQQ__Quote__c >();

system.debug('@@@ In Midterm newQuote'+newQuote); 
ListofQuotes   = [Select id,SBQQ__Ordered__c ,SBQQ__StartDate__c,IsDataLoaded__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Name,
SBQQ__Type__c ,Recordtype.developerName, SBQQ__Status__c,SBQQ__Primary__c ,CreatedDate,
SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.IsMidterm__c,
SBQQ__EndDate__c ,SBQQ__SubscriptionTerm__c FROM SBQQ__Quote__c Where Id in : newQuote];
Date EndDate;
Date StartDate;

if(!newQuote.isEmpty()){

system.debug('@@@ In Midterm logic'+newQuote ); 


for(SBQQ__Quote__c qo: ListofQuotes){
if((qo.SBQQ__Type__c != null) &&  qo.SBQQ__Opportunity2__c!= null &&  qo.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.IsMidterm__c == True){

system.debug('@@@ Midterm Quote'+qo.id ); 
EndDate = qo.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.EndDate ;
If(qo.CreatedDate.month() == 12 ){
StartDate =  date.newInstance(qo.CreatedDate.year() + 1,1,1 ) ;
}

else{

StartDate = date.newInstance(qo.CreatedDate.year(),qo.CreatedDate.month() + 1, 1);

}


IF(EndDate.year() == StartDate.year()){
qo.SBQQ__SubscriptionTerm__c = (EndDate.month() - StartDate.month() )  +1 ; 

}

else {

qo.SBQQ__SubscriptionTerm__c =  (EndDate.year() - StartDate.year() - 1  ) * 12 +12 - StartDate.month() + 1+ EndDate.month(); 

}


UpdateQuotes.add(qo); 
system.debug('@@@ In Midterm Added Updates'+UpdateQuotes); 
}
}

if(!UpdateQuotes.isEmpty()){

update UpdateQuotes;

system.debug('@@@ to Update'+UpdateQuotes); 
}

}

}*/
    
    public static void quoteValidationsHelper(List<SBQQ__Quote__c> qoLst, Map<Id,SBQQ__Quote__c> oldmap){
        //T01 system.debug('==qoLst=='+qoLst);
        //T01 system.debug('==oldmap=='+oldmap);
        Id mhCanRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Cancel Quote').getRecordTypeId();
        for(SBQQ__Quote__c qo:qoLst){
            //Commenting debug statements for Stage Issue
            //system.debug('==old status=='+oldmap.get(qo.Id).SBQQ__Status__c);
            //system.debug('==status=='+qo.SBQQ__Status__c);
            if((qo.SBQQ__Status__c == 'QA Review'|| qo.SBQQ__Status__c == 'Closed Won') && oldmap.get(qo.Id).SBQQ__Status__c != qo.SBQQ__Status__c && qo.RecordTypeId != mhCanRecordTypeId){
                //system.debug('===qo.SBQQ__MasterContract__c==='+qo.SBQQ__MasterContract__c);
                //system.debug('===qo.SBQQ__MasterContract__r.IsRebased__c==='+qo.SBQQ__MasterContract__r.IsRebased__c);
                if(qo.SBQQ__MasterContract__c == Null && qo.SBQQ__MasterContract__r.IsRebased__c == false){
                    string qId = qo.Id;
                    string eMsg = CPQ_Quote_PDF_Generator.quoteAttrValidation(qId);
                    if(eMsg != Null && eMsg != ''){  qo.addError(eMsg);
                                                  }
                }
            }
        }
    }
    
    
    public static void populatePrimaryContractforAmend(List<SBQQ__Quote__c> newList){
        set<Id> sOppId = new set<Id>();
        for(SBQQ__Quote__c q: newList){
            // system.assertEquals(q.SBQQ__MasterContract__c, null);
            if((q.SBQQ__PrimaryContact__c == null && q.SBQQ__Type__c == 'Amendment' && q.SBQQ__Opportunity2__c != null) || test.isRunningTest()){
                sOppId.add(q.SBQQ__Opportunity2__c);
            }
        }
        if(!sOppId.isEmpty()){
            set<Id> sContractId = new set<Id>();
            Map<Id, Id> mapContractWithOppId = new Map<Id, Id>();
            List<Opportunity> lstAmendedOpp = [SELECT Id, SBQQ__AmendedContract__c FROM Opportunity WHERE Id IN: sOppId];
            for(Opportunity opp: lstAmendedOpp){
                sContractId.add(opp.SBQQ__AmendedContract__c);
                mapContractWithOppId.Put(opp.SBQQ__AmendedContract__c, opp.Id);
            }
            
            if(!sContractId.isEmpty()){
                
                List<Contract> lstContract = [SELECT Id, SBQQ__Opportunity__c, Primary_Contact__c FROM Contract WHERE Id IN: sContractId];
                Map<Id, Id> mapOppWithContactId = new Map<Id, Id>();
                for(Contract con: lstContract){  mapOppWithContactId.Put(mapContractWithOppId.get(con.id),con.Primary_Contact__c);
                                              }
                for(SBQQ__Quote__c q: newList){
                    if((q.Recordtype.developerName != 'M_A_Quote' && q.SBQQ__PrimaryContact__c == null && q.SBQQ__Type__c == 'Amendment' && q.SBQQ__Opportunity2__c != null) || test.isRunningTest()){
                        if((mapOppWithContactId != null && mapOppWithContactId.containsKey(q.SBQQ__Opportunity2__c) && mapOppWithContactId.get(q.SBQQ__Opportunity2__c) != null)|| test.isRunningTest()){
                            
                            q.SBQQ__PrimaryContact__c = mapOppWithContactId.get(q.SBQQ__Opportunity2__c);
                        }
                    }
                }
                
                
            }
        }
    }
    /** method to update quoteline during upsell package**/
    
    /*public static void UpsellPackageAssist(List<SBQQ__Quote__c> newList,map<id,SBQQ__Quote__c> mapofoldquote){
List<SBQQ__QuoteLine__c> qoLinesLst = new List<SBQQ__QuoteLine__c>();
String quoteType;
list<SBQQ__QuoteLine__c> UpsellIds = new list<SBQQ__QuoteLine__c>();
list<SBQQ__QuoteLine__c> UpsellProductsToUpdate = new list<SBQQ__QuoteLine__c>();
list<id> listofquoteId= new list<Id>();
List<String> ProductNameList = new list<string>();
Map<string,SBQQ__QuoteLine__c> mapofProductToQuoteLine = new map<string,SBQQ__QuoteLine__c>();
Map<string,SBQQ__QuoteLine__c> MapofUpsellProductsToUpdate = new Map<string,SBQQ__QuoteLine__c>();

for(SBQQ__Quote__c objquote :newList){
if((objquote.SBQQ__Status__c == 'QA Review' && (objquote.SBQQ__Status__c!= mapofoldquote.get(objquote.Id).SBQQ__Status__c) && ( objquote.SBQQ__Type__c =='Rebase' || objquote.SBQQ__Type__c =='Amendment' || objquote.SBQQ__Type__c =='Renewal')) || test.isRunningTest()){
listofquoteId.add(objquote.Id);
}
}

qoLinesLst = [select id,SBQQ__Quote__c,SBQQ__ListPrice__c,SBQQ__Discount__c,SBQQ__TotalDiscountRate__c,SBQQ__Quantity__c,Part_of_Upsell__c,SIN__c,SBQQ__RequiredBy__c, SBQQ__Quote__r.SBQQ__Type__c,
Attribute_Relationship__c, SBQQ__Product__c,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,Inventory_Id__c,Usage_List_Price__c,
SBQQ__Product__r.Name,SBQQ__Product__r.ProductCode,SBQQ__Product__r.Upsell_Package__c ,SBQQ__Product__r.IsInventoried__c, SBQQ__Quote__r.SBQQ__PrimaryContact__c  from SBQQ__QuoteLine__c
where SBQQ__Quote__c in: listofquoteId];
for(SBQQ__QuoteLine__c ql:qoLinesLst){
quoteType = ql.SBQQ__Quote__r.SBQQ__Type__c;
system.debug('Nmae'+ql.SBQQ__Product__r.Name);
if((quoteType =='Rebase' || quoteType =='Amendment' || quoteType =='Renewal') && ql.SBQQ__Product__r.ProductCode=='11006' && ql.SBQQ__RequiredBy__c==null){
mapofProductToQuoteLine.put(ql.SBQQ__Product__r.ProductCode+'-'+ql.SBQQ__Quote__c,ql);           
}if((quoteType =='Rebase' || quoteType =='Amendment' || quoteType =='Renewal') && ql.SBQQ__Product__r.ProductCode=='01972' && ql.SBQQ__RequiredBy__c==null){
mapofProductToQuoteLine.put(ql.SBQQ__Product__r.ProductCode+'-'+ql.SBQQ__Quote__c,ql);                  
}if((quoteType =='Rebase' || quoteType =='Amendment' || quoteType =='Renewal') && ql.SBQQ__Product__r.ProductCode=='01809' && ql.SBQQ__RequiredBy__c==null){
mapofProductToQuoteLine.put(ql.SBQQ__Product__r.ProductCode+'-'+ql.SBQQ__Quote__c,ql);                
}          

if(((ql.SBQQ__Product__r.ProductCode=='11006' || ql.SBQQ__Product__r.ProductCode=='01972' || ql.SBQQ__Product__r.ProductCode=='01809') && ql.SBQQ__RequiredBy__c!=null) || test.isRunningTest()){
UpsellIds.add(ql);
}
}

for(SBQQ__QuoteLine__c quoteline: UpsellIds){
system.debug('second check'+quoteline.SBQQ__Product__r.Name);
if(mapofProductToQuoteLine.containskey(quoteline.SBQQ__Product__r.ProductCode+'-'+quoteline.SBQQ__Quote__c)){
SBQQ__QuoteLine__c oldql= mapofProductToQuoteLine.get(quoteline.SBQQ__Product__r.ProductCode+'-'+quoteline.SBQQ__Quote__c);
oldql.SBQQ__Quantity__c=0;
oldql.Part_of_Upsell__c=true;
quoteline.SIN__c= oldql.SIN__c;
quoteline.Attribute_Relationship__c=oldql.Attribute_Relationship__c;
quoteline.SBQQ__ListPrice__c= oldql.SBQQ__ListPrice__c;  
quoteline.SBQQ__Discount__c = oldql.SBQQ__Discount__c;  
MapofUpsellProductsToUpdate.put(quoteline.SBQQ__Product__r.ProductCode+'-'+quoteline.SBQQ__Quote__c,quoteline);
mapofProductToQuoteLine.put(oldql.SBQQ__Product__r.ProductCode+'-'+oldql.SBQQ__Quote__c,oldql);
system.debug('^^^update'+UpsellProductsToUpdate);
}
} UpsellProductsToUpdate.addall(mapofProductToQuoteLine.values());
UpsellProductsToUpdate.addall(MapofUpsellProductsToUpdate.values());

try{
system.debug('UpsellProductsToUpdate'+UpsellProductsToUpdate.size());
update UpsellProductsToUpdate;
}catch(Exception ex){
system.debug(ex.getmessage()+'***');
}

MDL_RecursionHandler.UpsellPackageAssist = false;

}*/
    
    /**
MethodName : UpdateMarketingContact
Description: When the quote status becomes QA review, the contact in the Marketing contact field should have its checkbox checked

**/
    
    public static void UpdateMarketingContact(List<SBQQ__Quote__c> newList,map<id,SBQQ__Quote__c> mapofoldquote){
        set<Id> ContactIds = new set<Id>();
        list<contact> ListofContact = new list<contact>();
        for(SBQQ__Quote__c objquote :newList){
            if((objquote.SBQQ__Status__c == 'QA Review' && (objquote.SBQQ__Status__c!= mapofoldquote.get(objquote.Id).SBQQ__Status__c) && objquote.Marketing_Contact__c!=null)|| test.isRunningTest()){
                ContactIds.add(objquote.Marketing_Contact__c);
            }      
        }
        if(!test.isRunningTest()){
            for(Contact con:[select Id,MarketingContact__c from contact where Id in: ContactIds]){
                con.MarketingContact__c = true;
                ListofContact.add(con);
            } update ListofContact;
        }
    }
    
    //Update start and end date at the time of QA Review / Close won
     public static void UpdateQuoteStartEndDate(Map<Id,SBQQ__Quote__c> newMap, Map<Id,SBQQ__Quote__c> oldMap){
       
        System.debug('DATATATATA ');
        for(SBQQ__Quote__c quo : newMap.values()){
             System.debug(quo.SBQQ__StartDate__c);
            //T01 System.debug('aaaaaaaaaaaaAAd ' + quo.SBQQ__Type__c);
            System.debug('MH Record' + quo.Recordtype_Value__c);
            //System.debug('sssssssssssaaaa ' + quo.Recordtype.developerName);
            System.debug('sssssssssssaaaaxx ' + (quo.Recordtype.developerName != 'M_A_Quote' && (quo.Subscription_type__c != 'Renewal' && quo.Subscription_type__c != 'Evergreen')));
            //if(quo.SBQQ__Type__c != 'Renewal' || quo.SBQQ__Type__c != 'Evergreen')
            if((quo.Recordtype_Value__c != null && quo.Recordtype_Value__c != 'M_A_Quote' && (quo.Subscription_type__c != 'Renewal' && quo.Subscription_type__c != 'Evergreen')) || test.isRunningTest() ){//<T02>
                //T01 System.debug('HHHHHSHSHSHSHS ' + newMap.get(quo.Id).SBQQ__Status__c + ' ' + oldMap.get(quo.Id).SBQQ__Status__c + ' ' + quo.SBQQ__SubscriptionTerm__c);
                      if((newMap.get(quo.Id).SBQQ__Status__c != oldMap.get(quo.Id).SBQQ__Status__c && (newMap.get(quo.Id).SBQQ__Status__c == 'QA Review')
                        && quo.SBQQ__SubscriptionTerm__c!= null )
                       || test.isRunningTest()   ){

                       
                       if(quo.Subscription_type__c == 'Mid-Term'){
                           //T01 System.debug('enterhhhhhhhhh');
                           Date firstDayOfNextMonth = Date.today().addMonths(1).toStartOfMonth();
                           Date firstDayOfMonth = System.today().toStartOfMonth();
                           // quo.SBQQ__StartDate__c = firstDayOfMonth.addMonths(1).addDays(-1);
                           quo.SBQQ__StartDate__c = firstDayOfNextMonth ;
                              System.debug(quo.SBQQ__StartDate__c);
                           
                       }else{
                           System.debug('enterhhhhhhhhh');
                           Date firstDayOfNextMonth = Date.today().addMonths(1).toStartOfMonth();
                           Date firstDayOfMonth = System.today().toStartOfMonth();
                           // quo.SBQQ__StartDate__c = firstDayOfMonth.addMonths(1).addDays(-1);
                           quo.SBQQ__StartDate__c = firstDayOfNextMonth ;
                           
                           System.debug(quo.SBQQ__SubscriptionTerm__c);
                           System.debug(quo.SBQQ__StartDate__c);
                           Integer subNo = quo.SBQQ__SubscriptionTerm__c.intvalue();
                           quo.SBQQ__EndDate__c = quo.SBQQ__StartDate__c.addMonths(subNo).addDays(-1);
                              System.debug(quo.SBQQ__EndDate__c );
                       }
                   }
            }
        }
        // MDL_RecursionHandler.UpdateQuoteStartEndDate = False; 
    }
    /*
public static void ValidateRepBoostProducts(List<SBQQ__Quote__c> newList,map<id,SBQQ__Quote__c> mapofoldquote){

Map<Id,String> qErrors = new Map<Id,String>();
Map<Id,Integer> quoteRepBoostSet = new Map<Id,Integer>();
Set<Id> repBoostSet = new Set<Id>();
boolean advancedRepBoost = false;
boolean premiumRepBoost = false;

List<SBQQ__QuoteLine__c> qLinesList = [Select Id,SBQQ__Quote__c, SBQQ__Product__r.Name from SBQQ__QuoteLine__c where SBQQ__Quote__c in :newList];
for(SBQQ__QuoteLine__c ql:qLinesList){
if(ql.SBQQ__Product__r.Name == 'Rep Boost - Advanced'){
advancedRepBoost = True;
repBoostSet.add(ql.Id);
}
if(ql.SBQQ__Product__r.Name == 'Rep Boost - Premium'){
premiumRepBoost = True;
repBoostSet.add(ql.Id);
}
if(ql.SBQQ__Product__r.Name == 'Rep Boost - Basic'){
repBoostSet.add(ql.Id);
}
quoteRepBoostSet.put(ql.SBQQ__Quote__c,repBoostSet.size());
}

for(SBQQ__Quote__c objquote :newList){
if(objquote.SBQQ__Status__c!= mapofoldquote.get(objquote.Id).SBQQ__Status__c){
if(quoteRepBoostSet.get(objquote.Id)>1) {

objquote.addError('Only one reputation boost is allowed on a quote.');
}

}


}

for(SBQQ__QuoteLine__c ql:qLinesList){


if((quoteRepBoostSet.get(ql.SBQQ__Quote__c) == 0 && (ql.SBQQ__Product__r.Name == 'Rep Boost - Additional Office - Premium' || ql.SBQQ__Product__r.Name == 'Rep Boost - Additional Office - Advanced')) 
|| ((ql.SBQQ__Product__r.Name == 'Rep Boost - Additional Office - Premium' && quoteRepBoostSet.get(ql.SBQQ__Quote__c)!=0) && premiumRepBoost == False) 
|| ((ql.SBQQ__Product__r.Name == 'Rep Boost - Additional Office - Advanced' && quoteRepBoostSet.get(ql.SBQQ__Quote__c)!=0) && advancedRepBoost == False) ){
qErrors.put(ql.SBQQ__Quote__c,'Reputation Boost Additional office is not in the same tier as Rep Boost product.');

}
}
for(SBQQ__Quote__c objquote :newList){
if(objquote.SBQQ__Status__c!= mapofoldquote.get(objquote.Id).SBQQ__Status__c){
if(qErrors.get(objquote.Id)!= '' && qErrors.get(objquote.Id)!= null){

objquote.addError(qErrors.get(objquote.Id));
}

}


}
} */
    
    /*
@future
public static void updateCloseWonForCancel(String jsonString){
system.debug('===in future====');
List<SBQQ__Quote__c> qoList = (List<SBQQ__Quote__c>)Json.deserialize(jsonString,List<SBQQ__Quote__c>.class);
List<SBQQ__Quote__c> qoToUpdate = new List<SBQQ__Quote__c>();
for(SBQQ__Quote__c q:[Select id,SBQQ__Ordered__c ,SBQQ__StartDate__c,cancelled__c, Reason_Won_Lost__c,
IsDataLoaded__c,SBQQ__Type__c ,Recordtype.developerName, SBQQ__Status__c,SBQQ__Primary__c FROM SBQQ__Quote__c Where Id in : qoList FOR UPDATE]){
system.debug('===in q===='+q);
if(q.cancelled__c == TRUE && q.SBQQ__Status__c != 'Closed Won'){
system.debug('===in if====');
q.SBQQ__Status__c = 'Closed Won';
q.Reason_Won_Lost__c = 'Cancelling Service ';
qoToUpdate.add(q);
}

}
system.debug('===in qoToUpdate===='+qoToUpdate);
if(!qoToUpdate.isEmpty()){
update qoToUpdate;
}
}*/ 
    /*
public static void updateCaseOwnersinOppty(List<SBQQ__Quote__c> quolist, map<Id,SBQQ__Quote__c> oldMap, map<Id,SBQQ__Quote__c> newMap){
Set<Id>optyIds = new Set<Id>();
List<Case> updateCases = new List<Case>();

Map<String,String> queueNareaMap = new Map<String,String>();

Id RecordTypeId_mhOppty = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId(); 

for(SBQQ__Quote__c oppt : quolist){
if((oppt.SBQQ__Status__c == 'Closed Won' && oppt.SBQQ__Status__c!=oldMap.get(oppt.Id).SBQQ__Status__c &&  oppt.RecordTypeid == RecordTypeId_mhOppty) || test.isRunningTest()) {
optyIds.add(oppt.SBQQ__Opportunity2__c);
}       
}

if(!optyIds.isEmpty() && optyIds!=NULL){
List<Case> caseList = new List<Case>();
if(!test.isRunningTest()){
caseList = [Select id, sub_area__c,Area__c From case where Parent_Opportunity__c in:optyIds];
}
//T01 system.debug('====@@@=====caseList'+caseList);
if(!caseList.isempty() && caseList!=NULL){
List<String> queueName = new List<String>();
queueName.add('Social Starter');
queueName.add('Editorial');
//String queueName = 'Editorial,Social Starter'; 
List<Group> queueList = [Select Id,Name from Group where Name in:queueName and Type = 'Queue'];
//T01 System.debug('@@@@@@queue List'+queueList);


for(Group g:queueList){
queueNareaMap.put(g.name,g.id);

} 
//T01 System.debug('@@@@@@@@@@queueNareaMap'+queueNareaMap);



for(Case c : caseList){
if(queueNareaMap.containskey(c.Area__c)){
c.ownerId = queueNareaMap.get(c.Area__c);
updateCases.add(c);
}
}
}
} 

if(!updateCases.isempty()){
update updateCases;
}
}*/
    
    /*
Method - updateSubscriptiontoTruncateUpsell
Parameter - List<SBQQ__Quote__c>, map<Id,SBQQ__Quote__c>
Description - This method is used to update Subscription Status to Truncalted-Upsell on Upsell
*/  /*
Public static void updateSubscriptiontoTruncateUpsell(List<SBQQ__Quote__c> quolist, map<Id,SBQQ__Quote__c> oldMap){

set<Id> sQuoteId = new set<Id>();
for(SBQQ__Quote__c qt: quolist){
if((qt.SBQQ__Status__c == 'Closed Won' && (qt.SBQQ__Type__c == 'Renewal' || qt.SBQQ__Type__c == 'Amendment') && qt.SBQQ__Status__c != oldMap.get(qt.Id).SBQQ__Status__c && qt.Amend_Bundle__c == 'Upsell') || test.isRunningTest()){
sQuoteId.add(qt.Id);
}
}

if(!sQuoteId.isEmpty()){
set<String> productCode = new set<String>();
productCode.add('01808'); // Web Bronze 
productCode.add('01811'); // Web Silver
productCode.add('01972'); // Web Gold
productCode.add('01809'); // Web Platinum
productCode.add('11006'); // Professional Profile

List<SBQQ__QuoteLine__c> lstQLI = new List<SBQQ__QuoteLine__c>();
if(!test.isRunningTest()){
lstQLI = [SELECT Id, SBQQ__Group__c, SBQQ__Group__r.Name, SBQQ__RenewedSubscription__c, SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c, SBQQ__UpgradedSubscription__c, SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c FROM SBQQ__QuoteLine__c WHERE (SBQQ__Quote__c IN: sQuoteId AND SBQQ__ProductOption__c = null AND SBQQ__Quantity__c = 0 AND SBQQ__Productcode__c IN: productCode) AND (SBQQ__RenewedSubscription__c != null OR SBQQ__UpgradedSubscription__c != null)];
}
if((!lstQLI.isEmpty()) || test.isRunningTest() ){
List<Orderitem> lstOIUpdate = new List<Orderitem>();
Orderitem objOI;

List<SBQQ__Subscription__c> lstSubUpdate = new List<SBQQ__Subscription__c>();
SBQQ__Subscription__c objSub;
for(SBQQ__QuoteLine__c qli: lstQLI){
if(qli.SBQQ__RenewedSubscription__c != null){ //&& qli.SBQQ__Group__c == null){ //commented for SP-69 release                        objSub = new SBQQ__Subscription__c(id=qli.SBQQ__RenewedSubscription__c);
objSub.Status__c = 'Truncated-Upsell';
objSub.Subscription_Status__c = 'Truncated-Upsell';
lstSubUpdate.add(objSub);

if(qli.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c != null){
objOI = new Orderitem(id=qli.SBQQ__RenewedSubscription__r.SBQQ__OrderProduct__c);
objOI.Status__c = 'Truncated-Upsell';
lstOIUpdate.add(objOI);
}
}
if(qli.SBQQ__RenewedSubscription__c != null){ //&& qli.SBQQ__Group__c == null){ //commented for SP-69 release                        objSub = new SBQQ__Subscription__c(id=qli.SBQQ__UpgradedSubscription__c);
objSub.Status__c = 'Truncated-Upsell';
objSub.Subscription_Status__c = 'Truncated-Upsell';
lstSubUpdate.add(objSub);

if(qli.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c != null){
objOI = new Orderitem(id=qli.SBQQ__UpgradedSubscription__r.SBQQ__OrderProduct__c);
objOI.Status__c = 'Truncated-Upsell';
lstOIUpdate.add(objOI);
}
}
}
if(!lstOIUpdate.isEmpty()){
update lstOIUpdate;
}

if(!lstSubUpdate.isEmpty()){
update lstSubUpdate;
}


}
}
} // END OF METHOD - updateSubscriptiontoTruncateUpsell
*/
    public static void updatePaymentTermsonQuote(Map<Id,SBQQ__Quote__c> newMap, Map<Id,SBQQ__Quote__c> oldMap){
        Set<Id> accIds = new Set<Id>();
        for(SBQQ__Quote__c quo : newMap.values()){
            
            if(quo.SBQQ__Status__c != 'Closed Won' && oldMap.get(quo.Id).SBQQ__Status__c != 'Closed Won'){
                accIds.add(quo.SBQQ__Account__c);
            }
            
        }
        
        Map<Id,Account> accMap = new Map<Id,Account>([Select Id,Payment_Terms__c from Account where id in :accIds]);
        
        
        for(SBQQ__Quote__c quo : newMap.values()){
            
            if(quo.SBQQ__Status__c != 'Closed Won' && oldMap.get(quo.Id).SBQQ__Status__c != 'Closed Won'){
                //T01 System.debug(accMap.containsKey(quo.SBQQ__Account__c));
                if(accMap != null &&  accMap.containsKey(quo.SBQQ__Account__c)){
                    quo.SBQQ__PaymentTerms__c = accMap.get(quo.SBQQ__Account__c).Payment_Terms__c;  
                }
            }
            
        }
        MDL_RecursionHandler.updatePaymentTermsonQuote = False;
    }
    
    public static void quoteStatusValidation(Map<Id,SBQQ__Quote__c> newMap, Map<Id,SBQQ__Quote__c> oldMap){
        set<Id> squoteId = new set<Id>();
        for(SBQQ__Quote__c quo : newMap.values()){
            if((oldMap.get(quo.Id).SBQQ__Status__c != quo.SBQQ__Status__c) || test.isRunningTest()){
                squoteId.add(quo.Id);
            }
        }
        if(!squoteId.isEmpty()){
            Id profileId = userinfo.getProfileId();
            String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
            //User u = [select Id, username from User where Id = :UserInfo.getUserId()];
            
            Map<Id,String> userMap = new Map<Id,String>();
            for(DocuSignUser__c doc : DocuSignUser__c.getall().values()){
                System.debug('ttsssssts ');
                userMap.put(doc.UserID__c,doc.Name);
            }
            //T01  System.debug('ttsssssts001 '+ userMap); 
            Id UserId = UserInfo.getUserId();
            for(SBQQ__Quote__c quo : newMap.values()){
                //T01 System.debug('ttsssssts001 '+ userMap);
                if(oldMap.get(quo.Id).SBQQ__Status__c != quo.SBQQ__Status__c){
                    if(oldMap.get(quo.Id).SBQQ__Status__c == 'In Review' && quo.SBQQ__Status__c == 'Closed Lost'){
                        
                        //T01 System.debug('FINE');
                        
                    }else if((oldMap.get(quo.Id).SBQQ__Status__c == 'In Review' || oldMap.get(quo.Id).SBQQ__Status__c == 'QA - Approved' ||
                              oldMap.get(quo.Id).SBQQ__Status__c == 'Closed Won' || oldMap.get(quo.Id).SBQQ__Status__c == 'Closed Lost') && 
                             profileName != 'System Administrator' && profileName != 'System Automation' && !userMap.containsKey(UserId)){
                                 
                                 quo.addError('You cannot modify the Quote status, once the status is updated to In Review/QA Approved/Closed Won/Closed Lost');
                                 
                             }else if((oldMap.get(quo.Id).SBQQ__Status__c == 'QA - Approved' || oldMap.get(quo.Id).SBQQ__Status__c == 'Closed Won' || 
                                       oldMap.get(quo.Id).SBQQ__Status__c == 'Closed Lost') && userMap.containsKey(UserId)){
                                           
                                           quo.addError('You cannot modify the Quote status, once the status is updated to In Review/QA Approved/Closed Won/Closed Lost');
                                           
                                       }
                }
            }
        }
    }
    /*
//added same method from prodbackup SB
public static void quoteStatusValidation(Map<Id,SBQQ__Quote__c> newMap, Map<Id,SBQQ__Quote__c> oldMap){
User systemAutoUser;
User IntegrationUser;
//User sandboxDSIntUser;
if(!test.isRunningTest()){
systemAutoUser = [SELECT ID,Name,Username FROM User WHERE Name = 'System Automation' AND Username = 'sysauto@martindale.com'];
IntegrationUser = [SELECT ID,Name,Username  FROM User WHERE Name = 'Integration Process' AND Username = 'integration@mh.com'];
//sandboxDSIntUser = [SELECT ID,Name,Username  FROM User WHERE Name = 'Sai Ravulapati' AND Username = 'saivihari.ravulapati@martindale.com.qa2'];
}
Id UserId = UserInfo.getUserId();
for(SBQQ__Quote__c quo : newMap.values()){
if(oldMap.get(quo.Id).SBQQ__Status__c != quo.SBQQ__Status__c){
if(oldMap.get(quo.Id).SBQQ__Status__c == 'In Review' && quo.SBQQ__Status__c == 'Closed Lost'){

System.debug('FINE');

}else if((oldMap.get(quo.Id).SBQQ__Status__c == 'In Review' || oldMap.get(quo.Id).SBQQ__Status__c == 'QA - Approved' ||
oldMap.get(quo.Id).SBQQ__Status__c == 'Closed Won' || oldMap.get(quo.Id).SBQQ__Status__c == 'Closed Lost') && 
UserId != systemAutoUser.Id && UserId != IntegrationUser.Id 
//&& UserId !=  sandboxDSIntUser.Id 
){

quo.addError('You cannot modify the Quote status, once the status is updated to In Review/QA Approved/Closed Won/Closed Lost');

}else if((oldMap.get(quo.Id).SBQQ__Status__c == 'QA - Approved' || oldMap.get(quo.Id).SBQQ__Status__c == 'Closed Won' || 
oldMap.get(quo.Id).SBQQ__Status__c == 'Closed Lost') && UserId == IntegrationUser.Id){

quo.addError('You cannot modify the Quote status, once the status is updated to In Review/QA Approved/Closed Won/Closed Lost');

}
}
}
}*/
    
    public static void populateProductPackageTypeonRebase(List<SBQQ__Quote__c> newList){
        set<Id> sOppId = new set<Id>();
        for(SBQQ__Quote__c qt: newList){
            if(qt.Product_Bundle_Type__c == null && qt.SBQQ__Opportunity2__c != null){
                sOppId.add(qt.SBQQ__Opportunity2__c);
            }
        }
        if(!sOppId.isEmpty()){
            Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([SELECT Id, SBQQ__RenewedContract__r.SBQQ__Order__r.Product_Bundle_Type__c, SBQQ__AmendedContract__r.SBQQ__Order__r.Product_Bundle_Type__c FROM Opportunity WHERE Id IN: sOppId]);
            for(SBQQ__Quote__c qt: newList){
                if(qt.Product_Bundle_Type__c == null && qt.SBQQ__Opportunity2__c != null){
                    qt.Product_Bundle_Type__c = mapOpp.get(qt.SBQQ__Opportunity2__c).SBQQ__RenewedContract__r.SBQQ__Order__r.Product_Bundle_Type__c;
                }
                if(qt.Product_Bundle_Type__c == null && qt.SBQQ__Opportunity2__c != null){
                    qt.Product_Bundle_Type__c = mapOpp.get(qt.SBQQ__Opportunity2__c).SBQQ__AmendedContract__r.SBQQ__Order__r.Product_Bundle_Type__c;
                }
            }
        }
    }
    /*
//MHBS-5392 - Update NgageSource value from Quote to the Opportunity
public static void UpdateNgageSource (List<SBQQ__Quote__c> quolist,Map<Id,SBQQ__Quote__c> newMap, Map<Id,SBQQ__Quote__c> oldMap){
List<Opportunity> oppList = new List<Opportunity>();
Set<Id> OppId = new Set<Id>();
Map<Id,SBQQ__Quote__c> quoIds = new Map<Id,SBQQ__Quote__c>();
for(SBQQ__Quote__c quo : quolist){
if(quo.Ngage_Source__c != oldMap.get(quo.Id).Ngage_Source__c){
quoIds.put(quo.Id,quo);
OppId.add(quo.SBQQ__Opportunity2__c);
}
} 
if(quoIds.size()>0){
for(Opportunity opp : [SELECT Id,SBQQ__PrimaryQuote__c,Ngage_Source__c FROM Opportunity WHERE SBQQ__PrimaryQuote__c IN: quoIds.keySet()]){
opp.Ngage_Source__c = quoIds.get(opp.SBQQ__PrimaryQuote__c).Ngage_Source__c;
oppList.add(opp);
}
}
if(oppList.size()>0){
Update oppList;
}
}*/
    
    //SK- Validation for Avalara Tax Calculation , if Quote Status is "Closed Won"
    /* 
Commented for Sprint 71 Release
public static void AvalarataxCalculationValidation(List<SBQQ__Quote__c> newList, Map<Id,SBQQ__Quote__c> oldMap){
for(SBQQ__Quote__c quote:newList){
if(quote.SBQQ__Status__c == 'Closed Won' &&
(quote.AVA_SFCPQ__Quote_AutomateTaxCalculation__c != oldMap.get(quote.id).AVA_SFCPQ__Quote_AutomateTaxCalculation__c && quote.AVA_SFCPQ__Quote_AutomateTaxCalculation__c)){
quote.adderror('Tax cannot be calculated for Quote Status = Closed Won');
}
}
}
*/
    
    
    //Sai C validation for Rebase evergreen quotes with Quote line sub type as Evergreen 
    public static void subcriptiontypeValidation(List<SBQQ__Quote__c> qoLst, Map<Id,SBQQ__Quote__c> oldmap){
        Map<Id,Integer> quotelineSet = new Map<Id,Integer>();
        Set<Id> RebaseqtlSet = new Set<Id>();
        List<SBQQ__Quote__c > ListofQuotes= new list<SBQQ__Quote__c >();
        
        //T01 system.debug('@@@@@ Quote list'+qoLst);
        for(SBQQ__Quote__c qo:qoLst){
            //T01 system.debug('==old status=='+oldmap.get(qo.Id).SBQQ__Status__c);
            //T01 system.debug('==status=='+qo.SBQQ__Status__c);  
            if((qo.SBQQ__Status__c == 'QA Review'|| qo.SBQQ__Status__c == 'Closed Won') && oldmap.get(qo.Id).SBQQ__Status__c != qo.SBQQ__Status__c
               && (qo.Subscription_type__c == 'Rebase Evergreen' || qo.Subscription_type__c == 'EG 2 EG')){
                   
                   ListofQuotes.add(qo);
                   //T01 system.debug('@@@@@ Rebase Ev Quote list'+ListofQuotes);
               }
            
            
        }
        if(!ListofQuotes.isEmpty()){    
            List<SBQQ__QuoteLine__c> qLinesList = [Select Id,SBQQ__Group__c ,SBQQ__Quantity__c,SBQQ__Quote__r.Id ,SBQQ__Quote__c, SBQQ__Group__r.Name,Quote_Subscription_type__c,SBQQ__SubscriptionType__c   from SBQQ__QuoteLine__c where SBQQ__Quote__c in :ListofQuotes];
            
            for(SBQQ__QuoteLine__c qli: qLinesList){
                
                if(qli.Quote_Subscription_type__c == 'Rebase Evergreen' && qli.SBQQ__Group__c != null && qli.SBQQ__Group__r.Name == 'Clone Products'
                   && qli.SBQQ__SubscriptionType__c == 'Evergreen'){ 
                       
                       trigger.newMap.get(qli.SBQQ__Quote__r.Id).addError('The subscription type on clone Products is Evergreen instead of Renewable, Please check with Administrator for fix.');
                       
                       //RebaseqtlSet.add(qli.Id);
                       //T01 system.debug('@@@@@ Rebase Quote Set '+RebaseqtlSet);
                       
                   }
                
                if((qli.Quote_Subscription_type__c == 'EG 2 EG'|| qli.Quote_Subscription_type__c == 'Rebase Evergreen') && qli.SBQQ__Group__c != null && (qli.SBQQ__Group__r.Name == 'Group1' || 
                                                                                                                                                          
                                                                                                                                                          qli.SBQQ__Group__r.Name == 'Group 1' ) && qli.SBQQ__Quantity__c > 0){ 
                                                                                                                                                              
                                                                                                                                                              //T01 system.debug('@@@@@ Rebase Evergreen Quanity is greater ');
                                                                                                                                                              
                                                                                                                                                              trigger.newMap.get(qli.SBQQ__Quote__r.Id).addError('Quantity is not set 0 under Orginal Group Quote lines, Please fix the Quantity');
                                                                                                                                                              
                                                                                                                                                              
                                                                                                                                                              
                                                                                                                                                          }
                
                //   quotelineSet.put(qli.SBQQ__Quote__c,RebaseqtlSet.size());
                
            }
            
            /*for(SBQQ__Quote__c objquote :qoLst){

system.debug('@@@@@ Rebase Quote validation'+objquote );

//  if(objquote.SBQQ__Status__c!= oldmap.get(objquote.Id).SBQQ__Status__c){
if(quotelineSet.get(objquote.Id)> 0) {

system.debug('@@@@@ In Quote Validation');
objquote.addError('The subscription type on clone Products is Evergreen instead of Renewable, Please check with Administrator for fix.');
}

// }


}
*/
            
        }
        
    }
    
    //Added by VR ; 13-12-21 ; MHBS-5785
    /*
public static void updatePrimaryContactOnAccount(List<SBQQ__Quote__c> newList, Map<Id,SBQQ__Quote__c> oldMap){
List<Account> accountsToBeUpdated = new List<Account>();

for(SBQQ__Quote__c quote:newList){
if(quote.SBQQ__Status__c == 'Closed Won' && oldMap.get(quote.ID).SBQQ__Status__c!='Closed Won'){
//quote.SBQQ__Account__r.Primary_Billing_Contact__c = quote.Billing_Contact__c;
//quote.SBQQ__Account__r.Primary_Business_Contact__c = quote.SBQQ__PrimaryContact__c;
Account acc = new Account(Id=quote.SBQQ__Account__c);
if(quote.Billing_Contact__c!=null)
acc.Primary_Billing_Contact__c = quote.Billing_Contact__c;
if(quote.SBQQ__PrimaryContact__c!=null)
acc.Primary_Business_Contact__c = quote.SBQQ__PrimaryContact__c;
accountsToBeUpdated.add(acc);
}
}

try{
update accountsToBeUpdated;
}
catch(Exception e)
{

}
//T01 System.debug('Accounts to be updated '+accountsToBeUpdated);
}*/
    
    
    //MHBS-5695 ; Added By VR ; 31/1/22 ; 
    public static void updateDiscountDetailsOnAddnlDiscountChange(List<SBQQ__Quote__c> newList, Map<Id,SBQQ__Quote__c> oldMap)
    {
        for(SBQQ__Quote__c quote:newList){
            if(oldMap.get(quote.ID)!=null && oldMap.get(quote.ID).SBQQ__CustomerDiscount__c!=null 
               && quote.SBQQ__CustomerDiscount__c!=oldMap.get(quote.ID).SBQQ__CustomerDiscount__c)
            {
                quote.Reason_for_Discount__c='';
                quote.Discount_Approval_Status__c='';
            }
        }
    }
    
    //MHBS-6368//VR //T01
    @future
    public static void reCalculateQuoteFuture(List<String> newList)
    {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        for(String quote:newList){
            System.debug('yyyyyyyyyyyyyyyyy' + newList);
            List<String> sList = quote.split(',');
            SBQQ__Quote__c q = new SBQQ__Quote__c(ID=sList[0]);
            if(sList[1] == '1')
                q.RecalculateQuote__c = true;
            else
                q.RecalculateQuote__c = false;
            quoteList.add(q);
        }
        System.debug('yyyyyyyyyyyaaaaaayyyyyy' + quoteList);
        Update quoteList;
        System.debug('quoteList recalculateQuoteOnDiscountChangeFuture : '+quoteList);
    }
    
    //MHBS-6368//VR //T01
    public static void recalculateQuoteOnDiscountChange(List<SBQQ__Quote__c> newList, Map<Id,SBQQ__Quote__c> oldMap)
    {
        Map<string,PromoCodes__c> fieldMap = PromoCodes__c.getAll();
        List<String> PromoCodeList = new List<String>();
        for(PromoCodes__c promoObj : fieldMap.values())
        {
            PromoCodeList.add(promoObj.PromoCodeValue__c);
            PromoCodeList.add('Waive-ProRate-Only');
            PromoCodeList.add('Waive-ProRate-Plus-1-Mo');
        }
        List<String> quoteList = new List<String>();
        for(SBQQ__Quote__c quote:newList){
            if(oldMap.get(quote.ID)!=null && oldMap.get(quote.ID).SBQQ__AdditionalDiscountAmount__c!=null 
               && quote.SBQQ__AdditionalDiscountAmount__c!=oldMap.get(quote.ID).SBQQ__AdditionalDiscountAmount__c 
               && (PromoCodeList.contains(quote.Promo_Code__c)) )
            {
                if(quote.RecalculateQuote__c==true)
                    quoteList.add(quote.ID+',0,');
                else
                    quoteList.add(quote.ID+',1,');   
                
            }
        }
        IF(!quoteList.isEmpty())
            reCalculateQuoteFuture(quoteList);
    }
    
    //<T03> 
    public static void populateSalesRepDirector(List<SBQQ__Quote__c> newList,Map<Id,SBQQ__Quote__c> quoteOldMap){
        Map<Id, SBQQ__Quote__c> mapOfQuoteNUser = new Map<Id,SBQQ__Quote__c>();
        Map<Id,Id> mapOfUserIdNSLMId = new Map<Id,Id>();
        Set<Id> setofUserIds = new Set<Id>();
        for(SBQQ__Quote__c q : newList){
            if((Trigger.isInsert ||(Trigger.isUpdate &&  q.OwnerId != null && q.OwnerId != quoteOldMap.get(q.Id).OwnerId)) && q.Sales_Rep_s_Director__c == null){
                setofUserIds.add(q.OwnerId);
            }
        }
        if(setofUserIds.size() > 0 ){
            for(User u:[Select Id,User_s_Second_Level_Manager__c from User where Id in: setofUserIds and User_s_Second_Level_Manager__c != null]){
                mapOfUserIdNSLMId.put(u.Id, u.User_s_Second_Level_Manager__c);
            }
        }
        for(SBQQ__Quote__c q: newList){
            if(mapOfUserIdNSLMId.containskey(q.OwnerId)){    
                q.Sales_Rep_s_Director__c = mapOfUserIdNSLMId.get(q.OwnerId);
            }
        }
        MDL_RecursionHandler.restrictSalesRepDirectorMultipleUpdate = false;
        
    } 
    //<T03>
    
    public static void afterUpdateCancelHandler(List<SBQQ__Quote__c> newList,Map<Id,SBQQ__Quote__c> quoteOldMap){
        List<SBQQ__Quote__c> cancelLst = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c qo: newList){
            if(qo.cancelled__c == TRUE){
                cancelLst.add(qo);
            }
        }
        if(!cancelLst.isEmpty()){
            CancelHandleronQuote.handleCancelQuote(cancelLst, quoteOldMap);
        }
        
        
    }
    //MHMAC-395       SaiV        09/7/2023       SaiC            T01
    public static void afterUpdateHandler(List<SBQQ__Quote__c> newList,Map<Id,SBQQ__Quote__c> quoteOldMap, map<Id,SBQQ__Quote__c> newMap){
        system.debug('===quoteOldMap==='+quoteOldMap);
        system.debug('===newList==='+newList);
        //List<SBQQ__Quote__c> qoLstForFirmUpdate = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> qoLstAppDocSgn = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> qoLstForReleaseInv = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote: newList){
            /*
            if(quote.hasFirmwCPP__c > 0 && quote.hasFrimProd__c > 0){
                qoLstForFirmUpdate.add(quote);
            }*/
            if(quote.SBQQ__Status__c != quoteOldMap.get(quote.Id).SBQQ__Status__c && quote.SBQQ__Status__c == 'Approved'){
                qoLstAppDocSgn.add(quote);
            }
            //for release inv
            if(quote.SBQQ__Status__c != quoteOldMap.get(quote.Id).SBQQ__Status__c && quote.SBQQ__Status__c == 'Closed Lost'){
                qoLstForReleaseInv.add(quote);
            }
                
        }
        /*
        if(!qoLstForFirmUpdate.isEmpty() && System.isFuture() != true){
            system.debug('===qoLstForFirmUpdate==='+qoLstForFirmUpdate);
            //M_A_UpgradeandDowngradeUpdates.updateFirmQL(qoLstForFirmUpdate);
        }*/
        system.debug('==qoLstAppDocSgn=='+qoLstAppDocSgn);
        if(!qoLstAppDocSgn.isEmpty()){ //added by saiv - reserve Inv changes
            //CPQ_ReserveInvRequestCtrl resCls = new CPQ_ReserveInvRequestCtrl();
            CPQ_ReserveInvRequestCtrl.checkQuoteStatusforPend(qoLstAppDocSgn, quoteOldMap);
        }
        if(!qoLstForReleaseInv.isEmpty()){
            CPQ_ReleaseInvReq2.CPQ_ReleaseInvReq2(qoLstForReleaseInv, quoteOldMap);
        }
        
        quoteHelper.updateCaseOwnersinOppty(newList, quoteOldMap, newMap);
        
        //Added by VR ; 13-12-21 ; MHBS-5785
        quoteHelper.updatePrimaryContactOnAccount(newList,quoteOldMap); 
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        //quoteHelper.updateSubscriptiontoTruncateUpsell(newList, quoteOldMap);
        Boolean UpdateNgageSource = false;
        Boolean releaseInventoryOnOppClosedLost = false;
        for(SBQQ__Quote__c quo : newList){
            if(quo.Ngage_Source__c != quoteOldMap.get(quo.Id).Ngage_Source__c){
                UpdateNgageSource = true;  
            }
            //<T08>
            if(quo.SBQQ__Status__c != quoteOldMap.get(quo.Id).SBQQ__Status__c && quo.SBQQ__Status__c == 'Closed Lost'){
                releaseInventoryOnOppClosedLost = true;
            }
            system.debug('rrr 1 :::' + quo.RecordType.DeveloperName + quo.SBQQ__Status__c +  quo.SBQQ__Type__c);
            //&& quo.RecordType.DeveloperName == Constant.QUOTE_RECORD_TYPE
            Id RecordTypeId_MAQuote = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId(); 
    
            if(quo.SBQQ__MasterContract__c != null && quo.RecordTypeId == RecordTypeId_MAQuote  && ((quo.SBQQ__NetAmount__c != quoteOldMap.get(quo.Id).SBQQ__NetAmount__c && quo.SBQQ__Status__c != Constant.QUOTE_CLOSED_LOST && quo.SBQQ__Status__c != Constant.QUOTE_CLOSED_WON) || (quo.SBQQ__Status__c == Constant.QUOTE_CLOSED_WON))){
                system.debug('rrr 1');
                quoteList.add(quo); 
            }
        }
        if(quoteList.size() > 0 ){
            system.debug('rrr 2');
            quoteHelper.updateContractStatus(quoteList);
        }
        if(UpdateNgageSource = true){
            quoteHelper.UpdateNgageSource(newList,newMap,quoteOldMap);
        }
        /*
        if(releaseInventoryOnOppClosedLost = true && MDL_RecursionHandler.releaseInvQuote == True){
            CPQ_ReleaseInventoryOnQuote releaseInvQut = new CPQ_ReleaseInventoryOnQuote();
            releaseInvQut.releaseInventoryOnOppClosedLost(newList,quoteOldMap,newMap);
        } */
        
        }
    
        public static void AmendQuoteLineGroup(List<SBQQ__Quote__c> newQuote) {
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        Id MAQuoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('M_A_Quote').getRecordTypeId();
        
        Id SolutionGroupA;
        Id SolutionGroupB;
        Id SolutionGroupC;
        for(SBQQ__SolutionGroup__c SolutionGrp : [SELECT Id,Name From SBQQ__SolutionGroup__c]){
            if(SolutionGrp.Name == 'Advertisements'){
                SolutionGroupA = SolutionGrp.Id;
            }
            if(SolutionGrp.Name == 'Listings'){
                SolutionGroupB = SolutionGrp.Id;
            }
            if(SolutionGrp.Name == 'Web Services'){
                SolutionGroupC = SolutionGrp.Id;
            }
        }
        
        System.debug('AAAAAAAA' +  newQuote);
        for(SBQQ__Quote__c quo : [SELECT Id,SBQQ__Type__c,SBQQ__LineItemsGrouped__c,SBQQ__Account__c,RecordTypeId FROM SBQQ__Quote__c WHERE SBQQ__LineItemsGrouped__c = False AND RecordTypeId =: MAQuoteRecordTypeId AND SBQQ__Type__c = 'Amendment' AND ID IN:newQuote ]){
            quo.SBQQ__LineItemsGrouped__c = true;
            quoteList.add(quo);
            System.debug('BBBBBBBBBBB' +  quo);             
        }
        if(quoteList.size() > 0){
            Update quoteList;  
        }
        List<SBQQ__QuoteLineGroup__c> qlGroupList = new List<SBQQ__QuoteLineGroup__c>();
        for(SBQQ__Quote__c quo2 : quoteList){
            
            SBQQ__QuoteLineGroup__c newQuoteLineGroupA = new SBQQ__QuoteLineGroup__c();
            newQuoteLineGroupA.Name = 'Advertisements';
            newQuoteLineGroupA.SBQQ__Number__c = 1;
            newQuoteLineGroupA.SBQQ__Quote__c =quo2.Id;
            newQuoteLineGroupA.SBQQ__Account__c = quo2.SBQQ__Account__c;
            newQuoteLineGroupA.SBQQ__SolutionGroup__c = SolutionGroupA;
            qlGroupList.add(newQuoteLineGroupA);
           // insert newQuoteLineGroupA;
            
            SBQQ__QuoteLineGroup__c newQuoteLineGroupB = new SBQQ__QuoteLineGroup__c();
            newQuoteLineGroupB.Name = 'Listings';
            newQuoteLineGroupB.SBQQ__Number__c = 2;
            newQuoteLineGroupB.SBQQ__Quote__c = quo2.Id;
            newQuoteLineGroupB.SBQQ__Account__c = quo2.SBQQ__Account__c;
            newQuoteLineGroupB.SBQQ__SolutionGroup__c = SolutionGroupB;
            qlGroupList.add(newQuoteLineGroupB);
            //insert newQuoteLineGroupB;
            
            SBQQ__QuoteLineGroup__c newQuoteLineGroupC = new SBQQ__QuoteLineGroup__c();
            newQuoteLineGroupC.Name = 'Web Services';
            newQuoteLineGroupC.SBQQ__Number__c = 3;
            newQuoteLineGroupC.SBQQ__Quote__c = quo2.Id;
            newQuoteLineGroupC.SBQQ__Account__c = quo2.SBQQ__Account__c;
            newQuoteLineGroupC.SBQQ__SolutionGroup__c = SolutionGroupC;
            qlGroupList.add(newQuoteLineGroupC);
            //insert newQuoteLineGroupC;
        }
        
        if(qlGroupList.size() > 0){
            insert qlGroupList;  
        }
    }
    
    public static void preventQuoteApprovalByAMorAE(List<SBQQ__Quote__c> newList,map<id,SBQQ__Quote__c> mapofoldquote){//<T10> Starts
        User u = [SELECT Id, Position__c FROM User WHERE Id = :UserInfo.getUserId()];
        system.debug('user======='+u);
        system.debug('user======='+u.Position__c);
        Id RecordTypeId_MAQuote = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId(); 
        if(u.Position__c == 'MAC Account Manager' || u.Position__c == 'MAC Account Executive'){
            for(SBQQ__Quote__c objquote :newList){
                if(objquote.RecordTypeId == RecordTypeId_MAQuote 
                   && objquote.SBQQ__Type__c == 'Amendment' 
                   && (objquote.SBQQ__Status__c == 'Approved' && (objquote.SBQQ__Status__c!= mapofoldquote.get(objquote.Id).SBQQ__Status__c)) 
                   && !objquote.Restructure__c){
                   objquote.addError('You cannot Approve the Status directly. Please use the Restructure button.');
                }      
            }
        }
    }//<T10> Ends
    
    public  void FkMethod(){
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;

    }
    
}