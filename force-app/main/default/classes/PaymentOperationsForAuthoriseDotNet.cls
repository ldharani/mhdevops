global with sharing class PaymentOperationsForAuthoriseDotNet {
  ClassForHandlingAuthorizeDotNet.PaymentResult result;
    
    WebService static ClassForHandlingAuthorizeDotNet.PaymentResult refund(Id transactionId) {
        invoiceit_s__Transaction__c transactionObj;
        list<invoiceit_s__Payment_Method__c> paymentMethods;
        list<invoiceit_s__Invoice__c> listOfInvoices;
        list<invoiceit_s__Gateway__c> listOfGateways;
        invoiceit_s__Payment_Method__c paymentMethod;
        invoiceit_s__Invoice__c transactionInvoice;
        invoiceit_s__Gateway__c paymentGateWay;
        ClassForHandlingAuthorizeDotNet.PaymentResult result;
        
        System.debug('I am inside the retryFailedTrasactions ');
        // query the transaction object
        transactionObj = ClassForHandlingAuthorizeDotNet.getTransaction(transactionId);  
        // query the related gateway based on transaction gateway
        listOfGateways = ClassForHandlingAuthorizeDotNet.getDefaultGateway(transactionObj.invoiceit_s__Payment_Gateway__c);

        if(!listOfGateways.isEmpty()){
            // query the non failed payment method
            paymentMethods = ClassForHandlingAuthorizeDotNet.getDefaultPaymentMethod(transactionObj.invoiceit_s__Payment_Method__c);

          if(paymentMethods.size() > 0) {
              paymentMethod = paymentMethods.get(0);  
              // query the failed transaction invoice
              listOfInvoices = ClassForHandlingAuthorizeDotNet.getInvoices(transactionObj.invoiceit_s__Request_Invoice__c);
  
              if(listOfInvoices.size() > 0) {
                  transactionInvoice = listOfInvoices.get(0);
                  paymentGateWay = listOfGateways.get(0);
                    // refund the transaction
                    ClassForHandlingAuthorizeDotNet authorizeGateway = new ClassForHandlingAuthorizeDotNet(paymentGateWay, transactionInvoice, paymentMethod);
                    result = authorizeGateway.handleRefund_Click(transactionObj.invoiceit_s__Gateway_ID__c, transactionObj.Id, transactionObj.invoiceit_s__Amount__c); 
                    
                    system.debug('result in refund method is ' + result);
                    return result;
                }
            }
        }
       
       return null;
   }
   
   WebService static ClassForHandlingAuthorizeDotNet.PaymentResult void(Id transactionId) {
        invoiceit_s__Transaction__c transactionObj;
        list<invoiceit_s__Payment_Method__c> paymentMethods;
        list<invoiceit_s__Invoice__c> listOfInvoices;
        list<invoiceit_s__Gateway__c> listOfGateways;
        invoiceit_s__Payment_Method__c paymentMethod;
        invoiceit_s__Invoice__c transactionInvoice;
        invoiceit_s__Gateway__c paymentGateWay;
        ClassForHandlingAuthorizeDotNet.PaymentResult result;
        
        System.debug('I am inside the retryFailedTrasactions '); 
        // query the transaction object
        transactionObj = ClassForHandlingAuthorizeDotNet.getTransaction(transactionId);  
        // query the related gateway based on transaction gateway
        listOfGateways = ClassForHandlingAuthorizeDotNet.getDefaultGateway(transactionObj.invoiceit_s__Payment_Gateway__c);

        if(!listOfGateways.isEmpty()){
            // query the non failed payment method
            paymentMethods = ClassForHandlingAuthorizeDotNet.getDefaultPaymentMethod(transactionObj.invoiceit_s__Payment_Method__c);

          if(paymentMethods.size() > 0) {
              paymentMethod = paymentMethods.get(0);  
              // query the failed transaction invoice
              listOfInvoices = ClassForHandlingAuthorizeDotNet.getInvoices(transactionObj.invoiceit_s__Request_Invoice__c);
  
              if(listOfInvoices.size() > 0) {
                  transactionInvoice = listOfInvoices.get(0);
                  paymentGateWay = listOfGateways.get(0);
                  // refund the transaction
                  ClassForHandlingAuthorizeDotNet authorizeGateway = new ClassForHandlingAuthorizeDotNet(paymentGateWay, transactionInvoice,paymentMethod);
                  result = authorizeGateway.handleVoid_Click(transactionObj.invoiceit_s__Gateway_ID__c, transactionObj.Id, transactionObj.invoiceit_s__Amount__c); 
                  
                  return result;
              }
          }
        }
        return null;
   }
}