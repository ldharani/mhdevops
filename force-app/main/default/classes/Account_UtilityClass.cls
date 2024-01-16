/**
@@*
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-9435    Bharath     16/08/2023     John Mattheson  T01     MN Order Status/Customer status badge issues
*************************************************************************************************************************/
public class Account_UtilityClass {
    Public Static List<Group> groupList = new List<Group>();
    Public Static List<Account> accList = new List<Account>();
    Public Static List<Contract> contractList = new List<Contract>();
    
    public static List<Group> OrderProductCaseCreationGroup(){
        if(groupList.size() == 0){
            groupList = [SELECT Id FROM Group WHERE Name = 'Onboarding' AND Type = 'Queue'];
        }
        return groupList; 
    }
    public static List<Account> AccountOrderStatusLogic(Set<Id> accIdAA){
        if(accList.size() == 0){
            accList = [SELECT ID,Loss_Date__c,Re_acquisition_date__c,Acquisition_date__c,Customer_Status__c,Order_Status__c  FROM Account WHERE ID IN: accIdAA FOR UPDATE]; //<T01>
        }
        return accList; 
    }
    public static List<Contract> AccountOrderStatusLogicAA(Set<Id> accId){
        if(contractList.size() == 0){
            contractList = [Select Id,Status__c,AccountId,SBQQ__Evergreen__c,Cancelled__c FROM Contract WHERE AccountId IN: accId];
        }
        return contractList; 
    }
}