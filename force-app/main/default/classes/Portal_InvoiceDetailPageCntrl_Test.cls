@isTest
public class Portal_InvoiceDetailPageCntrl_Test {
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"email":"are02@gmail.com","LastName":"ABCD","FirstName":"ACFPY","Suffix":"","Title":"Engineer","Psw":"","PhoneCode":"","Phone":"100-000-000"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    private static testmethod void testMethodA(){
        CSC_token__c cc = new CSC_token__c();
        cc.Actual_Token__c = 'ExpectedToken';
        cc.Name = 'ExpectedToken';
        insert cc;
        
        DefaultPaymentAccount__c ddd = new DefaultPaymentAccount__c();
        ddd.Name = 'DefaultAccountRecord';
        ddd.Default_Account_ID__c = '0017j00000SIlpn';
        ddd.DefaultAccountNumber__c = '1000095499';
        ddd.PaymentAllocationRectypeID__c = '0124D0000000iUN';
        ddd.PaymentRecordTypeID__c = '0124D0000000iWn';
        ddd.USDCurrencyID__c = 'a03F0000009vD0D';
        insert ddd;
        
        Account acc = new Account();
        acc.Name = 'testAcc'; 
        acc.MH_Cust_Number__c = '1234567890';
        acc.Logical_Doc__c='https://martindale-nolo--cpqdev.my.salesforce.com/p/setup/layout/LayoutFieldList?type=2147483648=AccountFields&retURL=%2Fui%2Fsetup%2FSetup%3Fsetupid%3DAccount';
        insert acc;
        
        blng__Invoice__c Inv= new blng__Invoice__c();
        inv.blng__Account__c = acc.Id;
        inv.blng__InvoiceStatus__c = 'Posted';
        inv.blng__InvoiceDate__c = System.today();
        inv.IsDataLoaded__c = 'Y';
        inv.RecordTypeId = Schema.SObjectType.blng__Invoice__c.getRecordTypeInfosByName().get('MH Invoice').getRecordTypeId();
        insert inv;
        
        blng__Payment__c pay = new blng__Payment__c();
        pay.blng__Account__c = acc.Id;
        pay.blng__Invoice__c = Inv.Id;
        pay.blng__Amount__c = 50.00;
        insert pay;
        
        blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = acc.Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '4112344112344113';
        pmRec.blng__CardNumber__c='4112344112344113';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'Visa';
        insert pmRec;
        String idValue = pmRec.Id;
        
        Document doc = new Document();
        doc.Name = 'CSC Pay Now Help 9.4.15';
        doc.FolderId = [SELECT Id,Name FROM Folder WHERE Name='MDL ACH Bank Files'].Id;
        insert doc;
        
        PageReference pageRef = Page.Portal_InvoicedetailPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('c', String.valueOf(acc.MH_Cust_Number__c));
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();
        ApexPages.currentPage().getHeaders().put('SMB_Authorization','SMB_Authorization');
        ApexPages.currentPage().getHeaders().put('Authorization','Authorization');
        Portal_InvoiceDetailPageCntrl porInv = new Portal_InvoiceDetailPageCntrl();
        porInv.getselectedFilterMonthItems();
        porInv.selectedFilterMonth = '0';
        porInv.fliterInvoicePayment();
        porInv.selectedFilterMonth = '1';
        porInv.fliterInvoicePayment();
        porInv.selectedFilterMonth = '3';
        porInv.fliterInvoicePayment();
        porInv.selectedFilterMonth = '6';
        porInv.fliterInvoicePayment();
        porInv.selectedFilterMonth = '9';
        porInv.fliterInvoicePayment();
        porInv.selectedFilterMonth = '12';
        porInv.fliterInvoicePayment();
        porInv.signOut();
        porInv.openHelp();
        Portal_InvoiceDetailPageCntrl.InvoicePaymentWrapper wrapper = new Portal_InvoiceDetailPageCntrl.InvoicePaymentWrapper(acc.Id,'IPType','Name',Inv.blng__InvoiceDate__c,'TotalInvoiceValue','TotalPayment','UnPaidAmount','PaymentStatus','PaymentType','RecordTypeName','isdataLoaded');
        Portal_InvoiceDetailPageCntrl.todeleteInvId = idValue;
        porInv.deleteInvoice();
        pageReference pg=Portal_InvoiceDetailPageCntrl.downloadinv(Inv.id);
        Test.StopTest();
    }
}