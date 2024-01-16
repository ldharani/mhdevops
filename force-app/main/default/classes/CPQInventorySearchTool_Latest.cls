/*****
Class Name: CPQ_InventorySearchNew
Created by: IJ for Search Inventory Page
****/
public class CPQInventorySearchTool_Latest{
    public List<selectoption> areasOfPracticeList{get;set;}
    public String selectedareaOfPractice {get;set;}
    public String selectedProdType{get;set;}
    public list<ProdTypeWrapper> prodTypeList{get;set;}
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
    public static  List<String> cityList {get;set;}
    public static  List<String> countyList {get;set;}
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
    
    public boolean addRelatedAOP{get;set;}
    public boolean disableCity{get;set;}
    public boolean disableState{get;set;}
    public boolean disableCounty{get;set;}
    //public List<SelectOption> countryList{get;set;}
    public List<String> countryList1{get;set;}
    public Boolean containsCity{get;set;}
    public       Boolean containsState{get;set;}
    public       Boolean containsCounty{get;set;}
    public String aop{get;set;}
    public String productCode{get;set;}
    public String countyId{get;set;}
    public String cityId{get;set;}
    public String stateId{get;set;}
    public String countryId{get;set;}
    
    // Cart
    public static  String selCartId {get;set;}
    public List<SelectOption> cartList {get; set;}
    public Map<String,List<ResultClass>> finalResultsTemp {get;set;}
    
    public void getRenderPageBlockTable(){
        //creating a new List to hold the records which exists in map
        
        
        List<String> tempSelectedProducts = new List<String>();  
        System.debug(selectedProductTypes);
        System.debug(finalResults);
        tempSelectedProductTypes.addAll(selectedProductTypes);
        System.debug(initialSelectedProductTypes);
        initialSelectedProductTypes.addAll(selectedProductTypes);
        initialSelectedProductTypes.addAll(indSelectedProductTypes);
        
        System.debug(initialSelectedProductTypes);
        if(finalResults != null && finalResults.size()>0){
            //looping the list of records displayed in VF page                                
            for(String s: selectedProductTypes){
                //checking if all the records are in the Map
                if(finalResults.containsKey(s)){
                    //If yes, adding it to a new list. 
                    tempSelectedProducts.add(s);
                }
            }
            
            
            
            //clearing the original list first
            selectedProductTypes.clear();
            //adding the from original list to the original list*
            selectedProductTypes.addAll(tempSelectedProducts);
            System.debug(selectedProductTypes);
            System.debug(finalResults);
            /*    return true;}
else{
return false;
}*/
        }
        
    }
    public Integer SizeOfMap { get { 
        if(finalResults != null){
            return finalResults.size();}
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
            'Martindale.com Preferred State Results' => 'MDC Preferred State Results',
            'Lawyers.com Spanish Preferred State Results' => 'LDC Spanish Preferred State Results'
            };
               
    
    
    public CPQInventorySearchTool_Latest(){ 
       
        countryList = new List<String>{'USA'};
        defaultCountry = 'USA';
        finalResults =  new Map<String,List<ResultClass>>();
        finalResultsTemp = new Map<String,List<ResultClass>>();
        searchCount = new Map<String,Integer>();
        disableCity = false;
        system.debug('disableCity '+disableCity);
        disableState = false;
        disableCounty = false;
        selectAll = true;
        prodTypeList = new list<ProdTypeWrapper>();
        prodCodeMap = new Map<String,String>();
        dynamicStatelisttemp = new List<SelectOption>();
        addRelatedAOP = false;
        selectedProdCount = 'Select Product Types';
        prodTypeList = getProdTypeList();
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
        
        aOPListBasedOnProduct();
        
        String query = 'SELECT CountryName__c FROM GEO_Location__c '+
            ' WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\'' +
            ' and (CountryName__c =\'USA\' or CountryName__c = \'Canada\') Group by CountryName__c order by CountryName__c  ASC ';
        AggregateResult[] groupedResults = Database.query(query);
        dynamicCountrylist = new List<SelectOption>();
        for(AggregateResult ar : groupedResults){
            if(ar.get('CountryName__c') != null && ar.get('CountryName__c') != '')
                dynamicCountrylist.add(new SelectOption((String)ar.get('CountryName__c'),(String)ar.get('CountryName__c')));
        }
        
        // START -- Search Cart
        String soql = 'SELECT ';
        soql += queryAllFields('Cart__c') + ', ';
        soql += '(SELECT Id FROM Cart_Line_Items__r) ';
        soql += ' FROM Cart__c ORDER BY Createddate DESC';
        List<Cart__c> lstCart = Database.query(soql);
        cartList = new List<SelectOption>();
        cartList.add(new SelectOption('', '-- None --'));
        for(Cart__c c: lstCart){
            cartList.add(new SelectOption(c.Id, c.Name));
        }
        // END -- Search Cart
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
                prodTypeList.add(new ProdTypeWrapper(ipmap.get(num).Product_Name__c,ipmap.get(num).Product_Code__c,true));
                prodCodeMap.put(ipmap.get(num).Product_Name__c,ipmap.get(num).Product_Code__c);
           } 
        }  
        
        System.debug(prodTypeList);
        return prodTypeList; 
        
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
        System.debug('aOPListBasedOnProduct');
        
        areasOfPracticeList = new list<selectoption>();
        selectedareaOfPracticeList = new List<String>();
        selectedProductTypes = new list<String>(); 
       // geoLocationsList = new List<GEO_Location__c>();
        Set<String> aopValues = new Set<String>();
        Set<String> prodIds = new Set<String>();
        Integer count = 0;
        selectedProductStrings = '';
        containsCity = false;
        containsState = false;
        containsCounty = false;
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
                if(pt.Name.contains('City')  || pt.Name.contains('Banner')){
                    containsCity = true;
                }
                if(pt.Name.contains('State') || pt.Name.contains('Banner') ){
                    containsState = true;
                }
                if(pt.Name.contains('County')  || pt.Name.contains('Banner') ){
                    containsCounty = true;
                }
                
               
        }
        }
        
        if(containsCity == false){
            disableCity = true;
            
        }
        if(containsState == false && containsCity == false && containsCounty == false){
            disableState = true;
        }

        if(containsCounty == false){
            disableCounty = true;
        }
        
        if(prodIds != null){
            system.debug('@@@@prodIds'+prodIds);
            system.debug('@@@@disableState'+disableState);
            system.debug('@@@@disableCity'+disableCity);
            system.debug('@@@@disableCounty'+disableCounty);
            system.debug('@@@@renderState'+containsCity);
            system.debug('@@@@containsCounty'+containsCounty);
            system.debug('@@@@containsState'+containsState);
            
            //system.debug('prodId : '+prodId );
            
            //for(String prod :prodIds){
                //String squery = 'select id,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c INCLUDES (\'' + prod + '\') order by AOP_Name__c limit 1000';
               // String squery = 'select id,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c != null and AOP_Name__c != null order by AOP_Name__c limit 1000';
               // geoLocationsList = database.query(squery);
                for(GEO_Location__c geo: [select id,AOP_List_value__c,AOP_Name__c from GEO_Location__c where AOP_List_value__c != null and AOP_Name__c != null order by AOP_Name__c limit 1000] ){
                    aopValues.add(geo.AOP_Name__c);
                    
                //}
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
        prodTypeList = getProdTypeList();
        resultstoshow = new List<ResultClass>();
        finalResults = new Map<String,List<ResultClass>>();
        searchCount = new Map<String,Integer>();
        for(ProdTypeWrapper p :prodTypeList){
            p.isSelected = true;
        }
        return null;
    }
    
    public PageReference createCart(){
        finalResults = finalResultsTemp;
        if(finalResults != null && !finalResults.isEmpty()){
            
            List<Product2> productList = [SELECT Id, Name, (SELECT Id, AttributeName__c, AttributeType__c, ShowinDocuSign__c, SecondaryAttributeName__c, Required__c, Attribute_Picklist_Values__c, AttributeConfiguration__r.Name FROM Product_Attributes__r) FROM Product2 WHERE Name IN: finalResults.keyset()];
            
            if(!productList.isEmpty()){
                Map<String, ProductAttribute__c> mapProductAttribute = new Map<String, ProductAttribute__c>();
                for(Product2 pr: productList){
                    for(ProductAttribute__c pa: pr.Product_Attributes__r){
                        mapProductAttribute.Put(pr.Id + '___' + pa.AttributeName__c, pa);
                    }
                }
                List<Attribute_Lines__c> ALInsert = new List<Attribute_Lines__c>();
                Map<Id, Id> mapProductWithAR = new Map<Id, Id>();
                
                Cart__c newCart = new Cart__c();
                if(selCartId != null && selCartId != ''){
                    newCart.Id = selCartId;
                }else{
                    newCart.Inventory_Status__c = 'New';
                }
                upsert newCart;
                
                for(Product2 pr: productList){
                    Attribute_Relationship__c objAR = new Attribute_Relationship__c();
                    insert objAR;
                    mapProductWithAR.Put(pr.Id, objAR.Id);
                    for(ResultClass rc: finalResults.get(pr.Name)){
                        if(mapProductAttribute.containsKey(pr.Id + '___AOP')){
                            ProductAttribute__c objPA = mapProductAttribute.get(pr.Id + '___AOP');
                            Attribute_Lines__c objAL = new Attribute_Lines__c();
                            objAL.Product_Attribute__c = objPA.Id;
                            objAL.Attribute_Junction__c = objAR.Id;
                            objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                            objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                            objAL.Required__c = objPA.Required__c;
                            objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                            objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                            objAL.Attribute_Type__c = objPA.AttributeType__c;
                            objAL.String_Value__c = rc.aop;
                            ALInsert.add(objAL);
                        }
                        if(mapProductAttribute.containsKey(pr.Id + '___Service City')){
                            ProductAttribute__c objPA = mapProductAttribute.get(pr.Id + '___Service City');
                            Attribute_Lines__c objAL = new Attribute_Lines__c();
                            objAL.Product_Attribute__c = objPA.Id;
                            objAL.Attribute_Junction__c = objAR.Id;
                            objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                            objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                            objAL.Required__c = objPA.Required__c;
                            objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                            objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                            objAL.Attribute_Type__c = objPA.AttributeType__c;
                            objAL.String_Value__c = rc.city;
                            ALInsert.add(objAL);
                        }
                        if(mapProductAttribute.containsKey(pr.Id + '___County')){
                            ProductAttribute__c objPA = mapProductAttribute.get(pr.Id + '___County');
                            Attribute_Lines__c objAL = new Attribute_Lines__c();
                            objAL.Product_Attribute__c = objPA.Id;
                            objAL.Attribute_Junction__c = objAR.Id;
                            objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                            objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                            objAL.Required__c = objPA.Required__c;
                            objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                            objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                            objAL.Attribute_Type__c = objPA.AttributeType__c;
                            objAL.String_Value__c = rc.County;
                            ALInsert.add(objAL);
                        }
                        if(mapProductAttribute.containsKey(pr.Id + '___Service State')){
                            ProductAttribute__c objPA = mapProductAttribute.get(pr.Id + '___Service State');
                            Attribute_Lines__c objAL = new Attribute_Lines__c();
                            objAL.Product_Attribute__c = objPA.Id;
                            objAL.Attribute_Junction__c = objAR.Id;
                            objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                            objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                            objAL.Required__c = objPA.Required__c;
                            objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                            objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                            objAL.Attribute_Type__c = objPA.AttributeType__c;
                            objAL.Picklist_Value__c = rc.state;
                            ALInsert.add(objAL);
                        }
                        if(mapProductAttribute.containsKey(pr.Id + '___Service Country')){
                            ProductAttribute__c objPA = mapProductAttribute.get(pr.Id + '___Service Country');
                            Attribute_Lines__c objAL = new Attribute_Lines__c();
                            objAL.Product_Attribute__c = objPA.Id;
                            objAL.Attribute_Junction__c = objAR.Id;
                            objAL.Attribute_Name__c = objPA.AttributeConfiguration__r.Name;
                            objAL.Attribute_Picklist_Values__c = objPA.Attribute_Picklist_Values__c;
                            objAL.Required__c = objPA.Required__c;
                            objAL.Secondary_Attribute_Name__c = objPA.SecondaryAttributeName__c;
                            objAL.Show_in_Docusign__c = objPA.ShowinDocuSign__c;
                            objAL.Attribute_Type__c = objPA.AttributeType__c;
                            objAL.String_Value__c = rc.Country;
                            ALInsert.add(objAL);
                        }
                    }
                }
                if(!ALInsert.isEmpty()){
                    insert ALInsert;
                }
                
                List<Cart_Line_Item__c> newCLIList = new List<Cart_Line_Item__c>();
                for(Product2 prd: productList){
                    Cart_Line_Item__c newCLI = new Cart_Line_Item__c();
                    newCLI.Name = prd.Name;
                    newCLI.Cart__c = newCart.Id;
                    newCLI.Product__c = prd.Id;
                    if(mapProductWithAR != null && mapProductWithAR.containsKey(prd.Id)){
                        newCLI.Attribute_Relationship__c = mapProductWithAR.get(prd.Id);
                    }
                    newCLIList.add(newCLI);
                }
                if(!newCLIList.isEmpty()){
                    insert newCLIList;
                }
                PageReference pr = new PageReference('/'+newCart.Id);
                return pr;
            }
        }
        return null;
    }
    
    public PageReference runsearch(){
        
        statecitylist = new List<string>();
        countryList1 = new List<String>();
        System.debug(StateList);
        System.debug(citylist);
        System.debug(countyList);
        System.debug('selectedProductTypes'+selectedProductTypes);
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
        /*********************County Result Logic***************************************/ 
        If(selectedProductTypes.contains('Lawyers.com Preferred County Results')
           || selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements')
           || selectedProductTypes.contains('Lawyers.com Preferred Banner Placements')
           || selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results')
           || selectedProductTypes.contains('Lawyers.com Shared County Results')
           || selectedProductTypes.contains('Martindale.com Preferred County Results')
          ){
              System.debug('statecitylist4'+statecitylist);
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
                  statecitylist.add(string.valueOf(ag.get('County_Name__c')) + ' Co.'+','+ string.valueOf(ag.get('State_Abbrevation__c'))+','+string.valueOf(ag.get('CountryName__c')));
              }    
              System.debug('statecitylist4'+statecitylist);
              statecitylist.sort(); 
              
              
          }
        System.debug(statecitylist);
        /*********************City Result Logic***************************************/ 
        If(selectedProductTypes.contains('Lawyers.com Preferred City Results')
           || (selectedProductTypes.contains('Lawyers.com Preferred Banner Placements')
               && independentCounty)
           || (selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results')
               && independentCounty)
          ){
              System.debug('statecitylist3'+statecitylist);
              string query = 'Select CountryName__c, County_Name__c,State_Abbrevation__c,City_Name__c '+
                  ' From GEO_Location__c '+
                  ' where CountryName__c IN:countryList AND State_Abbrevation__c IN:StateList ';
              
             /* if(independentCounty){
                  query  +=  '  and County_Name__c != NULL'; //and County_Name__c = \'Independent City\'';      
              }else{
                  
              }*/
              System.debug(countryList);
              System.debug(StateList);
              System.debug(cityList);
              if(cityList != NULL && !cityList.isEmpty()){
                  
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
        If(selectedProductTypes.contains('Lawyers.com Preferred State Results')
           || selectedProductTypes.contains('Preferred State Links')
           || selectedProductTypes.contains('Lawyers.com Spanish Preferred State Results')
           || selectedProductTypes.contains('Martindale.com Preferred State Results')){
               System.debug('statecitylist2'+statecitylist);
               string query = 'Select CountryName__c, State_Abbrevation__c '+
                   ' From GEO_Location__c '+
                   ' where CountryName__c IN:countryList ';
               If(StateList != NULL  && !StateList.isEmpty()){
                   query += ' AND State_Abbrevation__c IN:StateList ';
                   
               }
               query += '  AND State_Abbrevation__c != NULL '+
                   ' Group by CountryName__c,State_Abbrevation__c ';
               for(aggregateResult ag: database.query(query)){
                   Boolean flag = false;
                   if(statecitylist.size()>0){
                       for(String str:statecitylist){
                           
                           if(str.contains(string.valueOf(ag.get('State_Abbrevation__c')) +','+ string.valueOf(ag.get('CountryName__c'))) == true){
                               flag = true;
                               
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
        If(selectedProductTypes.contains('Lawyers.com Preferred National Results')
           || selectedProductTypes.contains('Martindale.com Preferred National Results')
           || selectedProductTypes.contains('Lawyers.com Spanish Preferred National Results')
           || selectedProductTypes.contains('Preferred National Links')
           || selectedProductTypes.contains('Lawyers.com Shared National Results')
          ){
              
              for(String s : countryList){
                  Boolean flag = false;
                  if(statecitylist.size()>0){
                      for(String str:statecitylist){
                          if(str.contains(s) == true){
                              flag = true;
                              
                          }
                      }
                  }
                  if(flag == false){
                      statecitylist.add(s);
                  }
                  
              }
              statecitylist.sort();
          }
        System.debug(statecitylist);
        /******************************************************************************/
        
        
        
        system.debug('disableCity '+disableCity);
        /*******************************************************************************************/
        
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
        String strAOP = selectedProdType + ' AOP';
        Set<Id> filteredOrderProductIds = new Set<Id>();
        Set<Id> searchfilteredOrderChargeIds = new Set<Id>();
        Set<Id> filteredQuotelineIds = new Set<Id>();
        Set<Id> searchfilteredOptyChargeIds = new Set<Id>();
        System.debug(initialSelectedProductTypes);
        System.debug(indSelectedProductTypes);
        System.debug(selectedProductTypes);
        if(initialSelectedProductTypes.size()>0){
            for(String s:initialSelectedProductTypes){
                if(selectedProductTypes.contains(s) != true){
                  selectedProductTypes.add(s);
                }
            }
        }
        if(indSelectedProductTypes.size()>0){
            for(String s:indSelectedProductTypes){
                if(selectedProductTypes.contains(s) != true){
                  selectedProductTypes.add(s);
                }
            }
        }
        System.debug(initialSelectedProductTypes);
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
        System.debug('selectedstatecity'+selectedstatecity+'Size:'+selectedstatecity.split(',').size());
        System.debug(selectedProductTypes);
        List<string> splittedstring = selectedstatecity.split(',');
        List<String> tempselectedProductTypes = new list<String>();
        if(splittedstring.size() == 4){
            independentCounty = true;
            /*if(selectedProductTypes.contains('Lawyers.com Preferred Banner Placements') != true
               || selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results') != true){
                  selectedProductTypes.add('Lawyers.com Preferred Banner Placements');
                    selectedProductTypes.add('Lawyers.com Spanish Preferred County Results');
                   selectedProductTypes.add('Lawyers.com Spanish Preferred Banner Placements');
               }*/
             if(selectedProductTypes.contains('Lawyers.com Preferred Banner Placements') == true)
                 tempselectedProductTypes.add('Lawyers.com Preferred Banner Placements');
             if(selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results') == true)
                 tempselectedProductTypes.add('Lawyers.com Spanish Preferred County Results');
            if(selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements') == true)
                 tempselectedProductTypes.add('Lawyers.com Spanish Preferred Banner Placements');
            indSelectedProductTypes.addall(selectedProductTypes);
            selectedProductTypes = tempselectedProductTypes;
            System.debug('selectedProductTypes'+selectedProductTypes);
        }
        
        
        System.debug(independentCounty);
       /* if(tempSelectedProductTypes != null){
        selectedProductTypes.clear();
        selectedProductTypes.addall(tempSelectedProductTypes);
        }*/
        System.debug(selectedProductTypes);
        countrystateString = ''; 
        If(selectedProductTypes.contains('Lawyers.com Preferred National Results')
           || selectedProductTypes.contains('Martindale.com Preferred National Results')
           || selectedProductTypes.contains('Lawyers.com Spanish Preferred National Results')
           || selectedProductTypes.contains('Preferred National Links')
           || selectedProductTypes.contains('Lawyers.com Shared National Results')
          ){
              if(selectedstatecity != ''){          
                  List<String> sList = selectedstatecity.split(',');
                  if(sList.size() == 4){
                      givenCountry = selectedstatecity.split(',')[3];
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
        System.debug(givenCountry);
        System.debug('??'+attrLinequery);        
        if(attrLinequery != '' ){
            String attrLinequeryFinal = 'Select Id,Attribute_Junction__r.AttributeValues__c,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c '+attrLinequery;
            List<Attribute_Lines__c> tempList = database.query(attrLinequeryFinal);
            for(Attribute_Lines__c alRec :tempList ){
                if(alRec.Attribute_Junction__r.AttributeValues__c != null && !alRec.Attribute_Junction__r.AttributeValues__c.contains('County') && !alRec.Attribute_Junction__r.AttributeValues__c.contains('City') && !alRec.Attribute_Junction__r.AttributeValues__c.contains('State'))
                    atrLineList.add(alRec);
            }
            
        }
        for(Attribute_Lines__c at:atrLineList){
            System.debug(at);
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
        If(selectedProductTypes.contains('Lawyers.com Preferred State Results')
           || selectedProductTypes.contains('Preferred State Links')
           || selectedProductTypes.contains('Lawyers.com Spanish Preferred State Results')
           || selectedProductTypes.contains('Martindale.com Preferred State Results')){
               
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
               countrystateString = givenCountry +';'+givenstate;               
               attrLinequery += ' where (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'State\') '+
                   ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'State\')) '+
                   ' AND CountryState_String__c =:countrystateString) ';
           }
        System.debug('??'+attrLinequery);  
        if(attrLinequery != '' ){
            String attrLinequeryFinal = 'Select Id,Attribute_Junction__r.AttributeValues__c,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c '+attrLinequery;
            List<Attribute_Lines__c> tempList = database.query(attrLinequeryFinal);
            for(Attribute_Lines__c alRec :tempList ){                
                if(alRec.Attribute_Junction__r.AttributeValues__c != null && !alRec.Attribute_Junction__r.AttributeValues__c.contains('County') && !alRec.Attribute_Junction__r.AttributeValues__c.contains('City') )
                    atrLineList.add(alRec);
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
           || (selectedProductTypes.contains('Lawyers.com Preferred Banner Placements')
               && independentCounty)
           || (selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results')
               && independentCounty)
          ){
              givenCountry = selectedstatecity.split(',')[2];
              givenstate   = selectedstatecity.split(',')[1];
              if(selectedstatecity.split(',')[0].contains(' Co.')){
                  givencounty    = selectedstatecity.split(',')[0];
              }else{
                  givenCity    = selectedstatecity.split(',')[0];
              }
              if(givenCity != ''){
                  if(independentCounty){
                      String givenCountyCountry = selectedstatecity.split(',')[3];
                      countrystateString = givenCountyCountry + ';' + givenCountry +';'+givenstate + ';'+ givencity ;  
                      System.debug(countrystateString);
                       givenCountry = selectedstatecity.split(',')[3];
                      givenstate   = selectedstatecity.split(',')[2];
                      givencounty    = selectedstatecity.split(',')[1];
                      givenCity    = selectedstatecity.split(',')[0];
                      countrystateString = givenCountry +';'+givenstate + ';'+ givencity ;
                  } else{
                      countrystateString = givenCountry +';'+givenstate + ';'+ givencity ;
                  }
                  if(attrLinequery != '' && attrLinequery != null){
                      attrLinequery += ' OR ';
                  }else{
                      attrLinequery += ' where ';
                  }
                  
                  if(countrystateString.contains(' Co.')){
                      countrystateString.remove(' Co.');
                  }
                  System.debug(countrystateString);
                  if(independentcounty == true){
                       
            attrLinequery += ' (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'City\') '+
                      ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'City\')) '+
                      ' AND Address_String__c =:countrystateString) ';
          
            String attrLinequeryFinal = 'Select Id,Attribute_Junction__r.AttributeValues__c,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c '+attrLinequery;
            List<Attribute_Lines__c> tempList = database.query(attrLinequeryFinal);
            for(Attribute_Lines__c alRec :tempList ){
                if(alRec.Attribute_Junction__r.AttributeValues__c != null && alRec.Attribute_Junction__r.AttributeValues__c.contains('Independent City') )
                    atrLineList.add(alRec);
            
            }}else if(independentcounty == false){
                  attrLinequery += ' (((Attribute_Type__c =\'Picklist\' AND Picklist_Value__c != null AND  Attribute_Name__c = \'City\') '+
                      ' OR (Attribute_Type__c = \'Text\' AND String_Value__c != null AND Attribute_Name__c = \'City\')) '+
                      ' AND Address_String__c =:countrystateString) ';
                  }
              }
          }
        
      
        System.debug('??'+attrLinequery);  
        If((selectedProductTypes.contains('Lawyers.com Preferred County Results')
            ||(selectedProductTypes.contains('Lawyers.com Preferred Banner Placements')
               && independentCounty == false)
            ||(selectedProductTypes.contains('Lawyers.com Spanish Preferred County Results')
               && independentCounty == false)    
            ||selectedProductTypes.contains('Lawyers.com Shared County Results')
            ||selectedProductTypes.contains('Lawyers.com Spanish Preferred Banner Placements')
            ||selectedProductTypes.contains('Martindale.com Preferred County Results')) && countrystateString ==''){
                
                givenCountry = selectedstatecity.split(',')[2];
                givenstate   = selectedstatecity.split(',')[1];
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
        System.debug(selectedareaOfPracticeList);
        System.debug(selectedProductTypes);
        
        if(givencounty.contains(' Co.')){
            givencounty.remove(' Co.');
        }
        String query = 'SELECT Id, Name, RecordTypeId, City_ID__c, City_Name__c,CountryID__c, CountryName__c, County_ID__c, County_Name__c,StateID__c, State_Abbrevation__c, AOP_ID__c, AOP_Name__c FROM GEO_Location__c where CountryName__c = :givenCountry OR AOP_Name__c in :selectedareaOfPracticeList';
        if(givenstate != null && givenstate != ''){
            query += ' OR State_Abbrevation__c = :givenstate ';
        } 
        if(givencounty != null && givencounty != ''){
            query += ' OR County_Name__c = :givencounty';
        }
        if(givencity != null && givencity != ''){
            query += ' OR City_Name__c = :givencity';
        }
        
        System.debug(query);
        List<GEO_Location__c> geoLocationsList = Database.query(query);
        
        for(GEO_Location__c geo : geoLocationsList){
            System.debug(givenCountry);
            System.debug(countryId);
            if(geo.CountryID__c != null && countryId.contains(geo.CountryID__c) != true && givenCountry.contains(geo.CountryName__c)){
                if(countryId == '' || countryId == null){
                    countryId = geo.CountryID__c;
                }else{
                    countryId = countryId+','+geo.CountryID__c;
                }
            }
            
            if(geo.AOP_ID__c != null && aop.contains(geo.AOP_ID__c) != true && selectedareaOfPracticeList.contains(geo.AOP_Name__c)){
                if(aop == '' || aop == null){
                    aop = geo.AOP_ID__c;
                }else{
                    aop = aop+','+geo.AOP_ID__c;
                }
            }
            
            if(givenstate != '' && geo.StateID__c != null && stateId.contains(geo.StateID__c) != true && givenstate.contains(geo.State_Abbrevation__c)){
                if(stateId == '' || stateId == null){
                    stateId = geo.StateID__c;
                }else{
                    stateId = stateId+','+geo.StateID__c;
                }
            }
            
            
            if(givencounty != '' && geo.County_ID__c != null && countyId.contains(geo.County_ID__c) != true && givenCounty.contains(geo.County_Name__c) && givenstate.contains(geo.State_Abbrevation__c)){
                if(countyId == '' || countyId == null){
                    countyId = geo.County_ID__c;
                }else{
                    countyId = countyId+','+geo.County_ID__c;
                }
            }
            
            List<string> citys = givenCity.split(',');
            if(givencity != '' && geo.City_ID__c != null && cityId.contains(geo.City_ID__c) != true && citys.contains(geo.City_Name__c)  && givenstate.contains(geo.State_Abbrevation__c)){
                if(cityId == '' || cityId == null){
                    cityId = geo.City_ID__c;
                }else{
                    cityId = cityId+','+geo.City_ID__c;
                }
            }
            
        }
        
        System.debug(selectedProductTypes);
        List<Product2> productList = [Select productcode,Name from product2 where name in :selectedProductTypes];
        System.debug('productList'+productList);
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
            System.debug(independentCounty);
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
        
        System.debug(countryId);
        System.debug(aop);
        System.debug(productCodeMap);
        System.debug(stateId);
        System.debug(countyId);
        System.debug(cityId);
        if(countyId == '3434'){
          //  countyId = null;
        }
        if(!Test.isRunningTest())
            getSearchCount(aop,countryId,stateId,countyId,cityId);
        System.debug(searchCount);
        if(!Test.isRunningTest())
            getResults(aop,productCodeMap,countryId,stateId,countyId,cityId); 
        
        Set<Id> attrel = new Set<Id>();
        System.debug('??'+attrLinequery);  
        if(attrLinequery != ''){
        String attrLinequeryFinal = 'Select Id,Picklist_Value__c,Attribute_Name__c,Attribute_Type__c,String_Value__c,Attribute_Junction__c from Attribute_Lines__c '+attrLinequery;
        System.debug(attrLinequeryFinal);
        List<Attribute_Lines__c> tempList  = database.query(attrLinequeryFinal);
        atrLineList.addall(tempList);
        }
        
        Set<ID> prodID = new Set<Id>();
        Map<String,ID> prodVsAttrRel = new Map<String,ID>();
        List<Product2> products = [Select Id,Name,ProductCode from Product2 where name in :selectedProductTypes];  
        for(Product2 prod:products){
            if(prod.Name == 'Lawyers.com Preferred Banner Placements' || prod.Name == 'Lawyers.com Spanish Preferred Banner Placements'){
                List<Product2> productList1 = [Select Id,Name from Product2 where ProductCode = :prod.ProductCode];                  
                for(Product2 prods :productList1){
                    System.debug(prods);
                    System.debug(prods.ID);
                    prodID.add(prods.ID);
                }                
            }else{
                prodID.add(prod.Id);
            }
        }
        
        for(Attribute_Lines__c attr:atrLineList){
            if(attr.Attribute_Junction__c != null){
                System.debug(attr.Attribute_Junction__c);
                attrel.add(attr.Attribute_Junction__c);
            }
        }
        
        for(Id atrj:attrel){
            System.debug(atrj);
        }
        Map<Id,String> attRelvsAop = new Map<Id,String>();
      //  List<Attribute_Lines__c> attrList = [ ];
        
        for(Attribute_Lines__c attr : [Select Id,Attribute_Junction__c,Picklist_Value__c from Attribute_Lines__c where  Attribute_Name__c = 'AOP' and Picklist_Value__c != null and Picklist_Value__c in :selectedareaOfPracticeList and Attribute_Junction__c in :attrel])  {
            attRelvsAop.put(attr.Attribute_Junction__c,attr.Picklist_Value__c);
            System.debug(attr.Attribute_Junction__c + ' ' +attr.Picklist_Value__c);
        }  
        
        System.debug('attrel'+attrel);
        System.debug('attRelvsAop'+attRelvsAop);
        
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
            System.debug(oi.Id);
            prodIds.add(oi.Product2Id);
        }
        Map<Id,Product2> prodIdVSProd =new Map<Id,Product2>([Select id, productcode from product2 where id in :prodIds]); 
        
        for(OrderItem op : ordProducts){   
            System.debug(op.Id);
            filteredOrderProductIds.add(op.Id); 
            attRelvsProd.put(op.Attribute_Relationship__c,prodIdVSProd.get(op.Product2Id).ProductCode);
            System.debug(op.Attribute_Relationship__c + ' '+prodIdVSProd.get(op.Product2Id).ProductCode);
            System.debug(op.Attribute_Relationship__c);
            System.debug(op.Attribute_Relationship__c+ ' '+attRelvsAop.get(op.Attribute_Relationship__c) + ' '+orderaopVsOrderIds.containsKey(attRelvsAop.get(op.Attribute_Relationship__c)));
            if(orderaopVsOrderIds.containsKey(attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c))){
                System.debug(orderaopVsOrderIds.get(attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c)));
                 System.debug(attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c));
                orderaopVsOrderIds.get((attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c))).add(op.OrderId);
            }else{
                      System.debug(attRelvsProd.get(op.Attribute_Relationship__c));
                 System.debug(op.Attribute_Relationship__c + ' ' +attRelvsAop.get(op.Attribute_Relationship__c));

                orderaopVsOrderIds.put((attRelvsAop.get(op.Attribute_Relationship__c)+'+'+attRelvsProd.get(op.Attribute_Relationship__c)), new set<ID>{op.OrderId});
            System.debug(orderaopVsOrderIds);

            }
            System.debug(op.OrderId);
            allOrderIds.add(op.OrderId);
        }
        System.debug('orderaopVsOrderIds'+ orderaopVsOrderIds);
        System.debug('filteredOrderProductIds'+filteredOrderProductIds);
        System.debug(allOrderIds);
        for(id i : allorderids){
            system.debug(i);
        }
        List<Contract> ContractList = [Select Id,ContractNumber,Original_Order__c,SBQQ__Order__c from Contract where SBQQ__Order__c in :allOrderIds or Original_Order__c  in : allOrderIds];
        System.debug(ContractList);
        for(Contract i : ContractList){
            system.debug(i.Id);
        }
        
        Map<Id,Contract> ordContractMap = new Map<Id,Contract>();
        
        for(Contract contr: ContractList){
            ordContractMap.put(Contr.SBQQ__Order__c,contr);
             ordContractMap.put(Contr.Original_Order__c,contr);
        }        
        
        System.debug(ordContractMap);
        for(id ordId : ordContractMap.keyset()){
            System.debug(ordId +' '+ordContractMap.get(ordId));
        }
        IF(!filteredOrderProductIds.isEmpty()){
            If(!allOrderIds.isEmpty()){
                Map<ID,Order> orderIdVsOrder = new Map<ID,Order>([select id,Name,
                                                                  Account.Name,
                                                                  Account.MH_Cust_Number__c
                                                                  From Order
                                                                  Where ID IN:allOrderIds]);
                for(string aop: orderaopVsOrderIds.keySet()){
                    system.debug(aop + ' '+ orderaopVsOrderIds.get(aop));
                }
                for(string aop: orderaopVsOrderIds.keySet()){
                    System.debug(aop);
                    List<innerOrders>tempinnerOrders = new List<innerOrders>();
                    System.debug(orderaopVsOrderIds.get(aop));
                    for(Id ordId : orderaopVsOrderIds.get(aop)){
                        System.debug(ordId);
                        Order toder = orderIdVsOrder.get(ordId);
                        System.debug(toder);
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
            
            System.debug('orderaopVsinnerwraps'+orderaopVsinnerwraps);
            system.debug('@@@searchfilteredOrderChargeIds'+searchfilteredOrderChargeIds);
            aggregateResult[] agOrdList = [select count(id) cnt,Attribute_Relationship__c attr
                                           From  OrderItem where
                                           (Status__c = 'Active' or (Status__c = 'Cancelled'and SBQQ__TerminatedDate__c >= Today) or 
                                            (Status__c = 'Truncated'and SBQQ__TerminatedDate__c >= Today)) and Product2Id = :prodID 
                                           and Attribute_Relationship__c in :attrel group by Attribute_Relationship__c];
            for(aggregateResult ag:agOrdList){
                //resultstoshow - 
                System.debug(ag);
                for(ResultClass rsp :resultstoshow){
                    System.debug(rsp.aop);
                    System.debug((Id)ag.get('attr'));
                    System.debug(attRelvsAop);
                    if((attRelvsAop.containskey((Id)ag.get('attr')) && (rsp.aop == attRelvsAop.get((Id)ag.get('attr')) || attRelvsAop.get((Id)ag.get('attr')).contains(rsp.aop) )) && ((String.valueof(rsp.product_id)) ==  attRelvsProd.get((Id)ag.get('attr')) || ('0'+String.valueof(rsp.product_id)) ==  attRelvsProd.get((Id)ag.get('attr')) )){
                        //  rsp.sold +=1;//Integer.valueOf(agOrdList.size());//(ag.get('cnt'));
                        string gaop = attRelvsAop.get((Id)ag.get('attr'))+'+'+String.valueof(rsp.product_id);
                        string gaop1 =   attRelvsAop.get((Id)ag.get('attr'))+'+0'+String.valueof(rsp.product_id);
                        System.debug(gaop);
                        system.debug(gaop1);
                        if(orderaopVsinnerwraps.containsKey(gaop) || orderaopVsinnerwraps.containsKey(gaop1)){
                            if(orderaopVsinnerwraps.get(gaop) != null){
                                System.debug(orderaopVsinnerwraps.get(gaop));
                                System.debug(rsp.innerordersList);
                                rsp.innerordersList = orderaopVsinnerwraps.get(gaop);
                            } else if(orderaopVsinnerwraps.get(gaop1) != null){
                                System.debug(rsp.innerordersList);
                                rsp.innerordersList = orderaopVsinnerwraps.get(gaop1); 
                            }  
                        }
                        system.debug('@@@@@rsp.innerordersList'+rsp.innerordersList);
                    }
                    
                }
            }
            
        }
        
        
        Map<String,set<Id>> quoteAopVsQuoteIds = new Map<String,set<Id>>();
        Map<String,set<Id>> prodVsQuoteIds = new Map<String,set<Id>>();
        System.debug(prodID);
        Map<String,List<innerOrders>> optyaopVsinnerwraps = new Map<String,List<innerOrders>>();
        Set<Id>   allQuoteIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLinesList = [Select Id,SBQQ__Quote__c,SBQQ__Product__r.ProductCode,Sin__c,Inventory_Id__c,Attribute_Relationship__c,SBQQ__Quote__r.SBQQ__Status__c 
                                                   from SBQQ__QuoteLine__c where  (Sin__c ='' or Sin__c = NULL)
                                                   and Inventory_Id__c != NULL and  SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won'
                                                   and SBQQ__Product__c in :prodID and Attribute_Relationship__c in :attrel and Attribute_Relationship__c != null];
        for(SBQQ__QuoteLine__c ql : quoteLinesList){
            System.debug(ql.Id);
            filteredQuotelineIds.add(ql.Id); 
            attRelvsProd.put(ql.Attribute_Relationship__c,ql.SBQQ__Product__r.ProductCode);
            if(quoteAopVsQuoteIds.containsKey(attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c))){
                quoteAopVsQuoteIds.get((attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c))).add(ql.SBQQ__Quote__c);
                //prodVsQuoteIds.get(attRelvsProd.get(ql.Attribute_Relationship__c)).add(ql.SBQQ__Quote__c);
            }else{
                quoteAopVsQuoteIds.put(attRelvsAop.get(ql.Attribute_Relationship__c)+'+'+attRelvsProd.get(ql.Attribute_Relationship__c), new set<ID>{ql.SBQQ__Quote__c});
                //prodVsQuoteIds.get(attRelvsProd.get(ql.Attribute_Relationship__c)).add(ql.SBQQ__Quote__c);
            }
            System.debug(quoteAopVsQuoteIds);
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
                    System.debug(aop);
                    List<innerOrders>tempinneroptys = new List<innerOrders>();
                    System.debug(quoteAopVsQuoteIds.get(aop));
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
            
            System.debug(prodID);
            System.debug(attrel);
            for(id at: attrel){
                System.debug(at);
            }
            aggregateResult[] agList =  [select count(id) cnt,Attribute_Relationship__c attr
                                         from SBQQ__QuoteLine__c where  (Sin__c ='' or Sin__c = NULL)
                                         and Inventory_Id__c != NULL and  SBQQ__Quote__r.SBQQ__Status__c != 'Closed Won'
                                         and SBQQ__Product__c = :prodID and Attribute_Relationship__c in :attrel group by Attribute_Relationship__c];  
            system.debug('@@@searchfilteredOptyChargeIds'+searchfilteredOptyChargeIds);
            system.debug('@@@agList'+agList);
            for(aggregateResult ag:agList){
                System.debug(ag);
                for(ResultClass rsp :resultstoshow){
                    System.debug(attRelvsAop);
                    System.debug((Id)ag.get('attr'));
                    System.debug(rsp.aop);
                    if((attRelvsAop.containsKey((Id)ag.get('attr')) && (rsp.aop ==  attRelvsAop.get((Id)ag.get('attr')) || attRelvsAop.get((Id)ag.get('attr')).contains(rsp.aop) )) && ((String.valueof(rsp.product_id)) ==  attRelvsProd.get((Id)ag.get('attr')) || ('0'+String.valueof(rsp.product_id)) ==  attRelvsProd.get((Id)ag.get('attr')) )){
                        string gaop =  attRelvsAop.get((Id)ag.get('attr'))+'+'+String.valueof(rsp.product_id);
                        string gaop1 =  attRelvsAop.get((Id)ag.get('attr'))+'+0'+String.valueof(rsp.product_id);
                         System.debug(optyaopVsinnerwraps);
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
                System.debug('!!!!resultstoshow'+resultstoshow);
                
            }
            
        }
        
        getRenderPageBlockTable();
        System.debug(selectedProductTypes);
        System.debug(finalResults);
        
        return null;
        
        
    }
    
    public List<SelectOption> getdynamicStatelist(){
        System.debug('StateList'+StateList);

statestrings = null;         
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
                options.add(new SelectOption(st,st));
               
            }
        }
         System.debug(options);
        return options;
    }
    
    
    public List<SelectOption> getdynamicCitylist(){
        system.debug('@@@@countystrings'+countytrings);
        system.debug('@@@@citystrings'+citystrings);
         system.debug('@@@@citystrings'+statelist);
        
        if(test.isRunningTest())
        {
            statelist = null;
        }

        if(statelist == null && (citystrings == null || citystrings == '' ) && (countytrings == null || countytrings == '')){
            statelist  = new List<String>();
            statelist.add('NY');
            
        }
       
        if( statelist != null){
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
                options.add(new SelectOption(st,st));
            }
        }
        system.debug(options);
        

        if(statelist != null){
            countytrings = '';
            String query = 'SELECT county_name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\' and CountryName__c = \'USA\' AND State_Abbrevation__c  in :statelist and county_name__c != null group by county_name__c';
            
            
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
        
        return options;
    }
    
    
    public List<SelectOption> getdynamicCountylist(){
        system.debug('@@@@countystrings'+countytrings);
        system.debug('@@@@citystrings'+citystrings);
       system.debug('@@@@citystrings'+statelist);
        System.debug(statelist == null && citystrings == null && countytrings == null);
        System.debug(countytrings);
        
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
        


        if( statelist != null ){
            countytrings = '';
            String query = 'SELECT county_name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\' and CountryName__c = \'USA\' AND State_Abbrevation__c  in :statelist and county_name__c != null group by county_name__c';
            
            
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
                options.add(new SelectOption(st,st));
            }
        }
        system.debug(options);  
        if(statelist != null){
            citystrings = '';
            String query = 'SELECT city_name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND State_Inv_Flag__c=\'Yes\' and CountryName__c = \'USA\' AND State_Abbrevation__c  in :statelist and city_name__c != null group by city_name__c';
            
            
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
        if(cntList.size() == 0){
            dynamicStatelisttemp = new List<SelectOption>();
            
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
    public static String refreshcityList(String cnt, string st, string countyfromPage){ 
        
        System.debug('State'+st);
        List<String>initialStates = new List<String>();
        
        string citystring = '';
        
        if(cnt == null || cnt == ''){
            cnt ='USA';
        }
        List<string>cntList     = cnt.split(',');
        List<string>stlist       = st.split(',');
        System.debug(cntList+'-'+stlist);
        dynamicStatelisttemp = new List<SelectOption>();
        if(cntList.size() == 0){
            dynamicStatelisttemp = new List<SelectOption>();
            
        }
        else if(cntList != null && !('').equals(cntList) ){
            system.debug('@@@@getLimitQueryRows()' + Limits.getQueryRows()); 
            
            String query = 'SELECT City_Name__c FROM GEO_Location__c WHERE RecordType.DeveloperName=\'M_H_GEO_Locations\' AND City_Inv_Flag__c=\'Yes\'';
            String filter = '';  
            
            if(!cntList.isEmpty()){
                filter = filter + ' and CountryName__c IN:cntList AND State_Abbrevation__c IN:stlist ';
            }
            
            if(countyfromPage != ' '){
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
        if(cntList.size() == 0){
            dynamicStatelisttemp = new List<SelectOption>();
            
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
                    if(i ==9999){
                        break;
                    }
                }
            }
        }
         system.debug('@@@citystring'+countystring);
        return countystring;
        
    }
    
    // @future(callout=true)
    public static void  getResults(String aop,Map<String,String> productCodeMap,String countryId,String stateId,String countyId,String cityId){ 
        resultstoshow = new List<ResultClass>();
        finalResults= new Map<String,List<ResultClass>>();
        System.debug('aop : '+aop+' productCodeMap : '+productCodeMap+' countryId : '+countryId+' stateId : '+stateId+' countyId : '+countyId+' cityId : '+cityId);
        
        Http http = new Http(); 
        HttpRequest req = new HttpRequest(); //initiate HTTP request
        string strEndPoint = '';
        //http://stg-back-office-services.lawyers.com/services/salestool/v1/inventory/byCity?cityId=12493&productCode=1920&aop=630&pageNumber=1&pageSize=100';
        
        if(countryId != null && countryId != ''){
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCountry?countryId=' + countryId + '&productCode=' + productCodeMap.get('National') +'&aop='+ aop + 'pageNumber=1&pageSize=100';
            System.debug('Country endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            
            HTTPResponse res = http.send(req);
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
                    if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('LDC','Lawyers.com');
                        r.product= r.product.replace('LDC','Lawyers.com');
                    }else if(r.product.startswith('MDC') != true && r.product.contains('Links') == false){
                        prodName = 'Lawyers.com '+r.product;
                        searchStr+=','+'LDC';
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product.replace('MDC','Martindale.com');
                        r.product= r.product.replace('MDC','Martindale.com');
                        if(prodName=='Martindale.com Preferred National Result'){
                            prodName=prodName+'s';
                            r.product= r.product.replace('MDC','Martindale.com')+'s';
                        }
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
                    if(finalResults.containskey(prodName)!= true){
                        finalResults.put(prodName,new List<ResultClass>{r});
                    }else if(finalResults.containskey(prodName) == true){
                        finalResults.get(prodName).add(r);    
                    }               
                }
            }
        }
        
        if(stateId != null && stateId != ''){
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byState?stateId=' + stateId + '&productCode=' + productCodeMap.get('State') +'&aop='+ aop + 'pageNumber=1&pageSize=100';
            System.debug('State endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            
            HTTPResponse res = http.send(req);
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                
                
                resultstoshow.addall(rs.data);
                
                for(ResultClass r : rs.data){
                    String prodName = '';
                    String searchStr = 'state'+','+r.aop_id;
                    
                    if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('LDC','Lawyers.com');
                        r.product= r.product.replace('LDC','Lawyers.com');
                    }else if(r.product.startswith('MDC') != true && r.product.contains('Links') == false){
                        
                        prodName = 'Lawyers.com '+r.product;
                        searchStr+=','+'LDC';
                        
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product.replace('MDC','Martindale.com');
                        r.product= r.product.replace('MDC','Martindale.com');
                        
                        if(prodName=='Martindale.com Preferred State Result'){
                            prodName=prodName+'s';
                            r.product= r.product.replace('MDC','Martindale.com')+'s';
                        }
                        
                        
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
                    if(finalResults.containskey(prodName)!= true){
                        finalResults.put(prodName,new List<ResultClass>{r});
                    }else if(finalResults.containskey(prodName) == true){
                        finalResults.get(prodName).add(r);    
                    }
                }
                
            }
        }
        
        
        if(cityId != null && cityId != ''){
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCity?cityId=' + cityId + '&productCode=' + productCodeMap.get('City') +'&aop='+ aop + 'pageNumber=1&pageSize=100';
            System.debug('City endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            
            HTTPResponse res = http.send(req);
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                
                resultstoshow.addall(rs.data);
                
                for(ResultClass r : rs.data){
                    System.debug('prodname'+r.product);
                        
                    String prodName = '';
                    String searchStr = 'city'+','+r.aop_id;
                    
                    if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('LDC','Lawyers.com');
                        r.product= r.product.replace('LDC','Lawyers.com');
                    }else if(r.product.startswith('MDC') != true && r.product.contains('Links') == false){
                        searchStr+=','+'LDC';
                        prodName = 'Lawyers.com '+r.product;
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                        prodName = r.product.replace('MDC','Martindale.com');
                        r.product= r.product.replace('MDC','Martindale.com');
                        
                        if(prodName=='Martindale.com Preferred City Result'){
                            prodName=prodName+'s';
                            r.product= r.product.replace('MDC','Martindale.com')+'s';
                        }
                        
                        
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
                    System.debug('prodname'+prodName);
                    if(prodName == 'Lawyers.com Spanish Display Ads'){  
                        prodName= 'Lawyers.com Spanish Preferred Banner Placements';    
                        r.product= 'Lawyers.com Spanish Preferred Banner Placements';
                     }
                    
                    if(searchcount != null && searchcount.containskey(searchStr)){
                        r.searchcount = searchcount.get(searchStr);
                    }
                    if(finalResults.containskey(prodName)!= true){
                        finalResults.put(prodName,new List<ResultClass>{r});
                    }else if(finalResults.containskey(prodName) == true){
                        finalResults.get(prodName).add(r);    
                    }
                }
                
            }
            
        }
        
        
        
        if(countyId != null && countyId != '') {
            strEndPoint = system.Label.Inventory_Tool_Endpoint + '/byCounty?countyId=' + countyId + '&productCode=' + productCodeMap.get('County') +'&aop='+ aop + 'pageNumber=1&pageSize=100';
            System.debug('County endpoint : '+strEndPoint);
            req.setEndpoint(strEndPoint);
            req.setMethod('GET');
            req.setTimeout(120000); 
            
            HTTPResponse res = http.send(req);
            
            
            String strSuccessErrorMsg = '';
            if(res.getStatusCode() == 200){
                
                fromJSON rs = (fromJSON)JSON.deserialize( res.getBody(), fromJSON.class);
                resultstoshow.addall(rs.data);
                System.debug('resultstoshow'+resultstoshow);
                for(ResultClass r : rs.data){
                    String prodName = '';
                    String searchStr = 'county'+','+r.aop_id;
                    
                    if(r.product.startswith('LDC') == true){
                        searchStr+=','+'LDC';
                        prodName = r.product.replace('LDC','Lawyers.com');
                        r.product= r.product.replace('LDC','Lawyers.com');
                    }else if(r.product.startswith('MDC') != true && r.product.contains('Links') == false){
                        searchStr+=','+'LDC';
                        prodName = 'Lawyers.com '+r.product;
                    }else if(r.product.startswith('MDC') == true){
                        searchStr+=','+'MDC';
                        
                        prodName = r.product.replace('MDC','Martindale.com');
                        r.product= r.product.replace('MDC','Martindale.com');
                        
                        if(prodName=='Martindale.com Preferred County Result'){
                            prodName=prodName+'s';
                            r.product= r.product.replace('MDC','Martindale.com')+'s';
                        }
                        
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
                    if(finalResults.containskey(prodName)!= true){
                        finalResults.put(prodName,new List<ResultClass>{r});
                    }else if(finalResults.containskey(prodName) == true){
                        finalResults.get(prodName).add(r);    
                    }
                }
                
            }
        }
        
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
        public List<innerOrders> innerordersList{get;set;}
    }
    
    class cls_errorMessage {
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
    
    /*
        Method Name: queryAllFields
        Description: This method is used to return all fields of sObject 
        Parameter  : sObject API Name
    */
    Public static string queryAllFields(String strObjectAPIName){
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String queryFields = String.join( fieldNames, ',' );
        return queryFields;
    }// END OF METHOD - queryAllFields
}