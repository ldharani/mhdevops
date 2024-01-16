/*****
Class Name: bob_contactlist_comp_class 
Created by: Bharath

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description

************************************************************************************************************************/
@isTest
public class bob_contactlist_comp_class_test {
    //Test method for Country,County,City,State dropdown population
    public static String country='USA';
    public static String state='NY';
    public static String county='New York';
    public static String city='New York';
    public static testMethod void testMethod1(){
        Geo_Location__c g = new Geo_Location__c();
        g.CountryName__c = 'USA';
        g.State_Abbrevation__c = 'NY';
        g.County_Name__c = 'New York';
        g.City_Name__c = 'New York';
       	insert g;
        test.startTest();
        	List<String> res = bob_contactlist_comp_class.countryList();
        	List<String> res2 = bob_contactlist_comp_class.stateList(country);
        	List<String> res3 = bob_contactlist_comp_class.countyList(country,state);
        	List<String> res4 = bob_contactlist_comp_class.cityList(country,state);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest();
        system.assertEquals(res.size() > 0,true);
        system.assertEquals(res2.size() > 0,true);
        system.assertEquals(res3.size() > 0,true);
        system.assertEquals(res4.size() > 0,true);
	}
    
    //Test method for filter function on Country,County,City,State dropdown population
    public static testMethod void testMethod2(){
        String ele1 = 'USA';
        String ele2 = 'N';
        String ele3 = 'New';
        Geo_Location__c g = new Geo_Location__c();
        g.City_Name__c = ele3 ;
        g.CountryName__c = 'USA';
        g.State_Abbrevation__c = state;
        g.County_Name__c = ele3 ;
       	insert g;
        test.startTest();
        	List<String> res = bob_contactlist_comp_class.countryList_Filter(ele1);
        	List<String> res2 = bob_contactlist_comp_class.stateList_Filter(country,ele2);
        	List<String> res3 = bob_contactlist_comp_class.countyList_Filter(country,state,ele3);
        	List<String> res4 = bob_contactlist_comp_class.cityList_Filter(country,state,ele3);
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest();
        system.assert(res.size() > 0);
        system.assert(res2.size() > 0);
        system.assert(res3.size() > 0);
        system.assert(res4.size() > 0);
	}
    
    //Test method for AOP duallistbox population
    static testMethod void testMethod3(){
        Contact c = new Contact(LastName='Test');
        test.startTest();
        	List<String> res = bob_contactlist_comp_class.aopListGeneration();
        	bob_contactlist_comp_class.contactListWrapper testWrap = new bob_contactlist_comp_class.contactListWrapper(false,c);
      		Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest();
      //  system.assert(res.size()>0);
	}
    
    //Test method for fetching Contact with given requirement
    static testMethod void testMethod4(){
        List<String> aop = new List<String>();
        aop.add('Accountants Liability');
        aop.add('Administrative Hearings and Appeals');
        DataFactory.loadCustomSettings();
        Id leadRecordTypeIdParent = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Account lstAcc = (DataFactory.createAccount('Test MH Acc', accRecordTypeId, 1))[0];
        lstAcc.MH_Customer_Status__c ='Test Activated';
        update lstAcc;
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        Contact lstCon =  (DataFactory.createContact('Test Con', lstAcc, conRecordTypeId, 1))[0];
        lstCon.DoNotCall = false;
        lstCon.Last_Activity_AE__c = Date.newInstance(2022, 10, 10);
        lstCon.Practice_Area_1__c = aop[0];
        lstCon.Practice_Status__c = 'Avvo Profile Deleted - Admin Use Only';
        lstCon.MailingCountry = country;
        lstCon.MailingState = state;
        lstCon.MailingCity = city;
        lstCon.County_1__c = county;
        lstCon.In_AE_Book__c = false;
        lstCon.Open_MH_Lead__c = false;
        update lstCon;
        test.startTest();
        	List<bob_contactlist_comp_class.contactListWrapper> res = bob_contactlist_comp_class.fetchContactWrapper(country,county,state,city,aop);
        	Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        test.stopTest();
        system.assert(res.size()>0);
	}
}