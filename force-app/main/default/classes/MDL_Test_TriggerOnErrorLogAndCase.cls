@isTest(seealldata=true)
public with sharing class MDL_Test_TriggerOnErrorLogAndCase {
    static testmethod void createErrorLog(){
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
        Account acc = testData.getAccount();
        invoiceit_s__Currency__c cur= new invoiceit_s__Currency__c(Name = 'USD', 
        invoiceit_s__Symbol__c = '$');
        insert cur;
        
        
        invoiceit_s__Product__c prod = testData.getProduct('false');
        invoiceit_s__Product_Rate_Plan__c prodRP = testData.getProductRatePlan(prod.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c pRPC = testData.getProductRatePlanCharge(Cur.Id, prodRP.Id);
        invoiceit_s__Job__c ord = testData.getOrder(acc.Id, Cur.Id);
        invoiceit_s__Job__c order = [select Id,Name from invoiceit_s__Job__c where Id=:ord.Id];
        System.debug('ord'+ord);
        
        Error_Log__c e = new Error_Log__c();
        e.Error_Reason__c = '400 : Bad Request';
        e.Order_Name__c  = order.Name;
        insert e;
        
        Error_Log__c errorLog = [select Id,Case__c from Error_Log__c where Id= :e.Id];
        
        Case c = [Select Id from Case where Id =: errorLog.Case__c];
        c.status = 'Closed';
        update c;
    }
    static testMethod void testCloseOfRenewalOpptyCase(){
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
        Account acc = testData.getAccount();
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        invoiceit_s__Job__c order = testData.getOrder(acc.Id, Cur.Id);
        order.Do_Not_Renew__c = false;
        order.invoiceit_s__Number_Of_Terms__c = 4;
        order.invoiceit_s__Discount_Percent__c = 0.0;
        update order;
        
        RecordType r = [Select r.SobjectType, r.Name, r.Id From RecordType r where r.SobjectType = 'Case' and r.Name = 'MDL Oppty Renew' LIMIT 1];
        Case c = new Case();
        c.AccountId = acc.Id;
        c.RecordTypeId = r.Id;
        c.Subject = 'Subscription Renewal for '+acc.Name;
        c.Description = 'Account is due for renewal within 120 days';
        c.Priority = 'Medium';
        c.Area__c = 'Opportunity';
        c.Sub_Area__c = 'Renewal';
        c.Parent_Order__c = order.Id;
        insert c;
        
        Test.startTest();
        c.status = 'Closed';
        c.Resolution__c = 'Lost';
        update c;
        Test.stopTest();
    }
}