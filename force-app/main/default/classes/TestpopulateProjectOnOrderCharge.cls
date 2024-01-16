@isTest(seealldata=true)
public class TestpopulateProjectOnOrderCharge{
    static testMethod void testPopulateProjectOnOrderChargeAttribute1(){
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        
        Account a = testData.getAccount();
        
        Contact c = testData.getContact(a.Id);  
        
        invoiceit_s__Currency__c currencyObj = testData.getCurrencyObject();
        
        invoiceit_s__Product__c product = testData.getProduct('false');
        product.Product_Provisioning__c = 'Manual Fulfillment';
        update product;
        Date validtodate = Date.today();
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
        Opportunity Opportunityobj = testData.getOpportunity(a.Id, c.Id, currencyObj.Id);
        
        
        
        invoiceit_crmx__Opportunity_Product__c opportunityproductobj= new invoiceit_crmx__Opportunity_Product__c(Name='Product', invoiceit_crmx__SequenceNumber__c=1,invoiceit_crmx__Opportunity__c=Opportunityobj.Id ,invoiceit_crmx__Product__c = product.Id);
        insert opportunityproductobj;
        
        invoiceit_crmx__Opportunity_Rate_Plan__c opportunityproductrateplanobj=new invoiceit_crmx__Opportunity_Rate_Plan__c(Name='Rate plan',invoiceit_crmx__Opportunity_Product__c=opportunityproductobj.Id ,invoiceit_crmx__Product_Rate_Plan__c = listProductRatePlans[0].id);
        insert opportunityproductrateplanobj;
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Opportunityrateplanchargeobj= new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c(Name='charge',invoiceit_crmx__Opportunity_Rate_Plan__c=opportunityproductrateplanobj.Id ,invoiceit_crmx__Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].id);
        insert Opportunityrateplanchargeobj;
        
        Opportunity_Charge_Attribute__c Opportunitychargeattributeobj=new Opportunity_Charge_Attribute__c(Attribute_Name__c='Ring to Number',Attribute_Order__c=2,Attribute_Picklist_Values__c='1',Picklist_Value__c='1',Required__c=true,Maximum_No_Of_Characters_In_Text__c=18,Minimum_No_Of_Characters_In_Text__c=25,Attribute_Type__c='Picklist',Boolean_Value__c=true,
                                                                                                          Date_Value__c=system.today(),Phone_Value__c='12345',Number_Value__c=12,String_Value__c='40',Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id);
        insert Opportunitychargeattributeobj;        
        
        
        list<Opportunity_Charge_Attribute__c> listofOpportunitychargeattributeobj = new list<Opportunity_Charge_Attribute__c>();
        //Commented by Sai C for county id code
        
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'State', Picklist_Value__c = 'test'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'County', Picklist_Value__c = 'test'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Picklist', Attribute_Name__c = 'City', Picklist_Value__c = 'test'));
        //listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id, Attribute_Type__c = 'Text', Attribute_Name__c  = 'Test', String_Value__c = 'te'));
        listofOpportunitychargeattributeobj.add(new Opportunity_Charge_Attribute__c(Opportunity_Rate_Plan_Charge__c=Opportunityrateplanchargeobj.Id,  Attribute_Type__c = 'String', Attribute_Name__c = 'AOP/Geo 1', String_Value__c = 'E-Commerce ; GU ; N/A ; Happy Jack ;'));
        
        insert listofOpportunitychargeattributeobj;               
        List<Id> ids = new List<Id>();
        for(Opportunity_Charge_Attribute__c o:listofOpportunitychargeattributeobj){
            ids.add(o.id);
        } 
        
        invoiceit_s__Job__c order = testData.getOrder(a.Id, CurrencyObj.Id);
        
        invoiceit_s__Job_Product__c orderProduct = testdata.getOrderProduct(order.Id, product.Id);
        invoiceit_s__Job_Rate_Plan__c orderRatePlan = testdata.getOrderRatePlan(OrderProduct.Id, productRatePlan.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRatePlanCharge =  new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'jobcharge', invoiceit_s__Job_Rate_Plan__c =orderRatePlan.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                               invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                                                               Quote_Type__c = 'Renew', invoiceit_s__Accounting_Code__c='01808',
                                                                                               invoiceit_s__Price__c=10);
        
        Test.startTest();
        insert orderRatePlanCharge;
        
        invoiceit_s__Job_Rate_Plan_Charge__c charge1= new invoiceit_s__Job_Rate_Plan_Charge__c(Name = 'charge', invoiceit_s__Job_Rate_Plan__c =orderRatePlan.Id,
                                                                                               invoiceit_s__Quantity__c = 12, invoiceit_s__Price_Type__c = 'One Time',
                                                                                               invoiceit_s__Unit_Price__c = 12,invoiceit_s__Service_Activation_Date__c = system.today(),
                                                                                               invoiceit_s__Service_End_Date__c = system.today().addMonths(5),
                                                                                               Quote_Type__c = 'Renew', Created_From_Charge__c = orderRatePlanCharge.id,
                                                                                               invoiceit_s__Accounting_Code__c='01808',
                                                                                               invoiceit_s__Price__c=10);
        
        Milestone1_Project__c proj1 = new Milestone1_Project__c(Name = 'Platinum Project', Status__c = 'New', Next_Monthly_Milestone_Maintenance_Date__c = System.today(), 
                                                                Next_Quarterly_Milestone_Maint_Date__c = System.Today(),No_of_Maintenance_Milestone__c = 5,
                                                                Order_Rate_Plan_Charge__c=charge1.id, Account__c = a.id,Order__c = order.Id);
        
        insert proj1;
        
        Milestone1_Project__c proj2 = new Milestone1_Project__c(Name = 'Gold Project', Status__c = 'New', Next_Monthly_Milestone_Maintenance_Date__c = System.today(), 
                                                                Next_Quarterly_Milestone_Maint_Date__c = System.Today(),No_of_Maintenance_Milestone__c = 5,
                                                                Order_Rate_Plan_Charge__c=orderRatePlanCharge.id, Account__c = a.id,Order__c = order.Id);
        
        insert proj2; 
        
        
        //populateProjectOnOrderChargeAttribute ctrl= new populateProjectOnOrderChargeAttribute();
        populateProjectOnOrderChargeAttribute.projectUpdateFromProcess(ids);
        
        
    }
    
    static testmethod void run2condition(){
        
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        Account acc = testData.getAccount();
        
        Contact c = testData.getContact(acc.Id);
        
        invoiceit_s__Currency__c cur = testData.getCurrencyObject();
        
        invoiceit_s__Product__c prod1 = testData.getProduct('true');
        
        invoiceit_s__Product_Rate_Plan__c pRatePlan1 = testData.getProductRatePlan(prod1.Id);
        
        list<invoiceit_s__Product_Rate_Plan_Charge__c> productCharges = new List<invoiceit_s__Product_Rate_Plan_Charge__c>();
        invoiceit_s__Product_Rate_Plan_Charge__c rpc1 = testData.getProductRatePlanCharge(cur.Id, pRatePlan1.Id);
         invoiceit_s__Product_Rate_Plan_Charge__c rpc2 = testData.getProductRatePlanCharge(cur.Id, pRatePlan1.Id);
        productCharges.add(rpc1);
        productCharges.add(rpc2);
        insert productCharges;
        
          Opportunity o = testData.getOpportunity(acc.Id, c.Id, cur.Id);
        
         invoiceit_s__Job__c order1 = testData.getOrder(acc.Id, cur.Id);
       // order1.invoiceit_crmx__Opportunity__c = o.id;
       // update order1;
        
        invoiceit_s__Job_Product__c orderProd1 = testData.getOrderProduct(order1.Id, prod1.Id);
        invoiceit_s__Job_Rate_Plan__c orderRP1 = testData.getOrderRatePlan(orderProd1.Id, pRatePlan1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC1 = testData.getOrderRatePlanCharge(orderRP1.Id, rpc1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orderRPC2 = testData.getOrderRatePlanCharge(orderRP1.Id, rpc1.Id);
        
      
        
        invoiceit_crmx__Opportunity_Product__c oppProd = testData.getOpportunityProduct(prod1.Id, o.Id);
        
        invoiceit_crmx__Opportunity_Rate_Plan__c oppRP = testData.getOpportunityRatePlan(oppProd.Id, pRatePlan1.Id);
        
        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oRPC = testData.getOppRatePlanCharge(oppRP.Id, rpc1.Id);
        
        List<Milestone1_Project__c> projlist = new List<Milestone1_Project__c>();
         Milestone1_Project__c p = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject');
        p.Account__c = acc.Id;
        p.Order__c = order1.id;
        p.Order_Rate_Plan_Charge__c = orderRPC1.id;
        projlist.add(p);
           Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('TaskCompProject1');
        p1.Account__c = acc.Id;
        p1.Order__c = order1.id;
        p1.Order_Rate_Plan_Charge__c = orderRPC2.id;
        projlist.add(p1);
        insert projlist;  
        
        List<Opportunity_Charge_Attribute__c> optychargeAttributeList = new List<Opportunity_Charge_Attribute__c>();
       Opportunity_Charge_Attribute__c charge1 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'City');
        charge1.Project__c = projlist[0].id;
        optychargeAttributeList.add(charge1);
        Opportunity_Charge_Attribute__c charge2 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'State');
         charge2.Project__c = projlist[0].id;
         optychargeAttributeList.add(charge2);
        Opportunity_Charge_Attribute__c charge3 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'County');
         charge3.Project__c = projlist[0].id;
        optychargeAttributeList.add(charge3);
        Opportunity_Charge_Attribute__c charge4 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'Country');
         charge4.Project__c = projlist[0].id;
         optychargeAttributeList.add(charge4);
        Opportunity_Charge_Attribute__c charge5 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Picklist', 'AOP/Geo');
         charge5.Project__c = projlist[0].id;
         optychargeAttributeList.add(charge5);
        Opportunity_Charge_Attribute__c charge6 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'Service Account Name');
         charge6.Project__c = projlist[0].id;
         optychargeAttributeList.add(charge6);
        
         Opportunity_Charge_Attribute__c charge7 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'City');
         charge7.Project__c = projlist[1].id;
         optychargeAttributeList.add(charge7);
        Opportunity_Charge_Attribute__c charge8 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'State');
         charge8.Project__c = projlist[0].id;
         optychargeAttributeList.add(charge8);
        Opportunity_Charge_Attribute__c charge9 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'County');
         charge9.Project__c = projlist[1].id;
         optychargeAttributeList.add(charge9);
        Opportunity_Charge_Attribute__c charge10 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'Country');
         charge10.Project__c = projlist[1].id;
         optychargeAttributeList.add(charge10);
        Opportunity_Charge_Attribute__c charge11 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Picklist', 'AOP/Geo');
         charge11.Project__c = projlist[1].id;
           optychargeAttributeList.add(charge11);
        Opportunity_Charge_Attribute__c charge12 = testData.getOppChargeswithoutInsert(oRPC.Id, 'Text', 'Service Account Name');
         charge12.Project__c = projlist[1].id;
           optychargeAttributeList.add(charge12);
        insert optychargeAttributeList;
        
        Test.startTest();
        populateProjectOnOrderChargeAttribute.projectUpdateFromProcess(new List<Id>{order1.id});
        Test.stopTest();
        
    }
}