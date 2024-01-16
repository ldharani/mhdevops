@isTest(seealldata=true)
public class createNgageFulfilmentCaseTest{
    
    static testMethod void testNgageFulfill(){
        
        //Id ngageAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_M_NG_Account).getRecordTypeId();
        Id ngageAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account acc = util.getAccount();
        acc.RecordTypeId =  ngageAccRecordTypeId ;
        Update acc;
        
        invoiceit_s__Currency__c curr = util.getCurrencyObject();
        
        Contact con = util.getContact(acc.Id);
        
        invoiceit_s__Product__c prod1 = util.getProduct('true');
        invoiceit_s__Product__c prod2 = util.getProduct('true');
        invoiceit_s__Product__c prod3 = util.getProduct('true');
        
        invoiceit_s__Product_Rate_Plan__c prp = util.getProductRatePlan(prod1.Id);
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(prod2.Id);
        invoiceit_s__Product_Rate_Plan__c prp3 = util.getProductRatePlan(prod3.Id);
        
        invoiceit_s__Product_Rate_Plan_Charge__c prpc = util.getProductRatePlanCharge(curr.Id , prp.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(curr.Id , prp2.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc3 = util.getProductRatePlanCharge(curr.Id , prp3.Id);
        
        //invoiceit_s__Job__c ord = util.getOrder(acc.Id , curr.Id );
        Opportunity opp = util.getOpportunity(acc.Id , con.id, curr.Id);
        
        
        invoiceit_s__Job__c ord = new invoiceit_s__Job__c();
        ord.Name = 'Test Order';
        ord.invoiceit_s__Account__c = acc.Id;
        ord.invoiceit_s__CurrencyL__c = curr.Id;
        ord.invoiceit_s__Status__c = 'In Progress';
        ord.invoiceit_crmx__Opportunity__c = opp.id;
        
        insert ord;
        
         
        //invoiceit_crmx__Opportunity_Product__c oppprod1 = util.getOpportunityProduct(prod1.Id,opp.Id); 
        
        invoiceit_s__Job_Product__c ordprod1 = new invoiceit_s__Job_Product__c(Name = 'Ngage Live Chat',invoiceit_s__Product_Code__c = '60010', invoiceit_s__Product__c = prod1.Id ,invoiceit_s__Job__c = ord.Id);
        insert ordprod1;
        
        invoiceit_s__Job_Product__c ordprod2 = new invoiceit_s__Job_Product__c(Name = 'Site Activation Fee',invoiceit_s__Product_Code__c = '60020', invoiceit_s__Product__c = prod2.Id ,invoiceit_s__Job__c = ord.Id);
        insert ordprod2;
        
        invoiceit_s__Job_Product__c ordprod3 = new invoiceit_s__Job_Product__c(Name = 'Facebook - Ngage Live Chat',invoiceit_s__Product_Code__c = '60050', invoiceit_s__Product__c = prod3.Id ,invoiceit_s__Job__c = ord.Id);
        insert ordprod3;
         
        invoiceit_s__Job_Rate_Plan__c ordrp1 = util.getOrderRatePlan(ordprod1.Id , prp.Id);
        invoiceit_s__Job_Rate_Plan__c ordrp2 = util.getOrderRatePlan(ordprod2.Id , prp2.Id);
        invoiceit_s__Job_Rate_Plan__c ordrp3 = util.getOrderRatePlan(ordprod3.Id , prp3.Id);
        
        invoiceit_s__Job_Rate_Plan_Charge__c ordrpc1 = util.getOrderRatePlanCharge(ordrp1.Id , prpc.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c ordrpc2 = util.getOrderRatePlanCharge(ordrp2.Id , prpc2.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c ordrpc3 = util.getOrderRatePlanCharge(ordrp3.Id , prpc3.Id);
        ordrpc3.Chat_Parent_Order_Rate_Plan_Charge__c = ordrpc1.id;
        update ordrpc3;
        
        List<Order_Charge_Attribute__c> textAreaAttrInsertList = new List<Order_Charge_Attribute__c>();
        
        Order_Charge_Attribute__c ordChargeAttr1 = util.getOrderCharges(ordrpc1.Id,'Text','URL');
        
        Order_Charge_Attribute__c ordChargeAttr2 = util.getOrderCharges(ordrpc2.Id,'Text','URL');
        Order_Charge_Attribute__c ordChargeAttr23 = util.getOrderCharges(ordrpc2.Id,'Picklist','abcd');
        Order_Charge_Attribute__c ordChargeAttr25 = util.getOrderCharges(ordrpc2.Id,'Number','123');
        Order_Charge_Attribute__c ordChargeAttr26 = util.getOrderCharges(ordrpc2.Id,'Boolean','True');
        Order_Charge_Attribute__c ordChargeAttr27 = util.getOrderCharges(ordrpc2.Id,'phone','324324234');
        Order_Charge_Attribute__c ordChargeAttr28 = util.getOrderCharges(ordrpc2.Id,'Date','324324234');
        Order_Charge_Attribute__c ordChargeAttr29 = util.getOrderCharges(ordrpc2.Id,'phone','324324234');
        //Order_Charge_Attribute__c ordChargeAttr30 = util.getOrderCharges(ordrpc2.Id,'Text Area','Test text Area');
        Order_Charge_Attribute__c  ordChargeAttr30  = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = ordrpc2.Id, Attribute_Type__c = 'Text Area', Attribute_Name__c = 'Text Area test', String_Value__c = 'Test123');
        textAreaAttrInsertList.add(ordChargeAttr30);
        
        Order_Charge_Attribute__c ordChargeAttr3 = util.getOrderCharges(ordrpc3.Id,'Text','URL');
        Order_Charge_Attribute__c ordChargeAttr4 = util.getOrderCharges(ordrpc3.Id,'Picklist','abcd');
        Order_Charge_Attribute__c ordChargeAttr5 = util.getOrderCharges(ordrpc3.Id,'Number','123');
        Order_Charge_Attribute__c ordChargeAttr6 = util.getOrderCharges(ordrpc3.Id,'Boolean','True');
        Order_Charge_Attribute__c ordChargeAttr7 = util.getOrderCharges(ordrpc3.Id,'phone','324324234');
        Order_Charge_Attribute__c ordChargeAttr8 = util.getOrderCharges(ordrpc3.Id,'Date','324324234');
        Order_Charge_Attribute__c ordChargeAttr9 = util.getOrderCharges(ordrpc3.Id,'phone','324324234');
       // Order_Charge_Attribute__c ordChargeAttr0 = util.getOrderCharges(ordrpc3.Id,'Text Area','Test text Area');
        Order_Charge_Attribute__c ordChargeAttr0 = new Order_Charge_Attribute__c(Order_Rate_Plan_Charge__c = ordrpc3.Id, Attribute_Type__c = 'Text Area', Attribute_Name__c = 'Text Area test', String_Value__c = 'Test123');
        textAreaAttrInsertList.add(ordChargeAttr0);
        
        insert textAreaAttrInsertList;
        List<invoiceit_s__Job__c > listOrders = new List<invoiceit_s__Job__c>();
        listOrders.add(ord);
        
        //createNgageFulfilmentCase controllr = new createNgageFulfilmentCase();
        
        Test.startTest();
        createNgageFulfilmentCase.fulfillCase(listOrders);
        
        ord.invoiceit_s__Status__c = 'Cancelled';
        ord.Loss_Reasons__c = 'Administrative';
        update ord; 
        Set<Id> cancelOrderIds = new Set<Id>();
        cancelOrderIds.add(ord.id);
        
        
       // createNgageFulfilmentCase.cancelCase(cancelOrderIds);
        
        createNgageFulfilmentCase classinstance = new createNgageFulfilmentCase();
        classinstance.FkMethod();
        
        case c = new case();
        c.Status = 'New';
        c.Parent_Order__c = ord.id;
        c.Subject = 'abcd';
        c.Origin = 'NgageSpt';
        c.Description = 'Test Ngage';
        c.Description__c = 'Test the description of Ngage products';
        c.Priority = 'High';
        c.Area__c = 'Order Update';
        c.Sub_Area__c = 'New Order';
        insert c;
        
        Test.stopTest();
    
    }  
}