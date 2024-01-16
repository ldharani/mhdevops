@isTest
public class mdl_CreditCardBankAccountFormTest {
    
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;

        
        //creating single account
        account acc = new account(Name = 'test', MH_Cust_Number__c = '1234567890');
        insert acc;
        system.debug('@@@acc'+ acc);
        acc = [select id,name, MH_Cust_Number__c
                       from account where id =: acc.id];
       
        
        //creating payment method
        invoiceit_s__Payment_Method__c paymentmethod = utilclass.getPaymentMethod(acc.Id);
        
        ApexPages.currentPage().getParameters().put('id',paymentmethod.id);
        ApexPages.currentPage().getParameters().put('c', acc.MH_Cust_Number__c);
        
        MDL_CreditCardBankAccountFormController invoking = new MDL_CreditCardBankAccountFormController
                                                            (new apexPages.StandardController(paymentmethod));
        
        invoking.selectedValue = 'Yes';
        
        invoking.save();
        invoking.idinv = null;
        invoking.checkcreditorbank = 'true';
        invoking.save();
         invoking.selectedValue = 'No';
        invoking.idinv = null;
        invoking.checkcreditorbank = 'false';
        invoking.save();
        
        invoking.goToMainPage();
        invoking.cancel();
        invoking.getItems();
        
        
    }

}