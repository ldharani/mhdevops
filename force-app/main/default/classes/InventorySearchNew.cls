global class InventorySearchNew{
    public List<selectoption> areasOfPracticeList{get;set;}
    public String selectedareaOfPractice {get;set;}
    public String selectedProdType{get;set;}
    public list<selectoption> prodTypeList{get;set;}
    public string searchCountry {get;set;}
    public string searchState {get;set;}
    public string searchCounty {get;set;}
    public string searchCity {get;set;}
    public List<GEO_Location__c > geoLocationsList{get;set;}    
     public static  List<String> countryList {get;set;}   //sai
     public static List<SelectOption> dynamicStatelisttemp; //sai
     public static  List<String> StateList {get;set;}   //sai
    public static  List<String> cityList {get;set;}
    public static  List<String> countyList {get;set;}
    public String countrystrings{get;set;}
    public String statestrings{get;set;}
    public String citystrings{get;set;}
    public String countytrings{get;set;}
    public String countyString{get;set;}
    public List<string> statecitylist{get;set;}
    public String selectedstatecity{get;set;}
     public List<String> selectedareaOfPracticeList {get;set;}
   // public static List<SelectOption> dynamicCountylist{get;set;}
    public boolean isReset{get;set;}
    public List<SelectOption> dynamicCountrylist{get;set;}
    
    //public transient List<mainDataOuterClass> mainWrapperList{get;set;}
   // public List<mainDataInnerClass> mainInnerList{get;set;}
    public Map<String,String> prodCodeMap {get;set;}
    private final Integer RECORDS_LIMIT_SIZE = 1000;
    private final String MSG_NUM_OF_RECORDS = 'Only first 1000 records are displayed. Please filter the data';
    public List<resultWrapper> resultstoshow {get;set;}
    public Map<string,string>searchProdTypeVSInvProdType = new Map<string,string>{
                              'Lawyers.com Preferred City Results'=>'Preferred City Results',
                               'Lawyers.com Preferred County Results' => 'Preferred County Results',
                               'Martindale.com Preferred County Results' => 'MDC Preferred County Results',
                               'Lawyers.com Shared County Results' => 'Lawyers.com Shared County Results',
                               'Martindale.com Preferred State Results' => 'MDC Preferred State Results'   
                                         };
    
    
    public InventorySearchNew(){   
        system.debug('@@@@after reset');
       // isReset = True;
        //countryList.add('USA');
        prodTypeList = new list<selectoption>();
        prodCodeMap = new Map<String,String>();
        dynamicStatelisttemp = new List<SelectOption>();
        List<Inventoried_Products_list_using_Product__c > iplist = Inventoried_Products_list_using_Product__c.getall().values();
        iplist.sort();
        for(Inventoried_Products_list_using_Product__c ip: iplist){
            prodTypeList.add(new SelectOption(ip.Product_Name__c,ip.Product_Name__c));
            prodCodeMap.put(ip.Product_Name__c,ip.Product_Code__c);
        }        
        searchCountry = 'USA'; //default country 
        
        //selectedProdType = 'Lawyers.com Preferred Banner Placements';
        selectedProdType = '------------------------------- Please Select  -------------------------------';
        aOPListBasedOnProduct();
        
         String query = 'SELECT CountryName__c FROM GEO_Location__c '+
                            ' WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\'' +
                             ' Group by CountryName__c order by CountryName__c  ASC ';
        AggregateResult[] groupedResults = Database.query(query);
         dynamicCountrylist = new List<SelectOption>();
        for(AggregateResult ar : groupedResults){
            if(ar.get('CountryName__c') != null && ar.get('CountryName__c') != '')
            dynamicCountrylist.add(new SelectOption((String)ar.get('CountryName__c'),(String)ar.get('CountryName__c')));
        }
    }
    public void aOPListBasedOnProduct(){
        //isReset =True;
        //system.debug('selectedProdType: '+selectedProdType);
        areasOfPracticeList = new list<selectoption>();        
        geoLocationsList = new List<GEO_Location__c>();
        String prodId = prodCodeMap.get(selectedProdType);
        
       system.debug('@@@@prodId'+prodId);
        
        //system.debug('prodId : '+prodId );
        String squery = 'select id,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c INCLUDES (\'' + prodId + '\') order by AOP_Name__c limit 1000';
       
        geoLocationsList = database.query(squery);
        for(GEO_Location__c geo:geoLocationsList ){
            areasOfPracticeList.add(new SelectOption(geo.AOP_Name__c ,geo.AOP_Name__c));
        }
        // To clear grey out field values on change of Product Type
        selectedareaOfPracticeList = new List<String>();
        countryList= new List<String>();
        StateList= new List<String>();
        cityList= new List<String>();
        countyList= new List<String>();
        statecitylist = new List<string>();
       /* countryList.add('USA');
        integer i=0;
        statestrings ='';
        for(aggregateResult ag :[SELECT State_Abbrevation__c 
                                     FROM GEO_Location__c 
                                     WHERE RecordType.DeveloperName='M_H_GEO_Locations' 
                                          and CountryName__c ='USA' 
                                           AND State_Abbrevation__c!=NULL 
                                 group by State_Abbrevation__c]){ 
                   String state = (String)ag.get('State_Abbrevation__c');
                if(state != null && state != ''){
                    if(i==0){
                        statestrings += state;
                    }
                    else{
                       statestrings += ','+state; 
                    }
                    i++;                 
               }
            }*/
        resultstoshow = new List<resultWrapper>();
        searchState = '';
        searchCounty = '';
        searchCity = '';        
    }    
    
    public PageReference resetParameters(){
        system.debug('@@@@ in reset'+ isReset);
       // isReset = true;
        //List<selectoption> areasOfPracticeList = new List<selectoption>();
        selectedProdType = '------------------------------- Please Select  -------------------------------';
         selectedareaOfPracticeList = new List<String>();
         countryList= new List<String>();
         StateList= new List<String>();
         cityList= new List<String>();
        countyList= new List<String>();
        statecitylist = new List<string>();
        
        resultstoshow = new List<resultWrapper>();
        ////mainInnerList = new List<mainDataInnerClass>();
        return null;
    }
    
    
    
    public PageReference runsearch(){
        system.debug('@@@@cityList'+cityList);
         system.debug('@@@@StateList'+StateList);
         system.debug('@@@@countryList   '+countryList);
        system.debug('@@@@countyList'+countyList);
            statecitylist = new List<string>();
        
        Boolean independentCounty = false;
        if(countyList != NULL && !countyList.isEmpty()){
            set<string>countyInnerSet = new set<string>();
            countyInnerSet.addAll(countyList);
            system.debug('@@@countyInnerSet'+countyInnerSet);
            if(countyInnerSet.contains('Independent City')){
                independentCounty = true;
            }
        }
        
        system.debug('@@@@independentCounty'+independentCounty);
        
           /***************country Result Logic**********************************/
        If(selectedProdType == 'Lawyers.com Preferred National Results'
              || selectedProdType == 'Martindale.com Preferred National Results'
              || selectedProdType == 'Lawyers.com Spanish Preferred National Results'
              || selectedProdType == 'Preferred National Links'
              || selectedProdType == 'Lawyers.com Shared National Results'
              ){
            statecitylist = countryList;
             statecitylist.sort();
        }
         /******************************************************************************/
        
        /*********************State Result Logic***************************************/
        else If(selectedProdType == 'Lawyers.com Preferred State Results'
                  || selectedProdType == 'Preferred State Links'
                  || selectedProdType == 'Lawyers.com Spanish Preferred State Results'
                  || selectedProdType == 'Martindale.com Preferred State Results'){
            string query = 'Select CountryName__c, State_Abbrevation__c '+
                              ' From GEO_Location__c '+
                              ' where CountryName__c IN:countryList ';
                      If(StateList != NULL  && !StateList.isEmpty()){
                          query += ' AND State_Abbrevation__c IN:StateList ';
                                   
                      }
                      query += '  AND State_Abbrevation__c != NULL '+
                                    ' Group by CountryName__c,State_Abbrevation__c ';
                      for(aggregateResult ag: database.query(query)){
                        statecitylist.add(string.valueOf(ag.get('State_Abbrevation__c')) +','+ string.valueOf(ag.get('CountryName__c')));
                      }
                      statecitylist.sort();
               }
        /*******************************************************************************************/
        
        
         /*********************City Result Logic***************************************/ 
          If(selectedProdType == 'Lawyers.com Preferred City Results'
                 || (selectedProdType == 'Lawyers.com Preferred Banner Placements'
                      && independentCounty)
                 || (selectedProdType == 'Lawyers.com Spanish Preferred County Results'
                      && independentCounty)
                      ){
         
             string query = 'Select CountryName__c, State_Abbrevation__c,City_Name__c '+
                                           ' From GEO_Location__c '+
                                           ' where CountryName__c IN:countryList AND State_Abbrevation__c IN:StateList ';
                                           //' AND City_Name__c !=NULL '+
                                           //' Group by CountryName__c,State_Abbrevation__c,City_Name__c ';
                 if(independentCounty){
                          query  +=  '  and County_Name__c != NULL and County_Name__c = \'Independent City\'';      
                 }
                if(cityList != NULL && !cityList.isEmpty()){
                
                query  +=  '  AND City_Name__c IN:cityList ' ;
                }
                
                query  += '  AND City_Name__c !=NULL '+
                           ' Group by CountryName__c,State_Abbrevation__c,City_Name__c ';
            List<aggregateResult> agcity = new List<aggregateResult>();
              agcity =  database.query(query);
            
            for(aggregateResult ag: agcity){
                if(independentCounty){
                    statecitylist.add(string.valueOf(ag.get('City_Name__c')) +','+ 'Independent City' +','+string.valueOf(ag.get('State_Abbrevation__c')) +','+string.valueOf(ag.get('CountryName__c')));
                }
                else{
                     statecitylist.add(string.valueOf(ag.get('City_Name__c')) +','+ string.valueOf(ag.get('State_Abbrevation__c')) +','+string.valueOf(ag.get('CountryName__c')));
                }
               
                
            }                           
             statecitylist.sort();
         }
         
         /*******************************************************************************************/
         
            /*********************County Result Logic***************************************/ 
          If(selectedProdType == 'Lawyers.com Preferred County Results'
                 ||selectedProdType == 'Lawyers.com Spanish Preferred Banner Placements'
                 ||selectedProdType == 'Lawyers.com Preferred Banner Placements'
                 ||selectedProdType == 'Lawyers.com Spanish Preferred County Results'
                 ||selectedProdType == 'Lawyers.com Shared County Results'
                 ||selectedProdType == 'Martindale.com Preferred County Results'
                 ){
         
             string query = 'Select CountryName__c, State_Abbrevation__c,County_Name__c'+
                                           ' From GEO_Location__c '+
                                           ' where CountryName__c IN:countryList AND State_Abbrevation__c IN:StateList ';
                                          
                if(countyList != NULL && !countyList.isEmpty()){
                
                    query  +=  '  AND County_Name__c IN:countyList ' ;
                    if(independentCounty){
                        query  +=  '  AND County_Name__c != \'Independent City\'';
                    }
                }
                
                query  += '  AND County_Name__c !=NULL '+
                           ' Group by CountryName__c,State_Abbrevation__c,County_Name__c ';
                           
                           system.debug('@@@query  '+query);
             List<aggregateResult> agcounty = new List<aggregateResult>();
              agcounty =  database.query(query);
            
            for(aggregateResult ag: agcounty){
                statecitylist.add(string.valueOf(ag.get('County_Name__c')) +','+ string.valueOf(ag.get('State_Abbrevation__c'))+','+string.valueOf(ag.get('CountryName__c')));
            }                           
            statecitylist.sort(); 
             
             
         }
         
         /*******************************************************************************************/
         
         
                
         /*   
            string getstatecitylistquery = '';
            getstatecitylistquery = 'Select CountryName__c, State_Abbrevation__c,City_Name__c '+
                                           ' From GEO_Location__c '+
                                           ' where CountryName__c IN:countryList AND State_Abbrevation__c IN:StateList '+
                                           ' AND City_Name__c !=NULL '+
                                           ' Group by CountryName__c,State_Abbrevation__c,City_Name__c ';
            if(cityList != NULL && !cityList.isEmpty()){
                getstatecitylistquery = 'Select CountryName__c, State_Abbrevation__c,City_Name__c '+
                                           ' From GEO_Location__c '+
                                           ' where CountryName__c IN:countryList AND State_Abbrevation__c IN:StateList '+
                                           ' AND City_Name__c IN:cityList AND City_Name__c !=NULL '+
                                           ' Group by CountryName__c,State_Abbrevation__c,City_Name__c ';
            }
            
            for(aggregateResult ag: database.query(getstatecitylistquery)){
                statecitylist.add(string.valueOf(ag.get('City_Name__c')) +','+ string.valueOf(ag.get('State_Abbrevation__c')));
            }
        */
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
        public List<innerOrders> innerordersList{get;set;}
        
        
        public resultWrapper(string aop, string tcountry,string tstate, string tcity, string tcounty){
           
            this.sold = 0;
            this.pend  = 0;
            this.available = 0;
            this.Maxcount = 0;
            this.areaofPractice = aop;
            this.Country = tcountry;
            this.state = tstate;
            this.City = tcity;
            this.county = tcounty;
            
            
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
        system.debug('@@@doSearch calling');
        resultstoshow = new List<resultWrapper>();
         String strAOP = selectedProdType + ' AOP';
         Set<Id> filteredOrderChargeIds = new Set<Id>();
         Set<Id> searchfilteredOrderChargeIds = new Set<Id>();
         Set<Id> filteredOptyChargeIds = new Set<Id>();
         Set<Id> searchfilteredOptyChargeIds = new Set<Id>();
         string givenCountry = '';
        string givenstate = '';
        string givencity = '';
        string givencounty = '';
         string filter = '';
        string filteropty = '';
        string countrystateString = '';
        Boolean independentCounty = false;
         List<string> splittedstring = selectedstatecity.split(',');
        if(splittedstring.size() == 4){
            independentCounty = true;
        }
        /*******************************sold Logic Starts here **************************************************/
        /***************************For country*********************************************/
         system.debug('@@@ filted order charge After doSearch calling'+filteredOrderChargeIds);
         
         If((selectedProdType == 'Lawyers.com Preferred National Results'
              || selectedProdType == 'Martindale.com Preferred National Results'
              || selectedProdType == 'Lawyers.com Spanish Preferred National Results'
              || selectedProdType == 'Preferred National Links')
              || selectedProdType == 'Lawyers.com Shared National Results'
              //|| selectedProdType == 'Preferred State Links')
             ){
                  givenCountry = selectedstatecity.split(',')[0];
                  filter += ' where Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'Country\' '+
                            ' AND String_Value__c=:givenCountry and Order_Rate_Plan_Charge__c IN:filteredOrderChargeIds ' ;
                  
                  system.debug('@@@ Filter'+ filter);
              }
        
               

        
        /*********************State Result Logic***************************************/
        else If(selectedProdType == 'Lawyers.com Preferred State Results'
                  || selectedProdType == 'Preferred State Links'
                  || selectedProdType == 'Lawyers.com Spanish Preferred State Results'
                  || selectedProdType == 'Martindale.com Preferred State Results'){
           givenCountry = selectedstatecity.split(',')[1];
           givenstate   = selectedstatecity.split(',')[0];
                      countrystateString = givenCountry +';'+givenstate;
              filter += ' where ((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'State\') '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'State\')) '+
                            ' AND Order_Rate_Plan_Charge__r.Address_Value__c =:countrystateString and Order_Rate_Plan_Charge__c IN:filteredOrderChargeIds ' ;           
        }
        /*******************************************************************************************/
        
        
        /*********************City Result Logic***************************************/
        else If(selectedProdType == 'Lawyers.com Preferred City Results'
                || (selectedProdType == 'Lawyers.com Preferred Banner Placements'
                     && independentCounty)
                || (selectedProdType == 'Lawyers.com Spanish Preferred County Results'
                     && independentCounty)
                     ){
           givenCountry = selectedstatecity.split(',')[2];
           givenstate   = selectedstatecity.split(',')[1];
           givencity    = selectedstatecity.split(',')[0];
                      
                         if(independentCounty){
                            String givenCountyCountry = selectedstatecity.split(',')[3];
                            countrystateString = givenCountyCountry + ';' + givenCountry +';'+givenstate + ';'+ givencity ;  
                         }
                         
                         else{
                             countrystateString = givenCountry +';'+givenstate + ';'+ givencity ;
                         }
                         system.debug('@@@@@ Final Value'+countrystateString);
              filter += 'where ((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'City\') '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'City\')) '+
                            ' AND Order_Rate_Plan_Charge__r.Address_Value__c =:countrystateString and Order_Rate_Plan_Charge__c IN:filteredOrderChargeIds ' ;           
        }
        /*******************************************************************************************/
        
          /*********************County Result Logic***************************************/ 
         else If(selectedProdType == 'Lawyers.com Preferred County Results'
                 ||(selectedProdType == 'Lawyers.com Preferred Banner Placements'
                     && independentCounty == false)
                 ||(selectedProdType == 'Lawyers.com Spanish Preferred County Results'
                     && independentCounty == false)    
                 ||selectedProdType == 'Lawyers.com Shared County Results'
                 ||selectedProdType == 'Lawyers.com Spanish Preferred Banner Placements'
                 ||selectedProdType == 'Martindale.com Preferred County Results'){
                    
                    
                         
                     
                          givenCountry = selectedstatecity.split(',')[2];
                            givenstate   = selectedstatecity.split(',')[1];
                            givencounty    = selectedstatecity.split(',')[0];
                          countrystateString = givenCountry +';'+givenstate + ';'+ givencounty;
                       filter += 'where ((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'County\') '+
                                  ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'County\')) '+
                                ' AND Order_Rate_Plan_Charge__r.Address_Value__c =:countrystateString and Order_Rate_Plan_Charge__c IN:filteredOrderChargeIds ' ;   
                          
                   /* filter += ' where (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'Country\' '+
                            ' AND String_Value__c=:givenCountry) AND ((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'State\' AND Picklist_Value__c=:givenstate) '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'State\' AND String_Value__c=:givenstate)) '+
                            '  AND ((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'County\' AND Picklist_Value__c=:givencounty) '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'County\' AND String_Value__c=:givencounty)) ';
                               */      
       
                     
                 }
        
        system.debug('@@@givenCountry'+givenCountry);
        for(string saop :selectedareaOfPracticeList){
            resultstoshow.add(new resultWrapper(saop,givenCountry,givenstate,givencity,givencounty));
        }
          
         
        
         List<Order_Charge_Attribute__c> orcaList = [SELECT id,Picklist_Value__c,Product_Type__c,Order_Rate_Plan_Charge__r.Address_Value__c,
                                                         Attribute_Name__c,Attribute_Type__c,Order_Rate_Plan_Charge__c,Order_Rate_Plan_Charge__r.invoiceit_s__Status__c,
                                                         Order_Rate_Plan_Charge__r.invoiceit_s__Service_End_Date__c,String_Value__c FROM Order_Charge_Attribute__c 
                                                         where Product_Type__c =: selectedProdType and 
                                                          Attribute_Type__c = 'Picklist' and Picklist_Value__c IN: selectedareaOfPracticeList
                                                             //OR  (Attribute_Type__c = 'Text' and String_Value__c IN: selectedareaOfPracticeList))
                                                          and (Order_Rate_Plan_Charge__r.invoiceit_s__Status__c = 'Active' or 
                                                              (Order_Rate_Plan_Charge__r.invoiceit_s__Status__c = 'Cancelled'and Order_Rate_Plan_Charge__r.invoiceit_s__Service_End_Date__c >= Today) or 
                                                              (Order_Rate_Plan_Charge__r.invoiceit_s__Status__c = 'Truncated'and Order_Rate_Plan_Charge__r.invoiceit_s__Service_End_Date__c >= Today))
                                                          and (Attribute_Name__c = 'AOP' or Attribute_Name__c =:strAOP)];
                                                               
          for(Order_Charge_Attribute__c oAttribute : orcaList){
           
            filteredOrderChargeIds.add(oAttribute.Order_Rate_Plan_Charge__c);            
            
          } 
        system.debug('@@@filteredOrderChargeIds'+filteredOrderChargeIds);
        string query = 'select id,Attribute_Name__c,Attribute_Type__c ,'+
                            ' String_Value__c, Order_Rate_Plan_Charge__c, '+
                            ' Order_Rate_Plan_Charge__r.AOP_Name__c, '+
                            ' Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c '+
                            ' From Order_Charge_Attribute__c ' ;
        
        Map<String,set<Id>> orderaopVsOrderIds = new Map<String,set<Id>>();
        Map<String,List<innerOrders>> orderaopVsinnerwraps = new Map<String,List<innerOrders>>();
        Set<Id>allOrderIds                     = new Set<Id>();
        
           
        IF(!filteredOrderChargeIds.isEmpty()){
            
            
            for(Order_Charge_Attribute__c oc: database.query(query+filter)){
                      searchfilteredOrderChargeIds.add(oc.Order_Rate_Plan_Charge__c);
                        allOrderIds.add(oc.Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c);
                        If(orderaopVsOrderIds.containsKey(oc.Order_Rate_Plan_Charge__r.AOP_Name__c)){
                            orderaopVsOrderIds.get(oc.Order_Rate_Plan_Charge__r.AOP_Name__c).add(oc.Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c);
                        }
                        else{
                            orderaopVsOrderIds.put(oc.Order_Rate_Plan_Charge__r.AOP_Name__c, new set<ID>{oc.Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c});
                        }
                  }
            
                If(!allOrderIds.isEmpty()){
                    
                   Map<ID,invoiceit_s__Job__c> orderIdVsOrder = new Map<ID,invoiceit_s__Job__c>([select id,Name,
                                                           invoiceit_s__Account__c,OrderNumber__c,
                                                            invoiceit_s__Account__r.Name,
                                                           invoiceit_s__Account__r.MH_Cust_Number__c
                                                     From invoiceit_s__Job__c
                                                   Where ID IN:allOrderIds]);
                    for(string aop: orderaopVsOrderIds.keySet()){
                        List<innerOrders>tempinnerOrders = new List<innerOrders>();
                        for(Id ordId : orderaopVsOrderIds.get(aop)){
                            invoiceit_s__Job__c toder = orderIdVsOrder.get(ordId);
                            tempinnerOrders.add(new innerOrders(toder.invoiceit_s__Account__r.MH_Cust_Number__c,
                                                                 toder.invoiceit_s__Account__r.Name,
                                                                 'Sold',
                                                                  toder.OrderNumber__c,
                                                                  toder.id,
                                                                  null));
                          
                        }
                       orderaopVsinnerwraps.put(aop,tempinnerOrders); 
                        
                    }
                   
                    
                }
                  system.debug('@@@searchfilteredOrderChargeIds'+searchfilteredOrderChargeIds);
                  for(aggregateResult ag: [select count(id) cnt,Picklist_Value__c
                                         From  Order_Charge_Attribute__c 
                                              where Product_Type__c =: selectedProdType and 
                                               ((Attribute_Type__c = 'Picklist' and Picklist_Value__c IN: selectedareaOfPracticeList)
                                                   OR  (Attribute_Type__c = 'Text' and String_Value__c IN: selectedareaOfPracticeList))
                                                 and (Attribute_Name__c = 'AOP' or Attribute_Name__c =:strAOP)
                                                  and Order_Rate_Plan_Charge__c IN:searchfilteredOrderChargeIds
                                           group by Picklist_Value__c]){
                                               system.debug('@@@@@picklistvalue'+string.valueOf(ag.get('Picklist_Value__c')));
                                               system.debug('@@@@@countValue'+Integer.valueOf(ag.get('cnt')));                                                 
                                               for(resultWrapper rsp :resultstoshow){
                                                   if(rsp.areaofPractice == string.valueOf(ag.get('Picklist_Value__c'))){
                                                       rsp.sold = Integer.valueOf(ag.get('cnt'));
                                                       string gaop = string.valueOf(ag.get('Picklist_Value__c'));
                                                       if(orderaopVsinnerwraps.containsKey(gaop)){
                                                           rsp.innerordersList = orderaopVsinnerwraps.get(gaop);
                                                           
                                                       }
                                                       system.debug('@@@@@rsp.innerordersList'+rsp.innerordersList);
                                                   }
                                                   
                                               }                   
                                               
                    }
        }
        
         /*******************************sold Logic Ends here **************************************************/
       
        
        /********************************Pend Logic Starts here **************************************************/
        
        If((selectedProdType == 'Lawyers.com Preferred National Results'
              || selectedProdType == 'Martindale.com Preferred National Results'
              || selectedProdType == 'Lawyers.com Spanish Preferred National Results'
              || selectedProdType == 'Preferred National Links')
              || selectedProdType == 'Lawyers.com Shared National Results'
              //|| selectedProdType == 'Preferred State Links')
             ){
                  givenCountry = selectedstatecity.split(',')[0];
                  filteropty += ' where Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'Country\' '+
                            ' AND String_Value__c=:givenCountry and Opportunity_Rate_Plan_Charge__c IN:filteredOptyChargeIds ' ;
                  
            
              }
        
        
        
        /*********************State Result Logic***************************************/
        else If(selectedProdType == 'Lawyers.com Preferred State Results'
                  || selectedProdType == 'Preferred State Links'
                  || selectedProdType == 'Lawyers.com Spanish Preferred State Results'
                  || selectedProdType == 'Martindale.com Preferred State Results'){
           givenCountry = selectedstatecity.split(',')[1];
           givenstate   = selectedstatecity.split(',')[0];
                      countrystateString = givenCountry +';'+givenstate;
              filteropty += 'where ((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'State\') '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'State\')) '+
                            ' AND Opportunity_Rate_Plan_Charge__r.Address_Value__c =:countrystateString and Opportunity_Rate_Plan_Charge__c IN:filteredOptyChargeIds ' ;           
        }
        /*******************************************************************************************/
        
        
        /*********************City Result Logic***************************************/
        else If(selectedProdType == 'Lawyers.com Preferred City Results'
               || (selectedProdType == 'Lawyers.com Preferred Banner Placements'
                     && independentCounty)
               || (selectedProdType == 'Lawyers.com Spanish Preferred County Results'
                     && independentCounty)
                     ){
           givenCountry = selectedstatecity.split(',')[2];
           givenstate   = selectedstatecity.split(',')[1];
           givencity    = selectedstatecity.split(',')[0];
                       
                           if(independentCounty){
                            String givenCountyCountry = selectedstatecity.split(',')[3];
                            countrystateString = givenCountyCountry + ';' + givenCountry +';'+givenstate + ';'+ givencity ;  
                         }
                         
                         else{
                             countrystateString = givenCountry +';'+givenstate + ';'+ givencity ;
                         }
                      
              filteropty += 'where ((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'City\') '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'City\')) '+
                            ' AND Opportunity_Rate_Plan_Charge__r.Address_Value__c =:countrystateString and Opportunity_Rate_Plan_Charge__c  IN:filteredOptyChargeIds ' ;           
        }
        /*******************************************************************************************/
        
          /*********************County Result Logic***************************************/ 
         else If(selectedProdType == 'Lawyers.com Preferred County Results'
                 ||(selectedProdType == 'Lawyers.com Preferred Banner Placements'
                 && independentCounty == false)
                 ||(selectedProdType == 'Lawyers.com Spanish Preferred County Results'
                     && independentCounty == false)
                 ||selectedProdType == 'Lawyers.com Shared County Results'
                 ||selectedProdType == 'Lawyers.com Spanish Preferred Banner Placements'
                 ||selectedProdType == 'Martindale.com Preferred County Results'){
                      givenCountry = selectedstatecity.split(',')[2];
                        givenstate   = selectedstatecity.split(',')[1];
                        givencounty    = selectedstatecity.split(',')[0];
                      countrystateString = givenCountry +';'+givenstate + ';'+ givencounty;
                  /*  filteropty += 'where (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'Country\' '+
                            ' AND String_Value__c=:givenCountry) AND (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'State\' AND Picklist_Value__c=:givenstate) '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'State\' AND String_Value__c=:givenstate)) '+
                            ' AND CountryState_String__c) AND (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'County\' AND Picklist_Value__c=:givencounty) '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'County\' AND String_Value__c=:givencounty)) '+
                            ' AND Opportunity_Rate_Plan_Charge__r.Address_Value__c =:countrystateString)';           
                   */
                   filteropty += 'where ((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'County\') '+
                              ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'County\')) '+
                            ' AND Opportunity_Rate_Plan_Charge__r.Address_Value__c =:countrystateString and Opportunity_Rate_Plan_Charge__c  IN:filteredOptyChargeIds ' ;
                     
                 }
        
        system.debug('@@@givenCountry'+givenCountry);
        system.debug('@@@Country State String value'+countrystateString);
        system.debug('@@@selectedstatecity'+selectedstatecity);
        for(string saop :selectedareaOfPracticeList){
           // resultstoshow.add(new resultWrapper(saop,givenCountry,givenstate,givencity,givencounty));
        }
          
         
        
         List<Opportunity_Charge_Attribute__c> optycaList = [SELECT id,Picklist_Value__c,Product_Type__c,Opportunity_Rate_Plan_Charge__r.Address_Value__c,
                                                         Attribute_Name__c,Attribute_Type__c,Opportunity_Rate_Plan_Charge__c,
                                                         Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Product_SIN__c, 
                                                         Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c,
                                                         Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__r.StageName,
                                                        String_Value__c FROM Opportunity_Charge_Attribute__c 
                                                         where Product_Type__c =: selectedProdType and 
                                                          Attribute_Type__c = 'Picklist' and Picklist_Value__c IN: selectedareaOfPracticeList
                                                          and (Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Product_SIN__c ='' or 
                                                               Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Product_SIN__c = NULL)
                                                          and Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c != NULL
                                                             //OR  (Attribute_Type__c = 'Text' and String_Value__c IN: selectedareaOfPracticeList))
                                                          and Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__r.StageName != 'Closed Won'
                                                          and (Attribute_Name__c = 'AOP' or Attribute_Name__c =:strAOP)];
                                                               
          for(Opportunity_Charge_Attribute__c oAttribute : optycaList){
           
            filteredOptyChargeIds.add(oAttribute.Opportunity_Rate_Plan_Charge__c);            
            
          } 
        system.debug('@@@filteredOptyChargeIds'+filteredOptyChargeIds);
        string optyquery = 'select id, Attribute_Name__c, Attribute_Type__c , Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c,'+
                            ' String_Value__c, Opportunity_Rate_Plan_Charge__c,Opportunity_Rate_Plan_Charge__r.AOP_Name__c'+
                            ' From Opportunity_Charge_Attribute__c ';
 
        Map<String,set<Id>> optyaopVsOptyIds = new Map<String,set<Id>>();
        Map<String,List<innerOrders>> optyaopVsinnerwraps = new Map<String,List<innerOrders>>();
        Set<Id>   allOptyIds                 = new Set<Id>();
                                    
        system.debug('@@@@optquery'+ optyquery+filteropty);
           
        IF(!filteredOptyChargeIds.isEmpty()){
            
            
            for(Opportunity_Charge_Attribute__c oc: database.query(optyquery+filteropty)){
                      searchfilteredOptyChargeIds.add(oc.Opportunity_Rate_Plan_Charge__c);
                      allOptyIds.add(oc.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                        If(optyaopVsOptyIds.containsKey(oc.Opportunity_Rate_Plan_Charge__r.AOP_Name__c)){
                            optyaopVsOptyIds.get(oc.Opportunity_Rate_Plan_Charge__r.AOP_Name__c).add(oc.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c);
                        }
                        else{
                            optyaopVsOptyIds.put(oc.Opportunity_Rate_Plan_Charge__r.AOP_Name__c, new set<ID>{oc.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c});
                        }
                  }
                  
                  If(!allOptyIds.isEmpty()){
                    
                   Map<ID,Opportunity> optyIdVsopty = new Map<ID,Opportunity>([select id,Name,
                                                           Account.Name,Account.MH_Cust_Number__c,
                                                           Release_Inventory_Date__c
                                                     From Opportunity
                                                   Where ID IN:allOptyIds]);
                                                   
                     system.debug('@@@optyIdVsopty '+optyIdVsopty);
                                                    
                    for(string aop: optyaopVsOptyIds.keySet()){
                        List<innerOrders>tempinneroptys = new List<innerOrders>();
                        for(Id optyId : optyaopVsOptyIds.get(aop)){
                            Opportunity topty = optyIdVsopty.get(optyId);
                            tempinneroptys.add(new innerOrders(topty.Account.MH_Cust_Number__c,
                                                                 topty.Account.Name,
                                                                 'Pended',
                                                                  topty.Name,
                                                                 // topty.id));
                                                                  topty.id,
                                                                  topty.Release_Inventory_Date__c));
                          
                        }
                       optyaopVsinnerwraps.put(aop,tempinneroptys); 
                        
                    }
                   
                    
                }
                
                  system.debug('@@@searchfilteredOptyChargeIds'+searchfilteredOptyChargeIds);
                  for(aggregateResult ag: [select count(id) cnt,Picklist_Value__c
                                         From  Opportunity_Charge_Attribute__c 
                                              where Product_Type__c =: selectedProdType and 
                                               ((Attribute_Type__c = 'Picklist' and Picklist_Value__c IN: selectedareaOfPracticeList)
                                                   OR  (Attribute_Type__c = 'Text' and String_Value__c IN: selectedareaOfPracticeList))
                                                 and (Attribute_Name__c = 'AOP' or Attribute_Name__c =:strAOP)
                                                  and Opportunity_Rate_Plan_Charge__c IN: searchfilteredOptyChargeIds
                                           group by Picklist_Value__c]){
                                               system.debug('@@@@@picklistvalue'+string.valueOf(ag.get('Picklist_Value__c')));
                                               system.debug('@@@@@countValue'+Integer.valueOf(ag.get('cnt')));                                                 
                                               for(resultWrapper rsp :resultstoshow){
                                                   if(rsp.areaofPractice == string.valueOf(ag.get('Picklist_Value__c'))){
                                                       rsp.pend = Integer.valueOf(ag.get('cnt'));
                                                        string gaop = string.valueOf(ag.get('Picklist_Value__c'));
                                                   if(optyaopVsinnerwraps.containsKey(gaop)){
                                                       List<innerOrders> innerordersTemp = new List<innerOrders>();
                                                       if(rsp.innerordersList != NULL){
                                                           innerordersTemp = rsp.innerordersList;
                                                           innerordersTemp.addAll(optyaopVsinnerwraps.get(gaop));
                                                       }
                                                       else{
                                                           innerordersTemp = optyaopVsinnerwraps.get(gaop);
                                                       }
                                                           rsp.innerordersList= innerordersTemp;
                                                       }
                                                   }
                                                  
                                                   
                                               }                   
                                               
                    }
        }
        
        
       /*********************************Pend Ends here **************************************************/ 
        
        /*****************************Available Logic Starts Here*******************************************/
        
        Map<String,Integer> prodVsMaxCount = new Map<String,Integer>();
        for(Inv_Product__mdt invp : [select id,Product_name__c,Max_Count__c 
                                     From  Inv_Product__mdt]){
               prodVsMaxCount.put(invp.Product_name__c,Integer.valueOf(invp.Max_Count__c));                          
         }
        
        
        Map<string,Integer> aopNameVsLimit = new Map<string,Integer>();
        
        //Inventory Table Search logic starts here
        If(searchProdTypeVSInvProdType.containsKey(selectedProdType)){
            
            string prodtype = searchProdTypeVSInvProdType.get(selectedProdType);
            string valueId = '';
            //getting geolocation value ID here
            string geoFilter = '';
            If(selectedProdType == 'Martindale.com Preferred State Results'){
                geoFilter = ' where countryStateString__c =:countrystateString LIMIT 1';
            }
            else If(selectedProdType == 'Lawyers.com Preferred County Results'
                   ||selectedProdType == 'Lawyers.com Shared County Results'
                   ||selectedProdType == 'Lawyers.com Spanish Preferred Banner Placements'
                   || selectedProdType == 'Martindale.com Preferred County Results'){
                geoFilter = ' where country_state_County_string__c =:countrystateString LIMIT 1';
            }
            else if(selectedProdType == 'Lawyers.com Preferred City Results'){
                 geoFilter = ' where address_String__c =:countrystateString LIMIT 1';      
            }
            
            string geoquery = 'Select id, Geo_Value_ID__c From GEO_Location__c';
            for(GEO_Location__c g : database.query(geoquery+geoFilter)){
                valueId = g.Geo_Value_ID__c;
            }
            system.debug('Value Id '+valueId);
            //after getting value id searching in inventory table
            //If result found adding aopNameVsLimit Map
            If(valueId !=''){
                for(Inventory_Table__c it : [select id,Product_Name__c, Aop_Name__c,
                                                      Inv_Limit__c
                                                      From Inventory_Table__c
                                                      where Value_ID__c =:valueId
                                             AND Product_Name__c=:prodtype
                                             And Aop_Name__c IN:selectedareaOfPracticeList]){
                           system.debug('inventory table records'+it);                  
                           aopNameVsLimit.put(it.Aop_Name__c,Integer.valueOf(it.Inv_Limit__c));  
                           system.debug('AOP Name '+aopNameVsLimit);                  
                 }
                
            }
            
            
        }
        
           // else condition and not added in abover inventory table condition handles here
             Integer count = prodVsMaxCount.get(selectedProdType);
            for(string sop:selectedareaOfPracticeList){
                if(!aopNameVsLimit.containsKey(sop)){
                    aopNameVsLimit.put(sop,count);
                }
                
            }
        
         // now looping through aopNameVsLIMIT and filling available in wrapper class
        for(string aop : aopNameVsLimit.keySet()){
            for(resultWrapper rsp :resultstoshow){
                if(rsp.areaofPractice == aop){
                    rsp.available = aopNameVsLimit.get(aop) - (rsp.sold + rsp.pend);
                    rsp.Maxcount = aopNameVsLimit.get(aop);
                }
                                                   
            }   
        }
            
      /********************************Available Logic Ends Here********************************************/
        
   
        
        return null;
        
        
    }
   
    public List<SelectOption> getdynamicStatelist(){
        system.debug('@@@@statestrings'+statestrings);
         List<SelectOption> options = new List<SelectOption>(); 
        If(statestrings != NULL){
            for(string st : statestrings.split(',')){
                 options.add(new SelectOption(st,st));
            }
        }
        return options;
    }
    
    
     public List<SelectOption> getdynamicCitylist(){
        system.debug('@@@@citystrings'+citystrings);
         List<SelectOption> options = new List<SelectOption>();
        If(citystrings != NULL){
            for(string st : citystrings.split(',')){
                 options.add(new SelectOption(st,st));
            }
        }
        return options;
    }
    
    
     public List<SelectOption> getdynamicCountylist(){
        system.debug('@@@@countystrings'+countytrings);
         List<SelectOption> options = new List<SelectOption>();
        If(countytrings != NULL){
            for(string st : countytrings.split(',')){
                 options.add(new SelectOption(st,st));
            }
        }
         system.debug('@@@@countystrings End '+countytrings);
        return options;
    }
    
    
        
    @Remoteaction @ReadOnly
    public static String refreshStateList(String cnt){ 
         List<String>initialStates = new List<String>();
        string statestring = '';
        system.debug('@@@@countryList'+cnt);
        List<string>cntList = cnt.split(',');
         dynamicStatelisttemp = new List<SelectOption>();
        if(cntList.size() == 0){
            dynamicStatelisttemp = new List<SelectOption>();
            
        }
        else if(cntList != null && !('').equals(cntList) ){
            system.debug('@@@@getLimitQueryRows()' + Limits.getQueryRows()); 
          
            String query = 'SELECT State_Abbrevation__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\'';
            String filter = '';  
            String filter2 ='';
            if(!cntList.isEmpty()){
                filter = filter + ' and CountryName__c IN:cntList ';
            }      
            
            filter = filter + ' AND State_Abbrevation__c!=NULL group by State_Abbrevation__c ';
            
          
           
            system.debug('@@@@query'+query + '  @@@Filter'+filter);
           
            AggregateResult[] groupedResults = Database.query(query+filter);
            
            //this integer to add comma not first time
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
                   // dynamicStatelisttemp.add(new SelectOption((String)ar.get('State_Abbrevation__c'),(String)ar.get('State_Abbrevation__c')));
                }
            }
          
            
            
            
        }
          system.debug('@@@dynamicStatelist'+statestring);
        return statestring;
    
        
        
        
    }
    
    @Remoteaction @ReadOnly
    public static String refreshcityList(String cnt, string st, string countyfromPage){ 
         List<String>initialStates = new List<String>();
        string citystring = '';
        system.debug('@@@@countryList'+cnt);
        system.debug('@@@@statelist'+st);
        system.debug('@@@@countyfromPage: '+countyfromPage);
        List<string>cntList     = cnt.split(',');
        List<string>stlist       = st.split(',');
         dynamicStatelisttemp = new List<SelectOption>();
        if(cntList.size() == 0){
            dynamicStatelisttemp = new List<SelectOption>();
            
        }
        else if(cntList != null && !('').equals(cntList) ){
            system.debug('@@@@getLimitQueryRows()' + Limits.getQueryRows()); 
            //Integer i = Limits.getQueryRows();
           /*  LIST<GEO_Location__c> gs= [SELECT State_Abbrevation__c FROM GEO_Location__c WHERE RecordType.DeveloperName='M_H_GEO_Locations'
                                                   and CountryName__c = 'USA' AND State_Abbrevation__c!=NULL 
                                                    LIMIT 5000];*/
            String query = 'SELECT City_Name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND City_Inv_Flag__c=\'Yes\'';
            String filter = '';  
           // String filter2 ='';
            if(!cntList.isEmpty()){
                filter = filter + ' and CountryName__c IN:cntList AND State_Abbrevation__c IN:stlist ';
            }
            
            if(countyfromPage != ' '){
                filter = filter + ' and County_Name__c != NULL and County_Name__c = \'Independent City\'';
            }
             //filter2 = filter;
            filter = filter + ' AND City_Name__c!=NULL group by City_Name__c ';
           
            system.debug('@@@@query'+query + '  @@@Filter'+filter);
             //filter = filter + ' LIMIT 50000';
            AggregateResult[] groupedResults = Database.query(query+filter);
            /*AggregateResult[] groupedResults =[SELECT City_Name__c FROM GEO_Location__c 
                                                WHERE RecordType.DeveloperName='M_H_GEO_Locations' 
                                                    and CountryName__c IN:cntList
                                                     AND City_Name__c!=NULL group by City_Name__c];*/
            
            //this integer to add comma not first time
            Integer i = 0;
            for(AggregateResult ar : groupedResults){
                String city = (String)ar.get('City_Name__c');
                if(city != null && city != ''){
                    if(i==0){
                        citystring += city;
                    }
                    else{
                       citystring += ','+city; 
                    }
                    i++;
                    if(i ==9999){
                        break;
                    }
                }
            }
          
            system.debug('@@@@support debug: '+i);
            
            
        }
          system.debug('@@@citystring'+citystring);
        return citystring;
      
        //return null;
        
        
        
    }
    
     @Remoteaction @ReadOnly
    public static String refreshcountyList(String cnt, string st){ 
         List<String>initialStates = new List<String>();
        string countystring = '';
        system.debug('@@@@countryList'+cnt);
        system.debug('@@@@countryList'+st);
        List<string>cntList     = cnt.split(',');
        List<string>stlist       = st.split(',');
         dynamicStatelisttemp = new List<SelectOption>();
        if(cntList.size() == 0){
            dynamicStatelisttemp = new List<SelectOption>();
            
        }
        else if(cntList != null && !('').equals(cntList) ){
            system.debug('@@@@getLimitQueryRows()' + Limits.getQueryRows()); 
            //Integer i = Limits.getQueryRows();
           /*  LIST<GEO_Location__c> gs= [SELECT State_Abbrevation__c FROM GEO_Location__c WHERE RecordType.DeveloperName='M_H_GEO_Locations'
                                                   and CountryName__c = 'USA' AND State_Abbrevation__c!=NULL 
                                                    LIMIT 5000];*/
            String query = 'SELECT County_Name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND County_Inv_Flag__c=\'Yes\'';
            String filter = '';  
           // String filter2 ='';
            if(!cntList.isEmpty()){
                filter = filter + ' and CountryName__c IN:cntList AND State_Abbrevation__c IN:stlist ';
            }      
             //filter2 = filter;
            filter = filter + ' AND County_Name__c!=NULL group by County_Name__c ';
           
            system.debug('@@@@query'+query + '  @@@Filter'+filter);
             //filter = filter + ' LIMIT 50000';
            AggregateResult[] groupedResults = Database.query(query+filter);
            /*AggregateResult[] groupedResults =[SELECT City_Name__c FROM GEO_Location__c 
                                                WHERE RecordType.DeveloperName='M_H_GEO_Locations' 
                                                    and CountryName__c IN:cntList
                                                     AND City_Name__c!=NULL group by City_Name__c];*/
            
            //this integer to add comma not first time
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
                   if(i ==9999){
                        break;
                    }
                }
            }
          
            
            
            
        }
          system.debug('@@@countystring'+countystring);
        return countystring;
      
        //return null;
        
        
        
    }
    
    
    
    
}