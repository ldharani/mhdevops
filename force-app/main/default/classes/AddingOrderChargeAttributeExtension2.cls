public with sharing class AddingOrderChargeAttributeExtension2  {

    public invoiceit_s__Job__c order{get;set;}
    public list<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOPRCharge{set;get;}
    public boolean isVisible{get;set;}
    public list<OrderChargeWrapper> listOfOrderChargeWrapper{get;set;}
    OrderChargeWrapper orderChargeWrapperObj;
    Id orderId;
    list<State_County__c> listOfStates;
    list<string> stateNames;
    list<State_County__c> listOfCounties;
    list<State_County__c>listOfCities;
    AddingOrderNavigation addingOrderNavigationobj;
     Map<id,String> optychargeVsAttributeString;
    Map<id,String> optychargeVsxrefAttributeString;
    Map<id,String> optychargeVsxrefcountyAttributeString;
    Map<id,String>tempoptychargeVsxrefcountyAttributeString;
    Map<id,String> optychargeVsInvAttributeString;
    Map<id,String> optychargeVsInvcountyAttributeString;
    Map<id,String> countryset;
    Map<id,String> countrystateset;
    Map<id,String> cityset;
    Map<id,String> xrefcountryset;
    Map<id,String> xrefcountrystateset;
    Map<id,String> xrefcityset;
    Map<id,String> invcountryset;
    Map<id,String> invcountrystateset;
    Map<id,String> invcityset;
    Map<id,String> invcountyset;
    Map<id,String> aopSet;
    public Set<String> prodTypeList{get;set;}
    
    
    
    
    
    //constructor
    public AddingOrderChargeAttributeExtension2 (ApexPages.StandardController controller) {
        orderId = ApexPages.currentPage().getParameters().get('id');
        order = [SELECT name, invoiceit_s__Status__c, invoiceit_s__Service_Activation_Date__c,
                 invoiceit_s__Service_End_Date__c FROM invoiceit_s__Job__c 
                 WHERE id =: orderId];
        //query for list of order charges along with order charge attribute
        listOfOPRCharge = [SELECT Name,invoiceit_s__Job_Rate_Plan__c,invoiceit_s__Accounting_Code__c,
                           (SELECT Attribute_Order__c,Picklist_Value__c, Attribute_Picklist_Values__c,Phone_Value__c,Long_text_value__c,
                                   Required__c,Name,Attribute_Name__c,Attr_Name__c,Minimum_No_Of_Characters_In_Text__c, Maximum_No_Of_Characters_In_Text__c,
                                   Address_String__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Number_Value__c,Order_Rate_Plan_Charge__c,String_Value__c,CountryState_String__c 
                                   FROM Order_Charge_Attributes__r ORDER By Address_Order__c ASC)
                                   FROM invoiceit_s__Job_Rate_Plan_Charge__c
                                   WHERE  invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Id =: orderId];
        addingOrderNavigationobj = new AddingOrderNavigation (listOfOPRCharge);
        prodTypeList = new set<string>();
        List<AOPGeo_Products_List__c> iplist = AOPGeo_Products_List__c.getall().values();
        for(AOPGeo_Products_List__c ip: iplist){
            prodTypeList.add(ip.Name);            
        }  
        first();
   }
    
    public Boolean hasNext {
        get {
            if(addingOrderNavigationobj != null) {
                return addingOrderNavigationobj.hasNext();    
            }
            else {
                return false;
            }
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            if(addingOrderNavigationobj != null) {
                return addingOrderNavigationobj.hasPrevious();        
            }
            else {
                return false;
            }
        }
        set;
    }
    
    public void quickSave() {
        save();
    }
    
    
    public void next() {
            listOfOPRCharge = addingOrderNavigationobj.next();
            populateList();
    }

    public void previous() { 
            listOfOPRCharge = addingOrderNavigationobj.previous();
            populateList();
    }

    public void first() {
            listOfOPRCharge = addingOrderNavigationobj.first();
            populateList();
    }
    
    public void last() {
            listOfOPRCharge = addingOrderNavigationobj.last();
            populateList();
    }
    
    
    public void populateList() {
        List<AggregateResult> aggResult ;
        if(Test.isRunningTest())
            aggResult = [ SELECT State__c state FROM State_County__c GROUP BY State__c order by State__c DESC LIMIT 1];
        else    
            aggResult = [ SELECT State__c state FROM State_County__c GROUP BY State__c order by State__c DESC];
        set<string> setOfStatesNew = new set<string>(); 
        for(AggregateResult agg : aggResult){
            setOfStatesNew.add((string)agg.get('state'));
        }
        list<string> setOfStates = new list<string>();
        setOfStates.addAll(setOfStatesNew);
        setOfStates.sort();
        
        listOfOrderChargeWrapper = new  list<OrderChargeWrapper>(); 
        for(invoiceit_s__Job_Rate_Plan_Charge__c charge:listOfOPRCharge) {
            orderChargeWrapperObj = new OrderChargeWrapper();
            orderChargeWrapperObj.orderRPCWrap = charge;
            orderChargeWrapperObj.isChecked = false;


            list<AttributeNames> listOfAttributes = new list<AttributeNames>();
            for(Order_Charge_Attribute__c charAtt : charge.Order_Charge_Attributes__r) {
                AttributeNames a1;// = new AttributeNames();
                //a1.orderChargeAttribute = charAtt;   
                if(prodTypeList.contains(charge.Name) && (charAtt.Attribute_Name__c.contains('AOP') || charAtt.Attribute_Name__c == 'Geo') && !charAtt.Attribute_Name__c.contains('AOP/Geo')){
                        system.debug('in if'+charAtt.Attribute_Name__c);
                }else{
                    a1 = new AttributeNames();
                    a1.orderChargeAttribute = charAtt;                
                    
                }
                if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Attribute_Picklist_Values__c != null && charAtt.Attribute_Name__c != 'State' && charAtt.Attribute_Name__c != 'Xref State' && charAtt.Attribute_Name__c != 'County' && charAtt.Attribute_Name__c != 'Xref County' && charAtt.Attribute_Name__c != 'City') {
                    
                    a1.attributeOptions = new List<SelectOption>();
                    a1.attributeOptions.add(new SelectOption('', '--None--'));
                    for(string s : charAtt.Attribute_Picklist_Values__c.split(',')) {
                        String s1 = s.trim();
                        a1.attributeOptions.add(new SelectOption(s1, s1));    
                    }    
                } 
               
                else if(charAtt.Attribute_Name__c == 'State'|| charAtt.Attribute_Name__c == 'County'|| charAtt.Attribute_Name__c == 'City' ){                    
                    if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Attribute_Name__c == 'State') {
                        a1.attributeOptions = new List<SelectOption>();
                        if(charAtt.Picklist_Value__c != null){
                             a1.attributeOptions.add(new SelectOption(charAtt.Picklist_Value__c, charAtt.Picklist_Value__c));
                        }
                        a1.attributeOptions.add(new SelectOption('--None--', '--None--'));
                        for(String stateName : setOfStates){
                            if(charAtt.Picklist_Value__c != stateName)
                            a1.attributeOptions.add(new SelectOption(stateName ,stateName));                            
                        }                    
                    }   
                    
                   if(charAtt.Attribute_Type__c == 'Picklist' && (charAtt.Attribute_Name__c == 'County')) {
                        a1.attributeOptions = new List<SelectOption>();
                        if(charAtt.Picklist_Value__c != null){
                            a1.attributeOptions.add(new SelectOption(charAtt.Picklist_Value__c, charAtt.Picklist_Value__c));
                         }
                        a1.attributeOptions.add(new SelectOption('--None--', '--None--'));
                    }    
                                       
                   if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Attribute_Name__c == 'City') {
                        a1.attributeOptions = new List<SelectOption>();
                        if(charAtt.Picklist_Value__c != null){
                           a1.attributeOptions.add(new SelectOption(charAtt.Picklist_Value__c, charAtt.Picklist_Value__c));
                        } 
                        a1.attributeOptions.add(new SelectOption('--None--', '--None--'));   
                        }                    
                }  
                else if(charAtt.Attribute_Name__c == 'Xref State' || charAtt.Attribute_Name__c == 'Xref County'){
                    if(charAtt.Attribute_Type__c == 'Picklist' &&  charAtt.Attribute_Name__c == 'Xref State') {
                        a1.attributeOptions = new List<SelectOption>();
                        if(charAtt.Picklist_Value__c != null){
                             a1.attributeOptions.add(new SelectOption(charAtt.Picklist_Value__c, charAtt.Picklist_Value__c));
                        }
                        a1.attributeOptions.add(new SelectOption('--None--', '--None--'));
                        for(String stateName : setOfStates){
                            if(charAtt.Picklist_Value__c != stateName)
                            a1.attributeOptions.add(new SelectOption(stateName ,stateName));                            
                        }                    
                    }   
                    
                   if(charAtt.Attribute_Type__c == 'Picklist' &&  charAtt.Attribute_Name__c == 'Xref County') {
                        a1.attributeOptions = new List<SelectOption>();
                        if(charAtt.Picklist_Value__c != null){
                            a1.attributeOptions.add(new SelectOption(charAtt.Picklist_Value__c, charAtt.Picklist_Value__c));
                         }
                        a1.attributeOptions.add(new SelectOption('--None--', '--None--'));
                    }
                    
                               
                
                }
                if(charAtt.Attribute_Name__c.contains('AOP/Geo')){
                        system.debug('in if'+charAtt.Attribute_Name__c);
                        //existingIds.add(charAtt.Id);
                        if(charAtt.String_Value__c != null && charAtt.String_Value__c != 'null'){
                            if(charAtt.String_Value__c.contains(';')){
                                List<String> sList = new List<String>();
                                sList = charAtt.String_Value__c.split(';');
                                system.debug('slist here:::'+sList);
                                charAtt.Picklist_Value__c = sList[0];
                                charAtt.Address_String__c = sList[1];
                                charAtt.CountryState_String__c = sList[2];
                                charAtt.String_Value__c = sList[3];
                            }
                            //isAOPGeoExistsMap.put(charge.Name,true);
                        }
                    }
                 if(a1 != null){     
                listOfAttributes.add(a1);
                orderChargeWrapperObj.listOfAttributes.add(a1);
                }
            }
            //orderChargeWrapperObj.listOfAttributes = listOfAttributes;
            listOfOrderChargeWrapper.add(orderChargeWrapperObj);
        }

    }   
    public PageReference save(){
        try {
            
            list<Order_Charge_Attribute__c> listofAttribute = new list<Order_Charge_Attribute__c>();
            optychargeVsAttributeString           = new Map<id,String>();
            optychargeVsxrefAttributeString       = new Map<id,String>();
            optychargeVsxrefcountyAttributeString = new Map<id,String>();
            tempoptychargeVsxrefcountyAttributeString = new Map<id,String>();  // just to handle xref county validations
            optychargeVsInvAttributeString      = new Map<id,String>();
            optychargeVsInvcountyAttributeString= new Map<id,String>();
            countryset                          = new Map<id,String>();  //used for service country
            countrystateset                     = new Map<id,String>();  //used for service state
            cityset                             = new Map<id,String>();  //used for service city
            xrefcountryset                      = new Map<id,String>();  //used for Xref country
            xrefcountrystateset                 = new Map<id,String>();  //used for Xref state
            xrefcityset                         = new Map<id,String>();  //used for xrefcity
            invcountryset                       = new Map<id,String>();  //used for inv product country
            invcountrystateset                  = new Map<id,String>();  //used for inv product state
            invcityset                          = new Map<id,String>();  //used for inv product city
            invcountyset                        = new Map<id,String>();  //used for inv product county
            aopSet                              = new Map<id,String>();
            
             //initializing inventoried products set
            Set<String> inventoryProducts = new Set<String>{'Preferred Banner Placements',
                                                            'Preferred City Results',
                                                            'Preferred County Results',
                                                            'Preferred Martindale.com Results',
                                                            'Preferred National Links',
                                                            'Preferred National Results',
                                                            'Preferred State Links',
                                                            'Preferred State Results'}; 
            
            
            //if(listOfOrderChargeWrapper != null){
            for(OrderChargeWrapper ordChargeWrap:listOfOrderChargeWrapper){
                System.debug('Printing size of list1'+ordChargeWrap.orderRPCWrap.Order_Charge_Attributes__r);   
                for(Order_Charge_Attribute__c attribute:ordChargeWrap.orderRPCWrap.Order_Charge_Attributes__r){
                    system.debug('attribute is ====== ' + attribute);
                    
                       /***Added by Sai *******/
                        // forming all service address maps here
                     if(attribute.Attribute_Name__c.contains('AOP') && (attribute.Picklist_Value__c != NULL && attribute.Picklist_Value__c !='')){
                            aopSet.put(ordChargeWrap.orderRPCWrap.id, attribute.Picklist_Value__c.toUpperCase());
                        }
                        
                    if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service State' 
                       || attribute.Attribute_Name__c == 'Service City'){
                           string serviceValue = '';
                           if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service City'){
                               if(attribute.String_Value__c != null){
                                   serviceValue = attribute.String_Value__c.toUpperCase();
                               }
                               
                           }
                           else{
                                if(attribute.Picklist_Value__c != null){
                                   serviceValue = attribute.Picklist_Value__c.toUpperCase();
                                }
                               else if(attribute.String_Value__c != null){
                                    serviceValue = attribute.String_Value__c;
                                }
                           }
                           
                           
                           if(attribute.Attribute_Name__c == 'Service Country'){
                               countryset.put(ordChargeWrap.orderRPCWrap.id,serviceValue);
                           }
                           
                           if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service State'){
                                if(countrystateset.containsKey(ordChargeWrap.orderRPCWrap.id)){
                                    string temp = countrystateset.get(ordChargeWrap.orderRPCWrap.id) + ';' + serviceValue;
                                    countrystateset.put(ordChargeWrap.orderRPCWrap.id, temp);
                                }
                                else{
                                    countrystateset.put(ordChargeWrap.orderRPCWrap.id,serviceValue );
                                }
                           }
                           
                           
                           
                           
                           if(optychargeVsAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)){
                                string temp = optychargeVsAttributeString.get(ordChargeWrap.orderRPCWrap.id) + ';' + serviceValue;
                               optychargeVsAttributeString.put(ordChargeWrap.orderRPCWrap.id, temp);
                            }
                          else{
                              optychargeVsAttributeString.put(ordChargeWrap.orderRPCWrap.id,serviceValue);
                          }
                     } 
                        
                        system.debug('@@@@service ends');
                    
                    /*************Xref validation**************************/
                      if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State' 
                       || attribute.Attribute_Name__c == 'Xref City' || attribute.Attribute_Name__c == 'Xref County'){
                           string xrefvalue = '';
                           if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref City'){
                                if(attribute.String_Value__c != null){
                                       xrefvalue = attribute.String_Value__c.toUpperCase();
                               }
                            }
                            else{
                               if(attribute.Picklist_Value__c != null){
                                   xrefvalue = attribute.Picklist_Value__c.toUpperCase();
                               }
                               else if(attribute.String_Value__c != null){
                                    xrefvalue = attribute.String_Value__c.toUpperCase();
                                }
                               
                           }
                           system.debug('@@@@@xref value check'+attribute.Attribute_Name__c+';'+xrefvalue);
                           if(attribute.Attribute_Name__c == 'Xref Country'){
                               xrefcountryset.put(ordChargeWrap.orderRPCWrap.id,xrefvalue );
                           }
                           
                           if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State'){
                                if(xrefcountrystateset.containsKey(ordChargeWrap.orderRPCWrap.id)){
                                    string temp = xrefcountrystateset.get(ordChargeWrap.orderRPCWrap.id) + ';' + xrefvalue;
                                    xrefcountrystateset.put(ordChargeWrap.orderRPCWrap.id, temp);
                                }
                                else{
                                    xrefcountrystateset.put(ordChargeWrap.orderRPCWrap.id,xrefvalue );
                                }
                          }
                           
                           
                           
                          if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State' 
                             || attribute.Attribute_Name__c == 'Xref City' ){
                                 if(optychargeVsxrefAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)){
                                    string temp = optychargeVsxrefAttributeString.get(ordChargeWrap.orderRPCWrap.id) + ';' + xrefvalue;
                                    optychargeVsxrefAttributeString.put(ordChargeWrap.orderRPCWrap.id, temp);
                                }
                                else{
                                    optychargeVsxrefAttributeString.put(ordChargeWrap.orderRPCWrap.id,xrefvalue );
                                }
                             }
                           
                            if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State' 
                                || attribute.Attribute_Name__c == 'Xref County' ){ 
                               if(tempoptychargeVsxrefcountyAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)){
                                    string temp = tempoptychargeVsxrefcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id) + ';' + xrefvalue;
                                   tempoptychargeVsxrefcountyAttributeString.put(ordChargeWrap.orderRPCWrap.id, temp);
                                }
                              else{
                                  tempoptychargeVsxrefcountyAttributeString.put(ordChargeWrap.orderRPCWrap.id,xrefvalue );
                              }
                           }  
                         
                     } 
                        system.debug('@@@@xref ends');
                     /**** Forming inventory Product address Maps here ****/
                     if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State' 
                        || attribute.Attribute_Name__c == 'City' || attribute.Attribute_Name__c == 'County'){
                            
                          String value='';
                            if(attribute.Attribute_Name__c == 'Country'){
                                if(attribute.String_Value__c != null){
                                    value = attribute.String_Value__c.toUpperCase();
                                }
                                
                            } 
                            else{
                                if(attribute.Picklist_Value__c != null){
                                     value = attribute.Picklist_Value__c.toUpperCase();
                                }
                               
                            }
                         
                           if(attribute.Attribute_Name__c == 'Country'){
                               invcountryset.put(ordChargeWrap.orderRPCWrap.id,value );
                           }
                           
                           if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State'){
                                if(invcountrystateset.containsKey(ordChargeWrap.orderRPCWrap.id)){
                                    string temp = invcountrystateset.get(ordChargeWrap.orderRPCWrap.id) + ';' + value;
                                    invcountrystateset.put(ordChargeWrap.orderRPCWrap.id, temp);
                                }
                                else{
                                    invcountrystateset.put(ordChargeWrap.orderRPCWrap.id,value );
                                }
                           }
                            
                            
                          if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State' 
                             || attribute.Attribute_Name__c == 'City' ){ 
                               if(optychargeVsinvAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)){
                                    string temp = optychargeVsinvAttributeString.get(ordChargeWrap.orderRPCWrap.id) + ';' + value;
                                   optychargeVsinvAttributeString.put(ordChargeWrap.orderRPCWrap.id, temp);
                                }
                              else{
                                  optychargeVsinvAttributeString.put(ordChargeWrap.orderRPCWrap.id,value );
                              }
                           }
                            
                          if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State' 
                             || attribute.Attribute_Name__c == 'County' ){ 
                               if(optychargeVsinvcountyAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)){
                                    string temp = optychargeVsinvcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id) + ';' + value;
                                   optychargeVsinvcountyAttributeString.put(ordChargeWrap.orderRPCWrap.id, temp);
                                }
                              else{
                                  optychargeVsinvcountyAttributeString.put(ordChargeWrap.orderRPCWrap.id,value );
                              }
                           }     
                            
                     }   
                    
                    //for checking maximum charactor in string
                    if(attribute.Attribute_Type__c == 'Text'){

                        if(attribute.Maximum_No_Of_Characters_In_Text__c != null){
                            if(attribute.String_Value__c != null){
                                if(attribute.String_Value__c.length() > attribute.Maximum_No_Of_Characters_In_Text__c){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You can enter '+ attribute.Maximum_No_Of_Characters_In_Text__c +'   charactor for '+attribute.Attribute_Name__c +' Attribute.'));
                                    return null;
                                }   
                            }

                        }

                    }
                    
                    /*****this logic is for value id population for city as city name will be duplicate in more than
                         * one state*/
                        if(attribute.Attribute_Name__c == 'Service City'){
                            attribute.Address_String__c = optychargeVsAttributeString.get(ordChargeWrap.orderRPCWrap.id);
                            system.debug('@@@@@attribute.Address_String__c'+attribute.Address_String__c);
                        }
                        
                        else if(attribute.Attribute_Name__c == 'Xref City'){
                            system.debug('@@@exception finding' + optychargeVsxrefAttributeString.get(ordChargeWrap.orderRPCWrap.id));
                            attribute.Address_String__c = optychargeVsxrefAttributeString.get(ordChargeWrap.orderRPCWrap.id);
                        }
                        else if(attribute.Attribute_Name__c == 'City'){
                            attribute.Address_String__c = optychargeVsinvAttributeString.get(ordChargeWrap.orderRPCWrap.id);
                        }
                        else if(attribute.Attribute_Name__c == 'Xref County'){
                            optychargeVsxrefcountyAttributeString.put(ordChargeWrap.orderRPCWrap.id, tempoptychargeVsxrefcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id));
                            
                            //As county is not unique
                            attribute.country_state_County_string__c  = tempoptychargeVsxrefcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id);
                            system.debug('@@@@@@ in xref County'+ optychargeVsxrefcountyAttributeString);
                        }
                      else if(attribute.Attribute_Name__c == 'Service State'){
                          
                           attribute.CountryState_String__c = countrystateset.get(ordChargeWrap.orderRPCWrap.id);
                      }
                      else if(attribute.Attribute_Name__c == 'Xref State'){
                          
                           attribute.CountryState_String__c = xrefcountrystateset.get(ordChargeWrap.orderRPCWrap.id);
                      }
                      else if(attribute.Attribute_Name__c == 'State'){
                          
                           attribute.CountryState_String__c = invcountrystateset.get(ordChargeWrap.orderRPCWrap.id);
                      }
                       else if(attribute.Attribute_Name__c == 'County'){
                            
                             attribute.country_state_County_string__c  =optychargeVsinvcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id);
                        }  
                        
                        system.debug('@@@@@ list adding');
                    
                    listofAttribute.add(attribute); 
                }
            }
            
             //for checking AOP
             set<string> geoAOPSet     = new set<String>();
             if(!aopSet.isEmpty()){
                      for(aggregateResult ag : [select AOP_Name__c aop
                                                       from Geo_Location__c
                                                       where AOP_Name__c IN:aopSet.values()
                                                Group by AOP_Name__c]){
                          geoAOPSet.add(string.valueOf(ag.get('aop')).toUpperCase());                              
                      }
             }
            
            
            //for checking country
            Set<String> geoCountryset    = new set<String>();
            Set<String> invgeoCountryset = new set<String>();      
            if(!countryset.isEmpty()){
                for(aggregateResult ag : [select CountryName__c country, 
                                                 Country_Inv_Flag__c countryFlag
                                              From Geo_Location__c 
                                            where RecordType.DeveloperName = 'M_H_GEO_Locations' AND (CountryName__c IN:countryset.values()
                                                  OR CountryName__c IN:invcountryset.values()
                                                  OR CountryName__c IN:xrefcountryset.values())
                                            group by CountryName__c,Country_Inv_Flag__c
                                       ]){
                    If(ag.get('country') != null){
                         If(String.valueOf(ag.get('countryFlag')) == 'Yes'){
                          invgeoCountryset.add(string.valueOf(ag.get('country')).toUpperCase());                      
                      }
                  // else{
                           geoCountryset.add(string.valueOf(ag.get('country')).toUpperCase()); 
                  // }                        
                   }                          
                                         
                                          
                }      
            }      
            system.debug('@@@@@geoCountryset'+geoCountryset);
                  
             //for checking country
            Set<String> geoCountrystateset    = new set<String>();
            Set<String> invgeoCountrystateset = new set<String>();      
            if(!countryset.isEmpty()){
                for(Geo_Location__c geo : [select countryStateString__c,
                                                  State_Inv_Flag__c
                                              From Geo_Location__c 
                                            where RecordType.DeveloperName = 'M_H_GEO_Locations' AND (countryStateString__c IN:countrystateset.values()
                                                  OR countryStateString__c IN:invcountrystateset.values()
                                                  OR countryStateString__c IN:xrefcountrystateset.values())
                                           
                                       ]){
                    If(geo.countryStateString__c != null){
                          if(geo.State_Inv_Flag__c == 'Yes'){
                            invgeoCountrystateset.add(geo.countryStateString__c.toUpperCase());                    
                       }
                       //else{
                           geoCountrystateset.add(geo.countryStateString__c.toUpperCase());
                       //}                     
                    }                      
                                           
                                                 
                }      
            }      
            system.debug('@@@@@geoCountrystateset'+geoCountrystateset);      
            
            system.debug('@@@@optychargeVsAttributeString'+optychargeVsAttributeString.values());  
            system.debug('@@@@@optychargeVsxrefAttributeString'+optychargeVsxrefAttributeString);
            //for checking total address      
            Set<String>addressSet          = new Set<String>();
            Set<String>invaddressSet       = new Set<String>();
            Set<String>invCountyaddressSet = new Set<String>(); 
            Set<String>countyaddressSet    = new Set<String>();        
           for(Geo_Location__c geo : [select address_String__c,City_Inv_Flag__c,
                                             country_state_County_string__c, County_Inv_Flag__c
                                              From Geo_Location__c 
                                            where RecordType.DeveloperName = 'M_H_GEO_Locations' AND (address_String__c IN:optychargeVsAttributeString.values()
                                                  OR address_String__c IN:optychargeVsxrefAttributeString.values()
                                                  OR address_String__c IN:optychargeVsinvAttributeString.values()
                                                  OR country_state_County_string__c IN:optychargeVsinvcountyAttributeString.values()
                                                  OR country_state_County_string__c IN:optychargeVsxrefcountyAttributeString.values())
                                       ]){
                  if(geo.City_Inv_Flag__c == 'Yes' || geo.County_Inv_Flag__c == 'Yes'){
                      invaddressSet.add(geo.address_String__c.toUpperCase());
                  }
                  if(geo.County_Inv_Flag__c == 'Yes'){
                      invCountyaddressSet.add(geo.country_state_County_string__c.toUpperCase());
                  }                         
                                            
                 // else{
                     countyaddressSet.add(geo.country_state_County_string__c.toUpperCase());
                      addressSet.add(geo.address_String__c.toUpperCase()); 
                 // }                          
                                          
            }
            
            system.debug('@@@addressSet'+addressSet);
            system.debug('@@@invcountrystateset'+invcountrystateset);  
            
            for(OrderChargeWrapper ordChargeWrap:listOfOrderChargeWrapper){
                if(countryset.containsKey(ordChargeWrap.orderRPCWrap.id)){
                    if(!geoCountryset.contains(countryset.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Service country on  '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + countryset.get(ordChargeWrap.orderRPCWrap.id)));
                        return null;
                    }
                }
              
                
                if(countrystateset.containsKey(ordChargeWrap.orderRPCWrap.id)){
                    if(!geoCountrystateset.contains(countrystateset.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        List<string> parts = countrystateset.get(ordChargeWrap.orderRPCWrap.id).split(';');
                        string param = ' ';
                        if(parts.size() > 1){
                            param       = parts[parts.size()-1];
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Service State on  '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + param));
                        return null;
                    }
                }
                
               
                
                if(optychargeVsAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)){
                    
                    if(!addressSet.contains(optychargeVsAttributeString.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        List<string> parts = optychargeVsAttributeString.get(ordChargeWrap.orderRPCWrap.id).split(';');
                        string param = ' ';
                        if(parts.size() > 1){
                            param       = parts[parts.size()-1];
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Service City on '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + param ));
                                        return null;
                    }
                   
                }
                
                  
                if(xrefcountryset.containsKey(ordChargeWrap.orderRPCWrap.id)){
                    if(!geoCountryset.contains(xrefcountryset.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Xref country on  '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + xrefcountryset.get(ordChargeWrap.orderRPCWrap.id)));
                        return null;
                    }
                }
                
                 if(xrefcountrystateset.containsKey(ordChargeWrap.orderRPCWrap.id)){
                    if(!geoCountrystateset.contains(xrefcountrystateset.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        List<string> parts = xrefcountrystateset.get(ordChargeWrap.orderRPCWrap.id).split(';');
                        string param = ' ';
                        if(parts.size() > 1){
                            param       = parts[parts.size()-1];
                        } 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Xref State on  '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + param));
                        
                        return null;
                    }
                }
                
                system.debug('@@@@before error');
                if(optychargeVsxrefcountyAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)){
                     system.debug('@@@@@@optychargeVsxrefcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id)'+optychargeVsxrefcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id));
                    
                    if(!countyaddressSet.contains(optychargeVsxrefcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        List<string> parts = optychargeVsxrefcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id).split(';');
                        string param = ' ';
                        if(parts.size() > 2){
                            param       = parts[parts.size()-1];
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Xref County on '+ ' ' + ordChargeWrap.orderRPCWrap.Name  + ' with value  '+ ' ' + param));
                        system.debug('@@@@@@ countyaddressSet'+geoCountrystateset);
                        system.debug('@@@@@@ optychargeVsxrefcountyAttributeString'+optychargeVsxrefcountyAttributeString); 
                                        return null;
                    }
                }
                
                else if(optychargeVsxrefAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)){
                     system.debug('@@@@@@optychargeVsxrefAttributeString.get(ordChargeWrap.orderRPCWrap.id)'+optychargeVsxrefAttributeString.get(ordChargeWrap.orderRPCWrap.id));
                    
                    if(!addressSet.contains(optychargeVsxrefAttributeString.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        List<string> parts = optychargeVsxrefAttributeString.get(ordChargeWrap.orderRPCWrap.id).split(';');
                        string param = ' ';
                        if(parts.size() > 1){
                            param       = parts[parts.size()-1];
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Xref City on '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + param));
                                        return null;
                    }
                }
                
               
                
                //*********Inventory validations *****************************/
                if(invcountryset.containsKey(ordChargeWrap.orderRPCWrap.id)){
                    if(!invgeoCountryset.contains(invcountryset.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                    
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Country on  '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + invcountryset.get(ordChargeWrap.orderRPCWrap.id)));
                        return null;
                    }
                }
                if(invcountrystateset.containsKey(ordChargeWrap.orderRPCWrap.id) 
                           && inventoryProducts.contains(ordChargeWrap.orderRPCWrap.Name.split(' -')[0]) 
                           && (Inventoried_Products_list__c.getValues(ordChargeWrap.orderRPCWrap.Name.split(' -')[0]).Type__c == 'State'
                               || Inventoried_Products_list__c.getValues(ordChargeWrap.orderRPCWrap.Name.split(' -')[0]).Type__c == 'City'
                               || Inventoried_Products_list__c.getValues(ordChargeWrap.orderRPCWrap.Name.split(' -')[0]).Type__c == 'County')
                            ){
                    if(!invgeoCountrystateset.contains(invcountrystateset.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        List<string> parts = invcountrystateset.get(ordChargeWrap.orderRPCWrap.id).split(';');
                        string param = ' ';
                        if(parts.size() > 1){
                            param       = parts[parts.size()-1];
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid State on  '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + param));
                        return null;
                    }
                } 
                
                if(optychargeVsinvAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)
                            &&  inventoryProducts.contains(ordChargeWrap.orderRPCWrap.Name.split(' -')[0])
                            && Inventoried_Products_list__c.getValues(ordChargeWrap.orderRPCWrap.Name.split(' -')[0]).Type__c == 'City'){
                    
                    if(!invaddressSet.contains(optychargeVsinvAttributeString.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        List<string> parts = optychargeVsinvAttributeString.get(ordChargeWrap.orderRPCWrap.id).split(';');
                        string param = ' ';
                        if(parts.size() > 1){
                            param       = parts[parts.size()-1];
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid City on '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + param));
                                        return null;
                    }
                }
                
                if(optychargeVsinvcountyAttributeString.containsKey(ordChargeWrap.orderRPCWrap.id)
                            &&  inventoryProducts.contains(ordChargeWrap.orderRPCWrap.Name.split(' -')[0])
                            && Inventoried_Products_list__c.getValues(ordChargeWrap.orderRPCWrap.Name.split(' -')[0]).Type__c == 'County'){
                    
                    if(!invCountyaddressSet.contains(optychargeVsinvcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        List<string> parts = optychargeVsinvcountyAttributeString.get(ordChargeWrap.orderRPCWrap.id).split(';');
                        string param = ' ';
                        if(parts.size() > 2){
                            param       = parts[parts.size()-1];
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid County on '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + param));
                                        return null;
                    }
                }
                 
                 if(aopSet.containsKey(ordChargeWrap.orderRPCWrap.id)){
                    if(!geoAOPSet.contains(aopSet.get(ordChargeWrap.orderRPCWrap.id).toUpperCase())){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid AOP Value '+ ' ' + ordChargeWrap.orderRPCWrap.Name + ' with value  '+ ' ' + aopSet.get(ordChargeWrap.orderRPCWrap.id)));
                        return null;
                    }
                }
            }
            if(!listofAttribute.isEmpty()){
                upsert listofAttribute;
            }
            //}
        }catch(Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An exception has occured. Exception message is : ' + ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;    
        }     

        return new PageReference('/' + order.Id);
    }

    //wrapper class
    public class OrderChargeWrapper{

        public boolean isChecked {get;set;}
        public invoiceit_s__Job_Rate_Plan_Charge__c orderRPCWrap{get;set;}      

        public list<AttributeNames> listOfAttributes {get;set;}
         public  OrderChargeWrapper(){
            listOfAttributes = new list<AttributeNames>();
        }   
    }   

    public class AttributeNames {
        public Order_Charge_Attribute__c orderChargeAttribute {get;set;}
        public List<SelectOption> attributeOptions {get;set;}
        public integer maxValue {get;set;}
        public integer mixValue {get;set;}
        public list<SelectOption> listOfAttributesNew {get;set;}  
        public list<SelectOption> listOfAttributesLatest {get;set;} 
        public AttributeNames(){
            listOfAttributesNew = new list<SelectOption>();
            listOfAttributesLatest = new list<SelectOption>();
        }
    }
    
   
    /*
   public void populatingCountyCityValue(){
        
        String attributeName = ApexPages.currentPage().getParameters().get('attributeName');
        String chargeId = ApexPages.currentPage().getParameters().get('chargeId');
        String selectValue = ApexPages.currentPage().getParameters().get('selectValue');
        
               
            AttributeNames charAttLocal;  
            list<String> countyNames;  
            listOfCounties = new list<State_County__c>();
            for(OrderChargeWrapper chargeWrap : listOfOrderChargeWrapper){                
                    for(AttributeNames charAtt : chargeWrap.listOfAttributes){                        
                        if(charAtt.orderChargeAttribute.Picklist_Value__c != null && (charAtt.orderChargeAttribute.Attribute_Name__c == 'State'|| charAtt.orderChargeAttribute.Attribute_Name__c == 'Xref State') && charAtt.orderChargeAttribute.id == selectValue && charAtt.orderChargeAttribute.Order_Rate_Plan_Charge__c == chargeId){
                            listOfCounties = [Select id, County__c,City__c from State_County__c Where State__c =: charAtt.orderChargeAttribute.Picklist_Value__c];
                            listOfCounties.sort();
                            break;
                        }
                        
                    }
                }
            for(OrderChargeWrapper chargeWrap : listOfOrderChargeWrapper){
                //if(chargeWrap.opptChargeWrap.id == chargeId){
                    for(AttributeNames charAtt : chargeWrap.listOfAttributes){
                        if(charAtt.orderChargeAttribute.Attribute_Name__c == 'City' && charAtt.orderChargeAttribute.Order_Rate_Plan_Charge__c == chargeId){
                                charAtt.attributeOptions = new List<SelectOption>();
                                charAtt.attributeOptions.add(new SelectOption('--None--' ,'--None--'));
                                charAtt.listOfAttributesNew = new list<SelectOption>();
                                charAtt.listOfAttributesLatest = new list<SelectOption>();
                                integer i = 0;
                                for(State_County__c cityName : listOfCounties){
                                    if(i <= 998){
                                       charAtt.attributeOptions.add(new SelectOption(cityName.City__c ,cityName.City__c)); 
                                       i++;
                                       System.debug('charAtt.attributeOptions'+charAtt.attributeOptions.size());
                                    }
                                    if(i <=1996 && i >= 999){
                                        charAtt.listOfAttributesNew.add(new SelectOption(cityName.City__c ,cityName.City__c));
                                        i++;
                                        System.debug('charAtt.listOfAttributesNew'+charAtt.listOfAttributesNew.size());
                                    }
                                    if(i >= 1997){
                                        charAtt.listOfAttributesLatest.add(new SelectOption(cityName.City__c ,cityName.City__c));
                                        i++;
                                        System.debug('charAtt.listOfAttributesLatest'+charAtt.listOfAttributesLatest.size());
                                    }
                                   // charAtt.attributeOptions.add(new SelectOption(cityName.City__c ,cityName.City__c));                            
                                }
                        }else if((charAtt.orderChargeAttribute.Attribute_Name__c == 'County' || charAtt.orderChargeAttribute.Attribute_Name__c == 'Xref County' ) && charAtt.orderChargeAttribute.Order_Rate_Plan_Charge__c == chargeId){
                            charAtt.attributeOptions = new List<SelectOption>();
                            charAtt.attributeOptions.add(new SelectOption('--None--' ,'--None--'));
                            set<string> localSet = new set<string>();
                            countyNames = new list<String>();
                            for(State_County__c stateCountyObj : listOfCounties){
                                localSet.add(stateCountyObj.County__c);      
                            }
                            countyNames.addAll(localSet);
                            countyNames.sort();       
                            for(String countyName : countyNames){
                                if(countyName != null)
                                charAtt.attributeOptions.add(new SelectOption(countyName ,countyName));                            
                            }
                        }else if(charAtt.orderChargeAttribute.Attribute_Name__c == 'City' && charAtt.orderChargeAttribute.Order_Rate_Plan_Charge__c != chargeId){
                            charAtt.attributeOptions = new list<SelectOption>();
                            if(charAtt.orderChargeAttribute.Picklist_Value__c != null)
                                charAtt.attributeOptions.add(new SelectOption(charAtt.orderChargeAttribute.Picklist_Value__c,charAtt.orderChargeAttribute.Picklist_Value__c));
    
                            charAtt.listOfAttributesNew = new list<SelectOption>();
                            charAtt.listOfAttributesLatest = new list<SelectOption>();
                      }else if((charAtt.orderChargeAttribute.Attribute_Name__c == 'County'|| charAtt.orderChargeAttribute.Attribute_Name__c == 'Xref County' ) && charAtt.orderChargeAttribute.Order_Rate_Plan_Charge__c != chargeId){
                            charAtt.attributeOptions = new list<SelectOption>();
                            if(charAtt.orderChargeAttribute.Picklist_Value__c != null)
                                charAtt.attributeOptions.add(new SelectOption(charAtt.orderChargeAttribute.Picklist_Value__c,charAtt.orderChargeAttribute.Picklist_Value__c));
    
                            charAtt.listOfAttributesNew = new list<SelectOption>();
                            charAtt.listOfAttributesLatest = new list<SelectOption>();
                      }
                    }
               // }
               //break;
            }      
    }*/
    
    /*
    public void onChangeCountry(){
        String attributeName = ApexPages.currentPage().getParameters().get('attributeName');
        String chargeId = ApexPages.currentPage().getParameters().get('chargeId');
        String selectValue = ApexPages.currentPage().getParameters().get('selectValue');
        
        for(OrderChargeWrapper chargeWrap : listOfOrderChargeWrapper){
                for(AttributeNames charAtt : chargeWrap.listOfAttributes){
                    if(charAtt.orderChargeAttribute.Picklist_Value__c != null && (charAtt.orderChargeAttribute.Attribute_Name__c == 'County'|| charAtt.orderChargeAttribute.Attribute_Name__c == 'Xref County' ) && charAtt.orderChargeAttribute.id == selectValue && charAtt.orderChargeAttribute.Order_Rate_Plan_Charge__c == chargeId){
                       listOfCounties = [Select id, County__c,City__c from State_County__c Where County__c =: charAtt.orderChargeAttribute.Picklist_Value__c];
                       listOfCounties.sort(); 
                    }
                    
                    if(charAtt.orderChargeAttribute.Attribute_Name__c == 'City' && charAtt.orderChargeAttribute.Order_Rate_Plan_Charge__c == chargeId && listOfCounties.size() > 0){
                        charAtt.attributeOptions = new List<SelectOption>();
                                charAtt.attributeOptions.add(new SelectOption('--None--' ,'--None--'));
                                charAtt.listOfAttributesNew = new list<SelectOption>();
                                charAtt.listOfAttributesLatest = new list<SelectOption>();
                                integer i = 0;
                                for(State_County__c cityName : listOfCounties){
                                    if(i <= 998){
                                       charAtt.attributeOptions.add(new SelectOption(cityName.City__c ,cityName.City__c)); 
                                       i++;
                                       System.debug('charAtt.attributeOptions'+charAtt.attributeOptions.size());
                                    }
                                    if(i <=1996 && i >= 999){
                                        charAtt.listOfAttributesNew.add(new SelectOption(cityName.City__c ,cityName.City__c));
                                        i++;
                                        System.debug('charAtt.listOfAttributesNew'+charAtt.listOfAttributesNew.size());
                                    }
                                    if(i >= 1997){
                                        charAtt.listOfAttributesLatest.add(new SelectOption(cityName.City__c ,cityName.City__c));
                                        i++;
                                        System.debug('charAtt.listOfAttributesLatest'+charAtt.listOfAttributesLatest.size());
                                    }
                                   // charAtt.attributeOptions.add(new SelectOption(cityName.City__c ,cityName.City__c));                            
                                }
                    }else if(charAtt.orderChargeAttribute.Attribute_Name__c == 'City' && charAtt.orderChargeAttribute.Order_Rate_Plan_Charge__c != chargeId){
                            charAtt.attributeOptions = new list<SelectOption>();
                            if(charAtt.orderChargeAttribute.Picklist_Value__c != null)
                                charAtt.attributeOptions.add(new SelectOption(charAtt.orderChargeAttribute.Picklist_Value__c,charAtt.orderChargeAttribute.Picklist_Value__c));

                            charAtt.listOfAttributesNew = new list<SelectOption>();
                            charAtt.listOfAttributesLatest = new list<SelectOption>();
                        }
                }
            }
    }
    */
    
}