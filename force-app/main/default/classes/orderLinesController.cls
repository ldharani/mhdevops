/*
Apex Class   : orderLinesController
Created By   : Serge Kandukuri
Description  : This is View Attribute Component Class
*/
Public class orderLinesController{
    /*
        Method Name: fetchOLI
        Description: This method is used to Fetch list of OrderItem
        Parameter  : String strOLIId - Order record Id
    */
    
    @AuraEnabled
    public static List<wrapperOLI> fetchOLI(String strOrderId, String strStatus){
        Map<Id, Integer> mapProductWithTotalAttribute = fetchOLIProductWithAttributeCount(strOrderId);
        
        List<wrapperOLI> returnOLI = new List<wrapperOLI>();
        String strSOQL;
        strSOQL = 'SELECT ' + queryAllFields('OrderItem');
        strSOQL += ' ,Product2.Name,Product2.SBQQ__HasConfigurationAttributes__c ';
        strSOQL += ' FROM OrderItem';
        strSOQL += ' WHERE OrderId =: strOrderId';
        if(strStatus != null && strStatus != ''){
            strSOQL += ' AND Status__c =: strStatus';
        }
        strSOQL += ' ORDER BY OrderItemNumber ASC';
        //strSOQL += ' ORDER BY Createddate DESC';
        system.debug('#######'+strSOQL);
        List<OrderItem> lstOLI = database.query(strSOQL);
        
        //String quoteId; //addedbysaiv  
        List<String> quoteIds = new List<String>();
        set<Id> sAttributeRelationshipId = new set<Id>();
        for(OrderItem oli: lstOLI){
            sAttributeRelationshipId.add(oli.Attribute_Relationship__c);
            quoteIds.add(oli.Quote__c);
        }
        Map<Id, List<Attribute_Lines__c>> mapARIdWithAttributeLines = new Map<Id, List<Attribute_Lines__c>>();
        if(!sAttributeRelationshipId.isEmpty()){
            List<Attribute_Lines__c> lstARLines = [SELECT Id, Attribute_Junction__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN: sAttributeRelationshipId];
            for(Attribute_Lines__c al: lstARLines){
                if(mapARIdWithAttributeLines.containsKey(al.Attribute_Junction__c)){
                    mapARIdWithAttributeLines.get(al.Attribute_Junction__c).add(al);
                }else{
                    List<Attribute_Lines__c> lstARLinesAdd = new List<Attribute_Lines__c>();
                    lstARLinesAdd.add(al);
                    mapARIdWithAttributeLines.Put(al.Attribute_Junction__c, lstARLinesAdd);
                }
            }
        }
        String quoteLineID; //added by saiv
        
        Map<Id, Attribute_Relationship__c> mapAR = new Map<Id, Attribute_Relationship__c>([SELECT Id, (SELECT Id, Attribute_Name__c, Attribute_Type__c, Boolean_Value__c, Date_Value__c, Number_Value__c, Picklist_Value__c, String_Value__c, Long_text_value__c, Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__r Order By Product_Attribute__r.Attribute_Order__c ASC) FROM Attribute_Relationship__c WHERE Id IN: sAttributeRelationshipId]);
        quoteLinesController.returnSubUsageStateandCounty(quoteIds);
        for(OrderItem oli: lstOLI){
            quoteLineID = oli.SBQQ__QuoteLine__c;
            wrapperOLI objOLI = new wrapperOLI();
            objoli.objOLI = oli;
            if(mapAR != null && mapAR.containsKey(oli.Attribute_Relationship__c)){
                objoli.lstAL = mapAR.get(oli.Attribute_Relationship__c).Attribute_Lines__r;
            }
            system.debug('==oli.SBQQ__QuoteLine__c=='+oli.SBQQ__QuoteLine__c);
            //quoteLinesController qlC = new quoteLinesController();
            objoli.ServiceStateWithCountiesHover = quoteLinesController.getServiceStateWithCountiesNew(quoteLineID);
            //objoli.ServiceStateWithCountiesHover = quoteLinesController.getServiceStateWCoun(quoteLineID);
            if(oli.Attribute_Relationship__c == null){
                objoli.addAttributeButtonColor = 'buttonClassRed'; // 'buttonClassYellow';
            }else{
                if(mapAR != null && mapAR.containsKey(oli.Attribute_Relationship__c)){
                    if(mapAR.get(oli.Attribute_Relationship__c).Attribute_Lines__r.isEmpty()){
                        objoli.addAttributeButtonColor = 'buttonClassRed'; // 'buttonClassYellow';
                    }else if(mapAR.get(oli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(oli.Attribute_Relationship__c).Attribute_Lines__r.size() != mapProductWithTotalAttribute.get(oli.Product2Id)){
                        //added for SEO/GEO 01/17/22 - saiv
                        if(!oli.Order_Product_Name__c.contains('SEO')){
                          objoli.addAttributeButtonColor = 'buttonClassRed';    
                        }else{
                            if(mapAR.get(oli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(oli.Attribute_Relationship__c).Attribute_Lines__r.size() < mapProductWithTotalAttribute.get(oli.Product2Id)){
                                objoli.addAttributeButtonColor = 'buttonClassRed';
                            }else{
                                objoli.addAttributeButtonColor = 'buttonClassGreen';
                            }
                        }//end
                        
                    }else if(mapAR.get(oli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(oli.Attribute_Relationship__c).Attribute_Lines__r.size() == mapProductWithTotalAttribute.get(oli.Product2Id)){
                        objoli.addAttributeButtonColor = 'buttonClassGreen';
                    }
                }
                
            }
            
            returnoli.add(objOLI);
        }
        return returnOLI;
    }
    
    /*
        Method Name: createOrUpdateAttribute
        Description: This method is used to create or update Attribute_Lines__c
        Parameter  : List<Attribute_Lines__c>, String strOLIId
    */
    @AuraEnabled
    public static List<wrapperOLI> createOrUpdateAttribute(List<Attribute_Lines__c> AttLines, String strOrderId, String strStatus){
        
        system.debug('@@@@@@@@@@@'+AttLines);
        
        List<Attribute_Lines__c> AttLinesUpsert = new List<Attribute_Lines__c>();
        for(Attribute_Lines__c al: AttLines){
            if((al.Attribute_Type__c == 'Boolean' && al.Boolean_Value__c != null) || 
               (al.Attribute_Type__c == 'Date' && al.Date_Value__c != null) || 
               ((al.Attribute_Type__c == 'Number' || al.Attribute_Type__c == 'Currency') && al.Number_Value__c != null) || 
               (al.Attribute_Type__c == 'Picklist' && (al.Picklist_Value__c != null || al.String_Value__c != null)) || 
               ((al.Attribute_Type__c == 'String' || al.Attribute_Type__c == 'Text') && al.String_Value__c != null) || 
               (al.Attribute_Type__c == 'Text Area' && al.Long_text_value__c != null)
            ){
                AttLinesUpsert.add(al);
            }
        }
        if(!AttLinesUpsert.isEmpty()){
            upsert AttLinesUpsert;
        }
        
        // Delete Attribute Lines -- START
        List<Attribute_Lines__c> lstALDel = new List<Attribute_Lines__c>();
        for(Attribute_Lines__c al: AttLines){
            if(al.id != null){
                if((al.Attribute_Type__c == 'Boolean' && al.Boolean_Value__c == null) || 
                   (al.Attribute_Type__c == 'Date' && al.Date_Value__c == null) || 
                   ((al.Attribute_Type__c == 'Number' || al.Attribute_Type__c == 'Currency') && al.Number_Value__c == null) || 
                   (al.Attribute_Type__c == 'Picklist' && ((al.Picklist_Value__c == null || al.Picklist_Value__c == '') || (al.String_Value__c == null || al.String_Value__c == ''))) || 
                   ((al.Attribute_Type__c == 'String' || al.Attribute_Type__c == 'Text') && (al.String_Value__c == null || al.String_Value__c == '')) || 
                   (al.Attribute_Type__c == 'Text Area' && (al.Long_text_value__c == null || al.Long_text_value__c == ''))
                ){
                    lstALDel.add(al);
                }
            }
        }
        if(!lstALDel.isEmpty()){
            delete lstALDel;
        }
        // Delete Attribute Lines -- END
        return fetchOLI(strOrderId, strStatus);
        
    }
    
     /*
        Method Name: retrieveAttributesLines
        Description: This method is used to retrieve attribute Lines of particular Order Line
        Parameter  : String strOLIId
    */
    @AuraEnabled
    public static List<Attribute_Lines__c> retrieveAttributesLines(String sARelationshipIdParam){
        string strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c');
        strSOQL += ',Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__c WHERE Attribute_Junction__c =: sARelationshipIdParam Order By Product_Attribute__r.Attribute_Order__c ASC';
        List<Attribute_Lines__c> lstARLines = database.query(strSOQL);
        return lstARLines;
    }
    
    /*
        Method Name: retrieveProductAttributes
        Description: This method is used to retrieve attribute of particular Order Line
        Parameter  : String strOLIId, String strProductId
    */
    @AuraEnabled
    public static List<wrapperAL> retrieveProductAttributes(String strOLIId, String strProductId){
        List<wrapperAL> lstwrapperALReturn = new List<wrapperAL>();
        
        // Fetch Existing Attribute_Lines__c -- START
        OrderItem objOLI = [SELECT Id, Attribute_Relationship__c FROM OrderItem WHERE Id =: strOLIId];
        string strARId;
        if(objoli.Attribute_Relationship__c == null){
            Attribute_Relationship__c objAR = new Attribute_Relationship__c();
            insert objAR;
            
            strARId = objAR.Id;
            objoli.Attribute_Relationship__c = objAR.Id;
            update objOLI; 
        }else{
            strARId = objoli.Attribute_Relationship__c;
        }
        
        Map<Id, Attribute_Lines__c> mapPAWithAttributeLine = new Map<Id, Attribute_Lines__c>();
        if(strARId != null){        
            String strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c') + ', Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__c WHERE Attribute_Junction__c =: strARId Order By Product_Attribute__r.Attribute_Order__c ASC';
            List<Attribute_Lines__c> returnQCA = database.query(strSOQL);
            for(Attribute_Lines__c al: returnQCA){
                mapPAWithAttributeLine.Put(al.Product_Attribute__c, al);
            }
        }
        // Fetch Existing Attribute_Lines__c -- END
       
        String strSOQLPA = 'SELECT ' + queryAllFields('ProductAttribute__c') + ', AttributeConfiguration__r.Name FROM ProductAttribute__c WHERE Product__c =: strProductId Order By Attribute_Order__c ASC';
        List<ProductAttribute__c> lstPA = database.query(strSOQLPA);
        Attribute_Lines__c objAL;
        
        String[] arrpicklistvalues = new String[]{};
        wrapperAL objwrapperAL;
        for(ProductAttribute__c pa: lstPA){
            arrpicklistvalues = new String[]{};
            if(mapPAWithAttributeLine != null && mapPAWithAttributeLine.containsKey(pa.Id)){
                objAL = mapPAWithAttributeLine.get(pa.Id);
            }else{
                objAL = new Attribute_Lines__c();
                objAL.Product_Attribute__c = pa.Id;
                objAL.Attribute_Junction__c = strARId;
                objAL.Attribute_Name__c = pa.AttributeConfiguration__r.Name;
                objAL.Attribute_Picklist_Values__c = pa.Attribute_Picklist_Values__c;
                objAL.Required__c = pa.Required__c;
                objAL.Secondary_Attribute_Name__c = pa.SecondaryAttributeName__c;
                objAL.Show_in_Docusign__c = pa.ShowinDocuSign__c;
                objAL.Attribute_Type__c = pa.AttributeType__c;
                
            }
            objwrapperAL = new wrapperAL();
            objwrapperAL.objAL = objAL;
            if(pa.Attribute_Picklist_Values__c != null){
                for(String str: pa.Attribute_Picklist_Values__c.split(',')){
                    arrpicklistvalues.add(str.trim());
                }
                objwrapperAL.picklistValues = arrpicklistvalues;
            }
            lstwrapperALReturn.add(objwrapperAL);
        }
        
         //return returnQCA;
        return lstwrapperALReturn;
    }
    
    /*
        Method Name: deleteAttributeItem
        Description: This method is used to delete Order_Charge_Attribute__c
        Parameter  : String strAtrId
    */
    @AuraEnabled
    public static List<Attribute_Lines__c> deleteAttributeItem(String strAtrId, String strOLIId){
        Attribute_Lines__c objQCA = new Attribute_Lines__c(id=strAtrId);
        delete objQCA;
        return null;
    }
    
    /*
        Method Name: queryAllFields
        Description: This method is used to return all fields of sObject 
        Parameter  : sObject API Name
    */
    Public static string queryAllFields(String strObjectAPIName){
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String queryFields = String.join( fieldNames, ',' );
        return queryFields;
    }// END OF METHOD - queryAllFields
    
    /*
        Method Name: getPicklistvalues
        Description: This method is used to fetch Picklist values dynamically.
        Parameter  : String objectName, String field_apiname,Boolean nullRequired
    */
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        system.debug('#############'+objectName);
        system.debug('#############'+field_apiname);
        List<String> optionlist = new List<String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(nullRequired == true){
            optionlist.add('--None--');
        }
        
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }
    
    /*
        Method Name: fetchOLIProductWithAttributeCount
        Description: This method is used to Fetch list of OrderItem
        Parameter  : String strOrderId - Order record Id
    */
    @AuraEnabled
    public static Map<Id, Integer> fetchOLIProductWithAttributeCount(String strOrderId){
        Map<Id, Integer> returnProductWithAttCount = new Map<Id, Integer>();
        List<OrderItem> lstOLI = [SELECT Id, Product2Id FROM OrderItem WHERE OrderId =: strOrderId];
        set<Id> sProdId = new set<Id>();
        for(OrderItem oli: lstOLI){
            sProdId.add(oli.Product2Id);
        }
        if(!sProdId.isEmpty()){
            List<Product2> lstProduct = [SELECT Id, (SELECT Id FROM Product_Attributes__r) FROM Product2 WHERE Id IN: sProdId];
            for(Product2 prd: lstProduct){
                returnProductWithAttCount.Put(prd.id, prd.Product_Attributes__r.size());
            }
        }
        return returnProductWithAttCount;
    }
    
    /*
        Method Name: fetchSuggestionsApex
        Description: This method is used to Fetch list of suggested values from GEO_Location__c
        Parameter  : String input
    */
    @AuraEnabled
    public static List<String> fetchSuggestionsApex(String input, String strFieldName){
        List<String> lstSuggestionsReturn = new List<String>();
        Set<String> sSuggestions = new Set<String>();
        system.debug('############'+strFieldName);
        if(strFieldName == 'Service City'){
            string inputTemp = input + '%';
            List<GEO_Location__c> lstGL= [SELECT Id, City_Name__c FROM GEO_Location__c WHERE City_Name__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: lstGL){
                if(gl.City_Name__c != null){
                    sSuggestions.add(gl.City_Name__c);
                }
            }
        }else if(strFieldName == 'Service State'){
            string inputTemp = input + '%';
            List<GEO_Location__c> lstGL= [SELECT Id, State_Abbrevation__c FROM GEO_Location__c WHERE State_Abbrevation__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: lstGL){
                if(gl.State_Abbrevation__c != null){
                    sSuggestions.add(gl.State_Abbrevation__c);
                }
            }
        }else if(strFieldName == 'Service Country'){
            string inputTemp = input + '%';
            List<GEO_Location__c> lstGL= [SELECT Id, CountryName__c FROM GEO_Location__c WHERE CountryName__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: lstGL){
                if(gl.CountryName__c != null){
                    sSuggestions.add(gl.CountryName__c);
                }
            }
        }
        lstSuggestionsReturn.addAll(sSuggestions);
        return lstSuggestionsReturn;
    }
    
     /*
        Method Name: getServiceStateWithCountiesNew
        Description: This method is used to Fetch list of Service States with county
        Parameter  : None
    */
    @AuraEnabled
    public static List<quoteLinesController.wrapperStates> getServiceStateWithCountiesNew(String strOLIId){
        List<OrderItem> lstOI = [SELECT Id, SBQQ__QuoteLine__c FROM OrderItem WHERE Id =: strOLIId];
        if(!lstOI.isEmpty()){
            return quoteLinesController.getServiceStateWithCountiesNew(lstOI[0].SBQQ__QuoteLine__c);
        }
        return null;
    }
    public class wrapperOLI{
        @AuraEnabled
        public OrderItem objOLI;
        @AuraEnabled
        public List<quoteLinesController.wrapperStates> ServiceStateWithCountiesHover;
        @AuraEnabled
        public string addAttributeButtonColor;
        @AuraEnabled
        public List<Attribute_Lines__c> lstAL;
    }
    
    
    public class wrapperAL{
        @AuraEnabled
        public Attribute_Lines__c objAL;
        @AuraEnabled
        public List<string> picklistValues;
    }
}