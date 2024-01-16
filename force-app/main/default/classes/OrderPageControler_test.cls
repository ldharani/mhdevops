@istest(seealldata=true)
public class OrderPageControler_test {
    public static testmethod void runmethod1()
    {
        MDL_UtilClass_TestClass utlclass = new MDL_UtilClass_TestClass();
        account a = utlclass.getAccount();
        system.debug('Customer MH No. ' + a.MH_Cust_Number__c);
        contact c = utlclass.getContact(a.id);
        invoiceit_s__Currency__c cur = utlclass.getCurrencyObject();
        invoiceit_s__Product__c prod =  utlclass.getProduct('true');
        invoiceit_s__Product_Rate_Plan__c prt = utlclass.getProductRatePlan(prod.id);
        invoiceit_s__Product_Rate_Plan_Charge__c prpc =  utlclass.getProductRatePlanCharge(cur.id, prt.id);
        invoiceit_s__Job__c job = utlclass.getOrder(a.id, cur.id);
        invoiceit_s__Job_Product__c jp = utlclass.getOrderProduct(job.id, prod.id);
        invoiceit_s__Job_Rate_Plan__c ort = utlclass.getOrderRatePlan(jp.id, prt.id);
        invoiceit_s__Job_Rate_Plan_Charge__c orpc =  utlclass.getOrderRatePlanCharge(ort.id, prpc.id);
        Order_Charge_Attribute__c oca = utlClass.getOrderCharges(orpc.id, 'Text' , 'Service City');
        Order_Charge_Attribute__c oca1 = utlClass.getOrderCharges(orpc.id, 'Picklist' , 'Service State');
        ApexPages.currentPage().getParameters().put('c', a.MH_Cust_Number__c);
        OrdersPageController opc = new OrdersPageController();
        list<invoiceit_s__Job__c> ord =  opc.getOrders();
        ApexPages.currentPage().getParameters().put('ordid', job.id);
        ApexPages.currentPage().getParameters().put('c', a.MH_Cust_Number__c);
        OrdersPageController opc1 = new OrdersPageController();
        opc1.getOrders();
        opc1.Beginning();
        opc1.Next();
        opc1.Previous();
        opc1.End();
        opc1.getpaginationOptions();
        opc1.signOut();
        opc1.setTotal_size(ord.size());
        opc1.getTotal_size();
        opc1.setselectedSize('3');
        opc1.getselectedSize();
        opc1.SelectedCountSize();
        opc1.setendNo(1);
        opc1.getDisablePrevious();
        opc1.getDisableNext();
        opc1.setstartNo(1);
        opc1.getstartNo();
        opc1.getendNo();
    }

}