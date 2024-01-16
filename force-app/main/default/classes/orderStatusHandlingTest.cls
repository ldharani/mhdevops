// author                : Sai
// description           : test class for OrderStatusHandling


@isTest(seeAllData = true)
public class orderStatusHandlingTest {
    
    static testmethod void run2condition(){
        MDL_UtilClass_TestClass testutil = new MDL_UtilClass_TestClass();
        
        list<account> acclist = new List<account>();
        //creating account
        account a = new account();
        a.Name = 'testAcc'; 
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
        a.Organization_Type__c = 'Law Firm';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
        acclist.add(a);
        //update acc;
        
        account acc1 = new account();
        acc1.Name = 'testAcc1'; 
        acc1.Phone='122-34345-654';
        acc1.invoiceit_s__Preferred_Billing_Day__c = '1';
        acc1.Type = 'Customer';
        acc1.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        acc1.ShippingStreet = '111 Train Ave';
        acc1.BillingStreet = '111 Train Ave';
        acc1.BillingState = 'NY';
        acc1.ShippingState = 'NY';
        acc1.ShippingPostalCode = '12356-2343'; a.BillingPostalCode = '12356-2343';
        acc1.ShippingLongitude = 12;a.BillingLongitude = 12;
        acc1.ShippingLatitude = 10 ;a.BillingLatitude = 10;
        acc1.ShippingCountry = 'USA';a.BillingCountry = 'USA';
        acc1.ShippingCity = 'California';a.BillingCity = 'California';
        acc1.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        acc1.Organization_Type__c = 'Law Firm';
        acc1.Firm_Email__c = 'sbender@brirllp.com';
        acc1.Evergreen_Contract_Status__c = 'NA';
        acclist.add(acc1);
        
        insert acclist;        
        //creating currency
        invoiceit_s__Currency__c currencyobj = testutil.getCurrencyObject();
        
        List<invoiceit_s__Job__c> orderlist = new List<invoiceit_s__Job__c>();
        
        //creating order
        invoiceit_s__Job__c order   = testutil.getOrder(acclist[0].Id, currencyobj.Id);
        order.invoiceit_s__Status__c = 'Active';
        orderlist.add(order);
        system.debug('@@@@order in test class'+ order);
        
        //creating order
        invoiceit_s__Job__c order1   = testutil.getOrder(acclist[1].Id, currencyobj.Id);
        order1.invoiceit_s__Status__c = 'In Progress';
        orderlist.add(order1);
        
        system.debug('@@@frome test class');
        system.debug('@@@orderlist'+ orderlist);
        update orderlist;
        system.debug('@@@orderlist after'+ orderlist);
        
    }

}