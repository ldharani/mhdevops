@isTest(seeAlldata = true)
public class autoCompleteGenesisAOPControllerTest{
     static testmethod void scenario1(){
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
         //creating geo location record
        Geo_location__c geo = util.getGeolocation('USA','AZ','','Ajio');
        Test.startTest();
        autoCompleteGenesisAOPController.findSObjects('a','City_Name__c', '');
        Test.stopTest();
     }
}