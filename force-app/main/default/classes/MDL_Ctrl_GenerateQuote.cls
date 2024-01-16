public with sharing class MDL_Ctrl_GenerateQuote {
    public MDL_Ctrl_GenerateQuote() {
    }
    /*
    public decimal monthlyFees {get;set;}
    public Opportunity opportunity {get;set;}  
    public invoiceit_s__Quote__c quote{get;set;}
    public List<String> listOfOneTimeProd {get;set;}
    public List<String> listOfSubscriptionProd {get;set;}
    public List<Id> oneTimeProduct {get;set;}  
    public List<Id> subscriptionProduct {get;set;}
    public Decimal totalOneTimeSubscription {get;set;}
    public Decimal totalMonthlySubscription {get;set;}
    public String SenderName {get;set;}
    public String SenderTitle {get;set;}
    public String SenderEmail {get;set;}
    public String SenderPhone {get;set;}
    public String SenderFax {get;set;}
    public MDL_Ctrl_GenerateQuote() {
    }
    public MDL_Ctrl_GenerateQuote(ApexPages.StandardController stdController) {
        if(ApexPages.currentPage().getParameters().get('id')  != null){
            String qId = ApexPages.currentPage().getParameters().get('id'); 
            String OppId = '';
            monthlyFees = 0;
            opportunity = new Opportunity();
            quote = new invoiceit_s__Quote__c();
            oneTimeProduct = new List<Id>();
            subscriptionProduct = new List<Id>();
            listOfOneTimeProd = new List<String>();
            listOfSubscriptionProd = new List<String>();
            
            quote = [Select i.invoiceit_crmx__Opportunity__c From invoiceit_s__Quote__c i where id =: qId];
            OppId = quote.invoiceit_crmx__Opportunity__c;
            opportunity = [Select   invoiceit_crmx__Sub_Total__c ,  invoiceit_crmx__Shipping_Contact__r.Name,
                            Account.Owner.Name , Account.Owner.Title , Account.Owner.Email,
                            Account.Owner.Phone , Account.Owner.Fax ,   invoiceit_crmx__Number_Of_Terms__c,
                            (Select Name from invoiceit_crmx__Opportunity_Products__r) from Opportunity where Id =: OppId];
            if(opportunity.Account.Owner.Name != null)
                SenderName = opportunity.Account.Owner.Name;
            if(opportunity.Account.Owner.Title != null)    
                SenderTitle = opportunity.Account.Owner.Title;
            if(opportunity.Account.Owner.Email != null)    
                SenderEmail = opportunity.Account.Owner.Email;
            if(opportunity.Account.Owner.Phone != null)    
                SenderPhone = opportunity.Account.Owner.Phone;
            if(opportunity.Account.Owner.Fax != null)    
                SenderFax = opportunity.Account.Owner.Fax;
            //prod = new List<invoiceit_s__Quote_Product__c>();
            
            //prod = quote.invoiceit_s__Quote_Product__r;     
            
            //System.debug('monthly fees is : '+monthlyFees);
            
            List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> OppRPC = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
            
            OppRPC = [Select id , Name, invoiceit_crmx__Product_Rate_Plan_Charge__c,    invoiceit_crmx__Net_Total__c, 
                            invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c,
                            invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,
                            invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name,
                            Terms_Months__c                     
                        from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                        where   invoiceit_crmx__Opportunity__c =:  OppId];
            
             
            totalOneTimeSubscription = 0;
            totalMonthlySubscription = 0;
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c  oRPC : oppRPC){
                if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c != null){
                    if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'One Time'){
                        //oneTimeProduct.add(oRPC.invoiceit_s__Quote_Rate_Plan__r.invoiceit_s__Quote_Product__c); 
                        if(oRPC.Terms_Months__c != 1)
                            listOfOneTimeProd.add(oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name                                             
                                                +' - '
                                                +oRPC.Terms_Months__c + ' months');
                        
                        else
                            listOfOneTimeProd.add(oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name
                                                    + ' - '                                                 
                                                    +oRPC.Terms_Months__c
                                                    +' month');                     
                        system.debug('what is the decimal ' + oRPC.invoiceit_crmx__Net_Total__c);
                        totalOneTimeSubscription += oRPC.invoiceit_crmx__Net_Total__c.setScale(2);
                        system.debug('what is the decimal2 ' + totalOneTimeSubscription);
                    }
                    
                    else{
                        //subscriptionProduct.add(oRPC.invoiceit_s__Quote_Rate_Plan__r.invoiceit_s__Quote_Product__c);
                        if(oRPC.Terms_Months__c != 1)
                            listOfSubscriptionProd.add(oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name
                                                    + ' - '                                                 
                                                    +oRPC.Terms_Months__c
                                                    +' months');
                        else
                            listOfSubscriptionProd.add(oRPC.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name
                                                    + ' - '                                                 
                                                    +oRPC.Terms_Months__c
                                                    +' month');
                        if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'Monthly')
                            totalMonthlySubscription += oRPC.invoiceit_crmx__Net_Total__c.setScale(2);
                        if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'Quarterly')
                            totalMonthlySubscription += (oRPC.invoiceit_crmx__Net_Total__c)/3; 
                        if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'Half Yearly')
                            totalMonthlySubscription += (oRPC.invoiceit_crmx__Net_Total__c)/6;
                        if(oRPC.invoiceit_crmx__Product_Rate_Plan_Charge__r.invoiceit_s__Price_Type__c == 'Annual')
                            totalMonthlySubscription += (oRPC.invoiceit_crmx__Net_Total__c)/12;
                            
                    }
                }
            }
            //totalOneTimeSubscription = 100;
                        
        }   
    } */
}