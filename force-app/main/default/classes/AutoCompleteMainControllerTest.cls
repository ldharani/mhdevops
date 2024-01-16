@isTest
public class AutoCompleteMainControllerTest{
    public static testmethod void autoCompleteTestmethod(){
    
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Deactivate_Trigger_for_data_load__c customSetting = new Deactivate_Trigger_for_data_load__c(Name='Deactivate',Deactivate_trigger__c=false);
        insert customSetting;
         //creating geo location record
         Geo_location__c geo = util.getGeolocation('testUSA','testNY','','testCalifornia');
         geo.recordtypeid=  Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        AutoCompleteMainController autoComplete = new AutoCompleteMainController(sc);
        
        autoComplete.countryName ='';
        autoComplete.cityname='';
        autoComplete.AccountId='';
        autoComplete.countryName1='';
        autoComplete.billingCountryName='';
        autoComplete.stateName='';
        autoComplete.billingStateName='';
        
        autoComplete.selected =true;
        autoComplete.getItems();
        autoComplete.updateAccount();
        
        
        geo.State_Abbrevation__c ='NY';
        update geo;
        autoComplete.updateAccount();
        geo.City_Name__c ='California';
        update geo;
        autoComplete.updateAccount();
        geo.CountryName__c ='USA';
        geo.County_Name__c ='USA';
        update geo;
        
        autoComplete.copyshippingFields();
        autoComplete.updateAccount();
        
        autoComplete.selected =false;
        autoComplete.copyshippingFields();
        
        autoComplete.Close();
        PopupVFpageController popctrl = new PopupVFpageController(sc);
        popctrl.closePopup();
        popctrl.edit();
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
    
    }


}