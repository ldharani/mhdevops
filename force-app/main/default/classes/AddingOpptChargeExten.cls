public with sharing class AddingOpptChargeExten {

    public Opportunity oppt{get;set;}
    public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOfOpptCharge{set;get;}
    public boolean isVisible{get;set;}
    public list<OpptChargeWrapper> listOfOpptChargeWrapper{get;set;}
    OpptChargeWrapper opptChargeWrapperObj;
    Id opptId;

    //constructor
    public AddingOpptChargeExten(ApexPages.StandardController controller) {
        opptId = ApexPages.currentPage().getParameters().get('id');
        oppt = [SELECT name, Amount, CloseDate,StageName,invoiceit_crmx__Start_Date__c
                FROM Opportunity  
                WHERE id =:opptId];
        //query for list of oppt charges along with oppt charge attribute
        listOfOpptCharge = [SELECT Name,invoiceit_crmx__Opportunity_Rate_Plan__c,
                           (SELECT Attribute_Order__c,Picklist_Value__c,Required__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, Attribute_Picklist_Values__c, Name,Attribute_Name__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Phone_Value__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,String_Value__c
                            FROM Opportunity_Charge_Attributes__r ORDER By Attribute_Order__c)
                            FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                            WHERE  invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c  =:opptId ];
        listOfOpptChargeWrapper = new  list<OpptChargeWrapper>(); 

        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge:listOfOpptCharge) {
            opptChargeWrapperObj = new OpptChargeWrapper();
            opptChargeWrapperObj.opptChargeWrap = charge;
            opptChargeWrapperObj.isChecked = false;

            list<AttributeNames> listOfAttributes = new list<AttributeNames>();
            for(Opportunity_Charge_Attribute__c charAtt : charge.Opportunity_Charge_Attributes__r) {
                AttributeNames a1 = new AttributeNames();
                a1.opptyChargeAttribute = charAtt;   
                //spilting picklist value and displaying in a drop down
                if(charAtt.Attribute_Type__c == 'Picklist' && charAtt.Attribute_Picklist_Values__c != null) {
                    a1.attributeOptions = new List<SelectOption>();
                    // add the first option as none
                    a1.attributeOptions.add(new SelectOption('', '--None--'));
                    for(string s : charAtt.Attribute_Picklist_Values__c.split(',')) { 
                        string s1 = s.trim();                                                                   
                        a1.attributeOptions.add(new SelectOption(s1 ,s1 ));    
                    }
                    system.debug('a1.attributeOptions' +a1.attributeOptions); 
                }                
                listOfAttributes.add(a1);
            }
            opptChargeWrapperObj.listOfAttributes = listOfAttributes;

            listOfOpptChargeWrapper.add(opptChargeWrapperObj);
        }

    }   

    //saving oppt charge attribute 
    public PageReference save(){
        try {    
            list<Opportunity_Charge_Attribute__c> listofAttribute = new list<Opportunity_Charge_Attribute__c>();
            for(OpptChargeWrapper opptChargeWrap:listOfOpptChargeWrapper){

                for(Opportunity_Charge_Attribute__c attribute:opptChargeWrap.opptChargeWrap.Opportunity_Charge_Attributes__r){
                    
                    //for checking maximum charactor in string
                    if(attribute.Attribute_Type__c == 'Text'){
                        if(attribute.Maximum_No_Of_Characters_In_Text__c != null){
                            if(attribute.String_Value__c != null){
                                if(attribute.String_Value__c.length() > attribute.Maximum_No_Of_Characters_In_Text__c){
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You can enter '+ attribute.Maximum_No_Of_Characters_In_Text__c +'   charactor .'));
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
        public list<AttributeNames> listOfAttributes {get;set;}        
    }  

    public class AttributeNames {
        public Opportunity_Charge_Attribute__c opptyChargeAttribute {get;set;}
        public List<SelectOption> attributeOptions {get;set;}
    }
}