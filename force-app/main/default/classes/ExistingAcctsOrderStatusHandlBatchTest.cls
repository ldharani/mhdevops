//Author                : Sai
//Description           : Test class for ExistingAccountsOrderStatusHandlBatch which calls
//                        ExistingAcctsOrderStatusHandling class

@isTest(seeAllData = true)
public class ExistingAcctsOrderStatusHandlBatchTest {
    
    static testmethod void run2condition(){
        
        //creating accounts
        List<account> acclist = new list<account>();
        Account a = createaccount('testAcc0123456789','01234567890');
        Account a1 = createaccount('testAcc012345678900', '12345680500');
        Account a2 = createaccount('testAcc012345678911', '65465462165');
        acclist.add(a);
        acclist.add(a1);  
        acclist.add(a2);
        insert acclist;
        
        
               
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        //creating contact
        contact con = testutil.getContact(acclist[0].Id);
        
        //creating currency object
        invoiceit_s__Currency__c currencyobj = testutil.getCurrencyObject();
        
        
        //creating opportunity
        opportunity opp = testutil.getOpportunity(acclist[0].Id, con.Id, currencyobj.id);
        
        List<invoiceit_s__Job__c> orderslist = new list<invoiceit_s__Job__c>();
        
        //creating order
        invoiceit_s__Job__c job = createOrder('In Progress', acclist[0].id, currencyobj.id);
        invoiceit_s__Job__c job1 = createOrder('In Progress', acclist[0].id, currencyobj.id);
        invoiceit_s__Job__c job2 = createOrder('In Progress', acclist[0].id, currencyobj.id);
        invoiceit_s__Job__c job3 = createOrder('Active', acclist[0].id, currencyobj.id);
         invoiceit_s__Job__c job4 = createOrder('In Progress', acclist[1].id, currencyobj.id);
         orderslist.add(job);
         orderslist.add(job1);
         orderslist.add(job2);
         orderslist.add(job3);
         orderslist.add(job4);   
        insert orderslist;
        
        orderslist[1].invoiceit_s__Status__c = 'Expired';
        orderslist[2].invoiceit_s__Status__c = 'Expired';
        orderslist[2].invoiceit_s__Service_Activation_Date__c = date.today()-1;
        update orderslist;
        
        
        
        system.debug('@@@@account in test class'+ a);
        system.debug('@@@@account customer status'+ a.Customer_Status__c);
        system.debug('@@@@account MH_Cust_Number__c status'+ a.MH_Cust_Number__c);
        system.debug('@@@@account Organization_Type__c status'+ a.Organization_Type__c);
        system.debug('@@@@account created_from_test_class__c status'+ a.created_from_test_class__c);
		
      
        test.startTest();
        database.executeBatch(new ExistingAccountsOrderStatusHandlBatch());
        test.stopTest();
        
        
        
    }
    
    public static invoiceit_s__Job__c createOrder(String status, id accid, id currId){
        invoiceit_s__Job__c job = new invoiceit_s__Job__c();
        job.Name = 'Test Order';
        job.invoiceit_s__Account__c = accid;
        job.invoiceit_s__CurrencyL__c = currId;
        job.invoiceit_s__Status__c = status;
        job.invoiceit_s__Service_Activation_Date__c = date.today();
        return job;
    }     
   
    public static account createaccount(String Name, String customerNumber){
        Account a = new Account();
        a.Name= Name ; 
        a.Phone='122-34345-654';
        a.invoiceit_s__Preferred_Billing_Day__c = '1';
        a.Type = 'Customer';
        a.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        a.ShippingStreet = '111 Train Ave';
        a.BillingStreet = '111 Train Ave';
        a.BillingState = 'NY';
        a.ShippingState = 'NY';
        a.ShippingPostalCode = '12356-2343'; a.BillingPostalCode = '12356-2343';
        a.ShippingLongitude = 12;a.BillingLongitude = 12;
        a.ShippingLatitude = 10 ;a.BillingLatitude = 10;
        a.ShippingCountry = 'USA';a.BillingCountry = 'USA';
        a.ShippingCity = 'California';a.BillingCity = 'California';
        a.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
        a.Organization_Type__c = 'Law Firm';
        a.MH_Cust_Number__c    = customerNumber;
        return a;

    }
    
       

}