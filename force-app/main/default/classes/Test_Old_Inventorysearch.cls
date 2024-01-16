@isTest(SeeAllData=true)
public class Test_Old_Inventorysearch {


    
    @isTest
    public static void testMethod1(){
        
        Inventoried_Products_list_using_Product__c pl1 = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred State Results 1',Product_Name__c='Lawyers.com Preferred State Results',Product_Code__c='01956',Type__c ='State');
        insert pl1;
        
        Test.startTest();
        CPQ_InventorySearchNew inv = new CPQ_InventorySearchNew();
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred State Results';
        inv.selectedstatecity ='USA,NY';
        List<String> countyList = new List<String>{'Albany','Tioga','Independent City'};
        CPQ_InventorySearchNew.countyList = countyList;
         List<String> countryList = new List<String>{'USA','Canada'};
        CPQ_InventorySearchNew.countryList = countryList;
         List<String> StateList = new List<String>{'NY','VA'};
        CPQ_InventorySearchNew.StateList = StateList;
         List<String> cityList = new List<String>{'Albany','Tioga'};
        CPQ_InventorySearchNew.cityList = cityList;
        inv.statestrings = 'NY'+ ','+'VA';
        inv.citystrings = 'Albany'+ ','+'Tioga';
        inv.countytrings = 'Albany'+ ','+'Tioga';
         List<String> selectedareaOfPracticeL = new List<String>{'Administrative Law','Hospital Law'};
            inv.selectedareaOfPracticeList =selectedareaOfPracticeL;
        
        inv.runsearch();
        Test.StopTest();


        inv.dosearch();
    }
    
    @isTest
    public static void testMethod2(){
        Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred County Results 1',Product_Name__c='Lawyers.com Preferred County Results',Product_Code__c='01667',Type__c ='County');
        insert pl;
        
        CPQ_InventorySearchNew inv = new CPQ_InventorySearchNew();
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred County Results';
        inv.selectedstatecity ='USA,NY,Albany';
        List<String> countyList = new List<String>{'Albany','Tioga','Independent City'};
        CPQ_InventorySearchNew.countyList = countyList;
         List<String> countryList = new List<String>{'USA','Canada'};
        CPQ_InventorySearchNew.countryList = countryList;
         List<String> StateList = new List<String>{'NY','VA'};
        CPQ_InventorySearchNew.StateList = StateList;
         List<String> cityList = new List<String>{'Albany','Tioga'};
        CPQ_InventorySearchNew.cityList = cityList;
        inv.statestrings = 'NY'+ ','+'VA';
        inv.citystrings = 'Albany'+ ','+'Tioga';
        inv.countytrings = 'Albany'+ ','+'Tioga';
         List<String> selectedareaOfPracticeL = new List<String>{'Administrative Law','Hospital Law'};
            inv.selectedareaOfPracticeList =selectedareaOfPracticeL;
        inv.runsearch();
        Test.startTest();

       CPQ_InventorySearchNew.innerOrders i1 = new CPQ_InventorySearchNew.innerOrders('','','','','',Date.Today());
        
        inv.dosearch();
        Test.StopTest();
    }
    
    @isTest
    public static void testMethod3(){
        Inventoried_Products_list_using_Product__c pl = new Inventoried_Products_list_using_Product__c(Name='Lawyers.com Preferred City Results 1',Product_Name__c='Lawyers.com Preferred City Results',Product_Code__c='01920',Type__c ='City');
        insert pl;
        
        CPQ_InventorySearchNew inv = new CPQ_InventorySearchNew();
        inv.countrystrings ='';
        inv.statestrings ='';
        inv.citystrings ='';
        inv.countytrings ='';
        inv.countyString ='';
        inv.isReset =false;
        List<String> countyList = new List<String>{'Albany','Tioga','Independent City'};
        CPQ_InventorySearchNew.countyList = countyList;
         List<String> countryList = new List<String>{'USA','Canada'};
        CPQ_InventorySearchNew.countryList = countryList;
         List<String> StateList = new List<String>{'NY','VA'};
        CPQ_InventorySearchNew.StateList = StateList;
         List<String> cityList = new List<String>{'Albany','Tioga'};
        CPQ_InventorySearchNew.cityList = cityList;
        inv.statestrings = 'NY'+ ','+'VA';
        inv.citystrings = 'Albany'+ ','+'Tioga';
        inv.countytrings = 'Albany'+ ','+'Tioga';
         List<String> selectedareaOfPracticeL = new List<String>{'Administrative Law','Hospital Law'};
            inv.selectedareaOfPracticeList =selectedareaOfPracticeL;
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred City Results';
        inv.selectedstatecity ='USA,NY,Albany';
        Test.startTest();
        inv.runsearch();
        inv.dosearch();
        Test.StopTest();
    }
    
    @isTest
    public static void testMethod4(){
        
       
        
        CPQ_InventorySearchNew inv = new CPQ_InventorySearchNew();
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred National Results';
        List<String> selectedareaOfPracticeL = new List<String>{'Administrative Law','Hospital Law'};
            inv.selectedareaOfPracticeList =selectedareaOfPracticeL;
         inv.selectedstatecity ='USA,NY';
        List<String> countyList = new List<String>{'Albany','Tioga','Independent City'};
        CPQ_InventorySearchNew.countyList = countyList;
         List<String> countryList = new List<String>{'USA','Canada'};
        CPQ_InventorySearchNew.countryList = countryList;
         List<String> StateList = new List<String>{'NY','VA'};
        CPQ_InventorySearchNew.StateList = StateList;
         List<String> cityList = new List<String>{'Albany','Tioga'};
        CPQ_InventorySearchNew.cityList = cityList;
        inv.statestrings = 'NY'+ ','+'VA';
        inv.citystrings = 'Albany'+ ','+'Tioga';
        inv.countytrings = 'Albany'+ ','+'Tioga';
        inv.runsearch();
        inv.resetParameters();
        inv.getdynamicStatelist();
        inv.getdynamicCitylist();
        inv.getdynamicCountylist();
        CPQ_InventorySearchNew.refreshStateList('NY');
        CPQ_InventorySearchNew.refreshcityList('USA','NY','Albany');
        CPQ_InventorySearchNew.refreshcountyList('USA','NY');
       // inv.dosearch();
    }
    
     @isTest
    public static void testMethod5(){
      /*   Inventoried_Products_list_using_Product__c pl2 = new Inventoried_Products_list_using_Product__c(Name='LDC Preferred National Results',Product_Name__c='Lawyers.com Preferred National Results',Product_Code__c='01929',Type__c ='Country');
        insert pl2;
        
        CPQ_InventorySearchNew inv = new CPQ_InventorySearchNew();
        inv.countrystrings ='';
        inv.statestrings ='';
        inv.citystrings ='';
        inv.countytrings ='';
        inv.countyString ='';
        inv.isReset =false;
        List<String> countyList = new List<String>{'Albany','Tioga','Independent City'};
        CPQ_InventorySearchNew.countyList = countyList;
         List<String> countryList = new List<String>{'USA','Canada'};
        CPQ_InventorySearchNew.countryList = countryList;
         List<String> StateList = new List<String>{'NY','VA'};
        CPQ_InventorySearchNew.StateList = StateList;
         List<String> cityList = new List<String>{'Albany','Tioga'};
        CPQ_InventorySearchNew.cityList = cityList;
        inv.statestrings = 'NY'+ ','+'VA';
        inv.citystrings = 'Albany'+ ','+'Tioga';
        inv.countytrings = 'Albany'+ ','+'Tioga';
         List<String> selectedareaOfPracticeL = new List<String>{'Administrative Law','Hospital Law'};
            inv.selectedareaOfPracticeList =selectedareaOfPracticeL;
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred National Results';
        inv.selectedstatecity ='USA,NY,Albany';
        Test.startTest();
        inv.runsearch();
        inv.dosearch();
        Test.StopTest();
        
        */
        
    }
    
     @isTest
    public static void testMethod6(){
         Inventoried_Products_list_using_Product__c pl2 = new Inventoried_Products_list_using_Product__c(Name='LDC Preferred Banner Placements 1',Product_Name__c='Lawyers.com Preferred Banner Placements',Product_Code__c='01910',Type__c ='County');
        insert pl2;
        
        CPQ_InventorySearchNew inv = new CPQ_InventorySearchNew();
        inv.countrystrings ='';
        inv.statestrings ='';
        inv.citystrings ='';
        inv.countytrings ='';
        inv.countyString ='';
        inv.isReset =false;
        List<String> countyList = new List<String>{'Albany','Tioga','Independent City'};
        CPQ_InventorySearchNew.countyList = countyList;
         List<String> countryList = new List<String>{'USA','Canada'};
        CPQ_InventorySearchNew.countryList = countryList;
         List<String> StateList = new List<String>{'NY','VA'};
        CPQ_InventorySearchNew.StateList = StateList;
         List<String> cityList = new List<String>{'Albany','Tioga'};
        CPQ_InventorySearchNew.cityList = cityList;
        inv.statestrings = 'NY'+ ','+'VA';
        inv.citystrings = 'Albany'+ ','+'Tioga';
        inv.countytrings = 'Albany'+ ','+'Tioga';
         List<String> selectedareaOfPracticeL = new List<String>{'Administrative Law','Hospital Law'};
            inv.selectedareaOfPracticeList =selectedareaOfPracticeL;
        PageReference pageRef = Page.CPQInventorySearchNew;
           Test.setCurrentPage(pageRef);
        inv.selectedareaOfPractice = 'Administrative Law';
        inv.selectedProdType = 'Lawyers.com Preferred Banner Placements';
        inv.selectedstatecity ='USA,NY,Albany';
        Test.startTest();
        inv.runsearch();
        inv.dosearch();
        Test.StopTest();
    }
}