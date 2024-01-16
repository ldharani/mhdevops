@istest(seealldata=true)
public class OrderDetailsPageControlle_test {
 public static testmethod void runmethod1()
    {
        MDL_UtilClass_TestClass utlclass = new MDL_UtilClass_TestClass();
        account a = utlclass.getAccount();
        system.debug(a.MH_Cust_Number__c);
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
        ApexPages.currentPage().getParameters().put('ordid', job.id);
        OrderDetailsPageController opc = new OrderDetailsPageController();
        integer totsize = opc.getTotal_size();
        opc.setTotal_size(1);
        pageReference r = opc.signOut();
        list<OrderDetailsPageController.Products> op = new List<OrderDetailsPageController.Products>();
        op = opc.getOrderDetails();
        r = opc.Previous();
        r =opc.Next();
        r =opc.End();
        r =opc.Beginning();        
        opc.getpaginationOptions();
        opc.signOut();
        opc.setTotal_size(op.size());
        opc.getTotal_size();
        opc.setselectedSize('3');
        opc.getselectedSize();
        opc.SelectedCountSize();
        opc.setendNo(1);
        opc.getDisablePrevious();
        opc.getDisableNext();
        opc.setstartNo(1);
        opc.getstartNo();
        opc.getendNo();        
    }
}