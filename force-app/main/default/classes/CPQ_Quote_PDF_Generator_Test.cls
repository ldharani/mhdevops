@isTest
public class CPQ_Quote_PDF_Generator_Test {
    @isTest
    static void testMethodA(){
        
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> con =DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
        product2 objproduct= new product2();
        objproduct.Name ='Test Product';
        objproduct.IsInventoried__c = True;
        objproduct.ProductCode = '11006';
        insert objproduct;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__PrimaryContact__c = con[0].Id; 
        objquote.Billing_Contact__c = con[0].Id; 
        objquote.Marketing_Contact__c = con[0].Id; 
        objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__SubscriptionTerm__c = 12;
        Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        insert objquote;
        
        String qID = objquote.Id; 
        //Integer subNo;
        //
        
        Integration_Endpoints__c inCheck = new Integration_Endpoints__c();
        inCheck.Name = 'CheckInventory';
        inCheck.MethodType__c = 'POST';
        inCheck.API_key__c = '76F1CF765AA41A8E695F66A815B7D345';
        inCheck.Private_Key__c = 'eb84845010dfdaa173ba9e9022ee66d4f6b90488ac7065b0ccc916264108d4fa';
        inCheck.Endpoint_URL__c = 'http://stg-back-office-services.lawyers.com/services/inventory/v2/reserve';
        inCheck.xmlns__c = 'http://svcs.martindale.com/MHIntegration/PendInventoryRequest/v1.00';
        inCheck.Endpoint_URL_for_authentication__c = 'svcs-stg1.martindale.com/mhintegration/inventory';
        inCheck.Public_Key__c = 'b9d732cb87b851b56c9da59639bf5ad6512c56ae718ce2f344c7605922b3a966';
        insert inCheck;
        
        DocuSign_endpoints__c objIE = new DocuSign_endpoints__c();
        objIE.Name = 'Docusign Payment API';
        objIE.Username__c = '97de0b5c-8b64-47f2-9317-005b795839f9';
        objIE.Password__c = 'Demostage!2    ';
        objIE.Integration_Key__c = '5889ae64-deae-4ae4-9411-c0f17d7caa3a';
        objIE.Base_URL__c = 'https://demo.docusign.net/restapi/v2.1';
        objIE.Account_ID__c = '2342190';
        objIE.OAuthEndPoint__c = 'https://account-d.docusign.com/oauth/token';
        objIE.OAuthReqDomain__c = 'http://account-d.docusign.com';
        Insert objIE;
        
        DocuSign_endpoints__c objIE2 = new DocuSign_endpoints__c();
        objIE2.Name = 'Docusign Integration details';
        objIE2.Username__c = '61511d36-31b3-40f8-a1e0-d9d1713cb463';
        objIE2.Password__c = 'See4zy22';
        objIE2.Integration_Key__c = '5889ae64-deae-4ae4-9411-c0f17d7caa3a';
        objIE2.Base_URL__c = 'https://na2.docusign.net/restapi/v2';
        objIE2.Account_ID__c = '59033688';
        Insert objIE2;
        
        DocuSign_endpoints__c objAuth = new DocuSign_endpoints__c();
        objAuth.Name = 'AuthNet Details';
        obJAuth.Base_URL__c = 'https://apitest.authorize.net/xml/v1/request.api';
        objAuth.Integration_Key__c = '52b2cbbc-5982-47d7-bdde-268803368d18';
        objAuth.Username__c ='2bH9W37zeDTP';//need to move this to custom setting
        objAuth.Password__c = '6U7g65wm2BMn8S4R';//need to move this to custom setting
        objAuth.Account_ID__c = 'a613w000001dyJ6';
        Insert objAuth;
        
        DefaultPaymentAccount__c dfpa =  new DefaultPaymentAccount__c();
        dfpa.Name = 'DefaultAccountRecord';
        dfpa.Default_Account_ID__c = '001F000001ae0eX';
        dfpa.DefaultAccountNumber__c = '1000095499';
        dfpa.USDCurrencyID__c = 'a03F0000009vD0D'; 
        dfpa.PaymentAllocationRectypeID__c = '0123w0000026Diu';
        dfpa.PaymentRecordTypeID__c = '0123w0000026Dqd';
        Insert dfpa;
        /*
        DocuSignSetting__mdt  dsMDT = new DocuSignSetting__mdt();
        dsMDT.Label = 'JWT_setting';
        dsMDT.alg__c = '';
        dsMDT.Scope__c = 'signature spring_read spring_write';
        dsMDT.PrivateKey__c = 'MIIEpAIBAAKCAQEAs3ROf8jWzUbHMioeO+ufTUA4T4FY2xYavFo7FoW0EE2QgKwa4nYNwx3bb+0OsiKgC2gwT6yaC8oFt15hjvdV3uozJwP6/ufpQoUH4Q6dyfFkwkxp3IRfWtvBBBpIBaWm9nY8DU/B/pSYhXkoK0RmkPEdg/nbjwX96Q6UzlSNuamYkZubQpyZmxmVXZWII1QL4Q15gMpbtU5OqrEX4ZEYoXJf9ZEq6wG0rFO87RlYD3B8r+rJnBu9X22YfU5+gJNgJhOn+hfcbfL+ik2eDckw/53tPJgiCSstbXeuIclg9uU962vedGDL5pvY1QH8oOTwx5AAuBATJjGywwNdSHrd4wIDAQABAoIBAE/LVqBhWIn8f9RhgAIa2kHKXX+Uv0LjyE2aPY3dM9zP8IIWhPnPjn0FCK7zFMbGuK15zYmP8Qtu8C3CDNU6S3eMYeRmU7QGwOSwLHm5OxYxfSEcQzInthK7hk7htMa2CtCqcDdnEJa30j3/Soo6pvSqEfq+Hg+xlV6M+kPouwAjlwrZcoxXtr2Uc8BHH9AL8kP60mSO23+YkNppuny6FjiJMo3ULdH+b1il1xo+Nn72i4uMzcM+7C78KXqHhB1FWvLP3he9hZK0chYGYgVgi2+J0tm0hLtEbOd44wIXZasewDTnIFeeCUymO67TBz3MQ7twLq0cmd9+9JXAFtJ4l8kCgYEA6O5lGUKFxOBol3kSTUOhnfZXNHQXqGrDay42ZowsjhKVfQ2adWEmcQIGBjLMsQVWQOuIBhqRsGrFZd/9VK6tWmBvep52243r/lOrcv4a71E7PcUg28JlhmpzSeg2ZJwMZgCEF8yMl8xNoMh7feH+a2K/INQ5pysHx00WuG5O4e8CgYEAxToWvPvcgelj25BPifrn5m/qkBPvQQW4pSPjMs0QZDKk88gYMz1fhsEtgHi8MkK2OxTBav97YoerOXOtQiEpClj027k58gAVS7BcgPY8FwnnbiNAOYOP4PCtGcy1XPLkVwdrC9R2J0VURNAWhcQvPNMX2vfG3SohEpvOwLaCp00CgYBg6YbwqofDcOazVvExalkcwrhnn4GUVc82kcSah+mltr+xhu5jtebrj7735zzYzfKkEhrHB1jkQJgemcHp8L85YfQf3TxwfqzYZPFpZ6XHOlHeklzocgoRkcqjzlSLKY3TBpXu3PEF2z/VDHSs3FEhVrVUsFfIYJPc7Qrt8x8oywKBgQCC8FvkP/pXrZGEVbzYyGFplefOm81+B8RcrwTJ12cIfq8Qwkl+y0I+fsYswvt/CtddRhxbYx6Rfazpyai/fLB4lDKMJd8YkYGR7Jadb9zZFtQ1ROYAyR2eo2ro9AV8ni2GsgAZrIZ88ARQYy5wxJzv7t2pnFLExpGKfzK2svTvCQKBgQDe9euk5LWOCNrHK+e3Q8cmZOaOxWUduG2Ry0tVFrKR9QmR9aqjb6uQrnisTvEK8yE5uLxASgEULS3M3rMlLzLb8RkaVHsFwjkgpPv56q7FTK7C2PwsQY3E9Ip1Ejv26bjAy/ymY4lhhKEm1q/apPGw6484GK3Rf/QM0b42McK0hw=='; 
        *///return dsMDT;
        
        //String requestBody = '{"example":"test","access_token":"12345"}';
        
         test.startTest();
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        insert quoteline;
        
       
        
        /*SBQQ__QuoteLine__c quotelineA=new SBQQ__QuoteLine__c();
        quotelineA.SBQQ__Product__c=objproduct.id;
        quotelineA.SBQQ__Quote__c=objquote.Id;
        quotelineA.Attribute_Relationship__c = objAR.Id;
        insert quotelineA;*/
        String EnvelopeId = '0077886677';
        String EnvelopeLink = 'https://appdemo.docusign.com?back=documents/details/';
        String Subject = 'Test_Ds';
        String Sender = 'SaiV';
        String SenderEmail = 'saivihari.ravulapati@martindale.com';
        String result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        //CPQ_Quote_PDF_Generator.UpsellPackageAssist(qID);
        
        CPQ_Quote_PDF_Generator.quotePDF(qID);
        CPQ_Quote_PDF_Generator.getQuoteInfoOnPDF(qID);
        //CPQ_Quote_PDF_Generator.checkInvTrg(qID);
        CPQ_Quote_PDF_Generator.sendPDF('test','test','test','test');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String accessToken = '12345';//DocusignPaymentApi.getAccessToken();
        DocusignPaymentApi.generateandSendEnvelope(qID,null,'test','test');
        DocusignPaymentApi.createDSstatusRecord(EnvelopeId, qID, EnvelopeLink, null, null, Subject, Sender, SenderEmail);
        
        ID DefaultAccID = dfpa.Default_Account_ID__c;
        String DealultAccNumber = dfpa.DefaultAccountNumber__c;
        ID USDCurrencyID = dfpa.USDCurrencyID__c;
        DocusignPaymentApi.getPaymntInfo(EnvelopeId, qID);
        test.stopTest();
    }
    
    @isTest
    static void testMethodB(){
        
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        Contact con = new Contact(FirstName= 'test', LastName =' Mark Beamish');
            con.AccountId = lstAcc[0].Id;
            con.Phone = '123456789';
            con.RecordTypeId = conRecordTypeId;
        insert con;
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
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
        
        // Create Attribute_Lines__c - Service State
        Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'Service State', 'Multi-Picklist', '', 'Connecticut;Delaware;');
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      
      
        // Create Test Attribute Configuration - Practice Area
        Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, objproduct, 'String');
        
        
        // Create Test Attribute Configuration - Service State
        Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
        ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, objproduct, 'Multi-Picklist');
        objAL1.Attribute_Junction__c = objAR.Id;
        objAL1.Product_Attribute__c = objPA1.Id;
        update objAL1;
        
        // Create Test Attribute Configuration - Service County
        Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
        ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, objproduct, 'Multi-Picklist');
        objAL2.Attribute_Junction__c = objAR.Id;
        objAL2.Product_Attribute__c = objPA1.Id;
        update objAL2;
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__SubscriptionTerm__c = 12;
        Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        insert objquote;
        
        objquote.Marketing_Contact__c = Con.Id;
        objquote.Billing_Contact__c =Con.Id;
        objquote.SBQQ__PrimaryContact__c = Con.Id;
        //Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        update objquote;
        
        String qID = objquote.Id; 
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        insert quoteline;
        
        test.startTest();
        
        SBQQ__QuoteLine__c quotelineA=new SBQQ__QuoteLine__c();
        quotelineA.SBQQ__Product__c=objproduct.id;
        quotelineA.SBQQ__Quote__c=objquote.Id;
        quotelineA.SBQQ__RequiredBy__c = quoteline.Id;
        quotelineA.Attribute_Relationship__c = objAR.Id;
        insert quotelineA;
        
        
        String result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        //CPQ_Quote_PDF_Generator.UpsellPackageAssist(qID);
        
        CPQ_Quote_PDF_Generator.quotePDF(qID);

        Id noloQuoteRectypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Nolo Quote').getRecordTypeId();
        objquote.SBQQ__PrimaryContact__c = Con.Id;
        objquote.Billing_Contact__c = null;
        objquote.RecordtypeId = noloQuoteRectypeId;
        update objquote;
        result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        objquote.SBQQ__PrimaryContact__c = Con.Id;
        objquote.Billing_Contact__c = Con.Id;
        objquote.Marketing_Contact__c = null;
        update objquote;
        result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        test.stopTest();
    }
    
    @isTest
    static void testMethodC(){
        
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        Contact con = new Contact(FirstName= 'test', LastName =' Mark Beamish');
            con.AccountId = lstAcc[0].Id;
            con.Phone = '123456789';
            con.RecordTypeId = conRecordTypeId;
            con.Email = 'test@test.com';
        insert con;
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
        product2 objproduct= new product2();
        objproduct.Name ='Test Product';
        objproduct.IsInventoried__c = True;
        objproduct.ProductCode = '11006';
        insert objproduct;
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__SubscriptionTerm__c = 12;
        Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        insert objquote;
        
        
        String qID = objquote.Id; 
        
        Test.startTest();
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        insert quoteline;
        
        
        
        SBQQ__QuoteLine__c quotelineA=new SBQQ__QuoteLine__c();
        quotelineA.SBQQ__Product__c=objproduct.id;
        quotelineA.SBQQ__Quote__c=objquote.Id;
        quotelineA.SBQQ__RequiredBy__c = quoteline.Id;
        //quotelineA.Attribute_Relationship__c = objAR.Id;
       // insert quotelineA;

        String result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        Id noloQuoteRectypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Nolo Quote').getRecordTypeId();

        objquote.SBQQ__PrimaryContact__c = Con.Id;
        objquote.Billing_Contact__c = null;
        objquote.RecordtypeId = noloQuoteRectypeId;
        update objquote;
        result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        objquote.SBQQ__PrimaryContact__c = Con.Id;
        objquote.Billing_Contact__c = Con.Id;
        objquote.Marketing_Contact__c = null;
        update objquote;
        result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        //CPQ_Quote_PDF_Generator.UpsellPackageAssist(qID);
        //test.startTest();
        //CPQ_Quote_PDF_Generator.quotePDF(qID);
        try
        {
            
            objquote.SBQQ__Status__c = 'QA Review';
            update objquote;
            Test.stopTest();
        }
        catch (DmlException ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Primary Contact : Email address is missing. Please provide primary contact Email address.') ? true : false;
            //System.assertEquals(expectedExceptionThrown, false);
        }
    }
    
    @isTest
    static void testMethodD(){
        
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        Contact con = new Contact(FirstName= 'test', LastName =' Mark Beamish');
            con.AccountId = lstAcc[0].Id;
            con.Phone = '123456789';
            con.RecordTypeId = conRecordTypeId;
            con.Email = 'test@test.com';
        insert con;
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
        product2 objproduct= new product2();
        objproduct.Name ='Test Product';
        objproduct.IsInventoried__c = True;
        objproduct.ProductCode = '11006';
        insert objproduct;
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__SubscriptionTerm__c = 12;
        //objquote.Account_Credit_Status__c = 'Good Standing';
        Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        insert objquote;
        
        objquote.Marketing_Contact__c = Con.Id;
        objquote.Billing_Contact__c =Con.Id;
        objquote.SBQQ__PrimaryContact__c = Con.Id;
        //Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        objquote.Amend_Bundle__c = 'Upsell';
        update objquote;
        
        String qID = objquote.Id; 
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        insert quoteline;
        Test.startTest();
        SBQQ__QuoteLine__c quotelineA=new SBQQ__QuoteLine__c();
        quotelineA.SBQQ__Product__c=objproduct.id;
        quotelineA.SBQQ__Quote__c=objquote.Id;
        //quotelineA.SBQQ__RequiredBy__c = quoteline.Id;
        quotelineA.Attribute_Relationship__c = objAR.Id;
        insert quotelineA;
        String result = '';
        //String result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        CPQ_Quote_PDF_Generator.showUsellAlert(qID);
        
        
        Id noloQuoteRectypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Nolo Quote').getRecordTypeId();

        objquote.SBQQ__PrimaryContact__c = Con.Id;
        objquote.Billing_Contact__c = null;
        objquote.RecordtypeId = noloQuoteRectypeId;
        update objquote;
        result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        objquote.SBQQ__PrimaryContact__c = Con.Id;
        objquote.Billing_Contact__c = Con.Id;
        objquote.Marketing_Contact__c = null;
        update objquote;
        result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testMethodE(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        Contact con = new Contact(FirstName= 'test', LastName =' Mark Beamish');
            con.AccountId = lstAcc[0].Id;
            con.Phone = '123456789';
            con.RecordTypeId = conRecordTypeId;
            con.Email = 'test@test.com';
        insert con;
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
        product2 objproduct= new product2();
        objproduct.Name ='Test Product';
        objproduct.IsInventoried__c = True;
        objproduct.ProductCode = '11006';
        insert objproduct;
        
        // Create Test Attribute Configuration - Practice Area
        Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, objproduct, 'String');
        
        
        // Create Test Attribute Configuration - Service State
        Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
        ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, objproduct, 'Multi-Picklist');
        
        
        // Create Test Attribute Configuration - Service County
        Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
        ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, objproduct, 'Multi-Picklist');        
        
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__SubscriptionTerm__c = 12;
        Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        insert objquote;
        
        
        String qID = objquote.Id; 
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        insert quoteline;
        
        lstAcc[0].Credit_Status__c = 'Past Due';
        update lstAcc[0];
        
        Test.startTest();
        
        SBQQ__QuoteLine__c quotelineA=new SBQQ__QuoteLine__c();
        quotelineA.SBQQ__Product__c=objproduct.id;
        quotelineA.SBQQ__Quote__c=objquote.Id;
        quotelineA.SBQQ__RequiredBy__c = quoteline.Id;
        //quotelineA.Attribute_Relationship__c = objAR.Id;
        insert quotelineA;

        String result = CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        objquote.SBQQ__PrimaryContact__c = Con.Id;
        objquote.Billing_Contact__c = Con.Id;
        objquote.Marketing_Contact__c = Con.Id;
        update objquote;
        
        try
        {
            
            objquote.SBQQ__Status__c = 'QA Review';
            update objquote;
            
        }
        catch (DmlException ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Account Credit Status is Past Due you cannot proceed further') ? true : false;
            //System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testMethodF(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        Contact con = new Contact(FirstName= 'test', LastName =' Mark Beamish');
            con.AccountId = lstAcc[0].Id;
            con.Phone = '1234567890';
            con.RecordTypeId = conRecordTypeId;
            con.Email = '';
        insert con;
        
        Contact con1 = new Contact(FirstName= 'test', LastName =' Marking');
            con1.AccountId = lstAcc[0].Id;
            con1.Phone = '1234567899';
            con1.RecordTypeId = conRecordTypeId;
            con1.Email = 'testemail@martindale.com';
        insert con1;
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
        product2 objproduct= new product2();
        objproduct.Name ='Test SEO Product';
        objproduct.IsInventoried__c = False;
        //objproduct.ProductCode = '01662';
        insert objproduct;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL = DataFactory.createAttributeLines(objAR, 'Practice Area', 'String', 'SSDI', '');
        
        // Create Attribute_Lines__c - Service State
        Attribute_Lines__c objAL1 = DataFactory.createAttributeLines(objAR, 'Service State', 'Multi-Picklist', '', 'Connecticut;Delaware;');
        
        // Create Attribute_Lines__c - Practice Area
        Attribute_Lines__c objAL2 = DataFactory.createAttributeLines(objAR, 'Service County', 'Multi-Picklist', '', 'Connecticut---Tolland;Delaware---Sussex;Delaware---New Castle;Delaware---Kent');
      
      
        // Create Test Attribute Configuration - Practice Area
        Attribute_Configuration__c objAC1 = DataFactory.createAtrConfiguration('Practice Area', 1, 'Text');
        ProductAttribute__c objPA1 = DataFactory.createProductAttribute(objAC1, objproduct, 'String');
        objAL.Attribute_Junction__c = objAR.Id;
        objAL.Product_Attribute__c = objPA1.Id;
        update objAL;
        
        // Create Test Attribute Configuration - Service State
        Attribute_Configuration__c objAC = DataFactory.createAtrConfiguration('Service State', 4, 'Picklist');
        ProductAttribute__c objPA = DataFactory.createProductAttribute(objAC, objproduct, 'Multi-Picklist');
        objAL1.Attribute_Junction__c = objAR.Id;
        objAL1.Product_Attribute__c = objPA.Id;
        update objAL1;
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        //objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__SubscriptionTerm__c = 12;
        objquote.SBQQ__PrimaryContact__c = con.Id;
        objquote.Billing_Contact__c = con1.Id;
        objquote.Marketing_Contact__c = con1.Id;
        Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        insert objquote;
        
        
        String qID = objquote.Id; 
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        quoteline.Attribute_Relationship__c = objAR.Id;
        insert quoteline;
        
        Test.startTest();
        
        try
        {
            
            objquote.SBQQ__Status__c = 'QA Review';
            update objquote;
            
        }
        catch (DmlException ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Please create all the attributes') ? true : false;
            //System.assertEquals(expectedExceptionThrown, false);
        }
        
        CPQ_Quote_PDF_Generator classinstance = new CPQ_Quote_PDF_Generator();
        classinstance.FkMethod();
        Test.stopTest();
    }
    
     @isTest
    static void testMethodG(){
        
        DataFactory.loadCustomSettings();
       Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        lstAcc[0].Credit_Status__c = 'Good Standing';
        Update lstAcc;
        
        // Create Test Contact
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacts').getRecordTypeId();
        List<Contact> con =DataFactory.createContact('Test Con', lstAcc[0], conRecordTypeId, 1);
        
        opportunity testopp= new opportunity();
        testopp.Name='Test IJ';
        testopp.accountId=lstAcc[0].Id;
        testopp.StageName = 'Prospecting';
        testopp.CloseDate = System.today();
        insert testopp;
        String oppID = testopp.Id; 
        
        product2 objproduct= new product2();
        objproduct.Name ='Test Product';
        objproduct.IsInventoried__c = True;
        objproduct.ProductCode = '11006';
        insert objproduct;
        
        Attribute_Relationship__c objAR = new Attribute_Relationship__c();
        objAR.AttributeValues__c = 'Practice Area:SSDI,Service County:New York,';
        insert objAR;
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__PrimaryContact__c = con[0].Id; 
        objquote.Billing_Contact__c = con[0].Id; 
        objquote.Marketing_Contact__c = con[0].Id; 
        objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        objquote.SBQQ__SubscriptionTerm__c = 12;
        Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        insert objquote;
        
        String qID = objquote.Id; 
        //Integer subNo;
         test.startTest();
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        insert quoteline;
        
       
        
        Id noloQuoteRectypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Nolo Quote').getRecordTypeId();
        objquote.SBQQ__PrimaryContact__c = Con[0].Id;
        objquote.Billing_Contact__c = null;
        objquote.RecordtypeId = noloQuoteRectypeId;
        update objquote;
        CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        objquote.SBQQ__PrimaryContact__c = Con[0].Id;
        objquote.Billing_Contact__c = Con[0].Id;
        objquote.Marketing_Contact__c = null;
        update objquote;
        CPQ_Quote_PDF_Generator.quoteAttrValidation(qID);
        
        test.stopTest();
    }
}