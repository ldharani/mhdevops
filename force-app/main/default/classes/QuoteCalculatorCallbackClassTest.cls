@isTest
private class QuoteCalculatorCallbackClassTest {
    @isTest
    static void testCallback() {
        QuoteCalculatorCallbackClass qccbc = new QuoteCalculatorCallbackClass();
        String sampleQuoteJSON = '{"test": "test"}';
        Test.startTest();
        qccbc.callback(sampleQuoteJSON);
        Test.stopTest();
    }
}