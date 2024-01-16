public without sharing class AccountContactRelationshipLogic {

    public static boolean SYNC_ACCOUNT_CONTACT_CHANGES = true;
    public Id profileId;
    Public Set<String> authorizedProfiles;
    Public String profileName;
    
    public void doAfterInsert(List< Account_Contact_Relation__c > accountContactRelationships) {
        //SendAccountContactRelation(accountContactRelationships);
        system.debug('====== Account_Contact_Relation__c========='+accountContactRelationships);
        if(SYNC_ACCOUNT_CONTACT_CHANGES){
            IntegrationEngine.IntegrateContacts_BananaStandProfessionalsSyncCreateRelationship(accountContactRelationships);
        }
    }
    public void doBeforeDelete(List< Account_Contact_Relation__c > relations){
        //relations = [select Id, Account__c, Contact__c, Roles__c, Contact__r.Professional_ID__c from Account_Contact_Relation__c where IsDeleted = true];
        
        authorizedProfiles = new Set<String>{
                                             'System Administrator', 'Data Governor'
                                             
                                           };
        profileId = userInfo.getProfileId();
        profileName = [SELECT Name
                                    FROM Profile
                                    WHERE Id = :profileId
                                   ].Name;    
        System.debug('@@@@@@profile Name of the user---->'+profileName);
        
        for(Account_Contact_Relation__c accConRel: relations){
            System.debug('@@-----Whethwer profile is authorized or not----'+authorizedProfiles.contains(profileName));
            if(accConRel.Roles__c == 'Lead/Paying Attorney' && !authorizedProfiles.contains(profileName)){
                accConRel.addError('You do not have permissions to remove the Account contact relationship');
            }
            else{
                system.debug('======deletedrelations========='+relations);
                IntegrationEngine.IntegrateContacts_BananaStandProfessionalsSyncDeleteRelationship(relations);
            }
        }
        
        
    }
}