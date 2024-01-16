public with sharing class ClassAfterOnPaymentRun{
    // 1) we need to reprocess the failed transactions
    public void handleAfterOnPaymentRun(map<Id, invoiceit_s__Payment_Run__c> newMap, map<Id, invoiceit_s__Payment_Run__c> oldMap) {
      invoiceit_s__Payment_Run__c paymentRunOld;
      set<Id> setofpaymentRun = new set<Id>();
      string sQuery = '';
      
      for(invoiceit_s__Payment_Run__c paymentRun : newMap.values()) {
          paymentRunOld = oldMap.get(paymentRun.Id);
          if((paymentRun.invoiceit_s__Status__c != paymentRunOld.invoiceit_s__Status__c) 
              && (paymentRun.invoiceit_s__Status__c == 'Completed' || paymentRun.invoiceit_s__Status__c == 'Completed with errors')
              ) 
          {
              setofpaymentRun.add(paymentRun.Id);
          }
        } 
        
        system.debug('setofpaymentRun in trigger is ' + setofpaymentRun);
      if(!setofpaymentRun.isEmpty()) { 
        String cronExpr = null;
          String jobId  = null;           
          Integer hours =  system.now().Hour();
          Integer minutes = system.now().Minute() + 1;            
          Integer seconds = 0;
          Integer dayOfMonth = system.today().day();
          Integer month =  system.today().month(); 
          Integer year =  system.today().year();
          String space = ' ';
          String questionMark = '?';
          String repeat  = '*';
          String comma = ',';
      
      // schedule the bact class to process the failed transaction invoices
        cronExpr = seconds+ space  + minutes+ space + hours + space + dayOfMonth + space + month + space+ questionMark + space + year;  
        System.schedule('BatchProcessRetryFailedTransaction '+system.now(),cronExpr,new PaymentRunScheduler(setofpaymentRun));
      }
    }
    

    // method use to re process the failed transactions
    /*When the payment scheduler processes the payments automatically the default payment method will be picked up first (irrespective of the ranking). 
    If the payment gets declined, then the payment methods will be picked on the basis of the ranking (1,2,3 etc) 
    and each will be processed till the payment succeeds. */
    public static ClassForHandlingAuthorizeDotNet.PaymentResult retryFailedTrasactions(Id transactionId) {
        invoiceit_s__Transaction__c transactionObj;
        list<invoiceit_s__Payment_Method__c> paymentMethods;
        list<invoiceit_s__Invoice__c> listOfInvoices;
        list<invoiceit_s__Gateway__c> listOfGateways;
        invoiceit_s__Payment_Method__c paymentMethod;
        invoiceit_s__Invoice__c failedTransactionInvoice;
        invoiceit_s__Gateway__c paymentGateWay;
        string sRank;
        ClassForHandlingAuthorizeDotNet.PaymentResult result;
        
        System.debug('I am inside the retryFailedTrasactions ');
        // query the failed transaction 
        transactionObj = [SELECT invoiceit_s__Payment_Method__r.Rank__c, invoiceit_s__Payment_Method__r.invoiceit_s__Account__c,
                          invoiceit_s__Request_Invoice__c,
                          invoiceit_s__Payment_Gateway__c   
                          FROM invoiceit_s__Transaction__c
                          WHERE Id =: transactionId];   

        if(transactionObj.invoiceit_s__Payment_Method__r.Rank__c != null) {
            sRank = transactionObj.invoiceit_s__Payment_Method__r.Rank__c;
            // query the failed transaction associated gateway
            listOfGateways = [SELECT Name, invoiceit_s__Gateway_Type__c, invoiceit_s__Merchant_ID__c, invoiceit_s__Security_Key__c, invoiceit_s__Test_Mode__c, invoiceit_s__Merchant_Seal_User_Id__c
                              FROM invoiceit_s__Gateway__c
                              WHERE invoiceit_s__Gateway_Type__c =: 'Authorize.net'
                                  AND id =: transactionObj.invoiceit_s__Payment_Gateway__c
                                  LIMIT 1];

            if(!listOfGateways.isEmpty()){
                // query the non failed payment method
                paymentMethods = [SELECT invoiceit_s__Card_Number__c, invoiceit_s__Card_Type__c, invoiceit_s__Card_Expiration_Month__c, invoiceit_s__Card_Expiration_Year__c, invoiceit_s__CVV__c, invoiceit_s__Name_on_Card__c, invoiceit_s__Billing_Country__c,
                                  invoiceit_s__Bank_Routing_Code__c, invoiceit_s__Bank_Account_Number__c, invoiceit_s__Bank_Account_Type__c, invoiceit_s__Bank_Name__c, invoiceit_s__Bank_Account_Name__c,
                                  invoiceit_s__Billing_First_Name__c, invoiceit_s__Billing_Last_Name__c, invoiceit_s__Billing_Address__c, invoiceit_s__Billing_City__c, invoiceit_s__Billing_State_Province__c, invoiceit_s__Billing_Zip_Postal__c ,
                                  invoiceit_s__Account__c, invoiceit_s__Account__r.Name, invoiceit_s__Billing_Phone__c, invoiceit_s__Billing_Fax__c, invoiceit_s__Billing_Email__c,invoiceit_s__Billing_State__c 
                                  FROM invoiceit_s__Payment_Method__c
                                  WHERE invoiceit_s__Account__c =: transactionObj.invoiceit_s__Payment_Method__r.invoiceit_s__Account__c
                                  AND
                                  Rank__c >: sRank
                                  ORDER BY Rank__c
                                  LIMIT 1];

                if(paymentMethods.size() > 0) {
                    paymentMethod = paymentMethods.get(0);  
                    // query the failed transaction invoice
                    listOfInvoices = [SELECT invoiceit_s__Account__c, Name, invoiceit_s__Total_Invoice_Value__c, invoiceit_s__Unpaid_Amount__c, 
                                      invoiceit_s__CurrencyL__c, invoiceit_s__CurrencyL__r.Name, invoiceit_s__CurrencyL__r.invoiceit_s__Currency_Symbol__c, 
                                      invoiceit_s__Account__r.invoiceit_s__Gateway__c, invoiceit_s__Account__r.invoiceit_s__VAT_No__c, invoiceit_s__Account__r.Name, invoiceit_s__Account__r.BillingStreet, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingState , invoiceit_s__Account__r.BillingCountry, invoiceit_s__Account__r.BillingPostalCode,
                                      invoiceit_s__Account__r.ShippingStreet, invoiceit_s__Account__r.ShippingCity, invoiceit_s__Account__r.ShippingCountry, invoiceit_s__Account__r.ShippingState,invoiceit_s__Account__r.ShippingPostalCode,
                                      invoiceit_s__Billing_Contact__r.Name, invoiceit_s__Billing_Contact__r.MailingStreet, invoiceit_s__Billing_Contact__r.MailingCity, invoiceit_s__Billing_Contact__r.MailingState , invoiceit_s__Billing_Contact__r.MailingCountry, invoiceit_s__Billing_Contact__r.MailingPostalCode, invoiceit_s__Billing_Contact__r.Salutation,
                                      invoiceit_s__Billing_Contact__r.FirstName, invoiceit_s__Billing_Contact__r.LastName,invoiceit_s__Order__r.Name,invoiceit_s__Invoice_Status__c, invoiceit_s__Payment_Request_Amount__c,invoiceit_s__Invoice_State__c,
                                      invoiceit_s__Shipping_Contact__r.FirstName, invoiceit_s__Shipping_Contact__r.LastName, invoiceit_s__Shipping_Contact__r.Account.Name, invoiceit_s__Shipping_Contact__r.MailingStreet,
                                      invoiceit_s__Shipping_Contact__r.MailingCity, invoiceit_s__Shipping_Contact__r.MailingState, invoiceit_s__Shipping_Contact__r.MailingPostalCode, invoiceit_s__Shipping_Contact__r.MailingCountry
                                      FROM invoiceit_s__Invoice__c
                                      WHERE Id =: transactionObj.invoiceit_s__Request_Invoice__c
                                      LIMIT 1];

                    if(listOfInvoices.size() > 0) {
                        failedTransactionInvoice = listOfInvoices.get(0);
                        
                        paymentGateWay = listOfGateways.get(0);

                        // re process the failed transaction invoice
                        ClassForHandlingAuthorizeDotNet authorizeGateway = new ClassForHandlingAuthorizeDotNet(paymentGateWay,failedTransactionInvoice,paymentMethod);
                        result = authorizeGateway.handleAuthorizeAndCharge_Click(); 
                        
                        return result;
                    }
                }
            }
        }
        return null;
    }
}