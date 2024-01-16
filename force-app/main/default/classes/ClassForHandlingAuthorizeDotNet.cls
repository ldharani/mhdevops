global class ClassForHandlingAuthorizeDotNet {
    public static final String ENDPOINT_AUTHORIZEDOTNET_TEST = 'https://test.authorize.net/gateway/transact.dll';
    public static final String ENDPOINT_AUTHORIZEDOTNET_LIVE = 'https://secure.authorize.net/gateway/transact.dll';
    
    private map<string, string> parameters;
    private string sHttpBody = '';
    private string sHttpEndPoint = '';
    private string sHttpResponse;
    private list<string> responseArray;
    private invoiceit_s__Payment_Method__c paymentMethod;
    private invoiceit_s__Gateway__c gateway;
    private invoiceit_s__Invoice__c invoice;
    //private PaymentOperations.PaymentResult result = new PaymentOperations.PaymentResult();
    private invoiceit_s__Transaction__c transactionObj;
    private boolean isException = false;
    private Account account;
    private decimal dAmount;
    private PaymentResult result = new PaymentResult();
    
    public ClassForHandlingAuthorizeDotNet(invoiceit_s__Gateway__c gateway, invoiceit_s__Invoice__c invoice, invoiceit_s__Payment_Method__c paymentMethod) {
        this.invoice = invoice;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway;
        // 
        initialize();  
    }
    
    public PaymentResult handleAuthorizeAndCharge_Click() {  
        try { 
            decimal amountToBeProcessed = 0;
            if(invoice.invoiceit_s__Payment_Request_Amount__c != null && invoice.invoiceit_s__Payment_Request_Amount__c > 0 && invoice.invoiceit_s__Payment_Request_Amount__c < invoice.invoiceit_s__Unpaid_Amount__c) {
                amountToBeProcessed = invoice.invoiceit_s__Payment_Request_Amount__c;
            } else {
                amountToBeProcessed = invoice.invoiceit_s__Unpaid_Amount__c;
            }
            
            //fill  amount
            parameters.put('x_amount', string.ValueOf(amountToBeProcessed));
            
            //fill the invoice number
            parameters.put('x_invoice_num', invoice.Name);
            
            //fill the invoice number and invoice Id
            parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);
            
            //call the method fillCardInformation() where card information is captured
            fillCardInformation();
            populateCustomerDetails();
            
            //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
            transactionObj = new invoiceit_s__Transaction__c(invoiceit_s__Payment_Method__c = paymentMethod.Id, invoiceit_s__Type__c = 'Charge', invoiceit_s__Amount__c = amountToBeProcessed, invoiceit_s__Currency__c = invoice.invoiceit_s__CurrencyL__c, invoiceit_s__Payment_Gateway__c = gateway.Id);
            System.debug('transactionObj ' + transactionObj);
            //fill the type of method (Transaction Information)
            parameters.put('x_type', 'AUTH_CAPTURE');
            
            if(paymentMethod.invoiceit_s__Card_Number__c.Length() > 4){
              transactionObj.invoiceit_s__Request_Credit_Card_Number__c = paymentMethod.invoiceit_s__Card_Number__c.substring((paymentMethod.invoiceit_s__Card_Number__c.Length() - 4), paymentMethod.invoiceit_s__Card_Number__c.Length());
            }
            transactionObj.invoiceit_s__Request_Invoice__c = invoice.Id;
            transactionObj.invoiceit_s__Request_Type_Of_Payment__c = 'Credit Card';
            transactionObj.invoiceit_s__Request_Transaction_Type__c = 'Charge';
            transactionObj.invoiceit_s__Card_Expiration_Month__c = paymentMethod.invoiceit_s__Card_Expiration_Month__c;
            transactionObj.invoiceit_s__Card_Expiration_Year__c = paymentMethod.invoiceit_s__Card_Expiration_Year__c;
            transactionObj.invoiceit_s__Card_Type__c = paymentMethod.invoiceit_s__Card_Type__c;
            
            //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
            createStringFromMap();      
        
            System.debug('inside try ' + transactionObj);
            sHttpResponse = ClassForHandlingAuthorizeDotNet.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('\\|');
            handleRequest();
            if(transactionObj.invoiceit_s__Response_Status__c == 'Approved') {               
                //create the payment and payment allocation against the inv
                invoiceit_s__Payment__c payment = new invoiceit_s__Payment__c(invoiceit_s__Account__c = invoice.invoiceit_s__Account__c, 
                                            invoiceit_s__Amount__c = transactionObj.invoiceit_s__Amount__c, 
                                            invoiceit_s__Status__c = 'Completed', 
                                            invoiceit_s__Payment_Type__c = 'Credit Card',
                                            invoiceit_s__Payment_Date__c = system.today(),
                                            invoiceit_s__Transaction__c = transactionObj.Id,
                                            invoiceit_s__Currency__c = invoice.invoiceit_s__CurrencyL__c);
                insert payment;
                
                invoiceit_s__Payment_Allocation__c paymentAllocation = new invoiceit_s__Payment_Allocation__c(invoiceit_s__Payment__c = payment.Id,
                                                                                invoiceit_s__Amount__c = payment.invoiceit_s__Amount__c,
                                                                                invoiceit_s__Invoice__c = invoice.Id,
                                                                                invoiceit_s__Status__c = 'Completed');   
            
                insert paymentAllocation;
                
                transactionObj.invoiceit_s__Is_Payment_Processed_Successfully__c = true;
                update transactionObj;                                                                                                 
            }
        } catch(Exception ex) {
           system.debug('\n \n An Exception has occurred : ' + ex.getMessage());
           result.message = ex.getMessage() + ' ,Line NO ' + ex.getLineNumber() + ' ,Stack Trace ' + ex.getStackTraceString();
           result.exceptionOccured = true;
           // if exception occurs, log the messege into invoice Exception log.
           invoiceit_s__Invoice__c failedInvoiceTransaction = new invoiceit_s__Invoice__c(id = transactionObj.invoiceit_s__Request_Invoice__c,Exception_Log__c = ex.getMessage() + ' ,Line NO ' + ex.getLineNumber() + ' ,Stack Trace ' + ex.getStackTraceString());
           update failedInvoiceTransaction;
           
           if(transactionObj.invoiceit_s__Response_Status__c == 'Approved') {
               result.message += '\n \n Please Note : A user has been charged for this invoice but payment allocation is not done';
               transactionObj.invoiceit_s__Is_Payment_Processed_Successfully__c = false;
               transactionObj.invoiceit_s__Exception_Message__c = 'Transaction Has been processed sucessfully but invoice payment allocation is not done.' + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
               update transactionObj;   
           }
        }    
        
        return result;
    }
    
    public PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        try { 
            //fill the type of method (Transaction Information)
            parameters.put('x_type', 'VOID');    
            
            //fill the invoice number
            parameters.put('x_invoice_num', invoice.Name);
            
            //in order to void the transaction we need trasactionId
            parameters.put('x_trans_id', gatewayId);
            populateCustomerDetails();
            
            //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
            transactionObj = new invoiceit_s__Transaction__c(invoiceit_s__Type__c = 'Void', Id = transactionId, invoiceit_s__Gateway_ID__c = gatewayId, invoiceit_s__Is_Payment_Processed_Successfully__c = true, invoiceit_s__Amount__c = transactionAmount);
            transactionObj.invoiceit_s__Request_Credit_Card_Number__c = paymentMethod.invoiceit_s__Card_Number__c.substring((paymentMethod.invoiceit_s__Card_Number__c.Length() - 4), paymentMethod.invoiceit_s__Card_Number__c.Length());
            transactionObj.invoiceit_s__Request_Invoice__c = invoice.Id;
            transactionObj.invoiceit_s__Request_Type_Of_Payment__c = 'Credit Card';
            transactionObj.invoiceit_s__Request_Transaction_Type__c = 'Void';
            transactionObj.invoiceit_s__Card_Expiration_Month__c = paymentMethod.invoiceit_s__Card_Expiration_Month__c;
            transactionObj.invoiceit_s__Card_Expiration_Year__c = paymentMethod.invoiceit_s__Card_Expiration_Year__c;
            transactionObj.invoiceit_s__Card_Type__c = paymentMethod.invoiceit_s__Card_Type__c;
            
            //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
            createStringFromMap();      
            sHttpResponse = ClassForHandlingAuthorizeDotNet.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('\\|');
            handleRequest();
            if(transactionObj.invoiceit_s__Response_Status__c == 'Approved') {
                //cancel the payment 
                list<invoiceit_s__Payment__c> listOfPaymentsToCancelled = [SELECT Id,
                                                              (SELECT Id FROM invoiceit_s__Payment_Allocations__r)
                                                               FROM invoiceit_s__Payment__c
                                                               WHERE invoiceit_s__Transaction__c =: transactionObj.Id];
                                                   
                for(invoiceit_s__Payment__c payment : listOfPaymentsToCancelled) {
                    payment.invoiceit_s__Status__c = 'Cancelled';
                }                                              
                
                //update the payment to STATUS_CANCELLED then all the allocations will also get CANCELLED(by using trigger)
                update listOfPaymentsToCancelled;  
            }
        } catch(Exception ex) {
           system.debug('An Exception has occurred : ======' + ex.getMessage());
           result.message = ex.getMessage() + ' ,Line NO ' + ex.getLineNumber() + ' ,Stack Trace ' + ex.getStackTraceString();
           result.exceptionOccured = true;
        } 
        return result;
    }
    
    public PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        try { 
            //fill the type of method (Transaction Information)
            parameters.put('x_type', 'CREDIT');    
            
            //fill the invoice number
            parameters.put('x_invoice_num', invoice.Name);
            
            //fill the invoice number and invoice Id
            parameters.put('x_description', 'Refund against SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);
            
            //in order to refund/credit the money we need trasactionId
            parameters.put('x_trans_id', gatewayId);
            
            //x_card_num is the card number to be credited
             parameters.put('x_card_num', paymentMethod.invoiceit_s__Card_Number__c);
            
            //fill  amount
            parameters.put('x_amount', string.ValueOf(transactionAmount));
            
            populateCustomerDetails();
            
            //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
            transactionObj = new invoiceit_s__Transaction__c(invoiceit_s__Payment_Method__c = paymentMethod.Id, invoiceit_s__Type__c = 'Refund', Id = transactionId, invoiceit_s__Gateway_ID__c = gatewayId, invoiceit_s__Amount__c = transactionAmount, invoiceit_s__Is_Payment_Processed_Successfully__c = true, invoiceit_s__Payment_Gateway__c = gateway.Id);
            transactionObj.invoiceit_s__Request_Credit_Card_Number__c = paymentMethod.invoiceit_s__Card_Number__c.substring((paymentMethod.invoiceit_s__Card_Number__c.Length() - 4), paymentMethod.invoiceit_s__Card_Number__c.Length());
            transactionObj.invoiceit_s__Request_Invoice__c = invoice.Id;
            transactionObj.invoiceit_s__Request_Type_Of_Payment__c = 'Credit Card';
            transactionObj.invoiceit_s__Request_Transaction_Type__c = 'Refund';
            
            transactionObj.invoiceit_s__Card_Expiration_Month__c = paymentMethod.invoiceit_s__Card_Expiration_Month__c;
            transactionObj.invoiceit_s__Card_Expiration_Year__c = paymentMethod.invoiceit_s__Card_Expiration_Year__c;
            transactionObj.invoiceit_s__Card_Type__c = paymentMethod.invoiceit_s__Card_Type__c;
            
            //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
            createStringFromMap();      
        
            sHttpResponse = ClassForHandlingAuthorizeDotNet.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('\\|');
            handleRequest();
            
            if(transactionObj.invoiceit_s__Response_Status__c == 'Approved') {
                //cancel the payment 
                list<invoiceit_s__Payment__c> listOfPaymentsToCancelled = [SELECT Id,
                                                              (SELECT Id FROM invoiceit_s__Payment_Allocations__r)
                                                               FROM invoiceit_s__Payment__c
                                                               WHERE invoiceit_s__Transaction__c =: transactionObj.Id];
                                                   
                for(invoiceit_s__Payment__c payment : listOfPaymentsToCancelled) {
                    payment.invoiceit_s__Status__c = 'Cancelled';
                }                                              
                //update the payment to STATUS_CANCELLED then all the allocations will also get CANCELLED(by using trigger)
                update listOfPaymentsToCancelled; 
            }
        } catch(Exception ex) {
           system.debug('An Exception has occurred : ======' + ex.getMessage());
           result.message = ex.getMessage() + ' ,Line NO ' + ex.getLineNumber() + ' ,Stack Trace ' + ex.getStackTraceString();
           result.exceptionOccured = true;
        }
        return result;
    }
    
    public static string getHTTPResponse(string sHttpEndPoint, string sHttpBody) {
        Http httpObject = new Http();
        HttpResponse httpResponse;
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(sHttpEndPoint);
        httpRequest.setMethod('POST');
        httpRequest.setBody(sHttpBody);
        system.debug('in getHTTPResponse of utilclass try :: getCallouts ' + Limits.getCallouts());  
        system.debug('in sHttpBody ' + sHttpBody);
        
        if(!system.test.isRunningTest()) {
            httpResponse = httpObject.send(httpRequest);
            system.debug('sHttpResponse from server ' + httpResponse.getBody());
        } else {
            if(sHttpEndPoint == ClassForHandlingAuthorizeDotNet.ENDPOINT_AUTHORIZEDOTNET_TEST || sHttpEndPoint == ClassForHandlingAuthorizeDotNet.ENDPOINT_AUTHORIZEDOTNET_LIVE) {
                return '1|1|1|This transaction has been approved.|YUJNGH|Y|2160295577||0|600.00|CC|auth_capture||sandeep|b||dfsdf||wa|5555||||||||||||||||||71AFA2003D02930E47E84F23E14E07C3|P|2|||||||||||XXXX1111|Visa|||||||||||||||||false|1';
            } 
        }
        return httpResponse.getBody(); 
    }
    
    private void initialize(){
        parameters = new map<string, string>();
        //this determines is it sandboz or live
        if(gateway.invoiceit_s__Test_Mode__c){
            sHttpEndPoint = ClassForHandlingAuthorizeDotNet.ENDPOINT_AUTHORIZEDOTNET_TEST;
            parameters.put('x_email_customer', 'FALSE');
             //parameters.put('x_test_request', 'TRUE');
        } else {
            sHttpEndPoint = ClassForHandlingAuthorizeDotNet.ENDPOINT_AUTHORIZEDOTNET_LIVE;
            parameters.put('x_email_customer', 'TRUE');
        }
        
        //fill the merchant information from gateway
        parameters.put('x_login', gateway.invoiceit_s__Merchant_ID__c);
        parameters.put('x_tran_key', gateway.invoiceit_s__Security_Key__c); 
        
        /*parameters.put('x_login', '22LbQ9b7');
        parameters.put('x_tran_key', '8Fh7VnPV3e6h4b4S'); */
        
        //fill the version
        parameters.put('x_version', '3.1');          
        
        //are the response fields(In order to receive a delimited response from the payment gateway,submit this field with a value of TRUE, or the merchant has to configure a delimited response through the Merchant Interface.)
        //x_response_format = 0 or 1. 0 = XML and 1 = Delimited
        parameters.put('x_response_format','1'); 
        parameters.put('x_delim_data', 'TRUE');
        parameters.put('x_delim_char', '|'); 
        
        //This field, when set to TRUE, instructs the payment gateway to return transaction results to the merchant by means of an HTML form POST to the merchant’s Web server for a relay response.
        parameters.put('x_relay_response', 'FALSE'); 
        
        system.debug('parameters--------------> '+parameters);
    }
    
    private void handleRequest() {
        invoiceit_s__Transaction__c transactionObj2;
        //we have to refer page http://www.authorize.net/support/AIM_guide.pdf 37 page
        //if responseArray.get(0). 1 = Approved, 2 = Declined, 3 = Error, 4 = Held For review
        if(responseArray.get(0) == '1') {
            transactionObj.invoiceit_s__Response_Status__c = 'Approved';
            result.reloadPage = true;
        } else {
            if(transactionObj.Id != null) {
                transactionObj2 = new invoiceit_s__Transaction__c(invoiceit_s__Payment_Method__c = paymentMethod.Id, invoiceit_s__Type__c = transactionObj.invoiceit_s__Type__c, invoiceit_s__Gateway_ID__c = transactionObj.invoiceit_s__Gateway_ID__c, invoiceit_s__Amount__c = transactionObj.invoiceit_s__Amount__c);
                transactionObj2.invoiceit_s__Request_Credit_Card_Number__c = transactionObj.invoiceit_s__Request_Credit_Card_Number__c;
                transactionObj2.invoiceit_s__Currency__c = transactionObj.invoiceit_s__Currency__c;
                transactionObj2.invoiceit_s__Request_Type_Of_Payment__c = transactionObj.invoiceit_s__Request_Type_Of_Payment__c;
                transactionObj2.invoiceit_s__Request_Transaction_Type__c = transactionObj.invoiceit_s__Request_Transaction_Type__c;
                sObject sObjTrasn = (sObject)transactionObj2;
                transactionObj = (invoiceit_s__Transaction__c)sObjTrasn;
            }
            
            if(responseArray.get(0) == '2') {
                transactionObj.invoiceit_s__Response_Status__c = 'Declined';
            } else if(responseArray.get(0) == '3') {
                transactionObj.invoiceit_s__Response_Status__c = 'Error';
            } else {
                transactionObj.invoiceit_s__Response_Status__c = 'Held For review';
            }
        }
        
        transactionObj.invoiceit_s__Request_Invoice__c = invoice.Id;
        transactionObj.invoiceit_s__Gateway_Date__c = system.now(); 
        transactionObj.invoiceit_s__Response_Code__c = responseArray.get(0);
        transactionObj.invoiceit_s__Reason_Code__c = decimal.ValueOf(responseArray.get(0));
        transactionObj.invoiceit_s__Response_Message__c = responseArray.get(3);
        transactionObj.invoiceit_s__Response__c = responseArray.get(3);
        transactionObj.invoiceit_s__AVS_Response_Code__c =  responseArray.get(5);    
        transactionObj.invoiceit_s__Authorization__c = responseArray.get(4); // Authorization code  
        if(transactionObj.invoiceit_s__Gateway_ID__c == null) {  
            transactionObj.invoiceit_s__Gateway_ID__c = responseArray.get(6); // transaction Id  
        }
        
        if(transactionObj.Id == null) {
             result.message =  'Transaction created : ';
        } else {
             result.message =  'Transaction updated : ';
        }
        
        if(transactionObj.Id == null) {
            transactionObj.invoiceit_s__Payment_Gateway__c = gateway.Id;
            
        }
        upsert transactionObj;
        
        transactionObj = [SELECT Name, invoiceit_s__Response_Status__c, invoiceit_s__Amount__c
                          FROM invoiceit_s__Transaction__c
                          WHERE Id =: transactionObj.Id];
        
        result.message +=  transactionObj.Name + ' \n'
                        + 'Gateway Response : ' +  responseArray.get(3) + ' \n'
                        + 'Gateway Status : ' + transactionObj.invoiceit_s__Response_Status__c;
                        
        result.transactionObj = transactionObj; 
        
        system.debug('result final is ' + result);
    }
    
    //here from map we will "create key = value &" format
    //because we have to pass to endPoint
    private void createStringFromMap() {
        for(String key : parameters.keyset()) {
            // if the value is null, then it throws an exception
            if(parameters.get(key) != null) {
                sHttpBody += key + '=' +  EncodingUtil.urlEncode(parameters.get(key), 'UTF-8') + '&';
            }
        }
        sHttpBody = this.sHttpBody.substring(0, sHttpBody.length() - 1);
        system.debug('sHttpBody ' + sHttpBody);
    }
    
    private void fillCardInformation() {
        //fill the card information like card number, cvv, exp date and method like credit card
        parameters.put('x_card_num', paymentMethod.invoiceit_s__Card_Number__c);
        parameters.put('x_exp_date', paymentMethod.invoiceit_s__Card_Expiration_Month__c + paymentMethod.invoiceit_s__Card_Expiration_Year__c);
        parameters.put('x_card_code', paymentMethod.invoiceit_s__CVV__c);
        parameters.put('x_method', 'CC'); 
                                      
        /* parameters.put('x_card_num', '4007000000027');
        parameters.put('x_exp_date', '122014');
        parameters.put('x_card_code', '123');
        parameters.put('x_method', 'CC'); */
        
        //the following parameters are for the AVS
        if(paymentMethod.invoiceit_s__Billing_First_Name__c != null)
            parameters.put('x_first_name', paymentMethod.invoiceit_s__Billing_First_Name__c);

        if(paymentMethod.invoiceit_s__Billing_Last_Name__c != null)
            parameters.put('x_last_name', paymentMethod.invoiceit_s__Billing_Last_Name__c);
        
        if(paymentMethod.invoiceit_s__Billing_Address__c != null)
            parameters.put('x_address', paymentMethod.invoiceit_s__Billing_Address__c);
        
        if(paymentMethod.invoiceit_s__Billing_City__c != null)
            parameters.put('x_city', paymentMethod.invoiceit_s__Billing_City__c);
        
        if(paymentMethod.invoiceit_s__Billing_State_Province__c != null)
            parameters.put('x_state', paymentMethod.invoiceit_s__Billing_State_Province__c);
        
        if(paymentMethod.invoiceit_s__Billing_Zip_Postal__c != null)
            parameters.put('x_zip', paymentMethod.invoiceit_s__Billing_Zip_Postal__c);
        
        if(paymentMethod.invoiceit_s__Billing_Country__c != null)
            parameters.put('x_country', paymentMethod.invoiceit_s__Billing_Country__c);
        
        system.debug('Final values ='+parameters);
    }
    
    public void populateCustomerDetails() {
        // Billing details 
        if(paymentMethod.invoiceit_s__Account__r.Name != null){
            parameters.put('x_company', paymentMethod.invoiceit_s__Account__r.Name);
        }
        System.debug('paymentMethod values --------------'+paymentMethod);
        if(paymentMethod.invoiceit_s__Account__c != null){
            parameters.put('x_cust_id', paymentMethod.invoiceit_s__Account__c);  
        }
              
        if(paymentMethod.invoiceit_s__Billing_Phone__c != null){
             parameters.put('x_phone', paymentMethod.invoiceit_s__Billing_Phone__c);
        }
       
        if(paymentMethod.invoiceit_s__Billing_Fax__c != null){
            parameters.put('x_fax', paymentMethod.invoiceit_s__Billing_Fax__c);
        }
        
        if(paymentMethod.invoiceit_s__Billing_Email__c != null){
            parameters.put('x_email', paymentMethod.invoiceit_s__Billing_Email__c);
        }
        
        //invoice will be null, if the payment is done directly against the account
        if(invoice != null) {
           // shipping details
            if(invoice.invoiceit_s__Shipping_Contact__r.FirstName != null){
                parameters.put('x_ship_to_first_name', invoice.invoiceit_s__Shipping_Contact__r.FirstName);
            }
            if(invoice.invoiceit_s__Shipping_Contact__r.LastName != null){
                parameters.put('x_ship_to_last_name', invoice.invoiceit_s__Shipping_Contact__r.LastName);
            }
            
            if(invoice.invoiceit_s__Shipping_Contact__r.Account.Name != null){
                parameters.put('x_ship_to_company', invoice.invoiceit_s__Shipping_Contact__r.Account.Name);
            }
            
            if(invoice.invoiceit_s__Shipping_Contact__r.MailingStreet != null){
                parameters.put('x_ship_to_address', invoice.invoiceit_s__Shipping_Contact__r.MailingStreet);
            }
            
            if(invoice.invoiceit_s__Shipping_Contact__r.MailingCity != null){
                parameters.put('x_ship_to_city', invoice.invoiceit_s__Shipping_Contact__r.MailingCity);
            }
            
            if(invoice.invoiceit_s__Shipping_Contact__r.MailingState != null){
                parameters.put('x_ship_to_state', invoice.invoiceit_s__Shipping_Contact__r.MailingState);
            }
            
            if(invoice.invoiceit_s__Shipping_Contact__r.MailingPostalCode != null){
                parameters.put('x_ship_to_zip', invoice.invoiceit_s__Shipping_Contact__r.MailingPostalCode);
            }
            
            if(invoice.invoiceit_s__Shipping_Contact__r.MailingPostalCode != null){
                parameters.put('x_ship_to_country', invoice.invoiceit_s__Shipping_Contact__r.MailingCountry);
            }   
        }
    }
    
    global class PaymentResult {
      WebService String message;
      WebService Boolean reloadPage;
      WebService invoiceit_s__Transaction__c transactionObj;
      WebService boolean exceptionOccured = false;
   }    
   
   
   public static list<invoiceit_s__Payment_Method__c> getDefaultPaymentMethod(Id PaymentMethodId) {
      list<invoiceit_s__Payment_Method__c>  paymentMethods = [SELECT invoiceit_s__Card_Number__c, invoiceit_s__Card_Type__c, invoiceit_s__Card_Expiration_Month__c, invoiceit_s__Card_Expiration_Year__c, invoiceit_s__CVV__c, invoiceit_s__Name_on_Card__c, invoiceit_s__Billing_Country__c,
                                                                  invoiceit_s__Bank_Routing_Code__c, invoiceit_s__Bank_Account_Number__c, invoiceit_s__Bank_Account_Type__c, invoiceit_s__Bank_Name__c, invoiceit_s__Bank_Account_Name__c,
                                                                  invoiceit_s__Billing_First_Name__c, invoiceit_s__Billing_Last_Name__c, invoiceit_s__Billing_Address__c, invoiceit_s__Billing_City__c, invoiceit_s__Billing_State_Province__c, invoiceit_s__Billing_Zip_Postal__c ,
                                                                  invoiceit_s__Account__c, invoiceit_s__Account__r.Name, invoiceit_s__Billing_Phone__c, invoiceit_s__Billing_Fax__c, invoiceit_s__Billing_Email__c,invoiceit_s__Billing_State__c 
                                                                  FROM invoiceit_s__Payment_Method__c
                                                                  WHERE Id =: PaymentMethodId 
                                                                  LIMIT 1];                     
        return paymentMethods;                    
    }
    
    public static list<invoiceit_s__Invoice__c> getInvoices(Id invoiceId) {
      list<invoiceit_s__Invoice__c>  listOfInvoices = [SELECT invoiceit_s__Account__c, Name, invoiceit_s__Total_Invoice_Value__c, invoiceit_s__Unpaid_Amount__c, 
                                  invoiceit_s__CurrencyL__c, invoiceit_s__CurrencyL__r.Name, invoiceit_s__CurrencyL__r.invoiceit_s__Currency_Symbol__c, 
                                  invoiceit_s__Account__r.invoiceit_s__Gateway__c, invoiceit_s__Account__r.invoiceit_s__VAT_No__c, invoiceit_s__Account__r.Name, invoiceit_s__Account__r.BillingStreet, invoiceit_s__Account__r.BillingCity, invoiceit_s__Account__r.BillingState , invoiceit_s__Account__r.BillingCountry, invoiceit_s__Account__r.BillingPostalCode,
                                  invoiceit_s__Account__r.ShippingStreet, invoiceit_s__Account__r.ShippingCity, invoiceit_s__Account__r.ShippingCountry, invoiceit_s__Account__r.ShippingState,invoiceit_s__Account__r.ShippingPostalCode,
                                  invoiceit_s__Billing_Contact__r.Name, invoiceit_s__Billing_Contact__r.MailingStreet, invoiceit_s__Billing_Contact__r.MailingCity, invoiceit_s__Billing_Contact__r.MailingState , invoiceit_s__Billing_Contact__r.MailingCountry, invoiceit_s__Billing_Contact__r.MailingPostalCode, invoiceit_s__Billing_Contact__r.Salutation,
                                  invoiceit_s__Billing_Contact__r.FirstName, invoiceit_s__Billing_Contact__r.LastName,invoiceit_s__Order__r.Name,invoiceit_s__Invoice_Status__c, invoiceit_s__Payment_Request_Amount__c,invoiceit_s__Invoice_State__c,
                                  invoiceit_s__Shipping_Contact__r.FirstName, invoiceit_s__Shipping_Contact__r.LastName, invoiceit_s__Shipping_Contact__r.Account.Name, invoiceit_s__Shipping_Contact__r.MailingStreet,
                                  invoiceit_s__Shipping_Contact__r.MailingCity, invoiceit_s__Shipping_Contact__r.MailingState, invoiceit_s__Shipping_Contact__r.MailingPostalCode, invoiceit_s__Shipping_Contact__r.MailingCountry
                                  FROM invoiceit_s__Invoice__c
                                  WHERE Id =: invoiceId
                                  LIMIT 1];                    
        return listOfInvoices;                   
    }
    
    public static invoiceit_s__Transaction__c getTransaction(Id transactionId) {
       invoiceit_s__Transaction__c transactionObj = [SELECT invoiceit_s__Payment_Method__r.invoiceit_s__Account__c,
                          invoiceit_s__Request_Invoice__c,invoiceit_s__Gateway_ID__c,invoiceit_s__Amount__c,
                          invoiceit_s__Payment_Gateway__c   
                          FROM invoiceit_s__Transaction__c
                          WHERE Id =: transactionId]; 
                                         
        return transactionObj;                               
    }
    
    public static list<invoiceit_s__Gateway__c> getDefaultGateway(Id gateWayId) {
      list<invoiceit_s__Gateway__c> listOfGateways = [SELECT Name, invoiceit_s__Gateway_Type__c, invoiceit_s__Merchant_ID__c, invoiceit_s__Security_Key__c, invoiceit_s__Test_Mode__c, invoiceit_s__Merchant_Seal_User_Id__c
                          FROM invoiceit_s__Gateway__c
                          WHERE invoiceit_s__Gateway_Type__c =: 'Authorize.net'
                          AND Id =: gateWayId 
                          LIMIT 1];
                                         
        return listOfGateways;                             
    }
   
}