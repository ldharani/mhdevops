@isTest
public class Test_CPQ_SocialStartedExten {
    
    static testmethod void socialMethd(){
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();
        //acc.BillingStreet = 'test';
        //invoiceit_s__Currency__c currencyObj = new invoiceit_s__Currency__c(Name = 'USD', invoiceit_s__Symbol__c = '$');
        //insert currencyObj;
        
        Contact con = util.getContact(acc.Id);
        
        Product2  oppprod1 = new Product2(Name = 'Reputation Boost',ProductCode = '12000');
        insert oppProd1;
        
        // Create PricebookEntry
        PricebookEntry objPBEntry = DataFactory.createPricebookEntry(oppprod1, 100);
        
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        opp.AOPs__c = 'Test1, Divorce, Administrative Law';
        opp.PrimaryAOP__c = 'Business Law';
        opp.SecondaryAOP__c = 'Bankruptcy';
        opp.TertiaryAOP__c = 'Administrative Law';
        update opp;
        
        Id quoteRecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Intake Quote').getRecordTypeId();
        List<SBQQ__Quote__c> lstQuote = DataFactory.createQuote(acc, opp, quoteRecordTypeId, 1);
        Id quoteLineRecordTypeId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByName().get('M-A Intake Quote Line').getRecordTypeId();
        
        SBQQ__QuoteLine__c objQLI = DataFactory.createQuoteLine(lstQuote[0], oppprod1, objPBEntry, quoteLineRecordTypeId, 1);
        
        Id rt= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard Email2Case Record').getRecordTypeId();
        
        
        Attribute_Lines__c attrLines= new Attribute_Lines__c();
        attrLines.String_value__c = 'test';
        attrLines.Attribute_Name__c = 'Edition';
        attrLines.Address_String__c = 'test';
        attrLines.Attribute_Picklist_Values__c = '2021';
        insert attrLines;
        
        ApexPages.currentPage().getParameters().put('id',objQLI.id);
        ApexPages.currentPage().getParameters().put('attrId',attrLines.id);        
        
        CPQ_SocialStartedExten socialEx = new CPQ_SocialStartedExten();
        
        test.startTest();
        
        
        //socialStartedExten.socialStartedExten();
        socialEx.bankruptcy = true;
        socialEx.conName = 'Test Name';
        socialEx.conPhone = '12332133';
        socialEx.conEmail = 'abcd@gmail.com';
        socialEx.criminal = true;
        socialEx.estate = true;
        socialEx.divorce = true;
        socialEx.immigration = true;
        socialEx.labor = true;
        socialEx.business = true;
        socialEx.family = true;
        socialEx.civilright = true;
        socialEx.resid = true;
        socialEx.personalinj = true;
        socialEx.persInjMV = true;
        socialEx.persInPl = true;
        socialEx.persInjMM = true;
        socialEx.eldrLaw = true;
        socialEx.intProp = true;
        socialEx.websiteURL = 'Test Website';
        socialEx.facebookURL= 'Test Facebook';
        socialEx.LinkedInURL= 'Test LinkedIn';
        //socialEx.googleURL = 'Test Google';
        socialEx.noToGooglProf= True;
        socialEx.Notes= 'Test Notes';
        socialEx.doesNtwanProf= 'Client Does Not Want a Facebook Profile Created<br/>';
        socialEx.noToFbProf = True;
        socialEx.workerscomp = False;
        socialEx.noToLnProf = False;
        socialEx.none = False;
        socialEx.aops = 'Bankruptcy (2/week)<br/>, Criminal Defense (2/week)<br/>';
        socialEx.advArea = 'Testing Area';
        
        socialEx.Submit();
        socialEx.createCase('Test Area','Test Sub area','Test Subject','Test Description','Test Case Origin', acc.id );
        
        socialEx.createCase1('Test Area','Test Sub Area','Test subject','Test description','Test Case origin',acc.id);
        
        test.stopTest();
        
    }
}