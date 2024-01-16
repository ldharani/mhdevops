/*********************************************************************************
Created By : Lister Technologies

Created Purpose : This class is a controller class for MDL_PayNow page where the 
                  user can pay any of his 'unpaid' and 'posted' invoices.
                  First, the credit card details entered by the user are authorized 
                  from Authorize.net. Then, the payment is done using an Invoice IT
                  class.
Modified by : Lister Technologies
Modified Purpose : MHBS-173
***********************************************************************************/
public class MDL_PayNowController{
        ApexPages.standardController m_sc = null;
        public string invId{get;set;}
        public integer isCardDefault;   
        public invoiceit_s__Payment_Method__c paymentMethod{get;set;}
        public invoiceit_s__Payment_Method__c paymentMethodold;
        public Account  acctObj {get; set;}
        public invoiceit_s__Invoice__c invoiceObj {get; set;}
        public string PhoneNo;
        public string Phone {get;set;}
        public String sessionId {get;set;}
        public String token {get;set;}
        public boolean displayPage {get;set;}
        public String authorizeNpay {get;set;}
        public boolean isDefaultPaymentMethod;
        public String payMethID {get;set;}        
        public String baseCSCURL {get;set;}
        public String formSubmitCSCURL {get;set;}
        public String userIdFromHeader;
        public String formSMBSubmitURL {get;set;}
        public String formURL {get;set;}
        //public String smbrowtoken {get;set;}
        //public String smbtoken {get;set;}

        public string CardholderName{get;set;}
        public string CardBillingStreet{get;set;}
        public string CardBillingCity{get;set;}
        public string CardBillingCountry{get;set;}
        public string CardBillingState{get;set;}
        public boolean toInsert;
        public boolean toUpdate;
        public boolean toupdatePaymentMethod;
        public boolean noErrorInDML;
        public boolean redirectPage;
        public String transactionId {get;set;}
        public boolean makePayment{get;set;}  
        public boolean successPayment{get;set;} 
        public boolean showSuccessMessage{get;set;} 
        public boolean encryptCardNumber{get;set;}  
        public string Phone2 {get;set;}
        public string Phone3 {get;set;}
        public string Zip{get;set;}
        public string CVV{get;set;}
        public boolean baseURL;
        public String pmId;
        public PageReference invoice_page{get;set;}        
        public boolean isDisplayed{get;set;} 
        public Map<String,String> entireHeader{get;set;}     
        public Map<String,String> allParametersFromURL;
        List<credicardtWrap> allCreditCardssWrap = new List<credicardtWrap>();
        Map<String,invoiceit_s__Payment_Method__c> allCreditcardsMap = new Map<String,invoiceit_s__Payment_Method__c>();
        public static boolean allcreditcardRerender{get;set;}
        public string methodtype{get;set;}
        public string accountName{get;set;}
        public string bankName{get;set;}
        public string bankRouting{get;set;}
        public string accountType{get;set;}
        public string accountNumber{get;set;}
        public string conid{get;set;}
        public string index{get;set;}
        public invoiceit_s__Gateway__c        paymentGateway;
        public account acc;
        public boolean isSMB{get;set;}
        public String domain{get;set;}
        public boolean isValidPage{get;set;}
        public String smbrowtoken {get;set;}
        public String smbtoken {get;set;}
        
       
           public MDL_PayNowController() {
            allcreditcardRerender = true;
            allParametersFromURL = ApexPages.currentPage().getParameters();
            System.debug('allParametersFromURL'+allParametersFromURL);
            System.debug('Second time call'+ApexPages.currentPage().getParameters().get('toValidate'));
            CSC_token__c csc_token = CSC_token__c.getValues('ExpectedToken');
            smbrowtoken = ApexPages.currentPage().getHeaders().get('SMB_Authorization');
            if(smbrowtoken!=null){
            smbtoken = smbrowtoken.remove('Bearer '); 
            }
            domain = ApexPages.currentPage().getHeaders().get('RefDomain'); 
            String actual_token = csc_token.Actual_Token__c;
            entireHeader=ApexPages.currentPage().getHeaders();
             
                   
        
            baseCSCURL = csc_token.Base_URL__c;
            formSubmitCSCURL = csc_token.Form_Submit_URL__c;
            formSMBSubmitURL = csc_token.SMB_Form_Submit__c;
            acc = new account();
            
            if(entireHeader.containsKey('RefDomain')){
                isSMB = true;
                formURL= formSMBSubmitURL;
            }
            else{
                isSMB = false;
                formURL= formSubmitCSCURL; 
            }
            
            if(ApexPages.currentPage().getParameters().get('toValidate')=='toValidate'){      
               isDisplayed = true;
               encryptCardNumber = false;
               redirectPage = false;
               isDefaultPaymentMethod = false;
            }  
            else{                  
                baseURL=((URL.getSalesforceBaseUrl().toExternalForm().contains('rainbow'))?true:false);           
                invId = ApexPages.currentPage().getParameters().get('Id');
                sessionId = ApexPages.currentPage().getParameters().get('sessionId');
                authorizeNpay = ApexPages.currentPage().getParameters().get('authorize-pay'); 
                encryptCardNumber = false;
                redirectPage = false;
                isDefaultPaymentMethod = false;
                entireHeader=ApexPages.currentPage().getHeaders();            
                token = ApexPages.currentPage().getHeaders().get('Authorization');
                //token = 'bWFydGluZGFsZXNhbGVzZm9yY2Vjc2NpbnZvaWNlcGF5bWVudGludGVncmF0aW9u';
                /*for(Account acc:[Select i.Id,i.name, i.BillingStreet, i.BillingState,i.Phone, i.BillingPostalCode, i.BillingCountry, i.BillingCity,i.Unpaid_amount__c,i.MH_Cust_Number__c
                              From Account i where i.id in (select  j.invoiceit_s__Account__c from invoiceit_s__Invoice__c j where j.id=:invId)]){
                        acctObj = acc;
                }*/                
                 for(invoiceit_s__Invoice__c inv : [SELECT invoiceit_s__Account__c, Name,invoiceit_s__Invoice_Date__c, invoiceit_s__Account__r.id,invoiceit_s__Total_Invoice_Value__c, invoiceit_s__Unpaid_Amount__c,invoiceit_s__Payment_Status__c,  
                              invoiceit_s__CurrencyL__c, invoiceit_s__CurrencyL__r.Name, invoiceit_s__CurrencyL__r.invoiceit_s__Currency_Symbol__c,invoiceit_s__Invoice_Reference__c, 
                              invoiceit_s__Account__r.invoiceit_s__Gateway__c, invoiceit_s__Account__r.invoiceit_s__VAT_No__c, invoiceit_s__Account__r.Name,invoiceit_s__Account__r.MH_Cust_Number__c, invoiceit_s__Account__r.BillingStreet, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingState , invoiceit_s__Account__r.BillingCountry, invoiceit_s__Account__r.BillingPostalCode,
                              invoiceit_s__Account__r.ShippingStreet, invoiceit_s__Account__r.ShippingCity, invoiceit_s__Account__r.ShippingCountry, invoiceit_s__Account__r.ShippingState,invoiceit_s__Account__r.ShippingPostalCode,
                              invoiceit_s__Billing_Contact__r.Name, invoiceit_s__Billing_Contact__r.MailingStreet, invoiceit_s__Billing_Contact__r.MailingCity, invoiceit_s__Billing_Contact__r.MailingState , invoiceit_s__Billing_Contact__r.MailingCountry, invoiceit_s__Billing_Contact__r.MailingPostalCode, invoiceit_s__Billing_Contact__r.Salutation,
                              invoiceit_s__Billing_Contact__r.FirstName, invoiceit_s__Billing_Contact__r.LastName,invoiceit_s__Order__r.Name,invoiceit_s__Invoice_Status__c, invoiceit_s__Payment_Request_Amount__c,invoiceit_s__Invoice_State__c,
                              invoiceit_s__Shipping_Contact__r.FirstName,invoiceit_s__Billing_Contact__r.Email, invoiceit_s__Shipping_Contact__r.LastName, invoiceit_s__Shipping_Contact__r.Account.Name, invoiceit_s__Shipping_Contact__r.MailingStreet,
                              invoiceit_s__Shipping_Contact__r.MailingCity, invoiceit_s__Shipping_Contact__r.MailingState, invoiceit_s__Shipping_Contact__r.MailingPostalCode, invoiceit_s__Shipping_Contact__r.MailingCountry,invoiceit_s__Shipping_Contact__r.Phone,
                              RecordType.DeveloperName, RecordTypeId
                              FROM invoiceit_s__Invoice__c
                              WHERE Id =:invId]){
                        invoiceObj = inv;   
                }
                          
                                         
              if(actual_token!=token){
                    isDisplayed = false;                
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You are not authorized to access this page. Please contact the admininstrator'));
                    return;
                }
                else 
                
                
                {                     
                    isDisplayed = true; 
                    if(invoiceObj!=null){             
                        Datetime myDatetime = invoiceObj.invoiceit_s__Invoice_Date__c;
                    }
                    if((ApexPages.currentPage().getParameters().get('payMethId'))!=null){
                        pmId = ApexPages.currentPage().getParameters().get('payMethId');
                        for(invoiceit_s__Payment_method__c pmet: [Select i.Id,i.invoiceit_s__Name_on_Card__c,i.invoiceit_s__Default__c,i.Auto_Pay__c,i.Autopay_Updated_Date__c,  i.invoiceit_s__Card_Type__c, i.invoiceit_s__Card_Number__c, 
                                                            i.invoiceit_s__Card_Expiration_Year__c, i.invoiceit_s__CVV__c, i.invoiceit_s__Card_Expiration_Month__c, i.invoiceit_s__Account__c,i.invoiceit_s__Billing_Fax__c,
                                                            i.invoiceit_s__Account__r.Name,i.invoiceit_s__Account__r.MH_Cust_Number__c,i.invoiceit_s__Billing_Phone__c,i.invoiceit_s__Billing_State_Province__c,i.invoiceit_s__Billing_Zip_Postal__c,i.invoiceit_s__Billing_Address__c,i.invoiceit_s__Billing_City__c,i.invoiceit_s__Billing_Company__c,
                                                            i.invoiceit_s__Billing_Country__c,i.invoiceit_s__Billing_Email__c,i.invoiceit_s__Billing_First_Name__c,i.invoiceit_s__Billing_Last_Name__c,i.invoiceit_s__Payment_Method__c,
                                                            i.invoiceit_s__Bank_Account_Name__c,i.invoiceit_s__Bank_Name__c,i.invoiceit_s__Bank_Routing_Code__c,i.invoiceit_s__Bank_Account_Type__c,i.invoiceit_s__Bank_Account_Number__c
                                                            From invoiceit_s__Payment_Method__c i 
                                                            where i.invoiceit_s__Active__c = True and i.invoiceit_s__Account__r.MH_Cust_Number__c =:invoiceObj.invoiceit_s__Account__r.MH_Cust_Number__c and Id=:pmId limit 1 ]){
                            paymentMethod = pmet;
                         }
                    }
                    else{
                        for(invoiceit_s__Payment_method__c pmet: [Select i.Id,i.invoiceit_s__Name_on_Card__c,i.invoiceit_s__Default__c, i.Autopay_Updated_Date__c,i.Auto_Pay__c, i.invoiceit_s__Card_Type__c, i.invoiceit_s__Card_Number__c, 
                                                                i.invoiceit_s__Card_Expiration_Year__c, i.invoiceit_s__CVV__c, i.invoiceit_s__Card_Expiration_Month__c, i.invoiceit_s__Account__c,i.invoiceit_s__Billing_Fax__c,
                                                                i.invoiceit_s__Account__r.Name,i.invoiceit_s__Account__r.MH_Cust_Number__c,i.invoiceit_s__Billing_Phone__c,i.invoiceit_s__Billing_State_Province__c,i.invoiceit_s__Billing_Zip_Postal__c,i.invoiceit_s__Billing_Address__c,i.invoiceit_s__Billing_City__c,i.invoiceit_s__Billing_Company__c,
                                                                i.invoiceit_s__Billing_Country__c,i.invoiceit_s__Billing_Email__c,i.invoiceit_s__Billing_First_Name__c,i.invoiceit_s__Billing_Last_Name__c,i.invoiceit_s__Active__c,i.invoiceit_s__Payment_Method__c,
                                                                i.invoiceit_s__Bank_Account_Name__c,i.invoiceit_s__Bank_Name__c,i.invoiceit_s__Bank_Routing_Code__c,i.invoiceit_s__Bank_Account_Type__c,i.invoiceit_s__Bank_Account_Number__c
                                                                From invoiceit_s__Payment_Method__c i 
                                                                where i.invoiceit_s__Active__c = True and i.invoiceit_s__Account__r.MH_Cust_Number__c =:invoiceObj.invoiceit_s__Account__r.MH_Cust_Number__c ]){
                               if(pmet.invoiceit_s__Active__c && pmet.invoiceit_s__Default__c && pmet.invoiceit_s__Payment_Method__c != 'ACH'){
                                 paymentMethod = pmet;
                             
                             }
                             
                             if(pmet.invoiceit_s__Default__c && pmet.invoiceit_s__Payment_Method__c != 'ACH'){
                                 allCreditCardssWrap.add(new credicardtWrap(true,pmet)); 
                             }
                                                                      
                             else{
                                 
                                 if(pmet.invoiceit_s__Payment_Method__c != 'ACH' ){
                                 //|| (pmet.invoiceit_s__Payment_Method__c == 'ACH' && pmet.invoiceit_s__Active__c && pmet.invoiceit_s__Default__c)){
                                     allCreditCardssWrap.add(new credicardtWrap(false,pmet));
                                 }
                                 
                             }
                                                                       

                             
                             allCreditcardsMap.put(pmet.Id,pmet);

                         }
                    }    
                     if(paymentMethod!=null){   
                        payMethID = paymentMethod.Id;             
                        if(paymentMethod.invoiceit_s__Billing_Address__c!=null){
                            CardBillingStreet=paymentMethod.invoiceit_s__Billing_Address__c;
                        }
                        if(paymentMethod.invoiceit_s__Billing_City__c!=null){
                            CardBillingCity=paymentMethod.invoiceit_s__Billing_City__c;
                        }
                        if(paymentMethod.invoiceit_s__Billing_Country__c!=null){
                            CardBillingCountry=paymentMethod.invoiceit_s__Billing_Country__c;
                        }
                        if(paymentMethod.invoiceit_s__Billing_State_Province__c!=null){
                            CardBillingState=paymentMethod.invoiceit_s__Billing_State_Province__c;
                        }
                        if (paymentMethod.invoiceit_s__Billing_Zip_Postal__c!=null && paymentMethod.invoiceit_s__Billing_Zip_Postal__c.contains('-')){
                            Zip=paymentMethod.invoiceit_s__Billing_Zip_Postal__c.split('-', 2)[0];                        
                        }
                        else{
                            Zip=paymentMethod.invoiceit_s__Billing_Zip_Postal__c;                          
                        }  
                        if(paymentMethod.invoiceit_s__Card_Number__c!=null){
                            encryptCardNumber = true;
                        }
                        if(paymentMethod.invoiceit_s__Name_on_Card__c!=null){
                            CardholderName=paymentMethod.invoiceit_s__Name_on_Card__c;
                            System.debug('CardholderName'+paymentMethod.invoiceit_s__Name_on_Card__c);
                        }
                        
                        if(paymentMethod.invoiceit_s__CVV__c!=null){
                            CVV=paymentMethod.invoiceit_s__CVV__c;
                            System.debug('CVV'+paymentMethod.invoiceit_s__CVV__c);
                        }
                        if(paymentMethod.invoiceit_s__Payment_Method__c!= null){
                          methodtype = paymentMethod.invoiceit_s__Payment_Method__c;
                        }
                     /*   if(paymentMethod.invoiceit_s__Bank_Account_Name__c!= null){
                           accountName = paymentMethod.invoiceit_s__Bank_Account_Name__c;
                        }
                        if(paymentMethod.invoiceit_s__Bank_Name__c!= null){
                           bankName = paymentMethod.invoiceit_s__Bank_Name__c;
                        }
                        if(paymentMethod.invoiceit_s__Bank_Routing_Code__c!= null){
                           bankRouting = paymentMethod.invoiceit_s__Bank_Routing_Code__c;
                        }
                        if(paymentMethod.invoiceit_s__Bank_Account_Type__c!= null){
                           accountType = paymentMethod.invoiceit_s__Bank_Account_Type__c;
                        } */
                        if(paymentMethod.invoiceit_s__Bank_Account_Number__c!= null){
                           accountNumber = paymentMethod.invoiceit_s__Bank_Account_Number__c;
                        }                             
                     }
                     if((ApexPages.currentPage().getParameters().get('payMethId'))!=null && (ApexPages.currentPage().getParameters().get('transactionId'))==null) {
                       payMethID = ApexPages.currentPage().getParameters().get('payMethId');
                       makePayment = true;
                       showSuccessMessage = true;  
                       System.debug(' payMethID ID From URL'+payMethID );         
                    }
                    System.debug(' Transaction ID From URL'+ApexPages.currentPage().getParameters().get('transactionId'));
                    if((ApexPages.currentPage().getParameters().get('payMethId'))!=null && (ApexPages.currentPage().getParameters().get('transactionId'))!=null){
                        payMethID = ApexPages.currentPage().getParameters().get('payMethId');
                        String tranID = ApexPages.currentPage().getParameters().get('transactionId');
                        String tranName = '';
                        for(invoiceit_s__Transaction__c tran : [select Name from invoiceit_s__Transaction__c where Id= :tranID]){
                            tranName = tran.Name;
                        }
                        successPayment = true;
                        if(tranName!=null)
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Your payment has been processed successfully. The transaction ID is '+tranName));                        
                    }            
                }
            }
        }
    
        //This is a wrapper class which contains a boolean flag and a associated contact, the flag is used to denote if the contact was selected
        public class credicardtWrap{
            public boolean isSelected {get;set;}
            public invoiceit_s__Payment_Method__c paymentMethod {get;set;}
            public String NameOnCard{get;set;}
            public credicardtWrap(boolean s,invoiceit_s__Payment_Method__c paymethod){
                isSelected = s;
                paymentMethod = paymethod;
                NameOnCard = paymethod.invoiceit_s__Name_on_Card__c;
            }
        }
    
        Public List<credicardtWrap> getAllCreditCards()
        {    
            system.debug('@@@in getAllCreditCards'+ allCreditCardssWrap);
            return allCreditCardssWrap;
        }
    
        public PageReference selectcon() {
         system.debug('@@@ in selectcon'); 
         String selcreditcardid = conid;                //Get the ID of the selected creditcard
            integer indexVal = integer.valueOf(index);  //Get the index (row number) of the selected creditcard
            paymentMethod = new invoiceit_s__Payment_Method__c();

            paymentMethod  = allCreditcardsMap.get(selcreditcardid);
             if(paymentMethod!=null){   
                        payMethID = paymentMethod.Id;             
                        if(paymentMethod.invoiceit_s__Billing_Address__c!=null){
                            CardBillingStreet=paymentMethod.invoiceit_s__Billing_Address__c;
                        }
                        if(paymentMethod.invoiceit_s__Billing_City__c!=null){
                            CardBillingCity=paymentMethod.invoiceit_s__Billing_City__c;
                        }
                        if(paymentMethod.invoiceit_s__Billing_Country__c!=null){
                            CardBillingCountry=paymentMethod.invoiceit_s__Billing_Country__c;
                        }
                        if(paymentMethod.invoiceit_s__Billing_State_Province__c!=null){
                            CardBillingState=paymentMethod.invoiceit_s__Billing_State_Province__c;
                        }
                        if (paymentMethod.invoiceit_s__Billing_Zip_Postal__c!=null && paymentMethod.invoiceit_s__Billing_Zip_Postal__c.contains('-')){
                            Zip=paymentMethod.invoiceit_s__Billing_Zip_Postal__c.split('-', 2)[0];                        
                        }
                        else{
                            Zip=paymentMethod.invoiceit_s__Billing_Zip_Postal__c;                          
                        }  
                        if(paymentMethod.invoiceit_s__Card_Number__c!=null){
                            encryptCardNumber = true;
                        }
                        if(paymentMethod.invoiceit_s__Name_on_Card__c!=null){
                            CardholderName=paymentMethod.invoiceit_s__Name_on_Card__c;
                            System.debug('CardholderName'+paymentMethod.invoiceit_s__Name_on_Card__c);
                        }
                      
                        if(paymentMethod.invoiceit_s__CVV__c!=null){
                            CVV=paymentMethod.invoiceit_s__CVV__c;
                            System.debug('CVV'+paymentMethod.invoiceit_s__CVV__c);
                        }
                        
                        if(paymentMethod.invoiceit_s__Payment_Method__c!= null){
                          methodtype = paymentMethod.invoiceit_s__Payment_Method__c;
                        }
                       /* if(paymentMethod.invoiceit_s__Bank_Account_Name__c!= null){
                           accountName = paymentMethod.invoiceit_s__Bank_Account_Name__c;
                        }
                        if(paymentMethod.invoiceit_s__Bank_Name__c!= null){
                           bankName = paymentMethod.invoiceit_s__Bank_Name__c;
                        }
                        if(paymentMethod.invoiceit_s__Bank_Routing_Code__c!= null){
                           bankRouting = paymentMethod.invoiceit_s__Bank_Routing_Code__c;
                        }
                        if(paymentMethod.invoiceit_s__Bank_Account_Type__c!= null){
                           accountType = paymentMethod.invoiceit_s__Bank_Account_Type__c;
                        } 
                        if(paymentMethod.invoiceit_s__Bank_Account_Number__c!= null){
                           accountNumber = paymentMethod.invoiceit_s__Bank_Account_Number__c;
                        }*/            
                     
                     }
            //selectcon =  new List<contact>();
            //selectcon.add(con);
            //Using the index, set the boolean flag on the wrapper class variable to TRUE, all other rows are set to FALSE
            for(integer i=0; i < allCreditCardssWrap.size(); i++)
                if(i == indexVal - 1)
                    allCreditCardssWrap[i].isSelected = true;
                else
                    allCreditCardssWrap[i].isSelected = false;
          
          
                 
         return null;
      }
    
    public void reset() {
         
          for(credicardtWrap cr : allCreditCardssWrap){
              cr.isSelected = false;
          }
          //isShwon = true;  
        //PageReference pg = new PageReference('/apex/mdl_paynowNew?id='+invId);
        //pg.setRedirect(true);
        //return null;
    }

        public PageReference getvalues(){
            System.debug('authorize/pay'+ ApexPages.currentPage().getParameters().get('authorize-pay'));
            if(ApexPages.currentPage().getParameters().get('toValidate')=='toValidate'){
                CardholderName = ApexPages.currentPage().getParameters().get('CardholderName');
                CardBillingStreet = ApexPages.currentPage().getParameters().get('CardBillingStreet');   
                CardBillingCity = ApexPages.currentPage().getParameters().get('CardBillingCity'); 
                CardBillingCountry = ApexPages.currentPage().getParameters().get('CardBillingCountry');
                CardBillingState = ApexPages.currentPage().getParameters().get('CardBillingState'); 
                /*Phone = ApexPages.currentPage().getParameters().get('Phone');
                Phone2 = ApexPages.currentPage().getParameters().get('Phone2'); 
                Phone3 = ApexPages.currentPage().getParameters().get('Phone3');*/ 
                CVV = ApexPages.currentPage().getParameters().get('CVV');
                Zip = ApexPages.currentPage().getParameters().get('Zip');
                invId = ApexPages.currentPage().getParameters().get('InvoiceId');
                authorizeNpay = ApexPages.currentPage().getParameters().get('authorize-pay'); 
                sessionId = ApexPages.currentPage().getParameters().get('sessionId'); 
                 
                /*for(Account acc:[Select i.Id,i.name, i.BillingStreet, i.BillingState,i.Phone, i.BillingPostalCode, i.BillingCountry, i.BillingCity,i.Unpaid_amount__c,i.MH_Cust_Number__c
                              From Account i where i.id in (select  j.invoiceit_s__Account__c from invoiceit_s__Invoice__c j where j.id=:invId)]){
                        acctObj = acc;  
                }*/
                 
                for(invoiceit_s__Invoice__c inv : [SELECT invoiceit_s__Account__c, Name,invoiceit_s__Invoice_Date__c, invoiceit_s__Account__r.id,invoiceit_s__Total_Invoice_Value__c, invoiceit_s__Unpaid_Amount__c,invoiceit_s__Payment_Status__c,  
                              invoiceit_s__CurrencyL__c, invoiceit_s__CurrencyL__r.Name, invoiceit_s__CurrencyL__r.invoiceit_s__Currency_Symbol__c,invoiceit_s__Invoice_Reference__c, invoiceit_s__Account__r.MH_Cust_Number__c,
                              invoiceit_s__Account__r.invoiceit_s__Gateway__c, invoiceit_s__Account__r.invoiceit_s__VAT_No__c, invoiceit_s__Account__r.Name, invoiceit_s__Account__r.BillingStreet, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingState , invoiceit_s__Account__r.BillingCountry, invoiceit_s__Account__r.BillingPostalCode,
                              invoiceit_s__Account__r.ShippingStreet, invoiceit_s__Account__r.ShippingCity, invoiceit_s__Account__r.ShippingCountry, invoiceit_s__Account__r.ShippingState,invoiceit_s__Account__r.ShippingPostalCode,
                              invoiceit_s__Billing_Contact__r.Name, invoiceit_s__Billing_Contact__r.MailingStreet, invoiceit_s__Billing_Contact__r.MailingCity, invoiceit_s__Billing_Contact__r.MailingState , invoiceit_s__Billing_Contact__r.MailingCountry, invoiceit_s__Billing_Contact__r.MailingPostalCode, invoiceit_s__Billing_Contact__r.Salutation,
                              invoiceit_s__Billing_Contact__r.FirstName, invoiceit_s__Billing_Contact__r.LastName,invoiceit_s__Order__r.Name,invoiceit_s__Invoice_Status__c, invoiceit_s__Payment_Request_Amount__c,invoiceit_s__Invoice_State__c,
                              invoiceit_s__Shipping_Contact__r.FirstName,invoiceit_s__Billing_Contact__r.Email, invoiceit_s__Shipping_Contact__r.LastName, invoiceit_s__Shipping_Contact__r.Account.Name, invoiceit_s__Shipping_Contact__r.MailingStreet,
                              invoiceit_s__Shipping_Contact__r.MailingCity, invoiceit_s__Shipping_Contact__r.MailingState, invoiceit_s__Shipping_Contact__r.MailingPostalCode, invoiceit_s__Shipping_Contact__r.MailingCountry,invoiceit_s__Shipping_Contact__r.Phone,
                              RecordType.DeveloperName, RecordTypeId
                              FROM invoiceit_s__Invoice__c
                              WHERE Id =:invId]){
                        invoiceObj = inv;               
                }
                //execute if 'Confirm Payment' has been clicked            
                System.debug('Valueeeeeeee' + ApexPages.currentPage().getParameters().get('authorize-pay'));
                System.debug('Payment Method ID From URL'+ApexPages.currentPage().getParameters().get('payMethId'));
                if(ApexPages.currentPage().getParameters().get('authorize-pay') == '1'){
                    if(ApexPages.currentPage().getParameters().get('payMethId')!=null){                        
                        payMethID = ApexPages.currentPage().getParameters().get('payMethID');                        
                        for(invoiceit_s__Payment_Method__c pmet : [Select i.Id,i.invoiceit_s__Name_on_Card__c,i.Auto_Pay__c,i.Autopay_Updated_Date__c,i.invoiceit_s__Default__c, i.invoiceit_s__Card_Type__c, i.invoiceit_s__Card_Number__c, 
                                                            i.invoiceit_s__Card_Expiration_Year__c, i.invoiceit_s__CVV__c, i.invoiceit_s__Card_Expiration_Month__c, i.invoiceit_s__Account__c,i.invoiceit_s__Billing_Fax__c,
                                                            i.invoiceit_s__Account__r.Name,i.invoiceit_s__Account__r.MH_Cust_Number__c,i.invoiceit_s__Billing_Phone__c,i.invoiceit_s__Billing_State_Province__c,i.invoiceit_s__Billing_Zip_Postal__c,i.invoiceit_s__Billing_Address__c,i.invoiceit_s__Billing_City__c,i.invoiceit_s__Billing_Company__c,
                                                            i.invoiceit_s__Billing_Country__c,i.invoiceit_s__Billing_Email__c,i.invoiceit_s__Billing_First_Name__c,i.invoiceit_s__Billing_Last_Name__c,i.invoiceit_s__Payment_Method__c
                                                            From invoiceit_s__Payment_Method__c i where Id=:payMethID]){
                              paymentMethod = pmet;
                        }
                        userIdFromHeader = obtainUserId();
                        //invoke method to make the payment
                        makepayment();
                        if(redirectPage == true){ 
                            sessionId = ApexPages.currentPage().getParameters().get('sessionId');                    
                            PageReference confirmPayPage = new PageReference(formURL+'/success/'+sessionId+'/'+invoiceObj.id+'/'+paymentMethod.Id+'/'+transactionId);
                            confirmPayPage.setredirect(true);
                            return confirmPayPage;
                        }
                    }
                }
                //execute if 'Continue' has been clicked
                else if(ApexPages.currentPage().getParameters().get('authorize-pay') == '0'){
                    system.debug('@@@@allcreditcardRerender in 0'+allcreditcardRerender );
                    allcreditcardRerender = false;
                    sessionId = ApexPages.currentPage().getParameters().get('sessionId');
                    payMethID = ApexPages.currentPage().getParameters().get('payMethID');
                    system.debug('@@@paymethid in continue'+payMethID );
                    for(invoiceit_s__Payment_Method__c pmet:[Select i.Id,i.invoiceit_s__Name_on_Card__c,i.invoiceit_s__Default__c, i.invoiceit_s__Card_Type__c, i.invoiceit_s__Card_Number__c, 
                                                            i.invoiceit_s__Card_Expiration_Year__c, i.invoiceit_s__CVV__c, i.invoiceit_s__Card_Expiration_Month__c, i.invoiceit_s__Account__c,i.invoiceit_s__Billing_Fax__c,
                                                            i.invoiceit_s__Account__r.Name,i.invoiceit_s__Account__r.MH_Cust_Number__c,i.invoiceit_s__Billing_Phone__c,i.invoiceit_s__Billing_State_Province__c,i.invoiceit_s__Billing_Zip_Postal__c,i.invoiceit_s__Billing_Address__c,i.invoiceit_s__Billing_City__c,i.invoiceit_s__Billing_Company__c,
                                                            i.invoiceit_s__Billing_Country__c,i.invoiceit_s__Billing_Email__c,i.invoiceit_s__Billing_First_Name__c,i.invoiceit_s__Billing_Last_Name__c,i.invoiceit_s__Payment_Method__c
                                                            From invoiceit_s__Payment_Method__c i where 
                                                            i.Id=:payMethID]){
                                                            //i.invoiceit_s__Default__c=true and i.invoiceit_s__Account__r.Name=:invoiceObj.invoiceit_s__Account__r.Name limit 1 ]){
                                paymentMethod = pmet;
                    }
                    
                    for(invoiceit_s__Payment_Method__c pmet:[Select i.Id,i.invoiceit_s__Name_on_Card__c,i.invoiceit_s__Default__c, i.invoiceit_s__Card_Type__c, i.invoiceit_s__Card_Number__c, 
                                                            i.invoiceit_s__Card_Expiration_Year__c, i.invoiceit_s__CVV__c, i.invoiceit_s__Card_Expiration_Month__c, i.invoiceit_s__Account__c,i.invoiceit_s__Billing_Fax__c,
                                                            i.invoiceit_s__Account__r.Name,i.invoiceit_s__Account__r.MH_Cust_Number__c,i.invoiceit_s__Billing_Phone__c,i.invoiceit_s__Billing_State_Province__c,i.invoiceit_s__Billing_Zip_Postal__c,i.invoiceit_s__Billing_Address__c,i.invoiceit_s__Billing_City__c,i.invoiceit_s__Billing_Company__c,
                                                            i.invoiceit_s__Billing_Country__c,i.invoiceit_s__Billing_Email__c,i.invoiceit_s__Billing_First_Name__c,i.invoiceit_s__Billing_Last_Name__c,i.invoiceit_s__Payment_Method__c
                                                            From invoiceit_s__Payment_Method__c i where 
                                                            //i.Id=:payMethID]){
                                                            i.invoiceit_s__Default__c=true and i.invoiceit_s__Account__r.MH_Cust_Number__c =:invoiceObj.invoiceit_s__Account__r.MH_Cust_Number__c limit 1 ]){
                                paymentMethodold= pmet;
                    }
                    system.debug('@@@ payment method in continue'+paymentMethod  );
                    if(paymentMethod!=null){
                        isDefaultPaymentMethod = true;
                        //if((paymentMethod.invoiceit_s__Card_Type__c!=ApexPages.currentPage().getParameters().get('CardType')) || (paymentMethod.invoiceit_s__Card_Number__c!=ApexPages.currentPage().getParameters().get('ActualCardNumber')) || 
                        //        (paymentMethod.invoiceit_s__Card_Expiration_Month__c!=ApexPages.currentPage().getParameters().get('CardExpirationMonth')) || (paymentMethod.invoiceit_s__Card_Expiration_Year__c!=ApexPages.currentPage().getParameters().get('CardExpirationYear'))){
                            //paymentMethodold = paymentMethod;
                            //createNewPaymentmethod();
                            
                            String isChecked = ApexPages.currentPage().getParameters().get('defaultCard'); 
                            system.debug('@@@ isChecked'+ isChecked );
                            if(isChecked=='on'){
                                //paymentMethod.Rank__c = '1';
                                paymentMethod.Auto_Pay__c = true;
                                paymentMethod.Autopay_Updated_Date__c= system.today();
                                
                               // system.debug('@@@ Default'+ paymentMethodold.invoiceit_s__Default__c);
                                system.debug('@@@ Default'+ paymentMethod.invoiceit_s__Default__c);
                                
                                //added this check when no credit card available as default
                                if(paymentMethodold != null){
                                    paymentMethodold.Auto_Pay__c = false;
                                    paymentMethod.Autopay_Updated_Date__c= system.today();
                                    paymentMethodold.Rank__c = '';
                                }
                                
                                toupdate = true;
                            }
                            else{
                                paymentMethod.Auto_Pay__c= false;
                                paymentMethod.Autopay_Updated_Date__c= system.today();
                                toupdate = true;
                            }               
                            //toinsert = true;
                       // }
                     //  else{
                            paymentMethod.invoiceit_s__Name_on_Card__c = CardholderName;
                            paymentMethod.invoiceit_s__Billing_Address__c = CardBillingStreet;   
                            paymentMethod.invoiceit_s__Billing_City__c = CardBillingCity; 
                            paymentMethod.invoiceit_s__Billing_Country__c = CardBillingCountry;
                            paymentMethod.invoiceit_s__Billing_State_Province__c = CardBillingState; 
                            paymentMethod.invoiceit_s__Billing_Zip_Postal__c = Zip;
                           // toupdatePaymentMethod = true;
                      //  }
                    }
                    else if(paymentMethod==null){
                        createNewPaymentmethod();
                        String isChecked = ApexPages.currentPage().getParameters().get('defaultCard'); 
                        if(isChecked=='on'){
                            List<invoiceit_s__Payment_Method__c> paymtmethod = new List<invoiceit_s__Payment_Method__c>();
                
                                paymtmethod = [SELECT invoiceit_s__Name_on_Card__c,Auto_Pay__c,Autopay_Updated_Date__c,
                                              invoiceit_s__Card_Type__c, invoiceit_s__Billing_Address__c,
                                              invoiceit_s__Card_Number__c, invoiceit_s__Billing_City__c,
                                              invoiceit_s__Card_Expiration_Month__c, invoiceit_s__Card_Expiration_Year__c,
                                              invoiceit_s__Billing_Country__c, invoiceit_s__Billing_State_Province__c,
                                              invoiceit_s__Billing_Zip_Postal__c,
                                              invoiceit_s__Default__c, invoiceit_s__Account__c,
                                              invoiceit_s__Payment_Method__c
                                              from invoiceit_s__Payment_Method__c
                                              where  Auto_Pay__c = TRUE]   ;
                                
                              if ( paymtmethod.size()>0){
                                
                                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Default payment method already exists'));
                              
                               }
                               
                               else{
                               
                                    paymentMethod.Rank__c = '1';
                                    paymentMethod.Auto_Pay__c= true;
                                    paymentMethod.Autopay_Updated_Date__c= system.today();
                            
                            
                               }
                        }
                        else{
                           paymentMethod.Auto_Pay__c= false;
                           paymentMethod.Autopay_Updated_Date__c= system.today();
                        }  
                        toinsert = true;
                    }
                    //invoke method to check if all the values have been entered by the user in the form
                    validateValues();
                    if(ApexPages.hasMessages(ApexPages.Severity.Error)){
                        if(isDefaultPaymentMethod == true){
                            encryptCardNumber = true;
                        }
                        return null;                       
                    }                                            
                    //invoke method for authorization from 'Authorize.net'                   
                    /*String authResponse = authorizationRequest(invoiceObj.invoiceit_s__Unpaid_Amount__c);
                    if(authResponse.contains('Error')){
                        System.debug('authResponse'+authResponse);
                        if(isDefaultPaymentMethod == true){
                            encryptCardNumber = true;
                        }
                        if(authResponse.split('@').size()>1){                                       
                            String errMessage = authResponse.split('@')[1];
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errMessage));
                        }
                        else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occured during Authorization'));
                        }
                        return null;                        
                    }
                    else if(authResponse=='successful'){ */
                        //process the payment method and account if the payment method has been authorized                             
                        ValidateandSave(); 
                        if(paymentMethod.Id!=null && noErrorInDML == true){                          
                           sessionId = ApexPages.currentPage().getParameters().get('sessionId');
                            /*domain    = ApexPages.currentPage().getParameters().get('RefDomain');
                            //if(ApexPages.currentPage().getHeaders().get('RefDomain') != null){
                            //PageReference payPage = null;
                            //string contiueURL = '';
                            if(domain != null){
                                formURL = 'https://invoice.portal.qa-nolo.com';
                                //formURL = formSMBSubmitURL;
                                //contiueURL = formSMBSubmitURL+'/authorize/'+sessionId+'/'+invoiceObj.id+'/'+paymentMethod.Id;
                            }  
                              
                           else if(domain == null) {
                                formURL = 'https://invoice.stg1.lawyers.com';
                            } 
                             */
                            //}
                             
            
                           PageReference payPage = new PageReference(formURL+'/authorize/'+sessionId+'/'+invoiceObj.id+'/'+paymentMethod.Id);
                           //PageReference payPage = new PageReference(contiueURL);
                           //payPage = new PageReference(contiueURL);
                           payPage.setredirect(true);
                           return payPage;
                        }
                    //}                    
                }
            }  
            return null;
        }       
        public PageReference createNewPaymentmethod(){
            paymentMethod = new invoiceit_s__Payment_Method__c();
            paymentMethod.invoiceit_s__Card_Type__c = ApexPages.currentPage().getParameters().get('CardType');  
            paymentMethod.invoiceit_s__Card_Number__c = ApexPages.currentPage().getParameters().get('ActualCardNumber');  
            paymentMethod.invoiceit_s__Card_Expiration_Month__c = ApexPages.currentPage().getParameters().get('CardExpirationMonth');  
            paymentMethod.invoiceit_s__Card_Expiration_Year__c = ApexPages.currentPage().getParameters().get('CardExpirationYear');  
            paymentMethod.invoiceit_s__Name_on_Card__c=CardholderName;
            paymentMethod.invoiceit_s__Billing_Address__c = CardBillingStreet;   
            paymentMethod.invoiceit_s__Billing_City__c = CardBillingCity; 
            paymentMethod.invoiceit_s__Billing_Country__c = CardBillingCountry;
            paymentMethod.invoiceit_s__Billing_State_Province__c = CardBillingState; 
            paymentMethod.invoiceit_s__Billing_Zip_Postal__c = Zip;
             paymentMethod.invoiceit_s__CVV__c= CVV;
            if(invoiceObj.invoiceit_s__Account__c!=null)            
                paymentMethod.invoiceit_s__Account__c = invoiceObj.invoiceit_s__Account__c;
            paymentMethod.invoiceit_s__Active__c=true;
            return null;
        }
        public pageReference validateValues(){
            if(paymentMethod.invoiceit_s__Card_Number__c==null ||string.isBlank(paymentMethod.invoiceit_s__Card_Number__c))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Number'));            
            if(paymentMethod.invoiceit_s__Card_Expiration_Month__c=='--None--'||string.isBlank(paymentMethod.invoiceit_s__Card_Expiration_Month__c))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Expiration Month'));
            if(paymentMethod.invoiceit_s__Card_Expiration_Year__c=='--None--' ||string.isBlank(paymentMethod.invoiceit_s__Card_Expiration_Year__c))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Expiration Year'));
            if(paymentMethod.invoiceit_s__Card_Type__c=='--None--' ||string.isBlank(paymentMethod.invoiceit_s__Card_Type__c))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Type'));
            if(CardholderName==null ||string.isBlank(CardholderName))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Holder Name'));
            if(CardBillingStreet==null ||string.isBlank(CardBillingStreet))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Street Address'));
            if(CardBillingCity==null ||string.isBlank(CardBillingCity))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide city'));
            if(CardBillingCountry==null ||string.isBlank(CardBillingCountry))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide country'));
            if(CardBillingState==null ||string.isBlank(CardBillingState))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide state'));
            if(Zip==null ||string.isBlank(Zip))
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide postal code'));
            if(CVV==null ||string.isBlank(CVV) )
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide CVV'));
            //if(phone==null || string.isBlank(phone) && phone2==null || string.isBlank(phone2)&& phone3==null || string.isBlank(phone3))
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Phone number'));
            return null;
        }        
                          
        public PageReference ValidateandSave(){                       
            /*if(acctObj!=null){
                acctObj.BillingStreet=CardBillingStreet;
                acctObj.BillingCity=CardBillingCity;
                acctObj.BillingCountry=CardBillingCountry;
                acctObj.BillingState=CardBillingState;  
                acctObj.BillingPostalCode=Zip;
            }                     
            if (phone!=null || phone=='' && phone2!=null || phone2!='' && phone3!=null || phone3!=''){
                 acctObj.Phone= '('+phone+')'+phone2+''+phone3; 
            }*/       
            try{
                //if(acctObj!=null)
                    //upsert acctObj;
                if(toUpdate==true){
                    if(paymentMethodold != null){
                        update paymentMethodold;
                    }
                    
                    update paymentMethod;
                    String isChecked = ApexPages.currentPage().getParameters().get('defaultCard'); 
                    system.debug('@@@ isChecked'+ isChecked );
                    //to update account payment default payment method
                    account acc;
                    if(isChecked=='on'){
                        acc = new account (id=paymentMethod.invoiceit_s__Account__c, invoiceit_s__Payment_Method__c=paymentMethod.id);
                    }
                    else{
                        acc = new account (id=paymentMethod.invoiceit_s__Account__c, invoiceit_s__Payment_Method__c=null);
                    }
                    
                    //update acc;
                    
                }
                if(toinsert==true){
                    insert paymentMethod;                   
                }
                if(toupdatePaymentMethod==true){
                    update paymentMethod;          
                }
                noErrorInDML = true;
            }       
            catch(DmlException ex){
                noErrorInDML = false;
                ApexPages.addMessages(ex);
            }
            isDisplayed = true;
            return null;    
        } 
        public String obtainUserId(){
            String IdFromHeader = '';
            try{
                String userId = ApexPages.currentPage().getHeaders().get('uid');
                System.debug('UID----'+userId);                        
                String endPointForUserId = baseCSCURL+'/GetUserID.ashx?'+userId;                
                Http http = new Http(); 
                HttpRequest req = new HttpRequest(); 
                req.setEndpoint(endPointForUserId);
                req.setMethod('GET');
                req.setTimeout(20000);
                HTTPResponse res = http.send(req);
                System.debug('Response Body : '+res.getBody());
                if(res.getStatusCode()==200)
                    IdFromHeader = res.getBody();
            }catch(System.CalloutException ce) {
                Apexpages.Message am=new Apexpages.Message(ApexPages.Severity.Info, 'Problem with web service operation. Failed to make a callout to an external system.');
                Apexpages.addMessage(am);  
                successPayment = false;
                redirectPage = false;
            }
            return IdFromHeader;
        }
        public PageReference makepayment(){
        
             string gatewayName = '';
                system.debug('@@@invoiceObj '+ invoiceObj );
            if(invoiceObj.RecordType.DeveloperName.contains('Nolo')){
                gatewayName = label.Nolo_Payment_Gateway;
            }
            else{
                gatewayName = label.MDL_Payment_GateWay;
            } 
            
             system.debug('@@@gatewayName '+gatewayName  );
            paymentGateway = [select id, Name,
                                     invoiceit_s__Active__c,
                                     invoiceit_s__Default__c,
                                     invoiceit_s__Email_Customer__c,
                                     invoiceit_s__Exact_ID__c,
                                     invoiceit_s__Exact_ID_Security_Key__c,
                                     invoiceit_s__Gateway_Type__c,
                                     invoiceit_s__Merchant_ID__c,
                                     invoiceit_s__Merchant_Seal_User_Id__c,
                                     invoiceit_s__Merchant_Reference__c,
                                     invoiceit_s__Security_Key__c,
                                     invoiceit_s__Test_Mode__c,
                                     invoiceit_s__Transaction_Security_Key__c
                                     From invoiceit_s__Gateway__c
                                     where Name =: gatewayName ];
                                     
               acc = [select id, Name,
                             invoiceit_s__Gateway__c,MH_Cust_Number__c
                             from account 
                             where id =: invoiceObj.invoiceit_s__Account__c];    
            System.debug('invoiceObj '+invoiceObj );
            System.debug('paymentMethod'+paymentMethod);
            System.debug('paymentMethod.Id'+paymentMethod.Id);
            System.debug('paymentMethod.invoiceit_s__Default__c'+paymentMethod.invoiceit_s__Default__c);
            system.debug('@@@@@paymentGateway in makepayment'+ paymentGateway);
             system.debug('@@@@@paymentGateway in invoiceObj'+ invoiceObj);
             
            system.debug('@@@@@paymentGateway in acc'+ acc);
            String sResponseMessage = '';
            double amount           = invoiceObj.invoiceit_s__Unpaid_Amount__c;
            invoiceit_s__Payment__c paymentToUpdate;
            //account acc;
            if(paymentMethod!=null && invoiceObj!=null){
                paymentMethod.invoiceit_s__Card_Number__c = paymentMethod.invoiceit_s__Card_Number__c;
                paymentMethod.invoiceit_s__CVV__c = paymentMethod.invoiceit_s__CVV__c;
                if(!Test.isRunningTest()){  
                    invoiceit_s.PaymentSiteOperation siteClass = new invoiceit_s.PaymentSiteOperation();
                    sResponseMessage = siteClass.processPayment(paymentGateway,invoiceObj, paymentMethod, paymentMethod.id,amount,acc,false,null  );            
                    //sResponseMessage = siteClass.processPayment(invoiceObj ,paymentMethod,paymentMethod.Id,null,null,false);
                }
                System.debug('Payment Method ::'+sResponseMessage);
            }
            if((sResponseMessage.contains('Error')) || (sResponseMessage.contains('Declined'))){
                if(paymentMethod.invoiceit_s__Default__c==true){
                    encryptCardNumber = true;
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,sResponseMessage));
                successPayment = false;
            }
            else{                                 
                for(invoiceit_s__Transaction__c transactionCreated : [select Id,Name,invoiceit_s__Is_Payment_Processed_Successfully__c,invoiceit_s__Exception_Message__c from invoiceit_s__Transaction__c where invoiceit_s__Request_Invoice__c=:invoiceObj.Id and invoiceit_s__Payment_Method__c=:paymentMethod.Id order by LastModifiedDate desc limit 1]){
                    if(transactionCreated.invoiceit_s__Is_Payment_Processed_Successfully__c==true){
                        transactionId = transactionCreated.Id;
                        redirectPage = true;                                              
                    }
                    else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,sResponseMessage+transactionCreated.invoiceit_s__Exception_Message__c));
                        successPayment = false;
                        redirectPage = false;
                    }
                } 
                if(redirectPage = true){
                   try{                        
                        User createdUser = [Select Id from User where Name like '%Customer%Portal%Site%Guest%User%' LIMIT 1];
                        system.debug('@@@createdUser '+createdUser );
                        for(invoiceit_s__Payment__c payment : [select Id,User_ID__c from invoiceit_s__Payment__c where CreatedById=:createdUser.Id order by LastModifiedDate desc limit 1]){
                            
                            system.debug('@@@in payment payment'+ payment );
                            paymentToUpdate = payment;
                            
                            system.debug('@@@@@invoiceObj'+ invoiceObj);
                            //paymentToUpdate.invoiceit_s__Transaction__c  = transactionId;
                                if(invoiceObj!= null){
                                   system.debug('@@@ in if invoiceObj'+ invoiceObj);
                                    paymentToUpdate.Invoice__c   = invoiceObj.id;
                                }
                            
                            
                            System.debug('<><><>'+userIdFromHeader);                                                   
                            if(userIdFromHeader!=null && userIdFromHeader!='')
                                paymentToUpdate.User_ID__c = userIdFromHeader;                            
                        }
                        if(paymentToUpdate!=null){
                            system.debug('@@@@paymentToUpdate'+paymentToUpdate);
                            update paymentToUpdate;
                        }
                                                 
                    }                   
                    catch(Exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, e.getMessage()));
                        successPayment = false;
                        redirectPage = false;
                    } 
                }                           
               
            }  
            return null;             
        }
        /*public String authorizationRequest(Decimal unpaidAmount){
            String cardNumber = ApexPages.currentPage().getParameters().get('ActualCardNumber');
            String expirationMonth = ApexPages.currentPage().getParameters().get('CardExpirationMonth'); 
            String expirationYear = ApexPages.currentPage().getParameters().get('CardExpirationYear');
            CSC_Authentication_EndPoint__c cscauth = CSC_Authentication_EndPoint__c.getValues('IB EndPoint');
            String endPoint = cscauth.Endpoint_URL__c;
            String methodType = cscauth.Method_Type__c;
            String responseXML = '';
            String response = '';
            String responseAfterParse = '';
            Boolean isStatusCode200;
            String reqXML = MDL_PayNowController.constructXML_authRequest(cardNumber,expirationMonth,expirationYear,unpaidAmount);
            try{
                Http http = new Http(); 
                HttpRequest req = new HttpRequest(); 
                req.setEndpoint(endPoint);
                req.setMethod(methodType);
                req.setTimeout(20000);
                req.setBody(reqXML); 
                req.setHeader('Content-Type', 'text/xml');
                HTTPResponse res = http.send(req);
                responseXML = res.getBody();
                if(res.getStatusCode() == 200){
                    isStatusCode200 = true;
                }               
                System.debug('Response Body : '+res.getBody()); 
            }catch(System.CalloutException ce) {
                Apexpages.Message am=new Apexpages.Message(ApexPages.Severity.Info, 'Problem with web service operation. Failed to make a callout to an external system.');
                Apexpages.addMessage(am);   
            }
            catch(System.Exception e) {
                Apexpages.Message am=new Apexpages.Message(ApexPages.Severity.Info, 'Some Exception occurred , please try again after sometime.'+e.getMessage());
                Apexpages.addMessage(am);
            }
            if(isStatusCode200 == true){
                responseAfterParse = MDL_PayNowController.parseResponseXML(responseXML);
            }           
            return responseAfterParse;
        }
        public static String constructXML_authRequest(String cardNumber,String expirationMonth,String expirationYear,Decimal unpaidAmount){
            String requestXMLString = '';
            CSC_Authentication_EndPoint__c cscauth = CSC_Authentication_EndPoint__c.getValues('IB EndPoint');
            String transactionID = cscauth.Transaction_ID__c;
            String apiLogin = cscauth.API_login__c;
            String transactionType = cscauth.Transaction_Type__c;
            String xmlns = cscauth.xmlns__c;
            
            Xmlstreamwriter xmlW = new Xmlstreamwriter();
            
            xmlW.writeStartElement(null,'createTransactionRequest', null); 
            xmlW.writeAttribute(null,null,'xmlns',xmlns);
            
                xmlW.writeStartElement(null,'merchantAuthentication',null);
                    xmlW.writeStartElement(null,'name',null);
                        xmlw.writeCharacters(apiLogin);
                    xmlW.writeEndElement();
                    xmlW.writeStartElement(null,'transactionKey',null);
                        xmlW.writeCharacters(transactionID);
                    xmlW.writeEndElement();
                xmlW.writeEndElement(); 
            
                xmlW.writeStartElement(null,'transactionRequest',null);
                    xmlW.writeStartElement(null,'transactionType',null);
                        xmlw.writeCharacters(transactionType);
                    xmlW.writeEndElement();
                    
                    if(unpaidAmount!=null){
                        xmlW.writeStartElement(null,'amount',null);
                            xmlw.writeCharacters(String.valueOf(unpaidAmount));
                        xmlW.writeEndElement();
                    }                   
                    else{
                        xmlW.writeEmptyElement(null,'amount',null);
                    }
                    xmlW.writeStartElement(null,'payment',null);
                        xmlW.writeStartElement(null,'creditCard',null);
                            if(cardNumber!=null){
                                xmlW.writeStartElement(null,'cardNumber',null);
                                    xmlw.writeCharacters(cardNumber);
                                xmlW.writeEndElement();
                            }
                            else{
                                xmlW.writeEmptyElement(null,'cardNumber',null);
                            }
                            if(expirationMonth!=null && expirationYear!=null){
                                String expirationDate = expirationMonth + expirationYear.substring(2,expirationYear.length());
                                xmlW.writeStartElement(null,'expirationDate',null);
                                    xmlw.writeCharacters(expirationDate);
                                xmlW.writeEndElement();
                            }
                            else{
                                xmlW.writeEmptyElement(null,'expirationDate',null);
                            }
                        xmlW.writeEndElement();
                    xmlW.writeEndElement();
                    
                xmlW.writeEndElement();
                
            xmlW.writeEndElement();
            
            requestXMLString = xmlW.getXmlString();
            System.debug('Authentication Request :'+requestXMLString);
                
            return requestXMLString;            
        } 
        public static String parseResponseXML(String responseXML){
            String returnMessage = '';
            String result = '';
            String errorText = '';
            System.debug('responseXML'+responseXML);
            try{                
                Dom.Document response = new Dom.Document();
                response.load(responseXML);
                dom.Xmlnode res = response.getRootElement();
                
                for(dom.XmlNode resChild : res.getChildElements()) {
                    if(resChild.getName() == 'messages'){
                        for(dom.XmlNode resGrandChild : resChild.getChildElements()) {
                            if(resGrandChild.getName() == 'resultCode') {
                                result = resGrandChild.getText();
                            }
                        }
                    }
                }
                System.debug('result'+result);
                if(result=='Ok'){
                    if(responseXML.contains('transactionResponse')){
                        for(dom.XmlNode resChild : res.getChildElements()) {
                            System.debug('res.getChildElements()'+resChild);
                            if(resChild.getName() == 'transactionResponse'){
                                for(dom.XmlNode resGrandChild : resChild.getChildElements()) {                              
                                    if(resGrandChild.getName() == 'errors') {
                                        for(dom.XmlNode resGrandGrandChild : resGrandChild.getChildElements()){
                                            if(resGrandGrandChild.getName() == 'error'){
                                                for(dom.XmlNode resGrandGrandGrandChild : resGrandGrandChild.getChildElements()){
                                                    if(resGrandGrandGrandChild.getName() == 'errorText'){
                                                        errorText = resGrandGrandGrandChild.getText();
                                                    }
                                                }
                                            }
                                        }                   
                                    }
                                }
                            }
                        }
                    }
                    //errorText='';
                    if(errorText == '' || errorText==null){
                        returnMessage = 'successful';
                    }
                    else{
                        returnMessage = 'Error @' + errorText;
                    }                    
                    return returnMessage;                   
                }
                else if(result=='Error'){
                    if(responseXML.contains('transactionResponse')){
                        for(dom.XmlNode resChild : res.getChildElements()) {
                            System.debug('res.getChildElements()'+resChild);
                            if(resChild.getName() == 'transactionResponse'){
                                if(resChild.getChildElements().size()==0){
                                    for(dom.XmlNode responseChild : res.getChildElements()) {
                                        if(responseChild.getName() == 'messages'){
                                            for(dom.XmlNode resGrandChild : responseChild.getChildElements()) {
                                                if(resGrandChild.getName() == 'message') {
                                                    for(dom.XmlNode resGrandGrandChild : resGrandChild.getChildElements()){
                                                        if(resGrandGrandChild.getName() == 'text'){
                                                            errorText = resGrandGrandChild.getText();
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else{
                                    for(dom.XmlNode resGrandChild : resChild.getChildElements()) {                              
                                        if(resGrandChild.getName() == 'errors') {
                                            for(dom.XmlNode resGrandGrandChild : resGrandChild.getChildElements()){
                                                if(resGrandGrandChild.getName() == 'error'){
                                                    for(dom.XmlNode resGrandGrandGrandChild : resGrandGrandChild.getChildElements()){
                                                        if(resGrandGrandGrandChild.getName() == 'errorText'){
                                                            errorText = resGrandGrandGrandChild.getText();
                                                        }
                                                    }
                                                }
                                            }                   
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else if(!(responseXML.contains('transactionResponse'))){
                        for(dom.XmlNode resChild : res.getChildElements()) {
                            if(resChild.getName() == 'messages'){
                                for(dom.XmlNode resGrandChild : resChild.getChildElements()) {
                                    if(resGrandChild.getName() == 'message') {
                                        for(dom.XmlNode resGrandGrandChild : resGrandChild.getChildElements()){
                                            if(resGrandGrandChild.getName() == 'text'){
                                                errorText = resGrandGrandChild.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    returnMessage = 'Error @' + errorText;
                    return returnMessage;                           
                }               
            }
            catch(System.Exception e) {
                apexpages.Message am=new apexpages.Message(ApexPages.Severity.Info, 'Issue in parsing :'+e.getMessage());
                apexpages.addMessage(am);
            }
            return null;
        }    */      
 }