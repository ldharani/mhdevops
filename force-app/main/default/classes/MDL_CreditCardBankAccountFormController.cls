public class MDL_CreditCardBankAccountFormController {
    
    public string selectedValue {get;set;} 
    public id accid{get;set;}
    public id idinv{get;set;}
    public boolean formPanel{get;set;}
    public boolean successPanel{get;set;}
    public boolean Vaidationcheck{get;set;}
    public string checkcreditorbank{get;set;}
    public string tempCreditCardNumber{get;set;}
    public string tempCreditCardCVV{get;set;}
    public string  customerno{get;set;}
    public String sessionId {get;set;}
    public String domain{get;set;}
    public boolean isSMB{get;set;}
    public Map<String,String> entireHeader {get; set;} 
    public invoiceit_s__Payment_Method__c invpaymnt{get;set;}
    
    public String smbrowtoken {get;set;}
    public String smbtoken {get;set;}
       
    public MDL_CreditCardBankAccountFormController(ApexPages.StandardController controller) {
        Vaidationcheck = false;
        domain = ApexPages.currentPage().getHeaders().get('RefDomain'); 
       
        system.debug('@@@ in bank controller');
        idinv = ApexPages.currentPage().getParameters().get('id');
        customerno = ApexPages.currentPage().getParameters().get('c');
        checkcreditorbank = ApexPages.currentPage().getParameters().get('check');
        sessionId = ApexPages.currentPage().getParameters().get('sessionId');
        entireHeader = ApexPages.currentPage().getHeaders();
        smbrowtoken = ApexPages.currentPage().getHeaders().get('SMB_Authorization');
         if(smbrowtoken!=null){
            smbtoken = smbrowtoken.remove('Bearer '); 
        }
        
        system.debug('@@@sessionid'+ sessionId);
        system.debug('@@@customernumber'+ customerno);
        
        if(entireHeader.containsKey('RefDomain')){
            isSMB = true;
        }
        else{
            isSMB = false;
        }
        
        if(customerno != null){
            accid = [select id, name 
                           from account
                            where MH_Cust_Number__c =:customerno].id;
        }
        system.debug('@@@checkcreditorbank' + checkcreditorbank);
        system.debug('@@@@id'+idinv);
        system.debug('@@@accid'+ accid);
        if(idinv !=null){
            //this.invpaymnt = (invoiceit_s__Payment_Method__c )controller.getRecord();
            this.invpaymnt = [select id, invoiceit_s__Name_on_Card__c,Auto_Pay__c,Autopay_Updated_Date__c,
                              invoiceit_s__Card_Type__c, invoiceit_s__Billing_Address__c,
                              invoiceit_s__Card_Number__c, invoiceit_s__Billing_City__c,
                              invoiceit_s__Card_Expiration_Month__c, invoiceit_s__Card_Expiration_Year__c,
                              invoiceit_s__Billing_Country__c, invoiceit_s__Billing_State_Province__c,
                              invoiceit_s__Billing_Zip_Postal__c,
                              invoiceit_s__Default__c, invoiceit_s__Bank_Account_Name__c,
                              invoiceit_s__Bank_Name__c, invoiceit_s__Bank_Routing_Code__c,
                              invoiceit_s__Bank_Account_Type__c,
                              invoiceit_s__CVV__c,
                              invoiceit_s__Bank_Account_Number__c,
                              invoiceit_s__Payment_Method__c
                              from invoiceit_s__Payment_Method__c
                              where id = :idinv ];
            
            tempCreditCardNumber = invpaymnt.invoiceit_s__Card_Number__c;
            tempCreditCardCVV = invpaymnt.invoiceit_s__CVV__c;
            if(invpaymnt.Auto_Pay__c != null){
                if(invpaymnt.Auto_Pay__c){
                    selectedValue = 'Yes';
                    
                }
                else{
                    selectedValue = 'No';
                }
            }
            
        }
        else{
            invpaymnt = new invoiceit_s__Payment_Method__c();
            selectedValue ='No';
        }
        
        formPanel = true;     
    }
    
    public PageReference save() {
        Vaidationcheck = false;
        try{
            system.debug('@@@invpaymnt in save'+ invpaymnt);
            if(selectedValue == 'Yes'){
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
                              where invoiceit_s__Account__c = :accid AND Auto_Pay__c = TRUE ]   ;
                
              if ( paymtmethod.size()>0){
                
                  Vaidationcheck= True;
                  //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Default payment method already exists'));
              
               }
               
               else{ 
                    invpaymnt.Auto_Pay__c= true;
                    invpaymnt.Autopay_Updated_Date__c = system.today();
                }
            
            } else if (selectedValue == 'No'){
                invpaymnt.Auto_Pay__c= false;
                invpaymnt.Autopay_Updated_Date__c = system.today();
                
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please atleast one value'));
            }
            if(idinv == null){
                if(checkcreditorbank == 'true'){
                   /* if(this.invpaymnt.invoiceit_s__Card_Number__c == invpaymnt.invoiceit_s__Card_Number__c){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Credit card Detials you entered already Exists. Please update the existing'));
                    }*/
                 //else{   
                    invpaymnt.invoiceit_s__Payment_Method__c = 'Credit Card';
                    invpaymnt.invoiceit_s__Card_Number__c =tempCreditCardNumber;
                    invpaymnt.invoiceit_s__CVV__c = tempCreditCardCVV;
                    //}
                }
                else if(checkcreditorbank == 'false'){
                    invpaymnt.invoiceit_s__Payment_Method__c = 'ACH';
                }
                invpaymnt.invoiceit_s__Account__c = accid;
                
                try{
                    insert invpaymnt;
                }
                catch(exception ex){
                     apexpages.Message am;
                    if(ex.getMessage().contains('Credit Card Detials you entered already Exists')){
                        am = new apexpages.Message(ApexPages.Severity.Error, 'Credit Card Detials you entered already Exists. Please update the Existing one');
                    }
                    else{
                        am=new apexpages.Message(ApexPages.Severity.Error, ex.getMessage() + ', Line Number ' + ex.getLineNumber());
                    }
             
                    apexpages.addMessage(am);   
                    return null;
                }
                
            }
            else{
                
                if( invpaymnt.invoiceit_s__Payment_Method__c  == 'Credit Card')
                {
                    invpaymnt.invoiceit_s__Card_Number__c =tempCreditCardNumber;
                    invpaymnt.invoiceit_s__CVV__c = tempCreditCardCVV; 
                 }
                update invpaymnt;
            }
            
            formPanel = false;
            if(!Vaidationcheck){
            
                    successPanel = true;
                    system.debug('@@@@@@ IN SuccessPanel ');
            }
            
            
        }
        catch(exception e)
        {
            
        }
        
        return null;
        
    }
    
    
    public PageReference goToMainPage()
    {
        //PageReference mainPage = new PageReference('http://invoice.stg2.lawyers.com/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab');
        PageReference mainPage = null;
        string MainURL= '';
        if(isSMB){
            MainURL= system.label.SMB_Portal +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn='+smbtoken;
        }
        else{
            MainURL= system.label.PortalURL +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn='+smbtoken;
        }
        mainPage = new PageReference(MainURL);
        mainPage.setRedirect(true);
        return mainPage;
        
        //PageReference mainPage = new PageReference(system.Label.PortalURL +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab');
   
        //PageReference mainPage = Page.MDL_invoice_detail_page;
        //mainPage.setRedirect(true);
        //mainPage.getParameters().put('c',customerno);
        //mainPage.getParameters().put('tab','myPaymentTab');
        //mainPage.getParameters().put('sessionId',sessionId);
        //return mainPage;
        //return null;
        
    }
    
    public PageReference cancel()
    {
        //PageReference mainPage = new PageReference('http://invoice.stg2.lawyers.com/myPaymentTab/'+sessionId+ '/'+customerno+'/myPaymentTab');
       PageReference mainPage = null;
        string MainURL= '';
        if(isSMB){
            MainURL= system.label.SMB_Portal +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn='+smbtoken;
        }
        else{
            MainURL= system.label.PortalURL +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn ='+ smbtoken;
        }
        mainPage = new PageReference(MainURL);
        mainPage.setRedirect(true);
        return mainPage;
       
       //PageReference mainPage = new PageReference(system.Label.PortalURL +'/myPaymentTab/'+sessionId+ '/'+customerno+'/myPaymentTab');
        
        //PageReference mainPage = Page.MDL_invoice_detail_page;
        //mainPage.setRedirect(true);
        //mainPage.getParameters().put('c',customerno);
        //mainPage.getParameters().put('tab','myPaymentTab');
        //mainPage.getParameters().put('sessionId',sessionId);
        //return mainPage;
        //return null;
        
    }
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }   
    
    
}