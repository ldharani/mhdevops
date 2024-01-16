@isTest(seeAlldata = true)
public class InventorySearchControllerTest {
     static testmethod void scenario1(){
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
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred City Results';
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','Ajio');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred City Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';         
         ctrl.runCountrySearch();
     }
     
     static testmethod void scenario2(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred State Results';
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);
        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
                
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','Ajio');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred State Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';                  
         ctrl.runCountrySearch();
     }
     static testmethod void scenario3(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred State Results';
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);
        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','Ajio');         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred State Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';
         ctrl.searchCounty = null;         
         ctrl.runCountrySearch();
     }
     static testmethod void scenario4(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred County Results';
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);
        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Apache');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        //Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','Apache','');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred County Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';
         ctrl.searchCounty = 'Apache';         
         ctrl.runCountrySearch();
     }
    
    
  
     static testmethod void scenario5(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred City Results';
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);
        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','Ajio');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred City Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';
         ctrl.searchCity = 'Ajio';                  
         ctrl.runCountrySearch();
     }
     static testmethod void scenario6(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred Banner Placements';
        oppprod1.InventoryId__c = 'testid';
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','Ajio');         
                 
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred Banner Placements';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';
         ctrl.searchCounty = '';                           
         ctrl.runCountrySearch();
     }
     static testmethod void scenario7(){                       
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred City Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = '';                                    
         ctrl.runCountrySearch();
     }
     static testmethod void scenario8(){
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
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred City Results';
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'City', 'Ajio');
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','Ajio');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred City Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';         
         ctrl.runCountrySearch();         
     }     
     
     static testmethod void scenario9(){
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
        Opportunity opp1 = util.getOpportunity(acc.Id , con.Id ,curr.Id );        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred City Results';
        update oppprod1;
        
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod2.Name = 'Preferred City Results';
        update oppprod2;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp1         = util.getOpportunityRatePlan(oppprod2.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc1 = util.getOppRatePlanCharge(opprp1.Id , prodRatePlanCharge.Id);
        List<Opportunity_Charge_Attribute__c> ocaList = new List<Opportunity_Charge_Attribute__c>();  
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'AOP', 'Administrative Law');
        //Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'City', 'Ajio');
        
        Opportunity_Charge_Attribute__c aop1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'AOP', String_Value__c = 'Administrative Law');
        ocaList.add(aop1);
        Opportunity_Charge_Attribute__c country1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'Country', String_Value__c = 'USA');
        ocaList.add(country1 );
        Opportunity_Charge_Attribute__c state1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'State', String_Value__c = 'AZ');
        ocaList.add(state1);
        Opportunity_Charge_Attribute__c city1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'City', String_Value__c = 'Ajio');
        ocaList.add(city1); 
        insert ocaList;
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','Ajio');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred City Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';         
         ctrl.runCountrySearch();
     }
     static testmethod void scenario10(){
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
        Opportunity opp1 = util.getOpportunity(acc.Id , con.Id ,curr.Id );        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred City Results';
        update oppprod1;
        
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod2.Name = 'Preferred City Results';
        update oppprod2;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp1         = util.getOpportunityRatePlan(oppprod2.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc1 = util.getOppRatePlanCharge(opprp1.Id , prodRatePlanCharge.Id);
        List<Opportunity_Charge_Attribute__c> ocaList = new List<Opportunity_Charge_Attribute__c>();  
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'AOP', 'Administrative Law');
        //Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'City', 'Ajio');
        
        Opportunity_Charge_Attribute__c aop1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'AOP', String_Value__c = 'Administrative Law');
        ocaList.add(aop1);
        Opportunity_Charge_Attribute__c country1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'Country', String_Value__c = 'USA');
        ocaList.add(country1 );
        Opportunity_Charge_Attribute__c state1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'State', String_Value__c = 'AZ');
        ocaList.add(state1);
        Opportunity_Charge_Attribute__c city1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'City', String_Value__c = 'Ajio');
        ocaList.add(city1); 
        insert ocaList;        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','Ajio');
         
                       
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred City Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ'; 
         ctrl.searchCity = 'Ajio';         
         ctrl.runCountrySearch();
     }
     
     static testmethod void scenario11(){
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
        Opportunity opp1 = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred County Results';
        update oppprod1;
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod.Id,opp1.Id);
        oppprod2.Name = 'Preferred County Results';
        update oppprod2;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp1         = util.getOpportunityRatePlan(oppprod2.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc1 = util.getOppRatePlanCharge(opprp1.Id , prodRatePlanCharge.Id);
        List<Opportunity_Charge_Attribute__c> ocaList = new List<Opportunity_Charge_Attribute__c>();
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Apache');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        //Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
        
        Opportunity_Charge_Attribute__c aop1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'AOP', String_Value__c = 'Administrative Law');
        ocaList.add(aop1);
        Opportunity_Charge_Attribute__c country1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'Country', String_Value__c = 'USA');
        ocaList.add(country1 );
        Opportunity_Charge_Attribute__c state1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'State', String_Value__c = 'AZ');
        ocaList.add(state1);
        Opportunity_Charge_Attribute__c county1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'County', String_Value__c = 'Apache');
        ocaList.add(county1); 
        insert ocaList;
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','Apache','');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred County Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';
         ctrl.searchCounty = 'Apache';         
         ctrl.runCountrySearch();
     }
    
    //sai:
    /********************************************************************************/
     static testmethod void run2condition(){
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
        Opportunity opp1 = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred County Results';
        update oppprod1;
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod.Id,opp1.Id);
        oppprod2.Name = 'Preferred County Results';
        update oppprod2;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp1         = util.getOpportunityRatePlan(oppprod2.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc1 = util.getOppRatePlanCharge(opprp1.Id , prodRatePlanCharge.Id);
        List<Opportunity_Charge_Attribute__c> ocaList = new List<Opportunity_Charge_Attribute__c>();
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Apache');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        //Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
        
        Opportunity_Charge_Attribute__c aop1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'AOP', String_Value__c = 'Administrative Law');
        ocaList.add(aop1);
        Opportunity_Charge_Attribute__c country1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'Country', String_Value__c = 'USA');
        ocaList.add(country1 );
        Opportunity_Charge_Attribute__c state1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'State', String_Value__c = 'AZ');
        ocaList.add(state1);
        Opportunity_Charge_Attribute__c county1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'County', String_Value__c = 'Apache');
        ocaList.add(county1); 
        insert ocaList;
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','Apache','');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred County Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'AZ';
         ctrl.searchCounty = ''; 
         ctrl.searchCity   = null;
         ctrl.runCountrySearch();
     }
     static testmethod void scenario12(){
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
        Opportunity opp1 = util.getOpportunity(acc.Id , con.Id ,curr.Id );
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod2 = util.getOpportunityProduct(prod.Id,opp1.Id);
        oppprod2.Name = 'Preferred National Links';
        update oppprod2;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp1         = util.getOpportunityRatePlan(oppprod2.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc1 = util.getOppRatePlanCharge(opprp1.Id , prodRatePlanCharge.Id);
        List<Opportunity_Charge_Attribute__c> ocaList = new List<Opportunity_Charge_Attribute__c>();
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'County', 'Apache');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'State', 'AZ');
        //Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Picklist', 'City', 'Ajio');
        
        Opportunity_Charge_Attribute__c aop1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'AOP', String_Value__c = 'Administrative Law');
        ocaList.add(aop1);
        Opportunity_Charge_Attribute__c country1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'Country', String_Value__c = 'USA');
        ocaList.add(country1 );
        Opportunity_Charge_Attribute__c state1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'State', String_Value__c = 'AZ');
        ocaList.add(state1);
        Opportunity_Charge_Attribute__c county1 = new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c = opprpc1.id, Attribute_Type__c = 'Text', Attribute_Name__c = 'County', String_Value__c = 'Apache');
        ocaList.add(county1); 
        insert ocaList;
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','','Apache','');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred National Links';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'CA';
         ctrl.searchState = '';
         ctrl.searchCounty = '';                   
         ctrl.runCountrySearch();
     }
     static testmethod void scenario13(){
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
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred State Results';
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //creating orderCharge Attributes
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'AOP', 'Administrative Law');
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'County', 'Independent City');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes(opprpc.id, 'Text', 'City', 'Ajio');
        
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','AZ','','');
         
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred State Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'NY';         
         ctrl.runCountrySearch();         
     }    
     static testmethod void scenario14(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes

        Order_Charge_Attribute__c aop                               = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'AOP', 'Administrative Law');
        Order_Charge_Attribute__c county                            = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'County', 'Independent City');
        Order_Charge_Attribute__c country                           = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'Country', 'USA');
        Order_Charge_Attribute__c state                             = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'State', 'NC');
        Order_Charge_Attribute__c city                              = util.getOrderChargeAttributes(orderRatePlanCharge.id, 'Text', 'City', 'Boston');
                
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
         
          Test.startTest();
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred National Links';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'NC';
         ctrl.searchCounty = '';
          
         orderRatePlanCharge.invoiceit_s__Status__c = 'Cancelled';
         orderRatePlanCharge.invoiceit_s__Service_End_Date__c = system.today() +2;
         orderRatePlanCharge.Loss_Reasons__c = 'Testing';
         update orderRatePlanCharge;
                 
         ctrl.runCountrySearch();
           Test.stopTest();
     }
    
    
    
    //sai: line 628
    /******************************************************************************************/
     static testmethod void run1(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Preferred National Links';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'Administrative Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'Independent City'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
         Test.startTest();
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred National Links';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = '';
         ctrl.searchCounty = '';
         ctrl.runCountrySearch();
         Test.stopTest();
     }
    
    
     //sai: line 686
    /******************************************************************************************/
     static testmethod void run2(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Preferred National Links';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'Administrative Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'Independent City'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
         Test.startTest();
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred National Links';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'NC';
         ctrl.runCountrySearch();
         Test.stopTest();
     }
    
    
     //sai: line 756
    /******************************************************************************************/
     static testmethod void run3(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Preferred National Links';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'Administrative Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'Independent City'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
         Test.startTest();
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred National Links';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'NC';
         ctrl.searchCounty = 'Independent City';
         ctrl.runCountrySearch();
         Test.stopTest();
     }
    
     //sai: line 806
    /******************************************************************************************/
     static testmethod void run4(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Preferred National Links';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'Administrative Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'Independent City'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
         Test.startTest();
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred National Links';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'NC';
         ctrl.searchCity = 'Boston';
         ctrl.runCountrySearch();
         Test.stopTest();
     }
    
     //sai: line 858
    /******************************************************************************************/
     static testmethod void run5(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Preferred National Links';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Preferred National Links';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'Administrative Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'Independent City'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
         Test.startTest();
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Preferred National Links';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'NC';
         ctrl.searchCity = null;
         ctrl.searchCounty = 'Independent City';
         ctrl.runCountrySearch();
         Test.stopTest();
     }
    
     /******************************************************************************************/
     static testmethod void run6(){
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
        
        //Opportunity Product creation
        invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod.Id,opp.Id);
        oppprod1.Name = 'Lawyers.com Preferred City Results';
        update oppprod1;                
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Lawyers.com Preferred City Results';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'Administrative Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'Independent City'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
         
         Id mhgeoRecordTypeId = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        //creating geo location record
        Geo_location__c geo                                    = util.getGeolocation('USA','NC','','Boston');
        geo.City_Inv_Flag__c = 'Yes';
         geo.RecordTypeId = mhgeoRecordTypeId;
        update geo; 
         
         Test.startTest();
         InventorySearchController ctrl = new InventorySearchController();
         ctrl.resetParameters();
         ctrl.selectedProdType = 'Lawyers.com Preferred City Results';
         ctrl.selectedareaOfPractice = 'Administrative Law';
         ctrl.searchCountry = 'USA';
         ctrl.searchState = 'NC';
         ctrl.searchCity = '';
         ctrl.searchCounty = 'Independent City';
        
        ctrl.runCountrySearch();
          Test.stopTest();
     }
     
}