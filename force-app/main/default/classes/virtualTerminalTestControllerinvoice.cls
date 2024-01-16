// Author         : Akash
// Description    : Virtual Terminal account level payment
//                  according to selected recordType or Selected Invoice RecordType
//                  Payment Gateway


public class virtualTerminalTestControllerinvoice {
    
    public account                        acc                         {get;set;}
    public invoiceit_s__Payment_Method__c paymentMethod               {get;set;}
    public String                         invName                     {get;set;}
    public string                         invid                       {get;set;}
    public string                         slistOfCreditCards          {get;set;}
    public string                         selectedrecordTypefromUser  {get;set;}
    public string                         saveCardDetails             {get;set;}
    public decimal                         amount                      {get;set;}
    public boolean                        successPayment              {get;set;} 
    public String                         transactionId               {get;set;}
    public boolean                        redirectPage;
    public String                         choice                      {get;set;}
    public boolean                        selectedChoice              {get;set;}
    public string                         invAmount                   {get;set;}
    public boolean                        encryptCardNumber           {get;set;}
    public invoiceit_s__Invoice__c        invobj; 
    public invoiceit_s__Gateway__c        paymentGateway;
    public String                         selectedRecordType;
    public String                         sResponseMessage;
    public String                         cardSaveOption               {get;set;}
    public boolean                        isDisable                    {get;set;}
    public invoiceit_s__Invoice__c        invobjtemp; 
    public boolean                        isNone                       {get;set;}
    public String                         credicardselectedValue       {get;set;}
    public string                         urltonavigate                {get;set;}
    public String                         clickvalue                   {get;set;}
    public boolean                        isback                       {get;set;}
    public invoiceit_s__Currency__c       curr                         {get;set;}
    public string exceptionstring;
    Map<String,invoiceit_s__Payment_Method__c> allCreditcardsMap       = new Map<String,invoiceit_s__Payment_Method__c>();
    List<credicardtWrap> allCreditCardssWrap = new List<credicardtWrap>();            
    
    
    public virtualTerminalTestControllerinvoice (apexPages.StandardController stdController){
        
        this.acc                   = (account)stdController.getRecord();
        // added by steelbrick ram, Account name is required to pass it to gateway only for advanced payment where invoice is null 
        //system.debug('@@@@ acc name'+acc.name);
        acc.name = acc.MH_Cust_Number__c;
        choice                     = ApexPages.currentPage().getParameters().get('choice'); 
        selectedrecordTypefromUser = ApexPages.currentPage().getParameters().get('recordtypeselected');
        clickvalue                 = ApexPages.currentPage().getParameters().get('sClickValue');
        
        selectedChoice = false;
        paymentMethod = new invoiceit_s__Payment_Method__c();
        isDisable     = true;
        amount        = 0;
		
         system.debug('@@@isNOne in controller'+ isNone);
         system.debug('@@@@invName'+ ApexPages.currentPage().getParameters().get('namefield'));
        
         curr = [select id, invoiceit_s__Currency_Name__c 
                 from invoiceit_s__Currency__c
                  where invoiceit_s__Currency_Name__c = 'United States Dollar' 
                  LIMIT 1];
         
         if(clickvalue == 'true'){
             isNone        = true;
         }
         else if(clickvalue == 'false'){
             isNone = false;
         }
        //isNone        = true;
        //selectedrecordTypefromUser = null;
        //choice         = 'Yes';
        
        
         for(invoiceit_s__Payment_method__c pmet: [Select i.Name,i.Id,i.invoiceit_s__Name_on_Card__c,i.invoiceit_s__Default__c, i.invoiceit_s__Card_Type__c, i.invoiceit_s__Card_Number__c, 
                                                                i.invoiceit_s__Card_Expiration_Year__c, i.invoiceit_s__CVV__c, i.invoiceit_s__Card_Expiration_Month__c, i.invoiceit_s__Account__c,i.invoiceit_s__Billing_Fax__c,
                                                                i.invoiceit_s__Account__r.Name,i.invoiceit_s__Billing_Phone__c,i.invoiceit_s__Billing_State_Province__c,i.invoiceit_s__Billing_Zip_Postal__c,i.invoiceit_s__Billing_Address__c,i.invoiceit_s__Billing_City__c,i.invoiceit_s__Billing_Company__c,
                                                                i.invoiceit_s__Billing_Country__c,i.invoiceit_s__Billing_Email__c,i.invoiceit_s__Billing_First_Name__c,i.invoiceit_s__Billing_Last_Name__c,i.invoiceit_s__Active__c,i.invoiceit_s__Payment_Method__c,
                                                                i.invoiceit_s__Bank_Account_Name__c,i.invoiceit_s__Bank_Name__c,i.invoiceit_s__Bank_Routing_Code__c,i.invoiceit_s__Bank_Account_Type__c,i.invoiceit_s__Bank_Account_Number__c
                                                                From invoiceit_s__Payment_Method__c i 
                                                                where i.invoiceit_s__Account__c =: acc.id
                                                                     and i.invoiceit_s__Active__c = true]){
                              
                             allCreditCardssWrap.add(new credicardtWrap(false,pmet));
                             allCreditcardsMap.put(pmet.Id,pmet);
                             isback = true;
                             if(clickvalue == null){
                                 isNone = false;
                             }
                             

             }
             
             
             if(allCreditcardsMap.isEmpty()){
                 isNone = true;
             }
             
    }
    
    
     Public List<credicardtWrap> getAllCreditCards()
        {    
            system.debug('@@@in getAllCreditCards'+ allCreditCardssWrap);
            return allCreditCardssWrap;
        }
    
     public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Yes','Yes')); 
        options.add(new SelectOption('No','No')); 
        return options; 
    }
    
     public List<SelectOption> getrecordTypes() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('JV','JV Business Unit')); 
        options.add(new SelectOption('M-H','M-H Business Unit'));   
        return options; 
    } 
    
    
    //This is a wrapper class which contains a boolean flag and a associated payment method, the flag is used to denote if the contact was selected
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
    
    //submity payment action method definition
    public pageReference submitPayment(){
    
        system.debug('@@@in submitPayment');
         system.debug('@@@@amount'+amount); 
        
        //Declaration Section
        invobj             = new invoiceit_s__Invoice__c();
        paymentGateway     = new invoiceit_s__Gateway__c();
        invobjtemp         = new invoiceit_s__Invoice__c();
        selectedRecordType  = '';
        sResponseMessage = '';
        exceptionString = '';
        
        system.debug('@@@invid '+invid );
        //invid not null means user selected invoice in lookup
        if(invid != null && invid !=''){
            invobj = [SELECT invoiceit_s__Account__c, Name,invoiceit_s__Invoice_Date__c, invoiceit_s__Account__r.id,invoiceit_s__Net_Total__c, invoiceit_s__Unpaid_Amount__c,invoiceit_s__Payment_Status__c,  
                              invoiceit_s__CurrencyL__c, invoiceit_s__CurrencyL__r.Name, invoiceit_s__CurrencyL__r.invoiceit_s__Currency_Symbol__c,invoiceit_s__Invoice_Reference__c, invoiceit_s__Account__r.MH_Cust_Number__c,
                              invoiceit_s__Account__r.invoiceit_s__Gateway__c, invoiceit_s__Account__r.invoiceit_s__VAT_No__c, invoiceit_s__Account__r.Name, invoiceit_s__Account__r.BillingStreet, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingState , invoiceit_s__Account__r.BillingCountry, invoiceit_s__Account__r.BillingPostalCode,
                              invoiceit_s__Account__r.ShippingStreet, invoiceit_s__Account__r.ShippingCity, invoiceit_s__Account__r.ShippingCountry, invoiceit_s__Account__r.ShippingState,invoiceit_s__Account__r.ShippingPostalCode,
                              invoiceit_s__Billing_Contact__r.Name, invoiceit_s__Billing_Contact__r.MailingStreet, invoiceit_s__Billing_Contact__r.MailingCity, invoiceit_s__Billing_Contact__r.MailingState , invoiceit_s__Billing_Contact__r.MailingCountry, invoiceit_s__Billing_Contact__r.MailingPostalCode, invoiceit_s__Billing_Contact__r.Salutation,
                              invoiceit_s__Billing_Contact__r.FirstName, invoiceit_s__Billing_Contact__r.LastName,invoiceit_s__Order__r.Name,invoiceit_s__Invoice_Status__c, invoiceit_s__Payment_Request_Amount__c,invoiceit_s__Invoice_State__c,
                              invoiceit_s__Shipping_Contact__r.FirstName,invoiceit_s__Billing_Contact__r.Email, invoiceit_s__Shipping_Contact__r.LastName, invoiceit_s__Shipping_Contact__r.Account.Name, invoiceit_s__Shipping_Contact__r.MailingStreet,
                              invoiceit_s__Shipping_Contact__r.MailingCity, invoiceit_s__Shipping_Contact__r.MailingState, invoiceit_s__Shipping_Contact__r.MailingPostalCode, invoiceit_s__Shipping_Contact__r.MailingCountry,invoiceit_s__Shipping_Contact__r.Phone,
                              RecordType.DeveloperName,RecordType.Name
                              FROM invoiceit_s__Invoice__c
                             
                             where id =:invid];
            selectedRecordType = invobj.RecordType.Name;
        }
        //invid is null, but in this case user has opt for record type
        else{
            selectedRecordType = selectedrecordTypefromUser;
            // creating invoice object in case of 'No' condition
            //invobjtemp.invoiceit_s__Account__c      = acc.id;
            //invobjtemp.invoiceit_s__Invoice_Date__c = date.today();
            
            
        }
         system.debug('@@@selectedRecordType  '+selectedRecordType );
        
        //based on selectedRecordType getting the payment Gateway
        if(selectedRecordType !='' && selectedRecordType != null){
            String gatewayName = '';
            if(selectedRecordType.containsIgnoreCase('M-H')){
                gatewayName = Label.Nolo_Payment_Gateway;
            }
            else{
                gatewayName = Label.MDL_Payment_GateWay;
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
                                     //where id = 'a08M000000Bf293'];
                                     
                              
        }                    
        system.debug('@@@paymentGateway '+paymentGateway );                      
        if(paymentGateway != null){
           system.debug('@@@@acc'+acc);
           system.debug('@@@@credicardselectedValue'+credicardselectedValue); 
           
           if(credicardselectedValue != null && credicardselectedValue != ''){
               system.debug('@@@in if credicardselectedValue');
               //when page navigation occurs check selected value is resetting or not..? doubt
               paymentMethod = allCreditcardsMap.get(credicardselectedValue);
           
           }
           else{
               system.debug('@@@in else credicardselectedValue');
               if(paymentMethod.invoiceit_s__Account__c == null){
                    paymentMethod.invoiceit_s__Account__c = acc.id;
               }
           
                paymentMethod.invoiceit_s__Active__c=true;
                system.debug('@@@paymentMethod'+paymentMethod);
                try{
                    if(paymentMethod.id == null)
                        insert paymentMethod;
                 
                }    
                catch(exception ex){
                     apexpages.Message am;
                    exceptionstring = ex.getMessage();
                    system.debug('Exception'+ex);
                if(ex.getMessage().contains('Credit Card Detials you entered already Exists')){
                    am = new apexpages.Message(ApexPages.severity.Error,'Credit Card Details already Exists.Please update the Existing one');
                 }
                    
                else{
                    am=new apexpages.Message(ApexPages.severity.Error,ex.getMessage());
                    }
                    apexPages.addMessage(am);
                    //return null;   
                }
          
           }
           
            
        }
        
      
        
        return null;
    }
    
    
    public pageReference makePaymentNew(){
        system.debug('@@@@Exception string'+ exceptionstring);
	    if(exceptionstring != ''){
            system.debug('@@@ exception string'+ exceptionstring);
			if(exceptionstring.contains('Credit Card Detials you entered already Exists')){
                apexpages.Message am = new apexpages.Message(ApexPages.severity.Error,'Credit Card Details already Exists.Please update the Existing one');
				apexPages.addMessage(am);
                successPayment = false;
                redirectPage = false;
                isDisable = false;
             }
		}
		else{
				invoiceit_s__Payment__c paymentToUpdate;
			 invoiceit_s__Invoice__c invobjtemp = new invoiceit_s__Invoice__c();
			 if(choice == 'Yes'){
				 amount = decimal.valueOf(invAmount);
			 }
			 if(paymentGateway != null){
			   system.debug('@@@@acc'+acc);
			   system.debug('@@@invid in payment'+ invid);
			   
				system.debug('@@@paymentMethod'+paymentMethod);
					try{
					   
						invoiceit_s.PaymentSiteOperation siteClass = new invoiceit_s.PaymentSiteOperation();      
						if(invid != null){
							system.debug('@@@in PaymentSiteOperation');
							if(!Test.isRunningTest()){  
									  
								system.debug('@@@@amount'+amount);      
								 system.debug('@@@@paymentGateway'+paymentGateway);
								 system.debug('@@@@invobj'+invobj);
								 system.debug('@@@@paymentMethod.id'+paymentMethod.id);
								 system.debug('@@@@acc.id'+acc);       
								// sResponseMessage = siteClass.processPayment(paymentGateway,invobj, paymentMethod, paymentMethod.id,amount,acc,false,null  );
								// added by steelbrick ram, please query the currency record id and use it in the below line as last paramenter
								 sResponseMessage = siteClass.processPayment(paymentGateway,invobj, paymentMethod, paymentMethod.id,amount,acc,false,curr.id);
								system.debug('@@@callout done');
							}
						   
						}
						 else{
								 system.debug('@@@ in elase recordtype Payment');
								 if(!Test.isRunningTest()){  
									
									system.debug('final amount before processin : Laxman : ' + amount);
									
									system.debug('final paymentGateway: ' + paymentGateway);
									// added by steelbrick ram, please query the currency record id and use it in the below line as last paramenter
									sResponseMessage = siteClass.processPayment(paymentGateway,null, paymentMethod, paymentMethod.id,amount,acc,false,curr.id);
								 }
						 }
						 system.debug('@@@sResponseMessage '+sResponseMessage );   
						if((sResponseMessage.contains('Error')) || (sResponseMessage.contains('Declined'))){
							if(paymentMethod.invoiceit_s__Default__c==true){
								encryptCardNumber = true;
							}
							isDisable = false;
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,sResponseMessage));
							successPayment = false;
							
							 //deleting creditcard in case of transaction failure
							// delete paymentMethod;
						 
							
						}
						else{   
							system.debug('@@@@amount'+amount);      
								 system.debug('@@@@paymentGateway'+paymentGateway);
								 system.debug('@@@@invobj'+invobj);
								 system.debug('@@@@paymentMethod.id'+paymentMethod.id);
								 system.debug('@@@@acc.id'+acc); 
							for(invoiceit_s__Transaction__c transactionCreated : [select Id,Name,invoiceit_s__Is_Payment_Processed_Successfully__c,invoiceit_s__Exception_Message__c from invoiceit_s__Transaction__c where invoiceit_s__Request_Invoice__c=:invobj.Id and invoiceit_s__Payment_Method__c=:paymentMethod.Id order by LastModifiedDate desc limit 1]){
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
								isDisable = false;  
							   
							   if(transactionId != null){
									
									 Id trNoloRecordTypeId = Schema.SObjectType.invoiceit_s__Transaction__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Transaction).getRecordTypeId();
									if(selectedRecordType.containsIgnoreCase('M-H')){
										invoiceit_s__Transaction__c tr = new invoiceit_s__Transaction__c(id = transactionId, RecordTypeId = trNoloRecordTypeId);
										update tr;
									}
								   
							   }
								
								User createdUser = [Select Id from User where id=:UserInfo.getUserId() LIMIT 1];
								for(invoiceit_s__Payment__c payment : [select Id,User_ID__c,RecordTypeId from invoiceit_s__Payment__c where CreatedById=:createdUser.Id order by LastModifiedDate desc limit 1]){
									paymentToUpdate                              = payment;
									system.debug('@@@Payment in update'+ payment);
									system.debug('@@@Payment in update'+ payment.RecordTypeId);
									paymentToUpdate.invoiceit_s__Transaction__c  = transactionId;
									if(invid != null){
										paymentToUpdate.Invoice__c      = invid;
									}
									if(selectedRecordType.containsIgnoreCase('M-H')){
										paymentToUpdate.RecordTypeId = Schema.SObjectType.invoiceit_s__Payment__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Payments).getRecordTypeId();
									}
									
									System.debug('<><><>'+UserInfo.getUserId());                                                   
									if(UserInfo.getUserId()!=null && UserInfo.getUserId()!=''){
										paymentToUpdate.User_ID__c = UserInfo.getUserId(); 
									}
								   
																   
								 }
								   
									
								  if(paymentToUpdate!=null){
									  update paymentToUpdate;  
								  }
														   
							}                   
							catch(Exception e){
								system.debug('@@@@in main exception');
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, e.getMessage()));
								successPayment = false;
								redirectPage = false;
							} 
						}                           
				   
					}  
						/* if(cardSaveOption == 'No'){
							 delete paymentMethod;
						 
						 }*/
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,sResponseMessage+ '\n Transaciton Id:'+ transactionId ));
						 
					}    
				catch(exception ex){
					apexPages.addMessages(ex);
				}
				
			}
		}
         
        
    
        return null;
    }
    public void yesOrNoSelection(){
        if(choice == 'No'){
            selectedChoice = true;    
        }
        
    }
   
    public pageReference processPaymentRedirect(){
        system.debug('@@@isNOne in redirect'+ isNone);
       
        String url = ApexPages.currentPage().getUrl();
        system.debug('@@@@url'+url);
        pageReference pg = new PageReference(url);
        //pg.setRedirect(true);
        return pg;
    
    
    }
}