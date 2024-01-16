@isTest(seeAllData=true)
public class Test_CPQ_BatchQuoteLinesExpiry {
    static testMethod void testMethod1(){
        //DataFactory.loadCustomSettings();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-A Intake Account').getRecordTypeId();
        List<Account> lstAcc = DataFactory.createAccount('Test Acc', accRecordTypeId, 1);
        
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
        
        
        // Create Test Attribute Configuration - Service County
        Attribute_Configuration__c objAC2 = DataFactory.createAtrConfiguration('Service County', 6, 'Text');
        ProductAttribute__c objPA2 = DataFactory.createProductAttribute(objAC2, objproduct, 'Multi-Picklist');
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId();
        
        List<SBQQ__Quote__c> qoLst = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=lstAcc[0].Id;
        objquote.SBQQ__Opportunity2__c=testopp.id;
        objquote.SBQQ__PrimaryContact__c = con[0].Id; 
        objquote.Billing_Contact__c = con[0].Id; 
        objquote.Marketing_Contact__c = con[0].Id; 
        objquote.SBQQ__SubscriptionTerm__c = 12;
        Integer subNo = objquote.SBQQ__SubscriptionTerm__c.intvalue();
        //objquote.SBQQ__Type__c = 'Rebase';
        objquote.RecordTypeId =quoteRecordTypeId;
        insert objquote;
        //qoLst.add(objquote);
        /*
        SBQQ__Quote__c objquote2= new SBQQ__Quote__c();
        objquote2.SBQQ__Account__c=lstAcc[0].Id;
        objquote2.SBQQ__Opportunity2__c=testopp.id;
        objquote2.SBQQ__PrimaryContact__c = con[0].Id; 
        objquote2.Billing_Contact__c = con[0].Id; 
        objquote2.Marketing_Contact__c = con[0].Id; 
        //objquote.SBQQ__Type__c = 'Rebase';
        objquote2.RecordTypeId =quoteRecordTypeId;
        qoLst.add(objquote2);
        Insert qoLst;
        */
        String qID = objquote.Id; 
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=objproduct.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        quoteline.Inventory_Id__c = '123456789';
        quoteline.Pend_Date__c = date.today() - 10;
        insert quoteline;
        /*
        SBQQ__QuoteLine__c quotelineA=new SBQQ__QuoteLine__c();
        quotelineA.SBQQ__Product__c=objproduct.id;
        quotelineA.SBQQ__Quote__c=objquote.Id;
        quotelineA.SBQQ__RequiredBy__c = quoteline.Id;
        quotelineA.Attribute_Relationship__c = objAR.Id;
        insert quotelineA;
        */
        test.startTest();
        Database.executeBatch(new CPQ_BatchQuoteLinesExpiry (), 10);
        CPQ_BatchQuoteLinesExpiry m = new CPQ_BatchQuoteLinesExpiry();
        Database.executeBatch(m);
        test.stopTest();
        
        CPQ_MDL_ScheduleBatchQuoteLinesExpiry m1 = new  CPQ_MDL_ScheduleBatchQuoteLinesExpiry();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, m1);
        
 
    }
}