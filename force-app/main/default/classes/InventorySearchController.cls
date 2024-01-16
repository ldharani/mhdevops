global class InventorySearchController{
    public List<selectoption> areasOfPracticeList{get;set;}
    public String selectedareaOfPractice {get;set;}
    public String selectedProdType{get;set;}
    public list<selectoption> prodTypeList{get;set;}
    public string searchCountry {get;set;}
    public string searchState {get;set;}
    public string searchCounty {get;set;}
    public string searchCity {get;set;}
    public List<GEO_Location__c > geoLocationsList{get;set;}    
    
    public transient List<mainDataOuterClass> mainWrapperList{get;set;}
    public List<mainDataInnerClass> mainInnerList{get;set;}
    public Map<String,String> prodCodeMap {get;set;}
    private final Integer RECORDS_LIMIT_SIZE = 1000;
    private final String MSG_NUM_OF_RECORDS = 'Only first 1000 records are displayed. Please filter the data';
    
    public InventorySearchController(){        
        prodTypeList = new list<selectoption>();
        prodCodeMap = new Map<String,String>();
        List<Inventoried_Products_list_using_Product__c > iplist = Inventoried_Products_list_using_Product__c.getall().values();
        for(Inventoried_Products_list_using_Product__c ip: iplist){
            prodTypeList.add(new SelectOption(ip.Product_Name__c,ip.Product_Name__c));
            prodCodeMap.put(ip.Product_Name__c,ip.Product_Code__c);
        }        
        searchCountry = 'USA'; //default country 
        mainWrapperList = new List<mainDataOuterClass>();
        mainInnerList = new List<mainDataInnerClass>();
        selectedProdType = 'Lawyers.com Preferred Banner Placements';
        aOPListBasedOnProduct();
    }
    public void aOPListBasedOnProduct(){
        //system.debug('selectedProdType: '+selectedProdType);
        areasOfPracticeList = new list<selectoption>();        
        geoLocationsList = new List<GEO_Location__c>();
        String prodId = prodCodeMap.get(selectedProdType);
        //system.debug('prodId : '+prodId );
        String squery = 'select id,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c INCLUDES (\'' + prodId + '\') order by AOP_Name__c limit 1000';
        geoLocationsList = database.query(squery);
        for(GEO_Location__c geo:geoLocationsList ){
            areasOfPracticeList.add(new SelectOption(geo.AOP_Name__c ,geo.AOP_Name__c));
        }
        // To clear grey out field values on change of Product Type
        searchState = '';
        searchCounty = '';
        searchCity = '';        
    }    
    public PageReference resetParameters(){
        searchState = '';
        searchCounty = '';
        searchCity = '';
        selectedareaOfPractice = '';
        selectedProdType = '';
        mainWrapperList = new List<mainDataOuterClass>();
        mainInnerList = new List<mainDataInnerClass>();
        return null;
    }
    
    public PageReference runCountrySearch() {
        try {
        /*system.debug('selectedareaOfPractice: '+selectedareaOfPractice+' selectedProdType: '+selectedProdType);
        system.debug('searchCountry: '+searchCountry +' searchState: '+ searchState);
        system.debug('searchCounty: '+searchCounty +' searchCity:'+ searchCity);*/        
        mainWrapperList = new List<mainDataOuterClass>();        
        
        if(selectedProdType == 'Lawyers.com Preferred Banner Placements' || selectedProdType == 'Lawyers.com Preferred City Results' || selectedProdType == 'Lawyers.com Preferred County Results' || selectedProdType == 'Martindale.com Preferred County Results'){
            if(searchState == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Select State'));
                return null;
            }else{
                //DO NOTHING
            }
        }
        
        Set<Id> opptyIds = new Set<Id>(); //opptyIds
        Set<Id> opptyChargeIds = new Set<Id>(); //ORPCIds
        //Map<Id,boolean> InventoryIdMap = new Map<Id,boolean>();
        Set<String> cityList = new Set<String>();
        String flag = 'Yes';
        if(searchState != null && searchState != '' && searchCity == '' && selectedProdType == 'Lawyers.com Preferred City Results'){
            //system.debug('if query');
            List<aggregateResult> result = [SELECT City_Name__c FROM GEO_Location__c where State_Abbrevation__c =: searchState and City_Inv_Flag__c =: flag and RecordType.DeveloperName = 'M_H_GEO_Locations' Group by City_Name__c limit 1000];            
            for(AggregateResult a : Result) {
                if(a.get('City_Name__c') != null)
                cityList.add((String)a.get('City_Name__c'));
            }            
        }
        else if(searchState != null && searchState != '' && searchCounty == '' && (selectedProdType == 'Lawyers.com Preferred Banner Placements' || selectedProdType == 'Lawyers.com Preferred County Results'|| selectedProdType == 'Martindale.com Preferred County Results')){
            //cityList is CountyList here
            //system.debug('else if query');
            List<aggregateResult> result = [SELECT County_Name__c FROM GEO_Location__c where State_Abbrevation__c =: searchState and County_Inv_Flag__c =: flag and RecordType.DeveloperName = 'M_H_GEO_Locations' Group by County_Name__c limit 1000];            
            for(AggregateResult a : Result) {
                if(a.get('County_Name__c') != null)
                cityList.add((String)a.get('County_Name__c'));
            }
        }else if((searchState == null || searchState == '') && (selectedProdType == 'Preferred State Links' || selectedProdType == 'Lawyers.com Preferred State Results' || selectedProdType == 'Martindale.com Preferred State Results')){
            //cityList is StateList here
            List<aggregateResult> result = [SELECT State_Abbrevation__c FROM GEO_Location__c where CountryName__c =: searchCountry and State_Inv_Flag__c =: flag and RecordType.DeveloperName = 'M_H_GEO_Locations' Group by State_Abbrevation__c limit 1000];            
            for(AggregateResult a : Result) {
                if(a.get('State_Abbrevation__c') != null)
                cityList.add((String)a.get('State_Abbrevation__c'));
            }
        }
        //system.debug('cityList: '+cityList);
                  
        Map<String,mainDataOuterClass> mainMap = new Map<String,mainDataOuterClass>();
        list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOfOpptCharge = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        String strAOP = selectedProdType + ' AOP';
        Set<Id> filteredOpptyChargeIds = new Set<Id>();
        Map<Id,List<Opportunity_Charge_Attribute__c>> ocaMap = new Map<Id,List<Opportunity_Charge_Attribute__c>>();
        Map<Id,List<Order_Charge_Attribute__c>> orcaMap = new Map<Id,List<Order_Charge_Attribute__c>>();
        
        List<Opportunity_Charge_Attribute__c> ocaList = [SELECT id,Picklist_Value__c,Product_Type__c,Attribute_Name__c,Attribute_Type__c,Opportunity_Rate_Plan_Charge__c,
        String_Value__c FROM Opportunity_Charge_Attribute__c where Product_Type__c =: selectedProdType and (Attribute_Type__c = 'Picklist' and Picklist_Value__c =: selectedareaOfPractice)];
        
        //for(Opportunity_Charge_Attribute__c oAttribute:[SELECT id,Picklist_Value__c,Product_Type__c,Attribute_Name__c,Attribute_Type__c,Opportunity_Rate_Plan_Charge__c,
        //String_Value__c FROM Opportunity_Charge_Attribute__c where Product_Type__c =: selectedProdType and (Attribute_Type__c = 'Picklist' and Picklist_Value__c =: selectedareaOfPractice) ]){
        for(Opportunity_Charge_Attribute__c oAttribute:ocaList ){
            if(oAttribute.Attribute_Name__c == 'AOP' || oAttribute.Attribute_Name__c == strAOP)
            filteredOpptyChargeIds.add(oAttribute.Opportunity_Rate_Plan_Charge__c);
            
        }        
                        
        List<Opportunity_Charge_Attribute__c> ocaList1 = [SELECT id,Picklist_Value__c,Product_Type__c,Attribute_Name__c,Attribute_Type__c,Opportunity_Rate_Plan_Charge__c,
        String_Value__c FROM Opportunity_Charge_Attribute__c where Product_Type__c =: selectedProdType and (Attribute_Type__c = 'Text' and String_Value__c =: selectedareaOfPractice)];
        
        //for(Opportunity_Charge_Attribute__c oAttribute:[SELECT id,Picklist_Value__c,Product_Type__c,Attribute_Name__c,Attribute_Type__c,Opportunity_Rate_Plan_Charge__c,
        //String_Value__c FROM Opportunity_Charge_Attribute__c where Product_Type__c =: selectedProdType and (Attribute_Type__c = 'Text' and String_Value__c =: selectedareaOfPractice) ]){
        for(Opportunity_Charge_Attribute__c oAttribute:ocaList1 ){
            if(oAttribute.Attribute_Name__c == strAOP || oAttribute.Attribute_Name__c == 'AOP')
            filteredOpptyChargeIds.add(oAttribute.Opportunity_Rate_Plan_Charge__c);
        }              
        Set<String> attrNOTList = new Set<String>();
        attrNOTList.add('Service City');
        attrNOTList.add('Service Country');
        attrNOTList.add('Service State');
        attrNOTList.add('Service Account Name');
        attrNOTList.add('URL');
        
        List<Opportunity_Charge_Attribute__c> tocaList = [SELECT Picklist_Value__c, 
                                Attribute_Name__c,Attribute_Type__c,
                                Opportunity_Rate_Plan_Charge__c,String_Value__c 
                                FROM Opportunity_Charge_Attribute__c where Opportunity_Rate_Plan_Charge__c IN: filteredOpptyChargeIds
                                and Attribute_Name__c NOT IN: attrNOTList limit 10000];
        for(Opportunity_Charge_Attribute__c oAttribute:tocaList ){
            if(ocaMap.containsKey(oAttribute.Opportunity_Rate_Plan_Charge__c)){
                List<Opportunity_Charge_Attribute__c> ocatempList = ocaMap.get(oAttribute.Opportunity_Rate_Plan_Charge__c);
                ocatempList.add(oAttribute);
                ocaMap.put(oAttribute.Opportunity_Rate_Plan_Charge__c,ocatempList);               
            }else{
                List<Opportunity_Charge_Attribute__c> ocatempList = new List<Opportunity_Charge_Attribute__c>();
                ocatempList.add(oAttribute);
                ocaMap.put(oAttribute.Opportunity_Rate_Plan_Charge__c,ocatempList);                
            }
        }             
        
        //system.debug('ocaMap here:::'+ocaMap);
                                
        Set<Id> filteredOrderChargeIds = new Set<Id>();
        List<Order_Charge_Attribute__c> orcaList = [SELECT Picklist_Value__c,Name,Attribute_Name__c,
                                                    Attribute_Type__c,Order_Rate_Plan_Charge__c,
                                                    String_Value__c,Product_Type__c 
                                                    FROM Order_Charge_Attribute__c 
                                                    where Product_Type__c =: selectedProdType 
                                                    and (Attribute_Type__c = 'Picklist' 
                                                          and Picklist_Value__c =: selectedareaOfPractice)];
         
        //for(Order_Charge_Attribute__c oAttribute:[SELECT Picklist_Value__c,Name,Attribute_Name__c,Attribute_Type__c,Order_Rate_Plan_Charge__c,String_Value__c,Product_Type__c FROM Order_Charge_Attribute__c where Product_Type__c =: selectedProdType and (Attribute_Type__c = 'Picklist' and Picklist_Value__c =: selectedareaOfPractice) ]){
        for(Order_Charge_Attribute__c oAttribute : orcaList){
            if(oAttribute.Attribute_Name__c == 'AOP' || oAttribute.Attribute_Name__c == strAOP)
            filteredOrderChargeIds.add(oAttribute.Order_Rate_Plan_Charge__c);            
            
        }        
        
        List<Order_Charge_Attribute__c> orcaList1 = [SELECT Picklist_Value__c,Name,Attribute_Name__c,Attribute_Type__c,Order_Rate_Plan_Charge__c,String_Value__c,Product_Type__c FROM Order_Charge_Attribute__c where Product_Type__c =: selectedProdType and (Attribute_Type__c = 'Text' and String_Value__c =: selectedareaOfPractice)];
        
        //for(Order_Charge_Attribute__c oAttribute:[SELECT Picklist_Value__c,Name,Attribute_Name__c,Attribute_Type__c,Order_Rate_Plan_Charge__c,String_Value__c,Product_Type__c FROM Order_Charge_Attribute__c where Product_Type__c =: selectedProdType and (Attribute_Type__c = 'Text' and String_Value__c =: selectedareaOfPractice) ]){
        for(Order_Charge_Attribute__c oAttribute : orcaList1){
            if(oAttribute.Attribute_Name__c == strAOP || oAttribute.Attribute_Name__c == 'AOP')
            filteredOrderChargeIds.add(oAttribute.Order_Rate_Plan_Charge__c);            
        }                
        
        List<Order_Charge_Attribute__c> torcaList = [SELECT Picklist_Value__c,Name,Attribute_Name__c, Attribute_Type__c,Order_Rate_Plan_Charge__c,String_Value__c
                                   FROM Order_Charge_Attribute__c where Order_Rate_Plan_Charge__c IN: filteredOrderChargeIds
                                   and Attribute_Name__c NOT IN: attrNOTList limit 20000];
        for(Order_Charge_Attribute__c oAttribute: torcaList){
             List<Order_Charge_Attribute__c> orcatempList;
            if(orcaMap.containsKey(oAttribute.Order_Rate_Plan_Charge__c)){
                orcatempList = orcaMap.get(oAttribute.Order_Rate_Plan_Charge__c);
                orcatempList.add(oAttribute);                
            }else{
                orcatempList = new List<Order_Charge_Attribute__c >();
                orcatempList.add(oAttribute);                
            }            
            orcaMap.put(oAttribute.Order_Rate_Plan_Charge__c,orcatempList);   
        }
                                   
        listOfOpptCharge = [SELECT invoiceit_crmx__Opportunity_Rate_Plan__c,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c,
                             invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Product_SIN__c, invoiceit_crmx__Status__c, Created_From_Charge__c                           
                            FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                            WHERE  id IN: filteredOpptyChargeIds];                                                        
                            
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOPRCharge = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
                                    
        
        Set<Id> opptyChargswithoutChrgs = new Set<Id>(); 
        Set<String> uniqueIdSet = new Set<String>();
        Map<String,Set<Id>> testSetMap= new Map<String,Set<Id>>();
        Map<String,Set<Id>> testUniqMap= new Map<String,Set<Id>>();
        Map<Id,Set<Id>> oppChargeISNULLMap = new Map<Id,Set<Id>>();
        if(listOfOpptCharge != null && listOfOpptCharge.size() > 0){         
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge : listOfOpptCharge) {
                //added on 08/28/17 for Inv Id Bug
                if(charge.invoiceit_crmx__Status__c == 'Active'){
                    if(charge.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c != null && charge.Created_From_Charge__c == NULL){
                        if(!oppChargeISNULLMap.containsKey(charge.invoiceit_crmx__Opportunity__c)){                             
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.id);
                             oppChargeISNULLMap.put(charge.invoiceit_crmx__Opportunity__c,tempSet);                             
                         }else{
                             oppChargeISNULLMap.get(charge.invoiceit_crmx__Opportunity__c).add(charge.id);
                         }
                     }
                 }
                 String aop;
                 String city;
                 String state;
                 String country;
                 String county;
                 //system.debug('attrs ocaMap.get(charge.id):::'+ocaMap.get(charge.id));
                 if(ocaMap.containsKey(charge.id)){
                 for(Opportunity_Charge_Attribute__c charAtt : ocaMap.get(charge.id)) {                      
                      if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Picklist_Value__c != null && (charAtt.Attribute_Name__c == 'AOP' || charAtt.Attribute_Name__c == strAOP)) {
                          aop = charAtt.Picklist_Value__c;
                      }else if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && (charAtt.Attribute_Name__c == strAOP || charAtt.Attribute_Name__c == 'AOP')){
                          aop = charAtt.String_Value__c;
                      }
                      
                      if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Picklist_Value__c != null && charAtt.Attribute_Name__c == 'City') {
                          city = charAtt.Picklist_Value__c;
                      }else if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && charAtt.Attribute_Name__c == 'City'){
                          city = charAtt.String_Value__c;
                      }
                      
                      if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Picklist_Value__c != null && charAtt.Attribute_Name__c == 'State') {
                          state = charAtt.Picklist_Value__c;
                      }else if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && charAtt.Attribute_Name__c == 'State'){
                          state = charAtt.String_Value__c;
                      }
                      
                      if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && charAtt.Attribute_Name__c == 'Country') {
                          country = charAtt.String_Value__c;
                      }
                      if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Picklist_Value__c != null && charAtt.Attribute_Name__c == 'County') {
                          county = charAtt.Picklist_Value__c;
                      }else if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && charAtt.Attribute_Name__c == 'County'){
                          county = charAtt.String_Value__c;
                      }
                 }
                 }
                 /*system.debug('aop::::'+aop +':::selectedareaOfPractice::::'+selectedareaOfPractice);
                 system.debug('state::::'+state+':::searchState::::'+searchState);
                 system.debug('country::::'+country+':::searchCountry::::'+searchCountry);
                 system.debug('city::::'+city+':::searchCity::::'+searchCity);
                 system.debug('county::::'+county+':::searchCounty::::'+searchCounty);*/
                  
                 if(selectedareaOfPractice != null && searchCountry != null && searchState == '' && (searchCounty == '' || searchCity == '')){
                     //system.debug('in if');
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country)){
                         opptyIds.add(charge.invoiceit_crmx__Opportunity__c);
                         opptyChargeIds.add(charge.id);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         //system.debug('uniqueKey :::'+uniqueKey);
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         }                                              
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.id);                          
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.id);
                         }
                         
                     }else{
                         //String uniqueKey = (searchCity != null)? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
                         if(selectedProdType == 'Preferred National Links' || selectedProdType == 'Lawyers.com Preferred National Results'|| selectedProdType == 'Martindale.com Preferred National Results'){
                         String uniqueKey = searchState+'_'+searchCountry;
                         
                         //system.debug('uniqueKey :::'+uniqueKey);
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             //mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }
                         }
                     }                
                 }else if(selectedareaOfPractice != null && searchCountry != null && searchState != '' && (searchCounty == '' && searchCity == '')){
                     //system.debug('in else if --one');
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country) && searchState.equalsIgnoreCase(state)){
                         opptyIds.add(charge.invoiceit_crmx__Opportunity__c);
                         opptyChargeIds.add(charge.id);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         } 
                         //system.debug('uniqueKey :::'+uniqueKey);                     
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;                             
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.id);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                            
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.id);
                         }                         
                     }
                     else{
                         if(searchState != '' && ((searchCounty != '') && (searchCity == ''))){
                         String uniqueKey = searchState+'_'+searchCountry;
                         //system.debug('uniqueKey :::'+uniqueKey);                         
                                              
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             //mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                         
                         }
                         }
                         else if(selectedProdType == 'Lawyers.com Preferred State Results' || selectedProdType == 'Preferred State Links' || selectedProdType == 'Martindale.com Preferred State Results'){
                               String uniqueKey = searchState+'_'+searchCountry;
                             //system.debug('uniqueKey :::'+uniqueKey);                         
                                                  
                             if(!uniqueIdSet.contains(uniqueKey)){                         
                                 mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                                 //mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                                 mainOuterObj.state = searchState;
                                 mainOuterObj.country = searchCountry;
                                 mainOuterObj.chargeId = charge.id;//charge.Id;
                                 mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                                 uniqueIdSet.add(mainOuterObj.uniqueId);                         
                                 mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                             
                             }  
                         }
                     }                                                          
                     
                 }
                 else if(selectedareaOfPractice != null && searchCountry != null && searchState != '' && (searchCounty != '')){
                     //system.debug('in else if --two');
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country) && searchState.equalsIgnoreCase(state)
                         && (searchCounty.equalsIgnoreCase(county))){
                            opptyIds.add(charge.invoiceit_crmx__Opportunity__c);
                            opptyChargeIds.add(charge.id);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         }
                         //system.debug('uniqueKey :::'+uniqueKey);                     
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.id);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.id);
                         }
                     }else{
                         String uniqueKey = (searchCity != null && searchCity != '')? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
                         //system.debug('uniqueKey :::'+uniqueKey);                         
                                              
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (searchCity != null && searchCity != '')? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                         
                         }
                     }
                 }
                 
                 else if(selectedareaOfPractice != null && searchCountry != null && searchState != '' && (searchCity != '' && searchCity != null)){
                     //system.debug('in else if --three');
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country) && searchState.equalsIgnoreCase(state)
                          && searchCity.equalsIgnoreCase(city)){
                            opptyIds.add(charge.invoiceit_crmx__Opportunity__c);
                            opptyChargeIds.add(charge.id);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         }
                         //system.debug('uniqueKey :::'+uniqueKey);                     
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.id);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                         
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.id);
                         }
                     }else {
                         String uniqueKey = (searchCity != null)? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
                         //system.debug('uniqueKey :::'+uniqueKey);                         
                                              
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }
                     }
                 } 
                 else if(selectedareaOfPractice != null && searchCountry != null && searchState != '' && (searchCounty == null || searchCounty == '')){
                     //system.debug('in else if --four');
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country) && searchState.equalsIgnoreCase(state)
                         ){
                            opptyIds.add(charge.invoiceit_crmx__Opportunity__c);
                            opptyChargeIds.add(charge.id);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         //system.debug('uniqueKey :::'+uniqueKey);
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         }                     
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.id);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.id);
                         }
                     }else{ // No Match -- Show empty record
                         
                         String uniqueKey = (searchCity != null)? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
                         //system.debug('uniqueKey :::'+uniqueKey);
                                                                       
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.id;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                         
                         }
                     }
                 }            
            }
        }else{           
             String uniqueKey = (searchCity != null)? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
             //system.debug('uniqueKey :::'+uniqueKey);
             if(!uniqueIdSet.contains(uniqueKey)){                         
                 mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                 mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                 mainOuterObj.state = searchState;
                 mainOuterObj.country = searchCountry;
                 //mainOuterObj.chargeId = charge.invoiceit_crmx__Opportunity__c;//charge.Id;
                 mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                 uniqueIdSet.add(mainOuterObj.uniqueId);                         
                 mainMap.put(mainOuterObj.uniqueId,mainOuterObj);             
             }
        }
        
        if(searchState != null && searchState != '' && (selectedProdType == 'Lawyers.com Preferred Banner Placements' || selectedProdType == 'Lawyers.com Preferred City Results' || selectedProdType == 'Lawyers.com Preferred County Results'|| selectedProdType == 'Martindale.com Preferred County Results')){
            for(String s: cityList){
                String uniqueKey = (s!= null)? s+'_'+ searchState +'_'+searchCountry : searchCounty+'_'+ searchState +'_'+searchCountry;
                if(!uniqueIdSet.contains(uniqueKey)){                         
                     mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                     mainOuterObj.location = (s!= null)? s: searchCounty;
                     mainOuterObj.state = searchState ;
                     mainOuterObj.country = searchCountry;
                     //mainOuterObj.chargeId = charge.invoiceit_crmx__Opportunity__c;//charge.Id;
                     mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                     uniqueIdSet.add(mainOuterObj.uniqueId);                         
                     mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                 
                 }
            }
        }
        else if((searchState == null || searchState == '') && (selectedProdType == 'Preferred State Links' || selectedProdType == 'Lawyers.com Preferred State Results' || selectedProdType == 'Martindale.com Preferred State Results')){
            for(String s: cityList){
                String uniqueKey = searchState +'_'+ s +'_'+searchCountry;
                if(!uniqueIdSet.contains(uniqueKey)){                         
                     mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                     //mainOuterObj.location = (s!= null)? s: searchCounty;
                     mainOuterObj.state = s;
                     mainOuterObj.country = searchCountry;                     
                     mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                     uniqueIdSet.add(mainOuterObj.uniqueId);                         
                     mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                 
                 }
            }
        }
        //order changes 
        if(Test.isRunningTest()){       
            listOfOPRCharge = [SELECT Name,invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c,Opportunity_Rate_Plan_Charge__c                           
                                   FROM invoiceit_s__Job_Rate_Plan_Charge__c
                                   WHERE  Id IN: filteredOrderChargeIds LIMIT 1];  
                                   
        }
        
        else{
            listOfOPRCharge = [SELECT Name,invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c,Opportunity_Rate_Plan_Charge__c                           
                                   FROM invoiceit_s__Job_Rate_Plan_Charge__c
                                   WHERE  Id IN: filteredOrderChargeIds]; 
        }
        if(listOfOPRCharge != null && listOfOPRCharge.size() > 0){
            for(invoiceit_s__Job_Rate_Plan_Charge__c charge : listOfOPRCharge) {
                String aop;
                String city;
                String state;
                String country;
                String county;
                if(orcaMap.containsKey(charge.id)){
                for(Order_Charge_Attribute__c charAtt : orcaMap.get(charge.id)){ //charge.Order_Charge_Attributes__r) {
                    if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Picklist_Value__c != null && (charAtt.Attribute_Name__c == 'AOP' || charAtt.Attribute_Name__c == strAOP)) {
                          aop = charAtt.Picklist_Value__c;
                      }else if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && (charAtt.Attribute_Name__c == strAOP || charAtt.Attribute_Name__c == 'AOP')){
                          aop = charAtt.String_Value__c;
                      }
                      
                      if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Picklist_Value__c != null && charAtt.Attribute_Name__c == 'City') {
                          city = charAtt.Picklist_Value__c;
                      }else if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && charAtt.Attribute_Name__c == 'City'){
                          city = charAtt.String_Value__c;
                      }
                      
                      if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Picklist_Value__c != null && charAtt.Attribute_Name__c == 'State') {
                          state = charAtt.Picklist_Value__c;
                      }else if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && charAtt.Attribute_Name__c == 'State'){
                          state = charAtt.String_Value__c;
                      }
                      
                      if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && charAtt.Attribute_Name__c == 'Country') {
                          country = charAtt.String_Value__c;
                      }
                      if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Picklist_Value__c != null && charAtt.Attribute_Name__c == 'County') {
                          county = charAtt.Picklist_Value__c;
                      }else if(charAtt.Attribute_Type__c == 'Text' && charAtt.String_Value__c != null && charAtt.Attribute_Name__c == 'County'){
                          county = charAtt.String_Value__c;
                      }
                }
                }
                if(selectedareaOfPractice != null && searchCountry != null && searchState == '' && (searchCounty == '' || searchCity == '')){
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country)){
                         opptyIds.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                         opptyChargeIds.add(charge.Opportunity_Rate_Plan_Charge__c);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         //system.debug('uniqueKey :::'+uniqueKey);
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         }                                              
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);                          
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);
                         }
                         
                     }
                     else{
                         //String uniqueKey = (searchCity != null)? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
                         if(selectedProdType == 'Preferred National Links' || selectedProdType == 'Lawyers.com Preferred National Results' || selectedProdType == 'Martindale.com Preferred National Results'){
                         String uniqueKey = searchState+'_'+searchCountry;
                         
                         //system.debug('uniqueKey :::'+uniqueKey);
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             //mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }
                         }
                     }
                }else if(selectedareaOfPractice != null && searchCountry != null && searchState != '' && (searchCounty == '' && searchCity == '')){
                     
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country) && searchState.equalsIgnoreCase(state)){
                         opptyIds.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                         opptyChargeIds.add(charge.Opportunity_Rate_Plan_Charge__c);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         } 
                         //system.debug('uniqueKey :::'+uniqueKey);                     
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;                             
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                            
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);
                         }                         
                     }
                     else{
                         if(searchState != '' && ((searchCounty != '') && (searchCity == ''))){
                         String uniqueKey = searchState+'_'+searchCountry;
                         //system.debug('uniqueKey :::'+uniqueKey);                         
                                              
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             //mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                         
                         }
                         }
                         else if(selectedProdType == 'Lawyers.com Preferred State Results' || selectedProdType == 'Preferred State Links' || selectedProdType == 'Martindale.com Preferred State Results'){
                               String uniqueKey = searchState+'_'+searchCountry;
                             //system.debug('uniqueKey :::'+uniqueKey);                         
                                                  
                             if(!uniqueIdSet.contains(uniqueKey)){                         
                                 mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                                 //mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                                 mainOuterObj.state = searchState;
                                 mainOuterObj.country = searchCountry;
                                 mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                                 mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                                 uniqueIdSet.add(mainOuterObj.uniqueId);                         
                                 mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                             
                             }  
                         }
                     }                                                          
                     
                 }else if(selectedareaOfPractice != null && searchCountry != null && searchState != '' && (searchCounty != '')){
                     
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country) && searchState.equalsIgnoreCase(state)
                         && (searchCounty.equalsIgnoreCase(county))){
                            opptyIds.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                            opptyChargeIds.add(charge.Opportunity_Rate_Plan_Charge__c);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         }
                         //system.debug('uniqueKey :::'+uniqueKey);                     
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);
                         }
                     }else{
                         String uniqueKey = (searchCity != null && searchCity != '')? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
                         //system.debug('uniqueKey :::'+uniqueKey);                         
                                              
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (searchCity != null && searchCity != '')? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                         
                         }
                     }
                 }else if(selectedareaOfPractice != null && searchCountry != null && searchState != '' && (searchCity != '' && searchCity != null)){
                     
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country) && searchState.equalsIgnoreCase(state)
                          && searchCity.equalsIgnoreCase(city)){
                            opptyIds.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                            opptyChargeIds.add(charge.Opportunity_Rate_Plan_Charge__c);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         }
                         //system.debug('uniqueKey :::'+uniqueKey);                     
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                         
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);
                         }
                     }else {
                         String uniqueKey = (searchCity != null)? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
                         //system.debug('uniqueKey :::'+uniqueKey);                         
                                              
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }
                     }
                 }else if(selectedareaOfPractice != null && searchCountry != null && searchState != '' && (searchCounty == null || searchCounty == '')){
                     //system.debug('in else if --four');
                     if(selectedareaOfPractice.equalsIgnoreCase(aop) && searchCountry.equalsIgnoreCase(country) && searchState.equalsIgnoreCase(state)
                         ){
                            opptyIds.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                            opptyChargeIds.add(charge.Opportunity_Rate_Plan_Charge__c);
                         String uniqueKey = (city != null)? city+'_'+ state+'_'+country : county+'_'+ state+'_'+country;
                         //system.debug('uniqueKey :::'+uniqueKey);
                         if(testSetMap.containsKey(uniqueKey)){
                             Set<Id> tempSet = testSetMap.get(uniqueKey);
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }else{
                             Set<Id> tempSet = new Set<Id>();
                             tempSet.add(charge.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                             testSetMap.put(uniqueKey,tempSet);
                         }
                         if(!testUniqMap.containsKey(uniqueKey)){                             
                             Set<Id> tempSet = new Set<Id>();                             
                             testUniqMap.put(uniqueKey,tempSet);                             
                         }                     
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (city != null)? city : county;
                             mainOuterObj.state = state;
                             mainOuterObj.country = country;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);                         
                         }else{
                             testUniqMap.get(uniqueKey).add(charge.Opportunity_Rate_Plan_Charge__c);
                         }
                     }else{ // No Match -- Show empty record
                         
                         String uniqueKey = (searchCity != null)? searchCity +'_'+ searchState+'_'+searchCountry: searchCounty+'_'+ searchState+'_'+searchCountry;
                         //system.debug('uniqueKey :::'+uniqueKey);
                                                                       
                         if(!uniqueIdSet.contains(uniqueKey)){                         
                             mainDataOuterClass mainOuterObj = new mainDataOuterClass();
                             mainOuterObj.location = (searchCity != null)? searchCity : searchCounty;
                             mainOuterObj.state = searchState;
                             mainOuterObj.country = searchCountry;
                             mainOuterObj.chargeId = charge.Opportunity_Rate_Plan_Charge__c;//charge.Id;
                             mainOuterObj.uniqueId = mainOuterObj.location+'_'+mainOuterObj.state+'_'+mainOuterObj.country;
                             uniqueIdSet.add(mainOuterObj.uniqueId);                         
                             mainMap.put(mainOuterObj.uniqueId,mainOuterObj);
                         
                         }
                     }
                 }
                
            }
        }
        //order changes
        
        /*system.debug('testSetMap:::'+testSetMap);
        system.debug('uniqueIdSet:::'+uniqueIdSet);
        system.debug('opptyIds here:::>>>'+opptyIds);*/
        //system.debug('opptyChargeIds here:::>>>'+opptyChargeIds);
        List<Opportunity> opptyList = new  list<Opportunity>();
         if(Test.isRunningTest()){
            opptyList = [select id,Name,Account.Name,Account.MH_Cust_Number__c,Release_Inventory_Date__c                
                 FROM Opportunity where Id IN: opptyIds  LIMIT 1];
        }
        
        else{
            opptyList = [select id,Name,Account.Name,Account.MH_Cust_Number__c,Release_Inventory_Date__c                
                 FROM Opportunity where Id IN: opptyIds ];
        }
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        for(Opportunity op:opptyList){
            oppMap.put(op.id,op);
        }
        Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>> oppJobMap = new Map<Id,List<invoiceit_s__Job_Rate_Plan_Charge__c>>(); //oppId,List<Job>
        
        Set<Id> orderIds = new Set<Id>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> ordrList = [select id,invoiceit_s__Status__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__c,invoiceit_s__Order__r.OrderNumber__c,invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c from invoiceit_s__Job_Rate_Plan_Charge__c where Opportunity_Rate_Plan_Charge__c IN: opptyChargeIds and Opportunity_Rate_Plan_Charge__c != null];
        //for(invoiceit_s__Job_Rate_Plan_Charge__c ordr: [select id,invoiceit_s__Status__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__c,invoiceit_s__Order__r.OrderNumber__c,invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c from invoiceit_s__Job_Rate_Plan_Charge__c where Opportunity_Rate_Plan_Charge__c IN: opptyChargeIds and Opportunity_Rate_Plan_Charge__c != null]){ //invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c IN: opptyIds]){
        for(invoiceit_s__Job_Rate_Plan_Charge__c ordr: ordrList){
            orderIds.add(ordr.invoiceit_s__Order__c);        
        }
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> ordrList1 = [select id,invoiceit_s__Status__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__c,invoiceit_s__Order__r.OrderNumber__c,invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c,Opportunity_Rate_Plan_Charge__c,invoiceit_s__Order__r.Created_From_Order__c from invoiceit_s__Job_Rate_Plan_Charge__c where Opportunity_Rate_Plan_Charge__c IN: opptyChargeIds AND (invoiceit_s__Order__c IN: orderIds OR invoiceit_s__Order__r.Created_From_Order__c IN: orderIds)];
        //for(invoiceit_s__Job_Rate_Plan_Charge__c ordr: [select id,invoiceit_s__Status__c,invoiceit_s__Service_End_Date__c,invoiceit_s__Order__c,invoiceit_s__Order__r.OrderNumber__c,invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c,Opportunity_Rate_Plan_Charge__c,invoiceit_s__Order__r.Created_From_Order__c from invoiceit_s__Job_Rate_Plan_Charge__c where Opportunity_Rate_Plan_Charge__c IN: opptyChargeIds AND (invoiceit_s__Order__c IN: orderIds OR invoiceit_s__Order__r.Created_From_Order__c IN: orderIds)]){
        for(invoiceit_s__Job_Rate_Plan_Charge__c ordr: ordrList1 ){ 
            List<invoiceit_s__Job_Rate_Plan_Charge__c> tempList;
            if(oppJobMap.containsKey(ordr.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c)){
                tempList = oppJobMap.get(ordr.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c);
                tempList.add(ordr);
            }else{
                tempList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
                tempList.add(ordr);
            }
            oppJobMap.put(ordr.invoiceit_s__Order__r.invoiceit_crmx__Opportunity__c,tempList);
        }
        
        //system.debug('oppJobMap here'+oppJobMap);
        //system.debug('map here'+mainMap);
        //system.debug('testSetMap here'+testSetMap);
        //system.debug('testUniqMap here:::'+testUniqMap);
        //for(Opportunity opp:opptyList){
        for(String str:uniqueIdSet){
            mainInnerList = new List<mainDataInnerClass>();
            Integer soldCount = 0;
            Integer pendingCount = 0;
            mainDataOuterClass mainOuterObj = mainMap.get(str);
            Set<Id> chargeIDSet = testUniqMap.get(str);
            Set<Id> oppIdExistsMap = new Set<Id>();
            if(testSetMap.containsKey(mainOuterobj.uniqueId)){
            for(id oppId : testSetMap.get(mainOuterobj.uniqueId)){
                Opportunity opp = oppMap.get(oppId);
                if(opp != null){
                Set<Id> isNullChargeIds = new Set<Id>();
                //system.debug('opp here'+opp);
                if(oppChargeISNULLMap != null && oppChargeISNULLMap.containsKey(opp.id)){
                    isNullChargeIds = oppChargeISNULLMap.get(opp.id);
                }                
                
                if(oppJobMap.containsKey(opp.id)){                    
                    List<invoiceit_s__Job_Rate_Plan_Charge__c> jobList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
                    jobList = oppJobMap.get(opp.id);
                    if(jobList.size() > 0){
                        Set<Id> uniqueOrderIdSet = new Set<Id>();
                        for(invoiceit_s__Job_Rate_Plan_Charge__c j:jobList){
                            //system.debug('mainOuterobj.chargeId::::'+mainOuterobj.chargeId);
                            //system.debug('---id Opportunity_Rate_Plan_Charge__c---'+j.Opportunity_Rate_Plan_Charge__c);
                            
                            if(chargeIDSet.contains(j.Opportunity_Rate_Plan_Charge__c)){
                                
                            if(j.invoiceit_s__Status__c == 'Active' || j.invoiceit_s__Status__c == 'Evergreen'){
                                mainDataInnerClass innerObj = new mainDataInnerClass();
                                innerObj.customer = opp.Account.MH_Cust_Number__c;
                                innerObj.customerName = opp.Account.Name;
                                innerObj.status = 'Sold'; 
                                innerObj.orderOpportunity = j.invoiceit_s__Order__r.OrderNumber__c;
                                innerObj.orderOpportunityId = j.invoiceit_s__Order__c;
                                //innerObj.releaseDate = opp.Release_Inventory_Date__c;
                                mainInnerList.add(innerObj);
                                soldCount++;
                                uniqueOrderIdSet.add(j.invoiceit_s__Order__c);
                            }
                            else if(j.invoiceit_s__Status__c == 'Cancelled' || j.invoiceit_s__Status__c == 'Truncated'){
                                if(j.invoiceit_s__Service_End_Date__c >= system.today()){
                                    mainDataInnerClass innerObj = new mainDataInnerClass();
                                    innerObj.customer = opp.Account.MH_Cust_Number__c;
                                    innerObj.customerName = opp.Account.Name;
                                    innerObj.status = 'Sold'; 
                                    innerObj.orderOpportunity = j.invoiceit_s__Order__r.OrderNumber__c;
                                    innerObj.orderOpportunityId = j.invoiceit_s__Order__c;
                                    //innerObj.releaseDate = opp.Release_Inventory_Date__c;
                                    mainInnerList.add(innerObj);
                                    soldCount++;
                                    uniqueOrderIdSet.add(j.invoiceit_s__Order__c);
                                }                               
                            }
                            
                            }// if close idset check
                        }
                    } 
                }
                else{                    
                    if(isNullChargeIds != null){
                        for(Id cid: isNullChargeIds){ 
                            if(chargeIDSet.contains(cid) && !oppIdExistsMap.contains(opp.id)){
                                mainDataInnerClass innerObj = new mainDataInnerClass();
                                innerObj.customer = opp.Account.MH_Cust_Number__c;
                                innerObj.customerName = opp.Account.Name;
                                innerObj.status = 'Pending'; 
                                innerObj.orderOpportunity = opp.Name;
                                innerObj.orderOpportunityId = opp.id;
                                innerObj.releaseDate = opp.Release_Inventory_Date__c;
                                mainInnerList.add(innerObj);
                                pendingCount++;
                                oppIdExistsMap.add(opp.id);
                            }
                        }
                    }
                }
                
                }
                }// for opp != null close
            } //if close
            mainOuterObj.sold = soldCount;
            mainOuterObj.pending = pendingCount;
            mainInnerList.sort(); //sort order to show first
            
            mainOuterObj.innerList = mainInnerList;
            if(mainWrapperList.size() < RECORDS_LIMIT_SIZE)
            mainWrapperList.add(mainOuterObj);           
            
        }
        mainWrapperList.sort();
        if(mainWrapperList.size() == RECORDS_LIMIT_SIZE)
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,MSG_NUM_OF_RECORDS));
        
        //system.debug('mainWrapperList here'+mainWrapperList.size());
        } catch (Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()+':'+e.getLineNumber()));
        }
        return null;
    }
       
   global class mainDataOuterClass implements Comparable{                     
        
        public String location{get;set;}
        public String state{get;set;}
        public String country{get;set;}
        public Integer sold{get;set;}
        public Integer pending{get;set;}
        public String chargeId {get;set;}
        public String uniqueId {get;set;}
        public List<mainDataInnerClass> innerList{get;set;}
        
        global Integer compareTo(Object ObjToCompare) {
                        
            if(location != '' && location != null)
            return location.CompareTo(((mainDataOuterClass)ObjToCompare).location );
            else
            return state.CompareTo(((mainDataOuterClass)ObjToCompare).state);
        }
    }
    global class mainDataInnerClass implements Comparable{                     
        public String customer{get;set;}
        public String customerName{get;set;}
        public String status{get;set;}
        public String orderOpportunity{get;set;}
        public String orderOpportunityId{get;set;}
        public Date releaseDate{get;set;}                 
        
        global Integer compareTo(Object ObjToCompare) {                      
            mainDataInnerClass compareToRec = (mainDataInnerClass)ObjToCompare;
                        
            if (status  == compareToRec.status && customerName  == compareToRec.customerName) return 0;
            if (status  == compareToRec.status && customerName  > compareToRec.customerName) return 1;
            if (status  == compareToRec.status && customerName  < compareToRec.customerName) return -1;
            if (status  < compareToRec.status) return 1;            
            return -1;
        }            
    }
}