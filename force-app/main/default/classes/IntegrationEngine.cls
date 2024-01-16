public without sharing class IntegrationEngine {

    public static boolean isFutureUpdate = false;
    public static Map<Id, Id> mapAcctVsContId = new Map<Id,Id>();
    public static Map<Id, Id> accountIdVsContactIdMap = new Map<Id,Id>();
    

    public static integer IntegrateAccounts_BananaStand(List<Account> accounts) {
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();
        Set<Id> contactIdSet = new Set<Id>();
        List<Contact> contactListToIntegrate = new List<Contact>();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return 0;
        }

        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
        List<Error_Log__c> integrationQueues = CreateIntegrationQueues(accountMap.keySet());

        List<AccountContactRelation> accountContact = [  SELECT AccountId, ContactId
                                    FROM AccountContactRelation
                                    WHERE IsDirect = False AND AccountId in :accountMap.keySet()];
        System.debug('@@@@@@accountContactList--------------------->'+accountContact );
        if(accountContact.size() > 0){
            for(AccountContactRelation accr: accountContact){
                if(accr.ContactId!=Null){
                    contactIdSet.add(accr.ContactId);
                    mapAcctVsContId.put(accr.contactId,accr.accountId);
                }
            }
            System.debug('@@@@@@@Contact Id Set------------->'+contactIdSet);
            System.debug('@@@@@@@What is in the map---------->'+mapAcctVsContId);
            contactListToIntegrate = [Select Id, Name,AccountId,Professional_Id__c From Contact where id in: contactIdSet]; 
            
            System.debug('Contact lIst to Integrate------------------------>'+contactListToIntegrate);
            if(contactListToIntegrate.size()>0 ){
               // integrationQueues.addAll(CreateIntegrationQueuesConvert(contactListToIntegrate));
            }
        }

        IntegrateQueues(integrationQueues, integrationQueues.size());
        return integrationQueues.size();
    }
     public static integer IntegrateAccounts_BananaStandConvert(List<Account> accounts,List<Contact> contactsToIntegrate,Map<Id,Id> accountIdVsContactIdMap) {
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();
        Set<Id> contactIdSet = new Set<Id>();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return 0;
        }
        System.debug('@@@@@@@@@accountIdVsContactIdMap--------->'+accountIdVsContactIdMap);
        System.debug('@@@@@@@@@contactsToIntegrate--------->'+contactsToIntegrate);
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
        List<Error_Log__c> integrationQueues = CreateIntegrationQueues(accountMap.keySet());
        
        integrationQueues.addAll(CreateIntegrationQueuesConvert(contactsToIntegrate,accountIdVsContactIdMap));
        IntegrateQueues(integrationQueues, integrationQueues.size());
        return integrationQueues.size();
    }
     // Commneting this method as it is not being used - Ronak - 10/15/2019
     /*public static integer IntegrateContacts_BananaStandProfessionalsSyncCreateRelationship(List<Contact> contacts){
        Integration_Settings__c integrationSettings = Integration_Settings__c.getInstance();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return 0;
        }

        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();

        Set<Id> accountIds = new Set<Id>();
        for(Contact c : contacts){
            accountIds.add(c.AccountId);
        }

        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id in :accountIds AND Customer_ID__c = null]);

        if(accountMap.keySet().size() > 0){
            integrationQueues.addAll(CreateIntegrationQueues(accountMap.keySet()));
        }

        integrationQueues.addAll(CreateIntegrationQueues(contacts));
        IntegrateQueues(integrationQueues, integrationQueues.size());

        return integrationQueues.size();
    }*/
    
    //Commenting this logic as it is not being used. - Ronak - 10/15/2019
    /*public static integer CreateIntegrationQueuesAccountsAndContacts_BananaStand(List<Account> accounts, List<Contact> contacts) {
        System.debug('@@@@@@@Accounts list---------------->'+accounts);
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return 0;
        }

        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();

        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);

        integrationQueues.addAll(CreateIntegrationQueues(accountMap.keySet()));
        integrationQueues.addAll(CreateIntegrationQueues(contacts));

        return integrationQueues.size();
    }*/

    private static List<Error_Log__c> CreateIntegrationQueues(Set<Id> accountIds) {
        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        for (Id accountId : accountIds) {
            integrationQueues.add(new Error_Log__c(
                    Account_Name__c = accountId,
                    Number_Of_Attempts__c = 0,
                    Status__c = 'New',
                    Integration__c = 'Banana Stand',
                    Order_Name__c ='Avvo Business',
                    Error_Reason__c = 'Banana Stand'
            ));
        }

        return integrationQueues;
    }
    
    private static List<Error_Log__c> CreateIntegrationQueues(List<Contact> contacts) {
        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        for (Contact contact : contacts) {
            if(contact.Professional_Id__c != null) {
                integrationQueues.add(new Error_Log__c(
                        Account_Name__c = contact.Accountid,
                        Contact__c = contact.Id,
                        Professional_Id__c = contact.Professional_Id__c,
                        Number_Of_Attempts__c = 0,
                        Status__c = 'New',
                        Integration__c = 'Banana Stand Professionals Sync Create',
                        //Integration__c = 'Banana Stand',
                        Order_Name__c ='Avvo Business',
                    Error_Reason__c = 'Banana Stand Professionals Sync Create'
                ));
            }
        }

        return integrationQueues;
    }
    
    private static List<Error_Log__c> CreateIntegrationQueuesConvert(List<Contact> contacts, Map<Id,Id> accountIdVsContactIdMap) {
        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        System.debug('@@@@@@@@@@@@@@@@@Inside my method-------->');
        String accountId;
        for (Contact contact : contacts) {
            System.debug('@@@@@@@@@@accountIdVsContasadadasdctIdMap'+accountIdVsContactIdMap);
            System.debug('@@@@@@@@@@True or False---->'+accountIdVsContactIdMap.containskey(contact.Id));
            if(accountIdVsContactIdMap.containskey(contact.Id)){
                accountId = accountIdVsContactIdMap.get(contact.Id);
            }
            if(contact.Professional_Id__c != null) {
                integrationQueues.add(new Error_Log__c(
                        Account_Name__c = accountId,
                        Contact__c = contact.Id,
                        Professional_Id__c = contact.Professional_Id__c,
                        Number_Of_Attempts__c = 0,
                        Status__c = 'New',
                        Integration__c = 'Banana Stand Professionals Sync Create',
                        //Integration__c = 'Banana Stand',
                        Order_Name__c ='Avvo Business',
                    Error_Reason__c = 'Banana Stand Professionals Sync Create'
                ));
            }
        }

        return integrationQueues;
    }
    
    //Commenting this logic as it is not being used anywhere - Ronak - 10/15/2019
    /*public static void IntegrateContacts_BananaStandProfessionalsSyncDeleteRelationship(List<Contact> contacts){
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();

        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return;
        }

        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        for (Contact contact : contacts) {
            integrationQueues.add(new Error_Log__c(
                    Account_Name__c = contact.accountId,
                    Contact__c = contact.Id,
                    Professional_Id__c = contact.Professional_Id__c,
                    Number_Of_Attempts__c = 0,
                    Status__c = 'New',
                    Integration__c = 'Banana Stand Professionals Sync Destroy',
                    Order_Name__c ='Avvo Business',
                    Error_Reason__c = 'Banana Stand Professionals Sync Destroy'
            ));
        }

        IntegrateQueues(integrationQueues,
                integrationQueues.size());
    }*/

    //Commenting this logic as it is not required - Ronak - 10/15/2019
    /*public static void IntegrateContacts_BananaStandProfessionalsSyncCreateAndDeleteRelationship(List<Contact> oldContacts, List<Contact> newContacts){
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return;
        }

        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        for (Contact contact : oldContacts) {
            integrationQueues.add(new Error_Log__c(
                    Account_Name__c = contact.accountId,
                    Contact__c = contact.Id,
                    Professional_Id__c = contact.Professional_Id__c,
                    Number_Of_Attempts__c = 0,
                    Status__c = 'New',
                    Integration__c = 'Banana Stand Professionals Sync Destroy',
                    //Integration__c ='Play',
                    Order_Name__c ='Avvo Business',
                    Error_Reason__c = 'Banana Stand Professionals Sync Destroy'
            ));
        }
        for (Contact contact : newContacts) {
            integrationQueues.add(new Error_Log__c(
                    Account_Name__c = contact.accountId,
                    Contact__c = contact.Id,
                    Professional_Id__c = contact.Professional_Id__c,
                    Number_Of_Attempts__c = 0,
                    Status__c = 'New',
                    Integration__c = 'Banana Stand Professionals Sync Create',
                    //Integration__c = 'Banana Stand',
                    Order_Name__c ='Avvo Business',
                    Error_Reason__c = 'Banana Stand Professionals Sync Create'
            ));
        }

        IntegrateQueues(integrationQueues,
                integrationQueues.size());
    }*/
    
    //Commenting this logic as we are not using the Account Contact standard relation for Avvo 
    /*public static void IntegrateContacts_BananaStandProfessionalsSyncCreateRelationship(List<AccountContactRelation> relations){
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return;
        }

        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        for (AccountContactRelation relation : relations) {
            integrationQueues.add(new Error_Log__c(
                Account_Name__c = relation.accountId,
                Contact__c = relation.contactId,
                Professional_Id__c = relation.Contact.Professional_ID__c,
                Number_Of_Attempts__c = 0,
                Status__c = 'New',
                Integration__c = 'Banana Stand Professionals Sync Create',
                //Integration__c = 'Banana Stand',
                Order_Name__c ='Avvo Business',
                Error_Reason__c = 'Banana Stand Professionals Sync Create'
            ));
        }
        IntegrateQueues(integrationQueues,
                integrationQueues.size());
    }*/
    
    //Commenting this code logic as we are not utilizing the standard Account COntact Relation object - Ronak - 10/15/2019
    /*public static void IntegrateContacts_BananaStandProfessionalsSyncDeleteRelationship(List<AccountContactRelation> relations){
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return;
        }

        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        for (AccountContactRelation relation : relations) {
            integrationQueues.add(new Error_Log__c(
                    Account_Name__c = relation.accountId,
                    Contact__c = relation.contactId,
                    Professional_Id__c = relation.Contact.Professional_Id__c,
                    Number_Of_Attempts__c = 0,
                    Status__c = 'New',
                    Integration__c = 'Banana Stand Professionals Sync Destroy',
                    Order_Name__c ='Avvo Business',
                    Error_Reason__c = 'Banana Stand Professionals Sync Destroy'
            ));
        }

        IntegrateQueues(integrationQueues,
                integrationQueues.size());
    }*/
    
    //created for account contact custom object - 05/13/19
    public static void IntegrateContacts_BananaStandProfessionalsSyncCreateRelationship(List<Account_Contact_Relation__c> relations){
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return;
        }
        system.debug('====relations===='+relations);
        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        for (Account_Contact_Relation__c relation :[select id, name, Account__c, Contact__c, Contact__r.Professional_ID__c from Account_Contact_Relation__c where Id IN:relations]) {
            system.debug('===PID of Contact==='+relation.Contact__r.Professional_ID__c);
            integrationQueues.add(new Error_Log__c(
                Account_Name__c = relation.Account__c,
                Contact__c = relation.Contact__c,
                Professional_Id__c = relation.Contact__r.Professional_ID__c,
                Number_Of_Attempts__c = 0,
                Status__c = 'New',
                Integration__c = 'Banana Stand Professionals Sync Create',
                //Integration__c = 'Banana Stand',
                Order_Name__c ='Avvo Business',
                Error_Reason__c = 'Banana Stand Professionals Sync Create'
            ));
        }
        IntegrateQueues(integrationQueues,
                integrationQueues.size());
    }
    
    public static void IntegrateContacts_BananaStandProfessionalsSyncDeleteRelationship(List<Account_Contact_Relation__c> relations){
        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();
        if (integrationSettings.Disable_Banana_Stand_Integration__c) {
            return;
        }

        List<Error_Log__c> integrationQueues = new List<Error_Log__c>();
        for (Account_Contact_Relation__c relation :[select id, name, Account__c, Contact__c, Contact__r.Professional_ID__c from Account_Contact_Relation__c where Id IN:relations]) {
            integrationQueues.add(new Error_Log__c(
                    Account_Name__c = relation.Account__c,
                    Contact__c = relation.Contact__c,
                    Professional_Id__c = relation.Contact__r.Professional_ID__c,
                    Number_Of_Attempts__c = 0,
                    Status__c = 'New',
                    Integration__c = 'Banana Stand Professionals Sync Destroy',
                    Order_Name__c ='Avvo Business',
                    Error_Reason__c = 'Banana Stand Professionals Sync Destroy'
            ));
        }

        IntegrateQueues(integrationQueues,
                integrationQueues.size());
    }
    //end - 05/13/19

    private static void IntegrateQueues(List<Error_Log__c> integrationQueues, integer requestsToSend) {
        System.debug('@@@@@@@ Integration queues---------------->'+integrationQueues);
        System.debug('@@@@@isFutureUpdate '+isFutureUpdate );
        if (isFutureUpdate || System.IsFuture()) {
            new IntegrationEngine_BatchProcessRecords().Execute(null, integrationQueues);
            return;
        }

        insert integrationQueues;
        if (requestsToSend >= Limits.getLimitCallouts()) {
            IntegrationEngine_BatchProcessRecords.scheduleBatchJob();
        }
        else if (!isFutureUpdate) {
            Set<Id> recordIds = new Map<Id, Error_Log__c>(integrationQueues).keySet();
            RunNow(recordIds);
        }
    }

    @future(callout=true)
    private static void RunNow(Set<Id> integrationQueueIds) {
        isFutureUpdate = true;
        Error_Log__c[] records = [
                SELECT Id, Account_Name__c, Contact__c, Professional_Id__c, Integration__c, Number_of_Attempts__c, Status__c
                FROM Error_Log__c
                WHERE Id IN :integrationQueueIds];

        new IntegrationEngine_BatchProcessRecords().Execute(null, records);
    }
}