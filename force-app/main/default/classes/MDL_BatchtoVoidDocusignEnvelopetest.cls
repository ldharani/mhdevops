@isTest(seeAllData=true)
public class MDL_BatchtoVoidDocusignEnvelopetest {

    static testMethod void myUnitTest() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
        Account a = testData.getAccount();    
        Contact c = testData.getContact(a.Id);      
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();    
    
    
      //creating product
      invoiceit_s__Product__c product = testData.getProduct('Yes');   
    
      Opportunity opportunity1 = new Opportunity(Name = 'TestOpp', AccountId = a.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = c.Id ,
                invoiceit_crmx__CurrencyL__c = currencyObj.Id , invoiceit_crmx__Shipping_Contact__c = c.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,Docusign_Expiration_date__c = date.TODAY(), 
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,IsVoidable__c = false,                                                   
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
                Discount__c = 18 
        );
        insert opportunity1;   
        
        //creating opportunity product
        invoiceit_crmx__Opportunity_Product__c oppProduct = testData.getOpportunityProduct(Product.Id, opportunity1.id);
        
        Test.starttest();
        //MDL_ScheduleOppProductsExpiryopty m1 = new MDL_ScheduleOppProductsExpiryopty ();
        //String sch = '0 0 13 * * ?';
        
        //system.schedule('Test check', sch, m1);
         Database.executeBatch(new MDL_BatchtoVoidDocusignEnvelope (), 10);
        MDL_BatchtoVoidDocusignEnvelope m = new MDL_BatchtoVoidDocusignEnvelope();
        Database.executeBatch(m);
        Test.stopTest();
        
        
    }
}