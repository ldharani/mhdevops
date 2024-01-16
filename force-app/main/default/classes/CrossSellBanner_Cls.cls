/***************
* Class Name: CrossSellBanner_Cls
* Test Class: Test_CrossSellBanner_Cls
* Description: This class displays the order status in the Account page.
* Developed By: Ieswarya J
* Modification History : Created on July 27,2020
* 
* 
* *****
* Change History
************************************************************************************************************************
Jira       ModifiedBy    Date         Requested By    Tag     Description
MHBS-7530  Sachin        10/1/2023                    T01     Avvo Attorney account and firm account not updating the BU Icon as expected

************************************************************************************************************************/
public with sharing class CrossSellBanner_Cls {
    public String AccId; 
    public string ParentAccId;
    public string AvvoFirmId;
    public string MH_OrdStatus{get;set;}
    public string Avvo_OrdStatus{get;set;}
    public string Nolo_OrdStatus{get;set;}
    public string Ngage_OrdStatus{get;set;}
    public string Capt_OrdStatus{get;set;}
    public Boolean IsEngageAdded{get;set;}
    public Boolean IsMainAcc;
    public Boolean IsAttyAcc;
    Account MainAccount;
    Map<String,String> MapofRecTypeToOrderStatus;
    
    
    public CrossSellBanner_Cls(ApexPages.StandardController controller) {            
        AccId = ApexPages.currentPage().getParameters().get('id');
        String EngageAdded = '';
        IsAttyAcc = false;
        IsMainAcc= false;
        MapofRecTypeToOrderStatus = new map<string,string>();
        // <T01>
        Account ObjAcc = [select Id,ParentId,Active_Account_Binary__c,CancelledAccountBinary__c,Recordtype.developername,Recordtype.name,Is_Ngage_Product_added__c,Order_status__c,customer_status__c from Account where Id =:AccId];
        system.debug('@@@'+ObjAcc.Id);
        if(ObjAcc.Is_Ngage_Product_added__c && ObjAcc.Recordtype.developername=='Nolo_Account'){
            EngageAdded = ' (MH-Ngage)';
        }
        if(ObjAcc.Recordtype.name == 'IB Accounts'){
            IsMainAcc=true;
            ParentAccId =ObjAcc.Id;
            system.debug('Condition1');
        }else if(ObjAcc.Recordtype.developername == 'M_A_Atty_Account'){
            // <T01>
            Map<Id,Id> accIdParentIdMap = new Map<Id,Id>();
            
            if(ObjAcc.Active_Account_Binary__c == 1){
                MapofRecTypeToOrderStatus.put(ObjAcc.Recordtype.developername,'Active'); 
            }
            if(ObjAcc.Active_Account_Binary__c == 0 && ObjAcc.CancelledAccountBinary__c == 1){
                MapofRecTypeToOrderStatus.put(ObjAcc.Recordtype.developername,'Cancelled'); 
            }
            accIdParentIdMap.put(ObjAcc.Id,ObjAcc.ParentId);
            if(accIdParentIdMap.containsKey(ObjAcc.Id)){ 
                ParentAccId = [select Id,Parent.ParentId from Account where Id =:AccId and ParentId!=null and Parent.ParentId!=null].Parent.ParentId;
            }
            IsAttyAcc = true;
            system.debug('Condition2');
        }
        else{
            ParentAccId=ObjAcc.ParentId;
            system.debug('Condition3');
        }
        System.debug('yggwgfew ' + ParentAccId);
        if(ParentAccId !=null){
            for(Account Acc : [select Id,Recordtype.developername, Avvo_Order_Status__c ,Avvo_Customer_Status__c,ParentId,Order_Status__c,Is_Ngage_Product_added__c,customer_status__c from Account where ParentId = :ParentAccId]){                
                system.debug('Condition3aa ' + Acc.Recordtype.developername); 
                if(Acc.Recordtype.developername=='Nolo_Account' && Acc.Is_Ngage_Product_added__c == true){
                    system.debug('Condition3assa ' + Acc.Recordtype.developername); 
                    if(Acc.Order_Status__c!=null){ 
                        MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.Order_Status__c); 
                        EngageAdded = ' (MH-Ngage)';
                    }else if(Acc.customer_status__c!=null){
                        MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.customer_status__c); 
                    }else{
                        MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,'Prospect');
                    }
                }else if(Acc.Recordtype.developername!='M_A_Firm_Account'){
                    system.debug('Condition3aaaadda ' + Acc.Recordtype.developername); 
                    if(Acc.Order_Status__c!=null){
                        system.debug('sfsdagdsagsfgas ' + Acc.Recordtype.developername + Acc.Order_Status__c); 
                        MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.Order_Status__c); 
                    }
                    else if(Acc.Customer_Status__c!=null){
                        MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.Customer_Status__c); 
                    }else{
                        MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,'Prospect');
                    }
                }
                else if(Acc.Recordtype.developername=='M_A_Firm_Account'){
                    if(Acc.Avvo_Order_Status__c!=null){
                        MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.Avvo_Order_Status__c); 
                    }
                    else{
                        MapofRecTypeToOrderStatus.put(Acc.Recordtype.developername,Acc.Avvo_Customer_Status__c); 
                    }
                }
            }}
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
        System.debug(MapofRecTypeToOrderStatus.containskey('Nolo_Account'));
        System.debug(MapofRecTypeToOrderStatus.get('Nolo_Account'));
        System.debug(EngageAdded);
        if(MapofRecTypeToOrderStatus.containskey('Nolo_Account')){         
            MH_OrdStatus=(MapofRecTypeToOrderStatus.get('Nolo_Account'))+EngageAdded;
            System.debug('sggfgafdg' + MH_OrdStatus);
        }else
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