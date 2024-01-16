//Author                : sai
//Description           : Test class for orderStatusHandlingOnAccount



@isTest(seeAllData= true)
public class orderStatusHandlingOnAccountTest {
    static testmethod void run2condition(){
        
        
        MDL_UtilClass_TestClass utilclass = new MDL_UtilClass_TestClass();
        
        //creating a new account
        account acc = new account();
        acc.Name = 'testAc'; 
        acc.Phone='122-34345-654';
        acc.invoiceit_s__Preferred_Billing_Day__c = '1';
        acc.Type = 'Customer';
        acc.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        acc.ShippingStreet = '111 Train Ave';
        acc.BillingStreet = '111 Train Ave';
        acc.BillingState = 'NY';
        acc.ShippingState = 'NY';
        acc.ShippingPostalCode = '12356-2343'; acc.BillingPostalCode = '12356-2343';
        acc.ShippingLongitude = 12;acc.BillingLongitude = 12;
        acc.ShippingLatitude = 10 ;acc.BillingLatitude = 10;
        acc.ShippingCountry = 'USA';acc.BillingCountry = 'USA';
        acc.ShippingCity = 'California';acc.BillingCity = 'California';
        acc.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        acc.Organization_Type__c = 'Corporation';
        acc.Firm_Email__c = 'sbender@brirllp.com';
        acc.Evergreen_Contract_Status__c = 'NA';
        acc.Order_Status__c  = 'Active';
        insert acc;
        
        
        
        acc.Order_Status__c = 'InActive';
        update acc;
        
        
        
        
        acc.Order_Status__c        = 'Active';
        acc.Loss_Date__c           = date.today();
        acc.Acquisition_date__c    = date.today();
        acc.Re_acquisition_date__c = date.today();
        update acc;
        
        acc.Order_Status__c = 'Expired';
        update acc;
        
        acc.Order_Status__c        = 'Active';
        acc.Loss_Date__c           = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        acc.Acquisition_date__c    = date.newInstance(date.today().year()-1, date.today().month(), date.today().day());
        acc.Re_acquisition_date__c = date.newInstance(date.today().year(), date.today().month(), date.today().day());
        system.debug('@@@@Order_Status__c'+ acc.Order_Status__c);
        system.debug('acc.Loss_Date__c in test'+ acc.Loss_Date__c );
        system.debug('acc.Acquisition_date__c in test'+ acc.Acquisition_date__c );
        system.debug('acc.Re_acquisition_date__c in test'+ acc.Re_acquisition_date__c );
        update acc;
        
        
        acc.Order_Status__c = 'Expired';
        update acc;
        
        acc.Order_Status__c        = 'Active';
        acc.Loss_Date__c           = date.newInstance(date.today().year()+1, date.today().month(), date.today().day());
        acc.Acquisition_date__c    = date.newInstance(date.today().year()-1, date.today().month(), date.today().day());
        acc.Re_acquisition_date__c = date.newInstance(date.today().year()+1, date.today().month(), date.today().day());
        update acc;
        
        acc.Order_Status__c        = 'Expired';
        acc.Customer_Status__c     = 'Former Sub';
        acc.Loss_Date__c           = date.newInstance(date.today().year()+1, date.today().month(), date.today().day());
        acc.Acquisition_date__c    = date.newInstance(date.today().year()-1, date.today().month(), date.today().day());
        acc.Re_acquisition_date__c = date.newInstance(date.today().year()+1, date.today().month(), date.today().day());
        update acc;
        
         // New Fields Update on Account when opty closed won 
          MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();   
        Account acc4 = util.getAccount();  
        acc4.Business_Unit__c = 'Pending Migration';
        acc4.Legal_Entity__c = 'MH Taxable';
        update acc4;
        Account acc5 = util.getAccount();  
        acc5.Business_Unit__c = 'Pending Migration';
        acc5.Legal_Entity__c = 'MH Non-Taxable';
        update acc5;
        invoiceit_s__Currency__c cur = util.getCurrencyObject();
        Date invoiceDate = date.newInstance(date.today().year(), date.today().month(), 01);
        invoiceit_s__Invoice__c inv = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
                                                    invoiceit_s__Invoice_Status__c='Posted'
                                                    );
        insert inv;
        invoiceit_s__Invoice__c inv2 = new invoiceit_s__Invoice__c(
                                                    invoiceit_s__Account__c=acc5.Id,
                                                    invoiceit_s__Invoice_Date__c=invoiceDate,invoiceit_s__Due_Date__c = invoiceDate.addMonths(1),
                                                    invoiceit_s__Invoice_Status__c='Posted'
                                                    );
        insert inv2;
        test.starttest();
        
        //creating a new account
        //testing for updatingaccountFieldsOrderStatusActive for MH RecordType
        account acc1 = new account();
        acc1.Name = 'testAc11'; 
        acc1.Phone='122-34345-654';
        acc1.invoiceit_s__Preferred_Billing_Day__c = '1';
        acc1.Type = 'Customer';
        acc1.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        acc1.ShippingStreet = '111 Train Ave';
        acc1.BillingStreet = '111 Train Ave';
        acc1.BillingState = 'NY';
        acc1.ShippingState = 'NY';
        acc1.ShippingPostalCode = '12356-2343'; acc1.BillingPostalCode = '12356-2343';
        acc1.ShippingLongitude = 12;acc1.BillingLongitude = 12;
        acc1.ShippingLatitude = 10 ;acc1.BillingLatitude = 10;
        acc1.ShippingCountry = 'USA';acc1.BillingCountry = 'USA';
        acc1.ShippingCity = 'California';acc1.BillingCity = 'California';
        acc1.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        acc1.Organization_Type__c = 'Corporation';
        acc1.Firm_Email__c = 'sbender@brirllp.com';
        acc1.Evergreen_Contract_Status__c = 'NA';
        acc1.Order_Status__c  = 'Expired';
        insert acc1;
        
        //creating contact
        contact con = utilclass.getContact(acc1.Id);
        
        opportunity opp = utilclass.getOpportunity(acc1.Id, con.Id, cur.id);
        
       invoiceit_s__Product__c product = utilClass.getProduct('test');
        
        invoiceit_crmx__Opportunity_Product__c oppProduct = utilclass.getOpportunityProduct(Product.Id, opp.Id);
        
        opp.StageName              = 'Closed Won';
        opp.Reason_Won_Lost__c     = 'test';
        opp.Reason_for_Discount__c = 'test';
        opp.Discoint_Approved__c   = 'Discount Approved';
        update opp;
        
        acc1.Order_Status__c = 'Active';
        system.debug('@@@@testing for this');
        update acc1;
        
        Id noloaccRecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Account).getRecordTypeId();
        
        //creating a new account
        //testing for updatingaccountFieldsOrderStatusActive for NOLO RecordType
        account acc2 = new account();
        acc2.Name = 'testAc123'; 
        acc2.Phone='122-34345-654';
        acc2.invoiceit_s__Preferred_Billing_Day__c = '1';
        acc2.Type = 'Customer';
        acc2.invoiceit_s__Invoice_Delivery_Type__c = 'Email';
        acc2.ShippingStreet = '111 Train Ave';
        acc2.BillingStreet = '111 Train Ave';
        acc2.BillingState = 'NY';
        acc2.ShippingState = 'NY';
        acc2.ShippingPostalCode = '12356-2343'; acc2.BillingPostalCode = '12356-2343';
        acc2.ShippingLongitude = 12;acc2.BillingLongitude = 12;
        acc2.ShippingLatitude = 10 ;acc2.BillingLatitude = 10;
        acc2.ShippingCountry = 'USA';acc2.BillingCountry = 'USA';
        acc2.ShippingCity = 'California';acc2.BillingCity = 'California';
        acc2.Primary_Contact__c = 'venkatesan.mu@listertechnologies.com';
        acc2.Organization_Type__c = 'Corporation';
        acc2.Firm_Email__c = 'sbender@brirllp.com';
        acc2.Evergreen_Contract_Status__c = 'NA';
        acc2.Order_Status__c  = 'Expired';
        acc2.RecordTypeId     = noloaccRecordTypeId;
        insert acc2;
        
        //creating contact
        contact con1 = utilclass.getContact(acc2.Id);
        Id nolooppRecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Opportunity).getRecordTypeId();
        Id mhoppRecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_JV_Opportunity).getRecordTypeId();
       
        List<opportunity> opplist = new List<opportunity>();
        opportunity opp1 = new Opportunity(Name = 'TestOpp', AccountId = acc2.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con1.Id ,
                invoiceit_crmx__CurrencyL__c = cur.Id , invoiceit_crmx__Shipping_Contact__c = con1.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 20 , Type = 'New Business',
                Discount__c = 18,RecordtypeId=nolooppRecordTypeId
        );
       opplist.add(opp1);
        
         opportunity opp2 = new Opportunity(Name = 'TestOpp', AccountId = acc2.Id, Amount = 123,                                                      
                CloseDate = system.today(), StageName = 'Qualification' , Probability = 10 ,
                ForecastCategoryName = 'Amount is required' , invoiceit_crmx__Billing_Contact__c = con1.Id ,
                invoiceit_crmx__CurrencyL__c = cur.Id , invoiceit_crmx__Shipping_Contact__c = con1.Id,
                invoiceit_crmx__VAT__c = 0,invoiceit_crmx__Total__c = 123 , invoiceit_crmx__Total_Profit__c = 123 ,
                invoiceit_crmx__Total_Cost__c = 0 , invoiceit_crmx__Total_Contract_Value__c = 300 , 
                invoiceit_crmx__TotalProfitPercent__c = 100 , invoiceit_crmx__Sub_Total__c = 100 ,
                invoiceit_crmx__Recalculate__c = false , invoiceit_crmx__Number_Of_Terms__c = 12 ,
                invoiceit_crmx__Net_Total__c = 123 , invoiceit_crmx__Do_Not_Create_Automatic_Order__c = false ,
                invoiceit_crmx__Discount_Value__c = 24 , invoiceit_crmx__Discount_Percent__c = 20 , Type = 'New Business',
                Discount__c = 18,RecordtypeId=mhoppRecordTypeId
        );
       
        opplist.add(opp2);
        insert opplist;
        
       invoiceit_s__Product__c product1 = utilClass.getProduct('test');
        
        invoiceit_crmx__Opportunity_Product__c oppProduct1 = utilclass.getOpportunityProduct(Product1.Id, opp1.Id);
         invoiceit_crmx__Opportunity_Product__c oppProduct2 = utilclass.getOpportunityProduct(Product1.Id, opp2.Id);
        
        opp1.StageName              = 'Closed Won';
        opp1.Reason_Won_Lost__c     = 'test';
        opp1.Reason_for_Discount__c = 'test';
        opp1.Discoint_Approved__c   = 'Discount Approved';
         opp2.StageName              = 'Closed Won';
        opp2.Reason_Won_Lost__c     = 'test';
        opp2.Reason_for_Discount__c = 'test';
        opp2.Discoint_Approved__c   = 'Discount Approved';
        
        
        update opplist;
        
        acc2.Order_Status__c = 'Active';
        system.debug('@@@@testing for this');
        update acc2;
        
        Test.stoptest();
        
    }

}