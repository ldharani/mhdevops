@isTest
Public class ValidateLeadAddressTest{

    public testmethod  static void validateLeadsAddress(){
    
      // create a Lead
       Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Lead).getRecordTypeId();
       Lead lead=new Lead(LastName='Doe11',
                          Company='Test',
                          Status='Inquiry', 
                          RecordTypeId = LeadRecordTypeId,
                          MH_Customer_Number__c = '1568462461',
                          Postalcode = '08820'
                          );
       insert lead; 
       system.assert(lead.id != null);
        
       ValidateLeadAddress.validateaddress(lead); 
       lead.Country ='USA';
       lead.City='Edison';
       lead.State='MA';
       lead.PostalCode ='99950';
       update lead;
       ValidateLeadAddress.validateaddress(lead);   
       
       MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
       GEO_Location__c  geo = util.getGeolocation('USA','MA','USA', 'Edison');
       geo.Country_Inv_Flag__c ='Yes';
       geo.recordTypeid= Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
       update geo;
       system.assert(geo.id != null);
       
       ValidateLeadAddress.validateaddress(lead);
       
       List<AggregateResult> aggList = autoCompleteControllerFinal.findSObjects('3', 'County_ID__c ','USA','MA', 'Edison') ;
       
       List<Inventoried_Products_list__c> customList = new List<Inventoried_Products_list__c >();
       
       Inventoried_Products_list__c customSetting = new Inventoried_Products_list__c(name='Preferred Banner Placements',type__c='County',Product_Code__c='01910');
       customList.add(customSetting);
       Inventoried_Products_list__c customSetting2 = new Inventoried_Products_list__c(name='Preferred Banner Placements2',type__c='Country',Product_Code__c='019107');
       customList.add(customSetting2);
       
       Inventoried_Products_list__c customSetting3 = new Inventoried_Products_list__c(name='Preferred Banner Placements3',type__c='City',Product_Code__c='019105');
       customList.add(customSetting3);
       
       Inventoried_Products_list__c customSetting4 = new Inventoried_Products_list__c(name='Preferred Banner Placements4',type__c='state',Product_Code__c='019104');
       customList.add(customSetting4);
       insert customList;
       List<AggregateResult> aggList2 = autoCompleteControllerFinal1.findSObjects('3', 'County_ID__c ','USA','MA','USA','Edison','Preferred Banner Placements') ;
       List<AggregateResult> aggList3 = autoCompleteControllerFinal1.findSObjects('3', 'County_ID__c ','USA','MA','USA','Edison','Preferred Banner Placements2') ;
       List<AggregateResult> aggList4 = autoCompleteControllerFinal1.findSObjects('3', 'County_ID__c ','USA','MA','USA','Edison','Preferred Banner Placements3') ;
       List<AggregateResult> aggList5 = autoCompleteControllerFinal1.findSObjects('3', 'County_ID__c ','USA','MA','USA','Edison','Preferred Banner Placements4') ;
       AutoCompleteBillingaddressController autocomplete = new AutoCompleteBillingaddressController();
       autocomplete.getGeoLocations();
       
       Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
       
    }

}