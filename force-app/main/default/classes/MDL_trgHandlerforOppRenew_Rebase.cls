/*Trigger handler for TriggerOnOpportunity
* Created on - 29/09/2014
* Purpose - Renew/Rebase field is populated to an order only after the opportunity created is 'Closed Won'
*
* Modified on - 16/10/2014
* Purpose - When the Sales Rep changes the Stage of an Opportunity to "Closed/Won", if the Credit Status on the Account = "Past Due" and 
  the Credit Sub Status = "Override" allow the conversion of the Opportunity to an Order and then set the Credit Sub Status to blank. DO NOT change the Credit Status value.          
*  
* Modified on - 11/03/2015
* Purpose - If opportunity is closed lost inventory has to be released. Closed lost the renewal or rebase oppty should not release the inventory. It has SIN. In rebase when a  new Inventory  product added follows new rule (New Inventory prod will not have SIN)
*
* Modified On : June 10,2015
* Modified purpose : Inventory id to be blanked out in the integration class only after receiving a '200-success' response
*/
public with sharing class MDL_trgHandlerforOppRenew_Rebase {
    public static boolean recursionCheckforopty = true;
    public static boolean recursionCheckforoptyafterUpdate = true;
    public static boolean recursionCheckforoptyBeforeUpdate = true;
    public void handleOpp(List<Opportunity> trgnew,Map<Id,Opportunity> mapold,Map<Id,Opportunity> mapnew){
        Set<Id> ordersRenewId = new Set<Id>();
        Set<Id> ordersRebaseId = new Set<Id>();
        Set<Id> orderOrpceId = new Set<Id>();
        List<invoiceit_s__Job__c> orders = new List<invoiceit_s__Job__c>();
    List<invoiceit_s__Job__c> ordorpcList = new list<invoiceit_s__Job__c>();
        List<Opportunity> opplist = new List<Opportunity>();
        list<invoiceit_s__Job_Rate_Plan_Charge__c> orpc = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
       
        for(Opportunity opp : trgnew){
            if((opp.StageName=='Closed Won')&&(mapold.get(opp.Id).StageName!=mapnew.get(opp.Id).StageName)&&(opp.Quote_Type__c=='Renew' || opp.Quote_Type__c=='Modify')){
               opplist.add(opp);
            }
        }            
        for(Opportunity opportunity : opplist){
            if(opportunity.Quote_Type__c=='Renew'){                
                ordersRenewId.add(opportunity.Created_From_Order__c);
            }
            else if(opportunity.Quote_Type__c=='Modify'){               
                ordersRebaseId.add(opportunity.Created_From_Order__c);
            }
        } 
               if(ordersRebaseId.size()>0 || ordersRenewId.size()>0)
//                    orders = [select Id,Name,Renew_Rebase__c from invoiceit_s__Job__c where Id in :ordersRenewId or Id in :ordersRebaseId];
                 orders = [select Id,Name,Renew_Rebase__c,invoiceit_crmx__Opportunity__r.name, Created_From_Order__c, Created_From_Order__r.quote_type__c,  Created_From_Order__r.invoiceit_s__Service_Activation_Date__c, Created_From_Order__r.Renew_Rebase__c, Created_From_Order__r.invoiceit_s__Service_End_Date__c from invoiceit_s__Job__c where Id in :ordersRenewId or Id in :ordersRebaseId];
               list<invoiceit_s__Job__c> ol = new list<invoiceit_s__Job__c>();
               for(invoiceit_s__Job__c ord: orders){
//          ord.invoiceit_s__Recalculate__c = true;
                    if(ordersRenewId.contains(ord.Id)){
                        ord.Renew_Rebase__c='Renew';
                    }                    
                    else if(ordersRebaseId.contains(ord.Id)){
                       ord.Renew_Rebase__c='Rebase';
                    }
//Added by Rama 5/26/16 to update the service end date on a renew order 
                    system.debug('@@@Rama Order: ' + ord);
                    system.debug('Opp Name' + ord.invoiceit_crmx__Opportunity__r.name);
                    system.debug('ord.Created_From_Order__r.Renew_Rebase__c: ' + ord.Created_From_Order__r.Renew_Rebase__c + ' ord.Renew_Rebase__c: ' + ord.Renew_Rebase__c + ' : ' + ord.Created_From_Order__r.invoiceit_s__Service_End_Date__c);
/*                    if(ord.invoiceit_crmx__Opportunity__r.name.contains('MidTerm') && ord.Created_From_Order__r.Renew_Rebase__c == 'Renew' && ord.Renew_Rebase__c=='Rebase' && ord.Created_From_Order__r.invoiceit_s__Service_End_Date__c > date.today())                 if (ord.Created_From_Order__r.quote_type__c == 'Renew' && ord.Created_From_Order__r.Renew_Rebase__c == 'Rebase')

                   {
                        invoiceit_s__Job__c o = new invoiceit_s__Job__c();
                        o.id = ord.Created_From_Order__c;
                        o.invoiceit_s__Service_Activation_Date__c = ord.Created_From_Order__r.invoiceit_s__Service_Activation_Date__c;
                if (ord.Created_From_Order__r.invoiceit_s__Service_End_Date__c > date.today())    
                           o.invoiceit_s__Service_End_Date__c=date.today().addMonths(1).toStartofMonth()-1;

                        orderOrpceId.add(o.id);
                        ol.add(o);

                    }
*/
                   if( ord.Created_From_Order__r.Renew_Rebase__c == 'Renew' && ord.Renew_Rebase__c=='Rebase' && ord.Created_From_Order__r.invoiceit_s__Service_End_Date__c > date.today())
                    {
                      system.debug('Entered if condition: ' + ord);
                        invoiceit_s__Job__c o = new invoiceit_s__Job__c();
                        o.id = ord.Created_From_Order__c;
                        o.invoiceit_s__Service_End_Date__c=date.today().addMonths(1).toStartofMonth()-1;
//            o.invoiceit_s__Recalculate__c = true;
            orderOrpceId.add(o.id);
                        system.debug('Order Renew o.id: ' + o + ' Order Orpc List: ' + orderOrpceId);
                        ol.add(o);
                      system.debug('Entered if condition: ' + ol);
                    }

               }
        //try{
            //   if(orders.size()>0)
           if (ol.size() > 0)
            {
               orders.addAll(ol);
               orpc = [select id, invoiceit_s__Discount_Value__c, invoiceit_s__Tax__c, invoiceit_s__Service_Activation_Date__c, invoiceit_s__Service_End_Date__c, Renewable__c, invoiceit_s__Row_Total__c, Fulfilment_End_Date__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Order__c in :orderOrpceId order by invoiceit_s__Order__c];
               system.debug('orpc: ' + orpc + ' orpc size: ' + orpc.size());
               for (integer i = 0; i<=orpc.size(); i++)
               {
                   system.debug('Entered if condition: ' + orpc);
                   if (i < orpc.size()) {
                      if (orpc[i].Renewable__c == true )
                         orpc[i].invoiceit_s__Service_End_Date__c = date.today().addMonths(1).toStartofMonth()-1;
                       system.debug('Entered if condition: orpc' + orpc);
                   }
               }
           }
            if(orpc.size() > 0)
                update orpc;
        
               system.debug('Orcp Update: ' + orpc + ' Orders: ' + orders);

               update orders;     
           // }
           // catch(Exception ex) {
            //if(ex.getMessage().contains('Email address is missing')){
               // apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email address is missing. Please provide billing contact Email address'));
           // }
            //else{
             // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception has occurred. Please contact your System Administrator quoting the following message -- ' + ex.getMessage() + ', Line Number ' + ex.getLineNumber()));   
            
           // } 
            
            //}              
               
    }
    
    public void voidEnvelopeOnOppClosedLost(List<Opportunity> trgnew,Map<Id,Opportunity> mapold,Map<Id,Opportunity> mapnew){
       
        system.debug('@@@ in releaseInventoryOnOppClosedLost');
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setOppProdIds = new Set<Id>();
        set<id> setorder = new set<id>();
        list<Opportunity> opplist = new list<Opportunity>();
        list<Opportunity> updopplist = new list<Opportunity>();
        Map<Id,String> mapOppProdNInventoryId = new Map<Id,String>();
        List<invoiceit_crmx__Opportunity_Product__c > listOppProdsToUpdate = new List<invoiceit_crmx__Opportunity_Product__c >();
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        for(Opportunity opp : trgnew){
            if(opp.StageName=='Closed Lost' && (mapold.get(opp.Id).StageName != mapnew.get(opp.Id).StageName) && (opp.Quote_Type__c!='Renew')){
                system.debug('@@@ in closed lost condition');
                setOppIds.add(opp.Id);
                opplist.add(opp);
                
            }
        }
        
        for(Opportunity opp : opplist){
            if(opp.IsVoidable__c == False){
                opp.IsVoidable__c = True;
                //updopplist.add(opp);
            }
        }
        
        /*if(updopplist.size()>0){
            update updopplist;
        }*/
        
    }
    
    public void handleOppforAccCreditStatus(List<Opportunity> trgnew,Map<Id,Opportunity> mapold,Map<Id,Opportunity> mapnew){
       
        system.debug('@@@@in handleOppforAccCreditStatus');
        Set<Id> AccIdSet = new Set<Id>();



        List<Account> acclisttoUpdate = new List<Account>();   
        Map<Id,account> idVsAccount   = new Map<Id,Account>();
//Rama 6/15/16 Integrated the three methods handleoppforCreditSubStatus, handlemigratedoppforAccountDunning, handleOppforAccCreditStatus

        for(Opportunity opp : trgnew){
              system.debug('@@@opp.Credit_Approval_Status__c'+ opp.Credit_Approval_Status__c);
            system.debug('@@@opp.StageName'+ opp.StageName);
            system.debug('@@@mapold.get(opp.Id).StageName'+ mapold.get(opp.Id).StageName);
            system.debug('mapnew.get(opp.Id).StageName'+ mapnew.get(opp.Id).StageName);
            if((opp.Credit_Approval_Status__c=='Approved')&&(opp.StageName=='Closed Won')&&(mapold.get(opp.Id).StageName!=mapnew.get(opp.Id).StageName)){
                system.debug('@@@@ in if conditions');
                AccIdSet.add(opp.AccountId);
            }
           if((opp.Credit_Approval_Status__c=='Approved')&&(mapold.get(opp.Id).Credit_Approval_Status__c!=mapnew.get(opp.Id).Credit_Approval_Status__c)&&(opp.StageName!='Closed Won')){
               AccIdSet.add(opp.AccountId);
            }
            if(opp.name.contains('Migration') && opp.StageName=='Closed Won'){
               AccIdSet.add(opp.AccountId);
            }
            if(trigger.isInsert || (trigger.isUpdate && (mapnew.get(opp.id).stageName != mapold.get(opp.id).stageName))){
                system.debug('@@@@ in ids condition');
                 accidSet.add(opp.AccountId);
            }
            system.debug('@@@Account Ids: ' + accidSet);
        }
//Rama 6/15/16 Integrated the three methods handleoppforCreditSubStatus, handlemigratedoppforAccountDunning, handleOppforAccCreditStatus
        if(AccIdSet.size()>0){
            Boolean isAccNeedUpdate;
            for(Account acc : [select id, Credit_Status__c,Credit_Sub_Status__c, Customer_Status__c,
                           (select id, Name 
                               from invoiceit_s__Job__r limit 1),
                            (select id, Name, stageName 
                               from opportunities 
                               where stageName != 'Closed Lost' limit 1)
                            from Account where Id in :AccIdSet])
            { 
                isAccNeedUpdate = false;
                for(Opportunity opp : trgnew){
                    system.debug('@@@acc.id'+acc.id);
                    system.debug('@@@ opp acc.id'+opp.AccountId);
                    system.debug('@@@ mapold.get(opp.Id).Credit_Approval_Status__c'+mapold.get(opp.Id).Credit_Approval_Status__c);
                    system.debug('@@@ mapnew.get(opp.Id).Credit_Approval_Status__c'+mapnew.get(opp.Id).Credit_Approval_Status__c);
                    
                    //modifying if condition to avoid duplicates in the list
                    if(opp.AccountId == acc.id && opp.StageName=='Closed Won' ){
                        system.debug('@@@@in closed won');
                        Boolean valueChange = false;
                        if(opp.Credit_Approval_Status__c=='Approved' && mapold.get(opp.Id).StageName!=mapnew.get(opp.Id).StageName
                           && acc.Credit_Status__c=='Past Due' && acc.Credit_Sub_Status__c=='Override'){
                               acc.Credit_Sub_Status__c='';
                               valueChange = true;
                           }
                        if(opp.name.contains('Migration')){
                            acc.Dunning_Hold__c=true;
                          acc.Hold_dunning_letter_till__c = Date.today();
                            valueChange = true;
                        } 
                        if(valueChange){
                            isAccNeedUpdate = true;
                        }
                        
                    }

/*
                    if((opp.AccountId == acc.id && opp.Credit_Approval_Status__c=='Approved')&&(opp.StageName=='Closed Won')&&(mapold.get(opp.Id).StageName!=mapnew.get(opp.Id).StageName)){            
                        if(acc.Credit_Status__c=='Past Due' && acc.Credit_Sub_Status__c=='Override'){  
                            system.debug('@@@@@ in Past Due condtion with Override');
                            acc.Credit_Sub_Status__c='';
                            acclisttoUpdate.add(acc);
                        }

                    }
*/

                    if((opp.AccountId == acc.id && opp.Credit_Approval_Status__c=='Approved')&&(mapold.get(opp.Id).Credit_Approval_Status__c!=mapnew.get(opp.Id).Credit_Approval_Status__c)&&(opp.StageName!='Closed Won'))
                    {
                        if(acc.Credit_Status__c=='Past Due'){           
                            acc.Credit_Sub_Status__c='Override';
                            isAccNeedUpdate = true;
                        }
                    }

/*                    if(opp.AccountId == acc.id && opp.name.contains('Migration') && opp.StageName=='Closed Won'){
                        acc.Dunning_Hold__c=true;
                        acc.Hold_dunning_letter_till__c = Date.today();
                        acclisttoUpdate.add(acc);

                    }   */      
                }
                
                if(acc.invoiceit_s__Job__r.size() == 0){
                //checking that there are opportunities other than closed lost stage
                    if(acc.opportunities.size() > 0){
                            acc.Customer_Status__c = 'Prospect';
                    }
                    else{
                        acc.Customer_Status__c = '';
                    }
                    isAccNeedUpdate = true;
                }
                if(isAccNeedUpdate){
                    acclisttoUpdate.add(acc);
                }
            }
        }
        if(acclisttoUpdate.size()>0)
        update acclisttoUpdate; 
        
    }
  /*  public void handleoppforCreditSubStatus(List<Opportunity> trgnew,Map<Id,Opportunity> mapold,Map<Id,Opportunity> mapnew){
        Set<Id> AccIdSet = new Set<Id>();
        List<Account> acclisttoUpdate = new List<Account>();        
        for(Opportunity opp : trgnew){
            if((opp.Credit_Approval_Status__c=='Approved')&&(mapold.get(opp.Id).Credit_Approval_Status__c!=mapnew.get(opp.Id).Credit_Approval_Status__c)&&(opp.StageName!='Closed Won')){
               AccIdSet.add(opp.AccountId);
            }
        }
        if(AccIdSet.size()>0){
            for(Account acc : [select Credit_Status__c,Credit_Sub_Status__c from Account where Id in :AccIdSet]){ 
                if(acc.Credit_Status__c=='Past Due'){           
                    acc.Credit_Sub_Status__c='Override';
                    acclisttoUpdate.add(acc);
                }
            }
        }
        if(acclisttoUpdate.size()>0)
        update acclisttoUpdate;       
    }
     public void handlemigratedoppforAccountDunning(List<Opportunity> trgnew){
        Set<Id> AccIdSet = new Set<Id>();
        List<Account> acclisttoUpdate = new List<Account>();        
        for(Opportunity opp : trgnew){
            if(opp.name.contains('Migration') && opp.StageName=='Closed Won'){
               AccIdSet.add(opp.AccountId);
            }
        }
        if(AccIdSet.size()>0){
            for(Account acc : [select Credit_Status__c,Credit_Sub_Status__c from Account where Id in :AccIdSet]){ 
                //if(acc.Credit_Status__c=='Past Due'){           
                    acc.Dunning_Hold__c=true;
                    acc.Hold_dunning_letter_till__c = Date.today();
                    acclisttoUpdate.add(acc);
                //}
            }
        }
        if(acclisttoUpdate.size()>0)
        update acclisttoUpdate;       
    }*/
    
    public void voidDocuSignEnvelopes(List<Opportunity> newopty,Map<Id,Opportunity> mapold,Map<Id,Opportunity> mapnew){
        
         Set<Id> setOppIds = new Set<Id>();
        
        for(Opportunity opp : newopty){
            System.debug('=======Voidable====='+opp.IsVoidable__c);
            System.debug('=======old Map====='+mapold.get(opp.id).IsVoidable__c);
            System.debug('=======New Map====='+mapnew.get(opp.id).IsVoidable__c);
            if((opp.IsVoidable__c == TRUE && (mapold.get(opp.id).IsVoidable__c!= mapnew.get(opp.id).IsVoidable__c)) || opp.StageName=='Closed Lost' || opp.StageName=='Expired'){
                System.debug('==============Inside if condition==================');
                setOppIds.add(opp.id);
            }
        }
        
        if(setOppIds.size()>0 && !system.isFuture() && !System.IsBatch()){
        System.debug('Sending to the future method');
        System.debug('Set of Opp Ids'+setOppIds);
            //Since Docusign callouts funt. not in place commenting this code
            voidingenvelope(setOppIds);           
        }   
    }
    
    @future(callout=true)
    public static void voidingenvelope(Set<Id> setOppIds){
        System.debug('===========Inside Future Method==============');
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND dsfs__Opportunity__c in :setOppIds]){
                DocusignVoidApi voi = new DocusignVoidApi();
                voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
            }
    }
    
    
    public static void voidingenvelopefrombatch(Set<Id> OppIds){
        System.debug('===========Inside Future Method==============');
        for(dsfs__DocuSign_Status__c docustat : [Select id, name,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c From dsfs__DocuSign_Status__c where dsfs__Envelope_Status__c!= 'Completed' AND dsfs__Envelope_Status__c!= 'Voided' AND dsfs__Opportunity__c in :OppIds]){
                DocusignVoidApi voi = new DocusignVoidApi();
                voi.voidEnvelope(docustat.dsfs__DocuSign_Envelope_ID__c,'Void APIs');
            }
    }
    
    
    public void releaseInventoryOnOppClosedLost(List<Opportunity> trgnew,Map<Id,Opportunity> mapold,Map<Id,Opportunity> mapnew){
       
        system.debug('@@@ in releaseInventoryOnOppClosedLost');
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setOppProdIds = new Set<Id>();
        set<id> setorder = new set<id>();
        list<invoiceit_s__Job__c> ordlist = new list<invoiceit_s__Job__c>();
        Map<Id,String> mapOppProdNInventoryId = new Map<Id,String>();
        List<invoiceit_crmx__Opportunity_Product__c > listOppProdsToUpdate = new List<invoiceit_crmx__Opportunity_Product__c >();
       // User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        for(Opportunity opp : trgnew){
            system.debug('@@@@ opp.stageName'+opp.StageName);
            system.debug('@@@@@@mapold.get(opp.Id).StageName'+mapold.get(opp.Id).StageName);
            system.debug('@@@@ opp.Quote_Type__c'+opp.Quote_Type__c);
            if(opp.StageName=='Closed Lost' && (mapold.get(opp.Id).StageName != mapnew.get(opp.Id).StageName) && (opp.Quote_Type__c!='Renew')){
                system.debug('@@@ in closed lost condition');
                setOppIds.add(opp.Id);
            }
//            if(opp.name.startswith('Modify') ||  opp.name.startswith('Mid-Term'))

//            {
 //               ordlist.add(new invoiceit_s__Job__c(id=opp.Created_From_Order__c));

//            }
        }
        if(setOppIds.size()>0){
            releaseOrderProductInventories(setOppIds);
            /*for(invoiceit_crmx__Opportunity_Product__c oppProd :[select Id,InventoryId__c,Product_SIN__c,invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c from invoiceit_crmx__Opportunity_Product__c where invoiceit_crmx__Opportunity__c in :setOppIds and IsInventoried__c='true']){
                if((oppProd.Product_SIN__c==null || oppProd.Product_SIN__c=='') || oppProd.invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c ){
                    if(oppProd.InventoryId__c!=null && oppProd.InventoryId__c!=''){
                        mapOppProdNInventoryId.put(oppProd.Id,oppProd.InventoryId__c);
                        setOppProdIds.add(oppProd.Id);
                        oppProd.InventoryId__c = '';
                        listOppProdsToUpdate.add(oppProd);
                    }
                }       
            }*/
        }
//        if (ordlist.size() > 0)
           // update ordlist;
//        
       /* if(setOppProdIds.size()>0 && MDL_RecursionHandler.releaseInventoryOnOppClosedLost){ 
            if(!Test.isRunningTest() ){
               // MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,u.Username,mapOppProdNInventoryId);
               // 
               // added by sai: 18/5
               ID jobID = System.enqueueJob(new ReleaseInventroyQueueable(setOppProdIds,u.Username,mapOppProdNInventoryId));
            }
            MDL_RecursionHandler.releaseInventoryOnOppClosedLost = false;
        }

        if(listOppProdsToUpdate.size()>0){
            Database.update(listOppProdsToUpdate);
        }*/
    }
    
    
    public static void releaseOrderProductInventories(Set<Id> oppIds){
        Set<Id> setOppProdIds                 = new Set<Id>();
        Map<Id,String> mapOppProdNInventoryId = new Map<Id,String>();
        List<invoiceit_crmx__Opportunity_Product__c > listOppProdsToUpdate = new List<invoiceit_crmx__Opportunity_Product__c >();
        
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
         for(invoiceit_crmx__Opportunity_Product__c oppProd :[select Id,InventoryId__c,Product_SIN__c,invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c from invoiceit_crmx__Opportunity_Product__c where invoiceit_crmx__Opportunity__c in :oppIds and IsInventoried__c='true']){
                if((oppProd.Product_SIN__c==null || oppProd.Product_SIN__c=='') || oppProd.invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c ){
                    if(oppProd.InventoryId__c!=null && oppProd.InventoryId__c!=''){
                        mapOppProdNInventoryId.put(oppProd.Id,oppProd.InventoryId__c);
                        //setOppProdIds.add(oppProd.Id);
                        oppProd.InventoryId__c = '';
                        listOppProdsToUpdate.add(oppProd);
                        if((oppProd.Product_SIN__c==null || oppProd.Product_SIN__c=='') || (oppProd.invoiceit_crmx__Opportunity__r.Closed_lost_from_Order__c && (oppProd.Product_SIN__c==null || oppProd.Product_SIN__c==''))){
                            setOppProdIds.add(oppProd.Id);
                        }
                    }
                }       
            }
        
        if(setOppProdIds.size()>0 && MDL_RecursionHandler.releaseInventoryOnOppClosedLost ){ 
            if(!Test.isRunningTest() ){
               // MDL_Integration_Vim_Efs.releaseInventoryRequest(setOppProdIds,u.Username,mapOppProdNInventoryId);
               // 
               // added by sai: 18/5
                ID jobID = System.enqueueJob(new ReleaseInventroyQueueable(oppIds,setOppProdIds,u.Username,mapOppProdNInventoryId));
            }
            MDL_RecursionHandler.releaseInventoryOnOppClosedLost = false;
        }

        if(listOppProdsToUpdate.size()>0){
            Database.update(listOppProdsToUpdate);
        }
        
        
    }
    
    
    
}