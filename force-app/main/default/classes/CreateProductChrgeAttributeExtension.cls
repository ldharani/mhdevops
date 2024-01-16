public with sharing class CreateProductChrgeAttributeExtension {

    public Boolean isVisible{get;set;}
    public Product_Charge_Attribute__c productChargeAttribute{get;set;}
    public invoiceit_s__Product_Rate_Plan_Charge__c charge{get;set;}
    public list<Product_Charge_Attribute__c> listOfproductChargeAttributes{get;set;}
    String chrageId;
    public  integer count;
    public list<createChrgeWrapper> listOfcreateChrgeWrapper{get;set;}
    createChrgeWrapper createChrgeWrapObj;
    public integer classCounter = -1;
    list<Product_Charge_Attribute__c> listOfPChargeAttRemove;
    public CreateProductChrgeAttributeExtension (ApexPages.StandardController controller) {
        listOfPChargeAttRemove = new list<Product_Charge_Attribute__c>();
        isVisible = true;
        this.charge = (invoiceit_s__Product_Rate_Plan_Charge__c)controller.getRecord();
        chrageId = ApexPages.currentPage().getParameters().get('id');
        if(chrageId !=null){
            charge = [SELECT id,Name,invoiceit_s__Product_Rate_Plan__r.name,invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__c,invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.name
                      FROM invoiceit_s__Product_Rate_Plan_Charge__c
                      WHERE id=:chrageId ];   
        }
        listOfproductChargeAttributes = [SELECT id,Name,Attribute_Name__c,Product_Rate_Plan_Charge__c,Attribute_Type__c
                                         FROM Product_Charge_Attribute__c
                                         WHERE Product_Rate_Plan_Charge__c =:chrageId ];
        listOfcreateChrgeWrapper = new list<createChrgeWrapper>();
        if(!listOfproductChargeAttributes.isEmpty()){
            for(Product_Charge_Attribute__c proChargeAtt: listOfproductChargeAttributes){
                createChrgeWrapObj = new createChrgeWrapper();
                //productChargeAttribute = new Product_Charge_Attribute__c();                            
                createChrgeWrapObj.productChargeAttributeWrap = proChargeAtt;

                createChrgeWrapObj.counter = ++classCounter;
                listOfcreateChrgeWrapper.add(createChrgeWrapObj);
            }
        }
        else {                                       
            createChrgeWrapObj = new createChrgeWrapper(); 
            productChargeAttribute = new Product_Charge_Attribute__c();         

        }
    }

    public PageReference addingProductChargeAttribute() {
        String SFieldName ='';
        Integer listSize = listOfcreateChrgeWrapper.size();
        if(listSize  > 1) {
            SFieldName = listOfcreateChrgeWrapper[listSize - 1].productChargeAttributeWrap.Attribute_Name__c;
            for(Integer i =0; i < listSize; i++) {
                if(i != listSize - 1) {
                    if(SFieldName == listOfcreateChrgeWrapper[i].productChargeAttributeWrap.Attribute_Name__c) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Field Name');
                        ApexPages.addMessage(myMsg);                        
                        return null;
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
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate Field Name');
                    ApexPages.addMessage(myMsg);                        
                    return null;
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
    } 

}