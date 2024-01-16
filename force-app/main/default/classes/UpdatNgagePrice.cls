public class UpdatNgagePrice {

    private ApexPages.StandardController standardController;
    public list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> listOfOpptCharge{get;set;}
    //public list<OpptChargeWrapper> listOfOpptChargeWrapper{get;set;}
   // OpptChargeWrapper opptChargeWrapperObj;
    public Opportunity oppt{get;set;}
    Id opptId;
    public UpdatNgagePrice(ApexPages.StandardController controller) {
     this.standardController = standardController;
    listOfOpptCharge = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
    opptId = ApexPages.currentPage().getParameters().get('id');
        oppt = [SELECT name, Amount, CloseDate,StageName,invoiceit_crmx__Start_Date__c
                FROM Opportunity  
                WHERE id =:opptId];
       
      // Id profileId=userinfo.getProfileId();
       //profileName=[Select Id,Name from Profile where Id=:profileId].Name;
       //system.debug('@@@@ProfileName'+profileName);
       
       
        //query for list of oppt charges along with oppt charge attribute
        listOfOpptCharge = [SELECT Name,invoiceit_crmx__Opportunity_Rate_Plan__c,SIN__c,invoiceit_crmx__Unit_Price__c,invoiceit_crmx__Net_Total__c, invoiceit_crmx__Price_Type__c,
                             invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,URL_Attribute__c,invoiceit_crmx__Accounting_Code__c,
                             invoiceit_crmx__Price__c,invoiceit_crmx__Quantity__c ,invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name
                           //(SELECT Attribute_Order__c,Picklist_Value__c,Required__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, Attribute_Picklist_Values__c, Name,Attribute_Name__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Phone_Value__c,Number_Value__c,Opportunity_Rate_Plan_Charge__c,String_Value__c
                           // FROM Opportunity_Charge_Attributes__r where Attribute_Name__c = 'URL')
                            FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c
                            WHERE  invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Opportunity__c  =:opptId AND invoiceit_crmx__Accounting_Code__c = '60011' ];
    }
    
    public PageReference save(){
    
        try {    
            list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> updatecharges= new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Optycharges:listOfOpptCharge  ){

                    if(Optycharges.invoiceit_crmx__Unit_Price__c != null){
                         
                                 Optycharges.invoiceit_crmx__Net_Total__c =  Optycharges.invoiceit_crmx__Unit_Price__c ;
                                 Optycharges.invoiceit_crmx__Price__c=  Optycharges.invoiceit_crmx__Quantity__c * Optycharges.invoiceit_crmx__Unit_Price__c ;
                                 
                                 updatecharges.add(Optycharges); 
                            }
                    else{
                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Price cannot be left blank,Please fill with right value ');
                    ApexPages.addMessage(myMsg);
                    }
                        }

           
            if(!updatecharges.isEmpty()){
                update updatecharges;
            }


        } catch(Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An exception has occured. Exception message is : ' + ex.getMessage());
            ApexPages.addMessage(myMsg);
            return null;    
        }
        return new PageReference('/' + oppt.Id);
    }



}