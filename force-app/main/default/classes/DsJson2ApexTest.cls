@isTest
public class DsJson2ApexTest {

    @isTest
    public static void testJsonParsing() {
        // Test data
        String jsonString = '{"formulaTabs":[{"paymentDetails":{"chargeId":"123","customerId":"456","paymentSourceId":"789"}}]}';

        // Parse JSON using the DsJson2Apex class
        DsJson2Apex result = DsJson2Apex.parse(jsonString);

        // Validate the parsed result
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.formulaTabs);
        System.assertEquals(1, result.formulaTabs.size());

        DsJson2Apex.cls_formulaTabs formulaTab = result.formulaTabs[0];
        System.assertNotEquals(null, formulaTab);
        System.assertNotEquals(null, formulaTab.paymentDetails);

        DsJson2Apex.cls_paymentDetails paymentDetails = formulaTab.paymentDetails;
        System.assertNotEquals(null, paymentDetails);
        System.assertEquals('123', paymentDetails.chargeId);
        System.assertEquals('456', paymentDetails.customerId);
        System.assertEquals('789', paymentDetails.paymentSourceId);
    }
}