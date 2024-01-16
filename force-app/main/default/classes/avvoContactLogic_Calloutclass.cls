public class avvoContactLogic_Calloutclass {
    /*
    protected Boolean processedRecords = false;
    @testVisible
    private static integer maxErrorLength = Error_Log__c.Error_Message__c.getDescribe().getLength();
    private static integer maxResponseLength = Error_Log__c.API_Response__c.getDescribe().getLength();
    List<Error_Log__c> ErrLogList = [select id, Number_of_Attempts__c, Account_Name__c, Contact__c, Task_Id__c, Professional_Id__c, Error_Message__c, Status__c, Integration__c
                FROM Error_Log__c
                WHERE Number_of_Attempts__c = 0
                AND Status__c = 'New'];
    
    /*public void executeMethod(List<Error_Log__c> ErrLogList, List<Sobject>records){
        Map<string, Set<Error_Log__c>> contactsToSendToCreateRelationshipBananaStand = new Map<string, Set<Error_Log__c>>();
        Set<BananaStandAccountContactRelation> contactRelationsToCreateBananaStand = new Set<BananaStandAccountContactRelation>();
    
        Map<string, Set<Error_Log__c>> contactsToSendToDeleteRelationshipBananaStand = new Map<string, Set<Error_Log__c>>();
        Set<BananaStandAccountContactRelation> contactRelationsToDeleteBananaStand = new Set<BananaStandAccountContactRelation>();
    
        Map<Id, Set<Error_Log__c>> playsToUpdate = new Map<Id, Set<Error_Log__c>>();

        Set<Error_Log__c> integrationQueuesToDelete = new Set<Error_Log__c>();
        Set<Error_Log__c> successfulIntegrationQueues = new Set<Error_Log__c>();
        Set<Error_Log__c> integrationQueuesToUpdate = new Set<Error_Log__c>();
        //Set<Account_Contact_Relationship__c> relationsToDelete = new Set<Account_Contact_Relationship__c>();
        Set<Account> accountsToUpdate = new Set<Account>();

        Avvo_Integration_settings__c integrationSettings = Avvo_Integration_settings__c.getInstance();

        for (Sobject record : records) {
            Error_Log__c integrationQueue = (Error_Log__c)record;
            integrationQueue.Number_of_Attempts__c += 1;

            if (integrationQueue.Integration__c == 'Banana Stand') {
                if (integrationQueue.Account_Name__c != null) {
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
                if(integrationQueue.Contact__c != null && integrationQueue.Account_Name__c != null){
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
                if(integrationQueue.Contact__c != null && integrationQueue.Account_Name__c != null){
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
            else if(integrationQueue.Integration__c == 'Play') {
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
            }
            else {
                integrationQueue.Error_Message__c = 'Unknown integration message "' + integrationQueue.Integration__c + '"';
                integrationQueue.Status__c = 'Error';
                integrationQueue.Date_Time_Submitted__c = system.now();
                integrationQueuesToUpdate.add(integrationQueue);
            }
        }

        if (accountsToSendToBananaStand.size() > 0) {
            List<Account> accounts = [
                    SELECT Id, Name, Avvo_CustomerID__c, Phone, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Contact_Email__c, Contact_Name__c, Deleted_Date_Time__c
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

            relationsToDelete.addAll(GetRelationsToDelete(response.SuccessfulQueues));
        }

        if(contactRelationsToDeleteBananaStand.size() > 0) {
            BulkSendResponse response = DeleteProfessionalRelationshipInBananaStand(contactRelationsToDeleteBananaStand, integrationSettings, contactsToSendToDeleteRelationshipBananaStand);
            integrationQueuesToUpdate.addAll(response.QueuesToUpdate);
            successfulIntegrationQueues.addAll(response.SuccessfulQueues);
        }

        if(playsToUpdate.size() > 0) {
            BulkSendResponse response = ExecutePlayLogic(playsToUpdate);
            integrationQueuesToUpdate.addAll(response.QueuesToUpdate);
            successfulIntegrationQueues.addAll(response.SuccessfulQueues);
        }

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

        if (relationsToDelete.size() > 0) {
            Database.DeleteResult[] deleteResults = Database.delete(new List<Account_Contact_Relationship__c>(relationsToDelete), false);
            for (Database.DeleteResult deleteResult : deleteResults) {
                if (deleteResult.isSuccess() == false) {
                    system.debug('Failed to Delete Account_Contact_Relationship__c:' + deleteResult.getId());
                    system.debug(deleteResult.getErrors());
                }
            }

            processedRecords = true;
        }

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
    */
    public static string createnewContactCallout(List<Contact> contacts){
        //contacts = newContactsWithProfIds;
        system.debug('=====Contacts'+contacts);
        Avvo_Integration_settings__c avvoIntSet = new Avvo_Integration_settings__c();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = http.send(request);
        String url = avvoIntSet.Connection_URL_Banana_Stand__c;
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ avvoIntSet.Oauth_Token__c);
        DateTime sendTime = system.now();

         /*try {
            for (BananaStandAccountContactRelation relation : relations) {

                String professionalIdString = decimalToString(relation.ProfessionalId);
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
                //HttpResponse response = http.send(request);
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
                        response.QueuesToUpdate.add(integration);
                    }
                } else {
                    for (Error_Log__c integration : relationIntegrationQueues.get(relation.getKey())) {
                        integration.Attempted_Send_Body__c = body;
                        integration.Date_Time_Submitted__c = sendTime;
                        integration.API_Response__c = responseBody;
                        integration.Status__c = 'Successful';
                        if (integration.Id != null) {
                            response.SuccessfulQueues.add(integration);
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
                    response.QueuesToUpdate.add(integration);
                }
            }
        }*/
        return null;
        
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
        public Decimal ProfessionalId;

        public BananaStandAccountContactRelation(Id accountId, Id contactId, Decimal professionalId){
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