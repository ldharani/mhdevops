@isTest(seeAllData=true)
public class DocusignTriggerHandlertest {

    static testMethod void myUnitTest() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
       Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    
        Account a = testData.getAccount();    
        Contact c = testData.getContact(a.Id);      
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();    
    
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
    
      //creating product 
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        
        Product2 prod = new Product2(Name='Martindale-Avvo Complete Profile Plus',ProductCode='NgProd',Family='Ngage',IsActive=true,
               SBQQ__ChargeType__c='Recurring',SBQQ__ConfigurationEvent__c='Always',SBQQ__BillingFrequency__c='Monthly',
               SBQQ__BillingType__c = 'Advance',SBQQ__SubscriptionTerm__c = 1,
               SBQQ__NonDiscountable__c=true,SBQQ__PricingMethod__c='List',SBQQ__QuantityEditable__c=false,
               SBQQ__SubscriptionType__c='Renewable',SBQQ__PriceEditable__c=false,
               blng__BillingRule__c=objBR.ID,blng__RevenueRecognitionRule__c=objRR.ID,blng__TaxRule__c=objTR.ID,IsInventoried__c = true);
        insert prod;      
        
        PriceBookEntry pbE = new PriceBookEntry();
        pbE.Product2Id = prod.Id;
        pbE.PriceBook2Id = Test.getStandardPricebookId();
        //pbE.StandardPrice = 0;
        pbE.UnitPrice = 0;
        pbE.IsActive = true;
        pbE.UseStandardPrice = false;
        insert pbE; 
    
      Opportunity opportunity1 = new Opportunity(Name = 'TestOpp', AccountId = a.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 , 
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = c.Id ,
                invoiceit_crmx__CurrencyL__c = currencyObj.Id , invoiceit_crmx__Shipping_Contact__c = c.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 , 
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,IsVoidable__c = false,                                                   
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                Marketing_Contact__c = c.id,Auth_By_Contact__c = c.id,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 10 , Type = 'New Business',
                Discount__c = 18 
        );
        insert opportunity1;   
        
   
    
    invoiceit_s__Product_Rate_Plan__c productRatePlan = testData.getProductRatePlan(product.Id);    
    invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge = testData.getProductRatePlanCharge(currencyObj.Id, productRatePlan.Id);    
    Opportunity opportunity = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);    
   
    invoiceit_crmx__Opportunity_Product__c  oppProduct= new invoiceit_crmx__Opportunity_Product__c(Name = 'Opp Product',
                                                                                                       invoiceit_crmx__Product_Code__c = '1234', 
                                                                                                       invoiceit_crmx__Product__c = product.id ,
                                                                                                       invoiceit_crmx__Opportunity__c = opportunity1.id,
                                                                                                       InventoryId__c = '12345xyz',
                                                                                                       Pend_Date__c = date.today() - 10);
        insert oppProduct;
        
        
         Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
           SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Account__c = a.id;
            objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
            objQuote.RecordtypeId = quoteRecordTypeId; 
            objQuote.SBQQ__Opportunity2__c = opportunity1.id;
            objQuote.SBQQ__StartDate__c = system.today();
            objQuote.SBQQ__EndDate__c = system.today().adddays(30);
            objQuote.SBQQ__SubscriptionTerm__c = 12;
            objQuote.SBQQ__Primary__c = True;
            objQuote.SBQQ__Status__c = 'Approved';
            objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
            objQuote.SBQQ__BillingFrequency__c = 'Monthly'; 
        insert objQuote;
        
        Test.starttest();
        objQuote.Marketing_Contact__c = c.Id;
        objQuote.SBQQ__PrimaryContact__c = c.Id;
        objQuote.Billing_Contact__c = c.Id;
        Update objQuote;
        
        
        
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = objQuote.Id;
        ql.SBQQ__Product__c = prod.Id;
        ql.SBQQ__PricebookEntryId__c = pbE.Id;
        ql.SBQQ__ChargeType__c = 'Recurring';
        ql.SBQQ__SubscriptionTerm__c = 1;
        ql.SBQQ__SubscriptionType__c = 'Evergreen';
        ql.SBQQ__ProductSubscriptionType__c = 'Evergreen';
        ql.SBQQ__BillingType__c = 'Advance';
        ql.SFInventoryId__c = '1234';
        insert ql; 
        
        
        //Creating Docusign doc
        
        dsfs__DocuSign_Status__c docusign = new dsfs__DocuSign_Status__c( dsfs__DocuSign_Envelope_ID__c ='D367ED52',dsfs__Sent_Date_Time__c = System.now() ,
                                                    dsfs__Sender_Email__c ='test@gmail.com', dsfs__Subject__c = 'Your Martindale-Hubbell Agreement : Mannarino' ,
                                                    dsfs__Envelope_Status__c = 'Sent',dsfs__Opportunity__c = opportunity1.id,Quote__c = objQuote.Id );
                                                    
         insert  docusign;
        
        Test.stopTest();
       
        
        
        
        opportunity1.Docusign_Expiration_date__c = date.TODAY();
        update opportunity1 ;
        
        docusign.dsfs__Envelope_Status__c = 'Completed';
        update docusign;
        
        
        
        
    }
}