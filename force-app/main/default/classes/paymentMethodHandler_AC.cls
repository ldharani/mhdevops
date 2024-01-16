/***********************************************************************************************************************
 * @author -
 * @date - 
 * @description - Payment method Trigger Handler
 * @testclass - paymentMethodHandler_Test

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6098    VR            24/01/2022                           updateBankNameOnPayment()
************************************************************************************************************************/

public class paymentMethodHandler_AC { 
    public static Boolean paymentMethodHandlerFirstTime = true;
    // Update PM OrderStatusonaccount
    public static void updatePMOrderStatusOnAccount(Map<Id,Account> accNewMap, Map<Id,Account> accOldMap){
        List<blng__PaymentMethod__c> payRec = new List<blng__PaymentMethod__c>();
        Set<Id> accId = new Set<Id>();
        for(Account acc: accNewMap.Values()){
            //additional check
            /*system.debug('accoldmap==='+accOldMap);
            system.debug('accOldMap.containsKey(acc.Id)==='+acc.id);
            system.debug('accNewMap.get(acc.Id).Order_Status__c==='+accNewMap.get(acc.Id).Order_Status__c);
            //system.debug('accOldMap.get(acc.Id).Order_Status__c==='+accOldMap.get(acc.Id).Order_Status__c);
            system.debug('accNewMap.get(acc.Id).Order_Status__c   Last'+accNewMap.get(acc.Id).Order_Status__c);*/
            
            if(accOldMap != null &&  accOldMap.containsKey(acc.Id) &&accNewMap.get(acc.Id).Order_Status__c != accOldMap.get(acc.Id).Order_Status__c && accNewMap.get(acc.Id).Order_Status__c != Null){
                accId.add(acc.Id);
            }
        }
        if(accId.size() > 0){
            for(blng__PaymentMethod__c payMed : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountMeth(accId)){
                if(payMed.blng__PaymentType__c == 'Credit Card' && payMed.blng__Active__c == True && payMed.blng__AutoPay__c == True){
                    payMed.Order_Status_on_Account__c = payMed.blng__Account__r.Order_Status__c;
                    payRec.add(payMed);
                }
            }
        }
        if(payRec.size()>0){
            Update payRec;
        }
    }
    
    public static void updatePMOrderStatusOnAccountPAY(List<blng__PaymentMethod__c> payNewMap){
        List<blng__PaymentMethod__c> payRec = new List<blng__PaymentMethod__c>();
        Set<Id> accId = new Set<Id>();
        for(blng__PaymentMethod__c payMed : payNewMap){
            if(payMed.blng__Account__c != Null && payMed.blng__PaymentType__c == 'Credit Card' && payMed.blng__Active__c == True && payMed.blng__AutoPay__c == True){
                accId.add(payMed.blng__Account__c); 
            }
        }
        if(accId.size() > 0){
            Map<Id,Account> acc = new Map<Id,Account>();
            for(Account accM : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountPAYmeth(accId)){
                acc.put(accM.Id,accM);
            }
            for(blng__PaymentMethod__c payMedA : payNewMap){
                if(acc.containsKey(payMedA.blng__Account__c)){
                    payMedA.Order_Status_on_Account__c = acc.get(payMedA.blng__Account__c).Order_Status__c;
                }
            }
        }
    }
    //Update Billing Email on Payment Method
    public static void updatePMBillingEmail(List<blng__PaymentMethod__c> payNewMap){
        List<blng__PaymentMethod__c> payRec = new List<blng__PaymentMethod__c>();
        Set<Id> accId = new Set<Id>();
        for(blng__PaymentMethod__c payMed : payNewMap){
            if(payMed.blng__Account__c != Null && payMed.blng__PaymentType__c == 'Credit Card' && payMed.blng__Active__c == True && payMed.blng__AutoPay__c == True){
                accId.add(payMed.blng__Account__c); 
            }
        }
        Set<Id> conId = new Set<Id>();
        if(accId.size() > 0){
            for(Contract cont : PaymentMethod_UtilityClass.updatePMBillingEmailMeth(accId)){
                if(cont.Bill_To_Contact__c != Null){
                    conId.add(cont.Bill_To_Contact__c);
                }
            }
        }
        String conEmail;
        if(conId.size() > 0){
            for(Contact conRec: PaymentMethod_UtilityClass.updatePMBillingEmailMethAA(conId)){
                if(conRec.Email != Null){
                    conEmail = conRec.Email;
                }
            }
        }
        if(accId.size() > 0){
            Map<Id,Account> acc = new Map<Id,Account>();
            for(Account accM : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountPAYmeth(accId)){
                acc.put(accM.Id,accM);
            }
            for(blng__PaymentMethod__c payMedA : payNewMap){
                if(acc.containsKey(payMedA.blng__Account__c)){
                    // payMedA.blng__BillingEmail__c = conEmail;
                }
            }  
        }
    }
    
    public static void updatePMBillingEmailPAY(List<Contract> con){
        List<blng__PaymentMethod__c> payRec = new List<blng__PaymentMethod__c>();
        Set<Id> accId = new Set<Id>();
        Set<Id> conId = new Set<Id>();
        for(Contract conRec : con){
            if(conRec.AccountId != Null){
                accId.add(conRec.AccountId); 
            }
            if(conRec.Bill_To_Contact__c != Null){
                conId.add(conRec.Bill_To_Contact__c); 
            }
        }
        String conEmail;
        if(conId.size() > 0){
            for(Contact conRec: PaymentMethod_UtilityClass.updatePMBillingEmailMethAA(conId)){
                if(conRec.Email != Null){
                    conEmail = conRec.Email;
                }
            }
        }
        if(accId.size() > 0){
            for(blng__PaymentMethod__c PMrec : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountMeth(accId)){
                if(PMrec.blng__PaymentType__c == 'Credit Card' && PMrec.blng__Active__c == True && PMrec.blng__AutoPay__c == True){
                    // PMrec.blng__BillingEmail__c = conEmail;
                    payRec.add(PMrec);
                }
            } 
        }
        if(payRec.size()>0){
            Update payRec;
        }
    }
    //Update Collector Email Address on Payment Method
    public static void updatePMCollectorEmail(List<blng__PaymentMethod__c> payNewMap){
        List<blng__PaymentMethod__c> payRec = new List<blng__PaymentMethod__c>();
        Set<Id> accId = new Set<Id>();
        for(blng__PaymentMethod__c payMed : payNewMap){
            if(payMed.blng__Account__c != Null && payMed.blng__PaymentType__c == 'Credit Card' && payMed.blng__Active__c == True && payMed.blng__AutoPay__c == True){
                accId.add(payMed.blng__Account__c); 
            }
        }
        Set<Id> UserId = new Set<Id>();
        if(accId.size() > 0){
            for(Account accRec : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountPAYmeth(accId)){
                if(accRec.Collector__c != Null){
                    UserId.add(accRec.Collector__c);
                }
            }
        }
        String userEmail;
        if(UserId.size() > 0){
            for(User userRec: PaymentMethod_UtilityClass.userListsMeth(UserId)){
                if(userRec.Email != Null){
                    userEmail = userRec.Email;
                }
            }
        }
        if(accId.size() > 0){
            Map<Id,Account> acc = new Map<Id,Account>();
            for(Account accM : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountPAYmeth(accId)){
                acc.put(accM.Id,accM);
            }
            for(blng__PaymentMethod__c payMedA : payNewMap){
                if(acc.containsKey(payMedA.blng__Account__c)){
                    payMedA.Collector_Email_Address__c = userEmail;
                }
            }  
        }
    }
    public static void updatePMCollectorEmailPAY(Map<Id,Account> accNewMap, Map<Id,Account> accOldMap){
        List<blng__PaymentMethod__c> payRec = new List<blng__PaymentMethod__c>();
        Set<Id> accId = new Set<Id>();
        for(Account acc: accNewMap.Values()){
            if(accNewMap.get(acc.Id).Collector__c != accOldMap.get(acc.Id).Collector__c && accNewMap.get(acc.Id).Collector__c != Null){
                accId.add(acc.Id);
            }
        }
        Set<Id> UserId = new Set<Id>();
        if(accId.size() > 0){
            for(Account accRec : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountPAYmeth(accId)){
                if(accRec.Collector__c != Null){
                    UserId.add(accRec.Collector__c);
                }
            }
        }
        String userEmail;
        if(UserId.size() > 0){
            for(User userRec: PaymentMethod_UtilityClass.userListsMeth(UserId)){
                if(userRec.Email != Null){
                    userEmail = userRec.Email;
                }
            }
        }
        if(accId.size() > 0){
            for(blng__PaymentMethod__c payMed : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountMeth(accId)){
                if(payMed.blng__PaymentType__c == 'Credit Card' && payMed.blng__Active__c == True && payMed.blng__AutoPay__c == True){
                    payMed.Collector_Email_Address__c = userEmail;
                    payRec.add(payMed);
                }
            }
        }
        if(payRec.size()>0){
            Update payRec;
        }
    }
    //UPDATE MH ACCOUNT PAYMENT TERMS
    public static void updateMHAccountPaymentTerms(List<Account> accList, Map<Id,Account> oldAccMap){
        Map<Id,Account> mapAccNew = new Map<Id,Account>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> allAccIds = new Set<Id>();
        System.debug('XTest ' );
        for(Account accA : accList){
            System.debug('YTest ' +accA );
            if(accA.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId()){
                 System.debug('ZTest ' +accA );
                accIds.add(accA.Id);
            }
            
            if(oldAccMap != null){
            if(accA.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId() && accA.Payment_Terms__c != oldAccMap.get(accA.Id).Payment_Terms__c){
                 System.debug('ZTest ' +accA );
                allAccIds.add(accA.Id);
            }
            }
        }
        System.debug('ATest ' + accIds);
        
        
        for(Account acc : [SELECT ID,blng__DefaultPaymentType__c,Payment_Terms__c FROM Account WHERE ID IN: accIds]){
            System.debug('BTest ' + acc);
            System.debug('CTest ' + acc.blng__DefaultPaymentType__c);
                if(acc.blng__DefaultPaymentType__c != Null){
                    System.debug('DTest ' );
                    acc.Payment_Terms__c = 'Net 10';
                    mapAccNew.put(acc.Id, acc);
                }else{
                    System.debug('ETest ' );
                    acc.Payment_Terms__c = 'Net 30';
                    mapAccNew.put(acc.Id, acc);   
                }
        }
        if(allAccIds != null){       
            for(Account acc : [SELECT ID,blng__DefaultPaymentType__c,Payment_Terms__c FROM Account WHERE ID IN: allAccIds]){
            mapAccNew.put(acc.Id, acc);   
        }
                             }
        
        List<OrderItem> ordItemList = [Select Id,OrderId,Order.AccountId, Order.SBQQ__PaymentTerm__c from OrderItem where Order.AccountId in :mapAccNew.keyset() and (blng__InvoiceRunProcessingStatus__c = 'Pending Billing' or blng__InvoiceRunProcessingStatus__c = 'In Progress')];
        Map<Id,Order> orders = new Map<Id,Order>();
        
        for(OrderItem ordItem : ordItemList){
            if(orders != null && orders.containsKey(ordItem.OrderId) == false){
            Order newOrd =  new Order(id = ordItem.OrderId);
            newOrd.SBQQ__PaymentTerm__c = mapAccNew.get(ordItem.Order.AccountId).Payment_Terms__c;
            orders.put(newOrd.Id,newOrd);
            }
        }
        
        System.debug('FTest ' + !mapAccNew.isEmpty());
        if(!mapAccNew.isEmpty()){
            System.debug('GTest ' );
            Update mapAccNew.values();
        }
        
        if(orders.size()>0){
            update orders.values();
        }
        
    }
    
    /*
    Method Name - generateToken
    Parameter - Map of blng__PaymentMethod__c
    Description - Tokenization
    Return Type - None
    */
    public static void generateToken(Map<Id, blng__PaymentMethod__c> newMap){
        
        if(newMap != null && !newMap.keyset().isEmpty()){
            generateTokenforDMController.generateToken(newMap.keyset());
        }
    }
    
    /*
    Method Name - populatePaymentGateway
    Parameter - List of blng__PaymentMethod__c
    Description - Populate Payment Gateway on Payment Method based on Custom label
    Return Type - None
    */
    public static void populatePaymentGateway(List<blng__PaymentMethod__c> payNewMap){
        for(blng__PaymentMethod__c pm: payNewMap){
            if(pm.blng__PaymentGateway__c == null){
                pm.blng__PaymentGateway__c = system.Label.Gateway_for_Legal_Cases;
            }
        }
    }
    
    public static void updateDefaultPMonAccountInsert(List<blng__PaymentMethod__c> pmList){

        Map<Id,String> accVsDefaultPMMap = new  Map<Id,String>();

        for(blng__PaymentMethod__c pm : pmList){
            if(pm.blng__Account__c != Null && pm.blng__Active__c == True && pm.blng__AutoPay__c == true ){
                if(pm.blng__PaymentType__c == 'ACH'){
                accVsDefaultPMMap.put(pm.blng__Account__c,'ACH');
                } else if(pm.blng__PaymentType__c == 'Credit Card' && pm.blng__PaymentGatewayToken__c != null){
                    accVsDefaultPMMap.put(pm.blng__Account__c,'Credit Card'); 
                }
            }
            }          
        
        
        System.debug('accVsDefaultPMMap : ' + accVsDefaultPMMap);
        List<Account> accToUpdate = [Select id,blng__DefaultPaymentType__c from Account where id in :accVsDefaultPMMap.keyset()];
        
        for(Account acc : accToUpdate){
            if(accVsDefaultPMMap.containskey(acc.ID)){
                System.debug(accVsDefaultPMMap.get(acc.ID));
                acc.blng__DefaultPaymentType__c = accVsDefaultPMMap.get(acc.ID);
            }
        }
             System.debug(accToUpdate);
             
          
        if(accToUpdate.size() > 0){
            update accToUpdate;
        }
    }
    
    
    public static void updateDefaultPMonAccountUpdate(List<blng__PaymentMethod__c> pmList,Map<Id,blng__PaymentMethod__c> pmOldMap){

        Map<Id,String> accVsDefaultPMMap = new  Map<Id,String>();
        Set<Id> accIds = new  Set<Id>();
        for(blng__PaymentMethod__c pm : pmList){
            if(pm.blng__Account__c != Null){
                accIds.add(pm.blng__Account__c);
            }
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id,blng__DefaultPaymentType__c, (SELECT Id FROM blng__AccountPaymentMethods__r WHERE blng__AutoPay__c = TRUE AND
                                    blng__Active__c = TRUE) 
                                    FROM Account 
                                    WHERE Id in :accIds]);
                                    
        for(blng__PaymentMethod__c pm : pmList){
            if(pm.blng__Account__c != Null && pm.blng__AutoPay__c == true && pm.blng__Active__c == true && ( pmOldMap.get(pm.Id).blng__Active__c == false ||pmOldMap.get(pm.Id).blng__AutoPay__c == false)){
                if(pm.blng__PaymentType__c == 'ACH'){
                accVsDefaultPMMap.put(pm.blng__Account__c,'ACH');
                } else if(pm.blng__PaymentType__c == 'Credit Card' && pm.blng__PaymentGatewayToken__c != null){
                    accVsDefaultPMMap.put(pm.blng__Account__c,'Credit Card'); 
                }
            }else if(pm.blng__Account__c != Null && ((pm.blng__Active__c == false && pmOldMap.get(pm.Id).blng__Active__c == true) || (pm.blng__AutoPay__c == false && pmOldMap.get(pm.Id).blng__AutoPay__c == true))){
                if(accMap.get(pm.blng__Account__c).blng__AccountPaymentMethods__r.isEmpty()){
                    accVsDefaultPMMap.put(pm.blng__Account__c,null);
                }
            }
            
        }
        
        System.debug('accVsDefaultPMMap : ' + accVsDefaultPMMap);
        List<Account> accToUpdate = [Select id,blng__DefaultPaymentType__c from Account where id in :accVsDefaultPMMap.keyset()];
        
        for(Account acc : accToUpdate){
            if(accVsDefaultPMMap.containskey(acc.ID)){
                System.debug(accVsDefaultPMMap.get(acc.ID));
                acc.blng__DefaultPaymentType__c = accVsDefaultPMMap.get(acc.ID);
            }
        }
             System.debug(accToUpdate);
        if(accToUpdate.size() > 0){
            update accToUpdate;
        }
    }
    
    public static void updateDefaultPMonAccountDelete(List<blng__PaymentMethod__c> pmList){
            System.debug('updateDefaultPMonAccountDelete');
        Set<Id> accIds = new  Set<Id>();

        for(blng__PaymentMethod__c pm : pmList){
            if(pm.blng__Account__c != Null && pm.blng__Active__c == true && pm.blng__AutoPay__c == true){
                accIds.add(pm.blng__Account__c);
            }
        }
       
        System.debug(accIds);
        List<Account> accToUpdate = [SELECT Id,blng__DefaultPaymentType__c, (SELECT Id FROM blng__AccountPaymentMethods__r WHERE blng__AutoPay__c = TRUE AND
                                    blng__Active__c = TRUE) 
                                    FROM Account 
                                    WHERE Id in :accIds];
        
        for(Account acc : accToUpdate){
            if(acc.blng__AccountPaymentMethods__r.isEmpty()){
                acc.blng__DefaultPaymentType__c = null;
            }
        }
       
        System.debug(accToUpdate);
        if(accToUpdate.size() > 0){
            update accToUpdate;
        }
    }
    
    /* public static void updateDefaultPMonAccountUpdate(List<blng__PaymentMethod__c> pmList,Map<Id,blng__PaymentMethod__c> pmOldMap){

        Map<Id,String> accVsDefaultPMMap = new  Map<Id,String>();

        for(blng__PaymentMethod__c pm : pmList){
            if(pm.blng__Account__c != Null && ((pm.blng__Active__c == false && pmOldMap.get(pm.Id).blng__Active__c == true) || (pm.blng__AutoPay__c == false && pmOldMap.get(pm.Id).blng__AutoPay__c == true))){
                accVsDefaultPMMap.put(pm.blng__Account__c,null);
            }
        }
        
        List<Account> accToUpdate = [Select id,blng__DefaultPaymentType__c from Account where id in :accVsDefaultPMMap.keySet()];
        
                for(Account acc : accToUpdate){
            if(accVsDefaultPMMap.containskey(acc.ID)){
                acc.blng__DefaultPaymentType__c = accVsDefaultPMMap.get(acc.ID);
            }
        }
        if(accToUpdate.size() > 0){
            update accToUpdate;
        }
    }*/
    
    public static void populateCustIDonAccount_onInsert(List<blng__PaymentMethod__c> newMap){
        Set<Id> accId = new Set<Id>();
        Map<Id, String> mapAccIdtoPayProfId = new Map<Id, String>();
        system.debug('inside populateCustIDonAccount_onInsert');
        for(blng__PaymentMethod__c pm : newMap){
            if(pm.Payment_Profile_ID__c != null && pm.blng__AutoPay__c == true && pm.blng__PaymentType__c == 'Credit Card'){
                system.debug('in 11');
                if(pm.blng__Account__c != null){
                    system.debug('in 22');
                    mapAccIdtoPayProfId.put(pm.blng__Account__c, pm.Payment_Profile_ID__c);
                }
            }
        }
        system.debug('mapAccIdtoPayProfId : '+mapAccIdtoPayProfId);
        List<Account> listAccountToUpdate = new List<Account>();
        //List<Account> accList = [SELECT Id,blng__CustomerProfileId__c FROM Account WHERE Id IN: mapAccIdtoPayProfId.keySet()];        
        for(Account acc : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountPAYmeth(mapAccIdtoPayProfId.keySet())){
            if(mapAccIdtoPayProfId.containsKey(acc.Id)){
                acc.blng__CustomerProfileId__c = mapAccIdtoPayProfId.get(acc.Id);
                listAccountToUpdate.add(acc);
            }
        }
        
        try{
          update listAccountToUpdate;  
        }
        catch(Exception e){
            system.debug('Excpetion occured 1 : '+e.getMessage());
        }        
    }
    
    public static void populateCustIDonAccount_onUpdate(List<blng__PaymentMethod__c> newMap, Map<Id,blng__PaymentMethod__c> oldMap){
        Set<Id> accId = new Set<Id>();
        Map<Id, String> mapAccIdtoPayProfId = new Map<Id, String>();
        system.debug('inside populateCustIDonAccount_onUpdate');
        for(blng__PaymentMethod__c pm : newMap){
            if((pm.Payment_Profile_ID__c != oldMap.get(pm.Id).Payment_Profile_ID__c || pm.blng__AutoPay__c != oldMap.get(pm.Id).blng__AutoPay__c) 
               && pm.blng__AutoPay__c == true && pm.blng__PaymentType__c == 'Credit Card'){
                system.debug('in 33');
                if(pm.blng__Account__c != null){
                    system.debug('in 44');
                    mapAccIdtoPayProfId.put(pm.blng__Account__c, pm.Payment_Profile_ID__c);
                }
            }
        }
        system.debug('mapAccIdtoPayProfId2 : '+mapAccIdtoPayProfId);
        List<Account> listAccountToUpdate = new List<Account>();
        //List<Account> accList = [SELECT Id,blng__CustomerProfileId__c FROM Account WHERE Id IN: mapAccIdtoPayProfId.keySet()];        
        for(Account acc : PaymentMethod_UtilityClass.updatePMOrderStatusOnAccountPAYmeth(mapAccIdtoPayProfId.keySet())){
            if(mapAccIdtoPayProfId.containsKey(acc.Id)){
                acc.blng__CustomerProfileId__c = mapAccIdtoPayProfId.get(acc.Id);
                listAccountToUpdate.add(acc);
            }
        }
        
        try{
          update listAccountToUpdate; 
        }
        catch(Exception e){
            system.debug('Excpetion occured 1 : '+e.getMessage());
        }        
    }
    
   
    
    //MHBS-6098;Added by VR;24/1/22
    public static void updateBankNameOnPayment(List<blng__PaymentMethod__c> newList, Map<Id,blng__PaymentMethod__c> oldMap) {
        for(blng__PaymentMethod__c pobj:newList)
        {
            if(pobj.blng__PaymentType__c=='ACH' && pobj.blng__BankAccountName__c!=null && pobj.blng__BankAccountName__c.length()>22)
            {
                System.debug('updateBankNameOnPayment'+pobj.blng__BankAccountName__c);
                pobj.blng__BankAccountName__c=pobj.blng__BankAccountName__c.SubString(0,22);
            }
        }
    }

}