@isTest(seealldata=true)
public class CPQTestQuotePDF {

static testMethod void testQuote(){
     
          MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
    
        Account acc = testData.getAccount();    
        Contact c = testData.getContact(acc.Id);
        
        List<Opportunity> oppList = new List<Opportunity>();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('M-A Intake Opportunity').getRecordTypeId();
            Opportunity objOpp = new Opportunity();
            objOpp.Name = 'Test';
            objOpp.AccountId = acc.id;
            objOpp.RecordtypeId = oppRecordTypeId ;
            objOpp.Amount = 123.50;                                                      
            objOpp.CloseDate = system.today();
            objOpp.StageName = 'Needs Analysis';
            oppList.add(objOpp);
       
        
        insert oppList;  
        
        blng__BillingRule__c objBR = new blng__BillingRule__c();
        objBR.Name = 'Test';
        objBR.blng__Active__c = TRUE;
        objBR.blng__AmendmentBillCycleDateAlignment__c = 'Do not align amended Order Product';
        objBR.blng__GenerateInvoices__c = 'Yes';
        objBR.blng__InitialBillingTrigger__c = 'Order Product Activation Date ';
        objBR.blng__Notes__c = 'Test';
        objBR.blng__PartialPeriodTreatment__c = 'Separate';
        insert objBR;
        
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
            objProd.SBQQ__HasConfigurationAttributes__c = true;
            objProd.IsInventoried__c = true;
            objProd.blng__TaxRule__c = objTR.Id; 
            prodList.add(objProd);
        
        insert prodList;    
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
       
            SBQQ__Quote__c objQuote = new SBQQ__Quote__c();
            objQuote.SBQQ__Account__c = acc.id;
            objQuote.SBQQ__PricebookId__c = Test.getStandardPricebookId();
            objQuote.RecordtypeId = quoteRecordTypeId ; 
            objQuote.SBQQ__Opportunity2__c = objOpp.id;
            objQuote.SBQQ__StartDate__c = system.today();
            objQuote.SBQQ__EndDate__c = system.today().adddays(30);
            objQuote.SBQQ__SubscriptionTerm__c = 12;
            objQuote.SBQQ__Primary__c = True;
            objQuote.SBQQ__Status__c = 'Approved';
            objQuote.SBQQ__ExpirationDate__c = system.today().adddays(30);
            objQuote.SBQQ__BillingFrequency__c = 'Monthly';  
            quoteList.add(objQuote);
       // }
        insert quoteList;  
        
        
        
        PricebookEntry objPBEntry = new PricebookEntry();
        objPBEntry.Pricebook2Id = Test.getStandardPricebookId();
        objPBEntry.Product2Id = objProd.Id;
        objPBEntry.UnitPrice = 20;
        objPBEntry.IsActive = true;        
        insert objPBEntry;
        
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:,';
        insert objAR;
        
        Id pricebookId = Test.getStandardPricebookId();
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        SBQQ__QuoteLine__c objQLI = new SBQQ__QuoteLine__c();
        objQLI.SBQQ__Quote__c = objQuote.id;
        objQLI.SBQQ__Product__c = objProd.Id;
        objQLI.SBQQ__PricebookEntryId__c = objPBEntry.id;
        objQLI.SBQQ__DefaultSubscriptionTerm__c = 12;
        objQLI.SBQQ__Quantity__c = 1;
        objQLI.SBQQ__BillingFrequency__c = 'Monthly';
        objQLI.SBQQ__BillingType__c = 'Advance';
        objQLI.RecordTypeId = quoteLineRecordTypeId ;
        objQLI.Usage_List_Price__c = 100;
        
       // objQLI.SBQQ__Product__r.IsInventoried__c = True;
        objQLI.SBQQ__SubscriptionTerm__c = 1;
        //objQLI.Attribute_Relationship__c = objAR.Id;
        insert objQLI;
                        
        ApexPages.currentPage().getParameters().put('id',objQuote.id);
        CPQ_CreateQuotePDF contollr= new CPQ_CreateQuotePDF();
        //test.startTest();
        //quote_PDF_Generator qPDFG = new quote_PDF_Generator();
        contollr.FkMethod();
        
       Test.startTest();
        CPQ_Quote_PDF_Generator.quotePDF(objQuote.Id);
        
        //CPQ_Quote_PDF_Generator qPDFG = new CPQ_Quote_PDF_Generator ();
        //qPDFG .FkMethod();
          try{
            
            objQLI.Attribute_Relationship__c = null;
            update objQLI;
            CPQ_Quote_PDF_Generator.quotePDF(objQuote.Id);
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains('Please add attributes') ? true : false;
            system.assertEquals(expectedExceptionThrown,True);       
            }
            
            
            try{
            
            objQLI.Attribute_Relationship__c = null;
            update objQLI;
            CPQ_Quote_PDF_Generator.quotePDF(objQuote.Id);
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains('Please add primary contact') ? true : false;
            system.assertEquals(expectedExceptionThrown,True);       
            }
            
        Test.stopTest();
    
    }
    
    }