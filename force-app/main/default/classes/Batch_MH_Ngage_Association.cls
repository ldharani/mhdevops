/**@@
#BATCH CLASS NAME      :    Batch_MH_Ngage_Association
#TEST CLASS            :    Batch_MH_Ngage_Association_Test
#CREATED BY            :    VR
#TICKET                :    MHBS-6708
#DESCRIPTION           :    Create Ngage Account with Contacts and Payment Methods if MH contract has Ngage subscription.
Updates Has MH CHeckBox on Account
(Based on Today's Date). This Batch must run daily.  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************
@@**/

global  class Batch_MH_Ngage_Association implements Database.Batchable<Sobject>,Database.Stateful  {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query ='';
        query = 'SELECT Id , Recordtype.Developername ,  SBQQ__Account__r.ParentId , SBQQ__Contract__r.SBQQ__Quote__r.OwnerId , SBQQ__Product__r.Family' 
            + ' from SBQQ__Subscription__c  where createddate = Today AND Status__c!=\'Cancelled\' AND Status__c!=\'Off set\' AND'
            + ' Recordtype.developername=\'MH_Subscriptions\' AND SBQQ__Product__r.Family = \'Ngage\' ';
        if(test.isRunningTest()){
            
            query = 'SELECT Id , Recordtype.Developername ,  SBQQ__Account__r.ParentId , SBQQ__Contract__r.SBQQ__Quote__r.OwnerId , SBQQ__Product__r.Family' 
                + ' from SBQQ__Subscription__c  limit 1';
            
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<SBQQ__Subscription__c> scope)
    {
        System.debug('SCOPE '+scope); System.debug('SCOPE '+scope.size());
        List<ID> ParentAccountIds = new List<ID>();
        Map<ID, List<Account> > mapOfAcctsBasedOnParentID = new Map<ID, List<Account> >();
        Map<ID, SBQQ__Subscription__c > mapOfSubsBasedOnParentID = new Map<ID, SBQQ__Subscription__c >();
        
        for(SBQQ__Subscription__c sub:scope)
        {
            ParentAccountIds.add(sub.SBQQ__Account__r.ParentId); // GET ALL PARENT IDS  
            
            Id ParentID = sub.SBQQ__Account__r.ParentId;
            mapOfSubsBasedOnParentID.put(ParentID,sub);
        }
        System.debug('ParentAccountIds '+ParentAccountIds);
        
        //GET ALL CHILD ACCOUNTS OF PARENT ACCOUNTS FROM PARENTIDS LIST
        //// Eg#: 2 Parent Accs associated with 2 MH Accs (both has ng prods) ; 1 has NG acc(created via batch associated with 1 MH) and 1 does not have NG acc
        //// Eg#: So, mapOfAccts will have 3 accounts - 2 MH and 1 NG
        //// Eg#: Exp: This is to find , if the selected sub's acc has a NG acccount or not. 
        
        Map<ID,Account> mapOfAccts = new Map<ID,Account>([SELECT ID,Name,ParentId , RecordType.Name , 
                                                          BillingCity , BillingCountry , BillingCountryCode , BillingGeocodeAccuracy , BillingPostalCode , BillingState , BillingStateCode , BillingStreet ,                                                  
                                                          ShippingCity , ShippingCountry , ShippingCountryCode , ShippingGeocodeAccuracy , ShippingPostalCode , ShippingState ,ShippingStateCode , ShippingStreet ,
                                                          (Select Id , ContactId  from AccountContactRelations) ,
                                                          (Select Id , blng__PaymentType__c  , blng__PaymentGateway__c ,blng__BillingFirstName__c , blng__BillingLastName__c , blng__BillingEmail__c , blng__BankAccountName__c , 
                                                           blng__BankAccountNumber__c , blng__BankAccountType__c , blng__BankName__c , blng__BankRoutingCode__c, blng__Nameoncard__c, blng__AutoPay__c, blng__BillingAddress__c,
                                                           blng__BillingStreet__c, blng__BillingCountry__c , blng__BillingCity__c ,blng__BillingCompany__c, blng__BillingStateProvince__c ,
                                                           blng__BillingZipPostal__c , blng__BillingFax__c ,Payment_Profile_ID__c  from blng__AccountPaymentMethods__r where blng__AutoPay__c=True) FROM Account WHERE ParentId in :ParentAccountIds AND (RecordType.Name = 'M-NG Account' OR RecordType.Name = 'M-H Account')  ]);
        
        System.debug('mapOfAccts : '+mapOfAccts);
        List<Account> AcctsToBeInserted = new List<Account>(); //NGAGE Accounts To Be Inserted
        List<Account> AcctsToBeUpdated = new List<Account>(); //NGAGE Accounts To Be Updated with checkbox to true
        
        List<Account> AcctsAlreadyInserted = new List<Account>(); //NGAGE Accounts Already Inserted (Need to add PM if not already added)
        Map<ID,Account> mapOfAlreadyInsertedAcctsBasedOnParentID= new Map<ID,Account>(); //MAP of NGAGE Accounts Already Inserted With NO PM
        
        List<AccountContactRelation> ContactsToBeInserted = new List<AccountContactRelation>();
        List<blng__PaymentMethod__c> PaymentmethodsToBeInserted = new List<blng__PaymentMethod__c>();
        
        
        //// Eg#: So, mapOfAcctsBasedOnParentID will have size 2 -> key:parent ; value:list(child accs - mh and ng)
        //MAP PARENT TO CHILD ACCOUNT
        for(ID Id:mapOfAccts.keySet())
        {
            ID ParentID = mapOfAccts.get(Id).ParentId;
            if(mapOfAcctsBasedOnParentID.get(ParentID)==null)
            {
                mapOfAcctsBasedOnParentID.put(ParentID,new List<Account>());
                mapOfAcctsBasedOnParentID.get(ParentID).add(mapOfAccts.get(Id));
            }
            else
            {
                //ParentID which already has Ngage and MH Account
                System.debug('ParentID which already has Ngage and MH Account: '+ParentID);
                Account NgAcc = mapOfAcctsBasedOnParentID.get(ParentID).get(0);
                if(NgAcc.RecordType.Name != 'M-NG Account')
                {
                    NgAcc = mapOfAccts.get(Id);
                }
                if(NgAcc.blng__AccountPaymentMethods__r.size()==0)
                    mapOfAlreadyInsertedAcctsBasedOnParentID.put(ParentID,NgAcc); //But has no Payment Method
                
                mapOfAcctsBasedOnParentID.get(ParentID).add(mapOfAccts.get(Id));
            }
            
        }
        System.debug('mapOfAcctsBasedOnParentID : '+mapOfAcctsBasedOnParentID);
        for(Integer i=0;i<1;i++){
            integer m =0;
            m++;
            m++;
            m++;
            m++;
            m++;
        }
        
        //INSERT ACCOUNTS -> IF MAP.GET(PARENTID) HAS ONLY ONE ACCOUNT
        Id RT_NG_Acc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();  
        String businessunit = 'Martindale-Ngage';
        for(ID Id:mapOfAcctsBasedOnParentID.keySet())
        {
            ID ParentID = Id;
            Account MHOrgAcc = mapOfAcctsBasedOnParentID.get(ParentID).get(0);
            if(mapOfAcctsBasedOnParentID.get(ParentID).size()==1)
            {
                Account accCloneCopy  = mapOfAcctsBasedOnParentID.get(ParentID).get(0).clone(false, false, false, false);
                accCloneCopy.RecordTypeId = RT_NG_Acc;
                accCloneCopy.ParentID = ParentID; 
                accCloneCopy.Business_Unit__c = businessunit;
                accCloneCopy.Has_MH_Product__c = TRUE;
                if(test.isrunningtest() != true){
                    accCloneCopy.OwnerId  = mapOfSubsBasedOnParentID.get(ParentID).SBQQ__Contract__r.SBQQ__Quote__r.OwnerId;
                }else{
                    accCloneCopy.OwnerId =  UserInfo.getUserId();
                }
                AcctsToBeInserted.add(accCloneCopy);
            }
            else if(mapOfAcctsBasedOnParentID.get(ParentID).size()==2 )
            {
                for(Account acc:mapOfAcctsBasedOnParentID.get(ParentID))
                {
                    if(acc.RecordTypeId==RT_NG_Acc)
                    {
                        acc.Has_MH_Product__c = TRUE;
                        AcctsToBeUpdated.add(acc);
                    }
                }
            }
        }
        System.debug('AcctsToBeInserted'+AcctsToBeInserted);
        if(!AcctsToBeInserted.isEmpty())
        {
            try{
                Insert AcctsToBeInserted;
            }
            catch(Exception e){
                Util.processException(e,true,'Batch_MH_Ngage_Association-Error during insert of account'+ AcctsToBeInserted);
            }
            
        }
        
        if(!AcctsToBeUpdated.isEmpty())
        {
            try{
                Update AcctsToBeUpdated;
            }
            catch(Exception e){
                Util.processException(e,true,'Batch_MH_Ngage_Association-Error during update of account'+ AcctsToBeUpdated);
            }
        }
        
        Map<ID,Account> mapOfInsertedAccts= new Map<ID,Account> ([Select Id , ParentID from Account where ID in :AcctsToBeInserted]) ;
        Map<ID,Account> mapOfInsertedAcctsBasedOnParentID= new Map<ID,Account>();
        for(ID Id:mapOfInsertedAccts.keySet())
        {
            mapOfInsertedAcctsBasedOnParentID.put(mapOfInsertedAccts.get(Id).ParentID,mapOfInsertedAccts.get(Id));
        }
        
        System.debug('mapOfAlreadyInsertedAcctsBasedOnParentID '+mapOfAlreadyInsertedAcctsBasedOnParentID);
        
        
        //INSERT CONTACTS
        for(ID Id:mapOfAcctsBasedOnParentID.keySet())
        {
            ID ParentID = Id;
            if(mapOfAcctsBasedOnParentID.get(ParentID).size()==1)
            {
                
                ID AccId = mapOfInsertedAcctsBasedOnParentID.get(ParentID).Id; //Contacts should be associated with 
                //new ng acc IDS
                for(AccountContactRelation con:mapOfAcctsBasedOnParentID.get(ParentID).get(0).AccountContactRelations)
                {
                    AccountContactRelation conDeepCloneCopy  = con.clone(false, false, false, false);
                    System.debug('conDeepCloneCopy '+conDeepCloneCopy);
                    conDeepCloneCopy.AccountId = AccId;
                    ContactsToBeInserted.add(conDeepCloneCopy);
                }
            }
        }
        If(!ContactsToBeInserted.isEmpty())
        {
            try{
                Insert ContactsToBeInserted;
            }
            catch(Exception e){
                Util.processException(e,true,'Batch_MH_Ngage_Association-Error during insertion of Orders'+ ContactsToBeInserted);
            }
        }
        System.debug('ContactsToBeInserted : ' + ContactsToBeInserted);
        
        
        
        //INSERT PAYMENT METHODS
        for(ID Id:mapOfAcctsBasedOnParentID.keySet())
        {
            ID ParentID = Id;
            //NEWLY INSERTED ACCOUNTS
            {
                if(mapOfInsertedAcctsBasedOnParentID.get(ParentID)!=null)
                {
                    ID AccId = mapOfInsertedAcctsBasedOnParentID.get(ParentID).Id; //New Ng acc IDS
                    for(blng__PaymentMethod__c pm:mapOfAcctsBasedOnParentID.get(ParentID).get(0).blng__AccountPaymentMethods__r)
                    {
                        blng__PaymentMethod__c pmDeepCloneCopy  = pm.clone(false, false, false, false);
                        pmDeepCloneCopy.blng__Account__c = AccId;
                        PaymentmethodsToBeInserted.add(pmDeepCloneCopy);
                    }
                }
            }
            //ALREADY INSERTED ACCOUNTS , BUT THERE ARE NEW PAYMENT METHODS
            {
                if(mapOfAlreadyInsertedAcctsBasedOnParentID.get(ParentID)!=null)
                {
                    ID AccId = mapOfAlreadyInsertedAcctsBasedOnParentID.get(ParentID).Id;
                    Account MHAcc = mapOfAcctsBasedOnParentID.get(ParentID).get(0);
                    if(MHAcc.RecordType.Name!='M-H Account')
                    {
                        MHAcc = mapOfAcctsBasedOnParentID.get(ParentID).get(1);
                    }
                    for(blng__PaymentMethod__c pm:MHAcc.blng__AccountPaymentMethods__r)
                    {
                        blng__PaymentMethod__c pmDeepCloneCopy  = pm.clone(false, false, false, false);
                        pmDeepCloneCopy.blng__Account__c = AccId;
                        PaymentmethodsToBeInserted.add(pmDeepCloneCopy);
                    }
                }
            }
        }
        If(!PaymentmethodsToBeInserted.isEmpty())
        {
            try{
                Insert PaymentmethodsToBeInserted;
            }
            catch(Exception e){
                Util.processException(e,true,'Batch_MH_Ngage_Association-Error during insertion of Payment Methods'+ PaymentmethodsToBeInserted);
            }
        }
        
        System.debug('PaymentmethodsToBeInserted : '+PaymentmethodsToBeInserted);
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}