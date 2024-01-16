@isTest(seealldata=true)
private class TestRunSchedulerInvoiceIT {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        Account accountObj = new Account(Name='Account');
        insert accountObj;
        Date validtodate = Date.today();
        Contact contact = new Contact(lastname = 'testCon1',AccountId=accountObj.Id);
        insert contact;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj;
        
        invoiceit_s__Product__c product = new invoiceit_s__Product__c(Name = 'Test Product for tiers',invoiceit_s__Valid_From_Date__c = validtodate-1,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product');
        insert product;
        list<invoiceit_s__Product_Rate_Plan__c> listProductRatePlans = new list<invoiceit_s__Product_Rate_Plan__c>();
        invoiceit_s__Product_Rate_Plan__c productRatePlan;
        for(Integer x = 0;x< 2;x++){
            productRatePlan = new  invoiceit_s__Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,invoiceit_s__Product__c = product.Id,invoiceit_s__Valid_From_Date__c = validtodate,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2));
            listProductRatePlans.add(productRatePlan);
        }
        insert listProductRatePlans;
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                              invoiceit_s__Unit_price__c = 1000,
                                                              invoiceit_s__Cost_Price__c = 500,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              
                                                              invoiceit_s__Price_Type__c = 'One Time'
                                                              );
        listProductRatePlanCharges.add(productRatePlanCharge_SetUp);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj.ID,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                              invoiceit_s__Unit_price__c = 500,
                                                              invoiceit_s__Cost_Price__c = 250,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'Monthly'
                                                              );                                                       
        listProductRatePlanCharges.add(productRatePlanCharge_Monthly);
        insert listProductRatePlanCharges;
        invoiceit_s__Job__c orderObj = new invoiceit_s__Job__c(Name = 'TestHappyOrNot',invoiceit_s__Account__c=accountObj.Id,invoiceit_s__CurrencyL__c=currencyObj.Id,invoiceit_s__Partner__c=accountObj.Id,invoiceit_s__Billing_Contact__c=contact.id);
        insert orderObj;
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = orderObj.Id);
         insert jobProduct;

         invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
         insert jobRP;

         invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge_Monthly.id, invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Status__c = 'Ready to be Invoiced',invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Charge_Date__c = system.today(),invoiceit_s__Unit_Price__c = 12);
         insert charge;
         
         invoiceit_s__Invoice__c invoice12 = new invoiceit_s__Invoice__c(invoiceit_s__Account__c = accountObj.id,invoiceit_s__Order__c =orderObj.Id ,invoiceit_s__Billing_Contact__c = contact.Id, invoiceit_s__Shipping_Contact__c = contact.Id,
          invoiceit_s__CurrencyL__c = currencyObj.Id, invoiceit_s__Target_Date__c = Date.today(), invoiceit_s__Invoice_Status__c = 'Posted'
          ,invoiceit_s__Invoice_Date__c = System.today(),invoiceit_s__Invoice_State__c= 'Test' ,  invoiceit_s__Unpost_Reason__c = 'Test', invoiceit_s__Email_Sent__c = true 
        );
        insert invoice12;

        list<invoiceit_s__Invoice_Lines__c> listInvoiceLinestoinsert = new list<invoiceit_s__Invoice_Lines__c>();
        list<invoiceit_s__Invoice_Lines__c> listInvoiceLinestoupdate = new list<invoiceit_s__Invoice_Lines__c>();
        listInvoiceLinestoinsert.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Invoice__c = invoice12.id,invoiceit_s__Job_Rate_Plan_Charge__c=charge.Id ,invoiceit_s__Discount_Value__c =10,invoiceit_s__Line_Name__c = 'Broadband Installation For L',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__VAT__c = 8.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = orderObj.Id, invoiceit_s__Status__c='Active'));
        listInvoiceLinestoinsert.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Invoice__c = invoice12.id,invoiceit_s__Job_Rate_Plan_Charge__c=charge.Id ,invoiceit_s__Discount_Value__c =10,invoiceit_s__Line_Name__c = 'Broadband Installation For X',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__Tax__c= 25.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = orderObj.Id, invoiceit_s__Status__c='Active'));
        
        insert listInvoiceLinestoinsert;
        
        
        
        
      Test.startTest(); 
      RunSchedulerInvoiceIT  batch=new RunSchedulerInvoiceIT();
      string cron = '20 30 8 10 2 ?';
      string scheduleId=system.schedule('Name', cron, batch);
      invoiceit_s__Invoice_RunScheduler__c obj1=new invoiceit_s__Invoice_RunScheduler__c(invoiceit_s__JobId__c= scheduleId, invoiceit_s__Invoice_Date__c = System.today(), Name='Test Scheduler',invoiceit_s__Invoice_Currency__c=currencyObj.Id);
      insert obj1;
      
      //Database.executeBatch(batch);
      Test.stopTest();
   }
        static testMethod void myUnitTest3() {
        // TO DO: implement unit test
        
        Account accountObj = new Account(Name='Account');
        insert accountObj;
        Date validtodate = Date.today();
        Contact contact = new Contact(lastname = 'testCon1',AccountId=accountObj.Id);
        insert contact;
        
        invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(invoiceit_s__Currency_Symbol__c='USD');
        insert currencyObj;
        
        invoiceit_s__Product__c product = new invoiceit_s__Product__c(Name = 'Test Product for tiers',invoiceit_s__Valid_From_Date__c = validtodate-1,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2),invoiceit_s__Product_Family__c = 'Default',invoiceit_s__Product_Code__c = 'Code1',invoiceit_s__Description__c = 'Product');
        insert product;
        list<invoiceit_s__Product_Rate_Plan__c> listProductRatePlans = new list<invoiceit_s__Product_Rate_Plan__c>();
        invoiceit_s__Product_Rate_Plan__c productRatePlan;
        for(Integer x = 0;x< 2;x++){
            productRatePlan = new  invoiceit_s__Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,invoiceit_s__Product__c = product.Id,invoiceit_s__Valid_From_Date__c = validtodate,invoiceit_s__Valid_To_Date__c = validtodate.addMonths(2));
            listProductRatePlans.add(productRatePlan);
        }
        insert listProductRatePlans;
        list<invoiceit_s__Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<invoiceit_s__Product_Rate_Plan_Charge__c>();
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj.Id,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                              invoiceit_s__Unit_price__c = 1000,
                                                              invoiceit_s__Cost_Price__c = 500,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              
                                                              invoiceit_s__Price_Type__c = 'One Time'
                                                              );
        listProductRatePlanCharges.add(productRatePlanCharge_SetUp);
        
        invoiceit_s__Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly = new invoiceit_s__Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                              invoiceit_s__CurrencyL__c = currencyObj.ID,
                                                              invoiceit_s__Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                              invoiceit_s__Unit_price__c = 500,
                                                              invoiceit_s__Cost_Price__c = 250,
                                                              invoiceit_s__Product_Charge_Category__c = 'Taxable',
                                                              invoiceit_s__Price_Type__c = 'Monthly'
                                                              );                                                       
        listProductRatePlanCharges.add(productRatePlanCharge_Monthly);
        insert listProductRatePlanCharges;
        invoiceit_s__Job__c orderObj = new invoiceit_s__Job__c(Name = 'TestHappyOrNot',invoiceit_s__Account__c=accountObj.Id,invoiceit_s__CurrencyL__c=currencyObj.Id,invoiceit_s__Billing_Contact__c=contact.id);
        insert orderObj;
        invoiceit_s__Job_Product__c  jobProduct= new invoiceit_s__Job_Product__c(Name = 'jobProduct',invoiceit_s__Job__c = orderObj.Id);
         insert jobProduct;

         invoiceit_s__Job_Rate_Plan__c jobRP = new invoiceit_s__Job_Rate_Plan__c(Name = 'JobRP',invoiceit_s__Job_Product__c =jobProduct.Id);
         insert jobRP;

         invoiceit_s__Job_Rate_Plan_Charge__c charge = new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobRPC',invoiceit_s__Product_Rate_Plan_Charge__c=productRatePlanCharge_Monthly.id, invoiceit_s__Job_Rate_Plan__c =jobRP.Id,invoiceit_s__Status__c = 'Ready to be Invoiced',invoiceit_s__Quantity__c = 12,invoiceit_s__Price_Type__c = 'One Time',invoiceit_s__Charge_Date__c = system.today(),invoiceit_s__Unit_Price__c = 12);
         insert charge;
         
         invoiceit_s__Invoice__c invoice12 = new invoiceit_s__Invoice__c(invoiceit_s__Account__c = accountObj.id,invoiceit_s__Order__c =orderObj.Id ,invoiceit_s__Billing_Contact__c = contact.Id, invoiceit_s__Shipping_Contact__c = contact.Id,
          invoiceit_s__CurrencyL__c = currencyObj.Id, invoiceit_s__Target_Date__c = Date.today(), invoiceit_s__Invoice_Status__c = 'Posted'
          ,invoiceit_s__Invoice_Date__c = System.today(),invoiceit_s__Invoice_State__c= 'Test' ,  invoiceit_s__Unpost_Reason__c = 'Test', invoiceit_s__Email_Sent__c = true 
        );
        insert invoice12;

        list<invoiceit_s__Invoice_Lines__c> listInvoiceLinestoinsert = new list<invoiceit_s__Invoice_Lines__c>();
        list<invoiceit_s__Invoice_Lines__c> listInvoiceLinestoupdate = new list<invoiceit_s__Invoice_Lines__c>();
        listInvoiceLinestoinsert.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Invoice__c = invoice12.id,invoiceit_s__Job_Rate_Plan_Charge__c=charge.Id ,invoiceit_s__Discount_Value__c =10,invoiceit_s__Line_Name__c = 'Broadband Installation For L',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__VAT__c = 8.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = orderObj.Id, invoiceit_s__Status__c='Active'));
        listInvoiceLinestoinsert.add(new invoiceit_s__Invoice_Lines__c(invoiceit_s__Invoice__c = invoice12.id,invoiceit_s__Job_Rate_Plan_Charge__c=charge.Id ,invoiceit_s__Discount_Value__c =10,invoiceit_s__Line_Name__c = 'Broadband Installation For X',invoiceit_s__Quantity__c = 1,invoiceit_s__Unit_Price__c = 40.00,invoiceit_s__Tax__c= 25.00,invoiceit_s__Line_Amount__c = 40.00,invoiceit_s__Job__c = orderObj.Id, invoiceit_s__Status__c='Active'));
        
        insert listInvoiceLinestoinsert;
        
      Test.startTest(); 
      RunSchedulerInvoiceIT  batch=new RunSchedulerInvoiceIT();
      string cron = '20 30 8 10 2 ?';
      string scheduleId=system.schedule('Name', cron, batch);
      invoiceit_s__Invoice_RunScheduler__c obj1=new invoiceit_s__Invoice_RunScheduler__c(invoiceit_s__JobId__c= scheduleId, Name='Test Scheduler',invoiceit_s__Invoice_Currency__c=currencyObj.Id,invoiceit_s__Type__c='Monthly',invoiceit_s__Invoice_Day_Of_Month__c='3',invoiceit_s__Target_Day_Of_Month__c='2');
      insert obj1;
      
      //Database.executeBatch(batch);
      Test.stopTest();
    }
}