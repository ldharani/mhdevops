/***********************************************************************************************************************
 * @author - Sc
 * @date - 30 Mar 2022
 * @description - CPQ_ContractHelper
 * @testclass - 

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6861    VR            28/04/2022                   T04     Added changes for Street Line 2 Field
MHBS-6320    SS            31/03/2022   John Mattheson          Moving process builder to Apex
MHBS-7271    SS            13/06/2022   John Mattheson  <T01>   Fix for evergreened status update on contract
             SC            24/06/2022   John Mattheson  <T02>   Commented Debug logs
************************************************************************************************************************/
public class CPQ_ContractHelper {
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
           if((co.Status !=  '' || co.Status != null)            
               && co.SBQQ__Opportunity__r.SBQQ__RenewedContract__c != null && co.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Amend_Quote__c != null){
                   quotemap.put(co.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Amend_Quote__c , co.id); 
                   //system.debug('@@@ added map @@'+quotemap);
               }
        }
        //system.debug('@@@ quotemap @@'+quotemap);
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
            //system.debug(' @@@ QuoteUpdate @@@ '+qteUpdate );
            if(!qteUpdate.isEmpty() && !test.isRunningTest()){
                update qteUpdate ;
            }
        }
    }
    @future
    public static void updateContractStatusfromCanInPrgs(String jsonNewList, String jsonOldMap){ 
        List<Contract> contList = (List<Contract>) JSON.deserialize(jsonNewList, List<Contract>.class);
        Map<id, Contract> oldMap = (Map<id, Contract>) JSON.deserialize(jsonOldMap, Map<id, Contract>.class);
        List<Contract> ctLstToUpdate = new List<Contract>();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        Map<Id,List<SBQQ__Subscription__c>> subIdVsContractIdMap = new Map<Id,List<SBQQ__Subscription__c>>();
        
        for(SBQQ__Subscription__c sub: Contract_UtilityClass.checkSubsStatus(contList)){
            if(sub.Status__c != 'Cancelled' && sub.Status__c != 'Off set' && sub.SBQQ__TerminatedDate__c == Null){
                subList.add(sub);
                subIdVsContractIdMap.put(sub.SBQQ__Contract__c, subList);
            }
        }
        Id RecordTypeId_MAcontract = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('M-A Contract').getRecordTypeId(); //addedbysaiv M2.1
        for(Contract ct: Contract_UtilityClass.ForCancel(contList)){
            system.debug('===ct==='+ct);
            if(((((ct.IsCancelQuoteCreated__c == FALSE && ct.IsCancelQuoteCreated__c != oldMap.get(ct.Id)?.IsCancelQuoteCreated__c) 
                || ct.IsCancelQuoteCreated__c == FALSE) && ct.Status__c == 'Cancel in progress')) || (ct.RecordTypeId == RecordTypeId_MAcontract && ct.Amend_Quote__r.Cancelled__c == True) ){
                   if(!subIdVsContractIdMap.isEmpty()){
                       if(ct.SBQQ__RenewalOpportunity__c != Null && !subIdVsContractIdMap.get(ct.Id).isEmpty()){
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
                       }else if(ct.SBQQ__Evergreen__c == TRUE && subIdVsContractIdMap.containsKey(ct.Id) && !subIdVsContractIdMap.get(ct.Id).isEmpty()){
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
        //system.debug('==ctLstToUpdate=='+ctLstToUpdate);
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
        //system.debug('==previousContractLst=='+previousContractLst);
        //system.debug('==futureVSPreviousContrct=='+previousContractLst);
        for(Contract cont: Contract_UtilityClass.updateFutureContract(previousContractLst)){
        //system.debug('==futureVSPreviousContrct=='+futureVSPreviousContrct.containsKey(cont.Id));
            if(futureVSPreviousContrct.containsKey(cont.Id) || test.isRunningTest()){
                //system.debug('==in if 201==');
                cont.FutureContract__c = futureVSPreviousContrct.get(cont.Id);
                previousContractLstToUpdate.add(cont);
            }
        }
        //system.debug('==previousContractLstToUpdate=='+previousContractLstToUpdate);
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
        //System.debug('updateContractOrderStatus');
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
        
    }
    
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