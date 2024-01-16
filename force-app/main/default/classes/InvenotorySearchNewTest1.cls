/************************************************************
 * Author      : Sai Chandan
 * Description : Test Class for InventorySearchNew class
 * CreatedDate : 07/03/2018
 * **********************************************************/


@isTest(seeAllData = True)
public class InvenotorySearchNewTest1 {
    
    static testmethod void ConstructorTest(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
          //creating geo location record
         List<Geo_location__c>geoList = new List<Geo_location__c>();
        Geo_location__c geo         = util.getGeolocationWithoutInsert('USA','AZ','test','Ajio');
        geo.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo.State_Inv_Flag__c       = 'Yes';
         geo.City_Inv_Flag__c       = 'Yes';
         geo.County_Inv_Flag__c       = 'Yes';
        Geo_location__c geo1         = util.getGeolocationWithoutInsert('USA','AC','test','Ajij');
        geo1.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo1.State_Inv_Flag__c       = 'Yes';
         geo1.City_Inv_Flag__c       = 'Yes';
         geo1.County_Inv_Flag__c       = 'Yes';
       
        geoList.add(geo);
        geoList.add(geo1);
        
        //creating AOP Record here
        Id aopRecordTypeId    = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
        Geo_location__c geoaop = new Geo_location__c(AOP_List_value__c = '01667',AOP_Name__c = 'Administrative',
                                                       RecordTypeId = aopRecordTypeId);
         geoList.add(geoaop);
        insert geoList;
        
        InventorySearchNew ctrl = new InventorySearchNew();
        ctrl.selectedProdType   = 'Lawyers.com Preferred County Results';
        ctrl.aOPListBasedOnProduct();
        ctrl.resetParameters();
        Test.startTest();
         ctrl.statestrings = InventorySearchNew.refreshStateList('USA');
          ctrl.citystrings = InventorySearchNew.refreshcityList('USA', 'AC' ,' IndependentCity,AZ');
         ctrl.countytrings = InventorySearchNew.refreshcountyList('USA', 'AC,AZ');
        ctrl.getdynamicStatelist();
        ctrl.getdynamicCitylist();
        ctrl.getdynamicCountylist();
        Test.stopTest();
    
    }
    
    
    static testmethod void runsearchTest(){
          MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
          //creating geo location record
         List<Geo_location__c>geoList = new List<Geo_location__c>();
        Geo_location__c geo         = util.getGeolocationWithoutInsert('USA','AZ','test','Ajio');
        geo.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo.State_Inv_Flag__c       = 'Yes';
         geo.City_Inv_Flag__c       = 'Yes';
         geo.County_Inv_Flag__c       = 'Yes';
        Geo_location__c geo1         = util.getGeolocationWithoutInsert('USA','AC','test','Ajij');
        geo1.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo1.State_Inv_Flag__c       = 'Yes';
         geo1.City_Inv_Flag__c       = 'Yes';
         geo1.County_Inv_Flag__c       = 'Yes';
       
        geoList.add(geo);
        geoList.add(geo1);
        
        //creating AOP Record here
        Id aopRecordTypeId    = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
        Geo_location__c geoaop = new Geo_location__c(AOP_List_value__c = '01667',AOP_Name__c = 'Administrative',
                                                       RecordTypeId = aopRecordTypeId);
         geoList.add(geoaop);
        insert geoList;
        
        InventorySearchNew ctrl = new InventorySearchNew();
        List<string>ctrlist = new List<String>{'USA'};
        List<string>stlist = new List<String>{'AZ', 'AC'};
        List<string>ctlist = new List<String>{'Ajio', 'Ajij'};
        List<string>cntlist = new List<String>{'test', 'test'};
        InventorySearchNew.countryList    = ctrlist;
        InventorySearchNew.StateList      = stlist;
        InventorySearchNew.cityList        = ctlist;
        InventorySearchNew.countyList      = cntlist;
        
        Test.startTest();
        ctrl.selectedProdType = 'Lawyers.com Preferred National Results';
        ctrl.runsearch();
        
         ctrl.selectedProdType ='Lawyers.com Preferred State Results';
        ctrl.runsearch();
        
         ctrl.selectedProdType = 'Lawyers.com Preferred City Results';
        ctrl.runsearch();
        
        ctrl.selectedProdType = 'Lawyers.com Preferred County Results';
        ctrl.runsearch();
        Test.stopTest();
  
    }
    
    
    //Test for Country --> Lawyers.com Preferred National Results
    static testmethod void doSearchTest(){
        
        
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        
         //creating geo location record
         List<Geo_location__c>geoList = new List<Geo_location__c>();
        Geo_location__c geo         = util.getGeolocationWithoutInsert('USA','AZ','test','Ajio');
        geo.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo.State_Inv_Flag__c       = 'Yes';
         geo.City_Inv_Flag__c       = 'Yes';
         geo.County_Inv_Flag__c       = 'Yes';
        Geo_location__c geo1         = util.getGeolocationWithoutInsert('USA','AC','test','Ajij');
        geo1.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo1.State_Inv_Flag__c       = 'Yes';
         geo1.City_Inv_Flag__c       = 'Yes';
         geo1.County_Inv_Flag__c       = 'Yes';
       
        geoList.add(geo);
        geoList.add(geo1);
        
        //creating AOP Record here
        Id aopRecordTypeId    = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
        Geo_location__c geoaop = new Geo_location__c(AOP_List_value__c = '01667',AOP_Name__c = 'Administrative',
                                                       RecordTypeId = aopRecordTypeId);
         geoList.add(geoaop);
        insert geoList;
        
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
        oppprod1.Name = 'Lawyers.com Preferred National Results';
        oppprod1.InventoryID__c    = 'adfasdfsdf';
        
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
       
        
        //creating orderCharge Attributes
       List<Opportunity_Charge_Attribute__c> optychargeList = new  List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        //aop.Product_Type__c                                    = 'Lawyers.com Preferred National Results';
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'County', 'TestCounty');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'City', 'Ajio');
        optychargeList.add(aop);
          optychargeList.add(county);
          optychargeList.add(country);
          optychargeList.add(state);
          optychargeList.add(city);
        insert optychargeList;
        
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Lawyers.com Preferred National Results';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'test Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'TestCounty'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
        
         Test.startTest();
         InventorySearchNew ctrl = new InventorySearchNew();
         List<string> seleaopList = new List<string>{'test Law'};
         
         
         
        ctrl.selectedareaOfPracticeList = seleaopList;
        ctrl.selectedProdType           = 'Lawyers.com Preferred National Results';
        ctrl.selectedstatecity           = 'USA';
        //Test.startTest();
        ctrl.doSearch();
        Test.stopTest();
         
        
        
       
    }
    
    
    
    //Test for City--> Lawyers.com Preferred City Results
    static testmethod void doSearchScenario2(){
        
        
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        
         //creating geo location record
         List<Geo_location__c>geoList = new List<Geo_location__c>();
        Geo_location__c geo         = util.getGeolocationWithoutInsert('USA','AZ','test','Ajio');
        geo.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo.State_Inv_Flag__c       = 'Yes';
         geo.City_Inv_Flag__c       = 'Yes';
         geo.County_Inv_Flag__c       = 'Yes';
        Geo_location__c geo1         = util.getGeolocationWithoutInsert('USA','AC','test','Ajij');
        geo1.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo1.State_Inv_Flag__c       = 'Yes';
         geo1.City_Inv_Flag__c       = 'Yes';
         geo1.County_Inv_Flag__c       = 'Yes';
       
        geoList.add(geo);
        geoList.add(geo1);
        
        //creating AOP Record here
        Id aopRecordTypeId    = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
        Geo_location__c geoaop = new Geo_location__c(AOP_List_value__c = '01667',AOP_Name__c = 'Administrative',
                                                       RecordTypeId = aopRecordTypeId);
         geoList.add(geoaop);
        insert geoList;
        
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
        oppprod1.Name = 'Lawyers.com Preferred city Results';
        oppprod1.InventoryID__c    = 'adfasdfsdf';
        
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
       
        
        //creating orderCharge Attributes
       List<Opportunity_Charge_Attribute__c> optychargeList = new  List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        //aop.Product_Type__c                                    = 'Lawyers.com Preferred National Results';
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'County', 'TestCounty');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'City', 'Ajio');
        optychargeList.add(aop);
          optychargeList.add(county);
          optychargeList.add(country);
          optychargeList.add(state);
          optychargeList.add(city);
        insert optychargeList;
        
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
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'TestCounty'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
         
         Test.startTest();
         InventorySearchNew ctrl = new InventorySearchNew();
        List<string> seleaopList = new List<string>{'Administrative Law'};
         
         
         ctrl.selectedareaOfPracticeList = seleaopList;
         ctrl.selectedProdType           = 'Lawyers.com Preferred City Results';
         ctrl.selectedstatecity           = 'USA, AZ, Ajio';
          
        
         ctrl.doSearch();
        Test.stopTest();
         
        
        
       
    }
    
    //Test for State --> Lawyers.com Preferred State Results
    static testmethod void doSearchScenario3(){
        
        
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        
         //creating geo location record
         List<Geo_location__c>geoList = new List<Geo_location__c>();
        Geo_location__c geo         = util.getGeolocationWithoutInsert('USA','AZ','test','Ajio');
        geo.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo.State_Inv_Flag__c       = 'Yes';
         geo.City_Inv_Flag__c       = 'Yes';
         geo.County_Inv_Flag__c       = 'Yes';
        Geo_location__c geo1         = util.getGeolocationWithoutInsert('USA','AC','test','Ajij');
        geo1.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo1.State_Inv_Flag__c       = 'Yes';
         geo1.City_Inv_Flag__c       = 'Yes';
         geo1.County_Inv_Flag__c       = 'Yes';
       
        geoList.add(geo);
        geoList.add(geo1);
        
        //creating AOP Record here
        Id aopRecordTypeId    = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
        Geo_location__c geoaop = new Geo_location__c(AOP_List_value__c = '01667',AOP_Name__c = 'Administrative',
                                                       RecordTypeId = aopRecordTypeId);
         geoList.add(geoaop);
        insert geoList;
        
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
        oppprod1.Name = 'Lawyers.com Preferred State Results';
        oppprod1.InventoryID__c    = 'adfasdfsdf';
        
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
       
        
        //creating orderCharge Attributes
       List<Opportunity_Charge_Attribute__c> optychargeList = new  List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        //aop.Product_Type__c                                    = 'Lawyers.com Preferred National Results';
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'County', 'TestCounty');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'City', 'Ajio');
        optychargeList.add(aop);
          optychargeList.add(county);
          optychargeList.add(country);
          optychargeList.add(state);
          optychargeList.add(city);
        insert optychargeList;
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Lawyers.com Preferred State Results';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'Administrative Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'TestCounty'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
         
         Test.startTest();
         InventorySearchNew ctrl = new InventorySearchNew();
        List<string> seleaopList = new List<string>{'Administrative Law'};
         
         
         ctrl.selectedareaOfPracticeList = seleaopList;
         ctrl.selectedProdType           = 'Lawyers.com Preferred State Results';
         ctrl.selectedstatecity           = 'USA, AZ';
          
        
         ctrl.doSearch();
        Test.stopTest();
         
        
        
       
    }
    
    
    //Test for County --> Lawyers.com Preferred County Results
    static testmethod void doSearchScenario4(){
        
        
         MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        
        
         //creating geo location record
         List<Geo_location__c>geoList = new List<Geo_location__c>();
        Geo_location__c geo         = util.getGeolocationWithoutInsert('USA','AZ','test','Ajio');
        geo.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo.State_Inv_Flag__c       = 'Yes';
         geo.City_Inv_Flag__c       = 'Yes';
         geo.County_Inv_Flag__c       = 'Yes';
        Geo_location__c geo1         = util.getGeolocationWithoutInsert('USA','AC','test','Ajij');
        geo1.RecordTypeId            = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        geo1.State_Inv_Flag__c       = 'Yes';
         geo1.City_Inv_Flag__c       = 'Yes';
         geo1.County_Inv_Flag__c       = 'Yes';
       
        geoList.add(geo);
        geoList.add(geo1);
        
        //creating AOP Record here
        Id aopRecordTypeId    = Schema.SObjectType.Geo_location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
        Geo_location__c geoaop = new Geo_location__c(AOP_List_value__c = '01667',AOP_Name__c = 'Administrative',
                                                       RecordTypeId = aopRecordTypeId);
         geoList.add(geoaop);
        insert geoList;
        
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
        oppprod1.Name = 'Lawyers.com Preferred County Results';
        oppprod1.InventoryID__c    = 'adfasdfsdf';
        
        update oppprod1;
        
        //Opportunity rate plan creation
        invoiceit_crmx__Opportunity_Rate_Plan__c opprp         = util.getOpportunityRatePlan(oppprod1.Id , prodrateplan.Id);        
        //opportunity rate plan charge creation
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opprpc = util.getOppRatePlanCharge(opprp.Id , prodRatePlanCharge.Id);
       
        
        //creating orderCharge Attributes
       List<Opportunity_Charge_Attribute__c> optychargeList = new  List<Opportunity_Charge_Attribute__c>();
        Opportunity_Charge_Attribute__c aop                    = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'AOP', 'Administrative Law');
        //aop.Product_Type__c                                    = 'Lawyers.com Preferred National Results';
        Opportunity_Charge_Attribute__c county                 = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'County', 'TestCounty');
        Opportunity_Charge_Attribute__c country                = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Text', 'Country', 'USA');
        Opportunity_Charge_Attribute__c state                  = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'State', 'AZ');
        Opportunity_Charge_Attribute__c city                   = util.getOpportunityChargeAttributes_noInsert(opprpc.id, 'Picklist', 'City', 'Ajio');
        optychargeList.add(aop);
          optychargeList.add(county);
          optychargeList.add(country);
          optychargeList.add(state);
          optychargeList.add(city);
        insert optychargeList;
        
        //order creation
        invoiceit_s__Job__c order                                   = util.getOrder(acc.Id, curr.id);
        
        //order product creation
        invoiceit_s__Job_Product__c orderprod                       = util.getOrderProduct(order.Id, prod.Id);
        orderprod.name   = 'Lawyers.com Preferred County Results';
         update orderprod;
        
        //order rate plan creation
        invoiceit_s__Job_Rate_Plan__c orderrateplan                 = util.getOrderRatePlan(orderprod.id, prodrateplan.id);
        
        //order rate plan charge creation
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge    = util.getOrderRatePlanCharge(orderrateplan.id, prodRatePlanCharge.id);
        
        //creating orderCharge Attributes
        List<Order_Charge_Attribute__c> orderchargattlist    =  new List<Order_Charge_Attribute__c>();
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Picklist', 'AOP', 'Administrative Law'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'County', 'TestCounty'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'Country', 'USA'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'State', 'NC'));
         orderchargattlist.add(util.getOrderChargeAttributes_noInsert(orderRatePlanCharge.id, 'Text', 'City', 'Boston'));
         insert orderchargattlist;
         
         Test.startTest();
         InventorySearchNew ctrl = new InventorySearchNew();
        List<string> seleaopList = new List<string>{'Administrative Law'};
         
         
         ctrl.selectedareaOfPracticeList = seleaopList;
         ctrl.selectedProdType           = 'Lawyers.com Preferred County Results';
         ctrl.selectedstatecity           = 'USA, AZ, Apache';
          
        
         ctrl.doSearch();
        Test.stopTest();
         
        
        
       
    }
    

}