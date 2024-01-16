/*Test Class On InvoiceSummaryActPDF
*/
@isTest
public class CPQ_Invoice_Templatetest{
    
   /* static testmethod void run2condition_Nolo(){
        
        Integration_Endpoints__c i =new Integration_Endpoints__c();
       i.NAme ='OrderRequest';
       i.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/efs/v2/handleSalesForceXml';
       i.MethodType__c = 'POST';
       i.xmlns__c = 'http://svcs.martindale.com/MHIntegration/OrderRequest/v1.00';
       i.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
       i.Endpoint_URL_for_authentication__c = 'svcs.martindale.com/mhintegration/order';
       i.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
       i.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
       insert i;
        
        Restrict_Integration_Calls__c r = new Restrict_Integration_Calls__c();
        r.Name = 'Restrict';
        r.Restrict_Callouts__c = true;
        insert r;

         MDL_UtilClass_TestClass util= new MDL_UtilClass_TestClass();
        
         
        
        //creating account
        account acc = new account();
        acc = util.getAccount();
        
        //creating single contact
        contact con = new contact();
        con = util.getContact(acc.Id);
        
        blng__RevenueRecognitionRule__c objRR = new blng__RevenueRecognitionRule__c();
        objRR.Name = 'Test';
        objRR.blng__Active__c = TRUE;
        objRR.blng__CreateRevenueSchedule__c= 'Yes';
        objRR.blng__Notes__c = 'Test';
        insert objRR;
        
        blng__TaxRule__c objTR = new blng__TaxRule__c();
        objTR.Name = 'Test';
        objTR.blng__Active__c = TRUE;
        objTR.blng__TaxableYesNo__c = 'No';
        objTR.blng__Notes__c = 'Test';
        insert objTR;
        
          
        
        
        blng__BillingRule__c objBR = new blng__BillingRule__c();
        objBR.Name = 'Test';
        objBR.blng__Active__c = TRUE;
        objBR.blng__AmendmentBillCycleDateAlignment__c = 'Do not align amended Order Product';
        objBR.blng__GenerateInvoices__c = 'Yes';
        objBR.blng__InitialBillingTrigger__c = 'Order Product Activation Date ';
        objBR.blng__Notes__c = 'Test';
        objBR.blng__PartialPeriodTreatment__c = 'Separate';
        insert objBR;
        
        List<Product2> prodList = new List<Product2>();
        Product2 objProd = new Product2();
            objProd.Name = 'Test Prod';
            objProd.Productcode = '12345';
            objProd.IsActive = true;
            objProd.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            objProd.SBQQ__SubscriptionTerm__c = 12;
            // objProd.SBQQ__SubscriptionType__c = 'Evergreen';
            objProd.SBQQ__SubscriptionType__c = 'Renewable';
            objProd.SBQQ__ChargeType__c = 'Recurring';
            objProd.SBQQ__BillingFrequency__c = 'Monthly';
            objProd.SBQQ__BillingType__c = 'Arrears';
            objProd.SBQQ__PricingMethod__c = 'List';
            objProd.blng__BillingRule__c = objBR.Id;
            objProd.blng__RevenueRecognitionRule__c = objRR.Id;
            objProd.blng__TaxRule__c = objTR.Id; 
            prodList.add(objProd);
        
        
       // insert prodList; 
        
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id = Test.getStandardPricebookId();
        objPBEntry.Product2Id = objProd.Id;
        objPBEntry.UnitPrice = 20;
        objPBEntry.IsActive = true;        
        insert objPBEntry;   
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:,';
        insert objAR; 
        
         Attribute_Lines__c objAL = new Attribute_Lines__c();
        objAL.Attribute_Junction__c = objAR.Id;
        objAL.Attribute_Name__c = 'AOP';
        objAL.Attribute_Type__c = 'String';
        objAL.String_Value__c = 'Administrative';
       // objAL.Multi_Select_Value__c = strMSValue;
        insert objAL;
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        Id InvRecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('M-A Intake Invoice').getRecordTypeId();
       
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = acc.id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        insert objOrder;
        
        OrderItem objOI = new OrderItem();
        objOI.OrderId = objOrder.id;
        objOI.Quantity = 24;
        objOI.UnitPrice = 240;
        objOI.Product2id = objProd.Id;
        objOI.PricebookEntryId=objPBEntry.id;
        objOI.SBQQ__ChargeType__c = 'Recurring';
        objOI.SBQQ__BillingFrequency__c = 'Monthly';
        objOI.SBQQ__BillingType__c = 'Arrears';
        objOI.blng__BillingRule__c = objBR.Id;
        objOI.blng__RevenueRecognitionRule__c = objRR.Id;
        objOI.blng__BillableUnitPrice__c = 200;
        objOI.SBQQ__Activated__c = TRUE;
        objOI.blng__TaxRule__c = objTR.Id;
        objOI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objOI.Attribute_Relationship__c = objAR.Id;        
        objOI.UnitPrice = 10;
        objOI.ServiceDate = Date.today();
        //insert objOI;
       
        SBQQ__OrderItemConsumptionSchedule__c objOICS = new SBQQ__OrderItemConsumptionSchedule__c();
        objOICS.SBQQ__BillingTermUnit__c = 'Month';
        objOICS.SBQQ__BillingTerm__c = 1;
        objOICS.SBQQ__Category__c = 'Rates';
        objOICS.SBQQ__RatingMethod__c = 'Tier';
        objOICS.SBQQ__Type__c = 'Range';
        objOICS.SBQQ__OrderItem__c = objOI.Id;
        insert objOICS;
        
        objOICS = [SELECT Id FROM SBQQ__OrderItemConsumptionSchedule__c LIMIT 1];
        
        
        blng__UsageSummary__c objUSummary = DataFactory.createUsageSummary(acc, objOrder, objOI);
        objUSummary.blng__OrderItemConsumptionSchedule__c = objOICS.Id;
        objUSummary.blng__MatchingId__c = '123';
        update objUSummary;
        
        objUSummary = [SELECT Id, blng__MatchingId__c, blng__UnitOfMeasure__c , blng__MatchingAttribute__c FROM blng__UsageSummary__c LIMIT 1];

        
        blng__Usage__c objUsage = new blng__Usage__c();
        objUsage.blng__Account__c = acc.Id;
        objUsage.blng__Order__c = objOrder.Id;
        objUsage.blng__OrderProduct__c = objOI.Id;
        objUsage.blng__UsageSummary__c = objUSummary.Id;
       objUsage.blng__MatchingId__c = objUSummary.blng__MatchingId__c;
        objUsage.blng__MatchingAttribute__c = 'Quarterly';
        objUsage.blng__UnitOfMeasure__c = 'Hours';
        objUsage.Lead_Id__c = '1234';
        objUsage.blng__Quantity__c = 1;
        objUsage.blng__Subtotal__c = 0;
        objUsage.blng__UnitPrice__c = 0;
        objUsage.First_name__c = 'Test Fname';
        objUsage.Last_name__c = 'Test Lname';
        objUsage.Email__c = 'test@test.com';
        objUsage.blng__StartDateTime__c = system.now();
        objUsage.blng__EndDateTime__c = system.now();
        objUsage.blng__Status__c = 'New';
        objUsage.blng__PreratedQuantity__c = 0;
        objUsage.blng__PreratedAmount__c = 0;
        objUsage.blng__ProcessingDate__c = system.today();
       // insert objUsage;
        
        
        //creating invoice
        blng__Invoice__c  singleInv = new blng__Invoice__c ();
        
        singleInv.blng__Account__c= acc.id;    
        singleInv.blng__DueDate__c = date.Today().addDays(-90);
        singleInv.RecordtypeId = InvRecordTypeId ;
        singleInv.blng__InvoiceDate__c = date.Today().addDays(-10);
        insert singleInv ;
        
        //singleInv = util.getInvoice(acc.Id);
        singleInv.blng__BillToContact__c    = con.id;
        singleInv.blng__TargetDate__c= date.today();
        singleInv.Delivery_Type__c= 'Email';
        singleInv.blng__InvoiceDate__c = date.newInstance(2016, 01, 01);
        update singleInv; 
        
        
         //creating invoice line
        Id InvlineRecordTypeId = Schema.SObjectType.blng__InvoiceLine__c.getRecordTypeInfosByName().get('M-A Intake Invoice Line').getRecordTypeId();
        blng__InvoiceLine__c singleinvline = new blng__InvoiceLine__c ();
        //changes by vishnu
        //singleinvline.Name='sampleInvoiceLine';
        singleinvline.blng__Invoice__c = singleInv.id;
        singleinvline.blng__OrderProduct__c = objOI.id;
        singleinvline.RecordtypeId = InvlineRecordTypeId ;
        singleinvline.blng__StartDate__c = date.today();
        singleinvline.blng__EndDate__c = date.Today().addDays(-90);
        singleinvline.blng__UnitPrice__c = 100.00;
        singleinvline.blng__Quantity__c = 1;
        singleinvline.blng__TotalAmount__c = 100.00;
        //singleinvline.blng__OrderProduct__r.Usage_List_Price__c = 12;
        insert singleinvline;
       
       
         ApexPages.currentPage().getParameters().put('id',singleInv.id );
        CPQ_Invoice_Template classcalling = new CPQ_Invoice_Template();
        
        //blng__Order__c,First_name__c, Last_name__c,blng__OrderProduct__c,blng__OrderProduct__r.Product2Id FROM 
        //blng__Usage__c where blng__OrderProduct__c = :orderProductIds ];
		
        blng__Usage__c item= new blng__Usage__c();
		
        item.First_name__c='sample';
        item.Last_name__c='last';
        item.blng__OrderProduct__c = singleinvline.blng__OrderProduct__c;
       // item.blng__Account__c=acc.id;
        //insert item;
        
        
  
        
        
        CPQ_Invoice_Template.InvoiceLineWrapper itemTest = new  CPQ_Invoice_Template.InvoiceLineWrapper();
        /*itemTest.startDate = date.today();
		itemTest.endDate = date.Today().addDays(-90);
        itemTest.Name = 'SampleName';
        itemTest.description = 'Sampledescription';
        itemTest.quantity = 50;
        itemtest.unitPrice = 10;
        itemtest.totalPrice=100;
        itemtest.aopDescription='Sampledescription';*/
       
            //blng__InvoiceLine__c
       /* map<string,Double> mapofinvline = new map<string,Double>();
         mapofinvline = classcalling.listInv();
        //calling all getter methods
       // date stdate      = classcalling.StartDate; 
        //date edate       = classcalling.EndDate;
        
       // map<string,Integer> listInvLIst = classcalling.listInvLI;
        //classcalling.send();
        //classcalling.cancel();
        classcalling.sInvoiceId=singleInv.id;
        map<string,Double> test =classcalling.listInv ;        
        classcalling.listOfInvLine = new list<blng__InvoiceLine__c >();
        classcalling.listOfInvLineWrapper = new list<CPQ_Invoice_Template.InvoiceLineWrapper>();
        blng__Invoice__c i1=classcalling.Invoice1;
        blng__Invoice__c i2=classcalling.Invoice2;
        
    
        
    }*/
    
   /* public class InvoiceLineWrapperTest {
        
        public InvoiceLineWrapperTest(){}
        public date startDate{get;set;}
        public date endDate{get;set;}
        public String Name {get;set;}
        public String description{get;set;}
        public Decimal quantity{get;set;}
        public Decimal unitPrice{get;set;}
        public Decimal totalPrice{get;set;}
        public set<string> attributerelations{get;set;}
        public String aopDescription{get;set;}
    }*/
    

        
         @testSetup static void setup() {
        // Load Custom settings
        DataFactory.loadCustomSettings();
        
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        // Create Test Opportunity
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
        List<Opportunity> lstOpp = DataFactory.createOpportunity('Test Opp', lstAcc[0], oppRecordTypeId, 1);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create Billing Rule
        blng__BillingRule__c objBR = DataFactory.createBillingRule();
        
        // Create RevenueRecognition Rule
        blng__RevenueRecognitionRule__c objRR = DataFactory.createRevenueRecognitionRule();
        
        // Create blng__TaxRule__c  Rule
        blng__TaxRule__c objTR = DataFactory.createTaxRule();
        
        // Create ConsumptionSchedule 
      /*  ConsumptionSchedule objCS = DataFactory.createConsumptionSchedule(objBR, objRR, objTR);
        
        // Create ConsumptionSchedule 
        ConsumptionRate objCR = DataFactory.creatConsumptionRate(objCS);
        
        objCS.IsActive = TRUE;
        update objCS;*/
        
        // Create Test Product
        List<Product2> lstProd = DataFactory.createProduct('Test Product', objBR, objRR, objTR, 1);
        
        // Creaet Test Product Consumption Schedule
       // ProductConsumptionSchedule objPCS = DataFactory.creatProductConsumptionSchedule(objCS, lstProd[0]);
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        
        // Create Attribute_Lines__c - Service State
        Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'AOP', 'String', '', 'Administrative law');
        
        // Create Attribute_Lines__c - Practice Area
       /* Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'AOP', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      */
      
        // Create Test Attribute Configuration - Practice Area
       /* Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, lstProd[0], 'String');
        
        
        // Create Test Attribute Configuration - Service State
        Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
        ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, lstProd[0], 'Multi-Picklist');
        
        
        // Create Test Attribute Configuration - Service County
        Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
        ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, lstProd[0], 'Multi-Picklist');
        */
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(lstProd[0], 100);
        
        // Create Test Quote
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(lstAcc[0], lstOpp[0], quoteRecordTypeId, 1);
        
        
        // Create Test Quote Line
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], lstProd[0], objPBEntry, quoteLineRecordTypeId, 1);
       
        
        lstQuote[0].SBQQ__Ordered__c = TRUE;
        update lstQuote;
        

        
        
    }
    
    
    public static testMethod void testUnitMethod1(){
        test.startTest();
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOItem());
        Order objOrder = [SELECT Id, Enddate FROM Order LIMIT 1];
        
       // objOrder.Status = 'Activated';
       // update objOrder;
        
        //objOrder.SBQQ__Contracted__c = TRUE;
        //update objOrder;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        Contact objCon = [SELECT Id FROM Contact LIMIT 1];
        
        Opportunity objOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
       // Contract objContract = DataFactory.createContract(objAcc, objOpp);
        
        Product2 objProd = [SELECT Id FROM Product2 LIMIT 1];
        
        SBQQ__QuoteLine__c objQLI = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        
       // SBQQ__Subscription__c objSub = DataFactory.createSubscription(objAcc, objContract, objProd, objQLI);
        
        OrderItem objOI = [SELECT Id, OrderItemNumber, SIN__c, ServiceDate, EndDate FROM OrderItem LIMIT 1];
        Attribute_Relationship__c attr =  [select id from Attribute_Relationship__c limit 1];
        objOI.Attribute_Relationship__c = attr.Id;
        update objOI;
        
        SBQQ__OrderItemConsumptionSchedule__c objOICS = new SBQQ__OrderItemConsumptionSchedule__c();
        objOICS.SBQQ__BillingTermUnit__c = 'Month';
        objOICS.SBQQ__BillingTerm__c = 1;
        objOICS.SBQQ__Category__c = 'Rates';
        objOICS.SBQQ__RatingMethod__c = 'Tier';
        objOICS.SBQQ__Type__c = 'Range';
        objOICS.SBQQ__OrderItem__c = objOI.Id;
        insert objOICS;
        
        objOICS = [SELECT Id FROM SBQQ__OrderItemConsumptionSchedule__c LIMIT 1];
        
        
        blng__UsageSummary__c objUSummary = DataFactory.createUsageSummary(objAcc, objOrder, objOI);
        objUSummary.blng__OrderItemConsumptionSchedule__c = objOICS.Id;
        update objUSummary;
        
        objUSummary = [SELECT Id, blng__MatchingId__c, blng__UnitOfMeasure__c , blng__MatchingAttribute__c FROM blng__UsageSummary__c LIMIT 1];

        string strTodaydt = string.valueOf(system.now()).replace(' ', 'T');
        string strEnddt = string.valueOf(system.now().adddays(1)).replace(' ', 'T');
        
        blng__Usage__c objUsage = new blng__Usage__c();
        objUsage.blng__Account__c = objAcc.Id;
        objUsage.blng__Order__c = objOrder.Id;
        objUsage.blng__OrderProduct__c = objOI.Id;
        objUsage.blng__UsageSummary__c = objUSummary.Id;
        objUsage.blng__MatchingId__c = objUSummary.blng__MatchingId__c;
        objUsage.blng__MatchingAttribute__c = 'Quarterly';
        objUsage.blng__UnitOfMeasure__c = 'Hours';
        objUsage.Lead_Id__c = '1234';
        objUsage.blng__Quantity__c = 1;
        objUsage.blng__Subtotal__c = 0;
        objUsage.blng__UnitPrice__c = 0;
        objUsage.First_name__c = 'Test Fname';
        objUsage.Last_name__c = 'Test Lname';
        objUsage.Email__c = 'test@test.com';
        objUsage.blng__StartDateTime__c = system.now();
        objUsage.blng__EndDateTime__c = system.now();
        objUsage.blng__Status__c = 'New';
        objUsage.blng__PreratedQuantity__c = 0;
        objUsage.blng__PreratedAmount__c = 0;
        objUsage.blng__ProcessingDate__c = system.today();
        insert objUsage;
        
        blng__Usage__c objUsage2 = new blng__Usage__c();
        objUsage2.blng__Account__c = objAcc.Id;
        objUsage2.blng__Order__c = objOrder.Id;
        objUsage2.blng__OrderProduct__c = objOI.Id;
        objUsage2.blng__UsageSummary__c = objUSummary.Id;
        objUsage2.blng__MatchingId__c = objUSummary.blng__MatchingId__c;
        objUsage2.blng__MatchingAttribute__c = 'Quarterly';
        objUsage2.blng__UnitOfMeasure__c = 'Hours';
        objUsage2.Lead_Id__c = '1235';
        objUsage2.blng__Quantity__c = 1;
        objUsage2.blng__Subtotal__c = 0;
        objUsage2.blng__UnitPrice__c = 0;
        objUsage2.First_name__c = 'Test Fname';
        objUsage2.Last_name__c = 'Test Lname';
        objUsage2.Email__c = 'test@test.com';
        objUsage2.blng__StartDateTime__c = system.now();
        objUsage2.blng__EndDateTime__c = system.now();
        objUsage2.blng__Status__c = 'New';
        objUsage2.blng__PreratedQuantity__c = 0;
        objUsage2.Credit_Status__c = 'Posted';
        objUsage2.Credit_Amount__c = 0;
        objUsage2.blng__PreratedAmount__c = 0;
        objUsage2.blng__ProcessingDate__c = system.today();
        insert objUsage2;
        
        Id InvRecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('M-A Intake Invoice').getRecordTypeId();
       
        //creating invoice
        blng__Invoice__c  singleInv = new blng__Invoice__c ();
        
        singleInv.blng__Account__c= objacc.id;    
        singleInv.blng__DueDate__c = date.Today().addDays(-90);
        singleInv.RecordtypeId = InvRecordTypeId ;
        singleInv.blng__InvoiceDate__c = date.Today().addDays(-10);
        insert singleInv ;
        
        //singleInv = util.getInvoice(acc.Id);
        singleInv.blng__BillToContact__c    = objcon.id;
        singleInv.blng__TargetDate__c= date.today();
        singleInv.Delivery_Type__c= 'Email';
        singleInv.blng__InvoiceDate__c = date.newInstance(2016, 01, 01);
        update singleInv; 
        
        
         //creating invoice line
        Id InvlineRecordTypeId = Schema.SObjectType.blng__InvoiceLine__c.getRecordTypeInfosByName().get('M-A Intake Invoice Line').getRecordTypeId();
        blng__InvoiceLine__c singleinvline = new blng__InvoiceLine__c ();
        //changes by vishnu
        //singleinvline.Name='sampleInvoiceLine';
        singleinvline.blng__Invoice__c = singleInv.id;
        singleinvline.blng__OrderProduct__c = objOI.id;
        singleinvline.RecordtypeId = InvlineRecordTypeId ;
        singleinvline.blng__StartDate__c = date.today().addDays(-90);
        singleinvline.blng__EndDate__c = date.Today().addDays(+90);
        singleinvline.blng__UnitPrice__c = 100.00;
        singleinvline.blng__Quantity__c = 1;
        singleinvline.blng__TotalAmount__c = 100.00;
        //singleinvline.blng__OrderProduct__r.Usage_List_Price__c = 12;
        insert singleinvline;
        
        blng__InvoiceLine__c singleinvline2 = new blng__InvoiceLine__c ();
        //changes by VR
        //singleinvline2.Name='sampleInvoiceLine';
        singleinvline2.blng__Invoice__c = singleInv.id;
        singleinvline2.blng__OrderProduct__c = objOI.id;
        singleinvline2.RecordtypeId = InvlineRecordTypeId ;
        singleinvline2.blng__StartDate__c = date.today().addDays(-90);
        singleinvline2.blng__EndDate__c = date.Today().addDays(+90);
        singleinvline2.blng__UnitPrice__c = 100.00;
        singleinvline2.blng__Quantity__c = 1;
        singleinvline2.blng__TotalAmount__c = 100.00;
        //singleinvline.blng__OrderProduct__r.Usage_List_Price__c = 12;
        insert singleinvline2;
       
       
         ApexPages.currentPage().getParameters().put('id',singleInv.id );
        CPQ_Invoice_Template classcalling = new CPQ_Invoice_Template();
        
        //blng__Order__c,First_name__c, Last_name__c,blng__OrderProduct__c,blng__OrderProduct__r.Product2Id FROM 
        //blng__Usage__c where blng__OrderProduct__c = :orderProductIds ];
		
        blng__Usage__c item= new blng__Usage__c();
		
        item.First_name__c='sample';
        item.Last_name__c='last';
        item.blng__OrderProduct__c = singleinvline.blng__OrderProduct__c;
       // item.blng__Account__c=acc.id;
        //insert item;
        
        
  
        
        
        CPQ_Invoice_Template.InvoiceLineWrapper itemTest = new  CPQ_Invoice_Template.InvoiceLineWrapper();
        itemTest.startDate = date.today();
		itemTest.endDate = date.Today().addDays(-90);
        itemTest.Name = 'SampleName';
        itemTest.description = 'Sampledescription';
        itemTest.quantity = 50;
        itemtest.unitPrice = 10;
        itemtest.totalPrice=100;
        itemtest.aopDescription='Sampledescription';
       
            //blng__InvoiceLine__c
        map<string,Double> mapofinvline = new map<string,Double>();
        // mapofinvline = classcalling.listInv();
        //calling all getter methods
       // date stdate      = classcalling.StartDate; 
        //date edate       = classcalling.EndDate;
        
       // map<string,Integer> listInvLIst = classcalling.listInvLI;
        //classcalling.send();
        //classcalling.cancel();
        classcalling.sInvoiceId=singleInv.id;
        map<string,Double> test1 =classcalling.listInv ;        
        classcalling.listOfInvLine = new list<blng__InvoiceLine__c >();
        classcalling.listOfInvLineWrapper = new list<CPQ_Invoice_Template.InvoiceLineWrapper>();
        blng__Invoice__c i1=classcalling.Invoice1;
        blng__Invoice__c i2=classcalling.Invoice2;
        test.stoptest();

    }
        
    
    
}