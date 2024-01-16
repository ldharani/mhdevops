/*  Service Country = Text Field         Country = Text Value      Xref Country = Text Value
Service State = Picklist             State   = Picklist        Xref State   = Picklist
Service City = Text Field            City    = Picklist        Xref City    = Text Value
Service Zip code = Text Field        County = Picklist         

*/

public with sharing class AddingOpptChargeExten2Duplicate {
    
    public Opportunity oppt{get;set;}
    public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOfOpptCharge;
    public boolean isVisible{get;set;}
    public list<OpptChargeWrapper> listOfOpptChargeWrapper{get;set;}
    OpptChargeWrapper opptChargeWrapperObj;
    Id opptId;
    list<State_County__c> listOfStates;
    list<string> stateNames;
    list<State_County__c> listOfCounties;
    list<State_County__c>listOfCities;
    String ProfileName;
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
    String Attributevalue;
    public Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chargeMap {get;set;}
    public Map<Id,OpptChargeWrapper> chargeAttributesMap {get;set;}
    public Set<String> prodTypeList{get;set;}
    Map<id,String> aopGeoSet;
    Set<Id> existingIds {get;set;}
    public Map<Id, String> optychargeVSparentURL;
    public Map<Id, String> opptychargeVsChatURL;
    public Boolean hasError {
        get {
            return ApexPages.hasMessages();
        }
    }
    
    ClassForNavigation AddingOrderNavigationTestObj;
    public AddingOpptChargeExten2Duplicate(ApexPages.StandardController controller) {
        
        opptId = ApexPages.currentPage().getParameters().get('id');
        oppt = [SELECT name, Amount, CloseDate,StageName,invoiceit_crmx__Start_Date__c
                FROM Opportunity  
                WHERE id =:opptId];
        
        Id profileId=userinfo.getProfileId();
        profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('@@@@ProfileName'+profileName);
        
        
        //query for list of oppt charges along with oppt charge attribute
        listOfOpptCharge = [SELECT Name,invoiceit_crmx__Opportunity_Rate_Plan__c,SIN__c,invoiceit_crmx__Accounting_Code__c,
                             invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,
                            Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name,
                            Chat_Parent_Opportunity_Rate_Plan_Charge__c,invoiceit_crmx__Opportunity__r.StageName,Created_From_Charge__c,
                            (SELECT Attribute_Order__c,Picklist_Value__c,Required__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__r.StageName,
                             Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, Long_text_value__c,Social_Starter_Form_URL__c,
                             Attribute_Picklist_Values__c, Name,Attribute_Name__c,Attribute_Type__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Accounting_Code__c, 
                             Boolean_Value__c,Date_Value__c,Phone_Value__c,Number_Value__c,Address_String__c,
                             Opportunity_Rate_Plan_Charge__c,String_Value__c,Address_Order__c,Created_from_Modify__c,CountryState_String__c, 
                             ParentOpportunityChargeAttribute__c,Parent_Opportunity_Charge_Attribute_URL__c
                             FROM Opportunity_Charge_Attributes__r ORDER By Address_Order__c ASC,Attribute_Order__c DESC NULLS LAST)
                            FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                            WHERE  invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c  =:opptId];
       

       //To carry chat parent URL attribute to add on chats level
       optychargeVSparentURL = new Map<Id, String>();
       //To carry chat URL attribute to add on chat level
       opptychargeVsChatURL = new Map<Id,String>();
       for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opcharge :listOfOpptCharge){
           //checking for parent Opportunity rate plan charge in child opty
           if(opcharge.Chat_Parent_Opportunity_Rate_Plan_Charge__c == NULL){
               for(Opportunity_Charge_Attribute__c oca : opcharge.Opportunity_Charge_Attributes__r){
                   if(oca.ParentOpportunityChargeAttribute__c != NULL){
                       optychargeVSparentURL.put(opcharge.id, oca.Parent_Opportunity_Charge_Attribute_URL__c);
                   }else{
                       if((oca.Attribute_Name__c == 'URL' || oca.Attribute_Name__c == 'Domain Name') && oca.String_Value__c!=Null){
                          
                           opptychargeVsChatURL.put(opcharge.id,oca.String_Value__c);
                       }
                   }
                }
           }
       }
       
        system.debug('@@@@opptychargeVsChatURL'+opptychargeVsChatURL);
        AddingOrderNavigationTestObj = new ClassForNavigation(listOfOpptCharge);
        chargeMap = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        chargeAttributesMap = new Map<Id,OpptChargeWrapper>();
        prodTypeList = new set<string>();
        existingIds = new Set<Id>();
        
        List<AOPGeo_Products_List__c> iplist = AOPGeo_Products_List__c.getall().values();
        for(AOPGeo_Products_List__c ip: iplist){
            prodTypeList.add(ip.Name);            
        }  
        first();
        
    }
    public PageReference refreshPageCalled(){
        system.debug('called refresh');
        /*if (ApexPages.hasMessages()) {
return null;
} else {
PageReference page = new PageReference('/apex/addingOpptChargeAttributeDuplicate?id=' + oppt.Id);
page.setRedirect(true);
return page; 
}*/
        PageReference page = new PageReference('/apex/addingOpptChargeAttributeDuplicate?id=' + oppt.Id);
        page.setRedirect(true);
        return page;
        
    }
    public Boolean hasNext {
        get {
            if(AddingOrderNavigationTestObj != null) {
                return AddingOrderNavigationTestObj.hasNext();    
            }
            else {
                return false;
            }
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            if(AddingOrderNavigationTestObj != null) {
                return AddingOrderNavigationTestObj.hasPrevious();        
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
        listOfOpptCharge = AddingOrderNavigationTestObj.next();
        populateList();
    }
    
    public void previous() { 
        listOfOpptCharge = AddingOrderNavigationTestObj.previous();
        populateList();
    }
    
    public void first() {
        listOfOpptCharge = AddingOrderNavigationTestObj.first();
        populateList();
    }
    
    public void last() {
        listOfOpptCharge = AddingOrderNavigationTestObj.last();
        populateList();
    }
    
    
    public void populateList() {
          existingIds = new Set<Id>();
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
        listOfOpptChargeWrapper = new  list<OpptChargeWrapper>();
        Map<String,boolean> isAOPGeoExistsMap = new Map<String,boolean>(); 
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge : listOfOpptCharge) {
            
            Integer rows = 0;
            system.debug('@@@charge name'+ charge.Name);
            system.debug('@@@@@charge'+ charge.SIN__c);
            opptChargeWrapperObj = new OpptChargeWrapper();
            opptChargeWrapperObj.opptChargeWrap = charge;
            opptChargeWrapperObj.isChecked = false;
            chargeMap.put(charge.id,charge);
            if(charge.SIN__c == null || charge.SIN__c ==''){
                opptChargeWrapperObj.disable = false;
            }
            else{
                if(profileName !='Data Governor' && profileName !='System Administrator' && profileName !='Fulfillment Ops Rep'){                    
                    opptChargeWrapperObj.disable = true;
                }
                
            }
            
            /**********akash : 23/03/2018****************************************/
           
            
            if(!optychargeVSparentURL.isEmpty()){
                if(charge.Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL && optychargeVSparentURL.containsKey(charge.Chat_Parent_Opportunity_Rate_Plan_Charge__c)){
                     opptChargeWrapperObj.urlText = optychargeVSparentURL.get(charge.Chat_Parent_Opportunity_Rate_Plan_Charge__c);
                }
                else if(charge.Chat_Parent_Opportunity_Rate_Plan_Charge__c == NULL && optychargeVSparentURL.containsKey(charge.id)){
                    opptChargeWrapperObj.urlText = optychargeVSparentURL.get(charge.id);
                    system.debug('@@@@charge Text '+ charge.id);
                }
            }
            //Ronak added the code for showing the chat URL on the Add On features
            if(!opptychargeVsChatURL.isempty()){
                System.debug('=====inside my method----'+opptychargeVsChatURL.containsKey(charge.Chat_Parent_Opportunity_Rate_Plan_Charge__c));
                if(charge.Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL && opptychargeVsChatURL.containsKey(charge.Chat_Parent_Opportunity_Rate_Plan_Charge__c)){
                     opptChargeWrapperObj.urlText = '*Associated to chat : ' + charge.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name +'*Attribute::' + opptychargeVsChatURL.get(charge.Chat_Parent_Opportunity_Rate_Plan_Charge__c);
                }    
            }
            
            
            list<AttributeNames> listOfAttributes = new list<AttributeNames>();
            list<AttributeNames> listOfAttributes1 = new list<AttributeNames>();            
            system.debug('prodTypeList  >>>'+prodTypeList);
            for(Opportunity_Charge_Attribute__c charAtt : charge.Opportunity_Charge_Attributes__r) {                
                system.debug('charAtt >>>'+charAtt );
                AttributeNames a1;
                if(prodTypeList.contains(charge.Name) && (charAtt.Attribute_Name__c.contains('AOP') || charAtt.Attribute_Name__c == 'Geo') && !charAtt.Attribute_Name__c.contains('AOP/Geo')){
                    a1 = new AttributeNames();
                    system.debug('in if'+charAtt.Attribute_Name__c);
                }else{
                    a1 = new AttributeNames();
                    if(charAtt.Attribute_Name__c.contains('AOP/Geo')){
                        a1.attrName = 'AOP/Geo';
                    }else{
                        a1.attrName = charAtt.Attribute_Name__c;
                    }
                    a1.opptyChargeAttribute = charAtt;                
                    rows = rows + 1;
                    a1.rowCount = rows;
                }
                if(profileName !='Data Governor' && profileName !='System Administrator' && profileName !='Fulfillment Ops Rep'){                    
                    if(charAtt.Created_from_Modify__c && !charAtt.Attribute_Name__c.contains('AOP/Geo'))
                        a1.chargedisable= true;
                }
                //spilting picklist value and displaying in a drop down
                if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Attribute_Picklist_Values__c != null && charAtt.Attribute_Name__c != 'State' && charAtt.Attribute_Name__c != 'County' && charAtt.Attribute_Name__c != 'City') {
                    
                    a1.attributeOptions = new List<SelectOption>();
                    // add the first option as none
                    a1.attributeOptions.add(new SelectOption('', '--None--'));
                    for(string s : charAtt.Attribute_Picklist_Values__c.split(',')) { 
                        string s1 = s.trim();                                                                   
                        a1.attributeOptions.add(new SelectOption(s1 ,s1 ));    
                    }
                    system.debug('a1.attributeOptions' +a1.attributeOptions);
                    
                } else {                    
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
                    
                    if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Attribute_Name__c == 'County') {
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
                            system.debug('City========a1.attributeOptions'+a1.attributeOptions);
                        } 
                        a1.attributeOptions.add(new SelectOption('--None--', '--None--'));   
                    }
                    if(charAtt.Attribute_Type__c == 'String' && charAtt.Attribute_Name__c.contains('AOP/Geo')) {
                        a1.attributeOptions = new List<SelectOption>();
                        if(charAtt.String_Value__c != null){
                            if(charAtt.String_Value__c.contains(';')){
                                List<string> aopList = new List<string>();
                                aopList = charAtt.String_Value__c.split(';');
                                system.debug('======aopList:'+aopList);
                                for (String s : aopList){
                                    a1.attributeOptions.add(new SelectOption(s, s));
                                    system.debug('========a1.attributeOptions'+a1.attributeOptions);
                                }
                            }
                        }
                        a1.attributeOptions.add(new SelectOption('--None--', '--None--'));   
                    }
                    if(charAtt.Attribute_Name__c.contains('AOP/Geo')){
                        existingIds.add(charAtt.Id);
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
                            isAOPGeoExistsMap.put(charge.id,true);
                        }
                    }                    
                }           
                if(a1 != null){
                    listOfAttributes.add(a1);                               
                    opptChargeWrapperObj.listOfAttributes.add(a1);
                    system.debug('values in attribute'+opptChargeWrapperObj.listOfAttributes);
                }
                
            }
            if(prodTypeList.contains(charge.Name) && !isAOPGeoExistsMap.containsKey(charge.id)){// == 'SEO Advanced'){
                AttributeNames aa1 = new AttributeNames();                
                aa1.rowCount = rows + 1;
                Opportunity_Charge_Attribute__c oca = new Opportunity_Charge_Attribute__c();
                oca.Attribute_Name__c = 'AOP/Geo 1';
                //oca.Attribute_Type__c = 'Picklist';
                oca.Attribute_Type__c = 'String';
                oca.Attribute_Order__c = aa1.rowCount;               
                oca.Id = null;
                aa1.chargeId = charge.Id;                
                aa1.opptyChargeAttribute = oca;
                aa1.opptyChargeAttribute.CountryState_String__c = 'N/A';
                aa1.attrName = 'AOP/Geo';
                aa1.showAdd = true;
                //opptChargeWrapperObj.opptChargeWrap.Name = 'SEO Advanced';
                listOfAttributes1.add(aa1);                
                
            }
            listOfAttributes.addAll(listOfAttributes1);
            opptChargeWrapperObj.listOfAttributes.addAll(listOfAttributes1); 
            chargeAttributesMap.put(charge.id,opptChargeWrapperObj);
            
            listOfOpptChargeWrapper.add(opptChargeWrapperObj);
        }
        
        system.debug('@@@@existingIds'+existingIds.size());
        system.debug('listOfOpptChargeWrapper in populatelist:'+listOfOpptChargeWrapper);
    }
    public String addChargeObj {get;set;}
    //public String addChargeWrapper {get;set;}
    public String fromRowNum {get;set;}
    public String deleteRowNum {get;set;}
    public Integer MAX_ROWS {get;set;}
    public Integer ROWS_COUNT {get;set;} 
    public void addNewRow(){
        system.debug('in add new row'+fromRowNum);
        ROWS_COUNT = 0;
        MAX_ROWS = 30;
        AttributeNames aa1 = new AttributeNames();
        aa1.rowCount = Integer.valueof(fromRowNum)+1;
        Opportunity_Charge_Attribute__c oca = new Opportunity_Charge_Attribute__c();
        oca.Attribute_Name__c = 'AOP/Geo';
        //oca.Attribute_Type__c = 'Picklist';
        oca.Attribute_Type__c = 'String';                
        aa1.opptyChargeAttribute = oca;
        aa1.opptyChargeAttribute.CountryState_String__c = 'N/A';
        aa1.chargeId = addChargeObj;
        OpptChargeWrapper wrapObj  = chargeAttributesMap.get(addChargeObj);    
        wrapObj.opptChargeWrap = chargeMap.get(addChargeObj);
        aa1.attrName = 'AOP/Geo';
        
        for(AttributeNames a:wrapObj.listOfAttributes){
            if(a.opptyChargeAttribute.Attribute_Name__c.contains('AOP/Geo')){
                ROWS_COUNT = ROWS_COUNT +1;
                a.opptyChargeAttribute.Attribute_Order__c = ROWS_COUNT;
                a.opptyChargeAttribute.Attribute_Name__c = 'AOP/Geo '+ Integer.valueof(ROWS_COUNT);
                aa1.showAdd = false;
            }            
            
        }
        
        
        oca.Attribute_Name__c = 'AOP/Geo '+ Integer.valueof(ROWS_COUNT +1);
        if(ROWS_COUNT < MAX_ROWS){
            //aa1.opptyChargeAttribute.Attribute_Order__c = ROWS_COUNT +1;
            aa1.showAdd = true;
            wrapObj.listOfAttributes.add(aa1);
        }
        system.debug('list size'+ROWS_COUNT );
        system.debug('listOfOpptChargeWrapper here:'+listOfOpptChargeWrapper);
        
    }
    
    public void deleteRow(){
        OpptChargeWrapper wrapObj  = chargeAttributesMap.get(addChargeObj);
        Integer ROWS_COUNT = 0;
        system.debug('deleteRowNum here'+deleteRowNum);
        wrapObj.listofAttributes.remove(Integer.valueOf(deleteRowNum)-1);
        Integer attrSize = wrapObj.listofAttributes.size();
        AttributeNames aa = wrapObj.listOfAttributes[attrSize-1];
        Integer rowSeq = 0;
        for(AttributeNames a:wrapObj.listOfAttributes){
            if(a.opptyChargeAttribute.Attribute_Name__c.contains('AOP/Geo')){
                ROWS_COUNT = ROWS_COUNT +1;
                
            }
            a.rowCount = rowSeq + 1;
            rowSeq++; 
        }
        if(ROWS_COUNT != 1){
            aa.opptyChargeAttribute.Attribute_Order__c = null;
            
            //aa.opptyChargeAttribute.Attribute_Order__c = ROWS_COUNT +1;
        }else{
            // To show add symbolto AOP/Geo 1
            aa.opptyChargeAttribute.Attribute_Order__c = Integer.valueOf(deleteRowNum);
            
        }
        //return new PageReference('/apex/addingOpptChargeAttributeDuplicate?scontrolCaching=1&id=' + oppt.Id);        
    }
    
    //saving oppt charge attribute 
    public PageReference save(){
        try {    
            list<Opportunity_Charge_Attribute__c> listofAttribute = new list<Opportunity_Charge_Attribute__c>();
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
            aopGeoSet                           = new Map<id,String>();
            
            //initializing inventoried products set
            Set<String> inventoryProducts = new Set<String>{'Preferred Banner Placements',
                'Preferred City Results',
                'Preferred County Results',
                'Preferred Martindale.com Results',
                'Lawyers.com Shared County Results',
                'Preferred National Links',
                'Preferred National Results',
                'Preferred State Links',
                'Preferred State Results'}; 
                    
                    //Set<Id> deleteIds = new Set<Id>();
                    system.debug('listOfOpptChargeWrapper '+listOfOpptChargeWrapper );
            List<Opportunity_Charge_Attribute__c> insertList = new List<Opportunity_Charge_Attribute__c>();
            if(listOfOpptChargeWrapper != null){ 
                for(OpptChargeWrapper opptChargeWrap:listOfOpptChargeWrapper){
                    List<Opportunity_Charge_Attribute__c > tempAttrList = new List<Opportunity_Charge_Attribute__c >();
                    
                    //If save done, with empty rows, to get add button to last row- start
                    Integer ROWS_COUNT = 0;
                    Integer NOTROWS_COUNT = 0; 
                    for(AttributeNames a: opptChargeWrap.listOfAttributes){
                        if(a.opptyChargeAttribute.Attribute_Name__c.contains('AOP/Geo') && a.opptyChargeAttribute.String_Value__c != null){
                            ROWS_COUNT = ROWS_COUNT +1;                         
                        }else if(!a.opptyChargeAttribute.Attribute_Name__c.contains('AOP/Geo')){
                            NOTROWS_COUNT = NOTROWS_COUNT+1;
                        }
                    }
                    system.debug('ROWS_COUNT here>>>>:::'+ROWS_COUNT+'::::NOTROWS_COUNT:::'+NOTROWS_COUNT );
                    if(ROWS_COUNT >1){
                        if(NOTROWS_COUNT > 0){
                            AttributeNames aa = opptChargeWrap.listOfAttributes[Integer.valueof(NOTROWS_COUNT)+ Integer.valueof(ROWS_COUNT)-1];                    
                            aa.opptyChargeAttribute.Attribute_Order__c = null;
                            system.debug('@@@@aa.opptyChargeAttribute.Attribute_Name__c'+aa.opptyChargeAttribute.Attribute_Name__c);
                            
                            
                            
                        }
                    }
                    //If save done, with empty rows, to get add button to last row -end
                    
                    
                    for(AttributeNames attribute: opptChargeWrap.listOfAttributes){
                        
                        //system.debug('attribute.opptyChargeAttribute.Id here:::'+attribute.opptyChargeAttribute.Id);
                        /*if(attribute.opptyChargeAttribute.Attribute_Name__c.contains('AOP/Geo') && attribute.opptyChargeAttribute.Attribute_Order__c != null && attribute.opptyChargeAttribute.Id == null && attribute.opptyChargeAttribute.Picklist_Value__c == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please select '+attribute.opptyChargeAttribute.Attribute_Name__c +' Attribute.'));
                        return null;}*/
                        
                        system.debug('@@@@attribute.opptyChargeAttribute.Id here:::'+attribute.opptyChargeAttribute.Id);
                        system.debug('@@@@@attribute.opptyChargeAttribute.Attribute_Name__c here:::'+attribute.opptyChargeAttribute.Attribute_Name__c);
                        system.debug('@@@@attribute.opptyChargeAttribute.String_Value__c here:::'+attribute.opptyChargeAttribute.String_Value__c );
                        
                        if(attribute.opptyChargeAttribute.CountryState_String__c != 'N/A' && attribute.opptyChargeAttribute.CountryState_String__c != null){
                        }else{
                            attribute.opptyChargeAttribute.CountryState_String__c = 'N/A';
                        }
                        if(attribute.opptyChargeAttribute.Attribute_Name__c == 'AOP/Geo 1' && attribute.opptyChargeAttribute.Attribute_Order__c != null && attribute.opptyChargeAttribute.Id == null && attribute.opptyChargeAttribute.String_Value__c == null){
                            Opportunity_Charge_Attribute__c op = new Opportunity_Charge_Attribute__c();
                            op.Attribute_Name__c = attribute.opptyChargeAttribute.Attribute_Name__c;
                            op.Attribute_Type__c = attribute.opptyChargeAttribute.Attribute_Type__c;
                            op.String_Value__c = '' + ' ; '+''+ ' ; '+attribute.opptyChargeAttribute.CountryState_String__c+ ' ; '+''+' ; ';
                            op.Attribute_Order__c = attribute.opptyChargeAttribute.Attribute_Order__c;
                            
                            op.Opportunity_Rate_Plan_Charge__c = attribute.chargeId;
                            insertList.add(op);
                            system.debug('@@@@@@@test1');
                        }                        
                        else if(attribute.opptyChargeAttribute.Attribute_Name__c.contains('AOP/Geo') && attribute.opptyChargeAttribute.Id == null && attribute.opptyChargeAttribute.String_Value__c != null){
                            system.debug('testqqqqq'+attribute);
                            Opportunity_Charge_Attribute__c op = new Opportunity_Charge_Attribute__c();
                            op.Attribute_Name__c = attribute.opptyChargeAttribute.Attribute_Name__c;
                            op.Attribute_Type__c = attribute.opptyChargeAttribute.Attribute_Type__c;
                            op.String_Value__c = attribute.opptyChargeAttribute.Picklist_Value__c + ' ; '+attribute.opptyChargeAttribute.Address_String__c+ ' ; '+attribute.opptyChargeAttribute.CountryState_String__c+ ' ; '+attribute.opptyChargeAttribute.String_Value__c+' ; ';
                            op.Attribute_Order__c = attribute.opptyChargeAttribute.Attribute_Order__c;
                            
                            op.Opportunity_Rate_Plan_Charge__c = attribute.chargeId;
                            insertList.add(op);
                            system.debug('@@@@@@@test2');
                        }else if(attribute.opptyChargeAttribute.Attribute_Name__c.contains('AOP/Geo') && attribute.opptyChargeAttribute.Id != null && attribute.opptyChargeAttribute.String_Value__c != null){
                            Opportunity_Charge_Attribute__c op = new Opportunity_Charge_Attribute__c();
                            op.id = attribute.opptyChargeAttribute.Id;
                            op.String_Value__c = attribute.opptyChargeAttribute.Picklist_Value__c + ' ; '+attribute.opptyChargeAttribute.Address_String__c+ ' ; '+attribute.opptyChargeAttribute.CountryState_String__c+ ' ; '+attribute.opptyChargeAttribute.String_Value__c+' ; ';
                            op.Address_String__c = '';
                            op.Picklist_Value__c = '';
                            insertList.add(op);
                            system.debug('@@@@@@test3');
                            if(existingIds.contains(attribute.opptyChargeAttribute.Id)){
                                existingIds.remove(attribute.opptyChargeAttribute.Id);
                                system.debug('test4'+existingIds);
                            }
                        }
                        if(attribute.opptyChargeAttribute.Attribute_Name__c == 'AOP/Geo 1' && attribute.opptyChargeAttribute.Id != null && attribute.opptyChargeAttribute.String_Value__c == null){
                            system.debug('test2tesstts');
                            Opportunity_Charge_Attribute__c op = new Opportunity_Charge_Attribute__c();
                            op.id = attribute.opptyChargeAttribute.Id;
                            op.Attribute_Name__c = attribute.opptyChargeAttribute.Attribute_Name__c;
                            op.Attribute_Type__c = attribute.opptyChargeAttribute.Attribute_Type__c;
                            op.String_Value__c = '' + ' ; '+''+ ' ; '+attribute.opptyChargeAttribute.CountryState_String__c+ ' ; '+''+' ; ';
                            op.Attribute_Order__c = attribute.opptyChargeAttribute.Attribute_Order__c;
                            
                            //op.Opportunity_Rate_Plan_Charge__c = attribute.chargeId;
                            insertList.add(op);
                            
                            if(existingIds.contains(attribute.opptyChargeAttribute.Id)){ 
                                system.debug('test4444'+existingIds);
                                existingIds.remove(attribute.opptyChargeAttribute.Id);
                            }
                        }
                        
                    }
                    system.debug('existingIds here:::'+existingIds);
                    for(Opportunity_Charge_Attribute__c attribute:opptChargeWrap.opptChargeWrap.Opportunity_Charge_Attributes__r){
                        
                        
                        /***Added by Sai *******/
                        // forming all service address maps here
                        if(attribute.Attribute_Name__c.contains('AOP') && (!attribute.Attribute_Name__c.contains('AOP/Geo')) && (attribute.Picklist_Value__c != NULL && attribute.Picklist_Value__c !='')){
                            system.debug('@@@@ in AOP Set' + opptChargeWrap.opptChargeWrap.Name);
                            aopSet.put(opptChargeWrap.opptChargeWrap.id, attribute.Picklist_Value__c.toUpperCase());
                        }   
                        
                        /*if(attribute.Attribute_Name__c.contains('AOP/Geo') && (attribute.Picklist_Value__c != NULL && attribute.Picklist_Value__c !='')){
system.debug('@@@@ in AOPGeo Set' + opptChargeWrap.opptChargeWrap.Name);
aopGeoSet.put(opptChargeWrap.opptChargeWrap.id, attribute.Picklist_Value__c.toUpperCase());
}*/
                        
                        if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service State' 
                           || attribute.Attribute_Name__c == 'Service City'){
                               string serviceValue = '';
                               if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service City'){
                                   if(attribute.String_Value__c != null){
                                       serviceValue = attribute.String_Value__c.toUpperCase();
                                       Attributevalue = attribute.String_Value__c.toUpperCase();
                                   }
                                   
                               }
                               else{
                                   if(attribute.Picklist_Value__c != null){
                                       serviceValue = attribute.Picklist_Value__c.toUpperCase();
                                       Attributevalue = attribute.Picklist_Value__c.toUpperCase();
                                   }
                                   else if(attribute.String_Value__c != null){
                                       serviceValue = attribute.String_Value__c;
                                       Attributevalue = attribute.String_Value__c;
                                   }   
                               }
                               
                               
                               if(attribute.Attribute_Name__c == 'Service Country'){
                                   countryset.put(opptChargeWrap.opptChargeWrap.id,serviceValue);
                               }
                               
                               if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service State'){
                                   if(countrystateset.containsKey(opptChargeWrap.opptChargeWrap.id)){
                                       string temp = countrystateset.get(opptChargeWrap.opptChargeWrap.id) + ';' + serviceValue;
                                       countrystateset.put(opptChargeWrap.opptChargeWrap.id, temp);
                                       
                                   }
                                   else{
                                       countrystateset.put(opptChargeWrap.opptChargeWrap.id,serviceValue );
                                       
                                   }
                               }
                               
                               
                               
                               
                               if(optychargeVsAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)){
                                   string temp = optychargeVsAttributeString.get(opptChargeWrap.opptChargeWrap.id) + ';' + serviceValue;
                                   optychargeVsAttributeString.put(opptChargeWrap.opptChargeWrap.id, temp);
                               }
                               else{
                                   optychargeVsAttributeString.put(opptChargeWrap.opptChargeWrap.id,serviceValue);
                               }
                           } 
                        
                        system.debug('@@@@service ends');
                        
                        /*************Xref validation**************************/
                         //MHBS-2258 Do not allow rep to modify closed won opportunity - Ronak
                     if(attribute.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__r.StageName == 'Closed Won' && profileName != 'System Administrator'){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You can not modify the attributes once the Opportunity is Closed Won.'));
                            return null;
                      
                      }
                        if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State' 
                           || attribute.Attribute_Name__c == 'Xref City' || attribute.Attribute_Name__c == 'Xref County'){
                               string xrefvalue = '';
                               if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref City'){
                                   if(attribute.String_Value__c != null){
                                       xrefvalue = attribute.String_Value__c.toUpperCase();
                                       Attributevalue = attribute.String_Value__c.toUpperCase();
                                   }
                               }
                               else{
                                   if(attribute.Picklist_Value__c != null){
                                       xrefvalue = attribute.Picklist_Value__c.toUpperCase();
                                       Attributevalue = attribute.Picklist_Value__c.toUpperCase();
                                   }
                                   else if(attribute.String_Value__c != null){
                                       xrefvalue = attribute.String_Value__c.toUpperCase();
                                       Attributevalue = attribute.String_Value__c.toUpperCase();
                                   }
                                   
                               }
                               system.debug('@@@@@xref value check'+attribute.Attribute_Name__c+';'+xrefvalue);
                               if(attribute.Attribute_Name__c == 'Xref Country'){
                                   xrefcountryset.put(opptChargeWrap.opptChargeWrap.id,xrefvalue );
                                   
                               }
                               
                               if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State'){
                                   if(xrefcountrystateset.containsKey(opptChargeWrap.opptChargeWrap.id)){
                                       string temp = xrefcountrystateset.get(opptChargeWrap.opptChargeWrap.id) + ';' + xrefvalue;
                                       xrefcountrystateset.put(opptChargeWrap.opptChargeWrap.id, temp);
                                       
                                   }
                                   else{
                                       xrefcountrystateset.put(opptChargeWrap.opptChargeWrap.id,xrefvalue );
                                       
                                   }
                               }
                               
                               
                               
                               if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State' 
                                  || attribute.Attribute_Name__c == 'Xref City' ){
                                      if(optychargeVsxrefAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)){
                                          string temp = optychargeVsxrefAttributeString.get(opptChargeWrap.opptChargeWrap.id) + ';' + xrefvalue;
                                          optychargeVsxrefAttributeString.put(opptChargeWrap.opptChargeWrap.id, temp);
                                          
                                      }
                                      else{
                                          optychargeVsxrefAttributeString.put(opptChargeWrap.opptChargeWrap.id,xrefvalue );
                                          
                                      }
                                  }
                               
                               if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State' 
                                  || attribute.Attribute_Name__c == 'Xref County' ){ 
                                      if(tempoptychargeVsxrefcountyAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)){
                                          string temp = tempoptychargeVsxrefcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id) + ';' + xrefvalue;
                                          tempoptychargeVsxrefcountyAttributeString.put(opptChargeWrap.opptChargeWrap.id, temp);
                                          
                                      }
                                      else{
                                          tempoptychargeVsxrefcountyAttributeString.put(opptChargeWrap.opptChargeWrap.id,xrefvalue );
                                          
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
                                       Attributevalue = attribute.String_Value__c;
                                   }
                                   
                               } 
                               else{
                                   if(attribute.Picklist_Value__c != null){
                                       value = attribute.Picklist_Value__c.toUpperCase();
                                       Attributevalue = attribute.Picklist_Value__c ;
                                   }
                                   
                               }
                               
                               if(attribute.Attribute_Name__c == 'Country'){
                                   invcountryset.put(opptChargeWrap.opptChargeWrap.id,value );
                                   
                               }
                               
                               if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State'){
                                   if(invcountrystateset.containsKey(opptChargeWrap.opptChargeWrap.id)){
                                       string temp = invcountrystateset.get(opptChargeWrap.opptChargeWrap.id) + ';' + value;
                                       invcountrystateset.put(opptChargeWrap.opptChargeWrap.id, temp);
                                       
                                   }
                                   else{
                                       invcountrystateset.put(opptChargeWrap.opptChargeWrap.id,value );
                                       
                                   }
                               }
                               
                               
                               if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State' 
                                  || attribute.Attribute_Name__c == 'City' ){ 
                                      if(optychargeVsinvAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)){
                                          string temp = optychargeVsinvAttributeString.get(opptChargeWrap.opptChargeWrap.id) + ';' + value;
                                          optychargeVsinvAttributeString.put(opptChargeWrap.opptChargeWrap.id, temp);
                                          
                                      }
                                      else{
                                          optychargeVsinvAttributeString.put(opptChargeWrap.opptChargeWrap.id,value );
                                          
                                      }
                                  }
                               
                               if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State' 
                                  || attribute.Attribute_Name__c == 'County' ){ 
                                      if(optychargeVsinvcountyAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)){
                                          string temp = optychargeVsinvcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id) + ';' + value;
                                          optychargeVsinvcountyAttributeString.put(opptChargeWrap.opptChargeWrap.id, temp);
                                          
                                      }
                                      else{
                                          optychargeVsinvcountyAttributeString.put(opptChargeWrap.opptChargeWrap.id,value );
                                          
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
                        system.debug('@@@@normal ends');
                        
                        /*****this logic is for value id population for city as city name will be duplicate in more than
* one state*/
                        if(attribute.Attribute_Name__c == 'Service City'){
                            attribute.Address_String__c = optychargeVsAttributeString.get(opptChargeWrap.opptChargeWrap.id);
                            system.debug('@@@@@attribute.Address_String__c'+attribute.Address_String__c);
                        }
                        
                        else if(attribute.Attribute_Name__c == 'Xref City'){
                            system.debug('@@@exception finding' + optychargeVsxrefAttributeString.get(opptChargeWrap.opptChargeWrap.id));
                            attribute.Address_String__c = optychargeVsxrefAttributeString.get(opptChargeWrap.opptChargeWrap.id);
                        }
                        else if(attribute.Attribute_Name__c == 'City'){
                            attribute.Address_String__c = optychargeVsinvAttributeString.get(opptChargeWrap.opptChargeWrap.id);
                        }
                        else if(attribute.Attribute_Name__c == 'Xref County'){
                            optychargeVsxrefcountyAttributeString.put(opptChargeWrap.opptChargeWrap.id, tempoptychargeVsxrefcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id));
                            
                            //As county is not unique
                            attribute.country_state_County_string__c  = tempoptychargeVsxrefcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id);
                            system.debug('@@@@@@ in xref city '+ optychargeVsxrefcountyAttributeString);
                        }
                        else if(attribute.Attribute_Name__c == 'Service State'){
                            
                            attribute.CountryState_String__c = countrystateset.get(opptChargeWrap.opptChargeWrap.id);
                        }
                        else if(attribute.Attribute_Name__c == 'Xref State'){
                            
                            attribute.CountryState_String__c = xrefcountrystateset.get(opptChargeWrap.opptChargeWrap.id);
                        }
                        else if(attribute.Attribute_Name__c == 'State'){
                            
                            attribute.CountryState_String__c = invcountrystateset.get(opptChargeWrap.opptChargeWrap.id);
                        }
                        else if(attribute.Attribute_Name__c == 'County'){
                            
                            attribute.country_state_County_string__c  =optychargeVsinvcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id);
                        }
                        
                        
                        system.debug('@@@@@ list adding');
                        listofAttribute.add(attribute); 
                    }
                }
                
                
                system.debug('@@@@@optychargeVsAttributeString'+optychargeVsAttributeString); 
                system.debug('@@@@@countryset'+countryset);   
                system.debug('@@@@optychargeVsinvcountyAttributeString'+optychargeVsinvcountyAttributeString);        
                
                
                //for checking AOP
                set<string> geoAOPSet     = new set<String>();
                if(!aopSet.isEmpty()){
                    for(aggregateResult ag : [select AOP_Name__c aop
                                              from Geo_Location__c
                                              where AOP_Name__c IN:aopSet.values()
                                              Group by AOP_Name__c]){
                                                  String tempStr = string.valueOf(ag.get('aop'));
                                                  if(tempStr != null){
                                                      tempStr = tempStr.toUpperCase();
                                                      geoAOPSet.add(tempStr);
                                                  }
                                                  //geoAOPSet.add(string.valueOf(ag.get('aop')).toUpperCase());                              
                                              }
                }
                
                //for checking AOP
                /*set<string> geoAOPGeoSet     = new set<String>();
if(!aopGeoSet.isEmpty()){
for(aggregateResult ag : [select AOP_Name__c aop
from Geo_Location__c
where AOP_Name__c IN:aopGeoSet.values()
Group by AOP_Name__c]){
String tempStr = string.valueOf(ag.get('aop'));
if(tempStr != null){
tempStr = tempStr.toUpperCase();
geoAOPGeoSet.add(tempStr);
}                              
}
}*/
                
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
                
                for(OpptChargeWrapper opptChargeWrap:listOfOpptChargeWrapper){
                    if(countryset.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        if(!geoCountryset.contains(countryset.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Service country on  '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + countryset.get(opptChargeWrap.opptChargeWrap.id)));
                            return null;
                        }
                    }
                    
                    
                    if(countrystateset.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        if(!geoCountrystateset.contains(countrystateset.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            List<string> parts = countrystateset.get(opptChargeWrap.opptChargeWrap.id).split(';');
                            string param = ' ';
                            if(parts.size() > 1){
                                param       = parts[parts.size()-1];
                            }
                            
                            
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Service State on  '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + param));
                            return null;
                        }
                    }
                    
                    
                    
                    if(optychargeVsAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        
                        if(!addressSet.contains(optychargeVsAttributeString.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            List<string> parts = optychargeVsAttributeString.get(opptChargeWrap.opptChargeWrap.id).split(';');
                            string param = ' ';
                            if(parts.size() > 1){
                                param       = parts[parts.size()-1];
                            }
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Service City on '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value:  '+' ' + param ));
                            return null;
                        }
                        
                    }
                    
                    
                    if(xrefcountryset.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        
                        if(!geoCountryset.contains(xrefcountryset.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Xref country on  '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + xrefcountryset.get(opptChargeWrap.opptChargeWrap.id)));
                            return null;
                        }
                    }
                    
                    if(xrefcountrystateset.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        
                        if(!geoCountrystateset.contains(xrefcountrystateset.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            List<string> parts = xrefcountrystateset.get(opptChargeWrap.opptChargeWrap.id).split(';');
                            string param = ' ';
                            if(parts.size() > 1){
                                param       = parts[parts.size()-1];
                            }
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Xref State on  '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value:'+ ' ' + param));
                            return null;
                        }
                    }
                    
                    system.debug('@@@@before error');
                    if(optychargeVsxrefcountyAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        system.debug('@@@@@@optychargeVsxrefcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id)'+optychargeVsxrefcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id));
                        
                        if(!countyaddressSet.contains(optychargeVsxrefcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            List<string> parts = optychargeVsxrefcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id).split(';');
                            string param = ' ';
                            if(parts.size() > 2){
                                param       = parts[parts.size()-1];
                            }
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Xref County on '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + param ));
                            return null;
                        }
                    }
                    
                    else if(optychargeVsxrefAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        system.debug('@@@@@@optychargeVsxrefAttributeString.get(opptChargeWrap.opptChargeWrap.id)'+optychargeVsxrefAttributeString.get(opptChargeWrap.opptChargeWrap.id));
                        
                        if(!addressSet.contains(optychargeVsxrefAttributeString.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            List<string> parts = optychargeVsxrefAttributeString.get(opptChargeWrap.opptChargeWrap.id).split(';');
                            string param = ' ';
                            if(parts.size() > 1){
                                param       = parts[parts.size()-1];
                            }
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Xref City on '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' '+ Attributevalue));
                            return null;
                        }
                    }
                    
                    
                    
                    //*********Inventory validations *****************************/
                    if(invcountryset.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        
                        if(!invgeoCountryset.contains(invcountryset.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            List<string> parts = invcountryset.get(opptChargeWrap.opptChargeWrap.id).split(';');
                            string param       = parts[parts.size()-1];
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid Country on  '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value  '+ ' ' + param ));
                            return null;
                        }
                    }
                    if(invcountrystateset.containsKey(opptChargeWrap.opptChargeWrap.id) 
                       && inventoryProducts.contains(opptChargeWrap.opptChargeWrap.Name.split(' -')[0]) 
                       && (Inventoried_Products_list__c.getValues(opptChargeWrap.opptChargeWrap.Name.split(' -')[0]).Type__c == 'State'
                           || Inventoried_Products_list__c.getValues(opptChargeWrap.opptChargeWrap.Name.split(' -')[0]).Type__c == 'City'
                           || Inventoried_Products_list__c.getValues(opptChargeWrap.opptChargeWrap.Name.split(' -')[0]).Type__c == 'County')
                      ){
                          
                          if(!invgeoCountrystateset.contains(invcountrystateset.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                              List<string> parts = invcountrystateset.get(opptChargeWrap.opptChargeWrap.id).split(';');
                              string param = ' ';
                              if(parts.size() > 1){
                                  param       = parts[parts.size()-1];
                              } 
                              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid State on  '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + param ));
                              return null;
                          }
                      } 
                    
                    if(optychargeVsinvAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)
                       &&  inventoryProducts.contains(opptChargeWrap.opptChargeWrap.Name.split(' -')[0])
                       && Inventoried_Products_list__c.getValues(opptChargeWrap.opptChargeWrap.Name.split(' -')[0]).Type__c == 'City'){
                           
                           if(!invaddressSet.contains(optychargeVsinvAttributeString.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                               List<string> parts = optychargeVsinvAttributeString.get(opptChargeWrap.opptChargeWrap.id).split(';');
                               string param = ' ';
                               if(parts.size() > 1){
                                   param       = parts[parts.size()-1];
                               }
                               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid City on '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + param));
                               return null;
                           }
                       }
                    
                    if(optychargeVsinvcountyAttributeString.containsKey(opptChargeWrap.opptChargeWrap.id)
                       &&  inventoryProducts.contains(opptChargeWrap.opptChargeWrap.Name.split(' -')[0])
                       && Inventoried_Products_list__c.getValues(opptChargeWrap.opptChargeWrap.Name.split(' -')[0]).Type__c == 'County'){
                           
                           if(!invCountyaddressSet.contains(optychargeVsinvcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                               List<string> parts = optychargeVsinvcountyAttributeString.get(opptChargeWrap.opptChargeWrap.id).split(';');
                               string param = ' ';
                               if(parts.size() > 2){
                                   param       = parts[parts.size()-1];
                               }
                               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid County on '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + param ));
                               return null;
                           }
                       }
                    
                    if(aopSet.containsKey(opptChargeWrap.opptChargeWrap.id)){
                        if(!geoAOPSet.contains(aopSet.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid AOP Value '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + aopSet.get(opptChargeWrap.opptChargeWrap.id)));
                            return null;
                        }
                    }
                    /*if(aopGeoSet.containsKey(opptChargeWrap.opptChargeWrap.id)){
if(!geoAOPGeoSet.contains(aopGeoSet.get(opptChargeWrap.opptChargeWrap.id).toUpperCase())){
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Not a valid AOP Value '+ ' ' + opptChargeWrap.opptChargeWrap.Name + ' with value: '+ ' ' + aopGeoSet.get(opptChargeWrap.opptChargeWrap.id)));
return null;
}
}*/
                }
                
                if(!listofAttribute.isEmpty()){
                    upsert listofAttribute;
                }
                if(!insertList.isEmpty()){
                    upsert insertList;                 
                }
                List<Id> deleteIds = new List<Id>();
                system.debug('@@@@@@@final existingIds'+existingIds.size());
                if(!existingIds.isEmpty() && existingIds.size() > 0){
                    deleteIds.addAll(existingIds);
                    
                    // Uncommented Sai C
                    Database.DeleteResult[] deleteResults = Database.delete(deleteIds, false);
                }
            }        
            
        } catch(Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An exception has occured. Exception message is : ' + ex.getMessage()+ex.getLineNumber());
            ApexPages.addMessage(myMsg);
            return null;    
        }
        
        return new PageReference('/' + oppt.Id);
    }
    //wrapper class
    public class OpptChargeWrapper{
        public boolean isChecked {get;set;}
        public invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opptChargeWrap{get;set;}
        public boolean disable{get;set;}
        public list<AttributeNames> listOfAttributes {get;set;}       
        public string urlText{get;set;}
        
        public  OpptChargeWrapper(){
            listOfAttributes = new list<AttributeNames>();
        }
    }  
    
    public class AttributeNames {        
        public integer rowCount   {get; set;}
        public Id chargeId {get;set;}
        public Opportunity_Charge_Attribute__c opptyChargeAttribute {get;set;}
        public List<SelectOption> attributeOptions {get;set;}
        public list<SelectOption> listOfAttributesNew {get;set;}  
        public list<SelectOption> listOfAttributesLatest {get;set;}
        //public string stateName   {get;set;}
        //public string countryName {get;set;}
        public boolean chargedisable{get;set;}
        public string attrName {get;set;}
        public boolean showAdd {get;set;}         
        public AttributeNames(){
            listOfAttributesNew = new list<SelectOption>();
            listOfAttributesLatest = new list<SelectOption>();
        }
    }
    
    public void populatingCountyCityValue(){
        
        String attributeName = ApexPages.currentPage().getParameters().get('attributeName');
        String chargeId = ApexPages.currentPage().getParameters().get('chargeId');
        String selectValue = ApexPages.currentPage().getParameters().get('selectValue');
        
        
        AttributeNames charAttLocal;  
        list<String> countyNames;  
        listOfCounties = new list<State_County__c>();
        for(OpptChargeWrapper chargeWrap : listOfOpptChargeWrapper){                
            for(AttributeNames charAtt : chargeWrap.listOfAttributes){                        
                if(charAtt.opptyChargeAttribute.Picklist_Value__c != null && charAtt.opptyChargeAttribute.Attribute_Name__c == 'State' && charAtt.opptyChargeAttribute.id == selectValue && charAtt.opptyChargeAttribute.Opportunity_Rate_Plan_Charge__c == chargeId){
                    listOfCounties = [Select id, County__c,City__c from State_County__c Where State__c =: charAtt.opptyChargeAttribute.Picklist_Value__c];
                    listOfCounties.sort();
                    break;
                }
                
            }
        }
        for(OpptChargeWrapper chargeWrap : listOfOpptChargeWrapper){
            //if(chargeWrap.opptChargeWrap.id == chargeId){
            for(AttributeNames charAtt : chargeWrap.listOfAttributes){
                if(charAtt.opptyChargeAttribute.Attribute_Name__c == 'City' && charAtt.opptyChargeAttribute.Opportunity_Rate_Plan_Charge__c == chargeId){
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
                }else if(charAtt.opptyChargeAttribute.Attribute_Name__c == 'County' && charAtt.opptyChargeAttribute.Opportunity_Rate_Plan_Charge__c == chargeId){
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
                }else if(charAtt.opptyChargeAttribute.Attribute_Name__c == 'City' && charAtt.opptyChargeAttribute.Opportunity_Rate_Plan_Charge__c != chargeId){
                    charAtt.attributeOptions = new list<SelectOption>();
                    if(charAtt.opptyChargeAttribute.Picklist_Value__c != null)
                        charAtt.attributeOptions.add(new SelectOption(charAtt.opptyChargeAttribute.Picklist_Value__c,charAtt.opptyChargeAttribute.Picklist_Value__c));
                    
                    charAtt.listOfAttributesNew = new list<SelectOption>();
                    charAtt.listOfAttributesLatest = new list<SelectOption>();
                }else if(charAtt.opptyChargeAttribute.Attribute_Name__c == 'County' && charAtt.opptyChargeAttribute.Opportunity_Rate_Plan_Charge__c != chargeId){
                    charAtt.attributeOptions = new list<SelectOption>();
                    if(charAtt.opptyChargeAttribute.Picklist_Value__c != null)
                        charAtt.attributeOptions.add(new SelectOption(charAtt.opptyChargeAttribute.Picklist_Value__c,charAtt.opptyChargeAttribute.Picklist_Value__c));
                    
                    charAtt.listOfAttributesNew = new list<SelectOption>();
                    charAtt.listOfAttributesLatest = new list<SelectOption>();
                }
            }
            // }
            //break;
        }
        
    }
    
    public void onChangeCountry(){
        String attributeName = ApexPages.currentPage().getParameters().get('attributeName');
        String chargeId = ApexPages.currentPage().getParameters().get('chargeId');
        String selectValue = ApexPages.currentPage().getParameters().get('selectValue');
        
        for(OpptChargeWrapper chargeWrap : listOfOpptChargeWrapper){
            for(AttributeNames charAtt : chargeWrap.listOfAttributes){
                if(charAtt.opptyChargeAttribute.Picklist_Value__c != null && charAtt.opptyChargeAttribute.Attribute_Name__c == 'County' && charAtt.opptyChargeAttribute.id == selectValue && charAtt.opptyChargeAttribute.Opportunity_Rate_Plan_Charge__c == chargeId){
                    listOfCounties = [Select id, County__c,City__c from State_County__c Where County__c =: charAtt.opptyChargeAttribute.Picklist_Value__c];
                    listOfCounties.sort(); 
                }
                
                if(charAtt.opptyChargeAttribute.Attribute_Name__c == 'City' && charAtt.opptyChargeAttribute.Opportunity_Rate_Plan_Charge__c == chargeId && listOfCounties.size() > 0){
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
                }else if(charAtt.opptyChargeAttribute.Attribute_Name__c == 'City' && charAtt.opptyChargeAttribute.Opportunity_Rate_Plan_Charge__c != chargeId){
                    charAtt.attributeOptions = new list<SelectOption>();
                    if(charAtt.opptyChargeAttribute.Picklist_Value__c != null)
                        charAtt.attributeOptions.add(new SelectOption(charAtt.opptyChargeAttribute.Picklist_Value__c,charAtt.opptyChargeAttribute.Picklist_Value__c));
                    
                    charAtt.listOfAttributesNew = new list<SelectOption>();
                    charAtt.listOfAttributesLatest = new list<SelectOption>();
                }
            }
        }
    }
    public void updateChargesList(){
        system.debug('opptId in updateChargesList'+opptId);
        //For Seq Num
        Decimal lastSeqNum;
        Decimal lastIndpProdCompSeqNum;
        List<invoiceit_crmx__Opportunity_Product__c> pkgCompsList = new List<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> pkgIndCompsList = new List<invoiceit_crmx__Opportunity_Product__c>();
        
        List<invoiceit_crmx__Opportunity_Product__c> OppProdUpdateList = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(invoiceit_crmx__Opportunity_Product__c op: [select id,Name,invoiceit_crmx__Bundle_SequenceNumber__c,
                                                        invoiceit_crmx__Opportunity__c,invoiceit_crmx__Product_Bundle__c,
                                                        invoiceit_crmx__Product_Bundle__r.Name,invoiceit_crmx__Product_Family__c,
                                                        Product_SIN__c,invoiceit_crmx__SequenceNumber__c 
                                                        from invoiceit_crmx__Opportunity_Product__c 
                                                        where invoiceit_crmx__Opportunity__c =: opptId order by invoiceit_crmx__SequenceNumber__c]){
            if(op.invoiceit_crmx__Product_Bundle__c != null){                
                lastSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                pkgCompsList.add(op);
            }
            if(op.invoiceit_crmx__Product_Bundle__c == null){
                lastIndpProdCompSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                pkgIndCompsList.add(op);
            }
        }
        // For Product rate plan and Product rate plan charge update
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chargesList = [select id,Name,invoiceit_crmx__Accounting_Code__c,
                                                                             invoiceit_crmx__Opportunity_Rate_Plan__c,
                                                                             invoiceit_crmx__Product_Bundle_Line__c,
                                                                             invoiceit_crmx__Product_Rate_Plan_Charge__c,
                                                                             Created_From_Charge__c ,Package_Component__c ,
                                                                             Package_Wrapper__c,invoiceit_crmx__Opportunity__c,
                                                                             invoiceit_crmx__Opportunity__r.Created_From_Order__c 
                                                                             from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                             where invoiceit_crmx__Product_Bundle_Line__c != null 
                                                                               and Package_Wrapper__c = false and Package_Component__c = false 
                                                                             and invoiceit_crmx__Opportunity__c =: opptId 
                                                                             and invoiceit_crmx__Opportunity__r.Created_From_Order__c != null];
        system.debug(logginglevel.error,'---chargesList --'+chargesList );      
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> ORPCtoUpdateList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();        
        List<invoiceit_crmx__Opportunity_Rate_Plan__c> ORPUpdateList = new List<invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Set<Id> bundleLineIds = new Set<Id>();
        Set<Id> oppRatePlanIds = new Set<Id>();
        Map<Id,Id> oppRatePlanBundleLineMap = new Map<Id,Id>(); //opprateplanId,bundleLineId
        
        if(chargesList != null && chargesList.size() > 0){    
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge: chargesList){
                bundleLineIds.add(charge.invoiceit_crmx__Product_Bundle_Line__c);
                oppRatePlanIds.add(charge.invoiceit_crmx__Opportunity_Rate_Plan__c);
                oppRatePlanBundleLineMap.put(charge.invoiceit_crmx__Opportunity_Rate_Plan__c,charge.invoiceit_crmx__Product_Bundle_Line__c);
            }
            Map<Id,invoiceit_s__Product_Bundle_Line__c> prodBundleLineMap = new Map<Id,invoiceit_s__Product_Bundle_Line__c>();
            for(invoiceit_s__Product_Bundle_Line__c pbl: [select id,Name,invoiceit_s__Product_Bundle__c,invoiceit_s__Product__c,invoiceit_s__Product__r.Name,invoiceit_s__Product_Bundle__r.Name,invoiceit_s__Product_Rate_Plan__c,invoiceit_s__Product_Rate_Plan__r.Name,invoiceit_s__Product_Rate_Plan_Charge__c,invoiceit_s__Product_Rate_Plan_Charge__r.Name,invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c from invoiceit_s__Product_Bundle_Line__c]){         
                prodBundleLineMap.put(pbl.Id,pbl);          
            }
            
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge : chargesList){
                charge.Name = prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__r.Name;
                charge.invoiceit_crmx__Accounting_Code__c = prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c;
                charge.invoiceit_crmx__Product_Rate_Plan_Charge__c =  prodBundleLineMap.get(charge.invoiceit_crmx__Product_Bundle_Line__c).invoiceit_s__Product_Rate_Plan_Charge__c;
                ORPCtoUpdateList.add(charge);
            }
            Set<Id> oppProdsSet = new Set<Id>();
            for(invoiceit_crmx__Opportunity_Rate_Plan__c orp: [select id,invoiceit_crmx__Product_Rate_Plan__c,Name,invoiceit_crmx__Opportunity_Product__c from invoiceit_crmx__Opportunity_Rate_Plan__c where id IN: oppRatePlanIds]){
                orp.invoiceit_crmx__Product_Rate_Plan__c = prodBundleLineMap.get(oppRatePlanBundleLineMap.get(orp.id)).invoiceit_s__Product_Rate_Plan__c;
                orp.Name = prodBundleLineMap.get(oppRatePlanBundleLineMap.get(orp.id)).invoiceit_s__Product_Rate_Plan__r.Name;
                ORPUpdateList.add(orp);
                oppProdsSet.add(orp.invoiceit_crmx__Opportunity_Product__c);
            }
            
            if(!ORPUpdateList.isEmpty()){
                database.update(ORPUpdateList, false);
            }
            if(!ORPCtoUpdateList.isEmpty()){
                database.update(ORPCtoUpdateList, false);
            }
            //List<invoiceit_s__Product__c> invITProd = [select id,Name from invoiceit_s__Product__c where Name = 'Web Gold'];
            Set<String> webProdNames = new Set<String>{'Web Gold','Web Platinum'};
                List<invoiceit_s__Product__c> invITProd = [select id,Name from invoiceit_s__Product__c where Name IN: webProdNames ];
            Map<String,Id> invITProdMap = new Map<String,Id>();
            for(invoiceit_s__Product__c inn: invITProd){
                invITProdMap.put(inn.Name,inn.id);
            }
            // To Update Opp Prod with Seq num
            Decimal count = 1;
            for(invoiceit_crmx__Opportunity_Product__c op: [select id,Name,invoiceit_crmx__Product__c,invoiceit_crmx__Bundle_SequenceNumber__c,invoiceit_crmx__Opportunity__c,invoiceit_crmx__Product_Bundle__c,invoiceit_crmx__Product_Bundle__r.Name,invoiceit_crmx__Product_Family__c,Product_SIN__c,invoiceit_crmx__SequenceNumber__c, invoiceit_crmx__Product_Code__c from invoiceit_crmx__Opportunity_Product__c where Id IN: oppProdsSet]){
                op.invoiceit_crmx__SequenceNumber__c= lastSeqNum+count;
                if(op.invoiceit_crmx__Product_Bundle__r.Name == 'Gold Upsell - SEO' && (op.Name == 'Web Bronze' || op.Name == 'Web Gold' || op.Name == 'Web Silver')){
                    op.Name = 'Web Gold';
                    if(invITProdMap.containsKey('Web Gold'))
                        op.invoiceit_crmx__Product__c= invITProdMap.get('Web Gold');
                }
                if(op.invoiceit_crmx__Product_Bundle__r.Name == 'Platinum Upsell - SEO' && (op.Name == 'Web Bronze' || op.Name == 'Web Gold' || op.Name == 'Web Silver')){
                    op.Name = 'Web Platinum';
                    if(invITProdMap.containsKey('Web Platinum'))
                        op.invoiceit_crmx__Product__c= invITProdMap.get('Web Platinum');
                }
                /*if(op.Name == 'Web Bronze'){
op.Name = 'Web Gold';
if(invITProd != null && invITProd.size() >0)
op.invoiceit_crmx__Product__c= invITProd[0].id;
}*/
                //op.invoiceit_crmx__Product_Code__c = prodBundleLineMap.get(op.invoiceit_crmx__Product_Bundle__c).invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Accounting_Code__c;
                count++;
                OppProdUpdateList.add(op);
            }
            if(!OppProdUpdateList.isEmpty()){
                database.update(OppProdUpdateList, false);
            }
        }
        // For Seq again reordering
        List<invoiceit_crmx__Opportunity_Product__c> OppProdUpdateSeqList = new List<invoiceit_crmx__Opportunity_Product__c>();
        system.debug('lastSeqNum'+lastSeqNum);
        system.debug('lastIndpProdCompSeqNum'+lastIndpProdCompSeqNum);
        //system.debug('pkgCompsList.size()'+pkgCompsList.size());        
        //Initial pkg comp seq num is
        Decimal initSeqNum = 0;
        //if(pkgCompsList != null && pkgCompsList.size() > 0)
        //initSeqNum = lastSeqNum - (pkgCompsList.size());
        
        
        for(invoiceit_crmx__Opportunity_Product__c op:pkgCompsList){
            if(op.invoiceit_crmx__Product_Family__c == 'Package'){
                initSeqNum = op.invoiceit_crmx__SequenceNumber__c;
                break;
            }
        }
        system.debug('initSeqNum '+initSeqNum );
        Decimal lastNum = 0;
        if((lastSeqNum > lastIndpProdCompSeqNum || lastSeqNum < lastIndpProdCompSeqNum) && initSeqNum > 0){
            Integer count = 1;
            for(invoiceit_crmx__Opportunity_Product__c op:pkgCompsList){
                if(op.invoiceit_crmx__SequenceNumber__c == initSeqNum){
                    //SKIP least one as it is wrapper prod
                }else{
                    op.invoiceit_crmx__SequenceNumber__c= initSeqNum+count;
                    lastNum = op.invoiceit_crmx__SequenceNumber__c;
                    OppProdUpdateSeqList.add(op);
                    count++;
                }
            }
            system.debug('lastNum '+lastNum );
            Integer Indcount = 1;
            for(invoiceit_crmx__Opportunity_Product__c op: pkgIndCompsList){
                op.invoiceit_crmx__SequenceNumber__c = lastNum+Indcount;
                OppProdUpdateSeqList.add(op);
                Indcount++;
            }
        }
        if(!OppProdUpdateSeqList.isEmpty()){
            database.update(OppProdUpdateSeqList, false);
        }
    }
    public PageReference cancel(){
        return new PageReference('/' + oppt.Id);
    }
}