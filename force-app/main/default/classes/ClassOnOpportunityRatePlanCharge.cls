public with sharing class ClassOnOpportunityRatePlanCharge {
        /*THIS APPLIES FOR SHIPPABLE PRODUCTS ONLY
        Sales Force Fields Product Attributes
        Account Name       Service Account name
        Shipping Street    Service Street Address
        Shipping City      Service City
        Shipping State     Service State
        Shipping Zip       Service Zipcode
        Shipping Country Service Country
        Shipping Contact Primary (Shipping) Contact*/
    
    // Req : 1
    // When ever ORPC charge is created we need to create a product attributes to the opportunity charge, the only exception to this is we do need when opptCharge.Quote_Type__c = 'Renew'/'Modify'
    /* method to create opportunity charge attribute of particular Oppt charge by using value from Product charge attribute
     *  Arrgument Product Rate plan charge map
     *  Rettun type void
     */
   set<id> oppid = new set<id>();
   public void handleAfterOnOpptRatePlanCharge(map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> newMap, map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oldMap) {

        // Oppt Charge Attribute list 
        list<Opportunity_Charge_Attribute__c> listOfopptChargeAttribute = new list<Opportunity_Charge_Attribute__c>();

        // set of ids of Product charge
        set<Id> productChargeidSet = new set<Id>(); 
        set<Id> accountIdset = new set<Id>();

        // transfering product Charge attribute infomration to Oppt charge attribute
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opptCharge : newMap.values()) {
            if(opptCharge.Quote_Type__c == null || opptCharge.Quote_Type__c == 'New')
                productChargeidSet.add(opptCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c);

            accountIdset.add(opptCharge.Account_Id__c);
        }

        //map of product charge id with product charge
        map<Id, invoiceit_s__Product_Rate_Plan_Charge__c> map_proRatePlanChareg = new map<Id, invoiceit_s__Product_Rate_Plan_Charge__c>();

        // map of accountid with account
        map<id, Account> map_Account = new map<id, Account>();
        //quering account information
        if(!accountIdset.isEmpty()){
            map_Account = new map<id, Account>([SELECT Id,Name,ShippingCity,tz__Timezone_Full_F__c,ShippingState,ShippingCountry,Phone,ShippingPostalCode,ShippingStreet,Website,
                                                BillingCity,BillingState,BillingCountry,BillingPostalCode,BillingStreet, Firm_Email__c
                                                FROM Account
                                                WHERE id IN:accountIdset]); 

        }

        //quering product charge with product charge attribute
        if(!productChargeidSet.isEmpty()){
            map_proRatePlanChareg = new map<Id, invoiceit_s__Product_Rate_Plan_Charge__c>([SELECT Name, 
                                                                                           invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.Shippable__c,
                                                                                           (SELECT name, Attribute_Name__c, Attribute_Type__c, Product_Rate_Plan_Charge__c,
                                                                                                   Default_Boolean__c,Default_Currency__c,Default_Date__c,Default_Number__c,Default_Text__c,Required__c,
                                                                                                   AttributeName__r.Attribute_Picklist_Values__c,
                                                                                                   AttributeName__r.Attribute_Type__c,
                                                                                                   Attribute_Order__c,Show_in_DocuSign__c,Secondary_Attribute_Name__c,
                                                                                                   AttributeName__r.Name,
                                                                                                   AttributeName__r.Maximum_No_Of_Characters_In_Text__c,
                                                                                                   AttributeName__r.Minimum_No_Of_Characters_In_Text__c
                                                                                                   FROM Product_Charge_Attributes__r)
                                                                                                   FROM invoiceit_s__Product_Rate_Plan_Charge__c 
                                                                                                   WHERE id IN : productChargeidSet
                                                                                                   ]);
        }
        list<Product_Charge_Attribute__c> listOfProductChargeAttribute;
        Opportunity_Charge_Attribute__c  opptChargeAtt;

        if(!map_proRatePlanChareg.isEmpty()){
            //iterating through list of oppt charge 
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opptCharge : newMap.values()) {
                if(opptCharge.Quote_Type__c == null || opptCharge.Quote_Type__c == 'New') {
                    if(opptCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c != null) {
                        if( map_proRatePlanChareg.containskey(opptCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c )) {
                            listOfProductChargeAttribute = map_proRatePlanChareg.get(opptCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c).Product_Charge_Attributes__r;
                            System.debug('Printing size of listofloc'+listOfProductChargeAttribute.size());
                            
                            invoiceit_s__Product_Rate_Plan_Charge__c prpc = map_proRatePlanChareg.get(opptCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c);
                            
                            //iterating list of product attribute record and creating Oppt attribute
                            for(Product_Charge_Attribute__c productChargeAttr : listOfProductChargeAttribute) {
                                opptChargeAtt = new Opportunity_Charge_Attribute__c();
                                opptChargeAtt.Attribute_Type__c = productChargeAttr.AttributeName__r.Attribute_Type__c;
                                opptChargeAtt.Attribute_Name__c = productChargeAttr.AttributeName__r.Name;
                                opptChargeAtt.Required__c = productChargeAttr.Required__c;
                                
                                
                                // verify if it is a Shippable product or not
                                if(prpc.invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.Shippable__c == 'Yes') {
                                            Account account = map_Account.get(opptCharge.Account_Id__c);        
                                            
                                            if(opptChargeAtt.Attribute_Name__c == 'Service Account Name' || opptChargeAtt.Attribute_Name__c == 'Xref Service Account Name') {
                                                if(opptChargeAtt.Attribute_Type__c == 'Text'){
                                                    opptChargeAtt.String_Value__c = account.name;   
                                                }   
                                                else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                    opptChargeAtt.Picklist_Value__c = account.name; 
                                                }   
                                            }
                                            else if(opptChargeAtt.Attribute_Name__c == 'Service Street Address'){
                                        
                                                if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingStreet != NULL){
                                                       opptChargeAtt.String_Value__c = account.ShippingStreet;
                                                }                                                  
                                                else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingStreet == NULL){
                                                    opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                                }
                                                else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                    opptChargeAtt.Picklist_Value__c = account.ShippingStreet;   
                                                }   
                                                                          
                                            }
                                            else if(opptChargeAtt.Attribute_Name__c == 'Service City'){
                                                if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingCity != NULL){
                                                    opptChargeAtt.String_Value__c = account.ShippingCity;   
                                                } 
                                                else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingCity == NULL){
                                                    opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                                }  
                                                else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                    opptChargeAtt.Picklist_Value__c = account.ShippingCity; 
                                                }   
                                            }
                                            else if(opptChargeAtt.Attribute_Name__c == 'Service State'){
                                                if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingState !=NULL){
                                                    opptChargeAtt.String_Value__c = account.ShippingState;  
                                                } 
                                                else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingState == NULL){
                                                    opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                                }  
                                                else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                    opptChargeAtt.Picklist_Value__c = account.ShippingState;    
                                                }   
                                            }
                                            else if(opptChargeAtt.Attribute_Name__c == 'Service Country'){
                                                if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingCountry != NULL){
                                                    opptChargeAtt.String_Value__c = account.ShippingCountry;    
                                                }  
                                                else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingCountry == NULL){
                                                    opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                                }  
                                                else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                    opptChargeAtt.Picklist_Value__c = account.ShippingCountry;  
                                                }   
                                            }
                                            else if(opptChargeAtt.Attribute_Name__c == 'Service Zip'){
                                                if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingPostalCode !=NULL){
                                                    opptChargeAtt.String_Value__c = account.ShippingPostalCode; 
                                                } 
                                                else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.ShippingPostalCode == NULL){
                                                    opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                                }  
                                                else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                    opptChargeAtt.Picklist_Value__c = account.ShippingPostalCode;   
                                                }  
                                                                          
                                            }else if(opptChargeAtt.Attribute_Name__c=='Timezone'){
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.tz__Timezone_Full_F__c !=NULL){
                                                opptChargeAtt.String_Value__c = account.tz__Timezone_Full_F__c;   
                                            }
                                          }
                                }
                                
                                else {
                                    // non shippable products
                                    // populate attribute value according to jira LN-23
                                    if(map_Account.containskey(opptCharge.Account_Id__c)){
                                        Account account = map_Account.get(opptCharge.Account_Id__c);
    
                                        if(opptChargeAtt.Attribute_Name__c == 'Service Account Name' || opptChargeAtt.Attribute_Name__c == 'Xref Service Account Name') {
                                            if(opptChargeAtt.Attribute_Type__c == 'Text'){
                                                opptChargeAtt.String_Value__c = account.name;   
                                            }   
                                            else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                opptChargeAtt.Picklist_Value__c = account.name; 
                                            }   
                                            else{
    
                                            }                           
                                        }else if(opptChargeAtt.Attribute_Name__c=='Timezone'){
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.tz__Timezone_Full_F__c !=NULL){
                                                opptChargeAtt.String_Value__c = account.tz__Timezone_Full_F__c;   
                                            }
                                          }
                                        else if(opptChargeAtt.Attribute_Name__c == 'Service Street Address'){
                                            
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingStreet != NULL){
                                                   opptChargeAtt.String_Value__c = account.BillingStreet;
                                            } 
                                            
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingStreet != NULL){
                                                   opptChargeAtt.String_Value__c = account.BillingStreet;
                                            }   
                                            else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingStreet == NULL){
                                                opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }
                                            else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                opptChargeAtt.Picklist_Value__c = account.BillingStreet;   
                                            }   
                                                                      
                                        }
                                        else if(opptChargeAtt.Attribute_Name__c == 'Service City'){
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingCity != NULL){
                                                opptChargeAtt.String_Value__c = account.BillingCity;   
                                            } 
                                            else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingCity == NULL){
                                                opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }  
                                            else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                opptChargeAtt.Picklist_Value__c = account.BillingCity; 
                                            }   
                                            else{
    
                                            }                           
                                        }
                                        else if(opptChargeAtt.Attribute_Name__c == 'Service State'){
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingState !=NULL){
                                                opptChargeAtt.String_Value__c = account.BillingState;  
                                            } 
                                            else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingState == NULL){
                                                opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }  
                                            else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                opptChargeAtt.Picklist_Value__c = account.BillingState;    
                                            }   
                                            else{
    
                                            }                           
                                        }
                                        else if(opptChargeAtt.Attribute_Name__c == 'Service Country'){
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingCountry != NULL){
                                                opptChargeAtt.String_Value__c = account.BillingCountry;    
                                            }  
                                            else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingCountry == NULL){
                                                opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }  
                                            else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                opptChargeAtt.Picklist_Value__c = account.BillingCountry;  
                                            }   
                                            else{
    
                                            }                           
                                        }
                                        else if(opptChargeAtt.Attribute_Name__c == 'Service Zip'){
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingPostalCode !=NULL){
                                                opptChargeAtt.String_Value__c = account.BillingPostalCode; 
                                            } 
                                            else if(opptChargeAtt.Attribute_Type__c == 'Text' && account.BillingPostalCode == NULL){
                                                opptChargeAtt.String_Value__c  = productChargeAttr.Default_Text__c;
                                            }  
                                            else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                                opptChargeAtt.Picklist_Value__c = account.BillingPostalCode;   
                                            }  
                                            else{
    
                                            }                           
                                        }

                                        else if(opptChargeAtt.Attribute_Name__c == 'Ring To Number'){
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.Phone !=NULL){
                                                opptChargeAtt.String_Value__c = account.Phone.replaceAll('[^\\d.]', '');   
                                            }
                                        }
                                        
                                        else if(opptChargeAtt.Attribute_Name__c == 'Domain Name' || opptChargeAtt.Attribute_Name__c == 'Location' || opptChargeAtt.Attribute_Name__c == 'URL'){
                                            if(opptChargeAtt.Attribute_Type__c == 'Text' && account.Website !=NULL){
                                                opptChargeAtt.String_Value__c = account.Website;   
                                            } else {
                                                if(opptChargeAtt.Attribute_Type__c == 'Picklist' && account.Website !=NULL){
                                                    opptChargeAtt.Picklist_Value__c = account.Website;   
                                                }
                                            }
                                        }  
                                        
                                        else{
                                            if(opptChargeAtt.Attribute_Type__c == 'Date'){
                                                opptChargeAtt.Date_Value__c= productChargeAttr.Default_Date__c;
                                            
                                            }
                                            else if(opptChargeAtt.Attribute_Type__c == 'Boolean'){
                                                 opptChargeAtt.Boolean_Value__c = productChargeAttr.Default_Boolean__c;    
                                            }
                                            else if(opptChargeAtt.Attribute_Type__c == 'Date'){
                                                opptChargeAtt.Date_Value__c= productChargeAttr.Default_Date__c;
                                            }
                                            else if(opptChargeAtt.Attribute_Type__c == 'Number'){
                                                opptChargeAtt.Number_Value__c = productChargeAttr.Default_Number__c;
                                                
                                            }
                                        else if (opptChargeAtt.Attribute_Type__c == 'Currency'){
                                                 opptChargeAtt.String_Value__c = productChargeAttr.Default_Currency__c ;
                                                
                                            }
                                          
                                        }
                                    }
                            }
                            
                            if(opptChargeAtt.Attribute_Name__c == 'Language'){
                                if(opptChargeAtt.Attribute_Type__c == 'Text' && productChargeAttr.Default_Text__c == null){
                                    opptChargeAtt.String_Value__c = 'English';   
                                } else if(opptChargeAtt.Attribute_Type__c == 'Text' && productChargeAttr.Default_Text__c != null){
                                    opptChargeAtt.String_Value__c = productChargeAttr.Default_Text__c;      
                                } else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                    opptChargeAtt.Picklist_Value__c = 'English';  
                                }   
                            }
                            else if(opptChargeAtt.Attribute_Name__c == 'Country'){
                                if(opptChargeAtt.Attribute_Type__c == 'Text' && productChargeAttr.Default_Text__c == null){
                                    opptChargeAtt.String_Value__c = 'USA';   
                                } else if(opptChargeAtt.Attribute_Type__c == 'Text' && productChargeAttr.Default_Text__c != null){
                                    opptChargeAtt.String_Value__c = productChargeAttr.Default_Text__c;      
                                } else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                    opptChargeAtt.Picklist_Value__c = 'USA';  
                                }   
                            }
                            else if(opptChargeAtt.Attribute_Name__c == 'Call Tracking'){
                                if(opptChargeAtt.Attribute_Type__c == 'Text'){
                                    opptChargeAtt.String_Value__c = 'Y';   
                                }else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                    opptChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            else if(opptChargeAtt.Attribute_Name__c == 'Phone Number Type'){
                                if(opptChargeAtt.Attribute_Type__c == 'Text'){
                                    opptChargeAtt.String_Value__c = 'Local';   
                                }else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                    opptChargeAtt.Picklist_Value__c = 'Local';  
                                }   
                            }
                            else if(opptChargeAtt.Attribute_Name__c == 'Primary Website'){
                                if(opptChargeAtt.Attribute_Type__c == 'Text'){
                                    opptChargeAtt.String_Value__c = 'Y';   
                                }else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                    opptChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            else if(opptChargeAtt.Attribute_Name__c == 'Call Firm Now'){
                                if(opptChargeAtt.Attribute_Type__c == 'Text'){
                                    opptChargeAtt.String_Value__c = 'Y';   
                                }else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                    opptChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            else if(opptChargeAtt.Attribute_Name__c == 'Direct Website Link'){
                                if(opptChargeAtt.Attribute_Type__c == 'Text'){
                                    opptChargeAtt.String_Value__c = 'Y';   
                                }else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                    opptChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            else if(opptChargeAtt.Attribute_Name__c == 'Starter Kit'){
                                if(opptChargeAtt.Attribute_Type__c == 'Text'){
                                    opptChargeAtt.String_Value__c = 'Y';   
                                }else if(opptChargeAtt.Attribute_Type__c == 'Picklist'){
                                    opptChargeAtt.Picklist_Value__c = 'Y';  
                                }   
                            }
                            
                                

                                opptChargeAtt.Attribute_Picklist_Values__c = productChargeAttr.AttributeName__r.Attribute_Picklist_Values__c;
                                opptChargeAtt.Attribute_Order__c = productChargeAttr.Attribute_Order__c;
                                opptChargeAtt.Secondary_Attribute_Name__c= productChargeAttr.Secondary_Attribute_Name__c;
                                opptChargeAtt.Show_in_DocuSign__c = productChargeAttr.Show_in_DocuSign__c;
                                opptChargeAtt.Opportunity_Rate_Plan_Charge__c = opptCharge.Id;
                                opptChargeAtt.Maximum_No_Of_Characters_In_Text__c = productChargeAttr.AttributeName__r.Maximum_No_Of_Characters_In_Text__c;
                                opptChargeAtt.Minimum_No_Of_Characters_In_Text__c = productChargeAttr.AttributeName__r.Minimum_No_Of_Characters_In_Text__c;
                                listOfopptChargeAttribute.add(opptChargeAtt);
                            }    
                        }
                    }
                }
            }
        }

        if(!listOfopptChargeAttribute.isEmpty()){
            try{
                upsert listOfopptChargeAttribute;
            }catch(Exception ex) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An exception has occured. Exception message is : ' + ex.getMessage());
                ApexPages.addMessage(myMsg);
               
            }
            
        }
    }


   public void checkAndUpdateChat(list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> orpclist, map<id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> newmap)
    {
      list<Chat_Product_Opportunity_Charge__c> cpoc = new list<Chat_Product_Opportunity_Charge__c>();
      list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> orpcprofList = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
      list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> orpcList1 = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
      set<id> setid = new set<id>();
      list<invoiceit_crmx__Opportunity_Product__c> op = new list<invoiceit_crmx__Opportunity_Product__c>();
      list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> OppORPCList = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
      list<Chat_Product_Opportunity_Charge__c> cp = new list<Chat_Product_Opportunity_Charge__c> ();
      set<string> multiProdPerChatSet = new set<string>();
      System.debug('ORPC List: ' + orpclist);
        
       for (Chat_Products__c c: Chat_Products__c.getall().values())
        {
                if (c.Multi_Products_Per_Chat__c == true && c.ConversationProduct__c == false)
                   multiProdPerChatSet.add(c.Product_Name__c);
        }        
      orpclist1 = [select id, name, invoiceit_crmx__Opportunity__c, invoiceit_crmx__Opportunity_Rate_Plan__c, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c, invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name, invoiceit_crmx__Accounting_Code__c from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c where id in :newmap.keyset() ];
      for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c o:orpclist1)
      {
            system.debug('ORPC LIST: ' + o.id + ' : ' + o.name + ' : ' + o.invoiceit_crmx__Opportunity_Rate_Plan__c + ' : ' + o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c);
            system.debug('Opp Product Name: ' + o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__r.name + ' Code: ' + o.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c);
            if(multiProdPerChatset.contains(o.invoiceit_crmx__Accounting_Code__c))
            {
                orpcprofList.add(o);
                oppid.add(o.invoiceit_crmx__Opportunity__c);
            }
            setid.add(o.id);
      }
      cpoc = [select Chat_Product_Opp_Rate_Plan_Charge__c, Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c, Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c, Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, Chat_Usage_Opp_Rate_Plan_Charge__c from Chat_Product_Opportunity_Charge__c where Chat_Usage_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c in :Oppid and Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Accounting_Code__c in :multiProdPerChatset];
      id oldoppid = null;
      for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c or1: orpcproflist)
      {
            for ( Chat_Product_Opportunity_Charge__c o: cpoc) 
            {
                if(o.Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c == or1.invoiceit_crmx__Opportunity__c)
                {
                    cp.add(new Chat_Product_Opportunity_Charge__c(Chat_Product_Opp_Rate_Plan_Charge__c=or1.id, Chat_Usage_Opp_Rate_Plan_Charge__c = o.Chat_Usage_Opp_Rate_Plan_Charge__c));                     
                    op.add(new invoiceit_crmx__Opportunity_Product__c(id = or1.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, Is_Chat_Option_Shown__c='Yes'));
                    break;
                }
            }
        }
        
         system.debug('chat opp rpc ' + cp + ' Oppor Product: ' + op );
        if(!cp.isEmpty())
            insert cp;
        
        system.debug('Error on update of Opp product');
        if(!op.isEmpty())
            update op;
    } 
    
    //STATIC VARIABLE
    
    private static boolean runNeedApproval = true;
    public static boolean runOnceNeedApproval(){
    if(runNeedApproval){
     runNeedApproval =false;
     return true;
    }else{
        return runNeedApproval;
    }
    }
    
    
    public void createProfessionalProfilejunctionRecord(List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> chargestList){
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>chargesSet = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        set<Id> optyIds = new set<Id>();
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge:chargestList){
            if(charge.invoiceit_crmx__Accounting_Code__c == '11006'){
                chargesSet.add(charge);
                optyIds.add(charge.invoiceit_crmx__Opportunity__c);
            }
        }
        
        Map<id,Chat_Product_Opportunity_Charge__c> optyIdVscpoc = new Map<id,Chat_Product_Opportunity_Charge__c>();
        List<Chat_Product_Opportunity_Charge__c>cpocInsert = new List<Chat_Product_Opportunity_Charge__c>();
        if(!optyIds.isEmpty()){
            for(Chat_Product_Opportunity_Charge__c cpoc : [select id,Chat_Product_Opp_Rate_Plan_Charge__c,
                                                                  Chat_Usage_Opp_Rate_Plan_Charge__c,
                                                                Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c,
                                                              Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Accounting_Code__c
                                                              From Chat_Product_Opportunity_Charge__c
                                                              where Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c IN:optyIds
                                                           AND Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Accounting_Code__c='11006']){
                optyIdVscpoc.put(cpoc.Chat_Product_Opp_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity__c,cpoc);                                                       
            }
        }
        
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge : chargesSet){
            if(!optyIdVscpoc.isEmpty() && optyIdVscpoc.containsKey(charge.invoiceit_crmx__Opportunity__c)){
                string chatusageId = optyIdVscpoc.get(charge.invoiceit_crmx__Opportunity__c).Chat_Usage_Opp_Rate_Plan_Charge__c;
                cpocInsert.add(new Chat_Product_Opportunity_Charge__c(Chat_Product_Opp_Rate_Plan_Charge__c= charge.id,
                                                                       Chat_Usage_Opp_Rate_Plan_Charge__c = chatusageId));
            }
        }
        
        if(!cpocInsert.isEmpty()){
            insert cpocInsert;
        }
        
    }
    

}