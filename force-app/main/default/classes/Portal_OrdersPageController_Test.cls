@istest
public class Portal_OrdersPageController_Test   {
    public static testmethod void testMethodA() {
        CSC_token__c cc = new CSC_token__c();
        cc.Actual_Token__c = 'ExpectedToken';
        cc.Name = 'ExpectedToken';
        insert cc;
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Id strMAIntakeRecTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('M-A Intake Order').getRecordTypeId();
        List<Order> listOrder = new List<Order>();
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.RecordtypeId = strMAIntakeRecTypeId;
        objOrder.Status = 'Draft';
        objOrder.EffectiveDate = system.today();
        objOrder.EndDate = system.today() + 4;
        objOrder.AccountId = lstAcc[0].id;
        objOrder.Pricebook2Id = Test.getStandardPricebookId();
        objOrder.blng__BillingDayOfMonth__c = '1';
        insert objOrder;
        listOrder.add(objOrder);
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('pendResponseFor400Response');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();
        
        ApexPages.currentPage().getHeaders().put('Authorization','Authorization');
        ApexPages.currentPage().getHeaders().put('SMB_Authorization','SMB_Authorization');
        Portal_OrdersPageController orderController = new Portal_OrdersPageController();
        orderController.signOut();
        orderController.getOrders();
        orderController.addtoList();
        orderController.setTotal_size(listOrder.size());
        orderController.getTotal_size();
        orderController.Previous();
        orderController.Next();
        orderController.End();
        orderController.setselectedSize('3');
        orderController.getpaginationOptions();
        orderController.SelectedCountSize();
        orderController.getDisablePrevious();
        orderController.getDisableNext();
        orderController.getstartNo();
        orderController.setstartNo(1);
        orderController.getendNo();
        orderController.getselectedSize();
        orderController.setendNo(2);
    }
}