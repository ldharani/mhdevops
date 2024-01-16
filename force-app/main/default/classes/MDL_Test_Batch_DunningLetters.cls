/* Test Class to cover MDL_Batch_DunningLetters & MDL_Ctrl_SendEmail*/
@isTest
public with sharing class MDL_Test_Batch_DunningLetters {
        static testMethod void Test_TriggerHandlerOnOrderRPC() {/*
                MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
                
                Account a = testData.getAccount();
                invoiceit_s__Invoice__c invoice = testData.getInvoice(a.id);
                invoiceit_s__Invoice__c invoice2 = testData.getInvoice(a.id);
                invoiceit_s__Invoice__c invoice3 = testData.getInvoice(a.id);
                invoice2.invoiceit_s__Due_Date__c = date.Today().addDays(-60);              
                invoice3.invoiceit_s__Due_Date__c = date.Today().addDays(-30);
                update invoice2;
                update invoice3;
                Database.QueryLocator QL;
                Database.BatchableContext BC;
            
                MDL_Batch_DunningLetters b = new MDL_Batch_DunningLetters();
                
                QL = b.start(BC);
                Database.QueryLocatorIterator QIT =  QL.iterator();
                
                List<Account> list_account = new List<Account>(); 
                while (QIT.hasNext())
                {
                    Account acc = (Account)QIT.next();           
                    list_account.add(acc);
                } 
                
                b.execute(BC, list_account);
                //b.finish(BC);        
                MDL_ScheduleDunningLetters m = new MDL_ScheduleDunningLetters();
                String sch = '0 0 23 * * ?';
                system.schedule('Test check', sch, m);
             */    
        }      
}