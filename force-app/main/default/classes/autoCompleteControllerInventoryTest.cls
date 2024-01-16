@isTest(seeAlldata = true)
public class autoCompleteControllerInventoryTest{
     static testmethod void scenario1(){
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
         //creating geo location record
        Geo_location__c geo = util.getGeolocation('USA','AZ','','Ajio');
        Test.startTest();
        autoCompleteControllerInventory.findSObjects('a','City_Name__c','USA', 'AZ', '');
        Test.stopTest();
     }
}