public class ClassForDefineChargesValidity {
    public invoiceit_s__Job__c order{get;set;}
    public Id orderId{get;set;}
    public String value{set;get;}
    public list<invoiceit_s__Job_Rate_Plan_Charge__c> listOfOPRCharge{set;get;}
    public map<Integer, ClassForDefineChargesValidity.InnerClassORPC> map_Counter_InnerClassORPC {set; get;}
    public boolean isVisible{get;set;}    
    public ClassForDefineChargesValidity.InnerClassORPC innerClassORPC ;

    public ClassForDefineChargesValidity(ApexPages.StandardController controller) {
        orderId = ApexPages.currentPage().getParameters().get('id');
        order = [SELECT name, invoiceit_s__Status__c, invoiceit_s__Service_Activation_Date__c,
                 invoiceit_s__Service_End_Date__c FROM invoiceit_s__Job__c 
                 WHERE id =: orderId];             
    }             
    public List<selectOption> getvalues() {
        List<selectOption> options = new List<selectOption>();            
        options.add(new selectOption('', '- None -'));
        options.add(new selectOption('Extend', 'Extend'));
        options.add(new selectOption('Renew', 'Renew'));
        options.add(new selectOption('Cancel', 'Cancel'));
        return options;
    }

    public void changeValue() {

    }
    public PageReference fetchORPC(){
        if(value != null){

            listOfOPRCharge = [SELECT Name, invoiceit_s__Status__c,invoiceit_s__Service_Activation_Date__c,
                               invoiceit_s__Service_End_Date__c,
                               (SELECT Attribute_Order__c,Picklist_Value__c, Attribute_Picklist_Values__c,Phone_Value__c,Name,Attribute_Name__c,Maximum_No_Of_Characters_In_Text__c,Attribute_Type__c,Boolean_Value__c,Date_Value__c,Number_Value__c,Order_Rate_Plan_Charge__c,String_Value__c
                               FROM Order_Charge_Attributes__r ORDER By Attribute_Order__c)
                                FROM invoiceit_s__Job_Rate_Plan_Charge__c
                               WHERE  invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__r.Id =: orderId];
            system.debug('listOfOPRCharge ' +listOfOPRCharge);

            if(listOfOPRCharge.isEmpty()){
                isVisible = false;                    
                ApexPages.Message pageMessg = new ApexPages.Message(ApexPages.Severity.INFO,'Charges are not present associated with this Order');
                ApexPages.addMessage(pageMessg);
                return null;       
            } else{
                isVisible = true;
            }           

            map_Counter_InnerClassORPC = new map<Integer, ClassForDefineChargesValidity.InnerClassORPC>();                                                
            integer counter = 0;           

            for(invoiceit_s__Job_Rate_Plan_Charge__c orpc : listOfOPRCharge){

                innerClassORPC  = new  ClassForDefineChargesValidity.InnerClassORPC();
                counter = ++counter;                
                innerClassORPC.isChecked = false;
                innerClassORPC.orderRPC = orpc;
                System.debug('printing attributes--->'+orpc.Order_Charge_Attributes__r);
                innerClassORPC.listOforderChargeAtt = new list<Order_Charge_Attribute__c>();
                innerClassORPC.listOforderChargeAtt.addAll(orpc.Order_Charge_Attributes__r);
                map_Counter_InnerClassORPC.put(counter,innerClassORPC);            
            }

        }else{                   
            isVisible = false;        
        }                      
        return null;
    }


    public PageReference save(){
    if(value == null){
         ApexPages.Message pageMessg = new ApexPages.Message(ApexPages.Severity.INFO,'Please select the option for charge validity for further processing.');
         ApexPages.addMessage(pageMessg);
         return null;      
    }
        list<invoiceit_s__Job_Rate_Plan_Charge__c> listOfORPC = new list<invoiceit_s__Job_Rate_Plan_Charge__c>();
        if(!map_Counter_InnerClassORPC.values().isEmpty()){
            for(InnerClassORPC innerClassORPC : map_Counter_InnerClassORPC.values()){
                System.debug('value'+value); 
                System.debug('innerClassORPC.orderRPC.invoiceit_s__Service_End_Date__c'+innerClassORPC.orderRPC.invoiceit_s__Service_End_Date__c);
                if(value== 'Cancel' && innerClassORPC.orderRPC.invoiceit_s__Service_End_Date__c == null && innerClassORPC.isChecked){ 
                    System.debug('hi im inside cancel block');                   
                    ApexPages.Message pageMessg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please populate Service End Date');
                    ApexPages.addMessage(pageMessg);
                    return null;       
                }
                System.debug('innerClassORPC.orderRPC.invoiceit_s__Service_End_Date__c2'+innerClassORPC.orderRPC.invoiceit_s__Service_End_Date__c);
                if(innerClassORPC.orderRPC.invoiceit_s__Service_End_Date__c < innerClassORPC.orderRPC.invoiceit_s__Service_Activation_Date__c && innerClassORPC.isChecked){
                    System.debug('hi im inside secomd if cancel block');   
                    ApexPages.Message pageMessg = new ApexPages.Message(ApexPages.Severity.ERROR,'Service End Date must be greater than Service Start Date.');
                    ApexPages.addMessage(pageMessg);
                    return null;       
                }
                if(value== 'Cancel' && innerClassORPC.isChecked){
                    innerClassORPC.orderRPC.invoiceit_s__Status__c = 'Cancelled';
                }
                listOfORPC.add(innerClassORPC.orderRPC);
                System.debug('Printing list--->'+listOfORPC);
            }       
        }

        if(!listOfORPC.isEmpty()){
            upsert listOfORPC;      
        }
        PageReference pageRef = new PageReference('/'+orderId);
        return pageRef;       
    }

    public PageReference cancel(){      
        PageReference pageRef = new PageReference('/'+orderId);
        return pageRef;       
    }

    public class InnerClassORPC{
        public integer counter {get;set;}                    
        public boolean isChecked {get;set;}
        public invoiceit_s__Job_Rate_Plan_Charge__c orderRPC{get;set;}  
        public list<Order_Charge_Attribute__c> listOforderChargeAtt{get;set;}     
    }            


}