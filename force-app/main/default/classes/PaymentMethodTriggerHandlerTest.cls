// Test Class Which includes the coverage of 
//PaymentMethodTriggerHandler Class

@isTest(seealldata= True)
public class PaymentMethodTriggerHandlerTest{
    Static Testmethod void run2condition(){
    MDL_UtilClass_TestClass utiltest = new MDL_UtilClass_TestClass();
    
    //Creating a Account
    account acc = utiltest.getAccount();
    
    
    //creating a Contact
    contact con = utiltest.getContact(acc.id);
    
    //Creating a Payment Method
    invoiceit_s__Payment_Method__c SinglePm = new invoiceit_s__Payment_Method__c();
    SinglePm =utiltest.getPaymentMethod(acc.Id);
   // SinglePm.invoiceit_s__Card_Number__c = string.valueOf(1234567890);
    //SinglePm.invoiceit_s__CVV__c  = string.valueOf(1234);
    //Insert SinglePm;  
    
    test.startTest();
        try{
            update SinglePm;
            system.assert(True, 'Credit Card Detials you entered already Exists. Please update the Existing one');
        }
        catch(exception e){
            String message = e.getMessage();
        System.assert(message.contains('Credit Card Detials you entered already Exists. Please update the Existing one'), 'message=' + message);
        }
        test.stopTest();
    
    }


}