public with sharing class AddingOpptChargeExten2 {

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
    
    ClassForNavigation AddingOrderNavigationTestObj;
   public AddingOpptChargeExten2(ApexPages.StandardController controller) {
            
        opptId = ApexPages.currentPage().getParameters().get('id');
        oppt = [SELECT name, Amount, CloseDate,StageName,invoiceit_crmx__Start_Date__c
                FROM Opportunity  
                WHERE id =:opptId];
       
       Id profileId=userinfo.getProfileId();
       profileName=[Select Id,Name from Profile where Id=:profileId].Name;
       system.debug('@@@@ProfileName'+profileName);
       
       
        //query for list of oppt charges along with oppt charge attribute
        listOfOpptCharge = [SELECT Name,invoiceit_crmx__Opportunity_Rate_Plan__c,SIN__c,
                           (SELECT Attribute_Order__c,Picklist_Value__c,Required__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, Attribute_Picklist_Values__c, Name,Attribute_Name__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Phone_Value__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,String_Value__c
                            FROM Opportunity_Charge_Attributes__r ORDER By Attribute_Order__c)
                            FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                            WHERE  invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c  =:opptId ];

        AddingOrderNavigationTestObj = new ClassForNavigation(listOfOpptCharge);
       
          
       
        first();
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
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge : listOfOpptCharge) {
            system.debug('@@@charge name'+ charge.Name);
            system.debug('@@@@@charge'+ charge.SIN__c);
            opptChargeWrapperObj = new OpptChargeWrapper();
            opptChargeWrapperObj.opptChargeWrap = charge;
            opptChargeWrapperObj.isChecked = false;
            if(charge.SIN__c == null || charge.SIN__c ==''){
                opptChargeWrapperObj.disable = false;
            }
            else{
                if(profileName !='Data Governor' && profileName !='System Administrator' && profileName !='Fulfillment Ops Rep'){
                    opptChargeWrapperObj.disable = true;
                }
                
            }

            list<AttributeNames> listOfAttributes = new list<AttributeNames>();            
            for(Opportunity_Charge_Attribute__c charAtt : charge.Opportunity_Charge_Attributes__r) {
                AttributeNames a1 = new AttributeNames();
                a1.opptyChargeAttribute = charAtt; 
               
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
                        } 
                        a1.attributeOptions.add(new SelectOption('--None--', '--None--'));   
                    }                    
                }           
                listOfAttributes.add(a1);
                opptChargeWrapperObj.listOfAttributes.add(a1);
            }
            //opptChargeWrapperObj.listOfAttributes = listOfAttributes;
            listOfOpptChargeWrapper.add(opptChargeWrapperObj);
        }
    }
    
    
    //saving oppt charge attribute 
    public PageReference save(){
        try {    
            list<Opportunity_Charge_Attribute__c> listofAttribute = new list<Opportunity_Charge_Attribute__c>();
              if(listOfOpptChargeWrapper != null){ 
                for(OpptChargeWrapper opptChargeWrap:listOfOpptChargeWrapper){
    
                    for(Opportunity_Charge_Attribute__c attribute:opptChargeWrap.opptChargeWrap.Opportunity_Charge_Attributes__r){
                        
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
                        
                        listofAttribute.add(attribute); 
                    }
                }
                if(!listofAttribute.isEmpty()){
                    upsert listofAttribute;
                }
            }

        } catch(Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An exception has occured. Exception message is : ' + ex.getMessage());
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
       
        public  OpptChargeWrapper(){
            listOfAttributes = new list<AttributeNames>();
        }
    }  

    public class AttributeNames {
        public Opportunity_Charge_Attribute__c opptyChargeAttribute {get;set;}
        public List<SelectOption> attributeOptions {get;set;}
        public list<SelectOption> listOfAttributesNew {get;set;}  
        public list<SelectOption> listOfAttributesLatest {get;set;}
        public boolean chargedisable{get;set;}
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
}