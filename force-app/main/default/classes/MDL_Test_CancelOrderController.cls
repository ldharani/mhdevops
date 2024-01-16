@isTest(seealldata=true)
public with sharing class MDL_Test_CancelOrderController {
    static testmethod void cancelOrdertest(){
        
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account account1 = util.getAccount();
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        invoiceit_s__Job__c order1 = util.getOrder(account1.Id, currency1.Id);
        order1.invoiceit_s__Status__c = 'Active';       
        update order1;      
        invoiceit_s__Product__c product1 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp1 = util.getProductRatePlan(product1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc1 = util.getProductRatePlanCharge(currency1.Id, prp1.Id);
        prpc1.Package_Wrapper__c = true;
        insert prpc1;        
        
        invoiceit_s__Job_Product__c orderproduct1 = util.getOrderProduct(order1.Id , product1.Id);
        invoiceit_s__Job_Rate_Plan__c orp1 = util.getOrderRatePlan(orderproduct1.Id , prp1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc1 = util.getOrderRatePlanCharge( orp1.Id ,prpc1.Id );
        orpc1.invoiceit_s__Status__c = 'Active';                
        update orpc1;
        
        Chat_Product_Order_Charge__c chatPOC = new Chat_Product_Order_Charge__c();
        chatPOC.Chat_Usage_Order_Rate_Plan_Charge__c = orpc1.Id;
        chatPOC.Chat_Product_Order_Rate_Plan_Charge__c = orpc1.Id; 
        insert chatPOC;
        
        invoiceit_s__Product__c product2 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(product2.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(currency1.Id, prp2.Id);
        prpc2.Package_Component__c = true;
        insert prpc2;
        
        invoiceit_s__Job_Product__c orderproduct2 = util.getOrderProduct(order1.Id , product2.Id);
        invoiceit_s__Job_Rate_Plan__c orp2 = util.getOrderRatePlan(orderproduct2.Id , prp2.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc2 = util.getOrderRatePlanCharge( orp2.Id ,prpc2.Id );        
        orpc2.invoiceit_s__Price_Type__c = 'One Time';        
        update orpc2;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(order1);
        MDL_CancelOrderController coc = new MDL_CancelOrderController(sc);
        
        if(coc.lstInnerClassORPC.size()>0){
            coc.lstInnerClassORPC[0].isChecked = true;
            coc.lstInnerClassORPC[0].orderRPC.Loss_Reasons__c = 'Price too High';
            coc.packageWrap = coc.lstInnerClassORPC[0];
        }
        if(coc.lstInnerClassORPC.size()>1){
            coc.lstInnerClassORPC[1].isChecked = true;
            coc.lstInnerClassORPC[1].orderRPC.Loss_Reasons__c = 'Price too High';
            coc.independentWrap = coc.lstInnerClassORPC;
        }
        Pagereference cancelcharges_page = coc.cancelCharges();       
        List<SelectOption> selectitems = coc.getItems();
        Pagereference cancel_page = coc.cancel();
        coc.PageNumber = 1;
        coc.changeList();
        coc.initialize();
                
        order1.invoiceit_s__Status__c = 'Cancelled';
        order1.Loss_Reasons__c = 'Price too High';
        update order1;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(order1);
        MDL_CancelOrderController coc1 = new MDL_CancelOrderController(sc1);
        Pagereference cancel_page1 = coc1.cancel();
        Pagereference cancelcharges_page1 = coc1.cancelCharges();
        Pagereference cancelcharges_page2 = coc1.updateIndependentCharges();
        
        order1.Renew_Rebase__c = 'Renew';
        update order1;
        
        try{
            ApexPages.StandardController sc2 = new ApexPages.StandardController(order1);
            MDL_CancelOrderController coc2 = new MDL_CancelOrderController(sc2);
        }catch(Exception e){}
        
        order1.Renew_Rebase__c = 'Rebase';
        update order1;
        
        try{
            ApexPages.StandardController sc3 = new ApexPages.StandardController(order1);
            MDL_CancelOrderController coc3 = new MDL_CancelOrderController(sc3);
        }catch(Exception e){}
        
        
        Test.stopTest();        
    }
    static testMethod void cancelOrder(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account account1 = util.getAccount();
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        String recordTypeId = [Select Id,DeveloperName From RecordType Where SobjectType = 'invoiceit_s__Job__c' and DeveloperName = 'M_N_Order'].Id;
        invoiceit_s__Job__c order1 = util.getOrder(account1.Id, currency1.Id);
        order1.invoiceit_s__Status__c = 'Active';
        order1.RecordTypeId = recordTypeId;       
        update order1;
              
        invoiceit_s__Product__c product1 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp1 = util.getProductRatePlan(product1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc1 = util.getProductRatePlanCharge(currency1.Id, prp1.Id);
        prpc1.Package_Wrapper__c = true;
        
        invoiceit_s__Job_Product__c orderproduct1 = util.getOrderProduct(order1.Id , product1.Id);
        invoiceit_s__Job_Rate_Plan__c orp1 = util.getOrderRatePlan(orderproduct1.Id , prp1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc1 = util.getOrderRatePlanCharge( orp1.Id ,prpc1.Id );
        orpc1.invoiceit_s__Status__c = 'Active';        
        update orpc1;
        
        invoiceit_s__Product__c product2 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(product2.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(currency1.Id, prp2.Id);
        
        invoiceit_s__Job_Product__c orderproduct2 = util.getOrderProduct(order1.Id , product2.Id);
        invoiceit_s__Job_Rate_Plan__c orp2 = util.getOrderRatePlan(orderproduct2.Id , prp2.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc2 = util.getOrderRatePlanCharge( orp2.Id ,prpc2.Id );
        orpc2.invoiceit_s__Price_Type__c = 'One Time';
        
        update orpc2;
        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(order1);
        MDL_CancelOrderController coc1 = new MDL_CancelOrderController(sc1);
        
        if(coc1.lstInnerClassORPC.size()>1){
            coc1.lstInnerClassORPC[1].isChecked = true;
            coc1.lstInnerClassORPC[1].orderRPC.invoiceit_s__Status__c = 'Active';
            coc1.lstInnerClassORPC[1].orderRPC.Loss_Reasons__c = 'Price too High';
            coc1.lstInnerClassORPC[1].orderRPC.invoiceit_s__Price_Type__c = 'OneTime';            
            coc1.packageWrap = coc1.lstInnerClassORPC[0];
            coc1.componentWrap = coc1.lstInnerClassORPC;
            coc1.independentWrap = coc1.lstInnerClassORPC;
        }
        coc1.radiobuttonstatus = 'No';
        coc1.selVal = 'Price Too High';
        Pagereference updatecharges_page1 = coc1.updateAllCharges();
        //Pagereference cancelcharges_page2 = coc1.updateIndependentCharges();
        Test.stopTest();
    }
    static testMethod void cancelOrder1(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account account1 = util.getAccount();
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        String recordTypeId = [Select Id,DeveloperName From RecordType Where SobjectType = 'invoiceit_s__Job__c' and DeveloperName = 'M_N_Order'].Id;
        invoiceit_s__Job__c order1 = util.getOrder(account1.Id, currency1.Id);
        order1.invoiceit_s__Status__c = 'Active';
        order1.RecordTypeId = recordTypeId;       
        update order1;
              
        invoiceit_s__Product__c product1 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp1 = util.getProductRatePlan(product1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc1 = util.getProductRatePlanCharge(currency1.Id, prp1.Id);
        prpc1.Package_Wrapper__c = true;
        
        invoiceit_s__Job_Product__c orderproduct1 = util.getOrderProduct(order1.Id , product1.Id);
        invoiceit_s__Job_Rate_Plan__c orp1 = util.getOrderRatePlan(orderproduct1.Id , prp1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc1 = util.getOrderRatePlanCharge( orp1.Id ,prpc1.Id );
        orpc1.invoiceit_s__Status__c = 'Active';        
        update orpc1;
        
        invoiceit_s__Product__c product2 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(product2.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(currency1.Id, prp2.Id);
        
        invoiceit_s__Job_Product__c orderproduct2 = util.getOrderProduct(order1.Id , product2.Id);
        invoiceit_s__Job_Rate_Plan__c orp2 = util.getOrderRatePlan(orderproduct2.Id , prp2.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc2 = util.getOrderRatePlanCharge( orp2.Id ,prpc2.Id );
        orpc2.invoiceit_s__Price_Type__c = 'One Time';        
        
        update orpc2;
        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(order1);
        MDL_CancelOrderController coc1 = new MDL_CancelOrderController(sc1);
        
        if(coc1.lstInnerClassORPC.size()>1){
            coc1.lstInnerClassORPC[1].isChecked = true;            
            coc1.lstInnerClassORPC[1].orderRPC.invoiceit_s__Status__c = 'Active';
            coc1.lstInnerClassORPC[1].orderRPC.Loss_Reasons__c = 'Price too High';
            coc1.lstInnerClassORPC[1].orderRPC.invoiceit_s__Price_Type__c = 'One Time';
            coc1.packageWrap = coc1.lstInnerClassORPC[0];
            coc1.componentWrap = coc1.lstInnerClassORPC;
            coc1.independentWrap = coc1.lstInnerClassORPC;
        }
        coc1.radiobuttonstatus = 'No';
        coc1.selVal = 'Price Too High';
        Pagereference updatecharges_page1 = coc1.updateAllCharges();
        //Pagereference cancelcharges_page2 = coc1.updateIndependentCharges();
        coc1.selVal = '--None--';
        Pagereference updatecharges_page2 = coc1.updateAllCharges();
        Test.stopTest();
    }
    static testMethod void cancelExpiredOrder(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account account1 = util.getAccount();
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        invoiceit_s__Job__c order1 = util.getOrder(account1.Id, currency1.Id);
                
        invoiceit_s__Product__c product1 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp1 = util.getProductRatePlan(product1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc1 = util.getProductRatePlanCharge(currency1.Id, prp1.Id);
        
        invoiceit_s__Job_Product__c orderproduct1 = util.getOrderProduct(order1.Id , product1.Id);
        invoiceit_s__Job_Rate_Plan__c orp1 = util.getOrderRatePlan(orderproduct1.Id , prp1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc1 = util.getOrderRatePlanCharge( orp1.Id ,prpc1.Id );
        test.starttest();
        order1.invoiceit_s__Status__c = 'Expired';      
        update order1;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(order1);
        MDL_CancelOrderController coc = new MDL_CancelOrderController(sc);
            
        test.stopTest();
    }
    static testMethod void cancelOrderIndCharges(){
        MDL_UtilClass_TestClass util = new MDL_UtilClass_TestClass();
        Account account1 = util.getAccount();
        invoiceit_s__Currency__c currency1 = util.getCurrencyObject();
        String recordTypeId = [Select Id,DeveloperName From RecordType Where SobjectType = 'invoiceit_s__Job__c' and DeveloperName = 'M_N_Order'].Id;
        invoiceit_s__Job__c order1 = util.getOrder(account1.Id, currency1.Id);
        order1.invoiceit_s__Status__c = 'Active';
        order1.RecordTypeId = recordTypeId;       
        update order1;
              
        invoiceit_s__Product__c product1 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp1 = util.getProductRatePlan(product1.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc1 = util.getProductRatePlanCharge(currency1.Id, prp1.Id);
        prpc1.Package_Wrapper__c = true;
        
        invoiceit_s__Job_Product__c orderproduct1 = util.getOrderProduct(order1.Id , product1.Id);
        invoiceit_s__Job_Rate_Plan__c orp1 = util.getOrderRatePlan(orderproduct1.Id , prp1.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc1 = util.getOrderRatePlanCharge( orp1.Id ,prpc1.Id );
        orpc1.invoiceit_s__Status__c = 'Active';        
        update orpc1;
        
        invoiceit_s__Product__c product2 = util.getProduct('False');
        invoiceit_s__Product_Rate_Plan__c prp2 = util.getProductRatePlan(product2.Id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc2 = util.getProductRatePlanCharge(currency1.Id, prp2.Id);
        
        invoiceit_s__Job_Product__c orderproduct2 = util.getOrderProduct(order1.Id , product2.Id);
        invoiceit_s__Job_Rate_Plan__c orp2 = util.getOrderRatePlan(orderproduct2.Id , prp2.Id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc2 = util.getOrderRatePlanCharge( orp2.Id ,prpc2.Id );
        orpc2.invoiceit_s__Price_Type__c = 'One Time';
        
        update orpc2;
        Test.startTest();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(order1);
        MDL_CancelOrderController coc1 = new MDL_CancelOrderController(sc1);
        
        if(coc1.lstInnerClassORPC.size()>1){
            coc1.lstInnerClassORPC[1].isChecked = true;
            coc1.lstInnerClassORPC[1].orderRPC.invoiceit_s__Status__c = 'Active';
            coc1.lstInnerClassORPC[1].orderRPC.Loss_Reasons__c = 'Price too High';
            coc1.packageWrap = coc1.lstInnerClassORPC[0];
            coc1.componentWrap = coc1.lstInnerClassORPC;
            coc1.independentWrap = coc1.lstInnerClassORPC;
        }
        coc1.radiobuttonstatus = 'No';
        coc1.selVal = 'Price Too High';        
        Pagereference cancelcharges_page1 = coc1.updateIndependentCharges();
        MDL_CancelOrderController.getPicklistValues(new invoiceit_s__Job__c(),'Loss_Reasons__c');
        
        coc1.selVal = '--None--';
        Pagereference cancelcharges_page2 = coc1.updateIndependentCharges();
        Test.stopTest();
    }   
}