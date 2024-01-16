public with sharing class Cls_UtilTestClass{
    public Profile p;
    public Profile p_admin;
    
    public Cls_UtilTestClass(){
        p = [SELECT Id FROM Profile LIMIT 1];
        p_admin = [SELECT Id FROM Profile WHERE Name='System Administrator'];  
        system.debug('@@@@ p_admin'+ p_admin);
    }
        
    public String randomise(){
        String append = '';
        Integer i = 6;
        while(i > 0){
            append += string.valueOf((Integer)Math.ceil(Math.random()*10));
            i--; 
        }
        return append;
    }
    
    public User getUser(){
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+randomise()+'@testorg.com');
         insert u2;
         
        return u2;     
    }
    
    
    public User getUser_admin(){
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p_admin.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser'+randomise()+'@testorg.com');
         insert u2;
         
        return u2;     
    }
    
    public Account getAccount(){
        Account a = new Account();
        a.Name = 'testAcc' + randomise(); 
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
        a.Organization_Type__c = 'Corporation';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
        User u = getUser();
        a.Collector__c = u.Id;
        insert a;
        
        return a;       
    }
    
    
     public Account getAccount_withoutInsert(){
        Account a = new Account();
        a.Name = 'testAcc' + randomise(); 
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
        a.Organization_Type__c = 'Corporation';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
       
        
        return a;       
    }
    
    
     public Account getAccount_adminuser(){
        Account a = new Account();
        a.Name = 'testAcc' + randomise(); 
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
        a.Organization_Type__c = 'Corporation';
        a.Firm_Email__c = 'sbender@brirllp.com';
        a.Evergreen_Contract_Status__c = 'NA';
        User u = getUser_admin();
        //a.OwnerId = u.id;
        system.debug('@@@@profileid in util'+ u.ProfileId);
        a.Collector__c = u.Id;
        insert a;
        
        return a;       
    }
    
    public Contact getContact(Id accId){
        Contact c = new Contact();
        c.LastName = 'Test Contact' + randomise();
        c.Email = 'testabc@gmail.com';
        c.AccountId = accId;
        insert c;
        
        return c;
    }
    
    
    
     public Opportunity getOpportunity(Id accId,Id conId) {
        Opportunity opp = new Opportunity();
        opp.AccountId = accId;
        opp.ContactId = conId;
        opp.StageName ='Prospecting';
        opp.CloseDate = Date.today();
        opp.Name = 'testOpp';
        
        insert opp;
        
        return opp;
    }
    
    
   
    public Order getOrder(Id accId){
        Order job = new Order();
        job.Name = 'Test Order' + randomise();
        job.AccountId = accId;
        job.Status = 'Draft';
        job.EffectiveDate=system.today();
        
        insert job;
        
        return job;
    }
    
     public blng__Invoice__c getInvoice(Id accId){
        blng__Invoice__c invoice = new blng__Invoice__c();
        invoice.blng__Account__c = accId;    
        invoice.blng__DueDate__c = date.Today().addDays(-90);
        invoice.blng__InvoiceDate__c = date.Today().addDays(-10);
        insert invoice;
        
        return invoice;
    }
    
    public blng__InvoiceLine__c getInvoiceLines(Id inv,Id orderId) {
        blng__InvoiceLine__c invLines = new blng__InvoiceLine__c();
        invLines.blng__Invoice__c = inv;
        //invLines.invoiceit_s__Job__c = orderId;
        invLines.blng__UnitPrice__c = 100.00;
        invLines.blng__TotalAmount__c = 100.00;
        insert invLines;
        
        return invLines;
    }
    
    public blng__Payment__c getPayment(Id accId) {
        blng__Payment__c pay = new blng__Payment__c();
        pay.blng__Account__c = accId;
        pay.blng__Amount__c = 200.00;
        pay.blng__PaymentDate__c = Date.today();
        pay.blng__PaymentType__c = 'ACH';
        pay.blng__Status__c = 'Completed';
        
        insert pay;
        
        return pay;
    }
    
    public blng__PaymentMethod__c getPaymentMethod(Id accId){
        blng__PaymentMethod__c p = new blng__PaymentMethod__c();
        p.blng__Account__c=accId;
        p.blng__AutoPay__c=true;
        p.blng__Nameoncard__c='Murali';
        p.blng__CardNumber__c = string.valueOf(1234567890);
        p.blng__CVV__c = string.valueOf(1234);
        p.blng__BankAccountName__c = string.valueOf(1234567890);
        p.blng__BillingCity__c    = 'alaska';
        p.blng__BillingCountry__c = 'United States';
        p.blng__PaymentType__c = 'Credit Card';
        p.blng__BillingStateProvince__c = 'mexico';
        insert p;
        return p;       
    }
    
     public blng__PaymentMethod__c getPaymentMethodActive(Id accId){
        blng__PaymentMethod__c p = new blng__PaymentMethod__c();
        p.blng__Account__c=accId;
        p.blng__Nameoncard__c='Murali1';
        p.blng__CardNumber__c = string.valueOf(1234567890);
        p.blng__CVV__c = string.valueOf(1234);
        p.blng__BankAccountName__c = string.valueOf(1234567890);
        p.blng__BillingCity__c    = 'alaska';
        p.blng__BillingCountry__c = 'United States';
        p.blng__BillingStateProvince__c = 'mexico';
        p.blng__PaymentType__c = 'Credit Card';
        insert p;
        return p;       
    }
    
      public blng__PaymentTransaction__c getTransactionObj(Id payMethId,Id invId,Id PaymentGatewayId){
        blng__PaymentTransaction__c t = new blng__PaymentTransaction__c();
        t.blng__PaymentMethod__c = payMethId;
        t.blng__PaymentGateway__c = PaymentGatewayId;
        t.blng__RequestInvoice__c = invId;
        insert t;
        return t;
    }
    
    public blng__PaymentGateway__c getGateway(){
        blng__PaymentGateway__c g = new blng__PaymentGateway__c();
        g.Name = 'Autorize.net Sample';
        g.blng__GatewayType__c = 'AuthorizeDotNet';
        g.TestMode__c = true;
        g.blng__Active__c = true;
        insert g;
        return g;
    }
    
    public Product2 getProduct(Boolean isInventorable){
        Product2 product = new  Product2(Name = 'Test Product' + randomise(),
                //invoiceit_s__Valid_From_Date__c = Date.today(),
               // invoiceit_s__Valid_To_Date__c = Date.today()+90,
                Family = 'Default',
                ProductCode = '1234',
                Description = 'Product',
                IsInventoried__c = isInventorable
        );
        insert product;
        
        return product; 
    }
    
    
    }