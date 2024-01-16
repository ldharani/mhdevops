/***************
 * Class Name: AvvoAttyStatusUpdate_cls
 * Test Class: Test_AvvoAttyStatusUpdate_cls
 * Description: This class updates the customer status and order status 
 * 				on the Avvo Atty accounts based on the Advertising status field.
 * Developed By: Ieswarya J
 * Modification History : Created on July 22,2020
 * 
 * 
 * ******/
public class AvvoAttyStatusUpdate_cls {
    public static boolean IsRecursive = false;
    public static boolean IsBatchprocess = false;
    /***Method Name: updateAvvoFirmAccounts
     * Description: method to populate the Avvo Atty Account customer status and Order status
     * ***/ 
    public static void UpdateAttyAccountStatus(list<Account> listofAcc){
        //get recordtypeId
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        list<Account> ListtoUpdate = new list<Account>();
        //populate the status fields in Avvo atty accounts
        for(Account Acc : [select Id,Advertising_Status__c,Customer_Status__c,Order_Status__c,Start_Restart_Date__c,Date_of_Full_Cancellation__c,MAX_Cancel_Date_of_Subscription__c from Account where Id in: listofAcc and Recordtypeid =:AvvoAttyRecordTypeId ]){
           system.debug(Acc.Id+'-@@@@@Advertising_Status__c='+Acc.Advertising_Status__c);
            if(Acc.Advertising_Status__c == 'Cancelled'){
                Acc.Customer_Status__c='Former Sub';
                Acc.Order_Status__c='Cancelled';
            }
            else if(Acc.Advertising_Status__c =='Backorder'){
                Acc.Customer_Status__c='New';
                Acc.Order_Status__c='Active';
            }
             else if(Acc.Advertising_Status__c =='Backorder/Cancelled'){
                Acc.Customer_Status__c='New';
                Acc.Order_Status__c='Active';
            }
            else if(Acc.Advertising_Status__c =='Active in AE Book' || Acc.Advertising_Status__c =='Ad Model Test' ||
					Acc.Advertising_Status__c =='New Claim' || Acc.Advertising_Status__c =='Prospect' || Acc.Advertising_Status__c =='Seek List Only' ||
					Acc.Advertising_Status__c =='Waitlist' || Acc.Advertising_Status__c =='Waitlist/Cancelled' ||
                   Acc.Advertising_Status__c =='Active Campaign'){
                       Acc.Customer_Status__c='Prospect';
                       Acc.Order_Status__c=null;
            }
            if(Acc.Advertising_Status__c=='Current' && Acc.Start_Restart_Date__c!=null && Acc.Start_Restart_Date__c.daysBetween(system.today())  >=30){
                Acc.Customer_Status__c='Existing';
             }
            else if(Acc.Advertising_Status__c=='Current' && (Acc.Start_Restart_Date__c==null || Acc.Start_Restart_Date__c.daysBetween(system.today())  <=30)){
                 Acc.Customer_Status__c='New';
            }
           if(Acc.Advertising_Status__c=='Current' && Acc.Date_of_Full_Cancellation__c !=null && 
               Acc.Date_of_Full_Cancellation__c.Month() == Date.Today().Month()){
                Acc.Order_Status__c='Expired';  
            } 
            else if(Acc.Advertising_Status__c=='Current'){
                 Acc.Order_Status__c='Active';
            }
            if(Acc.Advertising_Status__c== 'Not Callable' && Acc.MAX_Cancel_Date_of_Subscription__c!=null){
				Acc.Customer_Status__c='Former Sub';
                Acc.Order_Status__c='Cancelled';
            } 
            else if(Acc.Advertising_Status__c== 'Not Callable'){                
				Acc.Customer_Status__c='Non-Prospect';
                Acc.Order_Status__c=null;
             } system.debug('!!!!Cust-orderstatus'+Acc.Customer_Status__c+'--'+Acc.Order_Status__c);
            
            ListtoUpdate.add(Acc);
            
        }    IsRecursive = true;
        database.update(ListtoUpdate,false);
        
    }
    
    /***Method Name: updateAvvoFirmAccounts
     * Description: method to update the Parent Account customer status and Order status
     * ***/ 
    public static void updateAvvoFirmAccounts(list<Account> listofAcc){
         //get recordtypeId
        Id AvvoFirmRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        
        map<Id,list<Account>> mapofparentToChildAccount = new map<Id,list<Account>>();
        list<Account> UpdateParentAccList = new list<Account>();
        
        set<Id> SetofParentId = new set<Id>();
        map<Id,Account> mapofParentAccount = new map<Id,Account>();
        
        for(Account acc: [select Id,ParentId,Avvo_customer_Status__c,Customer_Status__c,Order_Status__c,Avvo_Order_Status__c from Account where Id in:listofAcc and RecordtypeId =:AvvoFirmRecordTypeId ]){
                SetofParentId.add(acc.Id);
                acc.Avvo_customer_Status__c=null;
                acc.Avvo_Order_Status__c=null;
                mapofParentAccount.put(acc.Id,acc);
        }     
        
       
        for(Account acc:[select Id,ParentId,Customer_Status__c,Order_Status__c from Account where ParentId in: SetofParentId and RecordtypeId =:AvvoAttyRecordTypeId]){
             Account newAcc;
            if(mapofParentAccount.containskey(acc.parentId)) {
               newAcc= mapofParentAccount.get(acc.parentId);
               
              //update Customer status field
                    if(acc.Customer_Status__c == 'Existing') {
                        newAcc.Avvo_customer_Status__c = 'Existing';
                    } else if(acc.Customer_Status__c == 'New' && newAcc.Avvo_customer_Status__c!='Existing') {
                        newAcc.Avvo_customer_Status__c = 'New';
                        
                    } else if(acc.Customer_Status__c == 'Former Sub' && newAcc.Avvo_customer_Status__c!='New' && newAcc.Avvo_customer_Status__c!='Existing') {
                        newAcc.Avvo_customer_Status__c = 'Former Sub';
                       
                    } else if(acc.Customer_Status__c == 'Prospect' && newAcc.Avvo_customer_Status__c!='New' && newAcc.Avvo_customer_Status__c!='Existing' && newAcc.Avvo_customer_Status__c!='Former Sub'){
                        newAcc.Avvo_customer_Status__c = 'Prospect';
                       
                    }else if(acc.Customer_Status__c == 'Non-Prospect' && newAcc.Avvo_customer_Status__c!='New' && newAcc.Avvo_customer_Status__c!='Existing' && newAcc.Avvo_customer_Status__c!='Former Sub' && newAcc.Avvo_customer_Status__c!='Prospect'){
                        newAcc.Avvo_customer_Status__c = 'Non-Prospect';
                    }
            
            //update order status field
                   if(acc.Order_Status__c == 'Active') {
                        newAcc.Avvo_order_Status__c = 'Active';
                    } else if(acc.Order_Status__c == 'Cancelled' && newAcc.Avvo_order_Status__c!='Active') {
                        newAcc.Avvo_order_Status__c = 'Cancelled';
                    } else if(acc.Order_Status__c == 'Expired' && newAcc.Avvo_order_Status__c!='Active' && newAcc.Avvo_order_Status__c!='Cancelled') {
                        newAcc.Avvo_order_Status__c = 'Expired';
                    } 
            /*system.debug('#####acc.Order_Status__c'+acc.Order_Status__c);
             system.debug('#####acc.Customer_Status__c'+acc.Customer_Status__c);
             system.debug('#####newAcc.Avvo_order_Status__c'+newAcc.Avvo_order_Status__c);
             system.debug('#####newAcc.Avvo_customer_Status__c'+newAcc.Avvo_customer_Status__c);
            system.debug('#####newAcc.Id'+newAcc.Id);*/
           
            mapofParentAccount.put(newAcc.Id,newAcc);              
               
            }     
        }   
          //update the IB parent account field        
           List<Account> IBAccountList = new list<Account>();
        for(Account FirmAcc: mapofParentAccount.values() ){
            Account NewIBAcc = new Account(Id=FirmAcc.ParentId);
            NewIBAcc.Avvo_customer_Status__c = FirmAcc.Avvo_customer_Status__c;
            NewIBAcc.Avvo_order_Status__c = FirmAcc.Avvo_order_Status__c;
            IBAccountList.add(NewIBAcc);
            
        } if(!mapofParentAccount.isempty()){
            Database.Update(mapofParentAccount.values(),false);
            Database.update(IBAccountList,false);
        }    
    }
    
    
}