public class PaymentMethod_UtilityClass {
    Public Static List<blng__PaymentMethod__c> payRecList = new List<blng__PaymentMethod__c>();
    Public Static List<Account> accList = new List<Account>();
    Public Static List<Contract> contractList = new List<Contract>();
    Public Static List<Contact> conList = new List<Contact>();
    Public Static List<User> userList = new List<User>();
    
    public static List<blng__PaymentMethod__c> updatePMOrderStatusOnAccountMeth(Set<Id> accId){
        if(payRecList.size() == 0){
            payRecList = [SELECT Id,blng__PaymentType__c,blng__Active__c,blng__BillingEmail__c,blng__AutoPay__c,blng__Account__c,blng__Account__r.Order_Status__c FROM blng__PaymentMethod__c WHERE blng__Account__c IN: accId];
        }
        return payRecList; 
    }
    public static List<Account> updatePMOrderStatusOnAccountPAYmeth(Set<Id> accId){
        if(accList.size() == 0){
            accList = [SELECT Id,Order_Status__c,Collector__c FROM Account WHERE Id IN: accId];
        }
        return accList; 
    }
    public static List<Contract> updatePMBillingEmailMeth(Set<Id> accId){
        if(contractList.size() == 0){
            contractList = [SELECT Id,CreatedDate,AccountId,Bill_To_Contact__c FROM Contract WHERE AccountId IN: accId ORDER BY CreatedDate DESC LIMIT 1];
        }
        return contractList; 
    }
    public static List<Contact> updatePMBillingEmailMethAA(Set<Id> conId){
        if(conList.size() == 0){
            conList = [SELECT Id,Email FROM Contact WHERE Id IN: conId];
        }
        return conList; 
    }
    public static List<User> userListsMeth(Set<Id> UserId){
        if(userList.size() == 0){
            userList = [SELECT Id,Email FROM User WHERE Id IN: UserId];
        }
        return userList; 
    }
}