public class AutoCompleteBillingaddressController {
    
     public list<GEO_Location__c> getGeoLocations(){
        return [select id, Area_Type__c, City_ID__c, City_Name__c,
                       Combined_Statistical_Area__c, Core_Based_Statistical_Area__c,
                      CountryID__c,     County_Name__c, Historic_ID__c,  Metro_Division_Area__c, 
                      State_Abbrevation__c, StateID__c, Zipcode__c
                      From GEO_Location__c Where RecordType.DeveloperName = 'M_H_GEO_Locations' LIMIT 150];
    }

}