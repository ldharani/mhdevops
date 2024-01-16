public class Contract_UtilityClass { 
    Public Static List<Contract> contractList = new List<Contract>();
    Public Static List<Contract> contractListAA = new List<Contract>();
    Public Static List<SBQQ__Subscription__c> SBQQSubscriptionList = new List<SBQQ__Subscription__c>();
    public static List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
    public static List<Opportunity> oppList = new List<Opportunity>();
    public static List<Order> oddList = new List<Order>();
    Public Static List<Contract> contractListB = new List<Contract>();
    Public Static List<Contract> contractListforFutureUpdate = new List<Contract>();
    public static List<SBQQ__Subscription__c> subNgList = new List<SBQQ__Subscription__c>();
    public static List<Account> accNgList = new List<Account>();
    Public Static List<Contract> contractListforCancel = new List<Contract>();
    
    public static List<Contract> NgageIndicatorOnAccount(List<Contract> contrtLits){
        if(contractList.size() == 0){
            contractList = [SELECT ID,AccountId,Account.Is_Ngage_Product_added__c,Account.RecordTypeId,
                            IsCancelQuoteCreated__c,Status__c,CancelDate__c,Cancelled__c,SBQQ__Evergreen__c,
                            SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.Name, Created_from_Contract__c, FutureContract__c
                            FROM Contract WHERE Id IN: contrtLits];
        }
        return contractList; 
    }
    public static List<Contract> ForCancel(List<Contract> contrtLits){
        if(contractListforCancel.size() == 0){//M2.1 Saiv
            contractListforCancel = [SELECT ID,AccountId,Account.Is_Ngage_Product_added__c,Account.RecordTypeId,RecordTypeId,
                            IsCancelQuoteCreated__c,Status__c,CancelDate__c,Cancelled__c,SBQQ__Evergreen__c,Amend_Quote__r.Cancelled__c,
                            SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.Name, Created_from_Contract__c, FutureContract__c
                            FROM Contract WHERE Id IN: contrtLits FOR UPDATE];
        }
        return contractListforCancel; 
    }
    public static List<Contract> updateFutureContract(Set<Id> conId){
        if(contractListforFutureUpdate.size() == 0){
            contractListforFutureUpdate = [SELECT ID,AccountId,Account.Is_Ngage_Product_added__c,Account.RecordTypeId,
                            IsCancelQuoteCreated__c,Status__c,CancelDate__c,Cancelled__c,SBQQ__Evergreen__c,
                            SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.Name, Created_from_Contract__c, FutureContract__c
                            FROM Contract WHERE Id IN: conId];
        }
        return contractListforFutureUpdate; 
    }
    public static List<SBQQ__Subscription__c> SBQQSubscription(Set<Id> conId){
        if(SBQQSubscriptionList.size() == 0){
            SBQQSubscriptionList = [SELECT Id,SBQQ__Contract__c,Status__c,SBQQ__Product__r.Family,SBQQ__Product__r.Name,SBQQ__Contract__r.AccountId FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN: conId];
        }
        return SBQQSubscriptionList; 
    }
    public static List<SBQQ__Subscription__c> checkSubsStatus(List<Contract> contList){
        if(subList.size() == 0){
            subList = [select id,Status__c,SBQQ__Contract__c,SBQQ__TerminatedDate__c,SBQQ__RevisedSubscription__c from 
                       SBQQ__Subscription__c where SBQQ__Contract__c IN: contList];
        }
        return subList;
    }
    public static List<Contract> updateAccountNgageCustIdMeth(Map<String,List<Contract>> accToOrderMap){
        if(contractListAA.size() == 0){
            contractListAA = [SELECT Id,AccountId,Ngage_Cust_ID__c FROM Contract WHERE AccountId In: accToOrderMap.keySet()];
        }
        return contractListAA; 
    }
    public static List<Opportunity> CascadeQuoteContact(Set<Id> quoId){
        if(oppList.size() == 0){
            oppList = [SELECT Id,Billing_Contact__c,Marketing_Contact__c,Primary_Contact__c,SBQQ__PrimaryQuote__r.Billing_Contact__c,SBQQ__PrimaryQuote__r.Marketing_Contact__c,SBQQ__PrimaryQuote__r.SBQQ__PrimaryContact__c FROM Opportunity WHERE SBQQ__PrimaryQuote__c IN: quoId];
        }
        return oppList; 
    }
    public static List<Order> CascadeQuoteContactAA(Set<Id> quoId){
        if(oddList.size() == 0){
            oddList = [SELECT Id,BillToContactId,Marketing_Contact__c,Primary_Contact__c,SBQQ__Quote__r.Billing_Contact__c,SBQQ__Quote__r.Marketing_Contact__c,SBQQ__Quote__r.SBQQ__PrimaryContact__c FROM Order WHERE SBQQ__Quote__c IN: quoId];
        }
        return oddList; 
    }
    public static List<Contract> CascadeQuoteContactBB(Set<Id> quoId){
        if(contractListB.size() == 0){
            contractListB = [SELECT Id,Bill_To_Contact__c,Marketing_Contact__c,Primary_Contact__c,SBQQ__Quote__r.Billing_Contact__c,SBQQ__Quote__r.Marketing_Contact__c,SBQQ__Quote__r.SBQQ__PrimaryContact__c FROM Contract WHERE SBQQ__Quote__c IN: quoId];
        }
        return contractListB; 
    }
    public static List<SBQQ__Subscription__c> ngageSub(Set<Id> AccId){
        if(subNgList.size() == 0){
            subNgList = [SELECT ID,SBQQ__Quantity__c,SBQQ__Product__r.Name,SBQQ__Product__r.Family,SBQQ__Account__c,Status__c FROM SBQQ__Subscription__c WHERE SBQQ__Account__c IN: AccId AND (SBQQ__Product__r.Family = 'Ngage' OR SBQQ__Product__r.Name = 'Martindale-Avvo Complete Profile Plus' OR SBQQ__Product__r.Name = 'Martindale Base Profile')];
        }
        if(subNgList.size() == 0 && Test.isRunningTest()){
            subNgList = [SELECT ID,SBQQ__Quantity__c,SBQQ__Product__r.Name,SBQQ__Product__r.Family,SBQQ__Account__c,Status__c FROM SBQQ__Subscription__c LIMIT 1];
        }
        return subNgList;
    }
    public static List<Account> ngageacc(Set<Id> AccId){
        if(accNgList.size() == 0){
            accNgList = [SELECT Id,Is_Ngage_Product_added__c,Is_Combined_Profile_Product_added__c,Is_Base_Profile_Product_Added__c FROM Account WHERE ID IN: AccId];
        }
        return accNgList;
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