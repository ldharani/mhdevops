public abstract class IntegrationEngine_BatchBase implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    protected Boolean processedRecords = false;
    @testVisible
    private static integer maxErrorLength = Error_Log__c.Error_Message__c.getDescribe().getLength();
    private static integer maxResponseLength = Error_Log__c.API_Response__c.getDescribe().getLength();

    public void Execute(Database.BatchableContext bc, List<sObject> records) {
        Map<Id, Set<Error_Log__c>> accountsToSendToBananaStand = new Map<Id, Set<Error_Log__c>>();

        Map<string, Set<Error_Log__c>> contactsToSendToCreateRelationshipBananaStand = new Map<string, Set<Error_Log__c>>();
        Set<BananaStandAccountContactRelation> contactRelationsToCreateBananaStand = new Set<BananaStandAccountContactRelation>();

        Map<string, Set<Error_Log__c>> contactsToSendToDeleteRelationshipBananaStand = new Map<string, Set<Error_Log__c>>();
        Set<BananaStandAccountContactRelation> contactRelationsToDeleteBananaStand = new Set<BananaStandAccountContactRelation>();

        //Map<Id, Set<Error_Log__c>> playsToUpdate = new Map<Id, Set<Error_Log__c>>();

        Set<Error_Log__c> integrationQueuesToDelete = new Set<Error_Log__c>();
        Set<Error_Log__c> successfulIntegrationQueues = new Set<Error_Log__c>();
        Set<Error_Log__c> integrationQueuesToUpdate = new Set<Error_Log__c>();
        //Commented by ronak for account contact relationship object
        Set<AccountContactRelation> relationsToDelete = new Set<AccountContactRelation>();
        Set<Account> accountsToUpdate = new Set<Account>();

        Integration_Settings__c integrationSettings = Integration_Settings__c.getInstance();
        System.debug('Records in the query---------->'+records);
        
        for (Sobject record : records) {
            Error_Log__c integrationQueue = (Error_Log__c)record;
            integrationQueue.Number_of_Attempts__c += 1;

            if (integrationQueue.Integration__c == 'Banana Stand') {
                if (integrationQueue.Account_Name__c!= null) {
                    if (accountsToSendToBananaStand.containsKey(integrationQueue.Account_Name__c) == false) {
                        accountsToSendToBananaStand.put(
                                integrationQueue.Account_Name__c,
                                new Set<Error_Log__c>());
                    }
                    accountsToSendToBananaStand.get(integrationQueue.Account_Name__c).add(integrationQueue);
                } else {
                    if (integrationQueue.Id != null) {
                        integrationQueuesToDelete.add(integrationQueue);
                    }
                }
            }
            else if (integrationQueue.Integration__c == 'Banana Stand Professionals Sync Create'){
                if(integrationQueue.Contact__c != null && integrationQueue.Account_Name__c!= null){
                    BananaStandAccountContactRelation relation = new BananaStandAccountContactRelation(
                        integrationQueue.Account_Name__c,
                        integrationQueue.Contact__c,
                        integrationQueue.Professional_Id__c);

                    string key = relation.getKey();
                    if (contactsToSendToCreateRelationshipBananaStand.containsKey(key) == false){
                        contactsToSendToCreateRelationshipBananaStand.put(
                                key,
                                new Set<Error_Log__c>());

                        contactRelationsToCreateBananaStand.add(relation);
                    }
                    contactsToSendToCreateRelationshipBananaStand.get(key).add(integrationQueue);
                }
                else {
                    if (integrationQueue.Id != null) {
                        integrationQueuesToDelete.add(integrationQueue);
                    }
                }
            }
            else if (integrationQueue.Integration__c == 'Banana Stand Professionals Sync Destroy'){
                if(integrationQueue.Contact__c != null && integrationQueue.Account_Name__c!= null){
                    BananaStandAccountContactRelation relation = new BananaStandAccountContactRelation(
                        integrationQueue.Account_Name__c,
                        integrationQueue.Contact__c,
                        integrationQueue.Professional_Id__c);

                    string key = relation.getKey();
                    if (contactsToSendToDeleteRelationshipBananaStand.containsKey(key) == false){
                        contactsToSendToDeleteRelationshipBananaStand.put(
                            key,
                            new Set<Error_Log__c>());

                        contactRelationsToDeleteBananaStand.add(relation);
                    }
                    contactsToSendToDeleteRelationshipBananaStand.get(key).add(integrationQueue);
                }
                else {
                    if (integrationQueue.Id != null) {
                        integrationQueuesToDelete.add(integrationQueue);
                    }
                }
            }
            /*else if(integrationQueue.Integration__c == 'Play') {
                if (integrationQueue.Task_Id__c != null) {
                    if (playsToUpdate.containsKey(integrationQueue.Task_Id__c) == false) {
                        playsToUpdate.put(
                                integrationQueue.Task_Id__c,
                                new Set<Error_Log__c>());
                    }
                    playsToUpdate.get(integrationQueue.Task_Id__c).add(integrationQueue);
                } else {
                    if (integrationQueue.Id != null) {
                        integrationQueuesToDelete.add(integrationQueue);
                    }
                }
            }*/
            else {
                integrationQueue.Error_Message__c = 'Unknown integration message "' + integrationQueue.Integration__c + '"';
                integrationQueue.Status__c = 'Error';
                integrationQueue.Date_Time_Submitted__c = system.now();
                integrationQueuesToUpdate.add(integrationQueue);
            }
        }

        if (accountsToSendToBananaStand.size() > 0) {
            List<Account> accounts = [
                    SELECT Id, Name, Avvo_CustomerID__c, Auto_Customer_Number__c,parent.Auto_Customer_Number__c,Parent.Name,Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Contact_Email__c, Contact_Name__c, Deleted_Date_Time__c
                    FROM Account
                    WHERE Id In: accountsToSendToBananaStand.keySet()];

            if (accounts.size() > 0) {
                BulkSendResponse response = SendAccountsToBananaStand(new Set<Account>(accounts), integrationSettings, accountsToSendToBananaStand);
                integrationQueuesToUpdate.addAll(response.QueuesToUpdate);
                successfulIntegrationQueues.addAll(response.SuccessfulQueues);
                accountsToUpdate.addAll((List<Account>)response.SObjectsToUpdate);
            }
        }

        if(contactsToSendToCreateRelationshipBananaStand.size() > 0) {
            BulkSendResponse response = CreateProfessionalRelationshipInBananaStand(contactRelationsToCreateBananaStand, integrationSettings, contactsToSendToCreateRelationshipBananaStand);
            integrationQueuesToUpdate.addAll(response.QueuesToUpdate);
            successfulIntegrationQueues.addAll(response.SuccessfulQueues);
            //commented by ronak in respect for the account contact relationship object
            //relationsToDelete.addAll(GetRelationsToDelete(response.SuccessfulQueues));
        }

        if(contactRelationsToDeleteBananaStand.size() > 0) {
            BulkSendResponse response = DeleteProfessionalRelationshipInBananaStand(contactRelationsToDeleteBananaStand, integrationSettings, contactsToSendToDeleteRelationshipBananaStand);
            integrationQueuesToUpdate.addAll(response.QueuesToUpdate);
            successfulIntegrationQueues.addAll(response.SuccessfulQueues);
        }

        /*if(playsToUpdate.size() > 0) {
            BulkSendResponse response = ExecutePlayLogic(playsToUpdate);
            integrationQueuesToUpdate.addAll(response.QueuesToUpdate);
            successfulIntegrationQueues.addAll(response.SuccessfulQueues);
        }*/

        if (accountsToUpdate.size() > 0) {
            AccountLogic.SYNC_ACCOUNT_CHANGES = false; 
            Database.SaveResult[] saveResults = Database.update(new List<Account>(accountsToUpdate));
            AccountLogic.SYNC_ACCOUNT_CHANGES = true;
            for (Database.SaveResult saveResult : saveResults) {
                if (!saveResult.isSuccess()) {
                    system.debug('Failed to Update Account:' + saveResult.getId());
                    system.debug(saveResult.getErrors());
                }
            }
        }

       /* if (relationsToDelete.size() > 0) {
            Database.DeleteResult[] deleteResults = Database.delete(new List<Account_Contact_Relationship__c>(relationsToDelete), false);
            for (Database.DeleteResult deleteResult : deleteResults) {
                if (deleteResult.isSuccess() == false) {
                    system.debug('Failed to Delete Account_Contact_Relationship__c:' + deleteResult.getId());
                    system.debug(deleteResult.getErrors());
                }
            }

            processedRecords = true;
        }*/

        if (integrationSettings.Keep_Integration_Queue__c) {
            integrationQueuesToUpdate.addAll(successfulIntegrationQueues);
        }
        else {
            integrationQueuesToDelete.addAll(successfulIntegrationQueues);
        }

        if (integrationQueuesToUpdate.size() > 0) {
            Database.UpsertResult[] upsertResults = Database.upsert(new List<Error_Log__c>(integrationQueuesToUpdate), false);
            for(Database.UpsertResult upsertResult: upsertResults) {
                if (upsertResult.isSuccess() == false) {
                    system.debug('Failed to Update Integration Queue ' + upsertResult.getId());
                    system.debug(upsertResult.getErrors());
                }
            }

            processedRecords = true;
        }

        if (integrationQueuesToDelete.size() > 0) {
            Database.DeleteResult[] deleteResults = Database.delete(new List<Error_Log__c>(integrationQueuesToDelete), false);
            for(Database.DeleteResult deleteResult: deleteResults) {
                if (deleteResult.isSuccess() == false) {
                    system.debug('Failed to Delete Integration Queue ' + deleteResult.getId());
                    system.debug(deleteResult.getErrors());
                }
            }
            processedRecords = true;
        }
    }

    private BulkSendResponse SendAccountsToBananaStand(
            Set<Account> accounts,
            Integration_Settings__c integrationSettings,
            Map<Id, Set<Error_Log__c>> accountIntegrationQueues) {
        BulkSendResponse bulkResponse = new BulkSendResponse();

        Map<Id, String> accountsJSON = new Map<Id, String>();

        for (Account account : accounts) {
            try
            {
                accountsJSON.put(account.Id, SerializeAccount(account));
            } catch(Exception ex){
                for (Error_Log__c integration : accountIntegrationQueues.get(account.Id)) {
                    integration.Status__c = 'Error - Fatal';
                    //integration.Error_Message__c = ex.getMessage();
                    integration.Date_Time_Submitted__c = system.now();
                    bulkResponse.QueuesToUpdate.add(integration);
                }
            }
        }

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String url = integrationSettings.Connection_URL_Banana_Stand__c;
        request.setMethod('PUT');
        request.setHeader('Authorization', 'Bearer '+ integrationSettings.Oauth_Token__c);
        request.setHeader('Content-Type', 'application/json');
        //request.setTimeout(12000);
        

        Set<Id> accountIds = accountsJSON.keySet();
        DateTime sendTime = system.now();
        System.debug('Inside bulk response -------------->');
        try {
            System.debug('inside Try-------->');
            for (Id i : accountIds) {
                request.setEndpoint(url + i + '.json');
                System.debug('@@@@EndPoint------'+url+i+'.json');
                String body = accountsJSON.get(i);
                System.debug('@@What is in the body------->'+body);
                request.setBody(body);
                HttpResponse response = http.send(request);
                string responseBody = response.getBody().abbreviate(maxResponseLength);
                
                System.debug('@@@@@@Error Code----------->'+response.getStatusCode());
                 if (response.getStatusCode() != 200) {
                                   String errorMessage = 'The status code returned was not expected: ' +
                            response.getStatusCode() + ' ' + response.getStatus();

                    if (errorMessage.length() > maxErrorLength) {
                        errorMessage = errorMessage.substring(0, maxErrorLength);
                    }
                    System.debug('@@@@@@Error Message----------->'+errorMessage );
                    for (Error_Log__c integration : accountIntegrationQueues.get(i)) {
                        System.debug('@@@@@@Integration Queue----------->'+integration);
                        integration.Attempted_Send_Body__c = body;
                        integration.API_Response__c = responseBody;
                        if (integration.Number_of_Attempts__c < integrationSettings.Max_Retries_Banana_Stand__c) {
                            integration.Status__c = 'Error';
                        } else {
                            integration.Status__c = 'Error - Fatal';
                        }
                        integration.Error_Message__c = errorMessage;
                        integration.Date_Time_Submitted__c = sendTime;
                        bulkResponse.QueuesToUpdate.add(integration);
                    }
                } else {
                    System.debug('@@@@@@Sucess message------------>'+response.getStatusCode());
                    for (Error_Log__c integration : accountIntegrationQueues.get(i)) {
                        integration.Attempted_Send_Body__c = body;
                        integration.Date_Time_Submitted__c = sendTime;
                        integration.API_Response__c = responseBody;
                        integration.Status__c = 'Successful';
                        if (integration.id != null) {
                            bulkResponse.SuccessfulQueues.add(integration);
                        }
                        for(Account a : accounts){
                            if(a.Id == i){
                                JSONParser parser = JSON.createParser(response.getBody());
                                String customerId;
                                System.debug('@@@parser token'+parser.nextToken());
                                while (parser.nextToken() != null) {
                                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                        String fieldName = parser.getText();
                                        System.debug('What is the customer Id----->'+fieldName);
                                        if(fieldName == 'customer_id') {
                                            parser.nextToken();
                                            customerId = parser.getText();
                                            a.Avvo_CustomerID__c = customerId;
                                            break;
                                        }
                                        parser.nextToken();
                                    }
                                }
                                customerId = response.getBody();
                            }
                        }
                    }
                }
            }
        } catch(Exception e) {
            System.debug('inside Catch-------->'+e);
            for (Account account : accounts) {
                for (Error_Log__c integration : accountIntegrationQueues.get(Account.Id)) {
                    integration.Status__c = 'Error';
                    integration.Error_Message__c = e.getMessage();
                    integration.Date_Time_Submitted__c = sendTime;
                    bulkResponse.QueuesToUpdate.add(integration);
                }
            }
        }
        System.debug('Accounts----->'+accounts);
        bulkResponse.SObjectsToUpdate.addAll(accounts);
        return bulkResponse;
    }

    private BulkSendResponse CreateProfessionalRelationshipInBananaStand(Set<BananaStandAccountContactRelation> relations, Integration_Settings__c
            integrationSettings, Map<string, Set<Error_Log__c>> relationIntegrationQueues) {
        BulkSendResponse bulkResponse = new BulkSendResponse();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String url = integrationSettings.Connection_URL_Banana_Stand__c;

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ integrationSettings.Oauth_Token__c);

        DateTime sendTime = system.now();

        try {
            for (BananaStandAccountContactRelation relation : relations) {

                String professionalIdString = relation.ProfessionalId;
                String endpoint = url + relation.AccountId + '/professionals.json';
                request.setEndpoint(endpoint);

                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeFieldName('account_professional');
                gen.writeStartObject();
                gen.writeStringField('account_id', relation.AccountId);
                gen.writeStringField('professional_id', professionalIdString);
                gen.writeEndObject();
                gen.writeEndObject();
                String body = gen.getAsString();

                request.setBody(body);
                HttpResponse response = http.send(request);
                string responseBody = response.getBody().abbreviate(maxResponseLength);

                if (response.getStatusCode() != 200) {
                    String errorMessage = 'The status code returned was not expected: ' +
                            response.getStatusCode() + ' ' + response.getStatus() + ' Body: ' + response.getBody();

                    if (errorMessage.length() > maxErrorLength) {
                        errorMessage = errorMessage.substring(0, maxErrorLength);
                    }

                    for (Error_Log__c integration : relationIntegrationQueues.get(relation.getKey())) {
                        integration.Attempted_Send_Body__c = body;
                        integration.API_Response__c = responseBody;
                        if (integration.Number_of_Attempts__c < integrationSettings.Max_Retries_Banana_Stand__c) {
                            integration.Status__c = 'Error';
                        } else {
                            integration.Status__c = 'Error - Fatal';
                        }
                        integration.Error_Message__c = errorMessage;
                        integration.Date_Time_Submitted__c = sendTime;
                        bulkResponse.QueuesToUpdate.add(integration);
                    }
                } else {
                    for (Error_Log__c integration : relationIntegrationQueues.get(relation.getKey())) {
                        integration.Attempted_Send_Body__c = body;
                        integration.Date_Time_Submitted__c = sendTime;
                        integration.API_Response__c = responseBody;
                        integration.Status__c = 'Successful';
                        if (integration.Id != null) {
                            bulkResponse.SuccessfulQueues.add(integration);
                        }
                    }
                }
            }
        } catch(Exception e) {
            for (BananaStandAccountContactRelation relation : relations) {
                for (Error_Log__c integration : relationIntegrationQueues.get(relation.getKey())) {
                    integration.Status__c = 'Error';
                    integration.Error_Message__c = e.getMessage();
                    integration.Date_Time_Submitted__c = sendTime;
                    bulkResponse.QueuesToUpdate.add(integration);
                }
            }
        }
        return bulkResponse;
    }

    /*
    ---Commented by Ronak for the time being
    private Set<Account_Contact_Relationship__c> GetRelationsToDelete(Set<Integration_Queue__c> queues) {
        Set<Account_Contact_Relationship__c> relationsToDelete = new Set<Account_Contact_Relationship__c>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<string> keys = new Set<String>();

        for (Integration_Queue__c queue : queues) {
            contactIds.add(queue.Contact__c);
            accountIds.add(queue.Account__c);
            keys.add(string.valueOf(queue.Contact__c) + string.valueOf(queue.Account__c));
        }

        for (Account_Contact_Relationship__c relation : [SELECT Id, Contact__c, Account__c
                                                         FROM Account_Contact_Relationship__c
                                                         WHERE Account__c In: accountIds
                                                         AND Contact__c In: contactIds]) {
            if (keys.contains(string.valueOf(relation.Contact__c) + string.valueOf(relation.Account__c))) {
                relationsToDelete.add(relation);
            }
        }

        return relationsToDelete;
    }*/

    private BulkSendResponse DeleteProfessionalRelationshipInBananaStand(Set<BananaStandAccountContactRelation> relations, Integration_Settings__c
            integrationSettings, Map<string, Set<Error_Log__c>> relationIntegrationQueues) {
        BulkSendResponse bulkResponse = new BulkSendResponse();

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String url = integrationSettings.Connection_URL_Banana_Stand__c;

        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ integrationSettings.Oauth_Token__c);

        DateTime sendTime = system.now();

        try {
            for (BananaStandAccountContactRelation relation : relations) {
                String professionalIdString = relation.ProfessionalId;
                request.setEndpoint(url + relation.AccountId + '/professionals/' + professionalIdString + '.json');

                HttpResponse response = http.send(request);
                string responseBody = response.getBody().abbreviate(maxResponseLength);

                if (response.getStatusCode() != 200) {
                    String errorMessage = 'The status code returned was not expected: ' +
                            response.getStatusCode() + ' ' + response.getStatus() + ' Body: ' + response.getBody();

                    if (errorMessage.length() > maxErrorLength) {
                        errorMessage = errorMessage.substring(0, maxErrorLength);
                    }

                    for (Error_Log__c integration : relationIntegrationQueues.get(relation.GetKey())) {
                        if (integration.Number_of_Attempts__c < integrationSettings.Max_Retries_Banana_Stand__c) {
                            integration.Status__c = 'Error';
                        } else {
                            integration.Status__c = 'Error - Fatal';
                        }
                        integration.API_Response__c = responseBody;
                        integration.Error_Message__c = errorMessage;
                        integration.Date_Time_Submitted__c = sendTime;
                        bulkResponse.QueuesToUpdate.add(integration);
                    }
                } else {
                    for (Error_Log__c integration : relationIntegrationQueues.get(relation.GetKey()))  {
                        integration.Date_Time_Submitted__c = sendTime;
                        integration.Status__c = 'Successful';
                        integration.API_Response__c = responseBody;
                        if (integration.Id != null) {
                            bulkResponse.SuccessfulQueues.add(integration);
                        }
                    }
                }
            }
        } catch(Exception e) {
            for (BananaStandAccountContactRelation relation : relations) {
                for (Error_Log__c integration : relationIntegrationQueues.get(relation.GetKey())) {
                    integration.Status__c = 'Error';
                    integration.Error_Message__c = e.getMessage();
                    integration.Date_Time_Submitted__c = sendTime;
                    bulkResponse.QueuesToUpdate.add(integration);
                }
            }
        }
        return bulkResponse;
    }

    /*private BulkSendResponse ExecutePlayLogic(Map<Id, Set<Error_Log__c>> playsToUpdate) {

        List<Error_Log__c> taskQueues = [
                SELECT ID, Number_of_Attempts__c, Task_Id__c, Error_Message__c, Status__c, Integration__c, Find_Task_Play__c
                FROM Error_Log__c
                WHERE Task_Id__c in: playsToUpdate.keySet()];

        Map<Id, Set<Error_Log__c>> taskQueueMap = new Map<Id, Set<Error_Log__c>>();
        Set<Id> taskIdsSetPlays = new Set<Id>();
        for(Error_Log__c queue : taskQueues){
            if(!taskQueueMap.containsKey(queue.Task_Id__c)){
                taskQueueMap.put(queue.Task_Id__c, new Set<Error_Log__c>());
            }

            taskQueueMap.get(queue.Task_Id__c).add(queue);

            if (queue.Find_Task_Play__c) {
                taskIdsSetPlays.add(queue.Task_Id__c);
            }
        }

        Map<boolean, Set<Error_Log__c>> results =
           new TaskLogic().updatePlayAndRunPlayLogicWithQueues(new List<Id>(playsToUpdate.keySet()),
               taskIdsSetPlays, taskQueueMap);

        BulkSendResponse response = new BulkSendResponse();
        response.QueuesToUpdate.addAll(results.get(false));
        response.SuccessfulQueues.addAll(results.get(true));

        //return response;
        return null;
    }*/

    private class BulkSendResponse {
        public Set<Error_Log__c> SuccessfulQueues {get; private set;}
        public Set<Error_Log__c> QueuesToUpdate {get; private set;}
        public List<Account> SObjectsToUpdate {get; private set;}

        public BulkSendResponse() {
            SuccessfulQueues = new Set<Error_Log__c>();
            QueuesToUpdate = new Set<Error_Log__c>();
            SObjectsToUpdate = new List<Account>();
        }
    }

    public static String SerializeAccount(Account integrationAccount){
        try {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('account');
            gen.writeStartObject();
            gen.writeStringField('id', integrationAccount.Id);
            if (integrationAccount.Avvo_CustomerID__c != null) {
                gen.writeStringField('customer_id', integrationAccount.Avvo_CustomerID__c);
            } else {
                gen.writeNullField('customer_id');
            }
            
            // Passing Avvo Attorney Customer Number
            if (integrationAccount.Auto_Customer_Number__c!= null) {
                gen.writeStringField('customer_number', integrationAccount.Auto_Customer_Number__c);
            } else {
                gen.writeNullField('customer_number');
            }
            
            // Passing Avvo Firm Customer Number
            if (integrationAccount.Parent.Auto_Customer_Number__c!= null) {
                gen.writeStringField('firm_customer_number', integrationAccount.Parent.Auto_Customer_Number__c);
            } else {
                gen.writeNullField('firm_customer_number');
            }
            
             // Passing Avvo Firm Name
            if (integrationAccount.Parent.Name!= null) {
                gen.writeStringField('firm_name', integrationAccount.Parent.Name);
            } else {
                gen.writeNullField('firm_name');
            }
            gen.writeStringField('name', integrationAccount.Name);
            if (integrationAccount.Phone != null) {
                // eliminate formatting to send to banana stand
                String phoneNumber = '';
                for (Integer i = 0; i < integrationAccount.Phone.length(); i++) {
                    String character = integrationAccount.Phone.mid(i, 1);
                    if (character.isNumeric()) {
                        phoneNumber += character;
                    }
                }
                gen.writeStringField('phone_number', phoneNumber);
            }else{
                gen.writeNullField('phone_number');
            }
            
             if (integrationAccount.Contact_Email__c != null) {
                gen.writeStringField('contact_email', integrationAccount.Contact_Email__c);
            } else {
                gen.writeNullField('contact_email');
            }
            
            if (integrationAccount.Contact_Name__c != null) {
                gen.writeStringField('contact_name', integrationAccount.Contact_Name__c);
            } else {
                gen.writeNullField('contact_name');
            }

            if (integrationAccount.Deleted_Date_Time__c != null) {
                gen.writeDateTimeField('deleted_at', integrationAccount.Deleted_Date_Time__c);
            } else {
                gen.writeNullField('deleted_at');
            }

            // address section
            gen.writeFieldName('address');
            gen.writeStartObject();
            if (integrationAccount.BillingStreet != null) {
                String[] addressLines = new String[100];
                addressLines = integrationAccount.BillingStreet.split('\n');
                gen.writeStringField('address_line1', addressLines[0]);
            } else {
                gen.writeNullField('address_line1');
            }
            if (integrationAccount.BillingCity != null) {
                gen.writeStringField('city', integrationAccount.BillingCity);
            } else {
                gen.writeNullField('city');
            }
            if (integrationAccount.BillingState != null) {
                gen.writeStringField('state', integrationAccount.BillingState);
            } else {
                gen.writeNullField('state');
            }
            if (integrationAccount.BillingPostalCode != null) {
                gen.writeStringField('postal_code', integrationAccount.BillingPostalCode);
            } else {
                gen.writeNullField('postal_code');
            }
            if (integrationAccount.BillingCountry != null) {
                gen.writeStringField('country', integrationAccount.BillingCountry);
            } else {
                gen.writeNullField('country');
            }
            gen.writeEndObject();
            gen.writeEndObject();

            return gen.getAsString();
        } catch (Exception ex){
            System.debug('Failed to Serialize Account'+ex);
            return null;
            //throw new ('Failed to Serialize Account', ex);
        }
    }

    private string decimalToString(decimal value) {
        string stringValue = string.valueOf(value);
        integer decimalIndex = stringValue.indexOf('.');
        if (decimalIndex != -1) {
            stringValue = stringValue.substring(0, decimalIndex);
        }

        return stringValue;
    }

    private class BananaStandAccountContactRelation{
        public Id AccountId;
        public Id ContactId;
        public String ProfessionalId;

        public BananaStandAccountContactRelation(Id accountId, Id contactId, String professionalId){
            this.AccountId = accountId;
            this.ContactId = contactId;
            this.ProfessionalId = professionalId;
        }

        public string GetKey() {
            return string.valueOf(AccountId) + string.valueOf(ContactId);
        }

        public Integer hashCode() {
            return GetKey().hashCode();
        }

        public Boolean equals(Object obj) {
            if(obj instanceof BananaStandAccountContactRelation){
                BananaStandAccountContactRelation relation = (BananaStandAccountContactRelation)obj;
                return relation.GetKey() == GetKey();
            }

            return false;
        }
    }
}