public class LeadDuplicationClass {
    
    
    public LeadDuplicationClass(){
        
    }
    
    
    public static Map<id,List<account>> getDuplicateContactsAccounts(Lead lead){
        
        Map<id,List<account>> parectAccVsAccounts = new Map<id,List<account>>();
        set<Id> parentAccids                  = new set<id>();
        List<account> parentAccounts          = new List<account>();
        if(lead.Email != null){
            for(AccountContactRelation relatedContact: [select id,contactId,
                                                                AccountId,isActive, 
                                                                Account.Name,account.RecordType.Name,account.RecordType.DeveloperName,
                                                                Account.Parent_ID__c
                                                              From AccountContactRelation
                                                        where contact.Email =:lead.Email]){
            	   parentAccids.add(relatedContact.Account.Parent_ID__c);                                             
            }
            
        }
        
        if(!parentAccids.isEmpty()){
            for(Account acc : [select id,Name, 
                                       RecordType.DeveloperName,
                                       Parent_ID__c,ParentId
                                       From account
                               where Parent_ID__c IN:parentAccids]){
                                   
                  if(acc.ParentId == null){
                  		parentAccounts.add(acc);                     
                   }
                  else{
                      if(parectAccVsAccounts.containsKey(acc.Parent_ID__c)){
                          parectAccVsAccounts.get(acc.Parent_ID__c).add(acc);
                      }
                      else{
                          parectAccVsAccounts.put(acc.Parent_ID__c,new List<account>{acc});
                      }
                  }               
                                   
              }
            
        }
        
        
        
        return parectAccVsAccounts;
    }
    
    public static Map<id, List<AccountContactRelation>> getDuplicateContacts(Lead lead){
        
        Map<id, List<AccountContactRelation>> conIdVsRelatedContacts = new Map<id, List<AccountContactRelation>>();
       
        if(lead.Email != null){
            
            
            for(AccountContactRelation relatedContact: [select id,contactId,
                                                                AccountId,isActive, 
                                                                Account.Name,account.RecordType.Name,account.RecordType.DeveloperName,
                                                                Account.Parent_ID__c
                                                              From AccountContactRelation
                                                                where contact.Email =:lead.Email]){
                  if(conIdVsRelatedContacts.containsKey(relatedContact.ContactId)){
                       conIdVsRelatedContacts.get(relatedContact.ContactId).add(relatedContact);                                                 
                  }
                  else{
                      conIdVsRelatedContacts.put(relatedContact.ContactId, new List<AccountContactRelation>{relatedContact});
                  }
            }
        }
        
        return conIdVsRelatedContacts;
        
    }
    
    
    public static void customleadConversion(){
        
        Lead lead = new lead(LastName = 'Fry', Company='Fry And Sons', email='raza.sfdc@gmail.com');
        insert lead;
        
        AccountContactRelation acr = new AccountContactRelation();
        acr = [select id,contactId,
                                                                AccountId,isActive, 
                                                                Account.Name,account.RecordType.Name,account.RecordType.DeveloperName
                                                                From AccountContactRelation
                                                                where contact.Email =:lead.Email LIMIT 1];
                
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);

        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        //lc.setAccountId(acr.accountId);
        lc.setContactId(acr.ContactId);
        

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        system.debug('@@@lcr'+lcr);
        System.assert(lcr.isSuccess());
    }

}