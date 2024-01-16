/*Class Name : orderStatusHandlingOnAccount
*Modification History**************************************/////
/*Modified By: Ieswarya     on July 24,2020         for MHBS-3913    Tagged as T1 **/

public class orderStatusHandlingOnAccount {
    
    public static boolean recursionOrderstatusHandlOnaccount = true;
    public static boolean zipcodeupdateRecursion = true;
     
    //added by sai ravulapati for zip code update - start - updated 1/13/17 
    public static void zipCodeUpdate(list<account> acclist){
    
        map<string,id> zipcodes=new map<string,id>();
        map<string,string> zipcodeMap = new map<String,string>();
        Id mnAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        for(Account acc: acclist){
            
            if( acc.BillingPostalCode != null && acc.BillingPostalCode != '')
                zipcodeMap.put(acc.BillingPostalCode, acc.BillingPostalCode.split('-')[0]);
        }

        for(GEO_Location__c zipcode:[select zipcode__c from GEO_Location__c where zipcode__c in:zipcodeMap.values() AND RecordType.DeveloperName = 'M_N_GEO_Locations']){
            zipcodes.put(zipcode.zipcode__c,zipcode.id);
            
        }
        for(Account acc: acclist){
            if(acc.recordTypeId == mnAccRecordTypeId  && acc.BillingPostalCode!=null && acc.BillingPostalCode!='' && zipcodeMap.containskey(acc.BillingPostalCode)){
                    acc.Zipcode__c= zipcodes.get(zipcodeMap.get(acc.BillingPostalCode));
            }else{
                acc.Zipcode__c = null;
            }
        }
    }
    //added by sai ravulapati for zip code update - end - updated 1/13/17
    public static void orderStatusHandlingForAccont(list<account> acclist, map<id,account>oldmap, map<id,account>newmap){
        
        system.debug('@@@@in orderStatusHandlingForAccont');
        list<account> acclisttoUpdate = new list<account>();
        
        Set<Id> accidstoActive        = new Set<Id>();
        //T1
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
           system.debug('AvvoAttyRecordTypeId'+AvvoAttyRecordTypeId);   
       for(account singleacc : acclist){
            system.debug('@@@singleacc.Order_Status__c' + singleacc.Order_Status__c);
            system.debug('@@@oldmap.get(singleacc.id).Order_Status__cc' + oldmap.get(singleacc.id).Order_Status__c);
            system.debug('@@@newmap.get(singleacc.id).Order_Status__c' + newmap.get(singleacc.id).Order_Status__c);
           //T1
           system.debug('singleacc.RecordtypeId'+singleacc.RecordtypeId);
           if(singleacc.RecordtypeId!= AvvoAttyRecordTypeId){
            if(oldmap.get(singleacc.id).Order_Status__c != newmap.get(singleacc.id).Order_Status__c &&
               (newmap.get(singleacc.id).Order_Status__c == 'Cancelled' || newmap.get(singleacc.id).Order_Status__c == 'Expired')
                 &&  (oldmap.get(singleacc.id).Order_Status__c == 'Active'|| oldmap.get(singleacc.id).Order_Status__c == 'Evergreen')){
                     
                   
                     
                   Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month()-1);
                   Date lastDayOfMonth = Date.newInstance(date.today().year(), date.today().month()-1, numberOfDays);
                   System.debug('===============singleacc.Customer_Status__c=============='+singleacc.Customer_Status__c);
                     
                   singleacc.Customer_Status__c = 'Former Sub';
                   singleacc.Loss_Date__c = lastDayOfMonth;
                   singleacc.LossDate_Check__c = False;
                   singleacc.Re_acquisition_date__c = NULL;
                   acclisttoUpdate.add(singleacc);
               }
            
            else if(oldmap.get(singleacc.id).Order_Status__c != newmap.get(singleacc.id).Order_Status__c &&
                       newmap.get(singleacc.id).Order_Status__c == 'Active' 
                         && (oldmap.get(singleacc.id).Order_Status__c == 'Cancelled' || oldmap.get(singleacc.id).Order_Status__c == 'Expired')){
                             
                             //accids for which inactive to active  
                            accidstoActive.add(singleacc.id);  
                           //Date firstDayOfNextMonth = Date.today().addMonths(1).toStartOfMonth();
                           singleacc.Re_acquisition_date__c = Date.today();
                           singleacc.LossDate_Check__c = True;
                           /*if(singleacc.Loss_Date__c != null){
                               if(singleacc.Re_acquisition_date__c.year() != singleacc.Loss_Date__c.year()){
                               singleacc.Customer_Status__c = 'NEW';
                               singleacc.Win_back__c = false;
                                }
                               else if(singleacc.Re_acquisition_date__c.year() == singleacc.Loss_Date__c.year()){
                                   singleacc.Customer_Status__c = 'EXISTING';
                                   singleacc.Win_back__c = true;
                               }
                           }*/
                           
                             if(singleacc.Loss_Date__c != null && singleacc.Re_acquisition_date__c != null){
                                 if(singleacc.Loss_Date__c.year() == singleacc.Re_acquisition_date__c.year()){
                                        singleacc.Customer_Status__c = 'Existing';
                                        system.debug('check1');
                                        //singleacc.Win_back__c = false;
                                 }
                                 else if(singleacc.Re_acquisition_date__c.year() > singleacc.Loss_Date__c.year()){
                                             singleacc.Customer_Status__c = 'New';
                                             system.debug('check2');
                                            //singleacc.Win_back__c = true;
                                 }
                                 else if( Math.abs(Integer.valueOf(singleacc.Loss_Date__c.year() - singleacc.Re_acquisition_date__c.year())) >=0){
                                     singleacc.Customer_Status__c = 'New';
                                     system.debug('check3');
                                     //singleacc.Win_back__c = true;
                                 }
                                 else if(Math.abs(Integer.valueOf(singleacc.Loss_Date__c.year()-singleacc.Re_acquisition_date__c.year())) ==0){
                                     singleacc.Customer_Status__c = 'Existing';
                                     system.debug('check4');
                                     //singleacc.Win_back__c = true; 
                                 }
                                 
                             }
                             singleacc.Loss_Date__c = NULL;
                           orderStatusHandlingOnAccount.recursionOrderstatusHandlOnaccount =false;
            
                          
               }
           }
        }
        
        if(!accidstoActive.isEmpty()){
            updatingaccountFieldsOrderStatusActive(accidstoActive,newmap);
        }
        
        
        try{
            //update acclisttoUpdate;
        }
        catch(exception e){
            system.debug('@@@exception' + e);
        }
        
    }
    
    
    public static void updatingaccountFieldsOrderStatusActive(Set<Id>accidstoActive, map<id,account> newmap){
        
        //account RecordTypeIds to Update
        //uncommented after taking BU chanegs out
        Id RecordTypeId_accountMDL = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_JV_Account).getRecordTypeId();
        Id RecordTypeId_accountNolo = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Account).getRecordTypeId();
        //Id RecordTypeId_accountMDL = Schema.SObjectType.Account.getRecordTypeInfosByName().get('MDL Accounts').getRecordTypeId();
        //Id RecordTypeId_accountNolo = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Nolo Account').getRecordTypeId();

        List<Account> acclistActive = [Select id, Name, Order_Status__c,
                                           Acquisition_date__c, Customer_Status__c,
                                           Loss_Date__c, Re_acquisition_date__c,LossDate_Check__c,
                                            Win_back__c, Organization_Type__c,RecordType.DeveloperName,
                                           MH_Cust_Number__c,
                                           (select Id,RecordType.DeveloperName from Opportunities 
                                                      where StageName='Closed Won' AND (RecordType.DeveloperName = 'MH_Opportunity' OR RecordType.DeveloperName = 'Nolo_Opportunity')
                                                      order by LastModifiedDate DESC LIMIT 1)
                                                 from account 
                                                   where id IN:(accidstoActive) AND (RecordType.DeveloperName = 'Nolo_Account' OR RecordType.DeveloperName = 'MH_Accounts')];
        for(account acc: acclistActive){
            if(acc.opportunities.size() > 0 ){
                if(acc.Opportunities[0].RecordType.DeveloperName == 'MH_Opportunity'){
                    newmap.get(acc.id).RecordTypeId = RecordTypeId_accountMDL;
                    newmap.get(acc.id).Billing_Schedule__c = 'Arrears';
                    newmap.get(acc.id).Dunning_Hold__c = FALSE;
                    newmap.get(acc.id).Hold_dunning_letter_till__c= null;
                    if(newmap.get(acc.id).Legal_Entity__c != null && newmap.get(acc.id).Legal_Entity__c.contains('Non-Taxable')){
                        newmap.get(acc.id).Legal_Entity__c = 'JV Non-Taxable';
                    }    
                    else{
                       newmap.get(acc.id).Legal_Entity__c = 'JV Taxable'; 
                    }
                

                    newmap.get(acc.id).invoiceit_s__Invoice_Delivery_Type__c = 'Print';
                    newmap.get(acc.id).invoiceit_s__Gateway__c = null;
                    //newmap.get(acc.id).invoiceit_s__Payment_Terms__c = 'Net 30';
                }
                else{
                    newmap.get(acc.id).RecordTypeId = RecordTypeId_accountNolo;
                    newmap.get(acc.id).Billing_Schedule__c  = 'Advanced';
                    if(newmap.get(acc.id).Legal_Entity__c != null && newmap.get(acc.id).Legal_Entity__c.contains('Non-Taxable')){
                        newmap.get(acc.id).Legal_Entity__c = 'M-H Non-Taxable';
                    }    
                    else{
                        newmap.get(acc.id).Legal_Entity__c = 'M-H Taxable'; 
                    }
                    //newmap.get(acc.id).Legal_Entity__c = 'M-H Taxable';
                    newmap.get(acc.id).invoiceit_s__Invoice_Delivery_Type__c = 'Email'; //updated by saiv MHBS-4000
                    //newmap.get(acc.id).invoiceit_s__Payment_Terms__c = 'Net 10';
                     newmap.get(acc.id).invoiceit_s__Gateway__c = system.Label.Nolo_Test_Gateway;
                 
                }
            }
            
            
            
        }
    }
    
    public static void lossdateinactive(list<account> acclistold, map<id, account> newmap){
        for(account acc: acclistold){
            if(acc.Order_Status__c == 'InActive' && acc.Loss_Date__c == null){
                   Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month()-1);
                   Date lastDayOfMonth = Date.newInstance(date.today().year(), date.today().month()-1, numberOfDays);
                   newmap.get(acc.id).Loss_Date__c = lastDayOfMonth;
                   newmap.get(acc.id).Customer_Status__c = 'Former Sub';
                   //acc.Loss_Date__c = lastDayOfMonth;
            }
        }
    }

}