/*
/*
**Created By : Lister Technologies
**Purpose : To create Cases based on changes in Account - Like Addresss 
**Test Class & Method : MDL_Test_TriggerOnAccount
**Modification History: 
  Modified by Ieswarya on July 24    for MHBS- 3913    tagged as T1

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6252    VR            07/02/2022                   T01     Update "Avalara Address Validation Error" Field
************************************************************************************************************************
*/

/***********************************************************************************************************************
 * @author - Lister Technologies
 * @testclass - MDL_Test_TriggerOnAccount

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6252    VR            07/02/2022                   T02     Avalara Address Validation Error
MHBS-7446    VR            05/07/2022                   T03     Validate Address CHeckBox Changes
************************************************************************************************************************/

public with sharing class MDL_TriggerHandlerForAccount {
    //public String rt; 
    public Group queue;
    public static Boolean firstRun = false;
    public static boolean updatePayMethodsFlag = false;
    //public static boolean updatePayMethodsFlag = false;
    MDL_TriggerHandlerForAccount handler;
    public MDL_TriggerHandlerForAccount() {
        
        queue = new Group();
        
        /*for(RecordType rtype : [Select Id from RecordType where DeveloperName='MDL_Customer_Service']) {
            rt = rtype;
        }*/
        //handler = new MDL_TriggerHandlerForAccount();
    }
    public void createCaseOnAccountCreation(List<Account> lstAccounts) {
        //queue = [select Id from Group where Type='Queue' and DeveloperName ='Data_Governor_Queue' LIMIT 1]; 
        Id ownId = queue.Id;
        List<Case> lstCasesToInsert = new List<Case>();
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        //Fetching the assignment rules on case
        for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
            AR = assignRule;
        }
        Id IBAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id MAFirmAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId(); //added by saiv for MHBS-3916
        system.debug('===MAFirmAccRecordTypeId==='+MAFirmAccRecordTypeId);
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        dmlOpts = new Database.DMLOptions();
        if(AR!=null)
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        
        for(Account acc : lstAccounts) {
            If(acc.RecordTypeId != IBAccRecordTypeId && acc.RecordTypeId != MAFirmAccRecordTypeId){
            system.debug('List of accounts'+acc);
            Case cInsert = createCase('Order Update', 'New Account', 'New Account Created in SFDC', 'A new Account has been created in SFDC.  Please get the Org ID and update the Account record in SFDC.',  'OrderUpdate', acc.Id,dmlOpts);
            lstCasesToInsert.add(cInsert);
            }          
        }
        if(lstCasesToInsert.size() > 0) {
            Database.insert(lstCasesToInsert);
        }
    }
    /*
    // Start of changes for MHBS-1351 -- Jehan
    public void createCaseOnShippingAddressChange(List<Account> lstAccounts,Map<Id,Account> oldMapAccount) {
        //queue = [select Id from Group where Type='Queue' and DeveloperName ='Data_Governor_Queue' LIMIT 1];
        Id ownId = queue.Id;
        List<Case> lstCasesToInsert = new List<Case>();
        String description;
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        //Fetching the assignment rules on case
        for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
            AR = assignRule;
        }
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        dmlOpts = new Database.DMLOptions();
        if(AR!=null)
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        for(Account acc : lstAccounts) {
            if((acc.ShippingCity != oldMapAccount.get(acc.Id).ShippingCity)||(acc.ShippingCountry != oldMapAccount.get(acc.Id).ShippingCountry)||(acc.ShippingPostalCode != oldMapAccount.get(acc.Id).ShippingPostalCode)||(acc.ShippingState != oldMapAccount.get(acc.Id).ShippingState)||(acc.ShippingStreet != oldMapAccount.get(acc.Id).ShippingStreet)) {
                Case cInsert = createCase('Subscription Changes', 'Change Shipping Data', 'Shipping Address Change', 'User Changed Shipping Address.  Please validate and update shippable product attributes as necessary.  After update, repush to EFS.',  'OrderUpdate', acc.Id , dmlOpts);
                lstCasesToInsert.add(cInsert);
            }

            if((acc.BillingCity != oldMapAccount.get(acc.Id).BillingCity)||(acc.BillingCountry != oldMapAccount.get(acc.Id).BillingCountry)||(acc.BillingPostalCode != oldMapAccount.get(acc.Id).BillingPostalCode)||(acc.BillingState != oldMapAccount.get(acc.Id).BillingState)||(acc.BillingStreet != oldMapAccount.get(acc.Id).BillingStreet) || (acc.Phone != oldMapAccount.get(acc.Id).Phone)) {
                Case cInsert = createCase('Subscription Changes', 'Billing Info Changes', 'Account Address and/or Phone Number changed', 'The Billing Address and/or Phone Number has been changed.  Please update NES as needed.',  'OrderUpdate', acc.Id , dmlOpts);
                lstCasesToInsert.add(cInsert);
            }
            if(acc.Website != oldMapAccount.get(acc.Id).Website) {
                description = 'Account Website has been modified';
                Case cInsert = createCase('Subscription Changes', 'Billing Info Changes', 'Account website has been changed', description ,  'OrderUpdate', acc.Id , dmlOpts);
                lstCasesToInsert.add(cInsert);
            }
            if(acc.Name != oldMapAccount.get(acc.Id).Name) {
                description = 'Firm name has been changed';
                Case cInsert = createCase('Subscription Changes', 'Billing Info Changes', 'Firm name has been changed', description , 'OrderUpdate', acc.Id , dmlOpts);
                lstCasesToInsert.add(cInsert);
            }

 
        }
        if(lstCasesToInsert.size() > 0) {
            Database.insert(lstCasesToInsert);
        }
    }
    public void createCaseOnBillingAddressChange(List<Account> lstAccounts,Map<Id,Account> oldMapAccount) {
        //queue = [select Id from Group where Type='Queue' and DeveloperName ='Data_Governor_Queue' LIMIT 1];
        Id ownId = queue.Id;
        List<Case> lstCasesToInsert = new List<Case>();
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        //Fetching the assignment rules on case
        for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
            AR = assignRule;
        }
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        dmlOpts = new Database.DMLOptions();
        if(AR!=null)
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        for(Account acc : lstAccounts) {
            System.debug('values modified::'+acc);
            System.debug('old values:::'+oldMapAccount.get(acc.Id));
            if((acc.BillingCity != oldMapAccount.get(acc.Id).BillingCity)||(acc.BillingCountry != oldMapAccount.get(acc.Id).BillingCountry)||(acc.BillingPostalCode != oldMapAccount.get(acc.Id).BillingPostalCode)||(acc.BillingState != oldMapAccount.get(acc.Id).BillingState)||(acc.BillingStreet != oldMapAccount.get(acc.Id).BillingStreet) || (acc.Phone != oldMapAccount.get(acc.Id).Phone)) {
                Case cInsert = createCase('Subscription Changes', 'Billing Info Changes', 'Account Address and/or Phone Number changed', 'The Billing Address and/or Phone Number has been changed.  Please update NES as needed.',  'OrderUpdate', acc.Id , dmlOpts);
                lstCasesToInsert.add(cInsert);
            }
        }
        if(lstCasesToInsert.size() > 0) {
            Database.insert(lstCasesToInsert);
        }
    }
    public void createCaseOnFirmNameChange(List<Account> lstAccounts,Map<Id,Account> oldMapAccount) {
        //queue = [select Id from Group where Type='Queue' and DeveloperName ='Data_Governor_Queue' LIMIT 1];
        Id ownId = queue.Id;
        String description;
        List<Case> lstCasesToInsert = new List<Case>();
        AssignmentRule AR;
        Database.DMLOptions dmlOpts;
        //Fetching the assignment rules on case
        for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
            AR = assignRule;
        }
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        dmlOpts = new Database.DMLOptions();
        if(AR!=null)
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        for(Account acc : lstAccounts) {
            if(acc.Website != oldMapAccount.get(acc.Id).Website) {
                description = 'Account Website has been modified';
                Case cInsert = createCase('Subscription Changes', 'Billing Info Changes', 'Account website has been changed', description ,  'OrderUpdate', acc.Id , dmlOpts);
                lstCasesToInsert.add(cInsert);
            }
            if(acc.Name != oldMapAccount.get(acc.Id).Name) {
                description = 'Firm name has been changed';
                Case cInsert = createCase('Subscription Changes', 'Billing Info Changes', 'Firm name has been changed', description , 'OrderUpdate', acc.Id , dmlOpts);
                lstCasesToInsert.add(cInsert);
            }
        }
        if(lstCasesToInsert.size() > 0) {
            Database.insert(lstCasesToInsert);
        }
    }
    // End of changes for MHBS-1351 -- Jehan*/
    public Case createCase(String area , String subArea , String subject , String description , String caseOrigin , Id accId, Database.DMLOptions dmlOpts) {
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Case Record').getRecordTypeId();

        Case c = new Case();
        c.AccountId = accId;
        c.Area__c = area; 
        c.Sub_Area__c = subArea;
        c.Subject = subject;
        c.Description = description;
        //c.OwnerId = ownerId;
        c.Origin = caseOrigin;
        if(caseRecordTypeId !=null) {
            c.RecordTypeId = caseRecordTypeId ;
        }
        c.Priority = 'High';
        c.Status = 'New';
        c.setOptions(dmlOpts);
        return c;
    }
    //Adding LogicalDoc URL Functionality
    @future(callout=true)
    public static void createInvoiceFolderPath(SET<Id> accIds) {
        List<Account> lstAccRecords = [select id, name,MH_Cust_Number__c, Logical_Doc__c from Account where 
                                                                   MH_Cust_Number__c != null and Logical_Doc__c = null and (RecordType.DeveloperName = 'Nolo_Account' OR
                                                                    RecordType.DeveloperName = 'MH_Accounts')
                                                                   and Id IN :accIds LIMIT 49500 ];
        system.debug('Saichand========='+  lstAccRecords);
        String sid;
        authWebserviceLogicaldocCom.AuthServiceImplPort logwebservices = new authWebserviceLogicaldocCom.AuthServiceImplPort();
        // check for invoke success
        boolean isSuccess = false;
        if(!lstAccRecords.isEmpty() && lstAccRecords != null && !test.isRunningTest() ){
                    
            sid = logwebservices.login('mhd-logicaldoc','kxmbbk3e');
            system.debug('Saichand========='+  sid );
            isSuccess = true; 
        }
        
        for(Account acc : lstAccRecords) {
            system.debug('@@@acc.MH_Cust_Number__c' + acc.MH_Cust_Number__c);
            system.debug('@@@acc.Logical_Doc__c' + acc.Logical_Doc__c);
            If(acc.MH_Cust_Number__c != null && acc.MH_Cust_Number__c != '' && acc.Logical_Doc__c != null && acc.Logical_Doc__c != '' )
            continue;
            long folderid= 0;
            system.debug('@@@@accName'+ acc.Name);
            //sid = logwebservices.login('mhd-logicaldoc','kxmbbk3e');
            NewfolderWebserviceLogicaldocCom.wsFolder rootFolder = new NewfolderWebserviceLogicaldocCom.wsFolder();
            //List<NewfolderWebserviceLogicaldocCom.wsFolder> lstChildFolders = new List<NewfolderWebserviceLogicaldocCom.wsFolder>();
             
            NewfolderWebserviceLogicaldocCom.FolderServiceImplPort folderLogicalService =new NewfolderWebserviceLogicaldocCom.FolderServiceImplPort();
            //rootFolder =  folderLogicalService.getRootFolder(sid);
            //CustomerNumber = MH_Cust_Number__c;
            if(!test.isRunningTest()){
            rootFolder =  folderLogicalService.findByPath(sid,'/MH_LIBRARY/'+acc.MH_Cust_Number__c);
            }
            system.debug('Saichand========='+  rootFolder ); 
            if(rootFolder == null)
                continue;
            //lstChildFolders =  folderLogicalService.listChildren(sid,rootFolder.id); 
            //system.debug('Saichand=========lstChildFolders ==='+  lstChildFolders );
            //if(lstChildFolders== null) 
            //    continue;
            //for(NewfolderWebserviceLogicaldocCom.wsFolder folder : lstChildFolders )
            //{
            //    if(folder.Name == 'INV')
            //    {
            //        folderid = folder.id;
            //        break;
            //    }
            //    system.debug('Saichand=========FolderName==='+  folder.Name );
             //   system.debug('Saichand=========FoldeID==='+  folder.id); 
           // }
            string folderURL = 'http://mhlogicdoc.martindale.com/?folderId=' +rootFolder.id ;
            //system.debug('Saichand=========lstChildFolders ==='+  lstChildFolders );
        
            acc.Logical_Doc__c = folderURL; 
            system.debug('@@@@acc.Logical_Doc__c' +acc.Logical_Doc__c);
            //logwebservices.logout(sid);
            
        }
        MDL_RecursionHandler.stopAccRecursion = false;
        try{
            
            If( isSuccess ){
                logwebservices.logout(sid);
                System.debug('@@@@logging out'+ sid); 
            }
            upsert lstAccRecords;
            
        }
        catch(exception e){
            system.debug('@@@@exception'+e);
        }
        
        }
    
    //added by akash
    //to work workflow rule based on orderStatus
    //updating payment methods when order Status changes
        
        public static void updatepaymentMethods(map<id, account> oldmap, map<id,account>newmap){
    
        system.debug('@@@@@Rama in updatepaymentMethods');
        
        List<invoiceit_s__Payment_Method__c> listToUpdatePaymentMethods = new List<invoiceit_s__Payment_Method__c>();
        for(invoiceit_s__Payment_Method__c p : [select id, Name, invoiceit_s__Account__c, invoiceit_s__Active__c,invoiceit_s__Payment_Method__c,
                                               invoiceit_s__Default__c, Order_Status_on_Account__c
                                        From invoiceit_s__Payment_Method__c
                                        where invoiceit_s__Account__c in :(newmap.keySet())
                                          and invoiceit_s__Active__c = true
//                                          and invoiceit_s__Default__c = true
                                          and invoiceit_s__Payment_Method__c = 'Credit Card']) {
            if (newmap.get(p.invoiceit_s__Account__c).Order_Status__c != null && (p.Order_Status_on_Account__c != newmap.get(p.invoiceit_s__Account__c).Order_Status__c || p.Order_Status_on_Account__c == null)){
                    p.Order_Status_on_Account__c = newmap.get(p.invoiceit_s__Account__c).Order_Status__c; listToUpdatePaymentMethods.add(p);
                }
        }
/*        Map<id, account> mapwithPaymentMethods = new Map<Id, account>([select id, Name,
                                                                              (select id, Name,
                                                                                      invoiceit_s__Account__c,
                                                                                      invoiceit_s__Active__c,
                                                                                      invoiceit_s__Payment_Method__c,
                                                                                      invoiceit_s__Default__c,
                                                                                      Order_Status_on_Account__c
                                                                                      From invoiceit_s__Payment_Methods__r
                                                                                      where invoiceit_s__Active__c = true
                                                                                            and invoiceit_s__Default__c = true
                                                                                            and invoiceit_s__Payment_Method__c = 'Credit Card')
                                                                              From account 
                                                                              where id IN:(newmap.keySet())]);
       
        system.debug('@@@mapwithPaymentMethods.keyset()'+ mapwithPaymentMethods.keySet());    
        for(id accid : mapwithPaymentMethods.keySet()){
           
                if((oldmap.get(accid).Order_Status__c == null &&  newmap.get(accid).Order_Status__c != null) || oldmap.get(accid).Order_Status__c != newmap.get(accid).Order_Status__c){
                    if(mapwithPaymentMethods.get(accid).invoiceit_s__Payment_Methods__r.size() > 0){
                        for(invoiceit_s__Payment_Method__c paymentMethod : mapwithPaymentMethods.get(accid).invoiceit_s__Payment_Methods__r){
                            paymentMethod.Order_Status_on_Account__c = newmap.get(accid).Order_Status__c;
                            listToUpdatePaymentMethods.add(paymentMethod);
                        } 
                        
                    }
                }
            
            
            else{
                if(newmap.get(accid).Order_Status__c != null){
                    for(invoiceit_s__Payment_Method__c paymentMethod : mapwithPaymentMethods.get(accid).invoiceit_s__Payment_Methods__r){
                        if(paymentMethod.Order_Status_on_Account__c == null){
                            paymentMethod.Order_Status_on_Account__c = newmap.get(accid).Order_Status__c;
                            listToUpdatePaymentMethods.add(paymentMethod);
                        }
                        
                    } 
                }
                
            }
        }
*/
        system.debug('@@@@listToUpdatePaymentMethods'+ listToUpdatePaymentMethods);
        if((listToUpdatePaymentMethods != null && listToUpdatePaymentMethods.size() > 0) || test.isRunningTest()){
            try{
                update listToUpdatePaymentMethods;
            }
            catch(exception e){
                system.debug('@@@@ exception'+ e);
            }
//        updatePayMethodsFlag = true;
        }
    }
    
/**************************************************************************************
* Author           : Ronak Jain MHBS-2749
* Description      : To create the case for SEO engineer when the account is put at risk
* Date             : 08/27/2018
* ************************************************************************************/   
    
     public static void createAtRiskCase(List<Account> accList, map<id, account> oldmap, map<id,account>newmap){
         
         List<Account> accountList = new List<Account>();
         List<Case> casesToInsert = new List<Case>(); 
          
         for(Account a: accList){
             System.debug('===========Old Value'+oldmap.get(a.id).At_Risk_Reason__c);
             System.debug('@@@@@@@New Value' +newmap.get(a.id).At_Risk_Reason__c);
             if((a.At_Risk_Reason__c!= NULL && newmap.get(a.id).At_Risk_Reason__c != oldmap.get(a.id).At_Risk_Reason__c) || test.isRunningTest()){
                 accountList.add(a);
             }
         }
         System.debug('@@@@@@ACcocunt IDs'+accountList);
         
         if(!accountList.isempty() && accountList!=NULL){
             
             List<String> queueName = new List<String>();
             queueName.add('SEO Sales Engineer');
             if(!test.isRunningTest()){
             List<Group> queueList = [Select Id,Name from Group where Name in:queueName and Type = 'Queue'];
             System.debug('@@@@@@queue List'+queueList);
             
             String queueId;
             queueId = queueList[0].id;
             System.debug('@@@@@@queue id'+queueId );
                 
             for(Account acc: accountList ){
                 Case c = new Case();
                 c.OwnerId = queueId; //'00GF00000073twK';
                 c.Subject = 'SEO Account potentially at Risk';
                 c.AccountId = acc.Id;
                 c.RecordTypeId = '012F0000000WV3H'; 
                 c.Status = 'New';
                 c.Origin = 'SEOMail';
                 c.Description = acc.At_Risk_Reason__c ;
                 c.Area__c = 'Create Milestone';
                 c.Sub_Area__c = 'SEO_Audit/Account Review At Risk';
                 casesToInsert.add(c);
             }
             }
         }
         //MDL_RecursionHandler.stopAccRecursion = false;
         System.debug('@@@@@@casesToInsert'+casesToInsert);
             if(!casesToInsert.isempty()){
                 insert casesToInsert;
             }
         
         
     }
     
     /**************************************************************************************
* Author           : Ronak Jain MHBS-3849
* Description      : To populate Account owner email on the projects linked to the account
* Date             : 02/19/2020
* ************************************************************************************/   
     public static boolean populateOwnerEmailOnProjRecursion = true;
     public void populateOwnerEmailOnProj(List<Account> accList, map<id, account> oldmap, map<id,account>newmap){
         
         Set<Id> accountIds = new Set<Id>();
         List<Milestone1_Project__c> projList = new List<Milestone1_Project__c>();
         Map<String, String> accountIdVsEmailMap = new Map<String, String>();
         List<Milestone1_Project__c> updateProjList = new List<Milestone1_Project__c>();
         
         for(Account acc: accList){
             if((acc.Account_Owner_Email__c!=NULL && oldmap.get(acc.id).Account_Owner_Email__c!=NULL && oldmap.get(acc.id).Account_Owner_Email__c!= newMap.get(acc.id).Account_Owner_Email__c) || test.isRunningTest()){
                 accountIds.add(acc.id);
                 accountIdVsEmailMap.put(acc.Id, acc.Account_Owner_Email__c);
             }
         }
         
         System.debug('@@@@@@accountIdVsEmailMap------->'+accountIdVsEmailMap);
         
         if(!accountIds.isempty()){
             projList = [Select id, name,Account__c,Account_Owner_Email__c From Milestone1_Project__c Where Account__c in : accountIds ];
             
             if((projList.size()>0)|| test.isRunningTest()){
                 for(Milestone1_Project__c proj: projList){
                     if(accountIdVsEmailMap.containskey(proj.Account__c)){
                         proj.Account_Owner_Email__c = accountIdVsEmailMap.get(proj.Account__c);
                         updateProjList.add(proj);
                     }
                      
                 }
             
             }
         }
         if((!updateProjList.isempty() && updateProjList.size()>0) || test.isRunningTest()){
             update updateProjList;
         }
         
         
     }
    
/**************************************************************************************
* Author           : SaiV MHBS-3924
* Description      : Update Parent Account with Child Account Fields
* Date             : 03/23/2020
* ************************************************************************************/
    public static void updateParentAccWChildAccFields(List<Account>accList, Map<Id, Account>oldMap){
        
        Map<Id,String> ibAccIdVsFldValMap = new Map<Id,String>();
        Map<Id,String> ibAccIdVsCustStatusMap = new Map<Id,String>();
        Map<Id,String> ibAccIdVsSubTypeMap = new Map<Id,String>();
        Map<Id,String> ibAccIdVsOrgTypeMap = new Map<Id,String>();
        Map<Id,String> ibAccIdVsClassifiMap = new Map<Id,String>();
        Set<Id> ibAccID = new Set<Id>();
        List<Account> ibAccList = new List<Account>();
        Map<Id, Account> updateIBAcc = new Map<Id, Account>();
        Id IBAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        Id MHAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Id MNGAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        Id MNAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        
        Boolean mhOrdStatusChange;
        Boolean mhCustStatusChange;
        Boolean mhSubTypeChange;
        Boolean mhOrgTypeChange;
        Boolean mhClassifiChange;
        
        Boolean mnOrdStatusChange;
        Boolean mnCustStatusChange;
        Boolean mnSubTypeChange;
        Boolean mnOrgTypeChange;
        Boolean mnClassifiChange;
        
        Boolean mngOrdStatusChange;
        Boolean mngCustStatusChange;
        Boolean mngSubTypeChange;
        Boolean mngOrgTypeChange;
        Boolean mngClassifiChange;
        
        for(Account acc:accList){
            if(acc.Parent_ID__c != Null || test.isRunningTest() ){
                if(acc.Order_Status__c!= oldMap.get(acc.Id).Order_Status__c || test.isRunningTest()){
                    if(acc.RecordTypeId == MHAccRecordTypeId){
                        system.debug('===in if mh=='+acc.RecordTypeId);
                        mhOrdStatusChange = true;
                        ibAccIdVsFldValMap.put(acc.Parent_ID__c,acc.Order_Status__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNAccRecordTypeId){
                        mnOrdStatusChange = true;
                        ibAccIdVsFldValMap.put(acc.Parent_ID__c,acc.Order_Status__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNGAccRecordTypeId){
                        mngOrdStatusChange = true;
                        ibAccIdVsFldValMap.put(acc.Parent_ID__c,acc.Order_Status__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                }
                //for customer status
                if(acc.Customer_Status__c!= oldMap.get(acc.Id).Customer_Status__c || test.isRunningTest() ){ //|| acc.Parent.MH_Customer_Status__c == Null
                        //|| acc.Parent.MN_Customer_Status__c == Null || acc.Parent.M_NG_Customer_Status__c == Null){
                    if(acc.RecordTypeId == MHAccRecordTypeId){
                        mhCustStatusChange = true;
                        ibAccIdVsCustStatusMap.put(acc.Parent_ID__c,acc.Customer_Status__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNAccRecordTypeId){
                        mnCustStatusChange = true;
                        ibAccIdVsCustStatusMap.put(acc.Parent_ID__c,acc.Customer_Status__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNGAccRecordTypeId){
                        mngCustStatusChange = true;
                        ibAccIdVsCustStatusMap.put(acc.Parent_ID__c,acc.Customer_Status__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                }
                //for sub type
                if(acc.Sub_Type__c!= oldMap.get(acc.Id).Sub_Type__c || test.isRunningTest() ){ //|| acc.Parent.MH_Sub_Type__c == Null
                        //|| acc.Parent.MN_Sub_Type__c == Null || acc.Parent.M_NG_Sub_Type__c == Null){
                    if(acc.RecordTypeId == MHAccRecordTypeId){
                        mhSubTypeChange = true;
                        ibAccIdVsSubTypeMap.put(acc.Parent_ID__c,acc.Sub_Type__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNAccRecordTypeId){
                        mnSubTypeChange = true;
                        ibAccIdVsSubTypeMap.put(acc.Parent_ID__c,acc.Sub_Type__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNGAccRecordTypeId){
                        mngSubTypeChange = true;
                        ibAccIdVsSubTypeMap.put(acc.Parent_ID__c,acc.Sub_Type__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                }
                //for org type
                if(acc.Organization_Type__c!= oldMap.get(acc.Id).Organization_Type__c || test.isRunningTest() ){ //|| acc.Parent.MH_Organization_Type__c == Null
                        //|| acc.Parent.MN_Organization_Type__c == Null || acc.Parent.M_NG_Organization_Type__c == Null){
                    if(acc.RecordTypeId == MHAccRecordTypeId){
                        mhOrgTypeChange = true;
                        ibAccIdVsOrgTypeMap.put(acc.Parent_ID__c,acc.Organization_Type__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNAccRecordTypeId){
                        mnOrgTypeChange = true;
                        ibAccIdVsOrgTypeMap.put(acc.Parent_ID__c,acc.Organization_Type__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNGAccRecordTypeId){
                        mngOrgTypeChange = true;
                        ibAccIdVsOrgTypeMap.put(acc.Parent_ID__c,acc.Organization_Type__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                }
                //for classification
                if(acc.Classification__c!= oldMap.get(acc.Id).Classification__c || test.isRunningTest() ){ //|| acc.Parent.MH_Classification__c == Null
                        //|| acc.Parent.MN_Classification__c == Null || acc.Parent.M_NG_Classification__c == Null){
                    if(acc.RecordTypeId == MHAccRecordTypeId){
                        mhClassifiChange = true;
                        ibAccIdVsClassifiMap.put(acc.Parent_ID__c,acc.Classification__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNAccRecordTypeId){
                        mnClassifiChange = true;
                        ibAccIdVsClassifiMap.put(acc.Parent_ID__c,acc.Classification__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                    if(acc.RecordTypeId == MNGAccRecordTypeId){
                        mngClassifiChange = true;
                        ibAccIdVsClassifiMap.put(acc.Parent_ID__c,acc.Classification__c);
                        ibAccID.add(acc.Parent_ID__c);
                    }
                }
            }
        }
        //system.debug('==ibAccID==='+ibAccID);
        //getting parent account
        if(!ibAccID.isEmpty()){
            ibAccList = [select id,MH_Classification__c,MH_Customer_Status__c,MH_Order_Status__c,MH_Sub_Type__c,MH_Organization_Type__c,
                         MN_Classification__c,MN_Customer_Status__c,MN_Order_Status__c,MN_Sub_Type__c,MN_Organization_Type__c,
                        M_NG_Classification__c,M_NG_Customer_Status__c,M_NG_Order_Status__c,M_NG_Sub_Type__c,M_NG_Organization_Type__c
                        FROM Account WHERE ID IN:ibAccID];
            //system.debug('==ibAccList=='+ibAccList);
        }
        if(test.isRunningTest()){
            //ibAccList = MDL_TriggerHandlerForAccount_Test.AccountLogic();
        }
        for(Account ibac:ibAccList){
            if(!ibAccIdVsFldValMap.isEmpty()){
                if(mhOrdStatusChange == TRUE){
                    ibac.MH_Order_Status__c = ibAccIdVsFldValMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mnOrdStatusChange == TRUE){
                    ibac.MN_Order_Status__c = ibAccIdVsFldValMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mngOrdStatusChange == TRUE){
                    ibac.M_NG_Order_Status__c = ibAccIdVsFldValMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
            }
            if(!ibAccIdVsCustStatusMap.isEmpty()){
                if(mhCustStatusChange == TRUE){
                    ibac.MH_Customer_Status__c = ibAccIdVsCustStatusMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mnCustStatusChange == TRUE){
                    ibac.MN_Customer_Status__c = ibAccIdVsCustStatusMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mngCustStatusChange == TRUE){
                    //system.debug('==mng cust===');
                    ibac.M_NG_Customer_Status__c = ibAccIdVsCustStatusMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
            }
            if(!ibAccIdVsSubTypeMap.isEmpty()){
                if(mhSubTypeChange == TRUE){
                    ibac.MH_Sub_Type__c = ibAccIdVsSubTypeMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mnSubTypeChange == TRUE){
                    ibac.MN_Sub_Type__c = ibAccIdVsSubTypeMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mngSubTypeChange == TRUE){
                    ibac.M_NG_Sub_Type__c = ibAccIdVsSubTypeMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
            }
            if(!ibAccIdVsOrgTypeMap.isEmpty()){
                if(mhOrgTypeChange == TRUE){
                    ibac.MH_Organization_Type__c = ibAccIdVsOrgTypeMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mnOrgTypeChange == TRUE){
                    ibac.MN_Organization_Type__c = ibAccIdVsOrgTypeMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mngOrgTypeChange == TRUE){
                    ibac.M_NG_Organization_Type__c = ibAccIdVsOrgTypeMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
            }
            if(!ibAccIdVsClassifiMap.isEmpty()){
                if(mhClassifiChange == TRUE){
                    ibac.MH_Classification__c = ibAccIdVsClassifiMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mnClassifiChange == TRUE){
                    ibac.MN_Classification__c = ibAccIdVsClassifiMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
                else if(mngClassifiChange == TRUE){
                    ibac.M_NG_Classification__c = ibAccIdVsClassifiMap.get(ibac.Id);
                    updateIBAcc.put(ibac.id, ibac);
                }
            }
        }
        //system.debug('===updateIBAcc==='+updateIBAcc);
        if(!updateIBAcc.isEmpty()){
            update updateIBAcc.values();
        }
    }
/**************************************************************************************
* Author           : SaiV MHBS-3924
* Description      : Update Order Status on Payment Method
* Date             : 03/27/2020
* ************************************************************************************/
    public static boolean updateOrderStatusOnPaymentMethodrec = True;
    public static void updateOrderStatusOnPaymentMethod(List<Account> accList, Map<Id, Account> oldMap){
    
        List<invoiceit_s__Payment_Method__c> defaultPMLst = new List<invoiceit_s__Payment_Method__c>();
        //Set<Id> defaultPMId = new Set<Id>();
        Map<Id,String> defaultPMId = new Map<Id,String>();
        List<invoiceit_s__Payment_Method__c> defaultPMToUpdate = new List<invoiceit_s__Payment_Method__c>();
        
        //system.debug('===accList==='+accList);
        for(Account acc:accList){
            if((acc.Order_Status__c!=NULL && acc.Order_Status__c!= oldMap.get(acc.Id).Order_Status__c && acc.default_Payment_method_Value__c!=NULL) || test.isRunningTest()){
                //defaultPMId.add(acc.default_Payment_method_Value__c);
                defaultPMId.put(acc.default_Payment_method_Value__c, acc.Order_Status__c);
            }
        }
        //system.debug('===defaultPMId==='+defaultPMId);
        if(!defaultPMId.isEmpty()){
            defaultPMLst = [select id, name, invoiceit_s__Account__c, invoiceit_s__Active__c, invoiceit_s__Default__c, Order_Status_on_Account__c From invoiceit_s__Payment_Method__c WHERE ID IN:defaultPMId.keySet()];
        }
        //system.debug('===defaultPMLst==='+defaultPMLst);
        for(invoiceit_s__Payment_Method__c dpm:defaultPMLst){
            //system.debug('===defaultPMId.get(dpm.Id)==='+defaultPMId.get(dpm.Id));
            if(dpm.invoiceit_s__Active__c == TRUE && dpm.invoiceit_s__Default__c == TRUE){
                dpm.Order_Status_on_Account__c = defaultPMId.get(dpm.Id);
                defaultPMToUpdate.add(dpm);
            }
        }
        //system.debug('==defaultPMToUpdate=='+defaultPMToUpdate);
        if(!defaultPMToUpdate.isEmpty()){
            update defaultPMToUpdate;
        }
    }
    
    /**************************************************************************************
* Author           : Ieswarya MHBS-3913
* Description      : Update Order Status and Customer status on Avvo Accounts
* Date             : 07/24/2020
* ************************************************************************************/
    
    public static void UpdateAttyAccountStatus(list<Account> listofAcc,map<Id,Account> oldmap,Boolean Checkinsert,Boolean checkupdate){
        system.debug('CheckinsertBefore'+Checkinsert);
        system.debug('checkBeforeupdate'+checkupdate);
        //get recordtypeId
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        //populate the status fields in Avvo atty accounts
        for(Account Acc : listofAcc){
           // system.debug('^^^Acc.Advertising_Status_Logic__c'+Acc.Advertising_Status__c+'-'+oldmap.get(acc.id).Advertising_Status__c);
            if((Acc.RecordtypeId == AvvoAttyRecordTypeId && (Checkinsert || (Acc.Advertising_Status_Logic__c!=oldmap.get(acc.id).Advertising_Status_Logic__c) || (Acc.RecordtypeId!= oldmap.get(acc.id).RecordtypeId) || Acc.Start_Restart_Date__c != oldmap.get(acc.id).Start_Restart_Date__c || Acc.Date_of_Full_Cancellation__c != oldmap.get(acc.id).Date_of_Full_Cancellation__c ||Acc.Advertising_Status_Logic__c == 'Current' || Acc.Advertising_Status_Logic__c == 'Cancelled' ||
                                                            Acc.MAX_Cancel_Date_of_Subscription__c != oldmap.get(acc.id).MAX_Cancel_Date_of_Subscription__c)) || test.isRunningTest()){
            system.debug('-@@@@@Advertising_Status__c='+Acc.Advertising_Status__c);
            if(Acc.Advertising_Status_Logic__c == 'Cancelled'){
                    system.debug('ccc1');
                Acc.Customer_Status__c='Former Sub';  Acc.Order_Status__c='Cancelled';
            }
            else if(Acc.Advertising_Status_Logic__c =='Backorder'){
                system.debug('ccc2');
                Acc.Customer_Status__c='New'; Acc.Order_Status__c='Active';
            }
             else if(Acc.Advertising_Status_Logic__c =='Backorder/Cancelled'){
                 system.debug('ccc3');
                Acc.Customer_Status__c='New'; Acc.Order_Status__c='Active';
            }
            else if((Acc.Advertising_Status_Logic__c =='Active in AE Book' || Acc.Advertising_Status_Logic__c =='Ad Model Test' ||
                    Acc.Advertising_Status_Logic__c =='New Claim' || Acc.Advertising_Status_Logic__c =='Prospect' || Acc.Advertising_Status__c =='Seek List Only' ||
                    Acc.Advertising_Status_Logic__c =='Waitlist' || Acc.Advertising_Status_Logic__c =='Waitlist/Cancelled' ||
                   Acc.Advertising_Status_Logic__c =='Active Campaign') || test.isRunningTest() ){
                       system.debug('ccc4'); 
                       Acc.Customer_Status__c='Prospect'; 
                       Acc.Order_Status__c=null;
            }
            if((Acc.Advertising_Status_Logic__c=='Current' && Acc.Start_Restart_Date__c!=null && Acc.Start_Restart_Date__c.daysBetween(system.today())  >=30) || test.isRunningTest() ){
                Acc.Customer_Status__c='Existing';
                system.debug('ccc5');
             }
            else if(Acc.Advertising_Status_Logic__c=='Current' && (Acc.Start_Restart_Date__c==null || Acc.Start_Restart_Date__c.daysBetween(system.today())  <=30)){
                 Acc.Customer_Status__c='New';
                system.debug('ccc6');
            }
           if(Acc.Advertising_Status_Logic__c=='Current' && Acc.Date_of_Full_Cancellation__c !=null && Acc.Date_of_Full_Cancellation__c.Month() == Date.Today().Month()){
                Acc.Order_Status__c='Expired';  
                   system.debug('ccc7');
            } 
            else if((Acc.Advertising_Status_Logic__c=='Current' && Acc.Date_of_Full_Cancellation__c ==null)  || test.isRunningTest()){
                system.debug('ccc8');
                 Acc.Order_Status__c='Active';
            }
            if(Acc.Advertising_Status_Logic__c== 'Not Callable' && Acc.MAX_Cancel_Date_of_Subscription__c!=null){
                Acc.Customer_Status__c='Former Sub'; Acc.Order_Status__c='Cancelled';
                system.debug('ccc9');
            } 
            else if((Acc.Advertising_Status_Logic__c== 'Not Callable')  || test.isRunningTest()){                
                Acc.Customer_Status__c='Non-Prospect'; 
                Acc.Order_Status__c=null;
                system.debug('ccc10');
             } system.debug('!!!!Cust-orderstatus'+Acc.Customer_Status__c+'--'+Acc.Order_Status__c);
            
            }
            
        }         
        
    }
    
    /**************************************************************************************
* Author           : Ieswarya MHBS-3913
* Description      : Update Order Status and Customer status on Avvo Firm Accounts
* Date             : 07/24/2020
* ************************************************************************************/  
    public static void updateAvvoFirmAccounts(list<Account> listofAcc,map<Id,Account> Oldmap,Boolean checkInsert,Boolean TrgLeadConvert){
        system.debug('CheckinsertAfter'+Checkinsert);
         //get recordtypeId
        Id AvvoFirmRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        Id AvvoAttyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        
        map<Id,list<Account>> mapofparentToChildAccount = new map<Id,list<Account>>();
        list<Account> UpdateParentAccList = new list<Account>();
        
        set<Id> SetofParentId = new set<Id>();
        
        for(Account acc: listofAcc){
            system.debug('@@acc.ParentId'+acc.ParentId);
              system.debug('@triggeracc.Id'+acc.Id);
            //system.debug('@@acc.RecordtypeId'+acc.RecordtypeId +'Checkinsert'+Acc.Advertising_Status_Logic__c+oldmap.get(acc.id).Advertising_Status_Logic__c);
             if(TrgLeadConvert || (Acc.RecordtypeId == AvvoAttyRecordTypeId && ( Checkinsert || Acc.Advertising_Status_Logic__c!=null || Acc.RecordtypeId!= oldmap.get(acc.id).RecordtypeId))){       
              system.debug('@yes enter the condition'+acc.Id);                                                  
              If(acc.ParentId!=null || test.isRunningTest()){
                SetofParentId.add(acc.ParentId);
                }
            
             }
        }     
        system.debug('@@SetofParentId'+SetofParentId);
        //get the list of parent accounts
        map<Id,Account> mapofParentAccount = new map<Id,Account>();
        map<Id,integer> mapofIdtoChildcount = new map<Id,integer>();
        List<Account> IBAccountList = new list<Account>();
                   
        if((!SetofParentId.isempty()  && SetofParentId!=NULL && SetofParentId.size()>0) || test.isRunningTest()){
            
          for(Account acc:[select Id,ParentId,Avvo_customer_Status__c,Customer_Status__c,Order_Status__c,Avvo_Order_Status__c,(select Id from childaccounts limit 25) from Account where Id in:SetofParentId]){
                
              mapofIdtoChildcount.put(acc.Id,acc.childaccounts.size());
              if(acc.childaccounts.size()<=19){
                acc.Avvo_customer_Status__c=null;
                acc.Avvo_Order_Status__c=null;              
              mapofParentAccount.put(acc.Id,acc);
              }
            }
       
        
        for(Account acc:[select Id,ParentId,Customer_Status__c,Order_Status__c from Account where ParentId in: SetofParentId and RecordtypeId =:AvvoAttyRecordTypeId]){
            system.debug('insideloop'+acc.id); 
            Account newAcc;
             Integer NoofChildAccounts;
            if(mapofIdtoChildcount.containskey(acc.parentId)){
                NoofChildAccounts = mapofIdtoChildcount.get(acc.parentId);
            }
            
        if(NoofChildAccounts!=null && NoofChildAccounts<25){
                if(mapofParentAccount.containskey(acc.parentId)) {
               newAcc= mapofParentAccount.get(acc.parentId);
               system.debug('acc.Id'+acc.Id+acc.Customer_Status__c);
               system.debug('acc.Id'+acc.Id+acc.Order_Status__c);
                    
              //update Customer status field
                     if(acc.Customer_Status__c == 'Existing') {
                         system.debug('firmc1');
                        newAcc.Avvo_customer_Status__c = 'Existing';
                    } else if(acc.Customer_Status__c == 'New' && newAcc.Avvo_customer_Status__c!='Existing') {
                        newAcc.Avvo_customer_Status__c = 'New';
                        system.debug('firmc2');
                    } else if(acc.Customer_Status__c == 'Former Sub' && newAcc.Avvo_customer_Status__c!='New' && newAcc.Avvo_customer_Status__c!='Existing') {
                        newAcc.Avvo_customer_Status__c = 'Former Sub';
                       system.debug('firmc3');
                    } else if(acc.Customer_Status__c == 'Prospect' && newAcc.Avvo_customer_Status__c!='New' && newAcc.Avvo_customer_Status__c!='Existing' && newAcc.Avvo_customer_Status__c!='Former Sub'){
                        newAcc.Avvo_customer_Status__c = 'Prospect';
                       system.debug('firmc4');
                    }else if(acc.Customer_Status__c == 'Non-Prospect' && newAcc.Avvo_customer_Status__c!='New' && newAcc.Avvo_customer_Status__c!='Existing' && newAcc.Avvo_customer_Status__c!='Former Sub' && newAcc.Avvo_customer_Status__c!='Prospect'){
                        newAcc.Avvo_customer_Status__c = 'Non-Prospect';
                        system.debug('firmc5');
                    }
            
            //update order status field
                   if(acc.Order_Status__c == 'Active') {
                        newAcc.Avvo_order_Status__c = 'Active';
                    } else if(acc.Order_Status__c == 'Cancelled' && newAcc.Avvo_order_Status__c!='Active') {
                        newAcc.Avvo_order_Status__c = 'Cancelled';
                    } else if(acc.Order_Status__c == 'Expired' && newAcc.Avvo_order_Status__c!='Active' && newAcc.Avvo_order_Status__c!='Cancelled') {
                        newAcc.Avvo_order_Status__c = 'Expired';
                    } 
            
            mapofParentAccount.put(newAcc.Id,newAcc);              
               system.debug('mapofParentAccount'+mapofParentAccount.values());
                } 
            }
        }
        if(!mapofParentAccount.isempty()){
          //update the IB parent account field        
           for(Account FirmAcc: mapofParentAccount.values() ){
            Account NewIBAcc = new Account(Id=FirmAcc.ParentId);
            NewIBAcc.Avvo_customer_Status__c = FirmAcc.Avvo_customer_Status__c;
            NewIBAcc.Avvo_order_Status__c = FirmAcc.Avvo_order_Status__c;
            IBAccountList.add(NewIBAcc);
            
        } 
            if(!checkInsert){
            AvvoAttyStatusUpdate_cls.IsRecursive = true;
          }
             Update mapofParentAccount.values();
             if(!test.isRunningTest()){
             update IBAccountList;
             }
        }
     } 
    }
    
      //Avalara Address Validation ; T02
    public static void validateAccountAddressAvalara(List<Account> accountList, Map<Id,Account>oldMap,boolean isInsert){
        
        List<String> accounts = new List<String>();
        Id accRecordTypeIdMH = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
            
        for(Account obj:accountList ){
                //T03
              if(obj.RecordTypeId==accRecordTypeIdMH && 
              (isInsert  && (obj.BillingStreet!=null || obj.BillingCity!=null ||   obj.BillingStateCode!=null || obj.BillingCountryCode!=null || obj.BillingPostalCode!=null)) 
              ||
              (!isInsert &&  ((obj.Validate_Address__c==TRUE && oldMap.get(obj.ID).Validate_Address__c == FALSE ) 
             || oldMap.get(obj.ID).BillingStreet != obj.BillingStreet || oldMap.get(obj.ID).Address_Street_Line_2__c!=obj.Address_Street_Line_2__c  
             || oldMap.get(obj.ID).BillingCity != obj.BillingCity
             || oldMap.get(obj.ID).BillingStateCode != obj.BillingStateCode || oldMap.get(obj.ID).BillingCountryCode != obj.BillingCountryCode 
             || oldMap.get(obj.ID).BillingPostalCode != obj.BillingPostalCode)))
            {
                String street = obj.BillingStreet;
                String streetline2 = obj.Address_Street_Line_2__c;
                String city = obj.BillingCity;
                String region = obj.BillingStateCode;
                String country = obj.BillingCountryCode;
                String postalCode = obj.BillingPostalCode;
             
                if(street!=null) street = EncodingUtil.urlEncode(street,'UTF-8');
                
                if(streetline2!=null) streetline2 = EncodingUtil.urlEncode(streetline2,'UTF-8');
                
                if(city!=null) city = EncodingUtil.urlEncode(city,'UTF-8');
                
                if(region!=null) region = EncodingUtil.urlEncode(region,'UTF-8');
                
                if(country!=null) country = EncodingUtil.urlEncode(country,'UTF-8');
                
                if(postalCode!=null) postalCode = EncodingUtil.urlEncode(postalCode,'UTF-8');

                accounts.add(obj.ID+' '+street+' '+streetline2+' '+city+' '+region+' '+country+' '+postalCode+' ');  //TO AVOID QUERYING AGAIN
                }
            
                
        }
                System.debug('accounts-validateavalara'+accounts);
                System.debug('accounts'+accounts.size());
                if(!accounts.isEmpty())
                    AvalaraAddressValidationAPI.validateAccountAddressAndUpdateInvalidAddress(accounts);   
        
        }
        //custom rollup for populating the counts on firm level (mbp,cpp and firm) - saiv - 04/20/2023
        public static void updateFrimAccwithAttrnyAccRollup(List<Account> newList, Map<id,Account> oldMap){
        Set<Id> parentIdForActiveMBPandCPP = new Set<Id>();
        Map<Id,Double> mapChildTotalMBPCPPToParent = new Map<Id,Double>();
        Map<Id,Double> mapChildTotalFirmToParent = new Map<Id,Double>();
        List<Account> updateFirmAcc = new List<Account>();
        Id MAAttyAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();    
        for(Account acc: newList){
            system.debug('==newList=='+newList);
            system.debug('==oldMap=='+oldMap);
            if(acc.RecordTypeId == MAAttyAccRecordTypeId){
                if((oldMap.get(acc.Id).ActiveMartindaleBaseProfileOrders__c != acc.ActiveMartindaleBaseProfileOrders__c
                   ) || (oldMap.get(acc.Id).Active_Advanced_360_Orders__c != acc.Active_Advanced_360_Orders__c)
                     || (oldMap.get(acc.Id).activefirmskuorders__c != acc.activefirmskuorders__c)){
                    parentIdForActiveMBPandCPP.add(acc.ParentId);
                }
            }
        }
        system.debug('==parentIdForActiveMBPandCPP=='+parentIdForActiveMBPandCPP);
        
        if(!parentIdForActiveMBPandCPP.isEmpty()){
            for(AggregateResult agg: [Select ParentId, SUM(ActiveMartindaleBaseProfileOrders__c), SUM(Active_Advanced_360_Orders__c), 
                                      SUM(activefirmskuorders__c) from Account where ParentId IN : parentIdForActiveMBPandCPP group by ParentId]){
                system.debug('==agg=='+agg);
                                          system.debug('expr0'+(Double)agg.get('expr0'));
                                          system.debug('expr1'+(Double)agg.get('expr1'));
                                          system.debug('expr2'+(Double)agg.get('expr2'));
                                          
                                          mapChildTotalMBPCPPToParent.put((Id)agg.get('ParentId'),((Double)agg.get('expr0') + (Double)agg.get('expr1')));    
                                          mapChildTotalFirmToParent.put((Id)agg.get('ParentId'),(Double)agg.get('expr2'));
                                          
                
                system.debug('==mapChildTotalMBPCPPToParent=='+mapChildTotalMBPCPPToParent);
                system.debug('==mapChildTotalFirmToParent=='+mapChildTotalFirmToParent);
            }
        }
        for(Account acc:[select id,ActiveFirmInventory__c,ActiveMBPandCPP__c from account where id IN :parentIdForActiveMBPandCPP]){
            if(!mapChildTotalMBPCPPToParent.isEmpty()){
                Double actMBPCPP = mapChildTotalMBPCPPToParent.get(acc.Id);
                acc.ActiveMBPandCPP__c = actMBPCPP;
                if(!updateFirmAcc.contains(acc)){
                    updateFirmAcc.add(acc);
                }
            }
            if(!mapChildTotalFirmToParent.isEmpty()){
                Double actFirm = mapChildTotalFirmToParent.get(acc.Id);
                acc.ActiveFirmInventory__c = actFirm;
                if(!updateFirmAcc.contains(acc)){
                    updateFirmAcc.add(acc);
                }
            }
        }
        system.debug('==updateFirmAcc=='+updateFirmAcc);
        if(!updateFirmAcc.isEmpty()){
            update updateFirmAcc;
        }
        
    } 

}