/*****
Class Name: bob_contactlist_comp_class 
Created by: Bharath
* @testclass - bob_contactlist_comp_class_test

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-7959    SS            1/12/2022    John Mattheson  <T01>   Create Lead button logic
MHBS-8400    Bharath       09/02/2023   Kimberly Rudy   <T02>   MH Prospect List - Columns displayed
MHBS-8710    Bharath       18/04/2023   John Mattheson  <T03>   MH Book of Business enhancement to prevent prospecting to CPP & Firm SKU customers
MHBS-9041    Lakshmi       05/06/2023   John Mattheson  <T04>   Exclude the contacts that have AM Activity from BOB Prospect list   
MHBS-9361    Bharath       15/06/2023   Kavitha VS      <T05>   CPU Time Limit Error is observed for more than 50+ Contacts
MHBS-9093    Bharath       21/06/2023   Kimberly Rudy   <T06>   MH Prospect List - Exclude Former Subs Expired/Cancelled within 120 days
MHBS-10096   Bharath       01/11/2023   Kavitha VS      <T07>   BOB Functionality not working for MA Leads created by MAC sales Rep
************************************************************************************************************************/
global class bob_contactlist_comp_class{
    @AuraEnabled
    public static List<contactListWrapper> fetchContactWrapper(String searchCountry,String searchCounty,String searchState,String searchCity,List<String> searchAOP){
        List<contactListWrapper> lstcontactListWrapper = new List<contactListWrapper>();
        String aopString = String.join(new List<String>(searchAOP), '\',\'');
        String prac_status = 'Judge\',\'Deceased\',\'Retired\',\'Not Practicing\',\'License Issues\',\'Bad Contact Info\',\'Government Attorney\',\'Not an attorney';
        String cust_status = 'New\',\'Existing\',\'Former Sub'; //<T06>
        String condition0 = ' and (MailingCountry = \''+searchCountry+'\') and (MailingState = \''+searchState+'\') and (MailingCity = \''+searchCity+'\') and (County_1__c = \''+searchCounty+'\')';
        String condition1a = ' and (MailingCountry = \''+searchCountry+'\') and (MailingState = \''+searchState+'\') and (MailingCity = \''+searchCity+'\')';
        String condition1b = ' and (MailingCountry = \''+searchCountry+'\') and (MailingState = \''+searchState+'\') and (County_1__c = \''+searchCounty+'\')';
        String condition2 = ' and (MailingCountry = \''+searchCountry+'\') and (MailingState = \''+searchState+'\')';
        String condition3 = ' and (MailingCountry = \''+searchCountry+'\')';
        //<T02> starts
        String query1 = 'select Id,ISLN__c,Name,Account_Name__c,Phone,MailingState,MailingCity,Email,Website__c,Last_Activity_AE__c,Days_Since_Last_AE_Activity__c from Contact where (DoNotCall = false) and (Days_Last_AE_RSM_Activity__c > 14 or Days_Last_AE_RSM_Activity__c=null) and (Days_Since_Last_Activity_AM_CRM__c > 14 or Days_Since_Last_Activity_AM_CRM__c = null) and In_AM_Book__c = false and (In_AE_Book__c = false) and In_Avvo_AE_Book__c = false and (Open_MH_Lead__c = false) and (Open_Martindale_Avvo_Lead__c =false)'; //<T04> <T07>
        //<T02> ends
        String query2 = ' and (Practice_Area_1__c in (\''+ aopString +'\')'+' or Practice_Area_2__c in (\''+ aopString +'\')'+' or Practice_Area_3__c in (\''+ aopString +'\')'+' or Practice_Area_4__c in (\''+ aopString +'\')'+' or Practice_Area_5__c in (\''+ aopString +'\'))';
        String query3 = ' and (Practice_Status__c not in (\''+ prac_status +'\'))';
        String query4 = ' and ((MH_Customer_Status__c not in (\''+ cust_status +'\')) or (MH_Customer_Status__c = \'Former Sub\' and Loss_Cancel_Date__c > 120))'; //<T06>
        //<T03>, <T05> starts
        String query5 = ' and ((Part_of_sold_Firm_CPP_MBP1__c = false) and (Part_of_sold_Firm_SKU1__c = false))' ;
        //<T03>, <T05> ends
        String query6 = ' Order by Name ASC';
        String finalquery = '';
        List<Contact> obj = new List<Contact>();
        if((searchCity!='-- None --')&&(searchState!='-- None --')&&(searchCountry!='-- None --')&&(searchCounty=='-- None --')){
            //system.debug('c-s-ci'+searchCountry+searchState+searchCity+searchCounty);
            finalquery = query1 + query2 + query3 + query4 + condition1a + query5 + query6;
            obj = Database.query(finalquery);
        }
        else if((searchCity=='-- None --')&&(searchState!='-- None --')&&(searchCountry!='-- None --')&&(searchCounty!='-- None --')){
            //system.debug('c-s-co'+searchCountry+searchState+searchCounty+searchCity);
            finalquery = query1 + query2 + query3 + query4 + condition1b + query5 + query6;
            obj = Database.query(finalquery);
        }
        else if((searchCity=='-- None --')&&(searchState!='-- None --')&&(searchCountry!='-- None --')&&(searchCounty=='-- None --')){
            //system.debug('c-s'+searchCountry+searchState+searchCounty+searchCity);
            finalquery = query1 + query2 + query3 + query4 + condition2 + query5 + query6;
            obj = Database.query(finalquery);
        }
        else if((searchCity=='-- None --')&&(searchState=='-- None --')&&(searchCountry!='-- None --')&&(searchCounty=='-- None --')){
            //system.debug('c'+searchCountry+searchState+searchCounty+searchCity);
            finalquery = query1 + query2 + query3 + query4 + condition3 + query5 + query6;
            obj = Database.query(finalquery);
        }
        else if((searchCity!='-- None --')&&(searchState!='-- None --')&&(searchCountry!='-- None --')&&(searchCounty!='-- None --')){
            //system.debug('c-s-ci-co'+searchCountry+searchState+searchCity+searchCounty);
            finalquery = query1 + query2 + query3 + query4 + condition0 + query5 + query6;
            obj = Database.query(finalquery);
        }
        for(Contact con : obj){
            lstcontactListWrapper.add(new contactListWrapper(false,con));
        } 
        return lstcontactListWrapper;
    }
    
    @AuraEnabled
    public static list<String> aopListGeneration(){
        list<selectoption> prodTypeList = new list<selectoption>();
        Map<String,String> prodCodeMap = new Map<String,String>();
        list<String> areasOfPracticeList = new list<String>();        
        List<GEO_Location__c> geoLocationsList = new List<GEO_Location__c>();
        List<Inventoried_Products_list_using_Product__c > iplist = Inventoried_Products_list_using_Product__c.getall().values();
        for(Inventoried_Products_list_using_Product__c ip: iplist){
            prodTypeList.add(new SelectOption(ip.Product_Name__c,ip.Product_Name__c));
            prodCodeMap.put(ip.Product_Name__c,ip.Product_Code__c);
        }
        String selectedProdType = 'Lawyers.com Preferred Banner Placements';
        String prodId = prodCodeMap.get(selectedProdType);
        String squery = 'select id,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c INCLUDES (\'' + prodId + '\') order by AOP_Name__c limit 1000';
        geoLocationsList = database.query(squery);
        for(GEO_Location__c geo:geoLocationsList ){
            areasOfPracticeList.add(geo.AOP_Name__c);
        }
        return areasOfPracticeList;
    }
    
    public class contactListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public contact objContact{get;set;}
        public contactListWrapper(boolean isChecked, contact objContact){
            this.isChecked = isChecked;
            this.objContact = objContact;
        }
    }
    
    @AuraEnabled
    public static List<String> countryList(){
        Set<String> ret = new Set<String> ();
        List<GEO_Location__c> cqueryList = [SELECT CountryName__c FROM GEO_Location__c where CountryName__c!='' Order by CountryName__c ASC];
        if(cqueryList.size()>0){
            for(GEO_Location__c g :cqueryList){
                ret.add(g.CountryName__c);
            }
        }
        List<String> uniqueValue = new List<String>();
        uniqueValue.addAll(ret);
        return uniqueValue ;
    }
    
    @AuraEnabled
    public static List<String> stateList(String searchCountry){
        Set<String> ret = new Set<String> ();
        List<GEO_Location__c> cqueryList = [Select State_Abbrevation__c from GEO_Location__c where CountryName__c =: searchCountry Order by State_Abbrevation__c ASC];
        if(cqueryList.size()>0){
            for(GEO_Location__c g :cqueryList){
                ret.add(g.State_Abbrevation__c);
            }
        }
        List<String> uniqueValue = new List<String>();
        uniqueValue.addAll(ret);
        return uniqueValue ;
    }
    
    @AuraEnabled
    public static List<String> cityList(String searchCountry,String searchState){
        Set<String> ret = new Set<String> ();
        List<GEO_Location__c> cqueryList = [Select City_Name__c from GEO_Location__c where CountryName__c=:searchCountry and State_Abbrevation__c=:searchState Order by City_Name__c ASC];
        if(cqueryList.size()>0){
            for(GEO_Location__c g :cqueryList){
                ret.add(g.City_Name__c);
            }
        }
        List<String> uniqueValue = new List<String>();
        uniqueValue.addAll(ret);
        return uniqueValue ;
    }
    
    @AuraEnabled
    public static List<String> countyList(String searchCountry,String searchState){
        Set<String> ret = new Set<String> ();
        List<GEO_Location__c> cqueryList = [Select County_Name__c from GEO_Location__c where CountryName__c=:searchCountry and State_Abbrevation__c=:searchState Order by County_Name__c ASC];
        if(cqueryList.size()>0){
            for(GEO_Location__c g :cqueryList){
                ret.add(g.County_Name__c);
            }
        }
        List<String> uniqueValue = new List<String>();
        uniqueValue.addAll(ret);
        return uniqueValue ;
    }
    
    @AuraEnabled
    public static List<String> countryList_Filter(String ele){
        Set<String> ret = new Set<String> ();
        String ele2 = ele+'%';
        List<GEO_Location__c> cqueryList = [SELECT CountryName__c FROM GEO_Location__c where CountryName__c!='' and CountryName__c like :ele2 Order by CountryName__c Desc];
        if(cqueryList.size()>0){
            for(GEO_Location__c g :cqueryList){
                ret.add(g.CountryName__c);
            }
        }
        List<String> uniqueValue = new List<String>();
        uniqueValue.addAll(ret);
        return uniqueValue ;
    }
    
    @AuraEnabled
    public static List<String> stateList_Filter(String searchCountry,String ele){
        Set<String> ret = new Set<String> ();
        String ele2 = ele+'%';
        List<GEO_Location__c> cqueryList = [Select State_Abbrevation__c from GEO_Location__c where CountryName__c =: searchCountry and State_Abbrevation__c like :ele2 Order by State_Abbrevation__c ASC];
        if(cqueryList.size()>0){
            for(GEO_Location__c g :cqueryList){
                ret.add(g.State_Abbrevation__c);
            }
        }
        List<String> uniqueValue = new List<String>();
        uniqueValue.addAll(ret);
        return uniqueValue ;
    }
    
    @AuraEnabled
    public static List<String> countyList_Filter(String searchCountry,String searchState,String ele){
        Set<String> ret = new Set<String> ();
        String ele2 = ele+'%';
        List<GEO_Location__c> cqueryList = [Select County_Name__c from GEO_Location__c where CountryName__c=:searchCountry and State_Abbrevation__c=:searchState and County_Name__c like :ele2 Order by County_Name__c ASC];
        if(cqueryList.size()>0){
            for(GEO_Location__c g :cqueryList){
                ret.add(g.County_Name__c);
            }
        }
        List<String> uniqueValue = new List<String>();
        uniqueValue.addAll(ret);
        return uniqueValue ;
    }
    
    @AuraEnabled
    public static List<String> cityList_Filter(String searchCountry,String searchState,String ele){
        Set<String> ret = new Set<String> ();
        String ele2 = ele+'%';
        List<GEO_Location__c> cqueryList = [Select City_Name__c from GEO_Location__c where CountryName__c=:searchCountry and State_Abbrevation__c=:searchState and City_Name__c like :ele2 Order by City_Name__c ASC];
        if(cqueryList.size()>0){
            for(GEO_Location__c g :cqueryList){
                ret.add(g.City_Name__c);
            }
        }
        List<String> uniqueValue = new List<String>();
        uniqueValue.addAll(ret);
        return uniqueValue ;
    }
    
    //<T01> starts
    @AuraEnabled
    public static String createLeadsFromContacts(List<Id> contactIds){
        Set<Id> conIds = new Set<Id>();
        conIds.addAll(contactIds);
        //system.debug(conIds);
        Id batchProcessId =  Database.executeBatch(new BatchCreateLeadFromContact(conIds)); 
        //system.debug(batchProcessId);
        return batchProcessId;
    }
        
    @AuraEnabled
    public static String getListViews() {
        List<ListView> listviews =  [SELECT Id, Name FROM ListView WHERE SobjectType = 'Lead' and DeveloperName='My_Book_of_Business_Lead'];
        return listviews[0].Id;
    }
    
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }
    //<T01> ends
}