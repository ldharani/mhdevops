@isTest
public class paymentMethodHandler_Test {
    
    @testSetup static void setup() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser();
        // Load Custom settings
        DataFactory.loadCustomSettings();
         
        List<Usage_State_and_County__c> lstUSC = DataFactory.createUsageStateandCounty();
        // Create Test Account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        //List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        Account ac = new Account();
        ac.Name = 'Test ' + 'i ' + ' Account';
        ac.BillingStreet = 'test';
        ac.BillingCity =  'test';
        ac.BillingState =  'CA';
        ac.BillingCountry =  'USA';
        ac.BillingPostalCode =  '562';
        ac.RecordTypeId = accRecordTypeId;
        ac.ShippingStreet = 'test';
        ac.ShippingCity =  'test';
        ac.ShippingState =  'CA';
        ac.ShippingCountry =  'USA';
        ac.ShippingPostalCode =  '562';
        ac.Collector__c = u.id;
        insert ac;
        
        blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = ac.Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '4111111111111111';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'Visa';
        pmRec.Payment_Profile_ID__c = 'testProfileId';
        insert pmRec;
    }

    public static testmethod void testMethodA() {
        
        List<Account> lstAcc = [SELECT ID,Order_Status__c FROM Account LIMIT 1];
        lstAcc[0].Order_Status__c = 'Evergreen'; 
        Update lstAcc;
        
        blng__PaymentMethod__c pmRecA = new blng__PaymentMethod__c();
        pmRecA.blng__Account__c = lstAcc[0].Id;
        pmRecA.blng__PaymentType__c = 'Credit Card';
        pmRecA.blng__Active__c = True;
        pmRecA.blng__AutoPay__c = false;
        pmRecA.Card_Number__c = '4111111111111111';
        pmRecA.blng__Nameoncard__c = 'Jm';
        pmRecA.blng__CVV__c = '22222';
        pmRecA.blng__CardExpirationYear__c = '2030';
        pmRecA.blng__CardExpirationMonth__c = '10';
        pmRecA.blng__CardType__c = 'Visa';
        insert pmRecA;
        
    } 
    public static testmethod void testMethodB() {
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        List<blng__PaymentMethod__c> payNewMap = new List<blng__PaymentMethod__c>();
        blng__PaymentMethod__c pmRecA = new blng__PaymentMethod__c();
        pmRecA.blng__Account__c = acc.Id;
        pmRecA.blng__PaymentType__c = 'Credit Card';
        pmRecA.blng__Active__c = True;
        pmRecA.blng__AutoPay__c = True;
        pmRecA.Card_Number__c = '4111111111111111';
        pmRecA.blng__Nameoncard__c = 'Jm';
        pmRecA.blng__CVV__c = '22222';
        pmRecA.blng__CardExpirationYear__c = '2030';
        pmRecA.blng__CardExpirationMonth__c = '10';
        pmRecA.blng__CardType__c = 'Visa';
        insert pmRecA;
        payNewMap.add(pmRecA);
        
        paymentMethodHandler_AC.updatePMOrderStatusOnAccountPAY(payNewMap);
         delete pmRecA;
    }
    
    public static testmethod void testMethodC() {
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser();
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Collector__c = u.Id;
        insert acc;
        
        Contact concc = new Contact();
        concc.FirstName = 'accId';
        concc.LastName = 'accId';
        concc.AccountId = acc.Id;
        concc.Email = 'test@abc.com';
        concc.Phone = '123456789';
        insert concc;
        List<Contract> conlis = new List<Contract>();
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = acc.Id;
        con.Status__c = 'Evergreen';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        con.Bill_To_Contact__c = concc.Id;
        insert con; 
        conlis.add(con);
        
        List<blng__PaymentMethod__c> payNewMap = new List<blng__PaymentMethod__c>();
        blng__PaymentMethod__c pmRecA = new blng__PaymentMethod__c();
        pmRecA.blng__Account__c = acc.Id;
        pmRecA.blng__PaymentType__c = 'Credit Card';
        pmRecA.blng__Active__c = True;
        pmRecA.blng__AutoPay__c = True;
        pmRecA.Card_Number__c = '4111111111111111';
        pmRecA.blng__Nameoncard__c = 'Jm';
        pmRecA.blng__CVV__c = '22222';
        pmRecA.blng__CardExpirationYear__c = '2030';
        pmRecA.blng__CardExpirationMonth__c = '10'; 
        pmRecA.blng__CardType__c = 'Visa';
        insert pmRecA;
        payNewMap.add(pmRecA);
        
        paymentMethodHandler_AC.updatePMBillingEmail(payNewMap);
        paymentMethodHandler_AC.updatePMBillingEmailPAY(conlis);
        paymentMethodHandler_AC.updatePMCollectorEmail(payNewMap);
        
    }
    public static testmethod void testMethodD(){
        MDL_UtilClass_TestClass testData = new MDL_UtilClass_TestClass();
        User u = testData.getUser();
         
        List<Account> lstAcc = [SELECT ID,Order_Status__c FROM Account LIMIT 1];
        lstAcc[0].Collector__c = u.Id;
        //Update lstAcc;
        
        Contact concc = new Contact();
        concc.FirstName = 'accId';
        concc.LastName = 'accId';
        concc.AccountId = lstAcc[0].Id;
        concc.Email = 'test@abc.com';
        concc.Phone = '123456789';
        insert concc;
        List<Contract> conlis = new List<Contract>();
        Contract con = new Contract();
        con.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('MH Contract').getRecordTypeId();
        con.AccountId = lstAcc[0].Id;
        con.Status__c = 'Evergreen';
        con.StartDate = Date.today();
        con.ContractTerm = 12;
        con.Bill_To_Contact__c = concc.Id;
        insert con; 
        conlis.add(con);
        List<blng__PaymentMethod__c> payNewMap = new List<blng__PaymentMethod__c>();
        blng__PaymentMethod__c pmRecA = new blng__PaymentMethod__c();
        pmRecA.blng__Account__c = lstAcc[0].Id;
        pmRecA.blng__PaymentType__c = 'Credit Card';
        pmRecA.blng__Active__c = True;
        pmRecA.blng__AutoPay__c = false;
        pmRecA.Card_Number__c = '4111111111111111';
        pmRecA.blng__Nameoncard__c = 'Jm';
        pmRecA.blng__CVV__c = '22222';
        pmRecA.blng__CardExpirationYear__c = '2030';
        pmRecA.blng__CardExpirationMonth__c = '10'; 
        pmRecA.blng__CardType__c = 'Visa';
        insert pmRecA;
        
        pmRecA.Payment_Profile_ID__c = 'testID123';
        update pmRecA;
        payNewMap.add(pmRecA);
        
    }
    public static testmethod void testMethodE(){
        
        //Map<Id,Account> accNewMap, Map<Id,Account> accOldMap
        Map<Id, Account> newmap = new Map<Id, Account>();
        Map<Id, Account> oldmap = new Map<Id, Account>();
        
        Account acc1 = new Account();
        acc1.Name='test-acc1';
        acc1.Order_Status__c='Active';
        insert acc1;
        newmap.put(acc1.Id, acc1);
       
        Account acc2 = new Account();
        acc2.Name='test-acc2';
        acc2.Order_Status__c='Evergreen';
        insert acc2;
        oldmap.put(acc2.Id, acc2);
            
        blng__PaymentMethod__c payMet = new blng__PaymentMethod__c();
        payMet.blng__PaymentType__c = 'Credit Card';
        payMet.blng__Active__c = True;
        payMet.blng__BillingEmail__c='sample@gmail.com';
        payMet.blng__AutoPay__c =True;
        payMet.blng__Account__c= acc1.Id;
        payMet.Card_Number__c = '4111111111111111';
        payMet.blng__Nameoncard__c = 'Jm';
        payMet.blng__CVV__c = '22222';
        payMet.blng__CardExpirationYear__c = '2030';
        payMet.blng__CardExpirationMonth__c = '10'; 
        payMet.blng__CardType__c = 'Visa';
        insert payMet;
        
        Test.startTest();
        
        paymentMethodHandler_AC.updatePMOrderStatusOnAccount(newmap,oldmap);
        Test.stopTest();
    }
    
    public static testmethod void testMethodF(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'Test ' + 'i ' + ' Account';
        acc.BillingStreet = 'test';
        acc.BillingCity =  'test';
        acc.BillingState =  'CA';
        acc.BillingCountry =  'USA';
        acc.BillingPostalCode =  '562';
        acc.RecordTypeId = accRecordTypeId;
        acc.ShippingStreet = 'test';
        acc.ShippingCity =  'test';
        acc.ShippingState =  'CA';
        acc.ShippingCountry =  'USA';
        acc.ShippingPostalCode =  '562';
        insert acc;
        
        Test.startTest();
        List<blng__PaymentMethod__c> payMethodList = [SELECT Id, blng__PaymentGateway__c FROM blng__PaymentMethod__c WHERE blng__PaymentGateway__c = null];
        paymentMethodHandler_AC.populatePaymentGateway(payMethodList);
        
        blng__PaymentMethod__c pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = acc.Id;
        pmRec.blng__PaymentType__c = 'ACH';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.blng__BankAccountType__c = 'Checking';
        pmRec.blng__BankName__c ='US Bank';
        pmRec.blng__BankAccountName__c = 'US Bank';
        pmRec.blng__BankRoutingCode__c = '122105155';
        pmRec.blng__BankAccountNumber__c = '123456';
        pmRec.blng__BillingFirstName__c='John';
        pmRec.blng__BillingLastName__c='Matt';
        pmRec.blng__BillingEmail__c='test@testgmail.com';
        insert pmRec;
        
        payMethodList = [SELECT Id, blng__PaymentGateway__c, blng__Account__c, blng__Active__c, blng__AutoPay__c, blng__PaymentType__c, blng__PaymentGatewayToken__c FROM blng__PaymentMethod__c WHERE Id =: pmRec.Id AND blng__PaymentType__c ='ACH'];
        paymentMethodHandler_AC.updateDefaultPMonAccountInsert(payMethodList);
        
        pmRec = new blng__PaymentMethod__c();
        pmRec.blng__Account__c = acc.Id;
        pmRec.blng__PaymentType__c = 'Credit Card';
        pmRec.blng__Active__c = True;
        pmRec.blng__AutoPay__c = True;
        pmRec.Card_Number__c = '4111111111111111';
        pmRec.blng__Nameoncard__c = 'Jm';
        pmRec.blng__CVV__c = '22222';
        pmRec.blng__CardExpirationYear__c = '2030';
        pmRec.blng__CardExpirationMonth__c = '10';
        pmRec.blng__CardType__c = 'Visa';
        pmRec.Payment_Profile_ID__c = 'testProfileId';
        pmRec.blng__PaymentGatewayToken__c = '1234';
        insert pmRec;
        
        payMethodList = [SELECT Id, blng__PaymentGateway__c, blng__Account__c, blng__Active__c, blng__AutoPay__c, blng__PaymentType__c , blng__PaymentGatewayToken__c FROM blng__PaymentMethod__c WHERE Id =: pmRec.Id AND blng__PaymentType__c ='Credit Card' AND blng__PaymentGatewayToken__c != null];
        paymentMethodHandler_AC.updateDefaultPMonAccountInsert(payMethodList);
        
        Test.stopTest();
    }
}