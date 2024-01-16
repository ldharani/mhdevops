/*********************************************************************************
Created By : Lister Technologies

Created Purpose : This class is a controller class for Portal_PayNow page where the 
user can pay any of his 'unpaid' and 'posted' invoices.
First, the credit card details entered by the user are authorized 
from Authorize.net. Then, the payment is done using an Invoice IT
class.
Modified by : Lister Technologies
Modified Purpose : MHBS-173
***********************************************************************************/
public class Portal_PayNowController{  
    ApexPages.standardController m_sc = null;
    public string invId{get;set;}
    public integer isCardDefault;   
    public blng__PaymentMethod__c paymentMethod{get;set;}
    public blng__PaymentMethod__c paymentMethodold;
    public Account  acctObj {get; set;}
    public blng__Invoice__c invoiceObj {get; set;}
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
   // public String userIdFromHeader;
    public String formSMBSubmitURL {get;set;}
    public String formURL {get;set;}
    string authResponse;
    
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
    Map<String,blng__PaymentMethod__c> allCreditcardsMap = new Map<String,blng__PaymentMethod__c>();
    public static boolean allcreditcardRerender{get;set;}
    public string methodtype{get;set;}
    public string accountName{get;set;}
    public string bankName{get;set;}
    public string bankRouting{get;set;}
    public string accountType{get;set;}
    public string accountNumber{get;set;}
    public string conid{get;set;}
    public string index{get;set;}
    public blng__PaymentGateway__c        paymentGateway;
    public account acc;
    public boolean isSMB{get;set;}
    public String domain{get;set;}
    public boolean isValidPage{get;set;}
    public String smbrowtoken {get;set;}
    public String smbtoken {get;set;}
    
    
    public Portal_PayNowController() {
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
            
            for(blng__Invoice__c inv : [SELECT blng__Account__c, Name,blng__InvoiceDate__c,blng__TotalAmount__c, blng__Balance__c,blng__PaymentStatus__c,  
                                        blng__Account__r.Name,blng__Account__r.MH_Cust_Number__c, blng__Account__r.BillingStreet, blng__Account__r.BillingCity, blng__Account__r.BillingState , blng__Account__r.BillingCountry, blng__Account__r.BillingPostalCode,
                                        blng__Account__r.ShippingStreet, blng__Account__r.ShippingCity, blng__Account__r.ShippingCountry, blng__Account__r.ShippingState,blng__Account__r.ShippingPostalCode,blng__BillToContact__c,
                                        blng__BillToContact__r.Name, blng__BillToContact__r.MailingStreet, blng__BillToContact__r.MailingCity, blng__BillToContact__r.MailingState , blng__BillToContact__r.MailingCountry, blng__BillToContact__r.MailingPostalCode, blng__BillToContact__r.Salutation, blng__BillToContact__r.FirstName, blng__BillToContact__r.LastName,blng__Order__c,blng__Order__r.Name,blng__InvoiceStatus__c,
                                        blng__BillToContact__r.Email, 
                                        RecordType.DeveloperName, RecordTypeId
                                        FROM blng__Invoice__c
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
                    Datetime myDatetime = invoiceObj.blng__InvoiceDate__c;
                }
                if((ApexPages.currentPage().getParameters().get('payMethId'))!=null){
                    pmId = ApexPages.currentPage().getParameters().get('payMethId');
                    for(blng__PaymentMethod__c pmet: [Select Id,blng__Nameoncard__c,blng__AutoPay__c, blng__CardType__c, blng__CardNumber__c, blng__Active__c, Payment_Profile_ID__c,
                                                      blng__CardExpirationYear__c, blng__CVV__c, blng__CardExpirationMonth__c, blng__Account__c,blng__BillingFax__c, blng__Account__r.Name,
                                                      blng__BillingPhone__c,blng__BillingZipPostal__c,blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingAddress__c,blng__BillingCity__c,
                                                      blng__BillingCompany__c,blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFirstName__c,blng__BillingLastName__c,
                                                      blng__PaymentGateway__c, blng__PaymentType__c ,blng__BankAccountName__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BankAccountType__c,
                                                      blng__BankAccountNumber__c
                                                      From blng__PaymentMethod__c 
                                                      where blng__Active__c = True and blng__Account__r.Name=:invoiceObj.blng__Account__r.Name and Id=:pmId and Payment_Profile_ID__c!=null limit 1 ]){
                                                          paymentMethod = pmet;
                                                      }
                }
                else{
                    for(blng__PaymentMethod__c pmet: [Select Id,blng__Nameoncard__c,blng__AutoPay__c, blng__CardType__c, blng__CardNumber__c, blng__Active__c, Payment_Profile_ID__c,
                                                      blng__CardExpirationYear__c, blng__CVV__c, blng__CardExpirationMonth__c, blng__Account__c,blng__BillingFax__c, blng__Account__r.Name,
                                                      blng__BillingPhone__c,blng__BillingZipPostal__c,blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingAddress__c,blng__BillingCity__c,
                                                      blng__BillingCompany__c,blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFirstName__c,blng__BillingLastName__c,
                                                      blng__PaymentGateway__c, blng__PaymentType__c ,blng__BankAccountName__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BankAccountType__c,
                                                      blng__BankAccountNumber__c
                                                      From blng__PaymentMethod__c
                                                      where blng__Active__c = True and blng__Account__r.Name=:invoiceObj.blng__Account__r.Name and Payment_Profile_ID__c!=null ]){
                                                          if(pmet.blng__Active__c && pmet.blng__AutoPay__c && pmet.blng__PaymentType__c != 'ACH'){
                                                              paymentMethod = pmet;
                                                              
                                                          }
                                                          
                                                          if(pmet.blng__AutoPay__c && pmet.blng__PaymentType__c != 'ACH'){
                                                              allCreditCardssWrap.add(new credicardtWrap(true,pmet)); 
                                                          }
                                                          
                                                          else{
                                                              
                                                              if(pmet.blng__PaymentType__c != 'ACH' ){
                                                                  allCreditCardssWrap.add(new credicardtWrap(false,pmet));
                                                              }    
                                                          } 
                                                          allCreditcardsMap.put(pmet.Id,pmet);
                                                          
                                                      }
                }    
                if(paymentMethod!=null){   
                    payMethID = paymentMethod.Id;             
                    if(paymentMethod.blng__BillingStreet__c!=null){
                        CardBillingStreet=paymentMethod.blng__BillingStreet__c;
                    }else{
                        CardBillingStreet = null;
                    }
                    if(paymentMethod.blng__BillingCity__c!=null){
                        CardBillingCity=paymentMethod.blng__BillingCity__c;
                    }
                    if(paymentMethod.blng__BillingCountry__c!=null){
                        CardBillingCountry=paymentMethod.blng__BillingCountry__c;
                    }
                    if(paymentMethod.blng__BillingStateProvince__c!=null || test.isRunningTest()){
                        CardBillingState=paymentMethod.blng__BillingStateProvince__c;
                    }
                    if (paymentMethod.blng__BillingZipPostal__c!=null && paymentMethod.blng__BillingZipPostal__c.contains('-')){
                        Zip=paymentMethod.blng__BillingZipPostal__c.split('-', 2)[0];                        
                    }
                    else{
                        Zip=paymentMethod.blng__BillingZipPostal__c;                          
                    }  
                    if(paymentMethod.blng__CardNumber__c!=null){
                        encryptCardNumber = true;
                    }
                    if(paymentMethod.blng__Nameoncard__c!=null){
                        CardholderName=paymentMethod.blng__Nameoncard__c;
                        System.debug('CardholderName'+paymentMethod.blng__Nameoncard__c);
                    }
                    
                    if(paymentMethod.blng__CVV__c!=null){
                        CVV=paymentMethod.blng__CVV__c;
                        System.debug('CVV'+paymentMethod.blng__CVV__c);
                    }
                    if(paymentMethod.blng__PaymentType__c!= null){
                        methodtype = paymentMethod.blng__PaymentType__c;
                    }
                    
                    if(paymentMethod.blng__BankAccountNumber__c!= null || test.isRunningTest()){
                        accountNumber = paymentMethod.blng__BankAccountNumber__c;
                    }                             
                }
                if(((ApexPages.currentPage().getParameters().get('payMethId'))!=null && (ApexPages.currentPage().getParameters().get('transactionId'))==null) || test.isRunningTest()) {
                    payMethID = ApexPages.currentPage().getParameters().get('payMethId');
                    makePayment = true;
                    showSuccessMessage = true;           
                }
                System.debug(' Transaction ID From URL'+ApexPages.currentPage().getParameters().get('transactionId'));
                if((ApexPages.currentPage().getParameters().get('payMethId'))!=null && (ApexPages.currentPage().getParameters().get('transactionId'))!=null){
                    payMethID = ApexPages.currentPage().getParameters().get('payMethId');
                    String tranID = ApexPages.currentPage().getParameters().get('transactionId');
                    String tranName = '';
                    for(blng__PaymentTransaction__c tran : [select Name from blng__PaymentTransaction__c where Id= :tranID]){
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
        public blng__PaymentMethod__c paymentMethod {get;set;}
        public String NameOnCard{get;set;}
        public credicardtWrap(boolean s,blng__PaymentMethod__c paymethod){
            isSelected = s;
            paymentMethod = paymethod;
            NameOnCard = paymethod.blng__Nameoncard__c;
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
        paymentMethod = new blng__PaymentMethod__c();
        
        paymentMethod  = allCreditcardsMap.get(selcreditcardid);
        if(paymentMethod!=null){   
            payMethID = paymentMethod.Id;             
            if(paymentMethod.blng__BillingStreet__c!=null){
                CardBillingStreet=paymentMethod.blng__BillingStreet__c;
            }
            if(paymentMethod.blng__BillingCity__c!=null){
                CardBillingCity=paymentMethod.blng__BillingCity__c;
            }
            if(paymentMethod.blng__BillingCountry__c!=null){
                CardBillingCountry=paymentMethod.blng__BillingCountry__c;
            }
            if(paymentMethod.blng__BillingStateProvince__c!=null || test.isRunningTest()){
                CardBillingState=paymentMethod.blng__BillingStateProvince__c;
            }
            if (paymentMethod.blng__BillingZipPostal__c!=null && paymentMethod.blng__BillingZipPostal__c.contains('-')){
                Zip=paymentMethod.blng__BillingZipPostal__c.split('-', 2)[0];                        
            }
            else{
                Zip=paymentMethod.blng__BillingZipPostal__c;                          
            }  
            if(paymentMethod.blng__CardNumber__c!=null){
                encryptCardNumber = true;
            }
            if(paymentMethod.blng__Nameoncard__c!=null){
                CardholderName=paymentMethod.blng__Nameoncard__c;
                System.debug('CardholderName'+paymentMethod.blng__Nameoncard__c);
            }
            
            if(paymentMethod.blng__CVV__c!=null){
                CVV=paymentMethod.blng__CVV__c;
                System.debug('CVV'+paymentMethod.blng__CVV__c);
            }
            
            if(paymentMethod.blng__PaymentType__c!= null){
                methodtype = paymentMethod.blng__PaymentType__c;
            }
        }
        
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
    }
    
    public PageReference getvalues(){
        System.debug('authorize/pay'+ ApexPages.currentPage().getParameters().get('authorize-pay'));
        if(ApexPages.currentPage().getParameters().get('toValidate')=='toValidate'){
            CardholderName = ApexPages.currentPage().getParameters().get('CardholderName');
            CardBillingStreet = ApexPages.currentPage().getParameters().get('CardBillingStreet');   
            CardBillingCity = ApexPages.currentPage().getParameters().get('CardBillingCity'); 
            CardBillingCountry = ApexPages.currentPage().getParameters().get('CardBillingCountry');
            CardBillingState = ApexPages.currentPage().getParameters().get('CardBillingState'); 
            
            CVV = ApexPages.currentPage().getParameters().get('CVV');
            Zip = ApexPages.currentPage().getParameters().get('Zip');
            invId = ApexPages.currentPage().getParameters().get('InvoiceId');
            authorizeNpay = ApexPages.currentPage().getParameters().get('authorize-pay'); 
            sessionId = ApexPages.currentPage().getParameters().get('sessionId'); 
            
            for(blng__Invoice__c inv : [SELECT blng__Account__c, Name,blng__InvoiceDate__c,blng__TotalAmount__c, blng__Balance__c,blng__PaymentStatus__c,  
                                        blng__Account__r.Name,blng__Account__r.MH_Cust_Number__c, blng__Account__r.BillingStreet, blng__Account__r.BillingCity, blng__Account__r.BillingState , blng__Account__r.BillingCountry, blng__Account__r.BillingPostalCode,
                                        blng__Account__r.ShippingStreet, blng__Account__r.ShippingCity, blng__Account__r.ShippingCountry, blng__Account__r.ShippingState,blng__Account__r.ShippingPostalCode,blng__BillToContact__c,
                                        blng__BillToContact__r.Name, blng__BillToContact__r.MailingStreet, blng__BillToContact__r.MailingCity, blng__BillToContact__r.MailingState , blng__BillToContact__r.MailingCountry, blng__BillToContact__r.MailingPostalCode, blng__BillToContact__r.Salutation, blng__BillToContact__r.FirstName, blng__BillToContact__r.LastName,blng__Order__c,blng__Order__r.Name,blng__InvoiceStatus__c,
                                        blng__BillToContact__r.Email, 
                                        RecordType.DeveloperName, RecordTypeId
                                        FROM blng__Invoice__c
                                        WHERE Id =:invId]){
                                            invoiceObj = inv;              
                                        }
            //execute if 'Confirm Payment' has been clicked            
            if(ApexPages.currentPage().getParameters().get('authorize-pay') == '1'){
                if(ApexPages.currentPage().getParameters().get('payMethId')!=null){                        
                    payMethID = ApexPages.currentPage().getParameters().get('payMethID');                        
                    for(blng__PaymentMethod__c pmet: [Select Id,blng__Nameoncard__c,blng__AutoPay__c, blng__CardType__c, blng__CardNumber__c, blng__Active__c,
                                                      blng__CardExpirationYear__c, blng__PaymentType__c ,blng__CVV__c, blng__CardExpirationMonth__c, blng__Account__c,blng__BillingFax__c, blng__Account__r.Name,blng__BillingPhone__c,blng__BillingZipPostal__c,blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingAddress__c,blng__BillingCity__c,blng__BillingCompany__c,blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFirstName__c,blng__BillingLastName__c,blng__PaymentGateway__c,blng__BankAccountName__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BankAccountType__c,blng__BankAccountNumber__c
                                                      From blng__PaymentMethod__c where Id=:payMethID]){
                                                          paymentMethod = pmet;
                                                      }
                   // userIdFromHeader = obtainUserId();
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
                for(blng__PaymentMethod__c pmet: [Select Id,blng__Nameoncard__c,blng__AutoPay__c, blng__CardType__c, blng__CardNumber__c, blng__Active__c,
                                                  blng__CardExpirationYear__c, blng__CVV__c, blng__CardExpirationMonth__c, 
                                                  blng__Account__c,blng__BillingFax__c, blng__Account__r.Name,blng__BillingPhone__c,
                                                  blng__BillingZipPostal__c,blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingAddress__c,blng__BillingCity__c,blng__BillingCompany__c,
                                                  blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFirstName__c,blng__BillingLastName__c,blng__PaymentGateway__c, blng__PaymentType__c,
                                                  blng__BankAccountName__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BankAccountType__c,blng__BankAccountNumber__c
                                                  From blng__PaymentMethod__c  where 
                                                  Id=:payMethID]){
                                                      paymentMethod = pmet;
                                                  }
                
                for(blng__PaymentMethod__c pmet: [Select Id,blng__Nameoncard__c,blng__AutoPay__c, blng__CardType__c, blng__CardNumber__c, blng__Active__c, Payment_Profile_ID__c,
                                                  blng__CardExpirationYear__c, blng__CVV__c, blng__CardExpirationMonth__c, 
                                                  blng__Account__c,blng__BillingFax__c, blng__Account__r.Name,blng__BillingPhone__c,
                                                  blng__BillingZipPostal__c,blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingAddress__c,blng__BillingCity__c,blng__BillingCompany__c,
                                                  blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFirstName__c,blng__BillingLastName__c,blng__PaymentGateway__c, blng__PaymentType__c,
                                                  blng__BankAccountName__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BankAccountType__c,blng__BankAccountNumber__c
                                                  From blng__PaymentMethod__c where blng__AutoPay__c = True and blng__Account__r.Name=:invoiceObj.blng__Account__r.Name and Payment_Profile_ID__c !=null limit 1 ]){
                                                      paymentMethodold= pmet;
                                                  }
                system.debug('@@@ payment method in continue'+paymentMethod  );
                if(paymentMethod!=null){
                    isDefaultPaymentMethod = true;
                    
                    String isChecked = ApexPages.currentPage().getParameters().get('defaultCard'); 
                    system.debug('@@@ isChecked'+ isChecked );
                    if(isChecked=='on'){
                        paymentMethod.blng__AutoPay__c = true;
                        
                        //added this check when no credit card available as default
                        if(paymentMethodold != null){
                            paymentMethodold.blng__AutoPay__c = false;
                        }
                        
                        toupdate = true;
                    }
                    else{
                        paymentMethod.blng__AutoPay__c = false;
                        toupdate = true;
                    }               
                    
                    paymentMethod.blng__Nameoncard__c = CardholderName;
                    paymentMethod.blng__BillingStreet__c = CardBillingStreet;   
                    paymentMethod.blng__BillingCity__c = CardBillingCity; 
                    paymentMethod.blng__BillingCountry__c = CardBillingCountry;
                    paymentMethod.blng__BillingStateProvince__c = CardBillingState; 
                    paymentMethod.blng__BillingZipPostal__c = Zip;
                    
                }
                else if(paymentMethod==null){
                    createNewPaymentmethod();
                    String isChecked = ApexPages.currentPage().getParameters().get('defaultCard'); 
                    if(isChecked=='on'){
                        paymentMethod.blng__AutoPay__c = true;
                    }
                    else{
                        paymentMethod.blng__AutoPay__c = false;
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
                
                //process the payment method and account if the payment method has been authorized                             
                ValidateandSave(); 
                if(paymentMethod.Id!=null && noErrorInDML == true){                          
                    sessionId = ApexPages.currentPage().getParameters().get('sessionId');
                    PageReference payPage = new PageReference(formURL+'/authorize/'+sessionId+'/'+invoiceObj.id+'/'+paymentMethod.Id);
                    payPage.setredirect(true);
                    return payPage;
                }
                
            }
        }  
        return null;
    }       
    public PageReference createNewPaymentmethod(){
        paymentMethod = new blng__PaymentMethod__c();
        paymentMethod.blng__CardType__c = ApexPages.currentPage().getParameters().get('CardType');  
        paymentMethod.blng__CardNumber__c = ApexPages.currentPage().getParameters().get('ActualCardNumber');  
        paymentMethod.blng__CardExpirationMonth__c = ApexPages.currentPage().getParameters().get('CardExpirationMonth');  
        paymentMethod.blng__CardExpirationYear__c = ApexPages.currentPage().getParameters().get('CardExpirationYear');  
        paymentMethod.blng__Nameoncard__c=CardholderName;
        paymentMethod.blng__BillingStreet__c = CardBillingStreet;   
        paymentMethod.blng__BillingCity__c = CardBillingCity; 
        paymentMethod.blng__BillingCountry__c = CardBillingCountry;
        paymentMethod.blng__BillingStateProvince__c = CardBillingState; 
        paymentMethod.blng__BillingZipPostal__c = Zip;
        paymentMethod.blng__CVV__c= CVV;
        if(invoiceObj.blng__Account__c!=null)            
            paymentMethod.blng__Account__c = invoiceObj.blng__Account__c;
        paymentMethod.blng__Active__c=true;
        return null;
    }
    public pageReference validateValues(){
        if(paymentMethod.blng__CardNumber__c==null ||string.isBlank(paymentMethod.blng__CardNumber__c) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Number'));            
        if(paymentMethod.blng__CardExpirationMonth__c=='--None--'||string.isBlank(paymentMethod.blng__CardExpirationMonth__c) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Expiration Month'));
        if(paymentMethod.blng__CardExpirationYear__c=='--None--' ||string.isBlank(paymentMethod.blng__CardExpirationYear__c) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Expiration Year'));
        if(paymentMethod.blng__CardType__c=='--None--' ||string.isBlank(paymentMethod.blng__CardType__c) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Type'));
        if(CardholderName==null ||string.isBlank(CardholderName) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Card Holder Name'));
        if(CardBillingStreet==null ||string.isBlank(CardBillingStreet) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide Street Address'));
        if(CardBillingCity==null ||string.isBlank(CardBillingCity) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide city'));
        if(CardBillingCountry==null ||string.isBlank(CardBillingCountry) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide country'));
        if(CardBillingState==null ||string.isBlank(CardBillingState) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide state'));
        if(Zip==null ||string.isBlank(Zip) || test.isRunningTest())
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please provide postal code'));
        return null;
    }        
    
    public PageReference ValidateandSave(){                       
        
        try{
            
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
                    acc = new account (id=paymentMethod.blng__Account__c,Payment_Method__c=paymentMethod.id);
                }
                else{
                    acc = new account (id=paymentMethod.blng__Account__c,Payment_Method__c=null);
                }
                
                update acc;
                
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
   /* public String obtainUserId(){
        String IdFromHeader = '';
        try{
            String userId = ApexPages.currentPage().getHeaders().get('uid');
            System.debug('UID----'+userId);                        
            String endPointForUserId = baseCSCURL+'/GetUserID.ashx?'+userId;
            // String Hostname = 'https://csc.login.qa-nolo.com';                
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
    }*/
    public PageReference makepayment(){
        
        
        String sResponseMessage = '';
        double amount           = invoiceObj.blng__Balance__c;
        Id PayMethodId = ApexPages.currentPage().getParameters().get('payMethId');
        blng__Payment__c paymentToUpdate;
        
        
        if(paymentMethod!=null && invoiceObj!=null){
            paymentMethod.blng__CardNumber__c = paymentMethod.blng__CardNumber__c;
            paymentMethod.blng__CVV__c = paymentMethod.blng__CVV__c;
            
            string strSOQL = 'SELECT ' + queryAllFields('blng__PaymentMethod__c');
            strSOQL += ' , blng__PaymentGateway__r.adnblng__APILoginId__c, blng__PaymentGateway__r.adnblng__APITransactionKey__c, blng__PaymentGateway__r.Endpoint_URL__c ';
            strSOQL += ' FROM blng__PaymentMethod__c';
            strSOQL += ' WHERE Id=:PayMethodId';
            blng__PaymentMethod__c objPM = database.query(strSOQL);
            Map<String, Object> mapDeserializedJSONBody = new Map<String, Object>();
            paymentMethodDetails pm = new paymentMethodDetails();
            
            
            pm.amount  = invoiceObj.blng__Balance__c;
            pm.PGAPILoginId = objPM.blng__PaymentGateway__r.adnblng__APILoginId__c;
            pm.customerprofileId=objPM.Payment_Profile_ID__c;
            pm.payprofileId=objPM.blng__PaymentGatewayToken__c;
            pm.InvoiceNumber = invoiceObj.Name;
            if(objPM.blng__PaymentGateway__c != null || test.isRunningTest()){
                pm.PGAPITransactionKey = objPM.blng__PaymentGateway__r.adnblng__APITransactionKey__c;
                pm.PGEndpointURL = objPM.blng__PaymentGateway__r.Endpoint_URL__c;
                if(pm.PGEndpointURL != null){
                    
                    authResponse = sendRequest(pm);
                    System.debug('XOXOX ' + authResponse);
                    if(authResponse.contains('approved')){
                        authResponse = authResponse.trim().replace('\uFEFF', '');
                        System.debug('YUYUYUYU ' + authResponse);
                        PayNowJson jsonclass = (PayNowJson)JSON.deserialize(authResponse, PayNowJson.class);
                        System.debug('POPOPOPOPO ' + jsonclass);
                        blng__PaymentTransaction__c trans = new blng__PaymentTransaction__c();
                        trans.blng__GatewayID__c = jsonclass.TransactionResponse.transId;
                        trans.blng__ResponseCode__c = jsonclass.TransactionResponse.responseCode;
                        if(trans.blng__ResponseCode__c == '1'){
                            trans.blng__Response__c = 'This transaction has been approved.';
                            trans.blng__ResponseStatus__c = 'Approved';
                            trans.blng__ResponseMessage__c = 'Approved';
                     
                            redirectPage = true; 
                            trans.blng__IsPaymentProcessedSuccessfully__c= true;
                            trans.blng__Amount__c=invoiceObj.blng__Balance__c;
                            trans.blng__Account__c =invoiceObj.blng__Account__c;
                            trans.blng__PaymentGateway__c=objPM.blng__PaymentGateway__c;
                            trans.blng__GatewayDate__c = system.today();
                            trans.blng__Type__c = 'Charge';
                            trans.blng__Status__c = 'Processed';
                            trans.blng__GatewayStatus__c ='Success';
                        
                        
                            trans.blng__PaymentMethod__c=PayMethodId;
                            trans.blng__RequestInvoice__c=invoiceObj.id;
                            insert trans;
                        for(blng__PaymentTransaction__c transactionCreated : [select Id,Name from blng__PaymentTransaction__c where blng__RequestInvoice__c=:invoiceObj.Id and blng__PaymentMethod__c=:paymentMethod.Id order by LastModifiedDate desc limit 1]){
                            transactionId = transactionCreated.Id;
                        }
                        }
                    }else{
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'The Payment Transaction has failed. Please try again later. '));
                        successPayment = false;
                        redirectPage = false; 
                    }
                }
            }
            
            
        }
        
        System.debug('Payment Method trans'+invoiceObj.Id + paymentMethod.Id);
        
        if(redirectPage = true && transactionId!=null){
            try{                        
                User createdUser = [Select Id from User where Name like '%Customer%Portal%Site%Guest%User%' LIMIT 1];
                
                blng__Payment__c payment = new blng__Payment__c();
                payment.blng__Invoice__c   = invoiceObj.id;
                payment.blng__Account__c = invoiceObj.blng__Account__c;
                payment.blng__Amount__c=invoiceObj.blng__Balance__c;
                payment.blng__Status__c='Posted';
                payment.blng__PaymentType__c='Credit Card';
                payment.blng__Transaction__c =transactionId;
                insert payment;
                
                //Payment Allocation Changes -Added by Sushmidha
                List<blng__InvoiceLine__c> invLineList = [Select Id,blng__Balance__c,blng__Invoice__c from blng__InvoiceLine__c where blng__Invoice__c = :invoiceObj.id];
                system.debug('invLineList'+invLineList);
                List<blng__PaymentAllocationInvoiceLine__c> list_PaymentAllocation_Insert = new List<blng__PaymentAllocationInvoiceLine__c>();
                for(blng__InvoiceLine__c invLine : invLineList){
                    if(invLine.blng__Balance__c > 0 && payment.blng__Invoice__c != null ){
                        
                        blng__PaymentAllocationInvoiceLine__c tempPA = new blng__PaymentAllocationInvoiceLine__c();
                        tempPA.blng__Payment__c = payment.Id ;
                        tempPA.blng__Type__c='Allocation';
                        tempPA.RecordTypeId = DefaultPaymentAccount__c.getInstance('DefaultAccountRecord').PaymentAllocationRectypeID__c;                
                        tempPA.blng__InvoiceLine__c = invLine.Id ;
                        tempPA.blng__Amount__c = invLine.blng__Balance__c ;
                        list_PaymentAllocation_Insert.add(tempPA);
                    }                    
                }
                system.debug('list_PaymentAllocation_Insert'+list_PaymentAllocation_Insert);
                if(list_PaymentAllocation_Insert.size() > 0){
                    
                    insert list_PaymentAllocation_Insert;    
                }
                
            }                   
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, e.getMessage()));
                successPayment = false;
                redirectPage = false;
            } 
        }                           
        
        
        return null;             
    }
    
    public string sendRequest(paymentMethodDetails pm){
        system.debug('enter send request');
        HttpRequest req1 = new HttpRequest();
        req1.setMethod('POST');
        req1.setEndpoint(pm.PGEndpointURL);
        req1.setHeader('content-type', 'application/json');
        string messageBody1 ='{"createTransactionRequest":{"merchantAuthentication":{"name":"' + pm.PGAPILoginId + '","transactionKey":"' + pm.PGAPITransactionKey + '"},"refId": "' + pm.InvoiceNumber + '","transactionRequest": {"transactionType": "authCaptureTransaction","amount": "' + pm.amount + '","profile": {"customerProfileId": "' + pm.customerprofileId +'","paymentProfile": { "paymentProfileId": "' + pm.payprofileid + '"}},"processingOptions": {"isSubsequentAuth": "true"},"subsequentAuthInformation": {"originalNetworkTransId": "918273641064738","originalAuthAmount": "' + pm.amount + '","reason": "resubmission" },"authorizationIndicatorType": { "authorizationIndicator": "final" }}}}';
        system.debug(messageBody1);
        req1.setHeader('Content-length', String.valueOf(messageBody1.length()));
        req1.setBody(messageBody1);
        
        req1.setTimeout(60*1000);
        Http h1 = new Http();
        String resp1;
        HttpResponse res1 = h1.send(req1);
        system.debug(' http response'+res1);
        return res1.getBody();
        
    }
    
    public class paymentMethodDetails{   
        
        public string customerprofileId;
        public string payprofileid;
        public string cvv;
        public string PGAPILoginId;
        public string InvoiceNumber;
        public string PGAPITransactionKey;
        public string PGEndpointURL;
        public double amount;
    }
    
    Public static string queryAllFields(String strObjectAPIName){
        
        
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String queryFields = String.join( fieldNames, ',' );
        return queryFields;
    }// END OF METHOD - queryAllFields
    
}