@isTest
public class BatchPaymntMethdInActiveCls_Test {
    @isTest
    static void testBatch() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 2);
        // Create test data - Payment Methods with conditions met for deactivation
        List<blng__PaymentMethod__c> testPaymentMethods = new List<blng__PaymentMethod__c>();
        for (Integer i = 0; i < 2; i++) {
            blng__PaymentMethod__c pm = new blng__PaymentMethod__c(
                blng__Account__c = lstAcc[0].Id,
                blng__Active__c = True,
                //blng__AutoPay__c = True,
                Card_Number__c = '4111111111111111',
                blng__Nameoncard__c = 'Jm',
                blng__CVV__c = '22222',
                blng__CardType__c = 'Visa',
                blng__CardExpirationMonth__c = '01',
                blng__CardExpirationYear__c = '2020',
                blng__PaymentType__c = 'Credit Card'
            );
            testPaymentMethods.add(pm);
        }
        insert testPaymentMethods;

        // Create test data - Payment Methods that should not be deactivated
        List<blng__PaymentMethod__c> testPaymentMethodsNoDeactivation = new List<blng__PaymentMethod__c>();
        for (Integer i = 0; i < 2; i++) {
            blng__PaymentMethod__c pm = new blng__PaymentMethod__c(
                blng__Account__c = lstAcc[1].Id,
                blng__Active__c = True,
                //blng__AutoPay__c = True,
                Card_Number__c = '4111111111111111',
                blng__Nameoncard__c = 'Jm',
                blng__CVV__c = '22222',
                blng__CardType__c = 'Visa',
                blng__CardExpirationMonth__c = '12',
                blng__CardExpirationYear__c = '2024',
                blng__PaymentType__c = 'Credit Card'
            );
            testPaymentMethodsNoDeactivation.add(pm);
        }
        insert testPaymentMethodsNoDeactivation;

        // Start the batch job
        Test.startTest();
        Database.executeBatch(new BatchPaymntMethdInActiveCls());
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        Test.stopTest();
        
        ScheduleBatchPaymntMethdInActiveCls m1 = new  ScheduleBatchPaymntMethdInActiveCls();
    	String sch = '0 0 23 * * ?';
    	system.schedule('Test check', sch, m1);

        // Verify that the Payment Methods with conditions met for deactivation are deactivated
        List<blng__PaymentMethod__c> updatedPaymentMethods = [
            SELECT Id, blng__Active__c
            FROM blng__PaymentMethod__c
            WHERE Id IN :testPaymentMethods
        ];
        for (blng__PaymentMethod__c pm : updatedPaymentMethods) {
            System.assertEquals(false, pm.blng__Active__c, 'Payment Method should be deactivated');
        }

        // Verify that the other Payment Methods remain active
        List<blng__PaymentMethod__c> unchangedPaymentMethods = [
            SELECT Id, blng__Active__c
            FROM blng__PaymentMethod__c
            WHERE Id IN :testPaymentMethodsNoDeactivation
        ];
        for (blng__PaymentMethod__c pm : unchangedPaymentMethods) {
            System.assertEquals(true, pm.blng__Active__c, 'Payment Method should remain active');
        }
    }
}