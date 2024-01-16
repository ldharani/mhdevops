// Author      : Sai
// Description : Test Class for BatchChangeaccountOrderStatusCancelled

@isTest(seeAllData = true)
public class BatchChangeaccntOrderStsCancelledTest {
    
    static testmethod void run2condition(){
        
        //creating test data
         MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating account
        account acc = testutil.getAccount();
        
        //creating currency 
        invoiceit_s__Currency__c singlecurr = testutil.getCurrencyObject();
        
        Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month()-1);
        Date lastDayOfprevMonth = Date.newInstance(date.today().year(), date.today().month()-1, numberOfDays);
        //creating order
        invoiceit_s__Job__c order = new invoiceit_s__Job__c();
        order.Name                               = 'Test Order';
        order.invoiceit_s__Account__c            = acc.Id;
        order.invoiceit_s__CurrencyL__c          = singlecurr.id;
        order.invoiceit_s__Status__c             = 'Cancelled';
        order.invoiceit_s__Service_End_Date__c   = lastDayOfprevMonth;
        insert order;
        
        test.startTest();
            Database.executeBatch(new BatchChangeaccountOrderStatusCancelled(),10);
        test.stopTest();
        
        
        
    }
    
    

}