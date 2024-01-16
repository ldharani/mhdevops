@isTest(seealldata=true)
public class TestQuotePDF {
    
    
    static testMethod void run2condition(){
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        //product creation
        invoiceit_s__Product__c prod                                = util.getProduct('isInventorable');        
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = util.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = util.getProductRatePlanCharge(Curr.Id, prodrateplan.id);        
        //Opportunity Creation
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );   
        
         Opportunity childOpp = util.getOpportunity(acc.Id , con.Id ,curr.Id );
          childOpp.Parent_Opportunity__c = opp.id;
        update childOpp;
       
      
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred City Results';
        
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
           Opportunity_Charge_Attribute__c charge1 = util.getOppCharges(opprpc.Id, 'Text', 'Service City');
      Opportunity_Charge_Attribute__c charge2 = util.getOppCharges(opprpc.Id, 'Picklist', 'City');
      Opportunity_Charge_Attribute__c charge3 = util.getOppCharges(opprpc.Id, 'Picklist', 'County');
      Opportunity_Charge_Attribute__c charge4 = util.getOppCharges(opprpc.Id, 'Picklist', 'State');
      Opportunity_Charge_Attribute__c charge6 = util.getOppCharges(opprpc.Id, 'Picklist', 'AOP');
      Opportunity_Charge_Attribute__c charge7 = util.getOppCharges(opprpc.Id, 'Number', 'Phone');
      Opportunity_Charge_Attribute__c charge8 = util.getOppCharges(opprpc.Id, 'Date', 'Sell Date');
      Opportunity_Charge_Attribute__c charge9 = util.getOppCharges(opprpc.Id, 'Boolean', 'AOP');
      Opportunity_Charge_Attribute__c charge10 = util.getOppCharges(opprpc.Id, 'Text', 'Country');
          Opportunity_Charge_Attribute__c charge11 = util.getOppCharges(opprpc.Id, 'Phone', '34534634');
     
     ApexPages.currentPage().getParameters().put('id',opp.id);   
     ApexPages.StandardController sc = new ApexPages.StandardController(opp);
     generatePDFController pdfConrt = new generatePDFController(sc);
        
        Test.startTest();
        quote_PDF_Generator.quotePDF(opp.Id);
        
        Test.stopTest();
        
         opprpc.invoiceit_crmx__Accounting_Code__c ='01686';
        update opprpc;
      
          quote_PDF_Generator.quotePDF(opp.Id);
          pdfConrt.quotePDF();
       
    }
      
    
     static testMethod void run2condition1(){
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        //product creation
        invoiceit_s__Product__c prod                                = util.getProduct('isInventorable');  
         prod.IsInventoried__c  = 'TRUE';
         update prod;
         
        //product rate plan creation
        invoiceit_s__Product_Rate_Plan__c prodrateplan              = util.getProductRatePlan(prod.Id);        
        //product rate plan charge creation
        invoiceit_s__Product_Rate_Plan_Charge__c prodRatePlanCharge = util.getProductRatePlanCharge(Curr.Id, prodrateplan.id);   
         
          Opportunity dummyopp = util.getOpportunity(acc.Id , con.Id ,curr.Id ); 
        //Opportunity Creation
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id ); 
                opp.Ngage_Source__c = null;
         opp.Lock_Record__c = true;
         opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('M_NG_Opportunity').getRecordTypeId();
         opp.Reason_for_Discount__c = 'test';
         opp.Marketing_Contact__c = con.Id;
         opp.Auth_By_Contact__c = con.Id;
         opp.invoiceit_crmx__Billing_Contact__c  = con.Id;
         
         update opp;
        
         Opportunity childOpp = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        childOpp.Parent_Opportunity__c = opp.id;
        update childOpp;
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred City Results';
       oppprod1.invoiceit_crmx__Product_Family__c ='Nolo'; 
         update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
         opprpc.invoiceit_crmx__Price_Type__c = 'Annual';
         opprpc.invoiceit_crmx__Accounting_Code__c = '12002' ;
         
         
           invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc1 = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
           opprpc1.invoiceit_crmx__Accounting_Code__c = '12003' ;
        
         
           invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
          opprpc2.invoiceit_crmx__Accounting_Code__c = '12001' ;
         
         List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> updatecharges = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
         updatecharges.add(opprpc);
         updatecharges.add(opprpc1);
         updatecharges.add(opprpc2);
         update updatecharges;
         
         
      List<Opportunity_Charge_Attribute__c>  attributes = new List<Opportunity_Charge_Attribute__c>(); 
      Opportunity_Charge_Attribute__c charge1 = util.getOppChargeswithoutInsert(opprpc.Id, 'Text', 'Service City');
       charge1.String_Value__c = null;  
      Opportunity_Charge_Attribute__c charge2 = util.getOppChargeswithoutInsert(opprpc.Id, 'Picklist', 'City');
         charge2.Picklist_Value__c = null;
         
      Opportunity_Charge_Attribute__c charge7 = util.getOppChargeswithoutInsert(opprpc.Id, 'Number', 'Phone');
         charge7.Number_Value__c = null;
      Opportunity_Charge_Attribute__c charge8 = util.getOppChargeswithoutInsert(opprpc.Id, 'Date', 'Sell Date');
         charge8.Date_Value__c = null;
      Opportunity_Charge_Attribute__c charge9 = util.getOppChargeswithoutInsert(opprpc.Id, 'Boolean', 'AOP');
         charge9.Boolean_Value__c = false;
      Opportunity_Charge_Attribute__c charge10 = util.getOppChargeswithoutInsert(opprpc.Id, 'Text', 'Country');
         charge10.String_Value__c = null;
      Opportunity_Charge_Attribute__c charge11 = util.getOppChargeswithoutInsert(opprpc.Id, 'Phone', '34534634');
         charge11.Phone_Value__c = null;
        attributes.add(charge1); 
          attributes.add(charge2); 
          attributes.add(charge7); 
          attributes.add(charge8); 
          attributes.add(charge9); 
          attributes.add(charge10); 
          attributes.add(charge11); 
         insert attributes;
        
        ApexPages.currentPage().getParameters().put('id',opp.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generatePDFController pdfConrt = new generatePDFController(sc);
        
        Test.startTest();
        quote_PDF_Generator.quotePDF(opp.Id);
        pdfConrt.quotePDF();
        Test.stopTest();
         
         opp.Parent_Opportunity__c = dummyopp.Id;
         update opp;
         
          opprpc.invoiceit_crmx__Accounting_Code__c = '12011' ;
          opprpc1.invoiceit_crmx__Accounting_Code__c = '12012' ;
           updatecharges = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
         updatecharges.add(opprpc);
         updatecharges.add(opprpc1);
         update updatecharges;         
         
          quote_PDF_Generator.quotePDF(opp.Id);
          pdfConrt.quotePDF();
         
    }
    
    
    
    
     static testMethod void testQuote(){
     
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
       /* Account britacc = util.getAccount();
        invoiceit_s__Currency__c britCurr = new invoiceit_s__Currency__c(Name = 'GBP', invoiceit_s__Symbol__c = '£');
        insert britCurr;
        Contact britcon = util.getContact(britacc.Id);*/
        
        invoiceit_s__Product__c prod1 = util.getProduct('true');
        invoiceit_s__Product__c prod2 = util.getProduct('true');
        invoiceit_s__Product__c prod3 = util.getProduct('true');
        //invoiceit_s__Product__c prod4 = util.getProduct('true');
          
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(prod2.Id);
        invoiceit_s__Product_Rate_Plan__c prp3 = util.getProductRatePlan(prod3.Id);
        //invoiceit_s__Product_Rate_Plan__c prp4 = util.getProductRatePlan(prod4.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(curr.Id , prp2.Id);
        insert prpc2;
        invoiceit_s__Product_Rate_Plan_Charge__c prpc3 = util.getProductRatePlanCharge(curr.Id , prp3.Id);
        
        //invoiceit_s__Product_Rate_Plan_Charge__c britprpc4 = util.getProductRatePlanCharge(britCurr.Id , prp3.Id);

        
        Opportunity opp = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        //opp.Email_Sent_Date__c = date.today();    
        opp.Name = 'Test test';
        update opp;
        
        Opportunity childOpp = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        childOpp.Parent_Opportunity__c = opp.id;
        update childOpp;
        
        Opportunity opp2 = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        
        //Opportunity britopp = util.getOpportunity(britacc.Id , britcon.Id ,britcurr.Id );
        
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id);
        //invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod2.Id,opp.Id);
         invoiceit_crmx__Opportunity_Product__c  oppprod2 = new invoiceit_crmx__Opportunity_Product__c(Name = 'Site Activation Fee',invoiceit_crmx__Product_Code__c = '60020',InventoryId__c ='1233213', invoiceit_crmx__Product__c = prod2.Id ,invoiceit_crmx__Opportunity__c = opp.Id);
        insert oppProd2;
        invoiceit_crmx__Opportunity_Product__c  oppProd3 = new invoiceit_crmx__Opportunity_Product__c(Name = 'Ngage Live Chat',invoiceit_crmx__Product_Code__c = '60010',InventoryId__c ='123323213', invoiceit_crmx__Product__c = prod2.Id ,invoiceit_crmx__Opportunity__c = opp.Id);
        insert oppProd3;
        //invoiceit_crmx__Opportunity_Product__c  oppprod4 = new invoiceit_crmx__Opportunity_Product__c(Name = 'Site Activation Test',invoiceit_crmx__Product_Code__c = '60020',InventoryId__c ='1233213', invoiceit_crmx__Product__c = prod2.Id ,invoiceit_crmx__Opportunity__c = opp3.Id);
        //insert oppProd4;
        System.debug('Opportunity product 3'+oppProd3);
        
        //invoiceit_crmx__Opportunity_Product__c  britoppprod4 = new invoiceit_crmx__Opportunity_Product__c(Name = 'Ngage Live Chat',invoiceit_crmx__Product_Code__c = '60010',InventoryId__c ='1233213', invoiceit_crmx__Product__c = prod2.Id ,invoiceit_crmx__Opportunity__c = britopp.Id);
        //insert britoppprod4;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp = util.getOpportunityRatePlan(oppprod1.Id , prp.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp2 = util.getOpportunityRatePlan(oppprod2.Id , prp2.Id);
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp3 = util.getOpportunityRatePlan(oppprod3.Id , prp3.Id);
        //invoiceit_crmx__Opportunity_Rate_Plan__c opprp4 = util.getOpportunityRatePlan(oppprod4.Id , prp4.Id);
        
        //invoiceit_crmx__Opportunity_Rate_Plan__c britopprp = util.getOpportunityRatePlan(britoppprod4.Id , britprpc4.Id);

        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c britopprpc = util.getOppRatePlanCharge(britopprp.Id , prpc2.Id);

        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prpc2.Id);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name='Ngage Live Chat',invoiceit_crmx__Price_Type__c = 'Usage', invoiceit_crmx__Unit_Price__c = 100, invoiceit_crmx__Opportunity_Rate_Plan__c = opprp2.Id, invoiceit_crmx__Product_Rate_Plan_Charge__c = prpc3.Id);          
        insert opprpc2 ;
        
        /*invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc2 = util.getOppRatePlanCharge(opprp2.Id , prpc3.Id);
        opprpc2.invoiceit_crmx__Price_Type__c='Usage';
        update opprpc2;*/
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc3 = util.getOppRatePlanCharge(opprp3.Id , prpc3.Id);
        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc4 = util.getOppRatePlanCharge(opprp4.Id , prpc4.Id);
        opprpc3.invoiceit_crmx__Price_Type__c='Monthly';
        opprpc3.name = 'OppRPC3';
        update opprpc3;
        
        Opportunity_Charge_Attribute__c oppCharge1 = util.getOppCharges(opprpc.Id,'Text','URL');
        Id devRecordTypeId1 = Schema.SObjectType.Opportunity_Charge_Attribute__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_JV_Opportunity_Charge_Attribute).getRecordTypeId();
        oppCharge1.recordtypeid = devRecordTypeId1 ;
        Opportunity_Charge_Attribute__c oppCharge2 = util.getOppCharges(opprpc.Id,'Text','Service State');  
        oppCharge2.recordtypeid = devRecordTypeId1 ;
        
        //Opportunity_Charge_Attribute__c britoppChargeAttr = util.getOppCharges(britopprpc.Id,'Text','URL');
        
        oppCharge2.Opportunity_Rate_Plan_Charge__c = opprpc2.id;
                        
        ApexPages.currentPage().getParameters().put('id',opp.id);
        CreateQuotePDF contollr= new CreateQuotePDF();
        test.startTest();
        //quote_PDF_Generator qPDFG = new quote_PDF_Generator();
        contollr.FkMethod();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        generatePDFController pdfConrt = new generatePDFController(sc);
        
        try{
            
            quote_PDF_Generator.quotePDF(childOpp.id);
            pdfConrt.quotePDF();
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains('PDF cannot be generated for this Opportunity as it is a child opportunity.') ? true : false;
            system.assertEquals(expectedExceptionThrown,True);       
            }
       
        try{
            oppCharge2.Attribute_Type__c = 'Number';
            oppCharge2.String_Value__c = 'test1';
            //oppCharge2.Number_Value__c;
            update oppCharge2;
            quote_PDF_Generator.quotePDF(opp.id);
            pdfConrt.quotePDF();
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains('You can not generate the PDF since few attributes are blank') ? true : false;
            system.assertEquals(expectedExceptionThrown,True);       
            }
            
            
            
            try{
            oppCharge2.Attribute_Type__c = 'Number';
            oppCharge2.Number_Value__c = null;
            //oppCharge2.Number_Value__c;
            update oppCharge2;
            quote_PDF_Generator.quotePDF(opp.id);
            pdfConrt.quotePDF();
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains('You can not generate the PDF since few attributes are blank') ? true : false;
            system.assertEquals(expectedExceptionThrown,True);       
            }
            
        try{
            oppCharge2.Attribute_Type__c = 'Boolean';
            oppCharge2.Number_Value__c = 12;
            update oppCharge2;
            quote_PDF_Generator.quotePDF(opp.id);
            pdfConrt.quotePDF();
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains('You can not generate the PDF since few attributes are blank') ? true : false;
            system.assertEquals(expectedExceptionThrown,True);       
            }
       /* try{
            //oppCharge2.Attribute_Type__c = 'Picklist';
             Opportunity_Charge_Attribute__c oppCharges= util.getOppCharges(oppCharge2.Id, 'Text', 'AOP');
              oppCharges.String_Value__c = '';
              update oppCharges;
              Opportunity_Charge_Attribute__c oppCharges1 = util.getOppCharges(oppCharge2.Id, 'Number', 'ABC');
              oppCharges1.Number_Value__c = null;
              update oppCharges1;
              Opportunity_Charge_Attribute__c oppCharges2 = util.getOppCharges(oppCharge2.Id, 'Boolean', 'XYZ');
              oppCharges2.Boolean_Value__c = false;
              update oppCharges2;
              Opportunity_Charge_Attribute__c oppCharges3 = util.getOppCharges(oppCharge2.Id, 'Picklist', 'TYU');
              oppCharges3.Picklist_Value__c = null;
              update oppCharges3;
              Opportunity_Charge_Attribute__c oppCharges4 = util.getOppCharges(oppCharge2.Id, 'Date', 'Pay Date');
              oppCharges4.Date_Value__c = null;
              update oppCharges4;
            quote_PDF_Generator.quotePDF(opp.id);
            pdfConrt.quotePDF();
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('You can not generate the PDF since few attributes are blank') ? true : false;
           system.assertEquals(expectedExceptionThrown,True); 
             
           } */ 
            
        try{
            oppCharge2.Attribute_Type__c = 'Date';
            oppCharge2.Picklist_Value__c = 'test2';
            update oppCharge2;
            quote_PDF_Generator.quotePDF(opp.id);
            pdfConrt.quotePDF();
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains('You can not generate the PDF since few attributes are blank') ? true : false;
            system.assertEquals(expectedExceptionThrown,True);       
            }
        try{
            oppCharge2.Attribute_Type__c = 'Phone';
            oppCharge2.Date_Value__c = system.today();
            update oppCharge2;
            quote_PDF_Generator.quotePDF(opp.id);
            pdfConrt.quotePDF();
        }
        catch(Exception e){
             Boolean expectedExceptionThrown =  e.getMessage().contains('You can not generate the PDF since few attributes are blank') ? true : false;
            system.assertEquals(expectedExceptionThrown,True);       
            }
        try{
                quote_PDF_Generator.quotePDF(opp2.id);
                pdfConrt.quotePDF();
            }
         catch(Exception ex){
             system.assert(ex.getMessage().contains('You can not genrate the PDF since no product has been added to the opportunity.'));
         }
         try{
            System.debug('@@@@@opprpc'+opprpc);
            opprpc.invoiceit_crmx__Price_Type__c='One Time';
            update opprpc;
            System.debug('@@@@@@@@@@outside');
         } catch(Exception e){
             System.debug('@@@@Error'+e);
         }
       test.stopTest();
        
    }
    static testMethod void testQu(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod4 = util.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c prp4 = util.getProductRatePlan(prod4.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc4 = util.getProductRatePlanCharge(curr.Id , prp4.Id);
        Opportunity opp3 = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        invoiceit_crmx__Opportunity_Product__c  oppprod4 = new invoiceit_crmx__Opportunity_Product__c(Name = 'Site Activation Test',invoiceit_crmx__Product_Code__c = '60020',InventoryId__c ='1233213', invoiceit_crmx__Product__c = prod4.Id ,invoiceit_crmx__Opportunity__c = opp3.Id);
        insert oppProd4;
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp4 = util.getOpportunityRatePlan(oppprod4.Id , prp4.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc4 = util.getOppRatePlanCharge(opprp4.Id , prpc4.Id);
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp3);
        generatePDFController pdfConrt = new generatePDFController(sc);
        
        try{
                opp3.Lock_Record__c = True;
                update opp3;
                quote_PDF_Generator.quotePDF(opp3.id);
            }
         catch(Exception ex){
             system.assert(ex.getMessage().contains('You can not generate PDF since the opportuntiy is Locked.'));
         }
        try{
                opprpc4.invoiceit_crmx__Price_Type__c = 'Annual';
                opprpc4.name = 'OppRPC4';
                update opprpc4;
                quote_PDF_Generator.quotePDF(opp3.id);
                pdfConrt.quotePDF();
            }
         catch(Exception ex){
             //system.assert(ex.getMessage().contains('Please remove Annual products to generate the PDF.'));
         }
        try{
                opp3.invoiceit_crmx__Discount_Percent__c = 20;
                update opp3;
                quote_PDF_Generator.quotePDF(opp3.id);
                //pdfConrt.quotePDF();
            }
         catch(Exception ex){
             system.assert(ex.getMessage().contains('You cannot generate the PDF since the opportunity is not submitted for approval.'));
         }
        try{
                oppprod4.invoiceit_crmx__Product_Family__c = 'Nolo';
                update oppprod4;
                opp3.recordType.name = 'M-NG Opportunity';
                update opp3;
                quote_PDF_Generator.quotePDF(opp3.id);
                pdfConrt.quotePDF();
            }
         catch(Exception ex){
             //system.assert(ex.getMessage().contains('You can not add Martindale Hubbell or Nolo Products for this Opportnity.'));
         }
        
        test.stopTest();
     }
    static testMethod void testQuot(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod4 = util.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c prp4 = util.getProductRatePlan(prod4.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc4 = util.getProductRatePlanCharge(curr.Id , prp4.Id);
        Opportunity opp3 = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        opp3.Classification__c = 'Legal';
        //Id ngageRecTypeId= Schema.SObjectType.Contact.getRecordTypeInfosByName().get('M_NG_Opportunity').getRecordTypeId();
        //System.debug('=============ngageRecTypeId'+ngageRecTypeId);
        //opp3.RecordType.name = 'M-NG Opportunity';
        update opp3;
        invoiceit_crmx__Opportunity_Product__c  oppprod4 = new invoiceit_crmx__Opportunity_Product__c(Name = 'Site Activation Test',invoiceit_crmx__Product_Code__c = '60020',InventoryId__c ='1233213', invoiceit_crmx__Product__c = prod4.Id ,invoiceit_crmx__Opportunity__c = opp3.Id);
        insert oppProd4;
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp4 = util.getOpportunityRatePlan(oppprod4.Id , prp4.Id);
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc4 = util.getOppRatePlanCharge(opprp4.Id , prpc4.Id);
        
        
        
        pageReference pageRef2 = Page.CreateQuoteApprovalPagePDF ;
        //Set Parameter for id and opp here
        pageRef2.getParameters().put('id',opp3.id); 
        
    }
      
    
}