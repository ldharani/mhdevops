@isTest
private class MergeAccountCallout_Test {
    
    @testSetup static void setup(){
        
        Account IBAcc = new Account();
        IBAcc.Name = 'IB_Test';    
        IBAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        insert IBAcc;
        
        Account MHAcc = new Account();
        MHAcc.Name = 'MH_Test';    
        MHAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        MHAcc.Org_Id__c = '12345';
        MHAcc.ParentId = IBAcc.Id;
        insert MHAcc;
        
        Account MNAcc = new Account();
        MNAcc.Name = 'MN_Test';    
        MNAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        MNAcc.Nolo_Group_ID__c = '12345';
        MNAcc.ParentId = IBAcc.Id;
        insert MNAcc;
        
        Account MNGAcc = new Account();
        MNGAcc.Name = 'MNG_Test';    
        MNGAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-NG Account').getRecordTypeId();
        MNGAcc.ParentId = IBAcc.Id;
        insert MNGAcc;
        
        Account CAPAcc = new Account();
        CAPAcc.Name = 'CAP_Test';    
        CAPAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Captorra Account').getRecordTypeId();
        CAPAcc.ParentId = IBAcc.Id;
        insert CAPAcc;
        
        Account FIRMAcc = new Account();
        FIRMAcc.Name = 'FIRM_Test';    
        FIRMAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        FIRMAcc.ParentId = IBAcc.Id;
        insert FIRMAcc;
        
        Account ATTAcc = new Account();
        ATTAcc.Name = 'ATT_Test';    
        ATTAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        ATTAcc.ParentId = FIRMAcc.Id;
        insert ATTAcc;
        
        //-------------------------------------------------//
        Account IBAccDel = new Account();
        IBAccDel.Name = 'IB_Del_Test';    
        IBAccDel.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
        insert IBAccDel;
        
        Account MNAccDel = new Account();
        MNAccDel.Name = 'MN_Del_Test';    
        MNAccDel.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-N Account').getRecordTypeId();
        MNAccDel.Nolo_Group_ID__c = '12345';
        MNAccDel.ParentId = IBAccDel.Id;
        insert MNAccDel;
        
        Account CAPAccDel = new Account();
        CAPAccDel.Name = 'CAP_Del_Test';    
        CAPAccDel.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Captorra Account').getRecordTypeId();
        CAPAccDel.ParentId = IBAccDel.Id;
        insert CAPAccDel;
        
        Account FIRMAccDel = new Account();
        FIRMAccDel.Name = 'FIRM_Del_Test';    
        FIRMAccDel.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
        FIRMAccDel.ParentId = IBAccDel.Id;
        insert FIRMAccDel;
        
        Account ATTAccDel = new Account();
        ATTAccDel.Name = 'ATT_Del_Test';    
        ATTAccDel.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Atty Account').getRecordTypeId();
        ATTAccDel.ParentId = FIRMAccDel.Id;
        insert ATTAccDel;
    }
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest static void testMethod1(){
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Account accIB = [SELECT Id FROM Account WHERE Name='IB_Del_Test' LIMIT 1];
        Account accMH = [SELECT Id FROM Account WHERE Name='MH_Test' LIMIT 1];
        Account accFirm = [SELECT Id FROM Account WHERE Name='MH_Test' LIMIT 1];
        
        accMH.ParentId = accIB.Id;
        accFirm.ParentId = accIB.Id;
        Test.startTest();
        update accMH;
        update accFirm;
        Test.StopTest();
    }
    @isTest static void testMethod2(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Account accIB = [SELECT Id FROM Account WHERE Name='IB_Del_Test' LIMIT 1];
        Account accMH = [SELECT Id FROM Account WHERE Name='MH_Test' LIMIT 1];
        
        accMH.ParentId = accIB.Id;
        accMH.Reparent__c = True;
        Test.startTest();
        update accMH;
        Test.StopTest();
    }
    @isTest static void testMethod3(){
        String json = '{'+
            '   \"message\":{'+
            '      \"currentSfNumbers\":{'+
            '         \"sfGuid\":150088878,'+
            '         \"mhCustomerNumbers\": {'+
            '            \"mhCustomerNumber\": 12345323,'+
            '            \"mhOrgId\": 765656'+
            '         },'+
            '         \"ngageCustomerNumber\":345522222,'+
            '         \"captorraCustomerNumber\":232323,'+
            '         \"noloCustomerNumbers\":{'+
            '            \"noloCustomerNumber\":2323233232,'+
            '            \"noloGidNumber\":1234423232'+
            '         },'+
            '         \"avvoCustomerNumbers\":{'+
            '            \"avvoFirmCustomerNumber\":123456,'+
            '            \"avvoAttorneyCustomerNumbers\":['+
            '               123,'+
            '               1234,'+
            '               1234'+
            '            ]'+
            '         }'+
            '      },'+
            '      \"previousSfNumbers\":{'+
            '         \"sfGuid\":45678988,'+
            '         \"mhCustomerNumbers\": {'+
            '            \"mhCustomerNumber\": 12345323,'+
            '            \"mhOrgId\": 765656'+
            '         },'+
            '         \"ngageCustomerNumber\":345522222,'+
            '         \"captorraCustomerNumber\":232323,'+
            '         \"noloCustomerNumbers\":{'+
            '            \"noloCustomerNumber\":2323233232,'+
            '            \"noloGidNumber\":1234423232'+
            '         },'+
            '         \"avvoCustomerNumbers\":{'+
            '            \"avvoFirmCustomerNumber\":123456,'+
            '            \"avvoAttorneyCustomerNumbers\":['+
            '               123,'+
            '               1234,'+
            '               1234'+
            '            ]'+
            '         }'+
            '      },'+
            '      \"updatedAt\":34534534534'+
            '   }'+
            '}';
        MergeAccounrJson obj = MergeAccounrJson.parse(json);
        System.assert(obj != null);
    }
}