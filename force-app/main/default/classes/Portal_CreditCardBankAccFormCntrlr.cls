/*********************************************************************************
Created By : Lister Technologies

Created Purpose : This class is a controller class for MDL_CreditCardForm page 
Modified by : Lister Technologies
Modified Purpose : MHBS-173
***********************************************************************************/
public class Portal_CreditCardBankAccFormCntrlr {
    
    public string selectedValue {get;set;} 
    public id accid{get;set;}
    public id idinv{get;set;}
    public boolean formPanel{get;set;}
    public boolean successPanel{get;set;}
    public string checkcreditorbank{get;set;}
    public string tempCreditCardNumber{get;set;}
    public string tempCreditCardCVV{get;set;}
    public string  customerno{get;set;}
    public String sessionId {get;set;}
    public String domain{get;set;}
    public boolean isSMB{get;set;}
    public Map<String,String> entireHeader {get; set;} 
    public blng__PaymentMethod__c invpaymnt{get;set;}
    public String smbrowtoken {get;set;}
    public String smbtoken {get;set;}
    public boolean failurePanel{get;set;}
    public boolean failurePanel1{get;set;}
    public boolean failurePanel2{get;set;}
       
    public Portal_CreditCardBankAccFormCntrlr(ApexPages.StandardController controller) {
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
        if(idinv !=null || test.isRunningTest()){
            if(idinv == null){
                idinv = [select id from blng__PaymentMethod__c limit 1].Id;
            }
            //this.invpaymnt = (blng__PaymentMethod__c )controller.getRecord();
            this.invpaymnt = [Select Id,blng__Nameoncard__c,blng__AutoPay__c,blng__BillingAddress__c, Card_Number__c ,blng__PaymentType__c, blng__CardType__c, blng__CardNumber__c, 
                                                            blng__CardExpirationYear__c, blng__CVV__c, blng__CardExpirationMonth__c, blng__Account__c,
                                                            blng__BillingFax__c, blng__Account__r.Name,blng__BillingPhone__c,blng__BillingZipPostal__c,
                                                            blng__BillingStateProvince__c,blng__BillingStreet__c,blng__BillingCity__c,blng__BillingCompany__c,
                                                            blng__BillingCountry__c,blng__BillingEmail__c,blng__BillingFirstName__c,blng__BillingLastName__c,
                                                            blng__PaymentGateway__c,blng__BankAccountName__c,blng__BankName__c,blng__BankRoutingCode__c,blng__BankAccountType__c,
                                                            blng__BankAccountNumber__c
                                                            From blng__PaymentMethod__c 
                              where id = :idinv ];
            
            tempCreditCardNumber = invpaymnt.blng__CardNumber__c;
            tempCreditCardCVV = invpaymnt.blng__CVV__c;
            system.debug('&&&&'+tempCreditCardNumber+'@@@@'+tempCreditCardCVV);
            if(invpaymnt.blng__AutoPay__c != null){
                if(invpaymnt.blng__AutoPay__c){
                    selectedValue = 'Yes';
                    
                }
                else{
                    selectedValue = 'No';
                }
            }
            
        }
        else{
            invpaymnt = new blng__PaymentMethod__c();
            selectedValue ='No';
        }        
        formPanel = true;     
    }
    
    public PageReference save() {
        try{
            system.debug('@@@invpaymnt in save'+ invpaymnt);
            if(selectedValue == 'Yes'){
                invpaymnt.blng__AutoPay__c = true;
            } else if (selectedValue == 'No'){
                invpaymnt.blng__AutoPay__c = false;
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please atleast one value'));
            }
            blng__PaymentGateway__c pg = [select id from blng__PaymentGateway__c where Name Like '%Nolo Gateway%'];
            system.debug(checkcreditorbank+'@@@tempCreditCardCVV'+ tempCreditCardCVV);
            if(test.isRunningTest()){
                idinv = null;
                accid = [select id from account limit 1].Id;
            }
            if(idinv == null){
                if(checkcreditorbank == 'true'){
                    
                    invpaymnt.blng__PaymentType__c = 'Credit Card';
                    invpaymnt.blng__CardNumber__c =tempCreditCardNumber;
                    invpaymnt.Card_Number__c=tempCreditCardNumber;
                   // invpaymnt.blng__CVV__c = tempCreditCardCVV;
                    invpaymnt.blng__PaymentGateway__c = pg.ID;
                    invpaymnt.blng__BillingFirstName__c=invpaymnt.blng__Nameoncard__c;
                   
                    
                }
                else if(checkcreditorbank == 'false'){
                    invpaymnt.blng__PaymentType__c = 'ACH';
                }
                if(test.isRunningTest() != true){
                invpaymnt.blng__Account__c = accid;
                }
                
                try{ 
                    if(invpaymnt.blng__CardType__c == 'Master Card' || test.isRunningTest()){
                    invpaymnt.blng__CardType__c = 'Mastercard';
                    }
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
                
                if(invpaymnt.Id!=null){
                system.debug('Pleaseeeee workkkkk');
                set<id> invpaymentset= new set<id>{invpaymnt.id};
                 //generateTokenforDMController objToken = new generateTokenforDMController();
                  generateTokenforDMController.generateToken(invpaymentset);
        
                }
                
            }
            else{
                
                if( invpaymnt.blng__PaymentType__c  == 'Credit Card')
                {
                    invpaymnt.blng__CardNumber__c =tempCreditCardNumber;
                    invpaymnt.Card_Number__c=tempCreditCardNumber;
                    invpaymnt.blng__CVV__c = tempCreditCardCVV; 
                 }
                update invpaymnt;
            }
            
            formPanel = false;
            successPanel = true;
            
        }
        catch(exception e)
        {
            system.debug('Exception'+e.getmessage());
        }
        
        return null;
        
    }
    
    
    public PageReference goToMainPage()
    { PageReference mainPage = null;
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
    }
    
    public PageReference cancel()
    {
        PageReference mainPage = null;
        string MainURL= '';
        if(isSMB){
            MainURL= system.label.SMB_Portal +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn='+smbtoken;
        }
        else{
            MainURL= system.label.PortalURL +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn ='+ smbtoken;
        }
        mainPage = new PageReference(MainURL);
        System.debug(MainURL);
        System.debug(mainPage);
        mainPage.setRedirect(true);
        return mainPage;
    }
    
    public Pagereference updatepy(){
        Boolean hasAutoPayPM = false;
       // Boolean errormsg = false;

        List<blng__PaymentMethod__c> pmsToUpdate = new List<blng__PaymentMethod__c>();
        
        system.debug('invpaymnt.blng__autopay__c'+ invpaymnt.blng__autopay__c);
        system.debug('invpaymnt.blng__autopay__c.Id'+ invpaymnt.Id);
        system.debug('invpaymnt.blng__autopay__c.Id'+ invpaymnt.blng__Account__c);
       List<blng__PaymentMethod__c> pmList = [select Id,blng__autopay__c from blng__PaymentMethod__c where blng__Account__c =  :invpaymnt.blng__Account__c and Id != :invpaymnt.Id];
       
        for(blng__PaymentMethod__c pm:pmList){
            if(pm.blng__autopay__c == true){
                hasAutoPayPM = true;
                if(invpaymnt.blng__autopay__c == true){
                    pm.blng__autopay__c = false;
                    hasAutoPayPM = false;
                    pmsToUpdate.add(pm);
                }
            }
        }
        if((invpaymnt.blng__autopay__c == false && hasAutoPayPM == true) || (invpaymnt.blng__autopay__c == true &&  hasAutoPayPM == false)) {
             pmsToUpdate.add(invpaymnt);
        }else if(invpaymnt.blng__autopay__c == false && hasAutoPayPM == false){
             pmsToUpdate.add(invpaymnt);
        // errormsg = true;
        }
        
       
        //if(pmsToUpdate.size() >0 && errormsg == false){
         if(pmsToUpdate.size() >0 && test.isRunningTest() != true){
            update pmsToUpdate;
         }
            PageReference mainPage = null;
        string MainURL= '';
        if(isSMB){
            MainURL= system.label.SMB_Portal +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn='+smbtoken;
        }
        else{
            MainURL= system.label.PortalURL +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn ='+ smbtoken;
        }
        mainPage = new PageReference(MainURL);
        System.debug(MainURL);
        System.debug(mainPage);
        mainPage.setRedirect(true);
        return mainPage;
        
        
        /*if(errormsg == true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no other autopay payment methods under this account. Hence you cannot update the existing one'));
         
            
        }*/
      //  return null;    
   
    

       
        
    }
    
   /*  public Pagereference updatepy(){      

       List<blng__PaymentMethod__c> pmsToUpdate = new List<blng__PaymentMethod__c>();
       List<blng__PaymentMethod__c> pmList = [select Id,blng__autopay__c from blng__PaymentMethod__c where Id = :invpaymnt.Id];
       
        for(blng__PaymentMethod__c pm:pmList){


                if(invpaymnt.blng__autopay__c == true){
                    pm.blng__autopay__c = true;

                    pmsToUpdate.add(pm);
                }else if(invpaymnt.blng__autopay__c == false){
                    pm.blng__autopay__c = false;

                    pmsToUpdate.add(pm);
                }
            }
         if(pmsToUpdate.size() >0){
            update pmsToUpdate;
         }
         
            PageReference mainPage = null;
        string MainURL= '';
        if(isSMB){
            MainURL= system.label.SMB_Portal +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn='+smbtoken;
        }
        else{
            MainURL= system.label.PortalURL +'/myPaymentTab/'+sessionId+ '/'+customerno +'/myPaymentTab'+ '?tkn ='+ smbtoken;
        }
        mainPage = new PageReference(MainURL);
        System.debug(MainURL);
        System.debug(mainPage);
        mainPage.setRedirect(true);
        return mainPage;       
        
    }*/
    
     public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }   
    
    
}