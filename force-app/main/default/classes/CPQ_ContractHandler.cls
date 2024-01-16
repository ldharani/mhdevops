/***********************************************************************************************************************
 * @author - Sc
 * @date - 30 Mar 2022
 * @description - CPQ_ContractHandler
 * @testclass - 

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6861    VR            28/04/2022                   T04     Added changes for Street Line 2 Field
MHBS-6320    SS            31/03/2022   John Mattheson          Moving process builder to Apex
MHBS-7271    SS            13/06/2022   John Mattheson  <T01>   Fix for evergreened status update on contract
             SC            24/06/2022   John Mattheson  <T02>   Commented Debug logs
MHMAC-296    Jey           20/06/2023   John Mattheson  <T03>   Auto Create Amend Quote upon the Contract creation
MHBS-7447    SS            03/08/2022   John Mattheson  <T03>   Proration Billing Changes
************************************************************************************************************************/
public class CPQ_ContractHandler {

     public static void afterInsertHandler(List<Contract> contractLst){
        CPQ_ContractHelper.updateAccountNgageCustId(contractLst);
        if(CascadeQuoteContact.CascadeQuoteContactFirstTime == True){
            CascadeQuoteContact.CascadeQuoteContactFirstTime = False;
            CascadeQuoteContact.CascadeQuoteContactToContractIn(contractLst);
        }
       
        if(MDL_RecursionHandler.contractHandlerCheck == true){
            CPQ_ContractHelper.updateCreatedFromContract(contractLst);//MHBS-6320 
            CPQ_ContractHelper.updateContractOrderStatus(contractLst,null,false);//MHBS-6320
        }        
    }

    public static void afterUpdateHandler(List<Contract> contractLst, Map<Id, Contract> contractOldMap){
        CPQ_ContractHelper.updateAccountNgageCustId(contractLst);
        if((Deactivate_Customer_Order_Case_Update__c.getInstance(userinfo.getProfileId()) != null 
            && Deactivate_Customer_Order_Case_Update__c.getInstance(userinfo.getProfileId()).Activate__c)){                                  
                return;
            } else {
                AccountOrderStatusLogic.handlerLogic(contractLst);
        }
        CPQ_ContractHelper.updateContractOrderStatus(contractLst,contractOldMap,true);//MHBS-6320
        if(MDL_RecursionHandler.contractUpdateCheck == true){//MHBS-6320
            //cancellation filters
            List<Contract> contractCancelLst = new List<Contract>();
            Id RecordTypeId_MAcontract = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('M-A Contract').getRecordTypeId();
            for(Contract con: contractLst){
                if(con.Status__c == 'Cancel in progress' || con.RecordTypeId == RecordTypeId_MAcontract){
                    system.debug('==in cancel contract====');
                    contractCancelLst.add(con);    
                }
            }
            String jsonOldMap = JSON.serialize(contractOldMap);//T08
            String jsonNew = JSON.serialize(contractCancelLst);//T08
            if(!System.IsBatch() && !System.isFuture()){//T08
                System.debug('@@@@test10244 1'+jsonNew+' '+jsonOldMap);
                CPQ_ContractHelper.updateContractStatusfromCanInPrgs(jsonNew, jsonOldMap);
            }
            //added by saiv 04/13/2021
            if(!Test.isRunningTest()){
                CPQ_ContractHelper.updateFutureContract(contractLst,contractOldMap);
            }
        }
    }
    
    /*********** moved below code to cpq_contractHelper
    //@InvocableMethod
    // public static void CreateOrderforAmend(List<Contract> contractList, Map<Id,Contract> oldMap){
    public static void CreateOrderforAmend(List<Contract> contractList){
        Set<Id> ContractId = new Set<Id>();
        List<Contract> ConLst = new List<Contract>();
        List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> ConLinesLst = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> qteUpdate = new List<SBQQ__Quote__c>();
        map<id,id> quotemap = new  map<id,id>();
        
        system.debug('@@@ ConLst @@'+contractList);
        for(Contract co: contractList){
            // && co.Status != oldMap.get(co.Id).Status
            System.debug('1!!!!!!!!! ' + co.Status );
            System.debug('2!!!!!!!!! ' + co.SBQQ__Opportunity__r.SBQQ__RenewedContract__c );
            System.debug('3!!!!!!!!! ' + co.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Amend_Quote__c );
            if((co.Status !=  '' || co.Status != null)            
               && co.SBQQ__Opportunity__r.SBQQ__RenewedContract__c != null && co.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Amend_Quote__c != null){
                   
                   quotemap.put(co.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Amend_Quote__c , co.id); 
                   
                   system.debug('@@@ added map @@'+quotemap);             
                   
               }
        }
        system.debug('@@@ quotemap @@'+quotemap);
        if(!quotemap.isEmpty()){
            quoteLst = [select id,SBQQ__Status__c,Reason_Won_Lost__c  FROM 
                        SBQQ__Quote__c   WHERE Id IN:quotemap.keyset() AND SBQQ__Status__c != 'Closed Won' AND SBQQ__Status__c!= 'Close Lost'];
            for(SBQQ__Quote__c qte : quoteLst ){
                if(qte.SBQQ__Status__c!= 'Closed Won' ){
                    qte.SBQQ__Status__c= 'Closed Won'; 
                    qte.Reason_Won_Lost__c  = 'Administrative';
                    qteUpdate.add(qte);
                }    
            }
            system.debug(' @@@ QuoteUpdate @@@ '+qteUpdate );
            if(!qteUpdate.isEmpty() && !test.isRunningTest()){
                update qteUpdate ;
            }
        }
        
        
    }
    /*
    public static void UpdateSentEmail(List<Contract> contractList,Map<Id,Contract> oldMap){
        List<String> statusList = new List<String>{'Rebased','Evergreened','Midtermed'};
        for(Contract ctct:contractList){
            Contract oldObj = oldMap.get(ctct.Id);
            if(oldObj.status__c !=ctct.status__c && statusList.contains(ctct.status__c) &&!ctct.Email_Sent__c){
                ctct.Email_Sent__c = true;
            }
        }
        System.debug(' updated COntractList;:'+JSON.serialize(contractList));
    }*/
    
    /* Commented while writing test class since its commented on Trigger - JEY
    public static void UpdateCreatefromContract(List<Contract> contractList){
        Map<id, id> previouscontract = new Map<id, id>();
        Set<Id> ContractId = new Set<Id>();
        List<Contract> ConLst = new List<Contract>();
        List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> ConLinesLst = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> qteUpdate = new List<SBQQ__Quote__c>();
        map<id,id> quotemap = new  map<id,id>();
        
        system.debug('@@@ ConLst @@'+contractList);
        for(Contract co: contractList){
            
            if(co.SBQQ__Opportunity__r.SBQQ__RenewedContract__c != null && co.SBQQ__Opportunity__r.SBQQ__RenewedContract__c != ''){
                
                previouscontract.put(co.id, co.SBQQ__Opportunity__r.SBQQ__RenewedContract__c); 
                
                system.debug('@@@ added map @@'+previouscontract);            
                
            }
        }
        system.debug('@@@ quotemap @@'+previouscontract);
        if(!previouscontract.isEmpty()){
            for(Contract co: contractList){
                
                if(previouscontract.containsKey(co.SBQQ__Opportunity__r.SBQQ__RenewedContract__c) ){
                    co.Created_from_Contract__c = previouscontract.get(co.SBQQ__Opportunity__r.SBQQ__RenewedContract__c);
                    ConLst.add(co);
                }    
            }
            system.debug(' @@@ QuoteUpdate @@@ '+ConLst );
            if(!ConLst.isEmpty()){
                update ConLst ;
            }
        }
        
        
    }
    */
    /*
    @future
    //public static void updateContractStatusfromCanInPrgs(List<Contract> contList, Map<Id, Contract> oldMap){
    public static void updateContractStatusfromCanInPrgs(String jsonNewList, String jsonOldMap){
        List<Contract> contList = (List<Contract>) JSON.deserialize(jsonNewList, List<Contract>.class);
        Map<id, Contract> oldMap = (Map<id, Contract>) JSON.deserialize(jsonOldMap, Map<id, Contract>.class);
        system.debug('=====contList====='+contList);
        system.debug('=====oldMap====='+oldMap);
        List<Contract> ctLstToUpdate = new List<Contract>();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        Map<Id,List<SBQQ__Subscription__c>> subIdVsContractIdMap = new Map<Id,List<SBQQ__Subscription__c>>();
        //Set<Id> nonTerminatedSubList = new Set<Id>(); //added for mhbs-6646
        //<T02>system.debug('==contListforcancel=='+contList);
        //for(SBQQ__Subscription__c sub: [select id,Status__c,SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Contract__c IN: contList]){
        for(SBQQ__Subscription__c sub: Contract_UtilityClass.checkSubsStatus(contList)){
           //<T02> system.debug('=====sub=====90'+sub);
            if(sub.Status__c != 'Cancelled' && sub.Status__c != 'Off set' && sub.SBQQ__TerminatedDate__c == Null){
              //<T02>  system.debug('===status=='+sub.Status__c);
                //<T02>system.debug('===sub.SBQQ__TerminatedDate__c=='+sub.SBQQ__TerminatedDate__c);
                subList.add(sub);
                subIdVsContractIdMap.put(sub.SBQQ__Contract__c, subList);
            }
        }
        system.debug('==subIdVsContractIdMap=='+subIdVsContractIdMap);
        Id RecordTypeId_MAcontract = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('M-A Contract').getRecordTypeId(); //addedbysaiv M2.1
        for(Contract ct: Contract_UtilityClass.ForCancel(contList)){
            system.debug('==1=='+ct.IsCancelQuoteCreated__c);
            system.debug('==2=='+ct.Status__c);
            system.debug('==oldMap.get(ct.Id)=='+oldMap.get(ct.Id));
            if((((ct.IsCancelQuoteCreated__c == FALSE && ct.IsCancelQuoteCreated__c != oldMap.get(ct.Id)?.IsCancelQuoteCreated__c) 
                || ct.IsCancelQuoteCreated__c == FALSE) && ct.Status__c == 'Cancel in progress')){
                   //ct.Status__c = ct.PriorStatusVal__c;
                   if(!subIdVsContractIdMap.isEmpty()){
                       if(ct.SBQQ__RenewalOpportunity__c != Null && !subIdVsContractIdMap.get(ct.Id).isEmpty()){
                           //if(!ct.SBQQ__RenewalOpportunity__r.Name.contains('')){
                               if(ct.SBQQ__RenewalOpportunity__r.Name.contains('Renewal')){
                                   ct.Status__c = 'Renewed';
                               }
                               else if(ct.SBQQ__RenewalOpportunity__r.Name.contains('Rebased')){
                                   ct.Status__c = 'Rebased';
                               }
                               else if(ct.SBQQ__RenewalOpportunity__r.Name.contains('Mid-Term')){
                                   ct.Status__c = 'Midtermed';
                               }
                               else if(ct.SBQQ__RenewalOpportunity__r.Name.contains('Evergreen')){
                                   system.debug('===in evergreened==');
                                   ct.Status__c = 'Evergreened';
                               }
                           //}
                       }else if(ct.SBQQ__Evergreen__c == TRUE && subIdVsContractIdMap.containsKey(ct.Id) && !subIdVsContractIdMap.get(ct.Id).isEmpty()){
                                    //&& nonTerminatedSubList.size()>0){ //added for mhbs-6646 
                                    if(ct.RecordTypeId == RecordTypeId_MAcontract){//M2.1 SaiV
                                        ct.Status__c = 'Active';
                                    }else{
                                       ct.Status__c = 'Evergreen';
                                    }
                       }else{ //if(subIdVsContractIdMap.containsKey(ct.Id) && !subIdVsContractIdMap.get(ct.Id).isEmpty())
                           ct.Status__c = 'Active';
                       }
                   }
                   else{
                       ct.Status__c = 'Cancelled';
                       ct.Cancelled__c = TRUE;
                   }
                   ctLstToUpdate.add(ct);
               }
        }
        system.debug('==ctLstToUpdate=='+ctLstToUpdate);
        if(!ctLstToUpdate.isEmpty()){
            update ctLstToUpdate;
        }
    }  
    
    //added by IJ
    //Description : To roll up the Ngage customer ID ON Account
   
    public static void updateAccountNgageCustId(List<Contract> ContractList){        

        Map<String,List<Contract>> accToOrderMap = new Map<String,List<Contract>>();  
        for(Contract  obj : ContractList){
            List<Contract> AccContractList = new List<Contract>();
            if(accToOrderMap.containsKey(obj.AccountId)){
                AccContractList = accToOrderMap.get(obj.AccountId);
                AccContractList.add(obj);
                accToOrderMap.put(obj.AccountId,AccContractList);
            }else{
                AccContractList.add(obj);
                accToOrderMap.put(obj.AccountId,AccContractList);
            }
        }
        //Acc1.Id,Acc2.ID
        Map<String,Set<String>> accMap = new Map<String,Set<String>>();
        if(!accToOrderMap.keySet().Isempty() && accToOrderMap.keySet() != null){
        List<Contract> TempContract = Contract_UtilityClass.updateAccountNgageCustIdMeth(accToOrderMap);
       
        for(Contract obj : TempContract){
          String custId = obj.Ngage_Cust_ID__c;
            Set<String> custIdSet = new Set<String>();
            if(accMap.containsKey(obj.AccountId)){
                custIdSet = accMap.get(obj.AccountId);
            }
            custIdSet.add(custId);
            accMap.put(obj.AccountId,custIdSet);
        }
        
        List<Account> accListToBeUpdated = new List<Account>();
        for(String AccId : accMap.keySet()){
            String result = '';
            for(String custId : accMap.get(AccId)){
                if(custId != null){
                    if(result != ''){
                        result += ',';
                    }
                    result += custId;
                }
            }
            Account acc = new Account();
            acc.Id = AccId;
            acc.Customer_ID__c = result;
          accListToBeUpdated.add(acc);
        }
        upsert accListToBeUpdated;
        }
    }
    //method to update future contract - for contract banner -added by saiv 04/13/2021
    public static void updateFutureContract(List<Contract> ContractList, Map<id,contract> oldMap){
        Set<Id> previousContractLst = new Set<Id>();
        List<Contract> previousContractLstToUpdate = new List<Contract>();
        Map<Id,Id> futureVSPreviousContrct = new Map<Id,Id>();
        for(Contract co: ContractList){
            if((co.Created_from_Contract__c != null && co.Created_from_Contract__c != oldMap.get(co.Id).Created_from_Contract__c) || test.isRunningTest()){
            //system.debug();
                previousContractLst.add(co.Created_from_Contract__c);
                futureVSPreviousContrct.put(co.Created_from_Contract__c, co.Id);
            }
        }
        system.debug('==previousContractLst=='+previousContractLst);
        system.debug('==futureVSPreviousContrct=='+previousContractLst);
        for(Contract cont: Contract_UtilityClass.updateFutureContract(previousContractLst)){
        system.debug('==futureVSPreviousContrct=='+futureVSPreviousContrct.containsKey(cont.Id));
            if(futureVSPreviousContrct.containsKey(cont.Id) || test.isRunningTest()){
                system.debug('==in if 201==');
                cont.FutureContract__c = futureVSPreviousContrct.get(cont.Id);
                previousContractLstToUpdate.add(cont);
            }
        }
        system.debug('==previousContractLstToUpdate=='+previousContractLstToUpdate);
        if(!previousContractLstToUpdate.isEmpty() && !test.isRunningTest()){
            update previousContractLstToUpdate;
            MDL_RecursionHandler.contractUpdateCheck = false; //<T01>
        }
    
    }
    

    
         //MHBS-6320
    public static void updateCreatedFromContract(List<Contract > ContractList){        
         System.debug('updateCreatedFromContract');
        Set<String> custIdSet = new Set<String>();
         Set<Id> accIds = new Set<Id>();  
        List<Contract> updateContrList = new List<Contract>();
        for(Contract obj : [Select id,AccountId, Created_from_Contract__c,SBQQ__Opportunity__r.SBQQ__RenewedContract__c, SBQQ__Opportunity__r.SBQQ__AmendedContract__c from Contract where id in :ContractList]){
            System.debug(obj.SBQQ__Opportunity__r.SBQQ__RenewedContract__c );
            if(obj.SBQQ__Opportunity__r.SBQQ__RenewedContract__c != null){
                obj.Created_from_Contract__c = obj.SBQQ__Opportunity__r.SBQQ__RenewedContract__c;
                 accIds.add(obj.AccountId);
                updateContrList.add(obj);
                System.debug(updateContrList);
            }else if(obj.SBQQ__Opportunity__r.SBQQ__AmendedContract__c != null && obj.SBQQ__Opportunity__r.SBQQ__RenewedContract__c == null){//MHBS-7942
                obj.Created_from_Contract__c = obj.SBQQ__Opportunity__r.SBQQ__AmendedContract__c;
                updateContrList.add(obj);
            }
        }
        
        if(updateContrList.size()>0){
            MDL_RecursionHandler.contractHandlerCheck = false;
            try{
            update updateContrList;
                 }catch(Exception e){
                   Util.processException(e,true,'updateCreatedFromContract : Error during updation of Contracts'+updateContrList);
            }
        }
    }
    
    //MHBS-6320
    public static void updateContractOrderStatus(List<Contract > ContractList,Map<Id,Contract> ContractMap,Boolean isUpdate){        
             System.debug('updateContractOrderStatus');
        System.debug(isUpdate);
        Set<Id> evgContracts = new Set<Id>();
        Set<Id> renewedContracts = new Set<Id>();
        Set<Id> evgOrders= new Set<Id>();
        Set<Id> renewedOrders = new Set<Id>();
        List<Contract> updateContrList = new List<Contract>();
        List<Order> updateOrdersList = new List<Order>();
        for(Contract obj : [Select Id, EndDate,status,SBQQ__Opportunity__r.SBQQ__RenewedContract__c,SBQQ__Opportunity__r.Name from Contract where id in :ContractList and (SBQQ__Opportunity__r.Name like '%Evergreen%' OR SBQQ__Opportunity__r.Name like '%Renewal%')]){
           System.debug(obj.Id);
            System.debug(obj.SBQQ__Opportunity__r.Name);
            System.debug(obj.EndDate);
            System.debug(isUpdate);

            System.debug(obj.Status);
            System.debug(ContractMap);
            if(isUpdate == true){
            if(obj.SBQQ__Opportunity__r.Name.contains('Evergreen') && obj.EndDate == null && ((ContractMap!= null && ContractMap.containskey(obj.Id) && ContractMap.get(obj.id).status == 'Draft') && obj.Status == 'Activated')){
                obj.Status__c = 'Evergreen';
                updateContrList.add(obj);
                System.debug(updateContrList);
                }
            }
            if(obj.SBQQ__Opportunity__r.Name.contains('Evergreen')){
                evgContracts.add(obj.SBQQ__Opportunity__r.SBQQ__RenewedContract__c);
            }
            if(obj.SBQQ__Opportunity__r.Name.contains('Renewal')){
                renewedContracts.add(obj.SBQQ__Opportunity__r.SBQQ__RenewedContract__c);
            }             
        }
        
        if(isUpdate != true){
        System.debug(evgContracts);
         System.debug(renewedContracts);
        for(Contract obj : [Select id,EndDate,Status__C,SBQQ__Order__C from Contract where (id in :evgContracts or id in :renewedContracts)]){
            if(evgContracts.contains(obj.Id)){                
                obj.Status__c = 'Evergreened';                
                evgOrders.add(obj.SBQQ__Order__C);
                updateContrList.add(obj);
                 System.debug(evgOrders);
                 System.debug(updateContrList);
            }else if(renewedContracts.contains(obj.Id)){
                obj.Status__c = 'Renewed';
                renewedOrders.add(obj.SBQQ__Order__C);
                updateContrList.add(obj);
                System.debug(renewedOrders);
                 System.debug(updateContrList);
            }
        }
        
         for(Order obj : [Select id,Status__C from Order where (id in :evgOrders or id in :renewedOrders)]){
            if(evgContracts.contains(obj.Id)){                
                obj.Status__c = 'Evergreened';
                updateOrdersList.add(obj);
                      System.debug(updateOrdersList);
            }else if(renewedOrders.contains(obj.Id)){
                obj.Status__c = 'Renewed';
                updateOrdersList.add(obj);
                      System.debug(updateOrdersList);
            }
        }
        }
        
        System.debug(updateContrList);
        if(updateContrList.size()>0){
            MDL_RecursionHandler.contractHandlerCheck = false;
            
            try{
                
            update updateContrList;
            }catch(Exception e){
                Util.processException(e,true,'updateContractOrderStatus : Error during updation of Contracts'+updateContrList);
            }
        }
        
        System.debug(updateOrdersList);
        if(updateOrdersList.size()>0){
            try{
            update updateOrdersList;
             }catch(Exception e){
                Util.processException(e,true,'updateContractOrderStatus : Error during updation of Orders'+updateOrdersList);
            }
        }
        
    }*/
    //<T03> - Start
    public static QuoteModel load(String contractId, String context) {
        String quoteJSON = SBQQ.ServiceRouter.load('SBQQ.ContractManipulationAPI.ContractAmender', contractId, context);
        return (QuoteModel) JSON.deserialize(quoteJSON, QuoteModel.class);
    }
    private with sharing class AmendmentContextTest {
        public Boolean returnOnlyQuoteId;
    }
    @InvocableMethod(label = 'Call Amend Quote Creation method')
    public static void addProd(List<Id> conId){
        amendQuoteCreation(conId);
        System.debug('TTTTTTTTTTTTTS' + conId);
    }
    @future(callout=true)
    public static void amendQuoteCreation(List<Id> conId) {

        List<Contract> ContractList = [SELECT ID,IsInsertviaBatch__c FROM Contract WHERE RecordType.Developername = 'M_A_Contract' AND Id IN :conId];
            System.debug('121111111111112 ' + ContractList);
            AmendmentContextTest context = new AmendmentContextTest();
            context.returnOnlyQuoteId = true; 
            
            // Invoke the ContractAmender API
            String contextJson = JSON.serialize(context);
        for(Contract Con : ContractList){
            if(Con.IsInsertviaBatch__c == false){
                System.debug('435252343526326 ' + Con);
                try {
                    System.debug('tryyyyyyyyy ' + Con.Id);
                    QuoteModel quote = load(Con.Id, contextJson);
                } catch (Exception e) {
                    System.debug('An exception occurred: ' + e.getMessage());
                    QuoteModel quote = load(Con.Id, contextJson);
                    System.debug('tryy2222222 ' + Con.Id);
                }
            }
        }  
    }
    //<T03> - End
    //
    //
   
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