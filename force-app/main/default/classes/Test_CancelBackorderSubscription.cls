@IsTest
public class Test_CancelBackorderSubscription {

        
    static testmethod void Test_CancelBackorderSubscription(){
    
        list<Backorder__c> bkor = new list<Backorder__c>();
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;

        
        //creating single account
        account acc = new account(Name = 'test', MH_Cust_Number__c = '1234567890');
        insert acc;
        /*system.debug('@@@acc'+ acc);
        acc = [select id,name, MH_Cust_Number__c
                       from account where id =: acc.id];*/
       
    contact c = util.getcontact(acc.id);
    invoiceit_s__Currency__c cur =  util.getCurrencyObject();
    Opportunity opp = util.getOpportunity(acc.id , c.id , cur.id);
    Backorder__c Backorder = new Backorder__c(
                    Name = 'Test Backorder',
                    Account__c = acc.id,
                    Opportunity__c = opp.id,
                    Backorder_Id__c = '12',
                    Cancel_date__c = System.now().addDays(1)
        
            );
    Insert Backorder;
    Backorder.cancelled__c  = True ;
    Update Backorder;    
    bkor.add(Backorder);
    
    Test.startTest();
         id batchid = database.executebatch(new BackorderCancelLogic());
         BackorderCancelLogic bo = new BackorderCancelLogic();
         Database.BatchableContext bc;
         bo.execute(bc, bkor);      
        Test.stopTest();
        
    } 
    
    static testmethod void Test_CancelBackorderSubscription2(){
    
        list<Subscription__c > sb = new list<Subscription__c >();
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Deactivate_Trigger_for_data_load__c dtc = new Deactivate_Trigger_for_data_load__c();
        dtc.Deactivate_trigger__c = false;
        dtc.name = 'Deactivate';
        insert dtc;

        
        //creating single account
        account acc = new account(Name = 'test', MH_Cust_Number__c = '1234567890');
        insert acc;
        /*system.debug('@@@acc'+ acc);
        acc = [select id,name, MH_Cust_Number__c
                       from account where id =: acc.id];*/
       
    contact c = util.getcontact(acc.id);
    invoiceit_s__Currency__c cur =  util.getCurrencyObject();
    Opportunity opp = util.getOpportunity(acc.id , c.id , cur.id);
    Subscription__c Subscriptions = new Subscription__c (
                    Name = 'Test Subscriptions ',
                    Account__c = acc.id,
                    Opportunity__c = opp.id,
                    Subscription_Id__c= '12',
                    External_Id__c = '21321321',
                    cancelled__c  = True,
                    Cancel_date__c = System.now().addDays(-1)
        
            );
    Insert Subscriptions;
        
    Subscriptions.cancelled__c  = True ;
    Update Subscriptions;    
    sb.add(Subscriptions);
    Test.startTest();
         id batchid = database.executebatch(new SubscriptionCancelLogic ());
         SubscriptionCancelLogic bo = new SubscriptionCancelLogic ();
         Database.BatchableContext bc;
         bo.execute(bc, sb);            
            //SubscriptionCancelLogic b = new SubscriptionCancelLogic();
            //Database.executeBatch(b);
            
        Test.stopTest();
        
    } 
}