public class CascadeQuoteContact {
    Public Static Boolean CascadeQuoteContactFirstTime = True; 
    //----------------UPDATE-----------------------//
    public static void CascadeQuoteContactToOpp(Map<Id,SBQQ__Quote__c> newMap ,Map<Id,SBQQ__Quote__c> oldMap){
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> quoId = new Set<Id>();
        for(SBQQ__Quote__c quoRec : newMap.values()){
            if((newMap.get(quoRec.Id).SBQQ__Status__c != oldMap.get(quoRec.Id).SBQQ__Status__c && newMap.get(quoRec.Id).SBQQ__Status__c !=Null) &&
               (newMap.get(quoRec.Id).SBQQ__Status__c == 'QA Review' || newMap.get(quoRec.Id).SBQQ__Status__c == 'Closed Won')){
                   quoId.add(quoRec.Id);      
               }
        }
        //Update Opportunity
        if(quoId.size() > 0){
            for(Opportunity oppRec : Contract_UtilityClass.CascadeQuoteContact(quoId)){
                oppRec.Billing_Contact__c = oppRec.SBQQ__PrimaryQuote__r.Billing_Contact__c;
                oppRec.Marketing_Contact__c = oppRec.SBQQ__PrimaryQuote__r.Marketing_Contact__c;
                oppRec.Primary_Contact__c = oppRec.SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c;
                oppList.add(oppRec);
            }
        }
        if(oppList.size() > 0){
            Update oppList;
        }
    }
    public static void CascadeQuoteContactToOrderContract(Map<Id,SBQQ__Quote__c> newMap ,Map<Id,SBQQ__Quote__c> oldMap){
        List<Order> ordList = new List<Order>();
        List<Contract> conList = new List<Contract>();
        Set<Id> quoId = new Set<Id>();
        for(SBQQ__Quote__c quoRec : newMap.values()){
            if((newMap.get(quoRec.Id).Billing_Contact__c != oldMap.get(quoRec.Id).Billing_Contact__c) ||
               (newMap.get(quoRec.Id).Marketing_Contact__c != oldMap.get(quoRec.Id).Marketing_Contact__c) ||
               (newMap.get(quoRec.Id).SBQQ__PrimaryContact__c != oldMap.get(quoRec.Id).SBQQ__PrimaryContact__c)){
                   quoId.add(quoRec.Id);      
               }
        }
        //Update Order
        if(quoId.size() > 0){
            for(Order ordRec : Contract_UtilityClass.CascadeQuoteContactAA(quoId)){
                ordRec.BillToContactId = ordRec.SBQQ__Quote__r.Billing_Contact__c;
                ordRec.Marketing_Contact__c = ordRec.SBQQ__Quote__r.Marketing_Contact__c;
                ordRec.Primary_Contact__c = ordRec.SBQQ__Quote__r.SBQQ__PrimaryContact__c;
                ordList.add(ordRec);
            }
        }
        if(ordList.size() > 0){
            Update ordList;
        }
        //Update Contract
        if(quoId.size() > 0){
            for(Contract conRec : Contract_UtilityClass.CascadeQuoteContactBB(quoId)){
                conRec.Bill_To_Contact__c = conRec.SBQQ__Quote__r.Billing_Contact__c;
                conRec.Marketing_Contact__c = conRec.SBQQ__Quote__r.Marketing_Contact__c;
                conRec.Primary_Contact__c = conRec.SBQQ__Quote__r.SBQQ__PrimaryContact__c;
                conList.add(conRec);
            }
        }
        if(conList.size() > 0){
            Update conList;
        }
    }
    //----------------UPDATE-----------------------//
    
    //----------------INSERT-----------------------//
    public static void CascadeQuoteContactToOrderIn(List<Order> ordList){
        Set<Id> quoId = new Set<Id>();
        List<Order> ordListA = new List<Order>();
        for(Order ord : ordList){
            if(ord.SBQQ__Quote__c != Null){
                quoId.add(ord.SBQQ__Quote__c);
            }
        }
        if(quoId.size()>0){
            for(Order ordA : Contract_UtilityClass.CascadeQuoteContactAA(quoId)){
                ordA.BillToContactId = ordA.SBQQ__Quote__r.Billing_Contact__c;
                ordA.Marketing_Contact__c = ordA.SBQQ__Quote__r.Marketing_Contact__c;
                ordA.Primary_Contact__c = ordA.SBQQ__Quote__r.SBQQ__PrimaryContact__c;
                ordListA.add(ordA);
            }
        }
        if(ordListA.size() > 0){
            Update ordListA;
        } 
    }
    public static void CascadeQuoteContactToContractIn(List<Contract> contList){
        Set<Id> quoId = new Set<Id>();
        List<Contract> contListA = new List<Contract>();
        for(Contract cont : contList){
            if(cont.SBQQ__Quote__c != Null){
                quoId.add(cont.SBQQ__Quote__c);
            }
        }
        if(quoId.size()>0){
            for(Contract contA : Contract_UtilityClass.CascadeQuoteContactBB(quoId)){
                contA.Bill_To_Contact__c = contA.SBQQ__Quote__r.Billing_Contact__c;
                contA.Marketing_Contact__c = contA.SBQQ__Quote__r.Marketing_Contact__c;
                contA.Primary_Contact__c = contA.SBQQ__Quote__r.SBQQ__PrimaryContact__c;
                contListA.add(contA);
            }
        }
        if(contListA.size() > 0){
            Update contListA;
        } 
    }
}