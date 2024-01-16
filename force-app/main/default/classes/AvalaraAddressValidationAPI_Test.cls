/***********************************************************************************************************************
 * @author - VR
 * @date - 03 Feb 2022
 * @description - Api callout for Avalara Address Endpoint.
 * @testclass of - AvalaraAddressValidationAPI

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
************************************************************************************************************************/

@isTest
public class AvalaraAddressValidationAPI_Test {
    
     @testSetup static void setup() { 
          
        AvalaraAddressEndpoint__c setting1 = new AvalaraAddressEndpoint__c();
        AvalaraAddressEndpoint__c setting2 = new AvalaraAddressEndpoint__c();
        AvalaraAddressEndpoint__c setting3 = new AvalaraAddressEndpoint__c();
        AvalaraAddressEndpoint__c setting4 = new AvalaraAddressEndpoint__c();
        AvalaraAddressEndpoint__c setting5 = new AvalaraAddressEndpoint__c();
        AvalaraAddressEndpoint__c setting6 = new AvalaraAddressEndpoint__c();
        AvalaraAddressEndpoint__c setting7 = new AvalaraAddressEndpoint__c();
        
        setting1.Name = 'AvalaraAddressApiEndPoint';
        setting1.AvalaraAddressAPITextValue__c = 'https://admin.avalara.com/api/v2/addresses/resolve';
        setting2.Name = 'AvalaraAddressApiToken';
        setting2.AvalaraAddressAPITextValue__c = 'Basic MTEwMDA3ODMyNjpCQUREQ0MxMDRFREUwRENC';
        setting3.Name = 'line1';
        setting3.AvalaraAddressAPITextValue__c = 'line1';
        setting4.Name = 'city';
        setting4.AvalaraAddressAPITextValue__c = 'city';
        setting5.Name = 'region';
        setting5.AvalaraAddressAPITextValue__c = 'region';
        setting6.Name = 'country';
        setting6.AvalaraAddressAPITextValue__c = 'country';
        setting7.Name = 'postalCode';
        setting7.AvalaraAddressAPITextValue__c = 'postalCode';
        
        insert setting1; insert setting2 ;insert setting3; insert setting4; insert setting5 ;insert setting6; insert setting7;
        
     }
    
    static testmethod void validateLeadAddressAndUpdateInvalidAddress_Test1(){
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        Lead leadRec = new Lead();
        leadRec.Company = 'Test Account';
        leadRec.LastName= 'Test Lead';
        leadRec.Email = 'testmaclaim@gmail.com';
        leadRec.LeadSource = 'Web';
        leadRec.Status = 'Qualified';
        leadRec.Claimed_Date__c = Date.today() - 31;
        leadRec.Claimed_Method__c = 'Admin';
        leadRec.street = 'street';
        
        test.startTest();
        insert leadRec;
        test.stopTest();
        
        List<String> leads = new List<String>();
        Id leadRecordTypeIdMH = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        List<Lead> leadList = new List<Lead>();
        leadList.add(leadRec);
        for(Lead objLd:leadList ){
            
           {
                String street = objLd.Street;
                String streetline2 = objLd.Address_Street_Line_2__c;
                String city = objLd.City;
                String region = objLd.StateCode;
                String country = objLd.CountryCode;
                String postalCode = objLd.PostalCode;
             
               if(street!=null) street = EncodingUtil.urlEncode(street,'UTF-8');
               if(streetline2!=null) streetline2 = EncodingUtil.urlEncode(streetline2,'UTF-8');
               if(city!=null) city = EncodingUtil.urlEncode(city,'UTF-8');
               if(region!=null) region = EncodingUtil.urlEncode(region,'UTF-8');
               if(country!=null) country = EncodingUtil.urlEncode(country,'UTF-8');
               if(postalCode!=null) postalCode = EncodingUtil.urlEncode(postalCode,'UTF-8');

                leads.add(objLd.ID+' '+street+' '+streetline2+' '+city+' '+region+' '+country+' '+postalCode+' ');  //TO AVOID QUERYING AGAIN
            }
        }
       if(!leads.isEmpty())
        AvalaraAddressValidationAPI.validateLeadAddressAndUpdateInvalidAddress(leads);
        
         
    }
    
    static testmethod void validateLeadAddressAndUpdateInvalidAddress_Test2(){
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Lead leadRec = new Lead();
        leadRec.Company = 'Test Account';
        leadRec.LastName= 'Test Lead';
        leadRec.Email = 'testmaclaim@gmail.com';
        leadRec.LeadSource = 'Web';
        leadRec.Status = 'Qualified';
        leadRec.Claimed_Date__c = Date.today() - 31;
        leadRec.Claimed_Method__c = 'Admin';
        leadRec.street = 'street';
        
        test.startTest();
        insert leadRec;
        test.stopTest();
        
        List<String> leads = new List<String>();
        Id leadRecordTypeIdMH = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        List<Lead> leadList = new List<Lead>();
        leadList.add(leadRec);
        for(Lead objLd:leadList ){
            
           {
                String street = objLd.Street;
                String streetline2 = objLd.Address_Street_Line_2__c;
                String city = objLd.City;
                String region = objLd.StateCode;
                String country = objLd.CountryCode;
                String postalCode = objLd.PostalCode;
             
               if(street!=null) street = EncodingUtil.urlEncode(street,'UTF-8');
               if(streetline2!=null) streetline2 = EncodingUtil.urlEncode(streetline2,'UTF-8');
               if(city!=null) city = EncodingUtil.urlEncode(city,'UTF-8');
               if(region!=null) region = EncodingUtil.urlEncode(region,'UTF-8');
               if(country!=null) country = EncodingUtil.urlEncode(country,'UTF-8');
               if(postalCode!=null) postalCode = EncodingUtil.urlEncode(postalCode,'UTF-8');

                leads.add(objLd.ID+' '+street+' '+streetline2+' '+city+' '+region+' '+country+' '+postalCode+' ');  //TO AVOID QUERYING AGAIN
            }
        }
       if(!leads.isEmpty())
        AvalaraAddressValidationAPI.validateLeadAddressAndUpdateInvalidAddress(leads);
        
        
    }
    
    static testmethod void validateAccountAddressAndUpdateInvalidAddress_Test1(){
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        Account acc = new Account();
        acc.Name='Test Acc';
        
        test.startTest();
        insert acc;
        acc.BillingStreet = 'street';
        update acc;
        test.stopTest();
        
        List<String> accounts = new List<String>();
        Id accRecordTypeIdMH = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account > accountList =new List<Account>();
        accountList.add(acc);
        for(Account obj:accountList ){
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
            
                if(!accounts.isEmpty())
                    AvalaraAddressValidationAPI.validateAccountAddressAndUpdateInvalidAddress(accounts);
        }
    }
    
    static testmethod void validateAccountAddressAndUpdateInvalidAddress_Test2(){
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Account acc = new Account();
        acc.Name='Test Acc';
        
        test.startTest();
        insert acc;
        acc.BillingStreet = 'street';
        update acc;
        test.stopTest();
        
          List<String> accounts = new List<String>();
        Id accRecordTypeIdMH = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account > accountList =new List<Account>();
        accountList.add(acc);
        for(Account obj:accountList ){
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
            
                if(!accounts.isEmpty())
                    AvalaraAddressValidationAPI.validateAccountAddressAndUpdateInvalidAddress(accounts);
        }
    }
    
    static testmethod void validateAccountAddressWithStreetLengthHigh_Test3(){
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Account acc = new Account();
        acc.Name='Test Acc';
        
        test.startTest();
        insert acc;
        acc.BillingStreet = 'streetname streetname streetname, streetname,streetname, US';
        update acc;
        test.stopTest();
        
        List<String> accounts = new List<String>();
        Id accRecordTypeIdMH = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account > accountList =new List<Account>();
        accountList.add(acc);
        for(Account obj:accountList ){
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
            
                if(!accounts.isEmpty())
                    AvalaraAddressValidationAPI.validateAccountAddressAndUpdateInvalidAddress(accounts);
        }
    }
    
    static testmethod void getObjectByIdTest(){
        Account acc = new Account();
        acc.Name='Test Acc';
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        insert acc;
        AvalaraAddressValidationAPI.getObjectById(acc.ID);
        test.stopTest();
        
    }

}