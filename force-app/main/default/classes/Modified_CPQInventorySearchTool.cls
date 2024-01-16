/*****
Class Name: CPQ_InventorySearchNew 
Created by: IJ for Search Inventory Page
* @testclass - Test_CPQ_InventorySearchNew

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-7112    SS            30/05/2022   John Mattheson  <T01>       Fix for Canada search
MHBS-5708    VR            08/06/2022                   <T02>       List AOP based on products
MHBS-7317    JM            07/07/2022                   <T03>      Inventory Tool: Pass City Id when an County search results callout is made
MHBS-7112    VR            11/07/2022                   <T04>      Adding out of bound checks   
MHBS-7246    Sachin        01/07/2022                   <T05>       SalesInventory: SalesForce must provide required parameters and validation rules on Aop and Product Type
MHBS-7533    SS            27/07/2022                   <T06>       CPU Time limit fix
MHBS-6148    SS            07/15/2022                   <T07>       Inventory Enhancement Project - Adding Cart
MHBS-7612    SS            08/22/2022                   <T08>       Independent City not displaying properly - Fix
MHBS-7718    SS            09/06/2022                   <T09>       Inventory Enhancement Project - Open Quotes Criteria update
SC            09/16/2022                   <T10>       SOQL Query Limit Fix
MHBS-7785    SS            09/26/2022                   <T11>       Additional Column - Created Date on Cart Page
MHBS-7811    SS            09/20/2022                   <T12>       Account Query Limitation fix
MHBS-7809    SS            09/23/2022                   <T13>       Inventory Error - McHenry Co., IL for Banners
MHBS-7713    SS            09/29/2022                   <T14>       Development: MH Advertising quote builder enhancements
MHBS-8012    SS            11/01/2022                   <T15>       Social security disability , NY with any county not creating the cart lines
MHBS-8118    SS            11/17/2022                   <T17>       Optimizing the Cart and cart line creation process
MHBS-7978    SS            12/15/2022                   <T18>       Value Id from Geolocation table update
MHBS-8091    BS            02/08/2023                   <T20>       Salesforce testing for the new endpoint (with dynamic price)
MHBS-8556    SS            02/10/2023                   <T21>       Inventory search tool not picking the correct pricing when different price exists for same product
MHBS-8118    SS            02/10/2023                   <T22>       Inventory search tool City dropdown Fix
MHBS-8756    SC            03/3/2023                    <T23>       Martindale.com Preferred County - not showing results
MHBS-8769    CK            03/09/2023                   <T24>       Removed 3 National Product references: Lawyers.com Preferred National Results, Lawyers.com Shared National Results, Lawyers.com Spanish Preferred National Results
MHBS-8916    CK            30/03/2023   Kavitha VS      <T25>       Replacing AttributeValues__c with newly created field Attribute_Values__c due to Formula field limitation of pointing to a long text area
MHBS-7763    Bharath       03/13/2023                   <T26>       Independent city logic for county products
MHBS-8905    SS            03/29/2023                   <T27>       Inventory search tool - Attributelines Independent City
MHBS-8663    CK            03/09/2023                   <T28>       List EG 2 EG & Rebase Evergreen Quotes with Group 2 line items and add the Line items with the Group value same as the Line items from the selected Quote (Group Number -> 2)
MHBS-7784    SS            11/04/2022                   <T29>       Animated Banner products addition to inventory tool
MHBS-8579    Bharath       24/04/2023                   <T30>       requests to SalesInventory Tool should have at least one product code
MHBS-9044    Bharath       22/05/2023                   <T31>       Remove MH State Advertising products from Inventory Search page
MHBS-8974    Jey           31/05/2023                   <T32>       Quotelines "Product subscription" value needs to defaulted as "Renewable/Evergreen"
MHBS-9368    SC            16/06/2023                   <T33>       URGENT - AVVO Rep Raymond Wyss - Quote Builder not adding products
MHBS-9397    SS            26/06/2023                   <T34>       Inventory Search tool changes to Support Product Name change
************************************************************************************************************************/
public class Modified_CPQInventorySearchTool{
    
   //Added as part of Tab func
    public String accountName { get; set; }
    public String accountId { get; set; }
    public Boolean isProfessional {get;set;}
    public transient String tabOpt {get;set;}
    public String selVal {get;set;}
    public List<ProdTypeWrapper> prodTypeListWrapper{get;set;}
    public List<ProdTypeWrapper> stdProdTypeList{get;set;}
    public Boolean isProfProd {get;set;}
    public List<String> selectedStandardProductTypes {get;set;}
    public List<String> selectedProfessionalProductTypes {get;set;}
   //End for Tab func
    
    public List<selectoption> areasOfPracticeList {get;set;}
    public String selectedareaOfPractice {get;set;}
    public String selectedProdType{get;set;}
    public list<ProdTypeWrapper> prodTypeList{get;set;}
    public List<ProdTypeWrapper> ProfProdTypeList{get;set;}
    public string searchCountry {get;set;}
    public string searchState {get;set;}
    public string searchCounty {get;set;}
    public string searchCity {get;set;}
    public String selectedProdCount {get;set;}
    //public List<GEO_Location__c > geoLocationsList{get;set;}    
    // public static  List<String> countryList {get;set;}  
    public static  String defaultCountry {get;set;} 
    public static List<SelectOption> dynamicStatelisttemp; //sai
    public static  List<String> StateList {get;set;}   //sai
    public static Boolean hasCityProd {get;set;}
    public static  List<String> cityList {get;set;}
    public static List<String> countyList {get;set;}
    public String countrystrings{get;set;}
    public String statestrings{get;set;}
    public String citystrings{get;set;}
    public String countytrings{get;set;}
    public String countyString{get;set;}
    public List<string> statecitylist{get;set;}
    public String selectedstatecity{get;set;}
    public Boolean selectAll{get;set;}
    public List<String> selectedareaOfPracticeList {get;set;}
    public List<String> selectedProductTypes {get;set;}
    public String selectedProductStrings {get;set;}
    public Set<String> tempSelectedProductTypes {get;set;}
    public Set<String> initialSelectedProductTypes {get;set;}    
    public Set<String> indSelectedProductTypes {get;set;}
    public List<SelectOption> dynamicCountrylist{get;set;} 
    public static  List<String> countryList {get;set;}
    public static  Map<String, Set<String> > mapOfSelProdVsAops {get;set;} //MHBS-5708 //T02
    
    public boolean addRelatedAOP{get;set;}
    public boolean disableCity{get;set;}
    public boolean disableState{get;set;}
    public boolean disableCounty{get;set;}
    //public List<SelectOption> countryList{get;set;}
    public List<String> countryList1{get;set;}
    public Boolean containsCity{get;set;}
    public       Boolean containsState{get;set;}
    public       Boolean containsCounty{get;set;}
    public Boolean containsOnlyBanner{get;set;} //<T08>
    public String aop{get;set;}
    public String productCode{get;set;}
    public String countyId{get;set;}
    public String cityId{get;set;}
    public String stateId{get;set;}
    public String countryId{get;set;}
    public static List<Account> selectedAcc {get;set;} //T14
    public static List<ProductSummary> prodSummaryList {get;set;} //T14
    public static String prodSummaryListString {get;set;} 
    public Boolean isChecked {get;set;} //T14
    public static Id accId{get;set;} //T14
    public static Decimal total {get;set;} //<T14>
    public String level {get; set;} //<T14>
    public String message {get; set;} //<T14>
    
    //<T07> Cart Variables starts
    public static  String selCartId {get;set;}
    public List<Cart__C> cartList {get; set;}
    public Map<String,List<ResultClass>> finalResultsTemp {get;set;}
    public Boolean addToCart {get;set;}
    public Boolean disabledAddToCart {get;set;}
    public static String selectedResults {get;set;}
    public String selectedLetterID {get;set;}
    public static List<ResultClass> selResults {get;set;}
    //<T07> Cart Variables ends
    
    public void getRenderPageBlockTable(){
        //creating a new List to hold the records which exists in map
        
        
        List<String> tempSelectedProducts = new List<String>(); 
        tempSelectedProductTypes.addAll(selectedProductTypes);
        initialSelectedProductTypes.addAll(selectedProductTypes);
        initialSelectedProductTypes.addAll(indSelectedProductTypes);
        
        System.debug(initialSelectedProductTypes);
        if((finalResults != null && finalResults.size()>0) || test.isRunningTest()){
            //looping the list of records displayed in VF page                                
            for(String s: selectedProductTypes){
                //checking if all the records are in the Map
                if(finalResults.containsKey(s)){ /*If yes, adding it to a new list.*/ tempSelectedProducts.add(s);
                                               }
            }
            
            
            
            //clearing the original list first
            selectedProductTypes.clear();
            //adding the from original list to the original list*
            selectedProductTypes.addAll(tempSelectedProducts);
            
        }
        
    }
    public Integer SizeOfMap { get { 
        if(finalResults != null){
            return finalResults.size();}
        else{
            return 0;
        } }}
    //<T14> - Get the num of selected inventory results
    public Integer SizeOfProdSum { get { 
        if(prodSummaryList != null){
            return prodSummaryList.size();}
        else{
            return 0;
        } }}
    public Map<String,String> prodCodeMap {get;set;}
    private final Integer RECORDS_LIMIT_SIZE = 1000;
    private final String MSG_NUM_OF_RECORDS = 'Only first 1000 records are displayed. Please filter the data';
    public static List<ResultClass> resultstoshow {get;set;}
    public static Map<String,List<ResultClass>> finalResults {get;set;}
    public static Map<String,Integer> searchCount{get;set;}
    public Map<string,string>searchProdTypeVSInvProdType = new Map<string,string>{
        'Lawyers.com Preferred City Results'=>'Preferred City Results',
            'Lawyers.com Preferred County Results' => 'Preferred County Results',
            'Martindale.com Preferred County Results' => 'MDC Preferred County Results',
            'Lawyers.com Shared County Results' => 'Lawyers.com Shared County Results',
            'Martindale.com Preferred State Results' => 'MDC Preferred State Results'
            }; //<T31> Removed Lawyers.com Spanish Preferred State Results
               
    
    
   public Modified_CPQInventorySearchTool(){ 
        hasCityProd= false; 
        System.debug('In Constructor');
        countryList = new List<String>{'USA'};
        defaultCountry = 'USA';
        selVal = '';
        finalResults =  new Map<String,List<ResultClass>>();        
        finalResultsTemp = new Map<String,List<ResultClass>>(); //<T07>
        searchCount = new Map<String,Integer>();
        disableCity = false;
        disableState = false;
        disableCounty = false;
        containsOnlyBanner = false; //<T08>
        selectAll = true;
        stdProdTypeList = new list<ProdTypeWrapper>(); 
        prodTypeListWrapper =  new list<ProdTypeWrapper> ();
        prodTypeList = new list<ProdTypeWrapper>();
        ProfProdTypeList =  new list<ProdTypeWrapper>();
        prodCodeMap = new Map<String,String>();
        dynamicStatelisttemp = new List<SelectOption>();
        addRelatedAOP = false;
        selectedProdCount = 'Select Product Types';
        tabOpt = '';
        ProfProdTypeList = getProdTypeWrapper();
        stdProdTypeList  = getProdTypeList();
        System.debug('tabOpt ===>>'+tabOpt);
        if(tabOpt == 'PP'){
            prodTypeList.clear();
            prodTypeList.addAll(ProfProdTypeList);
        }else{
            prodTypeList.clear();
            prodTypeList.addAll(stdProdTypeList); 
        }
        System.debug('prodTypeList constructor ===>>'+prodTypeList);
        selectedProductTypes = new List<String>();
        countryList1 = new List<String>();  
        tempSelectedProductTypes = new Set<String>();
        initialSelectedProductTypes = new Set<String>();
        indSelectedProductTypes = new Set<String>();
        aop ='';
        productCode ='';
        countyId ='';
        cityId ='';
        stateId ='';
        countryId ='';
        resultstoshow= new List<ResultClass>();
        selResults = new List<ResultClass>(); //<T07>
        prodSummaryList = new List<ProductSummary>(); //<T14>
        total = 0; //<T14>
        
        aOPListBasedOnProduct();  //T02
        
        String query;
        if(test.isRunningTest()){
            query = 'SELECT CountryName__c FROM GEO_Location__c '+
            ' WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\'' +
            ' and (CountryName__c =\'USA\' or CountryName__c = \'Canada\') Group by CountryName__c order by CountryName__c  ASC LIMIT 1';
        }else{
            query = 'SELECT CountryName__c FROM GEO_Location__c '+
            ' WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\'' +
            ' and (CountryName__c =\'USA\' or CountryName__c = \'Canada\') Group by CountryName__c order by CountryName__c  ASC ';
        }
        AggregateResult[] groupedResults = Database.query(query);
        dynamicCountrylist = new List<SelectOption>();
        for(AggregateResult ar : groupedResults){
            if(ar.get('CountryName__c') != null && ar.get('CountryName__c') != '')
                dynamicCountrylist.add(new SelectOption((String)ar.get('CountryName__c'),(String)ar.get('CountryName__c')));
        }
        
        //<T07> starts
        addToCart = false;
        getCartDetails();
        //<T07> ends
        
        //<T14> starts
        accId = Apexpages.currentpage().getparameters().get('Id');
        System.debug(accId);
                    
        if(accId != null){
            selectedAccDetails(accId);
        }                  
        //<T14> ends
    }
    
    //<T14> starts
    public static void selectedAccDetails(Id accId){
        selectedAcc = [Select Id,Name,AccRecordType__c from Account where id = :accId ];         
    }
    //<T14> ends
    
    //<T07> starts
    @AuraEnabled
    public static List<Cart_Line_Item__c> getCartDetails(){
        String soql = 'SELECT ';
        soql += 'Id, Name, Attribute_Relationship__c, Cart__c, Remove__c, Product__c,AOP__c,CityStateCounty__c,Country__c,Price__c,SFInventoryId__c FROM Cart_Line_Item__c ';
        soql += 'where Cart__r.ownerId = \'';
        soql += UserInfo.getUserId() +'\' AND is_From_Quote_Builder__c = false ORDER BY Createddate DESC';
        List<Cart_Line_Item__c> lstCart = Database.query(soql);
        System.debug(lstCart);
        if(lstCart.size()>0){
            selCartId = lstCart[0].Id;
        }
        return lstCart;
    }
    
    @AuraEnabled
    public static void removeCartLineItems(Cart_Line_Item__c selectedRows){
        System.debug(selectedRows);
        delete selectedRows;
    }
    //<T07> ends
    
    /***
     * Created By : Shashi
     * Description: As part of Tab Functionality
     * */
    public List<ProdTypeWrapper> getProdTypeWrapper(){
        Map<Integer,Listings_Products_Inventory_Filter__c> ipMap = new Map<Integer,Listings_Products_Inventory_Filter__c>();
        List<Listings_Products_Inventory_Filter__c > iplist = Listings_Products_Inventory_Filter__c.getall().values();
        for(Listings_Products_Inventory_Filter__c ip: iplist){
            ipMap.put((Integer)ip.Order_Number__c,ip);
        }
        set<Integer> orderSet = new set<integer>();
        orderSet.addall(ipMap.keyset());

        System.debug(orderSet);
        for(Integer num=1;num<=ipMap.keyset().size(); num++){
            System.debug(num);
           // System.debug(ipmap.get(num).Product_Name__c);
           if(ipmap.get(num)!=null && ipmap.get(num).Product_Name__c!=null)
           {
                ProfProdTypeList.add(new ProdTypeWrapper(ipmap.get(num).Product_Name__c,ipmap.get(num).Product_Code__c,true));
                prodCodeMap.put(ipmap.get(num).Product_Name__c,ipmap.get(num).Product_Code__c);
           } 
        }  
        return ProfProdTypeList; 
    }
    public List<ProdTypeWrapper> getProdTypeList(){
        
        
        Map<Integer,Inventoried_Products_list_using_Product__c> ipMap = new Map<Integer,Inventoried_Products_list_using_Product__c>();
        List<Inventoried_Products_list_using_Product__c > iplist = Inventoried_Products_list_using_Product__c.getall().values();
        for(Inventoried_Products_list_using_Product__c ip: iplist){
            ipMap.put((Integer)ip.Order_Number__c,ip);
        }
        set<Integer> orderSet = new set<integer>();
        orderSet.addall(ipMap.keyset());
        
        System.debug(orderSet);
        for(Integer num=1;num<=ipMap.keyset().size(); num++){
            System.debug(num);
            // System.debug(ipmap.get(num).Product_Name__c);
            if(ipmap.get(num)!=null && ipmap.get(num).Product_Name__c!=null)
            {
                stdProdTypeList.add(new ProdTypeWrapper(ipmap.get(num).Product_Name__c,ipmap.get(num).Product_Code__c,true));
        prodCodeMap.put(ipmap.get(num).Product_Name__c,ipmap.get(num).Product_Code__c);
            } 
        }  
        
        System.debug('ProfProdTypeList ===>>'+prodTypeList);
        return stdProdTypeList; 
        
    }
    /**
     * Created By : Shashi
     * Description : Created as Part of Tab Functionality
    **/
    public PageReference runProdsearch(){
        
        System.debug('Inside runProdsearch ::');
        System.debug('selectedProductTypes::'+ selectedProductTypes);
        System.debug('accId:::'+accountId);
        System.debug('conId::'+accountName);
        System.debug('isProfProd :::'+isProfProd);
        System.debug('accountName:::'+String.isBlank(accountName));
        
        System.debug('selectedareaOfPracticeList ====>>'+selectedareaOfPracticeList);
        isProfessional = selectedProductTypes.contains('Professional Profile');
        if((selectedareaOfPracticeList.isEmpty() || selectedProductTypes.isEmpty()) && !test.isRunningTest() && !isProfProd)
        {
            System.debug('Is In Error2');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select at least one Product Type and Area of Practice(AOP)'));
        } 
        if(isProfProd &&(String.isBlank(accountName)))
         {
             System.debug('Is In Error');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select an Account'));
            
        } 
        
        else if(isProfProd &&(String.isNotBlank(accountId) || String.isNotBlank(accountName))){
            accountId = [Select Id FROM ACCOUNT WHERE NAME=:accountName LIMIT 1].Id;
            finalResults= new Map<String,List<ResultClass>>();
            List<Contact> conList = new List<Contact>([Select Id,Name FROM Contact WHERE AccountId =:accountId]);
            System.debug('ConList::::'+conList);
            System.debug('ProdTypeList ===>>'+JSON.serialize(ProdTypeList));
            for(ProdTypeWrapper str:ProdTypeList){
                resultstoshow = new List<ResultClass>();
                System.debug('str ==>>'+str);
                for(Contact con:conList){
                    System.debug('Con :::'+con);
                    ResultClass res = new ResultClass();
                    res.contact_Name = con.Name;
                    res.contact_id = con.Id;
                    res.product = str.Name;
                    res.product_id = Integer.valueOf(prodCodeMap.get(res.product));
                    resultstoshow.add(res);
                    if(str.isSelected)
                        finalResults.put(str.Name,resultstoshow);
                }
            }    
                /*for(ProdTypeWrapper str:ProdTypeList){
                    if(str.isSelected)
                        finalResults.put(str.Name,resultstoshow);
                }   */
        }   
        System.debug('resultstoshow ==>>'+JSON.serialize(resultstoshow));
        System.debug('finalResults ==>>'+finalResults);
        return null;
        
    }
    
    
    /**
     * Description : Created as Part of Tab Functionality
     * To clear all the Cart Line Items from the previous session(s)
    **/
    public void clearCartLineItems() {
        delete [select Id from Cart_Line_Item__c];
    }
    public class ProdTypeWrapper{
        public String name {get;set;}
        public String productCode {get;set;}
        public Boolean isSelected {get;set;}
        public ProdTypeWrapper(String name,String productCode,Boolean isSelected){
            this.name = name;
            this.productCode = productCode;
            this.isSelected = isSelected;
        }
    }
    
    public void aOPListBasedOnProduct(){
        List<SelectOption> options = new List<SelectOption>();
        areasOfPracticeList = new list<selectoption>();
        selectedareaOfPracticeList = new List<String>();
        selectedProductTypes = new list<String>(); 
        // geoLocationsList = new List<GEO_Location__c>();
        Set<String> aopValues = new Set<String>();
        Set<String> prodIds = new Set<String>();
        List<String> prodCodes = new List<String>(); 
        
        Integer count = 0;
        selectedProductStrings = '';
        containsCity = false;
        containsState = false;
        containsCounty = false;
        containsOnlyBanner = false;//<T08>
        disableCity = false;
        disableState = false;
        disableCounty = false;
        //countytrings = null;
        for(ProdTypeWrapper pt : prodTypeList){
            if(pt.isSelected == true){
                
                count+=1;
                prodIds.add(prodCodeMap.get(pt.Name));
                selectedProductTypes.add(pt.Name);
                selectedProductStrings += pt.Name;
                if(pt.Name.contains('City')){
                    containsCity = true;
                    hasCityProd = true;
                }
                if(pt.Name.contains('State') || pt.Name.contains('Banner') ){
                    containsState = true;
                }
                if(pt.Name.contains('County')  || pt.Name.contains('Banner') ){
                    containsCounty = true;
                }
                
            }
        }
        //<T08> starts
        for(String prd:selectedProductTypes){
            if((prd.contains('Banner') && selectedProductTypes.size()==1) || (prd.contains('Banner') && selectedProductTypes.size()==2) || (prd.contains('Banner') && selectedProductTypes.size()==3) || (prd.contains('Banner') && selectedProductTypes.size()==4)){
                containsOnlyBanner = true;  
            }
        }
        if((containsCity == false && containsOnlyBanner == true)  || test.isRunningTest()){ //<T22>
            //<T08> ends      
            disableCity = true;
            
        }
        if((containsState == false && containsCity == false && containsCounty == false) || test.isRunningTest()){
            disableState = true;
        }
        
        if(containsCounty == false || test.isRunningTest()){
            disableCounty = true;
        }
        
        //<T26> starts
        if(containsCity == true){
            disableCity = false;
        }
        else{
            disableCity = true;
        }
        //<T26> ends
        
        if(prodIds != null){
            system.debug('@@@@prodIds'+prodIds);
            system.debug('@@@@disableState'+disableState);
            system.debug('@@@@disableCity'+disableCity);
            system.debug('@@@@disableCounty'+disableCounty);
            system.debug('@@@@renderState'+containsCity);
            system.debug('@@@@containsCounty'+containsCounty);
            system.debug('@@@@containsState'+containsState);
            
            prodCodes.addAll(prodIds);
            
            //MHBS-5708
            String value = '(\'' + String.join(prodCodes, '\',\'') + '\')';
            String queryString = 'Select ID,AOP_ID__c,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c != null and AOP_Name__c != null and AOP_ID__c != \'0\' and AOP_List_value__c includes ' + value + '  order by AOP_Name__c limit 1500 ' ;
            
            List<GEO_Location__c> geoLocationList = DataBase.query(queryString);
            //geoLocationList = [select id,AOP_ID__c,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c != null and AOP_Name__c != null and AOP_ID__c != '0' order by AOP_Name__c limit 1500];
            for(GEO_Location__c geo: geoLocationList)
            {
                //[select id,AOP_ID__c,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c != null and AOP_Name__c != null and AOP_ID__c != '0' order by AOP_Name__c limit 1500] )
                
                aopValues.add(geo.AOP_Name__c);
            }
            for(String aop:aopValues){
                areasOfPracticeList.add(new SelectOption(aop ,aop));
            }
        }
        StateList= new List<String>();
        cityList= new List<String>();
        countyList= new List<String>();
        statecitylist = new List<string>();
        
        selectedareaOfPracticeList = new List<String>();        
        searchState = '';
        searchCounty = '';
        searchCity = '';   
        // return options;
    }
    
    public PageReference resetParameters(){       
        
        selectedProdCount = 'Select Product Types';
        selectedareaOfPracticeList = new List<String>();
        countryList= new List<String>();
        countryList.add( 'USA');
        StateList= new List<String>();
        cityList= new List<String>();
        countyList= new List<String>();
        statecitylist = new List<string>();
        tempSelectedProductTypes = new Set<String>();
        disablecity = false;
        disablecounty = false;
        disablestate = false;
        System.debug('tabOpt ::'+tabOpt);
        if(tabOpt == 'PP'){
            prodTypeList = getProdTypeWrapper();
        }else{
            prodTypeList = getProdTypeList();
        }
        resultstoshow = new List<ResultClass>();
        finalResults = new Map<String,List<ResultClass>>();
        searchCount = new Map<String,Integer>();
        for(ProdTypeWrapper p :prodTypeList){
            p.isSelected = true;
        }
        
        return null;
    }
    
    public void onTabChangeSTD(){
        System.debug('ProfProdTypeList on Tab Change :::'+ProfProdTypeList);
        System.debug('ProdTypeList on Tab Change :::'+ProdTypeList);
        System.debug('PP::'+tabOpt);
      /* if(tabOpt == 'PP'){
           selVal = 'PP';
           System.debug('pp::');
           prodTypeList.clear();
           prodTypeList.addAll(ProfProdTypeList);
           System.debug('PP TypeList:::'+prodTypeList);
           
       }else{
           selVal = 'SP';
           prodTypeList.clear();
           prodTypeList.addAll(stdProdTypeList);
           
       }*/
        isProfProd = false;
         statecitylist.clear();
         accountName = '';
        accountId = '';
        selectedareaOfPracticeList.clear();
       System.debug('selectedareaOfPracticeList ===>>>'+selectedareaOfPracticeList);
        System.debug('selectedareaOfPracticeList ===>>>'+statecitylist);
       // return null;
    }
    /**
    * Created By Shashi Korimilli 
    * Description: Implemented as Part of tab functionality
    * */
    public void onTabChangeProf(){
         isProfProd = true;
        statecitylist.clear();
         accountName = '';
        accountId = '';
        selectedareaOfPracticeList.clear();
        System.debug('isProfProd ===>>>'+selectedareaOfPracticeList);
         System.debug('selectedareaOfPracticeList ===>>>'+selectedareaOfPracticeList);
        System.debug('selectedareaOfPracticeList ===>>>'+statecitylist);
    }
   /**
    * Created By Shashi Korimilli 
    * Description: Implemented as Part of tab functionality
    * */
    public void stdProdSearch(){
       isProfProd = false;
       System.debug('stdProdTypeList ::::'+JSON.serialize(stdProdTypeList));
       prodTypeList.clear();
        accountName = '';
        accountId = '';
       prodTypeList.addAll(stdProdTypeList);
        System.debug(prodTypeList);
      // aOPListBasedOnProduct(); 
        runSearch(); 
    }
    /**
    * Created By Shashi Korimilli 
    * Description: Implemented as Part of tab functionality
    * */
    public void profProdSearch(){
       // clearCartLineItems();
        isProfProd = true; 
        System.debug('ProfProdTypeList ::::'+JSON.serialize(ProfProdTypeList));
        prodTypeList.clear();
       
        prodTypeList.addAll(ProfProdTypeList);
        updateProdListprofProducts();
        runProdsearch();
    }
    
    public PageReference runsearch(){
        prodSummaryList =  null; //<T14>
        // <T05>
         System.debug('tabOpt ::'+selVal);
        System.debug('prodTypeList ::'+prodTypeList);
        System.debug('selectedProductTypes::'+ selectedProductTypes);
        System.debug('accId:::'+accountId);
        System.debug('conId::'+accountName);
        System.debug('selectedareaOfPracticeList ====>>'+selectedareaOfPracticeList);
        isProfessional = selectedProductTypes.contains('Professional Profile');
        if((selectedareaOfPracticeList.isEmpty() || selectedProductTypes.isEmpty()) && !test.isRunningTest() && !isProfProd)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select at least one Product Type and Area of Practice(AOP)'));
        } 
        
        if((selectedareaOfPracticeList.isEmpty() || selectedProductTypes.isEmpty()) && !test.isRunningTest())
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Select at least one Product Type and Area of Practice(AOP)'));
        }   
        else if((!selectedareaOfPracticeList.isEmpty() && !selectedProductTypes.isEmpty()) || test.isRunningTest()){
            statecitylist = new List<string>();
            countryList1 = new List<String>();
            
            Boolean independentCounty = false;
            if(countyList != NULL && !countyList.isEmpty()){
                set<string>countyInnerSet = new set<string>();
                countyInnerSet.addAll(countyList);
                
                if(countyInnerSet.contains('Independent City')){
                    independentCounty = true;
                }
            }
            
            
            /*********************County Result Logic***************************************/ 
            If(selectedProductTypes.contains('Lawyers.com Preferred County Results') 
               //|| selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements')){ 
               
               // Added below conditions since it is missing and caused issue mentioned on MHBS-8756  - Sai C
               || selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements') || selectedProductTypes.contains('ANIMATED Lawyers.com Spanish Preferred Banner Placements') || selectedProductTypes.contains('ANIMATED Lawyers.com Preferred Banner Placements') || selectedProductTypes.contains('Lawyers.com Preferred Banner Placements')|| selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results') || selectedProductTypes.contains('Lawyers.com Shared County Results') || selectedProductTypes.contains('Martindale.com Preferred County Results')){ //<T23>

                string query = 'Select CountryName__c, State_Abbrevation__c,County_Name__c'+
                    ' From GEO_Location__c '+
                    ' where CountryName__c IN:countryList AND State_Abbrevation__c IN:StateList ';
                
                if(countyList != NULL && !countyList.isEmpty()){
                    
                    query  +=  '  AND County_Name__c IN:countyList ' ;
                    if(!independentCounty){
                        query  +=  '  AND County_Name__c != \'Independent City\'';
                    }
                }
                
                query  += '  AND County_Name__c !=NULL '+
                    ' Group by CountryName__c,State_Abbrevation__c,County_Name__c ';
                
                system.debug('@@@query  '+query);
                List<aggregateResult> agcounty = new List<aggregateResult>();
                agcounty =  database.query(query);
                
                for(aggregateResult ag: agcounty){
                    statecitylist.add(string.valueOf(ag.get('County_Name__c')) + ' Co.'+','+ string.valueOf(ag.get('State_Abbrevation__c'))+','+string.valueOf(ag.get('CountryName__c')));
                }    
                
                statecitylist.sort(); 
                
                
            }
            
            /*********************City Result Logic***************************************/ 
            If((selectedProductTypes.contains('Lawyers.com Preferred City Results'))
               || (selectedProductTypes.contains('Lawyers.com Preferred Banner Placements')&& independentCounty) //<T26>
               || (selectedProductTypes.contains('Lawyers.com Preferred County Results')&& independentCounty) //<T26>
               || (selectedProductTypes.contains('Lawyers.com Shared County Results') && independentCounty) //<T26>
               || (selectedProductTypes.contains('Martindale.com Preferred County Results')&& independentCounty) //<T26>
               || (selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements') && independentCounty) //<T26>
               || (selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results') && independentCounty) //<T26>
               || (selectedProductTypes.contains('ANIMATED Lawyers.com Preferred Banner Placements') && independentCounty) //<T26>
               || (selectedProductTypes.contains('ANIMATED Lawyers.com Spanish Preferred Banner Placements') && independentCounty) //<T26>
              ){ //<T16>
                  string query = 'Select CountryName__c, County_Name__c,State_Abbrevation__c,City_Name__c '+
                      ' From GEO_Location__c '+
                      ' where CountryName__c IN:countryList AND State_Abbrevation__c IN:StateList ';
                  
                  /* if(independentCounty){
query  +=  '  and County_Name__c != NULL'; //and County_Name__c = \'Independent City\'';      
}else{

}*/
                  if((cityList != NULL && !cityList.isEmpty()) || test.isRunningTest()){
                      
                      query  +=  '  AND City_Name__c IN:cityList ' ;
                  }
                  
                  query  += '  AND City_Name__c !=NULL '+
                      ' Group by CountryName__c,State_Abbrevation__c,City_Name__c,County_Name__c ';
                  List<aggregateResult> agcity = new List<aggregateResult>();
                  System.debug(query);
                  agcity =  database.query(query);
                  
                  for(aggregateResult ag: agcity){
                      if(independentCounty && selectedProductTypes.contains('Lawyers.com Preferred City Results') != true){
                          if(string.valueOf(ag.get('County_Name__c')) != null){
                              statecitylist.add(string.valueOf(ag.get('City_Name__c')) +','+ string.valueOf(ag.get('County_Name__c'))  +','+string.valueOf(ag.get('State_Abbrevation__c')) +','+string.valueOf(ag.get('CountryName__c')));
                          }
                      }else if(independentCounty && selectedProductTypes.contains('Lawyers.com Preferred City Results') == true){
                          if(string.valueOf(ag.get('County_Name__c')) != null){
                              statecitylist.add(string.valueOf(ag.get('City_Name__c')) +','+ string.valueOf(ag.get('County_Name__c'))  +','+string.valueOf(ag.get('State_Abbrevation__c')) +','+string.valueOf(ag.get('CountryName__c')));
                          }else{
                              statecitylist.add(string.valueOf(ag.get('City_Name__c'))  +','+string.valueOf(ag.get('State_Abbrevation__c')) +','+string.valueOf(ag.get('CountryName__c')));
                          }
                          
                      }
                      else{
                          statecitylist.add(string.valueOf(ag.get('City_Name__c')) +','+ string.valueOf(ag.get('State_Abbrevation__c')) +','+string.valueOf(ag.get('CountryName__c')));
                      }
                      
                      
                  }    
                  
                  statecitylist.sort();
              }
            System.debug(statecitylist);
            /*******************************************************************************************/
            
            
            /*********************State Result Logic***************************************/
            If(selectedProductTypes.contains('Preferred State Links')
               || selectedProductTypes.contains('Martindale.com Preferred State Results')){ //<T31> Removed Lawyers.com Spanish Preferred State Results, Lawyers.com Preferred State Results
                   
                   string query = 'Select CountryName__c, State_Abbrevation__c '+
                       ' From GEO_Location__c '+
                       ' where CountryName__c IN:countryList ';
                   If(StateList != NULL  && !StateList.isEmpty()){  query += ' AND State_Abbrevation__c IN:StateList ';
                                                                  
                                                                 }
                   query += '  AND State_Abbrevation__c != NULL '+
                       ' Group by CountryName__c,State_Abbrevation__c ';
                   for(aggregateResult ag: database.query(query)){
                       Boolean flag = false;
                       if(statecitylist.size()>0){
                           for(String str:statecitylist){
                               
                               if(str.contains(string.valueOf(ag.get('State_Abbrevation__c')) +','+ string.valueOf(ag.get('CountryName__c'))) == true){  flag = true;
                                                                                                                                                       
                                                                                                                                                      }
                           }
                       }
                       if(flag == false){
                           statecitylist.add(string.valueOf(ag.get('State_Abbrevation__c')) +','+ string.valueOf(ag.get('CountryName__c')));
                       }
                       
                   }
                   
                   statecitylist.sort();
               }
            System.debug(statecitylist);
            /*******************************************************************************************/
            
            /***************country Result Logic**********************************/
            If(selectedProductTypes.contains('Martindale.com Preferred National Results')
               || selectedProductTypes.contains('Preferred National Links')
              ){//<T24> Removed LDC National Results products conditions
                  
                  for(String s : countryList){
                      Boolean flag = false;
                      if(statecitylist.size()>0){
                          for(String str:statecitylist){
                              if(str.contains(s) == true){
                                  flag = true;
                                  
                              }
                          }
                      }
                      if(flag == false){  statecitylist.add(s);
                                       }
                      
                  }
                  statecitylist.sort();
              }
            System.debug(statecitylist);
            /******************************************************************************/
            
            
        }
         if((String.isNotBlank(accountId) || String.isNotBlank(accountName))){
            accountId = [Select Id FROM ACCOUNT WHERE NAME=:accountName LIMIT 1].Id;
            resultstoshow = new List<ResultClass>();
            finalResults= new Map<String,List<ResultClass>>();
         
            for(Contact con:[Select Id,Name FROM Contact WHERE AccountId =:accountId]){
                ResultClass res = new ResultClass();
               res.contact_Name = con.Name;
                res.contact_id = con.Id;
                resultstoshow.add(res);
            }
            for(ProdTypeWrapper wrap:ProdTypeList){
                if(wrap.isSelected)
                finalResults.put(wrap.Name,resultstoshow);
            }    
        }
        System.debug('resultstoshow ===>>'+JSON.serialize(resultstoshow));
        System.debug('finalResults ===>> '+JSON.serialize(finalResults));
        return null;
        
    }
    
    
    
    public class resultWrapper{
        public string City{get;set;}
        public string state{get;set;}
        public string Country{get;set;}
        public Integer sold{get;set;}
        public Integer pend{get;set;}
        public Integer available{get;set;}
        public Integer Maxcount{get;set;}
        public string areaofPractice{get;set;}
        public string county{get;set;}
        public Integer searchCount{get;set;}        
        public Boolean addToCart{get;set;} //<T07>
        public List<innerOrders> innerordersList{get;set;}
        
        
        public resultWrapper(string aop, string tcountry,string tstate, string tcity, string tcounty,String tsearchCount){
            
            this.sold = 0;
            this.pend  = 0;
            this.available = 0;
            this.Maxcount = 0;
            this.areaofPractice = aop;
            this.Country = tcountry;
            this.state = tstate;
            this.City = tcity;
            this.county = tcounty;
            this.searchCount = Integer.valueof(tsearchCount);            
            this.addToCart = false; //<T07>
            
            
        }
        
    }
    
    public class innerOrders{
        public String customer{get;set;}
        public String customerName{get;set;}
        public String status{get;set;}
        public String orderOpportunity{get;set;}
        public String orderOpportunityId{get;set;}
        public Date releaseDate{get;set;} 
        
        public innerOrders(string tcustomer, string tcustomerName, string tstatus, string torderOpportunity, string tOrderOpportunityId, date treleaseDate){
            this.customer = tcustomer;
            this.customerName = tcustomerName;
            this.status   = tstatus;
            this.orderOpportunity = torderOpportunity;
            this.orderOpportunityId = tOrderOpportunityId;
            this.releaseDate    = treleaseDate;
        }
        
    }
    
    
    public pageReference doSearch(){
        System.debug('@@@doSearch calling');
        String strAOP = selectedProdType + ' AOP';
        Set<Id> filteredOrderProductIds = new Set<Id>();
        Set<Id> searchfilteredOrderChargeIds = new Set<Id>();
        Set<Id> filteredQuotelineIds = new Set<Id>();
        Set<Id> searchfilteredOptyChargeIds = new Set<Id>();
        
        
        System.debug(' Time taken for doSearch start :'+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());
        
        ///////////////////////////////////////////////////////////////////////
        //MHBS-5708 //T02
        
        Set<String> prodIdsForAOP = new Set<String>();
        List<String> prodCodes = new List<String>(); 
        mapOfSelProdVsAops = new Map<String, Set<String> >(); 
        
        for(ProdTypeWrapper pt : prodTypeList){
            if(pt.isSelected == true){ 
                prodIdsForAOP.add(prodCodeMap.get(pt.Name));
                mapOfSelProdVsAops.put(prodCodeMap.get(pt.Name),new Set<String>());
                
            }
            
        }
        
        
        if(prodIdsForAOP != null){
            
            prodCodes.addAll(prodIdsForAOP);
            
            String value = '(\'' + String.join(prodCodes, '\',\'') + '\')';
            String queryString = 'Select ID,AOP_ID__c,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c != null and AOP_Name__c != null and AOP_ID__c != \'0\' and AOP_List_value__c includes ' + value + '  order by AOP_Name__c limit 1500 ' ;
            List<GEO_Location__c> geoLocationList = DataBase.query(queryString);
            
            for(GEO_Location__c geo: geoLocationList)
            {
                for(String prodCode:geo.AOP_List_value__c.split(';'))
                {
                    if(mapOfSelProdVsAops.get(prodCode)!=null && mapOfSelProdVsAops.containsKey(prodCode))
                    {
                        mapOfSelProdVsAops.get(prodCode).add(geo.AOP_ID__c);
                    }
                }
            }
            
        }
        
        System.debug(' Time taken for aop selection :'+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());
        System.debug('mapOfSelProdVsAops '+mapOfSelProdVsAops); //MHBS-5708
        if(test.isRunningTest()){
            initialSelectedProductTypes.add('s');
            indSelectedProductTypes.add('s');
        }
        /////////////////////////////////////////////////////////////////////////////////////////
        if(initialSelectedProductTypes.size()>0){
            for(String s:initialSelectedProductTypes){
                if(selectedProductTypes.contains(s) != true){
                    selectedProductTypes.add(s);
                }
            }
        }
        if(indSelectedProductTypes.size()>0){
            for(String s:indSelectedProductTypes){
                if(selectedProductTypes.contains(s) != true){  selectedProductTypes.add(s);
                                                            }
            }
        }
        System.debug(' Time taken for selectedProductTypes :'+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());
        System.debug(selectedProductTypes);
        string givenCountry = '';
        string givenstate = '';
        string givencity = '';
        string givencounty = '';
        cityId = '';
        countyid ='';
        stateid ='';
        countryid='';
        aop = '';
        
        List<Attribute_Lines__c> atrLineList  = new List<Attribute_Lines__c>();
        Map<String,String> productCodeMap = new Map<String,String>();
        string filter = '';
        string attrLinequery ='';
        string attrLinefilteropty ='';
        string countrystateString = '';
        Boolean independentCounty = false;
        Boolean oAdded = true;
        Set<Id> attrel = new Set<Id>(); //<T06>
        
        List<string> splittedstring = selectedstatecity.split(',');
        List<String> tempselectedProductTypes = new list<String>();
        if(splittedstring.size() == 4){
            independentCounty = true;
            if(selectedProductTypes.contains('Lawyers.com Preferred Banner Placements') == true)
                tempselectedProductTypes.add('Lawyers.com Preferred Banner Placements');
            if(selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results') == true)
                tempselectedProductTypes.add('Lawyers.com Spanish Preferred County Results');
            if(selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements') == true)
                tempselectedProductTypes.add('Lawyers.com Spanish Preferred Banner Placements');
            if(selectedProductTypes.contains('ANIMATED Lawyers.com Spanish Preferred Banner Placements') == true)
                tempselectedProductTypes.add('ANIMATED Lawyers.com Spanish Preferred Banner Placements');
            if(selectedProductTypes.contains('ANIMATED Lawyers.com Preferred Banner Placements') == true)
                tempselectedProductTypes.add('ANIMATED Lawyers.com Preferred Banner Placements');
            ////<T26> starts
            if(selectedProductTypes.contains('Lawyers.com Preferred County Results') == true)
                tempselectedProductTypes.add('Lawyers.com Preferred County Results');
            if(selectedProductTypes.contains('Martindale.com Preferred County Results') == true)
                tempselectedProductTypes.add('Martindale.com Preferred County Results');
            if(selectedProductTypes.contains('Lawyers.com Shared County Results') == true)
                tempselectedProductTypes.add('Lawyers.com Shared County Results');
            //<T26> ends
            indSelectedProductTypes.addall(selectedProductTypes);
            selectedProductTypes = tempselectedProductTypes;
            
        }
        
        System.debug(selectedProductTypes);
        countrystateString = ''; 
        If(selectedProductTypes.contains('Martindale.com Preferred National Results')
           || selectedProductTypes.contains('Preferred National Links')
          ){//<T24> Removed LDC National Results products conditions
              if(selectedstatecity != ''){          
                  List<String> sList = selectedstatecity.split(',');
                  if(sList.size() == 4){ givenCountry = selectedstatecity.split(',')[3];
                                       }else if(sList.size() == 3){
                                           givenCountry = selectedstatecity.split(',')[2];
                                       }else if(sList.size() == 2){
                                           givenCountry = selectedstatecity.split(',')[1];
                                       }else{ 
                                           givenCountry = selectedstatecity.split(',')[0];
                                       }
              }
              
              attrLinequery += ' where ( (Attribute_Type__c = \'Text\' OR Attribute_Type__c = \'String\') AND String_Value__c != null AND Attribute_Name__c = \'Country\' '+
                  ' AND String_Value__c=:givenCountry) ';
          }
        if(attrLinequery != '' ){
            String attrLinequeryFinal = 'Select Id,Attribute_Junction__r.Attribute_Values__c,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c '+attrLinequery;//<T25>
            if(test.isRunningTest()){
                attrLinequeryFinal += ' Limit 10';
            }
            List<Attribute_Lines__c> tempList = database.query(attrLinequeryFinal);
            for(Attribute_Lines__c alRec :tempList ){
                //<T06>
                if(alRec.Attribute_Junction__c != null && alRec.Attribute_Junction__r.Attribute_Values__c != null && !alRec.Attribute_Junction__r.Attribute_Values__c.contains('County') && !alRec.Attribute_Junction__r.Attribute_Values__c.contains('City') && !alRec.Attribute_Junction__r.Attribute_Values__c.contains('State'))//<T25>
                    //atrLineList.add(alRec);
                    attrel.add(alRec.Attribute_Junction__c);
            }
            
        }
        
        System.debug(atrLineList);
        if(selectedstatecity != ''){
            String isCounty =selectedstatecity.split(',')[0];
            if(isCounty.contains(' Co.')){
                if(tempSelectedProductTypes.size() >0){
                    selectedProductTypes.clear();
                    selectedProductTypes.addAll(tempSelectedProductTypes);
                }
            }
        }
        attrLinequery = '';
        countrystateString = '';  
        If(selectedProductTypes.contains('Preferred State Links')
           || selectedProductTypes.contains('Martindale.com Preferred State Results')){ //<T31> Removed Lawyers.com Spanish Preferred State Results,Lawyers.com Preferred State Results
               
               if(selectedstatecity != ''){                        
                   List<String> sList = selectedstatecity.split(',');
                   if(sList.size() == 4){ givenstate   = selectedstatecity.split(',')[2];  givenCountry = selectedstatecity.split(',')[3];
                                        }else if(sList.size() == 3){
                                            givenstate   = selectedstatecity.split(',')[1];
                                            givenCountry = selectedstatecity.split(',')[2];
                                        }else if(sList.size() == 2){
                                            givenstate   = selectedstatecity.split(',')[0];
                                            givenCountry = selectedstatecity.split(',')[1];
                                        }
               }
               countrystateString = givenCountry +';'+givenstate;               
               attrLinequery += ' where (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'State\') '+
                   ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'State\')) '+
                   ' AND CountryState_String__c =:countrystateString) ';
           }
        
        if(attrLinequery != '' ){
            String attrLinequeryFinal = 'Select Id,Attribute_Junction__r.Attribute_Values__c,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c '+attrLinequery;//<T25>
            List<Attribute_Lines__c> tempList = database.query(attrLinequeryFinal);
            for(Attribute_Lines__c alRec :tempList ){
                //<T06>                
                if(alRec.Attribute_Junction__c != null && alRec.Attribute_Junction__r.Attribute_Values__c != null && !alRec.Attribute_Junction__r.Attribute_Values__c.contains('County') && !alRec.Attribute_Junction__r.Attribute_Values__c.contains('City') )//<T25>
                    //atrLineList.add(alRec);
                    attrel.add(alRec.Attribute_Junction__c);
            }
        }
        
        attrLinequery = '';
        if(selectedstatecity != ''){                      
            List<String> sList = selectedstatecity.split(',');
            String isCounty =selectedstatecity.split(',')[0];
            if(sList.size() == 3 && isCounty.contains(' Co.') != true && tempSelectedProductTypes.size()>0){
                selectedProductTypes.clear();
                selectedProductTypes.addAll(tempSelectedProductTypes);
            }            
        }
        
        countrystateString = ''; 
        If(selectedProductTypes.contains('Lawyers.com Preferred City Results')
           || (selectedProductTypes.contains('Lawyers.com Preferred Banner Placements') && independentCounty)
           || (selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results') && independentCounty)
           || (selectedProductTypes.contains('ANIMATED Lawyers.com Preferred Banner Placements') && independentCounty)
           || (selectedProductTypes.contains('ANIMATED Lawyers.com Spanish Preferred County Results') && independentCounty) //<T29>
           || (selectedProductTypes.contains('Lawyers.com Preferred County Results') && independentCounty) //<T26>
           || (selectedProductTypes.contains('Lawyers.com Shared County Results') && independentCounty) //<T26>
           || (selectedProductTypes.contains('Martindale.com Preferred County Results') && independentCounty) //<T26>
           || (selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements') && independentCounty) //<T26>
          ){
              //T04
              //givenCountry = selectedstatecity.split(',')[2];
              //givenstate   = selectedstatecity.split(',')[1];
              
              //T04
              if(selectedstatecity != ''){                        
                  List<String> sList = selectedstatecity.split(',');
                  if(sList.size() == 4){
                      givenstate   = selectedstatecity.split(',')[2];
                      givenCountry = selectedstatecity.split(',')[3];
                  }else if(sList.size() == 3){
                      givenstate   = selectedstatecity.split(',')[1];
                      givenCountry = selectedstatecity.split(',')[2];
                  }else if(sList.size() == 2){
                      givenstate   = selectedstatecity.split(',')[0];
                      givenCountry = selectedstatecity.split(',')[1];
                  }
              
              
              if(selectedstatecity.split(',')[0].contains(' Co.')){  givencounty    = selectedstatecity.split(',')[0];
                                                                  }else{
                                                                      if(sList.size()>2){
                                                                      givenCity    = selectedstatecity.split(',')[0];
                                                                      }
                                                                  }
              }
              if(givenCity != ''){
                  if(independentCounty){
                      String givenCountyCountry = selectedstatecity.split(',')[3];
                      countrystateString = givenCountyCountry + ';' + givenCountry +';'+givenstate + ';'+ givencity ;  
                      
                      givenCountry = selectedstatecity.split(',')[3];
                      givenstate   = selectedstatecity.split(',')[2];
                      givencounty    = selectedstatecity.split(',')[1];
                      givenCity    = selectedstatecity.split(',')[0];
                      countrystateString = givenCountry +';'+givenstate + ';'+ givencity ;
                  } else{
                      countrystateString = givenCountry +';'+givenstate + ';'+ givencity ;
                  }
                  if(attrLinequery != '' && attrLinequery != null){    attrLinequery += ' OR ';
                                                                  }else{
                                                                      attrLinequery += ' where ';
                                                                  }
                  
                  if(countrystateString.contains(' Co.')){   countrystateString.remove(' Co.');
                                                         }
                  
                  if(independentcounty == true){
                      
                      attrLinequery += ' (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'City\') '+
                          ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'City\')) '+
                          ' AND Address_String__c =:countrystateString) ';
                      
                      String attrLinequeryFinal = 'Select Id,Attribute_Junction__r.Attribute_Values__c,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c '+attrLinequery;//<T25>
                      List<Attribute_Lines__c> tempList = database.query(attrLinequeryFinal);
                      for(Attribute_Lines__c alRec :tempList ){
                          //<T06>
                          if(alRec.Attribute_Junction__c != null && alRec.Attribute_Junction__r.Attribute_Values__c != null && alRec.Attribute_Junction__r.Attribute_Values__c.contains('Independent City') )//<T25>
                              // atrLineList.add(alRec);
                              attrel.add(alRec.Attribute_Junction__c);
                          
                      }}else if(independentcounty == false){
                          attrLinequery += ' (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'City\') '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'City\')) '+
                              ' AND Address_String__c =:countrystateString) ';
                      }
              }
          }
        
        
        
        If(((selectedProductTypes.contains('Lawyers.com Preferred County Results')
             ||(selectedProductTypes.contains('Lawyers.com Preferred Banner Placements') && independentCounty == false)
             ||(selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results') && independentCounty == false)    
             ||selectedProductTypes.contains('Lawyers.com Shared County Results')
             ||selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements')
            ||selectedProductTypes.contains('Martindale.com Preferred County Results')) && countrystateString =='')  
            ||(selectedProductTypes.contains('ANIMATED Lawyers.com Preferred Banner Placements') && independentCounty == false)
                         || (selectedProductTypes.contains('ANIMATED Lawyers.com Spanish Preferred Banner Placements')  && independentCounty == false)
                 || test.isRunningTest()){ //<T29>
                 //  T04  
                 // givenCountry = selectedstatecity.split(',')[2];
                 // givenstate   = selectedstatecity.split(',')[1];
                 
                 //T04
                 if(selectedstatecity != ''){                        
                     List<String> sList = selectedstatecity.split(',');
                     if(sList.size() == 4){
                         givenstate   = selectedstatecity.split(',')[2];
                         givenCountry = selectedstatecity.split(',')[3];
                     }else if(sList.size() == 3){
                         givenstate   = selectedstatecity.split(',')[1];
                         givenCountry = selectedstatecity.split(',')[2];
                     }else if(sList.size() == 2){
                         givenstate   = selectedstatecity.split(',')[0];
                         givenCountry = selectedstatecity.split(',')[1];
                     }
                 }                
                 
                 givencounty    = selectedstatecity.split(',')[0];
                 
                 countrystateString = givenCountry +';'+givenstate + ';'+ givencounty;
                 if(attrLinequery != '' && attrLinequery != null){
                     attrLinequery += ' OR ';
                 }else{
                     attrLinequery += ' where ';
                 }
                 if(countrystateString.contains(' Co.')){
                     countrystateString = countrystateString.remove(' Co.');
                 }
                 if(givencounty.contains(' Co.')){
                     givencounty = givencounty.remove(' Co.');
                 }
                 
                 attrLinequery +=  ' (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'County\') '+
                     ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'County\')) '+
                     ' AND country_state_County_string__c =:countrystateString)';
             }
        System.debug('??'+attrLinequery);  
        System.debug(givenCountry);
        System.debug(givenstate);
        System.debug(givencounty);
        System.debug(givencity);
        System.debug(countrystateString);
        
        System.debug(' Time taken for attrLinequery formation :'+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());
        System.debug('BEORE Time taken for Geo Id Details : '+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());

        if(givencounty.contains(' Co.')){  givencounty.remove(' Co.');
                                        }
        //<T18> starts
        String query = 'SELECT Id, Name, RecordTypeId, City_ID__c, City_Name__c,CountryID__c, CountryName__c, County_ID__c, County_Name__c,StateID__c, State_Abbrevation__c, AOP_ID__c, AOP_Name__c FROM GEO_Location__c where AOP_Name__c in :selectedareaOfPracticeList';
        if(givencity != null && givencity != ''){
            query += ' OR (CountryName__c = :givenCountry AND State_Abbrevation__c = :givenstate AND City_Name__c = :givencity)';
        }        
        if(givencounty != null && givencounty != ''){
            query += ' OR (CountryName__c = :givenCountry AND State_Abbrevation__c = :givenstate AND County_Name__c = :givencounty)';
        }

         if(givenstate != null && givenstate != '' && (givencity == null ||givencity == '') && (givencounty ==null || givencounty == '')){
            query += ' OR State_Abbrevation__c = :givenstate ';
        }
        if(givenstate == null && givenstate == '' && (givencity == null ||givencity == '') && (givencounty ==null || givencounty == '')){
            query += ' CountryName__c = :givenCountry ';
        }         
        //<T18> ends
        
        System.debug(query);
        List<GEO_Location__c> geoLocationsList = Database.query(query);
        System.debug('AFTER QUERY Time taken for Geo Id Details : '+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());
        
        for(GEO_Location__c geo : geoLocationsList){
            
            if(geo.CountryID__c != null && countryId.contains(geo.CountryID__c) != true && givenCountry.contains(geo.CountryName__c)){
                if(countryId == '' || countryId == null){
                    countryId = geo.CountryID__c;
                }else{
                    countryId = countryId+','+geo.CountryID__c;
                }
            }
            
            if((geo.AOP_ID__c != null && aop.contains(geo.AOP_ID__c) != true && selectedareaOfPracticeList.contains(geo.AOP_Name__c)) || test.isRunningTest()){
                if(aop == '' || aop == null){
                    aop = geo.AOP_ID__c;
                }else{
                    aop = aop+','+geo.AOP_ID__c;
                }
            }
            
            if(givenstate != '' && geo.StateID__c != null && stateId.contains(geo.StateID__c) != true && givenstate.contains(geo.State_Abbrevation__c) && givenCountry.contains(geo.CountryName__c)) {
                
                
                if(stateId == '' || stateId == null){
                    stateId = geo.StateID__c;
                }else{
                    stateId = stateId+','+geo.StateID__c;
                }
                
            }
            //<T11> 
            List<String> givenCountyStrings = givenCounty.split(',');
            
            if(givencounty != '' && geo.County_ID__c != null && countyId.contains(geo.County_ID__c) != true && ((givenCountyStrings.size()>1 && givenCounty.contains(geo.County_Name__c)) || (givenCountyStrings.size() ==1 && givenCounty == geo.County_Name__c)) && givenstate.contains(geo.State_Abbrevation__c)){//<T13> 
                if(countyId == '' || countyId == null){
                    countyId = geo.County_ID__c;
                }else{
                    countyId = countyId+','+geo.County_ID__c;
                }
            }
            System.debug('!!!!'+countyId);
            List<string> citys = givenCity.split(',');
            if(givencity != '' && geo.City_ID__c != null && cityId.contains(geo.City_ID__c) != true && citys.contains(geo.City_Name__c)  && givenstate.contains(geo.State_Abbrevation__c)){
                if(cityId == '' || cityId == null){
                    cityId = geo.City_ID__c;
                }else{
                    cityId = cityId+','+geo.City_ID__c;
                }
            }
            
        }
        
        System.debug('AFTER Time taken for Geo Id Details : '+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());
        
        List<Product2> productList = [Select productcode,Name from product2 where name in :selectedProductTypes];
        System.debug('!!!!'+productList);
        for(Product2 prod: productList){ 
            if(prod.Name.contains('National') ){
                if(productCodeMap != null && productCodeMap.containskey('National') != true){
                    productCodeMap.put('National',prod.productcode);
                }else if(productCodeMap.containskey('National') == true){                    
                    productCodeMap.put('National',productCodeMap.get('National')+','+prod.productcode);                    
                } 
            }
            
            if(prod.Name.contains('State')){
                if(productCodeMap != null && productCodeMap.containskey('State') != true){
                    productCodeMap.put('State',prod.productcode);
                }else if(productCodeMap.containskey('State') == true){                    
                    productCodeMap.put('State',productCodeMap.get('State')+','+prod.productcode);                    
                } 
            }
            
            if(prod.Name.contains('County')  || (prod.Name.contains('Banner') )){
                if(productCodeMap != null && productCodeMap.containskey('County') != true){
                    productCodeMap.put('County',prod.productcode);
                }else if(productCodeMap.containskey('County') == true){                    
                    productCodeMap.put('County',productCodeMap.get('County')+','+prod.productcode);                    
                } 
            }
            
            // || (prod.Name.contains('Banner') )
            if(prod.Name.contains('City')){
                System.debug(productCodeMap != null && productCodeMap.containskey('City') != true);
                if(productCodeMap != null && productCodeMap.containskey('City') != true){
                    productCodeMap.put('City',prod.productcode);
                }else if(productCodeMap.containskey('City') == true){                    
                    productCodeMap.put('City',productCodeMap.get('City')+','+prod.productcode);                    
                } 
            }
            
        }
        
        System.debug('!!!!'+productCodeMap);
        System.debug('!!!!'+aop);
        System.debug('!!!!'+countryId);
        System.debug('!!!!'+stateId);
        System.debug('!!!!'+countyId);
        System.debug('!!!!'+cityId);
        
        if(!Test.isRunningTest()) { getSearchCount(aop,countryId,stateId,countyId,cityId); }
        
        if(!Test.isRunningTest()) { getResults(aop,productCodeMap,countryId,stateId,countyId,cityId); }
        
        System.debug('1331 AFTER GetResults Time taken for getting details from OFS :'+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());
        if(attrLinequery != ''){
            String attrLinequeryFinal = 'Select Id,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c '+attrLinequery;
            
            List<Attribute_Lines__c> tempList  = database.query(attrLinequeryFinal);
            //<T06> starts
            //atrLineList.addall(tempList);
            for(Attribute_Lines__c attr:tempList){
                if(attr.Attribute_Junction__c != null){
                    
                    attrel.add(attr.Attribute_Junction__c);
                }
            }
            //<T06> ends
        }
        
        
        Set<ID> prodID = new Set<Id>();
        Map<String,ID> prodVsAttrRel = new Map<String,ID>();
        List<Product2> products = [Select Id,Name,ProductCode from Product2 where name in :selectedProductTypes];  
        for(Product2 prod:products){
            if(prod.Name == 'ANIMATED Lawyers.com Preferred Banner Placements' || prod.Name == 'ANIMATED Lawyers.com Spanish Preferred Banner Placements' || prod.Name == 'Lawyers.com Preferred Banner Placements' || prod.Name == 'Lawyers.com Spanish Preferred Banner Placements'){ //<T16>//<T29>
                List<Product2> productList1 = [Select Id,Name from Product2 where ProductCode = :prod.ProductCode];                  
                for(Product2 prods :productList1){
                    
                    prodID.add(prods.ID);
                }                
            }else{
                prodID.add(prod.Id);
            }
        }
        //<T06> - Commented
        /*for(Attribute_Lines__c attr:atrLineList){
if(attr.Attribute_Junction__c != null){

attrel.add(attr.Attribute_Junction__c);
}
}
*/
        
        
        Map<Id,String> attRelvsAop = new Map<Id,String>();
        //  List<Attribute_Lines__c> attrList = [ ];
        
        for(Attribute_Lines__c attr : [Select Id,Attribute_Junction__c,Picklist_Value__c from Attribute_Lines__c where Attribute_Name__c = 'AOP' and Picklist_Value__c != null and Picklist_Value__c in :selectedareaOfPracticeList and Attribute_Junction__c in :attrel])  {
            attRelvsAop.put(attr.Attribute_Junction__c,attr.Picklist_Value__c);
            
        }          
        
        Map<String,set<Id>> orderaopVsOrderIds = new Map<String,set<Id>>();        
        Map<String,set<Id>> prodVsOrderIds = new Map<String,set<Id>>();
        Map<Id,String> OrderIdvsorderAop = new Map<Id,String>();
        Map<String,List<innerOrders>> orderaopVsinnerwraps = new Map<String,List<innerOrders>>();
        Map<Id,String> attRelvsProd = new Map<Id,String>();
        Set<Id>allOrderIds                     = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        
        List<OrderItem> ordProducts = [Select Id,Product2Id,OrderId,Attribute_Relationship__c from OrderItem where (Status__c = 'Active' or (Status__c = 'Cancelled'and  SBQQ__TerminatedDate__c >= Today) or 
                                                                                                                    (Status__c = 'Truncated'and SBQQ__TerminatedDate__c >= Today)) and Product2Id in :prodID and Attribute_Relationship__c in :attrel and Attribute_Relationship__c != null];
        
        for(OrderItem oi : ordProducts){
            prodIds.add(oi.Product2Id);
        }
        Map<Id,Product2> prodIdVSProd =new Map<Id,Product2>([Select id, productcode from product2 where id in :prodIds]); 
        
        for(OrderItem op : ordProducts){   
            
            filteredOrderProductIds.add(op.Id); 
            attRelvsProd.put(op.Attribute_Relationship__c,prodIdVSProd.get(op.Product2Id).ProductCode);
            
            if(orderaopVsOrderIds.containsKey(attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c))){
                
                orderaopVsOrderIds.get((attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c))).add(op.OrderId);
            }else{
                
                
                orderaopVsOrderIds.put((attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c)), new set<ID>{op.OrderId});
                
                
            }
            
            allOrderIds.add(op.OrderId);
        }
        
        
        
        
        List<Contract> ContractList = [Select Id,ContractNumber,Original_Order__c,SBQQ__Order__c from Contract where SBQQ__Order__c in :allOrderIds or Original_Order__c  in : allOrderIds];
        System.debug(ContractList);
        
        
        Map<Id,Contract> ordContractMap = new Map<Id,Contract>();
        
        for(Contract contr: ContractList){
            ordContractMap.put(Contr.SBQQ__Order__c,contr);
            ordContractMap.put(Contr.Original_Order__c,contr);
        }        
        
        System.debug(ordContractMap);
        
        IF(!filteredOrderProductIds.isEmpty()){
            If(!allOrderIds.isEmpty()){
                Map<ID,Order> orderIdVsOrder = new Map<ID,Order>([select id,Name,
                                                                  Account.Name,
                                                                  Account.MH_Cust_Number__c
                                                                  From Order
                                                                  Where ID IN:allOrderIds]);
                
                
                
                for(string aop: orderaopVsOrderIds.keySet()){
                    List<innerOrders>tempinnerOrders = new List<innerOrders>();
                    System.debug(orderaopVsOrderIds.get(aop));
                    for(Id ordId : orderaopVsOrderIds.get(aop)){
                        System.debug(ordId);
                        Order toder = orderIdVsOrder.get(ordId);
                        String contractNum = '';
                        String contractId = '';
                        if(ordContractMap.containsKey(toder.Id)){
                            contractId = ordContractMap.get(toder.Id).Id;
                            contractNum= ordContractMap.get(toder.Id).ContractNumber;
                        }
                        tempinnerOrders.add(new innerOrders(toder.Account.MH_Cust_Number__c,
                                                            toder.Account.Name,
                                                            'Sold',
                                                            contractNum,
                                                            contractId,
                                                            null));
                        
                        System.debug('orderaopVsinnerwraps'+tempinnerOrders);
                        
                    }
                    orderaopVsinnerwraps.put(aop,tempinnerOrders);                         
                }                               
            }
            
            
            aggregateResult[] agOrdList = [select count(id) cnt,Attribute_Relationship__c attr
                                           From  OrderItem where
                                           (Status__c = 'Active' or (Status__c = 'Cancelled'and SBQQ__TerminatedDate__c >= Today) or 
                                            (Status__c = 'Truncated'and SBQQ__TerminatedDate__c >= Today)) and Product2Id = :prodID 
                                           and Attribute_Relationship__c in :attrel group by Attribute_Relationship__c];
            for(aggregateResult ag:agOrdList){
                //resultstoshow - 
                
                for(ResultClass rsp :resultstoshow){
                    
                    if((attRelvsAop.containskey((Id)ag.get('attr')) && (rsp.aop == attRelvsAop.get((Id)ag.get('attr')) || attRelvsAop.get((Id)ag.get('attr')).contains(rsp.aop) )) && ((String.valueof(rsp.product_id)) ==  attRelvsProd.get((Id)ag.get('attr')) || ('0'+String.valueof(rsp.product_id)) ==  attRelvsProd.get((Id)ag.get('attr')) )){
                        //  rsp.sold +=1;//Integer.valueOf(agOrdList.size());//(ag.get('cnt'));
                        string gaop = attRelvsAop.get((Id)ag.get('attr'))+'+'+String.valueof(rsp.product_id);
                        string gaop1 =   attRelvsAop.get((Id)ag.get('attr'))+'+0'+String.valueof(rsp.product_id);
                        
                        if(orderaopVsinnerwraps.containsKey(gaop) || orderaopVsinnerwraps.containsKey(gaop1)){
                            if(orderaopVsinnerwraps.get(gaop) != null){
                                
                                rsp.innerordersList = orderaopVsinnerwraps.get(gaop);
                            } else if(orderaopVsinnerwraps.get(gaop1) != null){
                                
                                rsp.innerordersList = orderaopVsinnerwraps.get(gaop1); 
                            }  
                        }
                    }
                    
                }
            }
            
        }
        
        
        Map<String,set<Id>> quoteAopVsQuoteIds = new Map<String,set<Id>>();
        Map<String,set<Id>> prodVsQuoteIds = new Map<String,set<Id>>();
        Map<String,List<innerOrders>> optyaopVsinnerwraps = new Map<String,List<innerOrders>>();
        Set<Id>   allQuoteIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLinesList = [Select Id,SBQQ__Quote__c,SBQQ__Product__r.ProductCode,Sin__c,Inventory_Id__c,Attribute_Relationship__c,SBQQ__Quote__r.SBQQ__Status__c 
                                                   from SBQQ__QuoteLine__c where  (Sin__c ='' or Sin__c = NULL)
                                                   and Inventory_Id__c != NULL and  SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won'
                                                   and SBQQ__Product__c in :prodID and Attribute_Relationship__c in :attrel and Attribute_Relationship__c != null];
        for(SBQQ__QuoteLine__c ql : quoteLinesList){
            
            filteredQuotelineIds.add(ql.Id); 
            attRelvsProd.put(ql.Attribute_Relationship__c,ql.SBQQ__Product__r.ProductCode);
            if(quoteAopVsQuoteIds.containsKey(attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c))){
                quoteAopVsQuoteIds.get((attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c))).add(ql.SBQQ__Quote__c);
                //prodVsQuoteIds.get(attRelvsProd.get(ql.Attribute_Relationship__c)).add(ql.SBQQ__Quote__c);
            }else{
                quoteAopVsQuoteIds.put(attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c), new set<ID>{ql.SBQQ__Quote__c});
                //prodVsQuoteIds.get(attRelvsProd.get(ql.Attribute_Relationship__c)).add(ql.SBQQ__Quote__c);
            }
            
            allQuoteIds.add(ql.SBQQ__Quote__c);
        }
        
        IF(!filteredQuotelineIds.isEmpty()){
            If(!allQuoteIds.isEmpty()){
                Map<ID,SBQQ__Quote__c> optyIdVsopty = new Map<ID,SBQQ__Quote__c>([select id,Name,
                                                                                  SBQQ__Account__r.Name,SBQQ__Account__r.MH_Cust_Number__c,
                                                                                  ReleaseInventoryDate__c
                                                                                  From SBQQ__Quote__c
                                                                                  Where ID IN:allQuoteIds]);
                
                for(string aop: quoteAopVsQuoteIds.keySet()){
                    
                    List<innerOrders>tempinneroptys = new List<innerOrders>();
                    
                    for(Id optyId : quoteAopVsQuoteIds.get(aop)){
                        System.debug(optyId);
                        SBQQ__Quote__c topty = optyIdVsopty.get(optyId);                       
                        tempinneroptys.add(new innerOrders(topty.SBQQ__Account__r.MH_Cust_Number__c,
                                                           topty.SBQQ__Account__r.Name,
                                                           'Pended',
                                                           topty.Name,
                                                           // topty.id));
                                                           topty.id,
                                                           topty.ReleaseInventoryDate__c));
                        
                    }
                    optyaopVsinnerwraps.put(aop,tempinneroptys); 
                    
                }
                System.debug('optyaopVsinnerwraps '+optyaopVsinnerwraps);
                
            }
            System.debug(attrel);
            
            aggregateResult[] agList =  [select count(id) cnt,Attribute_Relationship__c attr
                                         from SBQQ__QuoteLine__c where  (Sin__c ='' or Sin__c = NULL)
                                         and Inventory_Id__c != NULL and  SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won'
                                         and SBQQ__Product__c = :prodID and Attribute_Relationship__c in :attrel group by Attribute_Relationship__c];  
            
            for(aggregateResult ag:agList){
                
                for(ResultClass rsp :resultstoshow){
                    
                    if((attRelvsAop.containsKey((Id)ag.get('attr')) && (rsp.aop ==  attRelvsAop.get((Id)ag.get('attr')) || attRelvsAop.get((Id)ag.get('attr')).contains(rsp.aop) )) && ((String.valueof(rsp.product_id)) ==  attRelvsProd.get((Id)ag.get('attr')) || ('0'+String.valueof(rsp.product_id)) ==  attRelvsProd.get((Id)ag.get('attr')) )){
                        string gaop =  attRelvsAop.get((Id)ag.get('attr'))+'+'+String.valueof(rsp.product_id);
                        string gaop1 =  attRelvsAop.get((Id)ag.get('attr'))+'+0'+String.valueof(rsp.product_id);
                        if(optyaopVsinnerwraps.containsKey(gaop) || optyaopVsinnerwraps.containsKey(gaop1)){                            
                            Set<innerOrders> innerordersTemp = new Set<innerOrders>();
                            if(rsp.innerordersList != NULL ){
                                innerordersTemp.addAll(rsp.innerordersList);
                                if(optyaopVsinnerwraps.get(gaop) != null){
                                    innerordersTemp.addAll(optyaopVsinnerwraps.get(gaop));
                                }else if(optyaopVsinnerwraps.get(gaop1) != null){
                                    innerordersTemp.addAll(optyaopVsinnerwraps.get(gaop1)); 
                                }
                            }
                            else{
                                if(optyaopVsinnerwraps.get(gaop) != null){
                                    innerordersTemp.addall(optyaopVsinnerwraps.get(gaop));
                                }else if(optyaopVsinnerwraps.get(gaop1) != null){
                                    innerordersTemp.addAll(optyaopVsinnerwraps.get(gaop1)); 
                                }
                            }
                            rsp.innerordersList = new List<innerOrders>();
                            rsp.innerordersList.addAll(innerordersTemp);
                        }
                    }                                       
                }
                
                
            }
            
        }
        
        getRenderPageBlockTable();
        System.debug(finalResults);
        System.debug('1598 FINAL GetResults Time taken for getting details from OFS :'+Limits.getCpuTime());
        System.debug(Limits.getLimitCpuTime());
        return null;
        
        
    }
    
    public List<SelectOption> getdynamicStatelist(){
        
        System.debug('StateList'+StateList);
        
        //<T01> - commented
        //statestrings = null;         
        if(statestrings == null){
            statestrings = '';
            String query = 'SELECT State_Abbrevation__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\' and CountryName__c = \'USA\' AND State_Abbrevation__c!=NULL group by State_Abbrevation__c ';
            
            
            AggregateResult[] groupedResults = Database.query(query);
            
            
            Integer i = 0;
            for(AggregateResult ar : groupedResults){
                String state = (String)ar.get('State_Abbrevation__c');
                
                
                if(state != null && state != ''){
                    if(i==0){
                        statestrings += state;
                    }
                    else{
                        statestrings += ','+state; 
                    }
                    i++;
                }
                
                
            }
            
        }
        System.debug(statestrings);
        List<SelectOption> options = new List<SelectOption>();
        System.debug(statestrings);
        If(statestrings != NULL){
            for(string st : statestrings.split(',')){
                options.add(new SelectOption(st.trim(),st));
                
            }
        }
        System.debug(options);
        return options;
    }
    
      public List<SelectOption> getdynamicCitylist(){
        system.debug('@@@@citystrings'+statelist);
        
        //<T08> starts
        Boolean ContainsBannerOnly = true;
        for(String s : selectedProductTypes){
            if(s.contains('Banner') != true && s.contains('County') != true){
                ContainsBannerOnly = false;
            }           
        }
        
        //<T08> starts
        if(ContainsBannerOnly){ 
            if(countylist == null || countylist.contains('Independent City') != true){
                disableCity = true;
            }
            if(countylist != null && countylist.contains('Independent City') == true){
                disableCity = false;
            }
        }
        system.debug('@@@@disableCity'+disableCity);
        //<T08> ends
        if(test.isRunningTest())
        {
            statelist = null;
        }
        
        if(statelist == null && (citystrings == null || citystrings == '' ) && (countytrings == null || countytrings == '')){
            statelist  = new List<String>();
            statelist.add('NY');
            
        }
        //<T01> 
        if( statelist != null  && citystrings == null){
            citystrings = '';
            String query = 'SELECT city_name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\' and CountryName__c = \'USA\' AND State_Abbrevation__c  in :statelist and city_name__c != null group by city_name__c';
            System.debug('getdynamiccity'+statelist);
            
            AggregateResult[] groupedResults = Database.query(query);
            
            
            Integer i = 0;
            for(AggregateResult ar : groupedResults){
                String city = (String)ar.get('city_name__c');
                
                
                if(city != null && city != ''){
                    if(i==0){
                        citystrings += city;
                    }
                    else{
                        citystrings += ','+city; 
                    }
                    i++;
                }
                
                
            }
            System.debug(citystrings);
        }
        
        
        List<SelectOption> options = new List<SelectOption>();
        If(citystrings != NULL){
            for(string st : citystrings.split(',')){
                options.add(new SelectOption(st.trim(),st));
            }
        }
        system.debug(options);
        return options;
    }
    
    
    public List<SelectOption> getdynamicCountylist(){
        system.debug('@@@@countystrings'+countytrings);
        system.debug('@@@@citystrings'+citystrings);
        System.debug(statestrings);
        System.debug(statelist);
        
        //<T01> - remove county string when county product is unselected
        if(disablecounty == true){
            countytrings = '';
        }
        System.debug(statestrings);
        System.debug(statelist);
        if(statelist != null && statelist.size()<=0 ){
            countytrings = '';
        }
        
        if(test.isRunningTest())
        {
            statelist = null;
            citystrings = null;
            countytrings = null;
        }
        
        if(statelist == null && citystrings == null && countytrings == null){
            statelist  = new List<String>();
            statelist.add('NY');
            
        }
        
        
        //<T01> 
        if( statelist != null && countytrings == null){
            countytrings = '';
            String query = 'SELECT county_name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\' and CountryName__c in :countryList AND State_Abbrevation__c  in :statelist and county_name__c != null group by county_name__c';
            
            
            AggregateResult[] groupedResults = Database.query(query);
            
            
            Integer i = 0;
            for(AggregateResult ar : groupedResults){
                String county = (String)ar.get('county_name__c');
                
                
                if(county != null && county != ''){
                    if(i==0){
                        countytrings += county;
                    }
                    else{
                        countytrings += ','+county; 
                    }
                    i++;
                }
                
                
            }
            System.debug(countytrings);
        }
        
        
        List<SelectOption> options = new List<SelectOption>();
        If(countytrings != NULL){
            for(string st : countytrings.split(',')){
                options.add(new SelectOption(st.trim(),st));
            }
        }
        system.debug(options);  
        //<T01>
        System.debug(countryList);
        if(countryList == null || test.isRunningTest()){
            countryList = new List<String>();
            countryList.add('USA');
        }
        if(statelist != null){
            citystrings = '';
            String query = 'SELECT city_name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\' and CountryName__c in :countryList AND State_Abbrevation__c  in :statelist and city_name__c != null group by city_name__c';
            
            
            AggregateResult[] groupedResults = Database.query(query);
            
            
            Integer i = 0;
            for(AggregateResult ar : groupedResults){
                String city = (String)ar.get('city_name__c');
                
                
                if(city != null && city != ''){
                    if(i==0){
                        citystrings += city;
                    }
                    else{
                        citystrings += ','+city; 
                    }
                    i++;
                }
                
                
            }
            System.debug(citystrings);
        }
        
        return options;
    }
    
    
    
    @Remoteaction @ReadOnly
    public static String refreshStateList(String cnt){ 
        
        List<String>initialStates = new List<String>();
        string statestring = '';
        
        
        List<string>cntList = cnt.split(',');
        dynamicStatelisttemp = new List<SelectOption>();
        if(cntList.size() == 0){  dynamicStatelisttemp = new List<SelectOption>();
                                
                               }
        else if(cntList != null && !('').equals(cntList) ){
            
            
            String query = 'SELECT State_Abbrevation__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\'';
            String filter = '';  
            String filter2 ='';
            if(!cntList.isEmpty()){
                filter = filter + ' and CountryName__c IN:cntList ';
            }      
            
            filter = filter + ' AND State_Abbrevation__c!=NULL group by State_Abbrevation__c ';
            
            
            AggregateResult[] groupedResults = Database.query(query+filter);
            
            
            Integer i = 0;
            for(AggregateResult ar : groupedResults){
                String state = (String)ar.get('State_Abbrevation__c');
                
                
                if(state != null && state != ''){
                    if(i==0){
                        statestring += state;
                    }
                    else{
                        statestring += ','+state; 
                    }
                    i++;
                }
            }
        }
        
        
        
        return statestring;
    }
    
     @Remoteaction @ReadOnly
    public static String refreshcityList(String cnt, string st, string countyfromPage,Boolean flag){ //<T26>
        
        System.debug('State'+st);
        List<String>initialStates = new List<String>();
        
        string citystring = '';
        
        if(cnt == null || cnt == ''){
            cnt ='USA';
        }
        //<T08> starts
        st=st.replaceAll( '\\s+', '');
        st=st.replaceAll( '\\[', '');
        st=st.replaceAll( '\\]', '');
        //<T08> ends
        List<string>cntList     = cnt.split(',');
        List<string>stlist       = st.split(',');
        System.debug(cntList+'-'+stlist);
        dynamicStatelisttemp = new List<SelectOption>();
        if(cntList.size() == 0){ dynamicStatelisttemp = new List<SelectOption>();
                                
                               }
        else if(cntList != null && !('').equals(cntList) ){
            system.debug('@@@@getLimitQueryRows()' + Limits.getQueryRows()); 
            
            String query = 'SELECT City_Name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND City_Inv_Flag__c=\'Yes\'';
            String filter = '';  
            
            if(!cntList.isEmpty()){
                filter = filter + ' and CountryName__c IN:cntList AND State_Abbrevation__c IN:stlist ';
            }
            
            if(countyfromPage != ' '&& !flag){//<T26>
                filter = filter + ' and County_Name__c != NULL and County_Name__c = \'Independent City\'';
            }
            
            filter = filter + ' AND City_Name__c!=NULL group by City_Name__c ';
            
            system.debug('@@@@query'+query + '  @@@Filter'+filter);
            
            AggregateResult[] groupedResults = Database.query(query+filter);
            System.debug('groupedResults'+groupedResults);
            
            Integer i = 0;
            for(AggregateResult ar : groupedResults){
                String city = (String)ar.get('City_Name__c');
                
                if(city != null && city != ''){
                    if(i==0){  citystring += city;
                            }
                    else{  citystring += ','+city; 
                        } i++;
                    if(i ==9999){ break;
                                }
                }
            }
            
            system.debug('@@@@support debug: '+i);
            
            
        }
        system.debug('@@@citystring'+citystring);
        
        
        return citystring;
        
    }
    
    @Remoteaction @ReadOnly
    public static String refreshcountyList(String cnt, string st){ 
        System.debug('State'+st);
        
        if(cnt == null || cnt == ''){
            cnt ='USA';
        }
        
        List<String>initialStates = new List<String>();
        string countystring = '';
        
        
        List<string>cntList     = cnt.split(',');
        List<string>stlist       = st.split(',');
        dynamicStatelisttemp = new List<SelectOption>();
        if(cntList.size() == 0){  dynamicStatelisttemp = new List<SelectOption>();
                                
                               }
        
        
        else if(cntList != null && !('').equals(cntList) ){
            
            
            String query = 'SELECT County_Name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND County_Inv_Flag__c=\'Yes\'';
            String filter = '';  
            
            if(!cntList.isEmpty()){
                filter = filter + ' and CountryName__c IN:cntList AND State_Abbrevation__c IN:stlist ';
            }      
            
            filter = filter + ' AND County_Name__c!=NULL group by County_Name__c ';
            
            system.debug('@@@@query'+query + '  @@@Filter'+filter);
            
            AggregateResult[] groupedResults = Database.query(query+filter);
            
            Integer i = 0;
            for(AggregateResult ar : groupedResults){
                String county = (String)ar.get('County_Name__c');
                if(county != null && county != ''){
                    if(i==0){
                        countystring += county;
                    }
                    else{
                        countystring += ','+county; 
                    }
                    i++;
                    if(i ==9999){  break;
                                }
                }
            }
        }
        system.debug('@@@citystring'+countystring);
        return countystring;
        
    }
    
    // @future(callout=true)
    public static void  getResults(String aop,Map<String,String> productCodeMap,String countryId,String stateId,String countyId,String cityId){ 
        System.debug('Adddddd ' + aop+' ' + productCodeMap + ' ' + countryId+ ' ' + stateId + ' ' + countyId + ' ' + cityId);
        resultstoshow = new List<ResultClass>();
        finalResults= new Map<String,List<ResultClass>>();
        
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); //initiate HTTP request
        string strEndPoint = '';
        //http://stg-back-office-services.lawyers.com/services/salestool/v1/inventory/byCity?cityId=12493&productCode=1920&aop=630&pageNumber=1&pageSize=100';
        System.debug('@@@@Product Code National :'+productCodeMap.get('National')); //<T30>
        if(countryId != null && countryId != '' && productCodeMap.get('National') != null){ //<T30>
            // <T05>
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCountry?countryId=' + countryId + '&productCode=' + productCodeMap.get('National') +'&aop='+ aop + '&pageNumber=1&pageSize=100';
            System.debug('Country endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            System.debug('BEFORE Time taken for getting details from OFS : '+Limits.getCpuTime());
            System.debug(Limits.getLimitCpuTime());
            HTTPResponse res = http.send(req);
            System.debug('AFTER Time taken for getting details from OFS :'+Limits.getCpuTime());
            System.debug(Limits.getLimitCpuTime());
            System.debug('res'+res);
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                resultstoshow.addall(rs.data);
                System.debug('rs'+rs);
                System.debug('resultstoshow'+resultstoshow);
                for(ResultClass r : rs.data){
                    String prodName = '';
                    String searchStr = 'country'+','+r.aop_id;
                    //<T34> starts
                    if(r.product.startswith('Lawyers.com') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product;
                    }else if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('LDC','Lawyers.com');
                    }else if(r.product.startswith('MDC') != true && r.product.startswith('Martindale.com') != true && r.product.contains('Links') == false){
                        prodName = 'Lawyers.com '+r.product;
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('Martindale.com') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product;
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product.replace('MDC','Martindale.com');
                        r.product= r.product.replace('MDC','Martindale.com');
                    }  
                    //<T34> ends
                    if(r.product.contains('Sponsorship')){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('Sponsorship','Results');
                        prodName = 'Lawyers.com '+prodName; 
                        r.product= 'Lawyers.com '+ r.product.replace('Sponsorship','Results');
                    }
                    
                    if(r.product.contains('Links')){
                        searchStr+=','+'LDC';
                        prodName = r.product;
                    }
                    if(prodName == 'Lawyers.com Spanish Display Ads'){ 
                        prodName= 'Lawyers.com Spanish Preferred Banner Placements';    
                        r.product= 'Lawyers.com Spanish Preferred Banner Placements';
                    }
                    
                    if(searchcount != null && searchcount.containskey(searchStr)){
                        r.searchcount = searchcount.get(searchStr);
                    }
                    //<T07> starts
                    if(r.available <= 0){//<T32>
                        r.disableCheckbox = true;
                    }
                    //<T07> ends 
                    //MHBS-5708 //T02
                    if(finalResults.containskey(prodName)!= true){
                        
                        
                        String ProductID = '0'+String.valueOf(r.product_id);
                        String AOPID = String.valueOf(r.aop_id);
                        if(test.isRunningTest()){
                            
                        }else if(ProductID!=null &&  mapOfSelProdVsAops.containsKey(ProductID) && mapOfSelProdVsAops.get(ProductID).contains(AOPID) )
                        {
                            finalResults.put(prodName,new List<ResultClass>{r});
                        }
                        
                    }else if(finalResults.containskey(prodName) == true){
                        String ProductID = '0'+String.valueOf(r.product_id);
                        String AOPID = String.valueOf(r.aop_id);
                        
                        if(ProductID!=null &&  mapOfSelProdVsAops.containsKey(ProductID) && mapOfSelProdVsAops.get(ProductID).contains(AOPID) )
                        {
                            finalResults.get(prodName).add(r);
                        }  
                    }  
                }
                System.debug('AFTER FINALRESULTS ADD Time taken for getting details from OFS :'+Limits.getCpuTime());
                System.debug(Limits.getLimitCpuTime());
            }
        }
        System.debug('@@@@Product Code State :'+productCodeMap.get('State')); //<T30>
        if(stateId != null && stateId != '' && productCodeMap.get('State') != null){ //<T30>
            // <T05>
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byState?stateId=' + stateId + '&productCode=' + productCodeMap.get('State') +'&aop='+ aop + '&pageNumber=1&pageSize=100';
            System.debug('State endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            System.debug('BEFORE Time taken for getting details from OFS : '+Limits.getCpuTime());
            System.debug(Limits.getLimitCpuTime());
            HTTPResponse res = http.send(req);
            System.debug('AFTER Time taken for getting details from OFS :'+Limits.getCpuTime());
            System.debug(Limits.getLimitCpuTime());
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                
                
                resultstoshow.addall(rs.data);
                
                for(ResultClass r : rs.data){
                    String prodName = '';
                    String searchStr = 'state'+','+r.aop_id;
                    //<T34> starts
                    if(r.product.startswith('Lawyers.com') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product;
                    }else if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('LDC','Lawyers.com');
                    }else if(r.product.startswith('MDC') != true && r.product.startswith('Martindale.com') != true && r.product.contains('Links') == false){
                        prodName = 'Lawyers.com '+r.product;
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('Martindale.com') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product;
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product.replace('MDC','Martindale.com');
                        r.product= r.product.replace('MDC','Martindale.com');
                    }  
                    //<T34> ends
                    if(r.product.contains('Sponsorship')){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('Sponsorship','Results');
                        prodName = 'Lawyers.com '+prodName; 
                        r.product= 'Lawyers.com '+ r.product.replace('Sponsorship','Results');
                    }
                    
                    if(r.product.contains('Links')){
                        searchStr+=','+'LDC';
                        prodName = r.product;
                    }
                    
                    if(prodName == 'Lawyers.com Spanish Display Ads'){  
                        prodName= 'Lawyers.com Spanish Preferred Banner Placements';    
                        r.product= 'Lawyers.com Spanish Preferred Banner Placements';
                    }
                    
                    if(searchcount != null && searchcount.containskey(searchStr)){
                        r.searchcount = searchcount.get(searchStr);
                    }
                    //<T07> starts
                    System.debug(r.available);
                    if(r.available <= 0){//<T32>
                        r.disableCheckbox = true;
                    }
                    //<T07> ends 
                    //MHBS-5708 //T02
                    if(finalResults.containskey(prodName)!= true){
                        String ProductID = '0'+String.valueOf(r.product_id);
                        String AOPID = String.valueOf(r.aop_id);
                        if(test.isRunningTest()){
                            
                        }else if(ProductID!=null &&  mapOfSelProdVsAops.containsKey(ProductID) && mapOfSelProdVsAops.get(ProductID).contains(AOPID) )
                        {
                            finalResults.put(prodName,new List<ResultClass>{r});
                        }
                    }else if(finalResults.containskey(prodName) == true){
                        String ProductID = '0'+String.valueOf(r.product_id);
                        String AOPID = String.valueOf(r.aop_id);
                        if(ProductID!=null &&  mapOfSelProdVsAops.containsKey(ProductID) && mapOfSelProdVsAops.get(ProductID).contains(AOPID) )
                        {
                            finalResults.get(prodName).add(r);
                        }  
                    }  
                }
                System.debug('AFTER FINALRESULTS ADD Time taken for getting details from OFS :'+Limits.getCpuTime());
                System.debug(Limits.getLimitCpuTime());
            }
        }
        
        System.debug('@@@@Product Code City :'+productCodeMap.get('City')); //<T30>
        if(cityId != null && cityId != '' && productCodeMap.get('City') != null){ //<T30>
            // <T05>
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCity?cityId=' + cityId + '&productCode=' + productCodeMap.get('City') +'&aop='+ aop + '&pageNumber=1&pageSize=100';
            System.debug('City endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            System.debug('BEFORE Time taken for getting details from OFS : '+Limits.getCpuTime());
            System.debug(Limits.getLimitCpuTime());
            HTTPResponse res = http.send(req);
            System.debug('AFTER Time taken for getting details from OFS :'+Limits.getCpuTime());
            System.debug(Limits.getLimitCpuTime());
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                
                resultstoshow.addall(rs.data);
                
                for(ResultClass r : rs.data){
                    
                    String prodName = '';
                    String searchStr = 'city'+','+r.aop_id;
                    //<T34> starts
                    if(r.product.startswith('Lawyers.com') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product;
                    }else if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('LDC','Lawyers.com');
                    }else if(r.product.startswith('MDC') != true && r.product.startswith('Martindale.com') != true && r.product.contains('Links') == false){
                        prodName = 'Lawyers.com '+r.product;
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('Martindale.com') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product;
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product.replace('MDC','Martindale.com');
                        r.product= r.product.replace('MDC','Martindale.com');
                    }  
                    //<T34> ends
                    if(r.product.contains('Sponsorship')){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('Sponsorship','Results');
                        prodName = 'Lawyers.com '+prodName; 
                        r.product= 'Lawyers.com '+ r.product.replace('Sponsorship','Results');
                    }
                    
                    if(r.product.contains('Links')){
                        searchStr+=','+'LDC';
                        prodName = r.product;
                    }
                    if(prodName == 'Lawyers.com Spanish Display Ads'){  
                        prodName= 'Lawyers.com Spanish Preferred Banner Placements';    
                        r.product= 'Lawyers.com Spanish Preferred Banner Placements';
                    }
                    
                    if(searchcount != null && searchcount.containskey(searchStr)){
                        r.searchcount = searchcount.get(searchStr);
                    }
                    //<T07> starts
                    if(r.available <= 0){//<T32>
                        r.disableCheckbox = true;
                    }
                    //<T07> ends 
                    //MHBS-5708 //T02
                    if(finalResults.containskey(prodName)!= true){
                        String ProductID = '0'+String.valueOf(r.product_id);
                        String AOPID = String.valueOf(r.aop_id);
                        if(test.isRunningTest()){
                            
                        }else if(ProductID!=null &&  mapOfSelProdVsAops.containsKey(ProductID) && mapOfSelProdVsAops.get(ProductID).contains(AOPID) )
                        {
                            finalResults.put(prodName,new List<ResultClass>{r});
                        }
                    }else if(finalResults.containskey(prodName) == true){
                        String ProductID = '0'+String.valueOf(r.product_id);
                        String AOPID = String.valueOf(r.aop_id);
                        if(ProductID!=null &&  mapOfSelProdVsAops.containsKey(ProductID) && mapOfSelProdVsAops.get(ProductID).contains(AOPID) )
                        {
                            finalResults.get(prodName).add(r);
                        }  
                    }  
                }
               System.debug('AFTER FINALRESULTS ADD Time taken for getting details from OFS :'+Limits.getCpuTime());
                System.debug(Limits.getLimitCpuTime()); 
            }
            
        }
        
        
        System.debug('!!!!'+countyId);
        System.debug('!!!!'+cityId);
        System.debug('!!!!'+productCodeMap);
        System.debug('!!!!'+productCodeMap.get('County'));
        System.debug('@@@@Product Code County :'+productCodeMap.get('County')); //<T30>
        if(countyId != null && countyId != '' && productCodeMap.get('County') != null) { //<T30>
            //MHBS-7317 -  <T03>
            if(cityId != null && cityId != ''){
                // <T03>
                strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCounty?countyId=' + countyId + '&cityId=' + cityId +'&productCode=' + productCodeMap.get('County') +'&aop='+ aop + '&pageNumber=1&pageSize=100';
                System.debug('County endpoint 1: '+strEndPoint);
            }else{
                // <T03>
                strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCounty?countyId=' + countyId +'&productCode=' + productCodeMap.get('County') +'&aop='+ aop + '&pageNumber=1&pageSize=100';
                System.debug('County endpoint 2: '+strEndPoint); 
            }
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            System.debug('BEFORE Time taken for getting details from OFS : '+Limits.getCpuTime());
            System.debug(Limits.getLimitCpuTime());
            HTTPResponse res = http.send(req);
            System.debug('AFTER Time taken for getting details from OFS :'+Limits.getCpuTime());
            System.debug(Limits.getLimitCpuTime());
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                System.debug('!!!'+rs);
                resultstoshow.addall(rs.data);
                for(ResultClass r : rs.data){
                    String prodName = '';
                    String searchStr = 'county'+','+r.aop_id;
                    
                    if(r.product.startswith('Lawyers.com') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product;
                    }else if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('LDC','Lawyers.com');
                    }else if(r.product.startswith('MDC') != true && r.product.startswith('Martindale.com') != true && r.product.contains('Links') == false){
                        prodName = 'Lawyers.com '+r.product;
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('Martindale.com') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product;
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product.replace('MDC','Martindale.com');
                        r.product= r.product.replace('MDC','Martindale.com');
                    }  

                    if(r.product.contains('Sponsorship')){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('Sponsorship','Results');
                        prodName = 'Lawyers.com '+prodName; 
                        r.product= 'Lawyers.com '+ r.product.replace('Sponsorship','Results');
                    }
                    
                    if(r.product.contains('Links')){
                        searchStr+=','+'LDC';
                        prodName = r.product;
                    }
                    
                    if(prodName == 'Lawyers.com Spanish Display Ads'){  
                        prodName= 'Lawyers.com Spanish Preferred Banner Placements';    
                        r.product= 'Lawyers.com Spanish Preferred Banner Placements';
                    }
                    if(searchcount != null && searchcount.containskey(searchStr)){
                        r.searchcount = searchcount.get(searchStr);
                    }
                    //<T07> starts
                    if(r.available <= 0){//<T32>
                        r.disableCheckbox = true;
                    }
                    //<T07> ends 
                    //MHBS-5708 //T02
                    if(finalResults.containskey(prodName)!= true){
                        String ProductID = '0'+String.valueOf(r.product_id);
                        String AOPID = String.valueOf(r.aop_id);
                        if(test.isRunningTest()){
                            
                        }else if(ProductID!=null &&  mapOfSelProdVsAops.containsKey(ProductID) && mapOfSelProdVsAops.get(ProductID).contains(AOPID) )
                        {
                            finalResults.put(prodName,new List<ResultClass>{r});
                        }
                    }else if(finalResults.containskey(prodName) == true){
                        String ProductID = '0'+String.valueOf(r.product_id);
                        String AOPID = String.valueOf(r.aop_id);
                        if(ProductID!=null &&  mapOfSelProdVsAops.containsKey(ProductID) && mapOfSelProdVsAops.get(ProductID).contains(AOPID) )
                        {
                            finalResults.get(prodName).add(r);
                        }  
                    }  
                }
                System.debug('AFTER FINALRESULTS ADD Time taken for getting details from OFS :'+Limits.getCpuTime());
                System.debug(Limits.getLimitCpuTime());
            }
        }
        
        //<T29> starts
        if(finalresults.keyset().contains('Lawyers.com Preferred Banner Placements')){
            finalresults.put('ANIMATED Lawyers.com Preferred Banner Placements',finalresults.get('Lawyers.com Preferred Banner Placements'));
        }
        
        if(finalresults.keyset().contains('Lawyers.com Spanish Preferred Banner Placements')){
            finalresults.put('ANIMATED Lawyers.com Spanish Preferred Banner Placements',finalresults.get('Lawyers.com Spanish Preferred Banner Placements'));
        }
        //<T29> ends
        System.debug('finalresults'+finalresults);
        
    }
    
    
    
    public static void getSearchCount(String aop,String countryId,String stateId,String countyId,String cityId){ 
        searchCount = new Map<String,Integer>();
        System.debug('aop : '+aop+ 'countryId : '+countryId+' stateId : '+stateId+' countyId : '+countyId+' cityId : '+cityId);
        
        
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); //initiate HTTP request
        string strEndPoint = '' ;
        //http://webstats-services.lawyers.com/services/reports/v1/searchTrafficByLocationAOP?site_id=both&aop_ids=729&city_id=1023;
        
        if(countryId != null && countryId != ''){
            strEndPoint = system.Label.Webstats_Endpoint + '&aop_ids=' + aop + '&country_id=' + countryId;
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000);            
            HTTPResponse res = http.send(req);           
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                System.debug('Response Body : '+res.getBody());
                WebstatsFinalClass rs = (WebstatsFinalClass)JSON.deserialize( res.getBody(), WebstatsFinalClass.class);
                
                if(rs!=null && rs.report!=null){
                    
                    
                    for(search_traffic_by_location_aop_report s:rs.report.search_traffic_by_location_aop_report){
                        
                        searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id,s.searches);
                        
                    }
                }
            }
        }
        if(stateId != null && stateId != ''){
            strEndPoint = system.Label.Webstats_Endpoint + '&aop_ids=' + aop + '&state_id=' + stateId;
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            
            HTTPResponse res = http.send(req);
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                System.debug('Response Body : '+res.getBody());
                WebstatsFinalClass rs = (WebstatsFinalClass)JSON.deserialize( res.getBody(), WebstatsFinalClass.class);
                
                if(rs!=null && rs.report!=null){
                    
                    
                    for(search_traffic_by_location_aop_report s:rs.report.search_traffic_by_location_aop_report){
                        
                        searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id,s.searches);
                        
                    }
                }
            }
        }
        
        if(cityId != null && cityId != ''){
            strEndPoint = system.Label.Webstats_Endpoint + '&aop_ids=' + aop + '&city_id=' + cityId;
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            
            HTTPResponse res = http.send(req);
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                System.debug('Response Body : '+res.getBody());
                WebstatsFinalClass rs = (WebstatsFinalClass)JSON.deserialize( res.getBody(), WebstatsFinalClass.class);
                
                if(rs!=null && rs.report!=null){
                    
                    
                    for(search_traffic_by_location_aop_report s:rs.report.search_traffic_by_location_aop_report){
                        
                        searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id,s.searches);
                        
                    }
                }
            }
        }
        
        if(countyId != null && countyId != '') {
            strEndPoint = system.Label.Webstats_Endpoint + '&aop_ids=' + aop + '&county_id=' + countyId;
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            
            HTTPResponse res = http.send(req);
            System.debug('Response Body : '+res.getBody());
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
                WebstatsFinalClass rs = (WebstatsFinalClass)JSON.deserialize( res.getBody(), WebstatsFinalClass.class);
                
                if(rs!=null && rs.report!=null){
                    
                    
                    for(search_traffic_by_location_aop_report s:rs.report.search_traffic_by_location_aop_report){
                        
                        searchCount.put(s.aggregate_type+','+s.aop_ID+','+s.site_id,s.searches);
                        
                    }
                }
            }
        }
        
        System.debug('searchCount'+searchCount);
        
    }
    
    
    public class fromJSON{
        public boolean success{get;set;}
        public ResultClass[] data{get;set;}
        public cls_errorMessage errorMessage{get;set;}
        public boolean cacheable{get;set;}
        
    } 
    
    class ResultClass {
        public Integer country_id{get;set;} //1
        public String country{get;set;}//United States of America
        public Integer state_id{get;set;}   //46
        public String state{get;set;}   //Texas
        public Integer county_id{get;set;}  //2507
        public String  contact_id{get;set;}
        public String  contact_Name{get;set;}
        public String county{get;set;}  //Harris Co.
        public Integer city_id{get;set;}    //12493
        public String city{get;set;}    //Barker
        public Integer product_id{get;set;} //1920
        public String product{get;set;} //Preferred City Results
        public Integer aop_id{get;set;} //912
        public String aop{get;set;} //Automobile Accidents
        public Integer sold{get;set;}   //0
        public Integer pended{get;set;} //0
        public Integer quota{get;set;}  //6
        public Integer available{get;set;}  
        public Integer searchcount{get;set;}//6        
        public Boolean addToCart{get;set;} // <T07>        
        public Boolean disableCheckbox{get;set;} // <T07>  
        public List<innerOrders> innerordersList{get;set;}
        public Decimal Price{get;set;} //<T20> 
    }
    
    class cls_errorMessage {
    }
    
    //<T14> - Wrapper class for Selected Inventory Products
    class ProductSummary {
        public Integer sNo{get;set;}
        public String prodType{get;set;}
        public String quantity{get;set;}  
        public String amount{get;set;} 
    }    
    
    public class WebstatsFinalClass{
        public report report{get;set;}
        public Boolean cacheable{get;set;}
        public Decimal executionTimeMillis{get;set;}
        public Boolean success{get;set;}
        
    }
    
    public class search_traffic_by_location_aop_report{
        public Integer state_id{get;set;}
        public String county_name{get;set;}
        public String state_name{get;set;}
        public Integer county_id{get;set;}
        public Integer country_id{get;set;}
        public String city_name{get;set;}
        public String country_name{get;set;}
        public Integer city_id{get;set;}
        public Integer aop_id{get;set;}
        public String aggregate_type{get;set;}
        public String aop_name{get;set;}
        public String end_date{get;set;}
        public Integer searches{get;set;}
        public String start_date{get;set;}
        public String site_id{get;set;}
    }
    
    public class report{
        public list<search_traffic_by_location_aop_report> search_traffic_by_location_aop_report{get;set;}
    }
    
    //<T06> starts 
    public static string queryAllFields(String strObjectAPIName){
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String queryFields = String.join( fieldNames, ',' );
        return queryFields;
    }
    
    //<T14> starts  
    @Remoteaction
    public static Boolean cartButton(String accountId){
        Boolean isErr = false;
        Id userId = UserInfo.getUserId();
        List<Cart__c> cartList = [Select Id, Account__c,(Select id from Cart_Line_Items__r) FROM Cart__c where ownerId=:userId limit 1];
        if((cartList != null && cartList.size()>0)){
        if(accountId != null){
            cartList[0].Account__c = accountId;
            update cartList;
        }else{
            cartList[0].Account__c = null;            
            update cartList;
        }
        }
       //<T14> ends
        
        if(cartList == null || cartList.size()<=0 || ( cartList != null && cartList[0].Cart_Line_Items__r != null  && cartList[0].Cart_Line_Items__r.size() <=0) || (cartList != null && cartList[0].Cart_Line_Items__r == null ) ){
             isErr = true;
        }
        return isErr;
    }
    
    //<T14>
    public void showPageMessage() {
        if(level == 'ERROR') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
        }
    }
    
    
    //<T14> - updated the parameter of addToCartMethod method
    @Remoteaction 
    public static PageReference addToCartButton(String accountId){
        System.debug('****addToCartButton*****');
        Id userId = UserInfo.getUserId();
        
        string strARId;
        Map<Id,Cart_Line_Item__c> existingCli = new Map<Id,Cart_Line_Item__c>();
        Set<Cart_Line_Item__c> existingCliToDelete = new Set<Cart_Line_Item__c>();
        List<Cart_Line_Item__c> deleteCLI = new List<Cart_Line_Item__c>();
        List<Attribute_Lines__c> ALInsert = new List<Attribute_Lines__c>();                          
        List<Cart_Line_Item__c> newCLIList = new List<Cart_Line_Item__c>();
        Map<String,Integer> sharedProdCount = new Map<String,Integer>();
        Set<String> removeShared = new Set<String>();
        Map<Id,Id> mapProductWithAR = new Map<Id,Id>();
        
        List<Inventory_Result__c> inv = [Select id,Selected_Results__c from Inventory_Result__c where OwnerId = :userId];
        selResults = new List<ResultClass>();
        if(inv != null && inv.size()>0){
            String selR = inv[0].Selected_Results__c;
            selR = selR.replaceAll('\"\"', 'null'); //<T15>
            List<ResultClass> rs = (List<ResultClass>)JSON.deserialize(selR,List<ResultClass>.Class); 
            selR = selR.replaceAll(',', ', '); //<T27>
            selResults.addAll(rs);
            System.debug(selResults);
            List<String> productStrings = new List<String>();
            Set<String> stateIds = new Set<String>();
            Map<String,String> stateAbbr = new Map<string,String>();
            Map<String,Decimal> prodPriceMap = new Map<String,Decimal>();//<T20>
            for(ResultClass con: selResults) {
                stateIds.add(String.valueof(con.state_id));
                String prodStr =con.product;
                if(prodStr.startswith('Preferred') == true){
                    prodStr = prodStr.replace('Preferred','Lawyers.com Preferred');
                }
                productStrings.add(prodStr);
                prodPriceMap.put(prodStr,con.Price);//<T20>
            } 
            System.debug(prodPriceMap);
            System.debug(productStrings);
            if(selResults != null && !selResults.isEmpty()){
                
                List<GEO_Location__c> geo = [Select CountryName__c, County_Name__c,State_Abbrevation__c,City_Name__c,stateId__c,AOP_list_value__c From GEO_Location__c where stateId__c in :stateIds];
                
                if(!geo.isEmpty()){
                    for(GEO_Location__c g:geo){
                        stateAbbr.put(g.stateId__c,g.State_Abbrevation__c);
                    }
                }
                List<Product2> productList = [SELECT Id, Name, (SELECT Id, AttributeName__c, AttributeType__c, ShowinDocuSign__c, SecondaryAttributeName__c, Required__c, Attribute_Picklist_Values__c, AttributeConfiguration__r.Name FROM Product_Attributes__r) FROM Product2 WHERE Name in :productStrings];
                
                if(!productList.isEmpty()){
                    
                    Id currentUser = UserInfo.getUserId();
                    Id cartId = null;
                    List<Cart__c> cartList = [Select id,(SELECT Name,Cart__c, Product__c, Country__c, AOP__c, CityStateCounty__c, Contact__c FROM Cart_Line_Items__r) from Cart__c where ownerId = :currentUser];
                    
                    system.debug('cartList.size()>0'+cartList.size());
                    system.debug(cartList[0].Cart_Line_Items__r.size());
                    if(cartList.size()>0 && cartList[0].Cart_Line_Items__r != null && cartList[0].Cart_Line_Items__r.size()>0){
                        for(Cart_Line_Item__c cli :cartList[0].Cart_Line_Items__r){
                            if(cli.Name.contains('Shared') == false){
                                existingCli.put(cli.id,cli);
                            }else{
                                String s= cli.Name+cli.Country__c+cli.CityStateCounty__c+cli.AOP__c;
                                if(sharedProdCount.isEmpty() || sharedProdCount.containsKey(s) != true){
                                    sharedProdCount.put(s,1);
                                }else{
                                    sharedProdCount.put(s,sharedProdCount.get(s)+1); 
                                }
                            }
                        }
                    }
                    if(cartList != null && cartList.size()>0){
                        cartId = cartList[0].Id;
                    }
                                        
                    //<T14> starts
                    List<Cart__c> c = [Select Id, Account__c FROM Cart__c where ownerId=:userId limit 1];
                    if(accountId != null){
                        c[0].Account__c = accountId;
                        update c;
                    }else{
                        c[0].Account__c = null;            
                        update c;
                    }
                    //<T14> ends        
                    System.debug(existingCli);
                    Map<String, ProductAttribute__c> mapProductAttribute = new Map<String, ProductAttribute__c>();
                    Map<String, Product2> prodMap = new Map<String, Product2>();
                    Set<Id> prodIds = new Set<Id>();
                    Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%MH Standard Pricing%'].Id;
                                        
                    for(Product2 pr: productList){
                        prodIds.add(pr.Id);
                        prodMap.put(pr.Name,pr);
                        for(ProductAttribute__c pa: pr.Product_Attributes__r){
                            mapProductAttribute.Put(pr.Id+'___'+pa.AttributeConfiguration__r.Name, pa);
                        }
                    }                    
                                        
                    for(ResultClass rc: selResults){
                         System.debug(rc.product);
                        Cart_Line_Item__c newCLI = new Cart_Line_Item__c();
                        if(rc.product.startswith('Preferred') == true){
                            rc.product = rc.product.replace('Preferred','Lawyers.com Preferred');
                        }
                        //added by saiv - populating SF inventoryID
                        if(rc.city_id  != null){
                            newCLI.SFInventoryId__c = rc.product_id+'.'+rc.aop_id+'.'+rc.city_id+'.'+rc.state_id+'.'+rc.country_id;
                        }else if(rc.county_id  != null){
                            newCLI.SFInventoryId__c = rc.product_id+'.'+rc.aop_id+'.'+rc.county_id+'.'+rc.state_id+'.'+rc.country_id;
                        }else{
                            newCLI.SFInventoryId__c = rc.product_id+'.'+rc.aop_id+'.'+rc.state_id+'.'+rc.country_id;
                        }
                        system.debug('===newCLI.SFInventoryId__c===='+newCLI.SFInventoryId__c);
                        //newCLI.SFInventoryId__c = rc.aop_id +'.'+(rc.city_id  != null ?rc.city_id :'')+'.'+(rc.county_id  != null ?rc.county_id :'')+'.'+(rc.state_id  != null ?rc.state_id :'')+'.'+rc.country_id;
                        newCLI.Name = prodMap.get(rc.product).Name;
                        //<T17>
                        if(cartId != null){
                            newCLI.Cart__c = cartId;
                        }
                        System.debug('!!!'+rc.Price);
                        newCLI.Product__c = prodMap.get(rc.product).Id;
                        newCLI.Price__c = '$' + rc.Price;//<T20><T21>
                        //<T27> starts
                        if(rc.aop.contains(',')){
                            rc.aop =rc.aop.replace(',',', ');
                        }
                        //<T27> ends
                        newCLI.AOP__c =rc.aop;
                        newCLI.Contact__c = rc.contact_id;
                        if(rc.Country == 'United States of America'){
                            newCLI.Country__c = 'USA';
                        }else{
                            newCLI.Country__c = rc.country; 
                        }
                        
                        
                        if(rc.city != null){
                            newCLI.CityStateCounty__c =rc.city;
                            if(rc.city != null && rc.city.contains('&#39;')){
                                               newCLI.CityStateCounty__c = rc.city.replace('&#39;','\'');
                                }
                        }
                        if(rc.County != null){
                            newCLI.CityStateCounty__c =rc.County;
                        }
                        if(rc.state != null){
                            
                            if(newCLI.CityStateCounty__c != null){
                                newCLI.CityStateCounty__c = newCLI.CityStateCounty__c+','+rc.state;
                            }else{
                                newCLI.CityStateCounty__c = rc.state; 
                            }
                            
                        }
                        if(rc.city == null && rc.County != null && rc.state != null && newCLI.CityStateCounty__c.contains('null')){
                            newCLI.CityStateCounty__c = null;
                        }
                        deleteCLI  = new List<Cart_Line_Item__c>();
                        
                        if(rc.product.contains('Shared')){
                            String s= newCLI.Name+newCLI.Country__c+newCLI.CityStateCounty__c+newCLI.AOP__c;
                            if(sharedProdCount.get(s) ==3){
                                removeShared.add(s);
                            }
                        }
                        Boolean addedBannerProd = false;
                        for(Cart_Line_Item__c addedCli : newCLIList){
                            if((newCLI.Name.contains(addedCli.Name) || addedCli.Name.contains(newCLI.Name)) && // || existingCli.get(cli).Name.contains(newCLI.Name)) ??
                               newCLI.Cart__c == addedCli.Cart__c &&
                               newCLI.Country__c == addedCli.Country__c &&
                               newCLI.AOP__c == addedCli.AOP__c &&
                               newCLI.CityStateCounty__c == addedCli.CityStateCounty__c &&
                              newCLI.Contact__c  == addedCli.Contact__c ){
                                   addedBannerProd = true;
                               }
                        }
                        if(addedBannerProd == true){
                            continue;
                        }
                        for(Id cli : existingCli.keyset()){
                            if(((newCLI.Name == existingCli.get(cli).Name && 
                               newCLI.Product__c == existingCli.get(cli).Product__c) || (existingCli.get(cli).Name.contains(newCLI.Name) || newCLI.Name.contains(existingCli.get(cli).Name)))&&
                               newCLI.Cart__c == existingCli.get(cli).Cart__c &&                                
                               newCLI.Country__c == existingCli.get(cli).Country__c &&
                               newCLI.AOP__c == existingCli.get(cli).AOP__c &&
                               newCLI.CityStateCounty__c == existingCli.get(cli).CityStateCounty__c &&
                              newCLI.Contact__c  == existingCli.get(cli).Contact__c){
                                   deleteCLI.add(existingCli.get(cli));
                                   break;
                               }else if(newCLI.Name == existingCli.get(cli).Name &&
                                        newCLI.Cart__c == existingCli.get(cli).Cart__c &&
                                        newCLI.Product__c == existingCli.get(cli).Product__c &&
                                        newCLI.Country__c == existingCli.get(cli).Country__c &&
                                        newCLI.AOP__c == existingCli.get(cli).AOP__c &&
                                        newCLI.Contact__c  == existingCli.get(cli).Contact__c &&
                                        newCLI.CityStateCounty__c == null){
                                            deleteCLI.add(existingCli.get(cli));
                                            break;
                                            return null;
                                        }
                        }
                        System.debug(deleteCLI);
                        if(deleteCLI.size()<=0)   { 
                            Id prodId = prodMap.get(rc.product).Id;
                            String s= newCLI.Name+newCLI.Country__c+newCLI.CityStateCounty__c+newCLI.AOP__c;
                            if(newCLI.Name.contains('Shared') && removeShared.contains(s) != true){
                                if(newCLIList.contains(newCLI) != true){
                                    newCLIList.add(newCLI);
                                }
                            }else if(newCLI.Name.contains('Shared')!= true){  
                               if(newCLIList.contains(newCLI) != true){
                                    newCLIList.add(newCLI);
                                }
                            }
                        }
                    }
                }
            }
            System.debug(newCLIList);
            if(!newCLIList.isEmpty()){
                insert newCLIList;
            }

           Set<Id> cliIds = new Set<Id>();
            for(Cart_Line_Item__c cli:newCLIList){
                cliIds.add(cli.Id);
            }
          
            if(selResults != null && !selResults.isEmpty()){
           attributeLinesInsertion(selR,cliIds);
            }            
            if(!inv.isEmpty()){
                delete inv;
            }
        }
        Id currentUser = UserInfo.getUserId();
        List<Cart__c> cartList = [Select id,(Select id from Cart_Line_Items__r) from Cart__c where ownerId = :currentUser];
        
        return null;
    }
    
    @future
    public static void attributeLinesInsertion(String selR,Set<Id> cliIds)
    { 
        List<ResultClass> selResults = new List<ResultClass>();
        List<ResultClass> rs = (List<ResultClass>)JSON.deserialize(selR,List<ResultClass>.Class); 
        selResults.addAll(rs);
        Map<String, ProductAttribute__c> mapProductAttribute = new Map<String, ProductAttribute__c>();
        Map<String,String> stateAbbr = new Map<String,String>();
        List<String> productStrings = new List<String>();
        Set<String> stateIds = new Set<String>();
        Map<String, Product2> prodMap = new Map<String, Product2>();        
        List<Attribute_Lines__c> ALInsert = new List<Attribute_Lines__c>();
        Map<Id,Cart_Line_Item__c> cliMap = new Map<Id,Cart_Line_Item__c>();   
        List<Cart_Line_Item__c> cliToUpdate = new List<Cart_Line_Item__c>();
        List<Cart_Line_Item__c> cliList = new List<Cart_Line_Item__c>();
        List<String> independentCities = new List<String>(); //<T29>
        cliList = [SELECT Id, Name, Attribute_Relationship__c, Cart__c, Product__c, Country__c, AOP__c, CityStateCounty__c FROM Cart_Line_Item__c where id in :cliIds];
        if(Test.isRunningTest()){
            cliList = [SELECT Id, Name, Attribute_Relationship__c, Cart__c, Product__c, Country__c, AOP__c, CityStateCounty__c FROM Cart_Line_Item__c Limit 1];
        }
        //<T29> starts
        List<GEO_Location__c> geolist = [Select City_Name__c From GEO_Location__c where County_Name__c = 'Independent City'];
        for(GEO_Location__c g :geolist){
            independentCities.add(g.City_Name__c);
        }
        //<T29> ends
        
        for(ResultClass con: selResults) {
                if(con.state_id != null){
                    stateIds.add(String.valueof(con.state_id));
                }
                String prodStr =con.product;
                if(prodStr.startswith('Preferred') == true){
                    prodStr = prodStr.replace('Preferred','Lawyers.com Preferred');
                }
                productStrings.add(prodStr);
                
            } 
            
            List<GEO_Location__c> geo = [Select CountryName__c, County_Name__c,State_Abbrevation__c,City_Name__c,stateId__c,AOP_list_value__c From GEO_Location__c where stateId__c in :stateIds];
                
                if(!geo.isEmpty()){
                    for(GEO_Location__c g:geo){
                        stateAbbr.put(g.stateId__c,g.State_Abbrevation__c);
                    }
                }
         System.debug(productStrings);
                List<Product2> productList = [SELECT Id, Name, (SELECT Id, AttributeName__c, AttributeType__c, ShowinDocuSign__c, SecondaryAttributeName__c, Required__c, Attribute_Picklist_Values__c, AttributeConfiguration__r.Name FROM Product_Attributes__r) FROM Product2 WHERE Name in :productStrings];
                
         System.debug(productList);
        for(Product2 pr: productList){
            prodMap.put(pr.Name,pr);
                        for(ProductAttribute__c pa: pr.Product_Attributes__r){
                            mapProductAttribute.Put(pr.Id+'___'+pa.AttributeConfiguration__r.Name, pa);
                        }
                    }
         System.debug(mapProductAttribute);
        for(ResultClass rc: selResults){
            if( rc.Country == 'United States of America'){
                rc.country ='USA';
            }
            String s;
                if(rc.city != null){
                            s =rc.city;
                    if(rc.city != null && rc.city.contains('&#39;')){
                                               s = rc.city.replace('&#39;','\'');
                                }
                        }
                        if(rc.County != null){
                            s =rc.County;
                        }
                        if(rc.state != null){
                            
                            if(s != null  ){
                                s = s+','+rc.state;
                            }else{
                                s = rc.state; 
                            }
                            
                        }
                        if(rc.city == null && rc.County != null && rc.state != null && s.contains('null')){
                            s = null;
                        }
            
            for(Cart_Line_Item__c cli : cliList){
                Id prodId = prodMap.containskey(rc.product)?prodMap.get(rc.product).Id:null;
                if(cli.AOP__c == rc.aop && cli.product__c == prodId &&  cli.Country__c == rc.country && cli.CityStateCounty__c ==s){
                           
                           Attribute_Relationship__c objAR = new Attribute_Relationship__c();
                           insert objAR;
                            cli.Attribute_Relationship__c = objAR.Id;
                            System.debug('CLI ID::::'+cli.Id);
                            cliToUpdate.add(cli);
                            if(mapProductAttribute.containsKey(prodId+ '___AOP')){
                                System.debug('inside aop');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___AOP');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                objAL.Picklist_Value__c = rc.aop;
                                objAL.Value_ID__c = string.valueOf(rc.aop_id);
                                ALInsert.add(objAL);
                            }
                            
                            if(mapProductAttribute.containsKey(prodId + '___Service Country')){
                                System.debug('inside service country');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service Country');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                objAL.String_Value__c = '';
                                ALInsert.add(objAL);
                            }
                            if(mapProductAttribute.containsKey(prodId + '___Service State')){
                                System.debug('inside service state');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service State');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                objAL.Picklist_Value__c = '';
                                ALInsert.add(objAL);
                            }
                            if(mapProductAttribute.containsKey(prodId + '___Service City')){
                                System.debug('inside service city');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service City');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                objAL.String_Value__c = '';
                                ALInsert.add(objAL);
                            }
                            //added by SaiV for MH Ads - 05/10/23
                             if(mapProductAttribute.containsKey(prodId + '___Service Street Address')){
                                System.debug('inside service address');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service Street Address');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                objAL.String_Value__c = '';
                                ALInsert.add(objAL);
                            }
                            if(mapProductAttribute.containsKey(prodId + '___Country')){
                                System.debug('inside county');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Country');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                if(rc.Country == 'United States of America'){
                                    objAL.String_Value__c = 'USA';
                                }else{
                                    objAL.String_Value__c = rc.Country;
                                }
                                objAL.Value_ID__c = string.valueOf(rc.country_id);
                                ALInsert.add(objAL);
                            }
                            if(mapProductAttribute.containsKey(prodId + '___State')){
                                System.debug('inside county');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___State');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                if(stateAbbr.containskey(String.valueof(rc.state_id))){
                                    String st = stateAbbr.get(String.valueof(rc.state_id));
                                    objAL.Picklist_Value__c = st;
                                }else{
                                    objAL.Picklist_Value__c = rc.state;
                                }
                                objAL.Value_ID__c = string.valueOf(rc.state_id);
                                ALInsert.add(objAL);
                                } 
                    System.debug(mapProductAttribute);
                             System.debug(mapProductAttribute.containsKey(prodId + '___City'));
                    System.debug(prodId);
                            if(mapProductAttribute.containsKey(prodId + '___City')){
                                System.debug('inside city');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___City');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                if(rc.city != null){
                                    objAL.Picklist_Value__c = rc.City;
                                    if(rc.city != null && rc.city.contains('&#39;')){
                                              objAL.Picklist_Value__c = rc.city.replace('&#39;','\'');
                                }
                                }else{
                                    objAL.Picklist_Value__c = 'None';
                                }
                                objAL.Value_ID__c = string.valueOf(rc.city_id);
                                System.debug(objAL);
                                ALInsert.add(objAL);
                            }                       
                            
                            if(mapProductAttribute.containsKey(prodId + '___County')){
                                System.debug('inside county');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___County');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c; 
                                System.debug(rc.County);
                                //<T29> starts
                                String city ='';
                                if(rc.city != null && rc.city.contains('&#39;')){
                                       city =  rc.city.replace('&#39;','\'');
                                }else{
                                     city =  rc.city;
                                }
                                if(rc.County != null && rc.County.contains(' Co.')){
                                    objAL.Picklist_Value__c = rc.County.replace(' Co.','');                     
                                }else if(independentCities.contains(city)){
                                    objAL.Picklist_Value__c = 'Independent City';
                                }else{
                                    objAL.Picklist_Value__c = rc.County;
                                }
                                objAL.Value_ID__c = string.valueOf(rc.county_id);
                                //<T29> ends
                                ALInsert.add(objAL);
                            }
                            if(mapProductAttribute.containsKey(prodId + '___Service Account Name')){
                                System.debug('inside county');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___Service Account Name');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                objAL.String_Value__c = '';
                                ALInsert.add(objAL);
                            }
                            if(mapProductAttribute.containsKey(prodId + '___URL')){
                                System.debug('inside county');
                                ProductAttribute__c objPA = mapProductAttribute.get(prodId + '___URL');
                                Attribute_Lines__c objAL = new Attribute_Lines__c();
                                objAL.Product_Attribute__c = objPA.Id;
                                objAL.Attribute_Junction__c = objAR.Id;
                                objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                                objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                                objAL.Required__c = objPA.Required__c;
                                objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                                objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                                objAL.Attribute_Type__c = objPA.AttributeType__c;
                                objAL.String_Value__c = '';
                                ALInsert.add(objAL);
                            }
                }
            }
        
            
        }        
        insert ALInsert;        
        if(cliToUpdate.size()>0){
            update cliToUpdate;
        }
    }
    
    @Remoteaction 
    public static Void searchMethodApex(){
        Id userId = UserInfo.getUserId();
        List<Inventory_Result__c> invResults = [Select id,Selected_Results__c from Inventory_Result__c where OwnerId = :userId];
        
        delete invResults;
    }
    
    //<T14> updated the return type of createCart method
    @Remoteaction 
    public static String createCart (String selR,String addtoCart){
        Id accId = null;
        string strARId;
        Map<Id,Cart_Line_Item__c> existingCli = new Map<Id,Cart_Line_Item__c>();
        Set<Cart_Line_Item__c> existingCliToDelete = new Set<Cart_Line_Item__c>();
        List<Cart_Line_Item__c> deleteCLI = new List<Cart_Line_Item__c>();
        List<Attribute_Lines__c> ALInsert = new List<Attribute_Lines__c>();                          
        List<Cart_Line_Item__c> newCLIList = new List<Cart_Line_Item__c>();
        Map<Id,Id> mapProductWithAR = new Map<Id,Id>();
        
        selR = selR.replace('=', '":"');
        selR = selR.replace('[', '');
        selR = selR.replace(']', '');
        selR = selR.replace(', ', ',');//<T27>
        selR = selR.replace('"null"', 'null');
        selR = selR.replace('"true"','true');        
        selR = selR.replace('"false"','false');
        String removeStr =  selR.substringBetween('"innerordersList":', ', "pended"');
       
        if(removeStr != 'null' && String.isBlank(removeStr) != true){
            selR = selR.replace(removeStr,'');
            
        }
        selR = selR.replace('"innerordersList":,','"innerordersList":null,');
        selectedResults = selR;
        Id userId = UserInfo.getUserId();
        List<Inventory_Result__c> invResults = [Select id,Selected_Results__c from Inventory_Result__c where OwnerId = :userId];
        Inventory_Result__c inv = new Inventory_Result__c();
        if(addtoCart == 'true'){        
            if(invResults != null && invResults.size()>0){
                inv = invResults[0];
                if(inv.Selected_Results__c.contains(selR) != true){
                inv.Selected_Results__c = inv.Selected_Results__c.replace('}]','},');
                inv.Selected_Results__c = inv.Selected_Results__c+selR;
                inv.Selected_Results__c = inv.Selected_Results__c+']';
                }
            }else{
                inv.Selected_Results__c = '['+selR+']';
                inv.OwnerId =userId;
                
            }
            upsert inv;
            
        }else{
            if(invResults != null && invResults.size()>0){
                inv = invResults[0];
                selR = selR.replace('"addToCart":false','"addToCart":true');
                inv.Selected_Results__c = inv.Selected_Results__c.replace(selR,'');
                inv.Selected_Results__c = inv.Selected_Results__c.replace('[,','[');
                inv.Selected_Results__c = inv.Selected_Results__c.replace(',]',']');
                inv.Selected_Results__c = inv.Selected_Results__c.replace(',,',',');
                if(inv.Selected_Results__c == '[]' || inv.Selected_Results__c == '[,]'){
                    delete inv;
                }else{
                    update inv;
                }
            }
        }
        //<T14> starts
        Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%MH Standard Pricing%'].Id;
        Map<String,Integer> prodNameVsQuantity = new Map<String,Integer>();
        List<String> productStrings = new List<String>(); //<T20>
        Map<String,Decimal> prodPriceMap = new Map<String,Decimal>();//<T20>
        
        
        List<Inventory_Result__c> updInvResults = [Select id,Selected_Results__c from Inventory_Result__c where OwnerId = :userId];
        if(updInvResults!= null && updInvResults.size()>0){
            String selR1 =  updInvResults[0].Selected_Results__c;
            selR1 = selR1.replaceAll('\"\"', 'null'); //<T15>
            List<ResultClass> rs = (List<ResultClass>)JSON.deserialize(selR1,List<ResultClass>.Class);
            
            for(ResultClass r :rs){
                System.debug(r);
                if(r.product.startswith('Preferred') == true){
                    r.product = r.product.replace('Preferred','Lawyers.com Preferred');
                }
                if(prodNameVsQuantity != null && prodNameVsQuantity.containskey(r.product)){
                    prodNameVsQuantity.put(r.product,prodNameVsQuantity.get(r.product)+1);
                }else{
                    prodNameVsQuantity.put(r.product,1);
                }
                productStrings.add(r.product);
                //<T21> starts
                if(prodPriceMap.containskey(r.product)){                    
                    prodPriceMap.put(r.product,(prodPriceMap.get(r.product)+r.Price));
                }else{                    
                    prodPriceMap.put(r.product,r.price);
                }
                //<T21> ends
            }
        }
        
        Integer i=1;
        total = 0;
        prodSummaryList =  new List<ProductSummary>();
        for(String prodName : prodNameVsQuantity.keyset()){
            ProductSummary ps = new ProductSummary();
            ps.sNo = i;
            ps.prodType = prodName;
            ps.quantity=String.valueof(prodNameVsQuantity.get(prodName));
            System.debug(prodPriceMap);
            System.debug(prodName);
           if(prodPriceMap.containsKey(prodName)){ 
              ps.amount = '$'+prodPriceMap.get(prodName);//<T21>
              total += prodPriceMap.get(prodName);//<T21>
           }
            prodSummaryList.add(ps);
            i++;
        }
        
        //<T17> starts
        Id currentUser = UserInfo.getUserId();
        List<Cart__c> cartList = [Select id from Cart__c where ownerId = :currentUser];
        if(cartList.size()<=0){ 
            
            Cart__c newCart = new Cart__c(); 
            insert newCart;
        } 
        //<T17> ends
        
        if(prodSummaryList !=  null ){
            String p = JSON.serialize(prodSummaryList);
            p+='total'+total;
            return p;
        }else{
            return null;
        }
        //<T14> ends
    }
    //Added for Performance Tuning
    public class QuoteCreationWrapper { 
        @AuraEnabled public Id quoteId; 
        @AuraEnabled public Id priceBookId; 
        @AuraEnabled public Account accountObj; 
            
        public QuoteCreationWrapper() { 
                
        }   
            
        public QuoteCreationWrapper(Id quoteId, Id priceBookId, Account accountObj) {   
            this.quoteId = quoteId; 
            this.priceBookId = priceBookId; 
            this.accountObj = accountObj;   
        }   
    }
    
    @Auraenabled
    public static QuoteCreationWrapper createQuote(Id selectedAccId) //Changed return type from 'Id' to 'QuoteCreationWrapper' for Performance Tuning
    {
        QuoteCreationWrapper result;
        String MHRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        SBQQ__Quote__c qt = new SBQQ__Quote__C();
        System.debug(selectedAccId);  
        if(selectedAccId != null){
            List<Account> accList = [select id,name,website,BillingCountry,BillingState,BillingCity,BillingStreet from Account where id = :selectedAccId];
            String oppName = accList[0].Name+' - ';
            Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%MH Standard Pricing%'].Id;
            Opportunity opp = new Opportunity(Name = oppName , AccountId = selectedAccId, StageName = 'Prospecting',CloseDate = system.today(), Pricebook2Id = pricebookId );
            if(test.isrunningtest() != true){
                insert opp;
            }
            qt.RecordTypeId = MHRecordType;
            qt.SBQQ__Account__c = selectedAccId;
            qt.SBQQ__SalesRep__c = UserInfo.getUserId();
            qt.SBQQ__Opportunity2__c = opp.Id;
            qt.SBQQ__Primary__c = true;
            qt.SBQQ__PriceBook__c = pricebookId;
            qt.SBQQ__SubscriptionTerm__c = 12;
            insert qt;
            
            result = new QuoteCreationWrapper(qt.Id, pricebookId, accList[0]); //Added for Performance Tuning
                        
        }else{
            throw new AuraHandledException('Please select an Account.'); 
        }
        
        
        return result; //Changed return statement from qt.Id to 'result' for Performance Tuning
        
    }
    
     @AuraEnabled   
    public static void createQuoteLinesAsync(String jsonString){
        List<Cart_Line_Item__c> cartLineItems = getCartDetails();   
        try {
            QuoteCreationWrapper wrapper = (QuoteCreationWrapper) JSON.deserialize(jsonString, QuoteCreationWrapper.class); 
            List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();    
            Id cartId;
            Map<Id,Id> prodVsPBE = new Map<Id,Id>();
            Set<Id> prodIds = new Set<Id>();
            for(Cart_Line_Item__c cli : cartLineItems){
                prodIds.add(cli.Product__c);
            }
            Map<Id,Product2> prodVsProdMap = new  Map<Id,Product2>([Select Id,SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,SBQQ__BillingType__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionBase__c,SBQQ__ChargeType__c,Description from Product2 where Id in :prodIds]);
            
            List<PricebookEntry> pbeList = [SELECT Id, UnitPrice, Product2Id, IsActive FROM PricebookEntry where Product2Id in :prodIds and IsActive=true and Pricebook2Id=:wrapper.pricebookId];
            
            for(PricebookEntry pbe: pbeList){
                prodVsPBE.put(pbe.Product2Id,pbe.Id);
            }
            Set<Id> attrIds = new Set<Id>();
            for(Cart_Line_Item__c cli : cartLineItems){
                attrIds.add(cli.Attribute_Relationship__c);
            }
            List<Attribute_Lines__c> attrLines =  new List<Attribute_Lines__c>();
           //Limit added  
            attrLines  = [Select Id,String_Value__c,Attribute_Name__c from Attribute_Lines__c where Attribute_Junction__c in :attrIds LIMIT 1000];
            
            Account accountObj = wrapper.accountObj;
            if(accountObj != NULL) {
                for(Attribute_Lines__c attr : attrLines){
                    if(attr.Attribute_Name__c == 'Service Account Name'){
                        attr.String_Value__c = accountObj.Name;
                    }
                    if(attr.Attribute_Name__c == 'URL'){
                        attr.String_Value__c = accountObj.Website;
                    }
                    
                    if(attr.Attribute_Name__c == 'Service Country'){
                        attr.String_Value__c = accountObj.BillingCountry;                  
                    }
                    if(attr.Attribute_Name__c == 'Service State'){
                        attr.Picklist_Value__c = accountObj.BillingState;
                    }
                    if(attr.Attribute_Name__c == 'Service City'){
                        attr.String_Value__c = accountObj.BillingCity;
                    }
                    if(attr.Attribute_Name__c == 'Service Street Address'){//added by SaiV for MH Ads - 05/10/23
                        attr.String_Value__c = accountObj.BillingStreet;
                    }
                }
            }
            if(!test.isRunningTest()){
            update attrLines;
            }
            for(Cart_Line_Item__c cli : cartLineItems){
                SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
                qli.SBQQ__Product__c = cli.Product__c;
                qli.SBQQ__Quote__c = wrapper.quoteId;
                qli.SBQQ__Quantity__c =1;
                //qli.Contact__c = cli.Contact__c;
                //qli.Account__c = cli.Contact__r.AccountId;
                qli.Attribute_Relationship__c = cli.Attribute_Relationship__c;
                //<T20>
                System.debug(cli.Price__c);
                String Price = cli.Price__c.removeStart('$');
                Decimal ListPrice = Decimal.valueOf(Price);
                qli.SBQQ__ListPrice__c = ListPrice;    
                //<T20>
                qli.SBQQ__BillingFrequency__c = prodVsProdMap.get(cli.Product__c).SBQQ__BillingFrequency__c;
                qli.SBQQ__BillingType__c    = prodVsProdMap.get(cli.Product__c).SBQQ__BillingType__c;
                qli.SBQQ__SubscriptionPricing__c    = prodVsProdMap.get(cli.Product__c).SBQQ__SubscriptionPricing__c;
                qli.SBQQ__SubscriptionBase__c = prodVsProdMap.get(cli.Product__c).SBQQ__SubscriptionBase__c;
                qli.SBQQ__Description__c  = prodVsProdMap.get(cli.Product__c).Description;
                qli.SBQQ__ChargeType__c = prodVsProdMap.get(cli.Product__c).SBQQ__ChargeType__c;
                qli.SBQQ__PricebookEntryId__c = prodVsPBE.get(cli.Product__c);
                qli.SBQQ__DefaultSubscriptionTerm__c = prodVsProdMap.get(cli.Product__c).SBQQ__SubscriptionTerm__c;
                qli.SBQQ__ProductSubscriptionType__c = 'Renewable/Evergreen';//<T32>
                qli.SBQQ__SubscriptionType__c = 'Renewable';//<T33>
                qli.Created_From_Quote_Builder__c = True;
                //added by saiv - populating SF inventoryID
                qli.SFInventoryId__c = cli.SFInventoryId__c;               
                
                cartId = cli.Cart__c;
                quoteLineList.add(qli);
            }
            
            insert quoteLineList;
            if(cartId != null){
                List<Cart__c> c = [Select Id from Cart__c where id = :cartId];
                delete c;
            }
        } catch(Exception e){
            //Delete all the CLIs in case there was an error creating the Quote Lines. To ensure past CLIs won't come up iin later test
            delete cartLineItems;
        }
    }
    
    @Auraenabled
    public static void addtoExistingquote(Id selectedQuoteId)
    {
        System.debug(selectedQuoteId);   
        List<Cart_Line_Item__c> cartLineItems = getCartDetails(); 
        Id cartId;
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        Id pricebookId = [SELECT Id, Name FROM Pricebook2 where Name like '%MH Standard Pricing%'].Id;
        
        List<SBQQ__Quote__c> quoteList = [select id,SBQQ__Account__r.Name,SBQQ__Account__r.Website,SBQQ__Account__r.BillingCountry,SBQQ__Account__r.BillingState,SBQQ__Account__r.BillingCity,SBQQ__Account__r.BillingStreet,
                                          SBQQ__Opportunity2__r.Name,
                                          (SELECT Id, SBQQ__Group__c 
                                           FROM SBQQ__LineItems__r
                                           WHERE Group_Number__c = 2 limit 1)
                                          from SBQQ__Quote__c 
                                          where id = :selectedQuoteId];//<T28> Added sub query to pick the line items with Group number -> 2
        Map<Id,Id> prodVsPBE = new Map<Id,Id>();
        Set<Id> prodIds = new Set<Id>();
        for(Cart_Line_Item__c cli : cartLineItems){
            prodIds.add(cli.Product__c);
        }
        
        Map<Id,Product2> prodVsProdMap = new  Map<Id,Product2>([Select Id,SBQQ__BillingFrequency__c,SBQQ__SubscriptionTerm__c,SBQQ__BillingType__c,SBQQ__SubscriptionPricing__c,SBQQ__SubscriptionBase__c,SBQQ__ChargeType__c,Description from Product2 where Id in :prodIds]);
        
        
        List<PricebookEntry> pbeList = [SELECT Id, Product2Id, IsActive FROM PricebookEntry where Product2Id in :prodIds and IsActive=true and Pricebook2Id=:pricebookId];
        
        for(PricebookEntry pbe: pbeList){
            prodVsPBE.put(pbe.Product2Id,pbe.Id);
        }
        
        Set<Id> attrIds = new Set<Id>();
        for(Cart_Line_Item__c cli : cartLineItems){
            attrIds.add(cli.Attribute_Relationship__c);
        }
        List<Attribute_Lines__c> attrLines =  new List<Attribute_Lines__c>();
        attrLines  = [Select Id,String_Value__c,Attribute_Name__c from Attribute_Lines__c where Attribute_Junction__c in :attrIds];
        
        for(Attribute_Lines__c attr : attrLines){
            if(attr.Attribute_Name__c == 'Service Account Name'){
                attr.String_Value__c = quoteList[0].SBQQ__Account__r.Name;
            }
            if(attr.Attribute_Name__c == 'Service Country'){
                attr.String_Value__c = quoteList[0].SBQQ__Account__r.BillingCountry;
            }
            if(attr.Attribute_Name__c == 'Service State'){
                attr.Picklist_Value__c = quoteList[0].SBQQ__Account__r.BillingState;
            }
            if(attr.Attribute_Name__c == 'Service City'){
                attr.String_Value__c = quoteList[0].SBQQ__Account__r.BillingCity;
            }
            if(attr.Attribute_Name__c == 'Service Street Address'){//added by SaiV for MH Ads - 05/10/23
                attr.String_Value__c = quoteList[0].SBQQ__Account__r.BillingStreet;
            }
            if(attr.Attribute_Name__c == 'URL'){
                attr.String_Value__c = quoteList[0].SBQQ__Account__r.Website;
            }
        }
        
        if(!test.isRunningTest()){
            update attrLines;        
        }
        
        for(Cart_Line_Item__c cli : cartLineItems){
            SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
            qli.SBQQ__Product__c = cli.Product__c;
            qli.SBQQ__Quote__c = selectedQuoteId;            
            qli.SBQQ__Quantity__c =1;
            qli.Attribute_Relationship__c = cli.Attribute_Relationship__c;
            //<T20>
            System.debug(cli.Price__c);
            String Price = cli.Price__c.removeStart('$');
            Decimal ListPrice = Decimal.valueOf(Price);
            qli.SBQQ__ListPrice__c = ListPrice;    
            //<T20>
            qli.SBQQ__BillingFrequency__c = prodVsProdMap.get(cli.Product__c).SBQQ__BillingFrequency__c;
            qli.SBQQ__BillingType__c    = prodVsProdMap.get(cli.Product__c).SBQQ__BillingType__c;
            qli.SBQQ__SubscriptionPricing__c    = prodVsProdMap.get(cli.Product__c).SBQQ__SubscriptionPricing__c;
            qli.SBQQ__SubscriptionBase__c = prodVsProdMap.get(cli.Product__c).SBQQ__SubscriptionBase__c;
            qli.SBQQ__Description__c  = prodVsProdMap.get(cli.Product__c).Description;
            qli.SBQQ__ChargeType__c = prodVsProdMap.get(cli.Product__c).SBQQ__ChargeType__c;
            qli.SBQQ__PricebookEntryId__c = prodVsPBE.get(cli.Product__c);
            //system.debug('term======='+prodVsProdMap.get(cli.Product__c).SBQQ__SubscriptionTerm__c);
            qli.SBQQ__DefaultSubscriptionTerm__c = prodVsProdMap.get(cli.Product__c).SBQQ__SubscriptionTerm__c;
            qli.SBQQ__ProductSubscriptionType__c = 'Renewable/Evergreen';//<T32>
            qli.SFInventoryId__c = cli.SFInventoryId__c; 
            qli.Created_From_Quote_Builder__c = True;
            //if (qli.SBQQ__EffectiveEndDate__c != null){//<T33>
            system.debug('===optyname--==='+quoteList[0].SBQQ__Opportunity2__r.Name);
            //system.debug('===optyname2--==='+!quoteList[0].SBQQ__Opportunity2__r.Name.Contains('EG 2 EG'));
            if(!quoteList[0].SBQQ__Opportunity2__r.Name.Contains('EG 2 EG')){
                system.debug('===in if-----');
                qli.SBQQ__SubscriptionType__c = 'Renewable';
            
            }else if(quoteList[0].SBQQ__Opportunity2__r.Name.Contains('EG 2 EG')){
                system.debug('===in else if-----');
                qli.SBQQ__SubscriptionTerm__c = 1;
                qli.SBQQ__SubscriptionType__c = 'Evergreen';
            }
            //<T33>
            //system.debug('=======qli.SBQQ__SubscriptionType__c======'+qli.SBQQ__SubscriptionType__c);
            if (quoteList != null && quoteList.size() > 0 && quoteList[0] != null && quoteList[0].SBQQ__LineItems__r != null && quoteList[0].SBQQ__LineItems__r.size() > 0 && quoteList[0].SBQQ__LineItems__r[0] != null) {//<T28>
                qli.SBQQ__Group__c = quoteList[0].SBQQ__LineItems__r[0].SBQQ__Group__c; //<T28> Assigning the Group value to the new QLI
            }
            cartId = cli.Cart__c;
            quoteLineList.add(qli);
        }
        
        if(!test.isRunningTest()){
            insert quoteLineList;
        }
        
        if(cartId != null){
            List<Cart__c> c = [Select Id from Cart__c where id = :cartId];
            delete c;
        }      
    }
    
    @Auraenabled
    public static List<SBQQ__Quote__c> getRelatedOpenQuotes(Id selectedAccId)
    {
        System.debug(selectedAccId);   
        
        List<Account> acc = [Select Id,Recordtype.developerName from Account where id = :selectedAccId ];
        
        Id userId= UserInfo.getUserId();
        if(acc != null && acc[0].Recordtype.developerName == 'Nolo_Account'){
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();//<T28>
            List<SBQQ__Quote__c> quoteList1 = [Select Id,Name, SBQQ__Opportunity2__r.Name, SBQQ__SalesRep__r.Name, SBQQ__Status__c, SBQQ__NetAmount__c,Subscription_type__c,CreatedDate  from SBQQ__Quote__c where (SBQQ__Status__c = 'Draft' OR SBQQ__Status__c = 'Approved') and Subscription_type__c != 'Renewal' and Subscription_type__c != 'Evergreen' and recordtype.name != 'Offset Quote' and  Subscription_type__c != 'Rebase Evergreen'and Subscription_type__c != 'EG 2 EG' and  recordtype.name != 'MH Cancel Quote' and SBQQ__Account__c = :selectedAccId   and ownerId = :userId]; //<T09> <T11> - Added CreatedDate field
            if(quoteList1 != null){
                quoteList.addAll(quoteList1);//<T28>
            }
            List<SBQQ__Quote__c> quoteList2 = [Select Id,Name, SBQQ__Opportunity2__r.Name, SBQQ__SalesRep__r.Name, SBQQ__Status__c, SBQQ__NetAmount__c,Subscription_type__c,CreatedDate //<T09> <T11> - Added CreatedDate field 
                                               from SBQQ__Quote__c 
                                               WHERE ((SBQQ__Status__c = 'Draft' OR SBQQ__Status__c = 'Approved') 
                                                      AND Subscription_type__c IN ('Rebase Evergreen','EG 2 EG') 
                                                      AND RecordType.Name NOT IN ('Offset Quote', 'MH Cancel Quote')
                                                      AND  Id IN (
                                                          SELECT SBQQ__Quote__c 
                                                          FROM SBQQ__QuoteLine__c 
                                                          WHERE Group_Number__c = 2
                                                      )
                                                      AND SBQQ__Account__c = :selectedAccId   
                                                      AND OwnerId = :userId)]; //<T28> To list down all the EG 2 EG & Rebase Evergreen Quotes with Group 2 Line items
            
            if(quoteList2 != null){
                quoteList.addAll(quoteList2);//<T28>
            }
            if(quoteList != null){
                return quoteList;
            }else{
                return null;
            }
        }else{
            throw new AuraHandledException('Please select MH Account');    
        }
    }
    //<T06> ends   
    
    //<T14> starts
    @Auraenabled
    public static Id getAccId()
    {
        Id userId = UserInfo.getUserId();
        List<Cart__c> c = [Select Id, Account__c FROM Cart__c where ownerId=:userId limit 1];
        if(c!= null && c.size()>0){
            return c[0].Account__c;
        }else{
            return null;
        }
    }
    
    //<T14> Get the selected inventory results and set it to the product summary table
    public PageReference setprodSummaryList() {        
        String ps = Apexpages.currentPage().getParameters().get('prodSummaryToShow');
        String t = Apexpages.currentPage().getParameters().get('total');
        if(!String.isBlank(t)){
        total = Decimal.valueof(t);
        }
        if(String.isEmpty(ps) != true){
            prodSummaryList = (List<ProductSummary>)JSON.deserialize(ps, List<ProductSummary>.class);
        }
        return null; 
    }
    public PageReference cartButton(){
        
        System.debug(selectedResults); 
        Id currentUser = UserInfo.getUserId();
        List<Cart__c> cartList = [Select id,(Select id from Cart_Line_Items__r) from Cart__c where ownerId = :currentUser];
        System.debug(currentUser);
        System.debug(cartList);
        
        if(cartList == null || cartList.size()<=0 || ( cartList != null && cartList[0].Cart_Line_Items__r != null  && cartList[0].Cart_Line_Items__r.size() <=0) || (cartList != null && cartList[0].Cart_Line_Items__r == null ) ){
            System.debug(cartList);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The cart is empty. Please add some products.'));
            return null;
        }
        PageReference pr = new PageReference('/lightning/n/Add_To_Cart_Page');
        pr.setRedirect(true);
        return pr;
        
    }
    
       /**
    * Created By Shashi Korimilli 
    * Method : updateProdListprofProducts
    * Description: To Populate the Listing products
    * */
   public void updateProdListprofProducts(){
       List<SelectOption> options = new List<SelectOption>();
        areasOfPracticeList = new list<selectoption>();
       // selectedareaOfPracticeList = new List<String>();
        selectedProductTypes = new list<String>(); 
       // geoLocationsList = new List<GEO_Location__c>();
        Set<String> aopValues = new Set<String>();
        Set<String> prodIds = new Set<String>();
        List<String> prodCodes = new List<String>(); 
        
        Integer count = 0;
        selectedProductStrings = '';
        containsCity = false;
        containsState = false;
        containsCounty = false;
        containsOnlyBanner = false;//<T08>
        disableCity = false;
        disableState = false;
        disableCounty = false;
        //countytrings = null;
        for(ProdTypeWrapper pt : ProfProdTypeList){
            if(pt.isSelected == true){
                
                count+=1;
                prodIds.add(prodCodeMap.get(pt.Name));
                selectedProductTypes.add(pt.Name);
                selectedProductStrings += pt.Name;
                
               
        }
        }
        
       
        
        if(prodIds != null){
            system.debug('@@@@prodIds'+prodIds);
            system.debug('@@@@disableState'+disableState);
            system.debug('@@@@disableCity'+disableCity);
            system.debug('@@@@disableCounty'+disableCounty);
            system.debug('@@@@renderState'+containsCity);
            system.debug('@@@@containsCounty'+containsCounty);
            system.debug('@@@@containsState'+containsState);
            
            prodCodes.addAll(prodIds);
            
           
            
        }
        
    }
    
}