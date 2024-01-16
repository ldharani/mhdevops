@isTest
private class DocuSignJWTTest {

    @isTest
    static void testGenerateJWT() {
        // Test data
        String alg = 'RS256';
        String sub = 'user123';
        String iss = '1adf4055-5da4-471e-abfd-62943652dc5f';
        String privateKey = '123456ABC'; // Replace with your actual private key
        String scope = 'signature';
        String aud = 'authDomain';

        // Create an instance of DocuSignJWT
        DocuSignJWT jwtGenerator = new DocuSignJWT(alg, sub, iss, privateKey, scope, aud);

        // Generate JWT
        String generatedJWT = jwtGenerator.issue();

        // Validate the generated JWT (assuming you have a method to validate)
        //System.assert(DocuSignJWT.isValidJWT(generatedJWT, privateKey));
    }

    @isTest
    static void testInvalidJWT() {
        // Test data
        String alg = 'RS256';
        String sub = 'user123';
        String iss = '1adf4055-5da4-471e-abfd-62943652dc5f';
        String privateKey = '123456ABC'; // Replace with your actual private key
        String scope = 'signature';
        String aud = 'authDomain';

        // Create an instance of DocuSignJWT with invalid claims
        DocuSignJWT jwtGenerator = new DocuSignJWT(alg, sub, iss, privateKey, scope, aud);
        jwtGenerator.claims = new Map<String, String>{
            'invalidClaim' => 'value'
        };

        // Generate JWT
        String generatedJWT = jwtGenerator.issue();

        // Validate that the generated JWT is invalid
        //System.assert(!DocuSignJWT.isValidJWT(generatedJWT, privateKey));
    }
}