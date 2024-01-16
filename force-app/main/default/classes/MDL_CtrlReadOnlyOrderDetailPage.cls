/*
 *
 * Created By       :   Lister Technologies
 * Creation Date    :   24/07/2014
 * Purpose          :   To show a "read only view" on the Order Detail page that contains: order products, charges, attributes, dates and dollar values
 *
*/
public with sharing class MDL_CtrlReadOnlyOrderDetailPage {
    private ApexPages.StandardController standardController;
    public  invoiceit_s__Job__c orderRecord;
    public  String orderId{get;set;}
    public  transient List<invoiceit_s__Job_Rate_Plan_Charge__c> orderRPCList{get;set;}
    public  transient List<invoiceit_s__Job_Rate_Plan_Charge__c> bundlerOrpclist{get;set;}
    public  transient List<invoiceit_s__Job_Rate_Plan_Charge__c> OrpclistAlacart{get;set;}
    public  transient Decimal TotalValue{get;set;}   
    public MDL_CtrlReadOnlyOrderDetailPage(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        orderid=standardController.getId();
        TotalValue = 0.0;
        orderRecord = new invoiceit_s__Job__c();
        orderRPCList = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        bundlerOrpclist = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        OrpclistAlacart = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        orderRPCList = [Select  i.Name,i.invoiceit_s__Status__c, i.invoiceit_s__Service_End_Date__c, i.invoiceit_s__Service_Activation_Date__c, i.invoiceit_s__Row_Total__c, 
                                i.invoiceit_s__Job_Rate_Plan__c, (Select   Name,  
                                 Attribute_Name__c,Attr_Name__c,  
                                 Attribute_Type__c, Boolean_Value__c, Date_Value__c, 
                                 Number_Value__c,  Phone_Value__c, Picklist_Value__c, String_Value__c
                                From Order_Charge_Attributes__r ORDER By Address_Order__c ASC,Attribute_Order__c DESC NULLS LAST),invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.Name , Cancel_Date__c ,
                                Package_Component__c,invoiceit_s__Product_Bundle_Line__c,Package_Wrapper__c,
                                Fulfilment_Start_Date__c , Fulfilment_End_Date__c,of_days__c
                        From invoiceit_s__Job_Rate_Plan_Charge__c i
                        Where i.invoiceit_s__Order__c =: orderid
                        Order BY Package_Wrapper__c DESC];
        
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c orpc : orderRPCList){
            system.debug('@@@@orpc package wraper'+orpc.Package_Wrapper__c);
            system.debug('@@@@orpc Package_Component__c'+orpc.Package_Component__c);
            if(orpc.Package_Component__c || orpc.invoiceit_s__Product_Bundle_Line__c != null){
               bundlerOrpclist.add(orpc);
            }
        }    
        
        for(invoiceit_s__Job_Rate_Plan_Charge__c orpc : orderRPCList){
            //system.debug('@@@@orpc package wraper'+orpc.Package_Wrapper__c);
            //system.debug('@@@@orpc Package_Component__c'+orpc.Package_Component__c);
            if(orpc.Package_Component__c == False){
               OrpclistAlacart.add(orpc);
            }
        }    
             
    }
    
    Public void initialize(){
    invoiceit_s__Job_Rate_Plan_Charge__c orderRPC = new invoiceit_s__Job_Rate_Plan_Charge__c();
     for(invoiceit_s__Job_Rate_Plan_Charge__c orderRPCtemp : orderRPCList) {
            TotalValue += orderRPCtemp.of_days__c;
     }
     invoiceit_s__Job__c jobtoupdate = new invoiceit_s__Job__c(Id=orderid);
     jobtoupdate.Total_ECF__c = TotalValue;
     update jobtoupdate;
    }
    
    public Pagereference cancel() {
        return new PageReference('/'+orderId);
    }
}