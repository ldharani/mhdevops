/***********************************************************************************************************************
 * @author - VR
 * @date - 28/4/22
 * @ticket - MHBS-6861 
 * @description - Extensions for AddressWithCustomFields Aura Component
 * @testclass - 

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/


public class  AddressController {

     @AuraEnabled
     public static SObject getObjectById(ID ObjectID)
     {
         try{
              String objectName = ObjectID.getSObjectType().getDescribe().getName();
              String query = '';
              if(objectName=='Account')
              {
                  query = 'SELECT ID,BillingStreet,Address_Street_Line_2__c,BillingCity,BillingState,BillingCountry,BillingPostalCode FROM '+objectName+' WHERE ID = :ObjectID ';
              }
              else if(objectName=='Lead')
              {
                 query = 'SELECT ID,Street,Address_Street_Line_2__c,City,State,Country,PostalCode,County__c FROM '+objectName+' WHERE ID = :ObjectID ';
             
              }
              else if(objectName=='Contact')
              {
                 query = 'SELECT ID,MailingStreet,Address_Street_Line_2__c,MailingCity,MailingState,MailingCountry,MailingPostalCode,County_Name__c FROM '+objectName+' WHERE ID = :ObjectID ';
             
              }
              Sobject[] objects = Database.query(query);
              System.debug(' objects from AddressController '+ objects);
              return objects[0];
         }
         catch(Exception e)
         {
             System.debug('Exception Occurred'+e.getMessage());
         }
         return null;
     }

}