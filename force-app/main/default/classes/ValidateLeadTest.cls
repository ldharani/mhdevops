@isTest
Public class ValidateLeadTest{

    public testmethod  static void ValidateLead(){
    	Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
      // create a Lead
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
       Id MNLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MN_Lead).getRecordTypeId();
       Lead lead=new Lead(LastName='John1',
                          Company='John LLC',
                          Status='Inquiry', 
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820'
                          );
       insert lead;
        
        
        Lead lead1 =new Lead(LastName='mark',
                          Company='mark LLC',
                          Status='Inquiry', 
                          RecordTypeId = MNLeadRecordTypeId,
                          MH_Customer_Number__c = '1568462462',
                          Postalcode = '08830'
                          );
       insert lead1;
       
       system.assert(lead.id != null);
       ValidateLead.validate(lead.id); 
                lead.Company='add me';
                 lead.State='MA';
                  update lead;                
       ValidateLead.validate(lead.id); 
       
       
                 lead.LastName='add me';
                 lead.Country ='USA';
                
                 update lead;  
       system.assert(lead.id != null);                      
       ValidateLead.validate(lead.id);
        
        lead1.MN_Lead_Source__c ='';
        lead.Country ='USA';
                
                 update lead1;  
       system.assert(lead1.id != null);                      
       ValidateLead.validate(lead1.id);
        
         
    }
    
    public testmethod  static void ValidateLead2(){
    
    // create a Lead
       Id MALeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Unclaimed Leads').getRecordTypeId(); 
       Id claimMALeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Claimed Leads').getRecordTypeId(); 
        
       
       Lead lead=new Lead(LastName='John1',
                          Company='John LLC',
                          Status='Inquiry', 
                          RecordTypeId = MALeadRecordTypeId ,Email = '',
                          Professional_ID__c = '158462461',
                          Postalcode = '08820'
                          );
       insert lead;
       
       try{
       ValidateLead.validate(lead.id); 
       }
       
        catch(Exception e)

            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot convert an Unclaimed lead \n') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
                
            } 
    }
    
    public testmethod  static void ValidateLead3(){
    
      Id Captorralead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Captorra Lead').getRecordTypeId();
      Lead lead=new Lead(LastName='John1',
                          Company='John LLC',
                          Status='Inquiry', 
                          RecordTypeId = Captorralead ,Email = '',                        
                          Postalcode = '08820'
                          );
       insert lead;
       
       try{
       ValidateLead.validate(lead.id); 
       }
       
        catch(Exception e)

            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot convert lead since Email is blank ') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
                
            } 
     
    }
    
}