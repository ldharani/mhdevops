/***************
 * Class Name: AvvoContactCrossBanner_Cls
 * Test Class: Test_CrossSellBanner_Cls
 * Description: This class displays the order status in the Account page.
 * Developed By: Ieswarya J
 * Modification History : Created on July 27,2020
 * 
 * 
 * ******/
public with sharing class AvvoContactCrossBanner_Cls {
    public String RecId; 
    public String AccId; 
    public string ParentAccId;
    public string AvvoFirmId;
    public string MH_OrdStatus{get;set;}
    public string Avvo_OrdStatus{get;set;}
    public string Nolo_OrdStatus{get;set;}
    public string Ngage_OrdStatus{get;set;}
    public string Capt_OrdStatus{get;set;}
    public Boolean IsMainAcc;
    public Boolean IsAttyAcc;
    Account MainAccount;
    Map<String,String> MapofRecTypeToOrderStatus;
    
    
    public AvvoContactCrossBanner_Cls(ApexPages.StandardController controller) {            
        RecId = ApexPages.currentPage().getParameters().get('id');
        IsAttyAcc = false;
        IsMainAcc= false;
        MapofRecTypeToOrderStatus = new map<string,string>();
        Contact Con = [select Id,AccountId,Related_To_Account__c from contact where Id=:RecId];
        if(Con.Related_To_Account__c!=null){
           AccId = Con.Related_To_Account__c;
         }else{
           AccId = Con.AccountId;
           }
        Account ObjAcc = [select Id,ParentId,Recordtype.developername,Recordtype.name,Order_status__c,customer_status__c from Account where Id =:AccId];
        system.debug('@@@'+ObjAcc.Id);
        if(ObjAcc.Recordtype.name == 'IB Accounts'){
            IsMainAcc=true;
            ParentAccId =ObjAcc.Id;
            system.debug('Condition1');
        }else if(ObjAcc.Recordtype.developername == 'M_A_Atty_Account'){
               if(ObjAcc.Order_Status__c!=null){
                   MapofRecTypeToOrderStatus.put(ObjAcc.Recordtype.developername,ObjAcc.Order_Status__c); 
               }
                else{
                    MapofRecTypeToOrderStatus.put(ObjAcc.Recordtype.developername,ObjAcc.customer_status__c); 
                }
            ParentAccId = [select Id,Parent.ParentId from Account where Id =:AccId].Parent.ParentId;
            IsAttyAcc = true;
            system.debug('Condition2');
        }
        else{
            ParentAccId=ObjAcc.ParentId;
            system.debug('Condition3');
        }
        
            for(Account Acc : [select Id,Recordtype.developername,ParentId,Order_Status__c,Avvo_order_status__c,customer_status__c,avvo_customer_status__c from Account where ParentId = :ParentAccId]){                
                if(Acc.Recordtype.developername!='M_A_Firm_Account'){
                    if(Acc.Order_Status__c!=null){
                    MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.Order_Status__c); 
                    }
                    else if(Acc.customer_status__c!=null){
                    MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.customer_status__c); 
                    }else{
                     MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,'Prospect');
                    }
                }
                else if(Acc.Recordtype.developername=='M_A_Firm_Account'){
                    if(Acc.Avvo_Order_Status__c!=null){
                    MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.Avvo_Order_Status__c); 
                    }
                    else{
                    MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.avvo_customer_status__c); 
                    }
                }
           }
        
        if(IsAttyAcc){
            if(MapofRecTypeToOrderStatus.containskey('M_A_Atty_Account')){
            Avvo_OrdStatus=MapofRecTypeToOrderStatus.get('M_A_Atty_Account');
            }else{
                Avvo_OrdStatus = 'No Account';}
        } else   {   
            if(MapofRecTypeToOrderStatus.containskey('M_A_Firm_Account')){
            Avvo_OrdStatus=MapofRecTypeToOrderStatus.get('M_A_Firm_Account');
            } else{
            Avvo_OrdStatus = 'No Account';
            }
            }
        if(MapofRecTypeToOrderStatus.containskey('Nolo_Account'))
            MH_OrdStatus=MapofRecTypeToOrderStatus.get('Nolo_Account');
        else
            MH_OrdStatus = 'No Account';
        if(MapofRecTypeToOrderStatus.containskey('M_N_Account'))
            Nolo_OrdStatus=MapofRecTypeToOrderStatus.get('M_N_Account');
        else
            Nolo_OrdStatus = 'No Account';
        if(MapofRecTypeToOrderStatus.containskey('M_NG_Account'))
            Ngage_OrdStatus=MapofRecTypeToOrderStatus.get('M_NG_Account');
        else
            Ngage_OrdStatus = 'No Account';
        if(MapofRecTypeToOrderStatus.containskey('Captorra_Account'))
            Capt_OrdStatus=MapofRecTypeToOrderStatus.get('Captorra_Account');
        else
            Capt_OrdStatus = 'No Account';       
        
    }

}