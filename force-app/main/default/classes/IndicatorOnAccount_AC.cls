/***************
* Class Name: IndicatorOnAccount_AC
* Test Class: 
* Description: This class displays the order status in the Account page.
* Developed By: Jey
* 
*  
* ******/
public with sharing class IndicatorOnAccount_AC {
    public String AccId; 
    public string ParentAccId;
    public string MH_OrdStatus{get;set;}
    public string Co_OrdStatus{get;set;}
    public string BP_OrdStatus{get;set;}
    
    public IndicatorOnAccount_AC(ApexPages.StandardController controller) {            
        AccId = ApexPages.currentPage().getParameters().get('id');
        
        for(Account Acc : [SELECT Id,Recordtype.developername,Is_Ngage_Product_added__c,Is_Combined_Profile_Product_added__c,Is_Base_Profile_Product_Added__c FROM Account WHERE Id =:AccId]){                
            if(Acc.Recordtype.developername=='Nolo_Account' && Acc.Is_Ngage_Product_added__c == true){
                MH_OrdStatus = 'Active'; 
            }else{
                MH_OrdStatus = 'No Product';
            }
            if(Acc.Recordtype.developername=='Nolo_Account' && Acc.Is_Combined_Profile_Product_added__c == true){
                Co_OrdStatus = 'Active'; 
            }else{
                Co_OrdStatus = 'No Product';
            }
            if(Acc.Recordtype.developername=='Nolo_Account' && Acc.Is_Base_Profile_Product_Added__c == true){
                BP_OrdStatus = 'Active'; 
            }else{
                BP_OrdStatus = 'No Product';
            }
        } 
    }
}