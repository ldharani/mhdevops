@istest
public class Portal_OrderDetailsPageCntrl_Test   {
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
        
        product2 objproduct= new product2();
        objproduct.Name ='Test Product';
        objproduct.IsInventoried__c = True;
        objproduct.ProductCode = '11006';
        insert objproduct;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        list<Attribute_Lines__c> listofAL = new list<Attribute_Lines__c>();
        listofAL.add(objAL);
        
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('pendResponseFor400Response');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/xml');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();
        
        ApexPages.currentPage().getHeaders().put('Authorization','Authorization');
        ApexPages.currentPage().getHeaders().put('SMB_Authorization','SMB_Authorization');
        ApexPages.currentPage().getHeaders().put('UID','RefDomain');
        ApexPages.currentPage().getParameters().put('ordId',objOrder.id);
        Portal_OrderDetailsPageCntrl orderController = new Portal_OrderDetailsPageCntrl();
        Portal_OrderDetailsPageCntrl.Products prod = new Portal_OrderDetailsPageCntrl.Products();
        orderController.signOut();
        orderController.addtoList();
        orderController.getTotal_size();
        orderController.setTotal_size(4);
        orderController.Beginning();
        orderController.Previous();
        orderController.Next();
        orderController.End();
        orderController.setselectedSize('4');
        orderController.getselectedSize();
        orderController.SelectedCountSize();
        orderController.getPageNumber();
        orderController.setendNo(10);
        orderController.getpaginationOptions();
        orderController.CheckandInsertProducts(listofAL);
        orderController.getendNo();
        orderController.setstartNo(1);
        orderController.getstartNo();
        orderController.getDisableNext();
        orderController.getDisablePrevious();
        orderController.getTotalPages();
        orderController.getOrderDetails();
    }
}