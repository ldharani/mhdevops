public with sharing class CreateAttributesNew {

    public Boolean isVisible{get;set;}
    public Product_Charge_Attribute__c productChargeAttribute{get;set;}
    public invoiceit_s__Product_Rate_Plan_Charge__c charge{get;set;}
    public list<Product_Charge_Attribute__c> listOfproductChargeAttributes{get;set;}
    public String attributeRecordName{get;set;}
    String chrageId;
    public Boolean isChecked{get;set;}
    public  integer count;
    public Attribute_Config__c attributeConfig{get;set;}
    public list<createChrgeWrapper> listOfcreateChrgeWrapper{get;set;}
    createChrgeWrapper createChrgeWrapObj;
    public integer classCounter = -1;
    list<Product_Charge_Attribute__c> listOfPChargeAttRemove;
    public CreateAttributesNew(ApexPages.StandardController controller) {
        listOfPChargeAttRemove = new list<Product_Charge_Attribute__c>();
        isVisible = true;
        isChecked = false;
        this.charge = (invoiceit_s__Product_Rate_Plan_Charge__c)controller.getRecord();
        chrageId = ApexPages.currentPage().getParameters().get('id');
        if(chrageId !=null){
            charge = [SELECT id,Name,invoiceit_s__Product_Rate_Plan__r.name,invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__c,invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.name
                      FROM invoiceit_s__Product_Rate_Plan_Charge__c
                      WHERE id=:chrageId ];   
        }
        listOfproductChargeAttributes = [SELECT id,Name,Required__c,Default_Text__c,Default_Number__c, AttributeName__r.Attribute_Type__c ,Default_Date__c,Default_Currency__c,Default_Boolean__c,Attribute_Name__c,Product_Rate_Plan_Charge__c,Attribute_Type__c,AttributeName__c,Attribute_Order__c
                                         FROM Product_Charge_Attribute__c
                                         WHERE Product_Rate_Plan_Charge__c =:chrageId ];
        listOfcreateChrgeWrapper = new list<createChrgeWrapper>();
        if(!listOfproductChargeAttributes.isEmpty()){
            for(Product_Charge_Attribute__c proChargeAtt: listOfproductChargeAttributes){
                createChrgeWrapObj = new createChrgeWrapper();
                createChrgeWrapObj.productChargeAttributeWrap = proChargeAtt;
                createChrgeWrapObj.counter = ++classCounter;
                createChrgeWrapObj.type = proChargeAtt.AttributeName__r.Attribute_Type__c;
                listOfcreateChrgeWrapper.add(createChrgeWrapObj);
            }
        }
        else {                                       
            createChrgeWrapObj = new createChrgeWrapper(); 
            productChargeAttribute = new Product_Charge_Attribute__c();         

        }
    }
    
    public PageReference populateDefaultValues() {
        String param = ApexPages.CurrentPage().getParameters().get('attributeId');
        Integer counter = Integer.valueof(ApexPages.CurrentPage().getParameters().get('counter'));
        System.debug('Hi value param-->'+param );
        attributeConfig = [SELECT id,Name,Attribute_Type__c 
                           FROM Attribute_Config__c 
                           WHERE id=:param];
        
        for(integer i=0; i<listOfcreateChrgeWrapper.size(); i++) {
           if(listOfcreateChrgeWrapper[i].counter == counter ) {
               listOfcreateChrgeWrapper[i].type = attributeConfig.Attribute_Type__c;
               break;
           }
        }
        return null;
    }
    public PageReference addingProductChargeAttribute() {
        String SFieldName ='';
        isChecked = false;
        Integer listSize = listOfcreateChrgeWrapper.size();
        if(listSize  > 1) {
            SFieldName = listOfcreateChrgeWrapper[listSize - 1].productChargeAttributeWrap.Attribute_Name__c;
            for(Integer i =0; i < listSize; i++) {
                if(i != listSize - 1) {
                    if(SFieldName == listOfcreateChrgeWrapper[i].productChargeAttributeWrap.Attribute_Name__c) {
                        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Field Name');
                        //ApexPages.addMessage(myMsg);                        
                        //return null;
                    }
                }
            }
        }
        createChrgeWrapObj = new createChrgeWrapper();
        productChargeAttribute = new Product_Charge_Attribute__c();        
        createChrgeWrapObj.productChargeAttributeWrap = productChargeAttribute;
        createChrgeWrapObj.productChargeAttributeWrap.Product_Rate_Plan_Charge__c = chrageId; 
        createChrgeWrapObj.counter = ++classCounter;
        listOfcreateChrgeWrapper.add(createChrgeWrapObj); 
        isVisible = false;   
        return null;
    }  

    public pageReference removingAttribute(){                                                         
        string counterParam = Apexpages.currentPage().getParameters().get('counterparameter');
        count = integer.valueof(counterParam);      
        for(integer i=0 ; i< listOfcreateChrgeWrapper.size(); i++){
            if(listOfcreateChrgeWrapper[i].counter == count){
                if(listOfcreateChrgeWrapper[i].productChargeAttributeWrap.id !=null){
                    Product_Charge_Attribute__c pChargeAttRemove = new Product_Charge_Attribute__c(id= listOfcreateChrgeWrapper[i].productChargeAttributeWrap.id);
                    listOfPChargeAttRemove.add(pChargeAttRemove );  
                }                
                listOfcreateChrgeWrapper.remove(i);
                break;
            }
        }

        return null;
    }

    public PageReference savingAttribute(){
        try{
            if(!listOfPChargeAttRemove.isEmpty()){
                delete listOfPChargeAttRemove;
            }       
            String SFieldName =''; 
            Set<String> setOfString = new Set<String>();
            Integer listSize = listOfcreateChrgeWrapper.size();
            for(Integer i =0; i < listSize; i++) {
                SFieldName = listOfcreateChrgeWrapper[i].productChargeAttributeWrap.Attribute_Name__c;
                if(setOfString.contains(SFieldName)){
                    //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Field Name');
                    //ApexPages.addMessage(myMsg);                        
                    //return null;
                }
                setOfString.add(SFieldName);        
            }

            listOfproductChargeAttributes = new list<Product_Charge_Attribute__c>();
            for(Integer i =0;i<listSize;i++){
                listOfcreateChrgeWrapper[i].productChargeAttributeWrap.Product_Rate_Plan_Charge__c = chrageId;                  
                listOfproductChargeAttributes.add(listOfcreateChrgeWrapper[i].productChargeAttributeWrap);
            }
            if(!listOfproductChargeAttributes.isEmpty()){  
                upsert listOfproductChargeAttributes;
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Product Charge Attribute(s) successfully created/updated');
            ApexPages.addMessage(myMsg);
            isVisible= true;         

        }catch(Exception ex){
            String exceptionMsg = ' Type of Exception : ' + ex.getTypeName()+','+ ' Line Number : ' + ex.getLineNumber()+','+ ' Exception Message : ' + ex.getMessage();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,exceptionMsg );
            ApexPages.addMessage(myMsg);    
        }  
        return null;           
    }    
    public class createChrgeWrapper{
        public Product_Charge_Attribute__c productChargeAttributeWrap{get;set;}
        public integer counter{get; set;}
        public string type {get; set;}
    }
}