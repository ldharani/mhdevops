@isTest
public class Test_ClassOnAttributeLines {

    static testmethod void test1(){
        
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara());
        
        Cls_UtilTestClass util = new Cls_UtilTestClass();
        Account acc = util.getAccount();
        acc.BillingStreet = 'test';
        
        Contact con = util.getContact(acc.Id);
        
        Opportunity opp = util.getOpportunity(acc.Id , con.Id);
        
      
        opp.AOPs__c = 'Test1, Divorce, Administrative Law';
        update opp;
        
        Product2  oppprod1 = new Product2(Name = 'Reputation Boost',ProductCode = '12000');
        insert oppProd1;
        
        
        
        List<Attribute_Lines__c> attrLinesList = new List<Attribute_Lines__c>();
        List<Attribute_Lines__c> newLst = new List<Attribute_Lines__c>();
        Map<id, Attribute_Lines__c> oldMap = new Map<id, Attribute_Lines__c>();
        
        Attribute_Relationship__c atr = new Attribute_Relationship__c();
        atr.AttributeValues__c = 'test';
        insert atr;
        
        Attribute_Lines__c attrLines= new Attribute_Lines__c();
        attrLines.String_value__c = 'test';
        attrLines.Attribute_Name__c = 'Edition';
        attrLines.Address_String__c = 'test';
        attrLines.Attribute_Picklist_Values__c = '2021';
        attrLines.Attribute_Junction__c = atr.Id;
        attrLines.Show_in_Docusign__c = true;
        insert attrLines; 
              
        
        Attribute_Lines__c attrLines1= new Attribute_Lines__c();
        attrLines1.String_value__c = 'Newport';
        attrLines1.Attribute_Name__c = 'City';
        attrLines1.Address_String__c = 'USA;NY;Newport';
        attrLines1.Attribute_Picklist_Values__c = '2021';
        insert attrLines1;
        
        oldMap.put(attrLines1.Id, attrLines1);
        
        attrLines1.String_value__c = 'Newyork';
        attrLines1.Attribute_Name__c = 'City';
        attrLines1.Address_String__c = 'USA;NY;Newyork'; 
        newLst.add(attrLines1);
        update newLst;
        
        
        Attribute_Lines__c attrLines2= new Attribute_Lines__c();
        attrLines2.String_value__c = 'NY';
        attrLines2.Attribute_Name__c = 'State';
        attrLines2.CountryState_String__c = 'USA;NY';
        attrLines2.Address_String__c ='USA;NY';
        attrLines2.Attribute_Picklist_Values__c = '2021';
        insert attrLines2;
        
        Attribute_Lines__c attrLines3= new Attribute_Lines__c();
        attrLines3.String_value__c = 'USA';
        attrLines3.Attribute_Name__c = 'Country';
        attrLines3.Address_String__c = 'USA';
        attrLines3.Attribute_Picklist_Values__c = '2021';
        insert attrLines3;
        
        Attribute_Lines__c attrLines4= new Attribute_Lines__c();
        attrLines4.String_value__c = 'test';
        attrLines4.Attribute_Name__c = 'County';
        attrLines4.Address_String__c = 'test';
        attrLines4.Attribute_Picklist_Values__c = '2021';
        insert attrLines4;
        
        Attribute_Lines__c attrLines5= new Attribute_Lines__c();
        attrLines5.String_value__c = 'test';
        attrLines5.Attribute_Name__c = 'AOP';
        attrLines5.Address_String__c = 'test';
        attrLines5.Attribute_Picklist_Values__c = '2021';
        insert attrLines5;
        
        Attribute_Lines__c attrLines6= new Attribute_Lines__c();
        attrLines6.Attribute_Name__c = 'AOP';
        attrLines6.Picklist_Value__c = 'Debt Relief';
        attrLines6.Attribute_Junction__c = atr.Id;
        insert attrLines6;
        
        attrLinesList.add(attrLines);
        attrLinesList.add(attrLines1);
        attrLinesList.add(attrLines2);
        attrLinesList.add(attrLines3);
        attrLinesList.add(attrLines4);
        attrLinesList.add(attrLines5);
        attrLinesList.add(attrLines6);
        
        
        SBQQ__Quote__c objquote= new SBQQ__Quote__c();
        objquote.SBQQ__Account__c=acc.Id;
        objquote.SBQQ__Opportunity2__c=opp.id;
        objquote.SBQQ__SubscriptionTerm__c = 1;
        insert objquote;
        
        SBQQ__QuoteLine__c quoteline=new SBQQ__QuoteLine__c();
        quoteline.SBQQ__Product__c=oppProd1.id;
        quoteline.SBQQ__Quote__c=objquote.Id;
        quoteline.Inventory_Id__c = '123';
        quoteline.Attribute_Relationship__c = atr.Id;
        insert quoteline;
        
        Geo_Location__c gl = new Geo_Location__c();
        gl.CountryName__c ='USA';
        gl.State_Abbrevation__c ='NY';
        gl.City_Name__c ='Newport';
        gl.CountryID__c = '1';
        gl.RecordTypeId = Schema.SObjectType.Geo_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
        gl.StateID__c ='34';
        gl.City_ID__c ='34077';       
        insert gl;
        
        Geo_Location__c gl1 = new Geo_Location__c();
        gl1.AOP_Name__c ='Debt Relief';
        gl1.AOP_ID__c  ='560';
        gl1.RecordTypeId = Schema.SObjectType.Geo_Location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
  
        insert gl1;

        String strJsonList = '[{"attributes":{"type":"Attribute_Lines__c"},"String_Value__c":"test","Attribute_Name__c":"Edition","Address_String__c":"test","Attribute_Picklist_Values__c":"2021","Attribute_Junction__c":"a6U7j000000DUGCEA4","Show_in_Docusign__c":true}]';
        String strJsonMap ='{"a6S7j000000D5LgEAK":{"attributes":{"type":"Attribute_Lines__c","url":"/services/data/v51.0/sobjects/Attribute_Lines__c/a6S7j000000D5LgEAK"},"String_Value__c":"test","Attribute_Name__c":"Edition","Address_String__c":"test","Attribute_Picklist_Values__c":"2021","Attribute_Junction__c":"a6U7j000000DUGWEA4","Show_in_Docusign__c":true}}';
        
        Test.startTest();
        ClassOnAttributeLines.updateAttrValues(attrLinesList);
        ClassOnAttributeLines.populateAddressStringFields(attrLinesList);
        ClassOnAttributeLines.populateValueIdsonAddressFields(attrLinesList);
        //ClassOnAttributeLines.blankInventoryId(strJsonList,strJsonMap);
        ClassOnAttributeLines.blankInventoryId(newLst,oldMap);
        Test.stopTest();
    }
}