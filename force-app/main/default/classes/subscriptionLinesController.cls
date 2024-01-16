/*
** Created By : Serge Kandukuri
** Purpose    : This is View Attribute Component Class
** Test class : subscriptionLinesControllerTest

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-5720    VR            27/04/2022                   T01     Added 'ALL' as an option for subscription status picklist        
************************************************************************************************************************
*/
Public class subscriptionLinesController{
    /*
        Method Name: fetchSLI
        Description: This method is used to Fetch list of Subscription Lines
        Parameter  : String strContractId - Contract record Id
    */
    @AuraEnabled
    public static List<wrapperSLI> fetchSLI(String strContractId, String strStatus){
        Map<Id, Integer> mapProductWithTotalAttribute = fetchSLIProductWithAttributeCount(strContractId);
        
        List<wrapperSLI> returnSLI = new List<wrapperSLI>();
        String strSOQL;
        strSOQL = 'SELECT ' + queryAllFields('SBQQ__Subscription__c');
        strSOQL += ' ,SBQQ__OrderProduct__r.OrderItemNumber,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,SBQQ__RequiredByProduct__r.Name, RecordType.Name, SBQQ__OrderProduct__r.Order.RecordType.Name';
        strSOQL += ' FROM SBQQ__Subscription__c';
        strSOQL += ' WHERE SBQQ__Contract__c =: strContractId';
        if(strStatus != null && strStatus != '' && strStatus != 'All' ){ //T01
            strSOQL += ' AND Status__c =: strStatus';
        }
        strSOQL += ' ORDER BY Name ASC';
        //strSOQL += ' ORDER BY Createddate DESC';
        system.debug('#######'+strSOQL);
        List<SBQQ__Subscription__c> lstSLI = database.query(strSOQL);
        
        List<String> quoteIds = new List<String>();        
        set<Id> sAttributeRelationshipId = new set<Id>();
        for(SBQQ__Subscription__c sli: lstSLI){
            sAttributeRelationshipId.add(sli.Attribute_Relationship__c);
            system.debug('==sli.Quote__c=='+sli.Quote__c);
            quoteIds.add(sli.Quote__c);
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
        String quoteLineID;
        Map<Id, Attribute_Relationship__c> mapAR = new Map<Id, Attribute_Relationship__c>([SELECT Id, (SELECT Id, Attribute_Name__c, Attribute_Type__c, Boolean_Value__c, Date_Value__c, Number_Value__c, Picklist_Value__c, String_Value__c, Long_text_value__c, Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__r Order By Product_Attribute__r.Attribute_Order__c ASC) FROM Attribute_Relationship__c WHERE Id IN: sAttributeRelationshipId]);
        quoteLinesController.returnSubUsageStateandCounty(quoteIds);
        for(SBQQ__Subscription__c sli: lstSLI){
            //quoteLinesController.returnUsageStateandCounty(quoteId);
            wrapperSLI objSLI = new wrapperSLI();
            objSLI.objSLI = sli;
            quoteLineID = sli.SBQQ__QuoteLine__c;
            system.debug('===quoteLineID==='+quoteLineID);
            if(mapAR != null && mapAR.containsKey(sli.Attribute_Relationship__c)){
                objsli.lstAL = mapAR.get(sli.Attribute_Relationship__c).Attribute_Lines__r;
            }
            //objsli.ServiceStateWithCountiesHover = quoteLinesController.getServiceStateWithCountiesNew(sli.SBQQ__QuoteLine__c);
            objsli.ServiceStateWithCountiesHover = quoteLinesController.getServiceStateWithCountiesNew(quoteLineID);
            if(sli.Attribute_Relationship__c == null){
                objsli.addAttributeButtonColor = 'buttonClassRed'; // 'buttonClassYellow';
            }else{
                if(mapAR != null && mapAR.containsKey(sli.Attribute_Relationship__c)){
                    if(mapAR.get(sli.Attribute_Relationship__c).Attribute_Lines__r.isEmpty()){
                        objsli.addAttributeButtonColor = 'buttonClassRed'; // 'buttonClassYellow';
                    }else if(mapAR.get(sli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(sli.Attribute_Relationship__c).Attribute_Lines__r.size() != mapProductWithTotalAttribute.get(sli.SBQQ__Product__c)){
                        //added for SEO/GEO 01/17/22 - saiv
                        if(!sli.SBQQ__ProductName__c.contains('SEO')){
                            objsli.addAttributeButtonColor = 'buttonClassRed';    
                        }else{
                            if(mapAR.get(sli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(sli.Attribute_Relationship__c).Attribute_Lines__r.size() < mapProductWithTotalAttribute.get(sli.SBQQ__Product__c)){
                                objsli.addAttributeButtonColor = 'buttonClassRed';
                            }else{
                                objsli.addAttributeButtonColor = 'buttonClassGreen';
                            }
                        }//end
                    }else if(mapAR.get(sli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(sli.Attribute_Relationship__c).Attribute_Lines__r.size() == mapProductWithTotalAttribute.get(sli.SBQQ__Product__c)){
                        objsli.addAttributeButtonColor = 'buttonClassGreen';
                    }
                }
                
            }
            
            returnsli.add(objSLI);
        }
        return returnSLI;
    }
    
   
    /*
        Method Name: retrieveAttributesLines
        Description: This method is used to retrieve attribute Lines of particular Order Line
        Parameter  : String strOLIId
    */
    @AuraEnabled
    public static List<Attribute_Lines__c> retrieveAttributesLines(String sARelationshipIdParam){
        string strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c');
        strSOQL += ', Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__c WHERE Attribute_Junction__c =: sARelationshipIdParam Order By Product_Attribute__r.Attribute_Order__c ASC';
        List<Attribute_Lines__c> lstARLines = database.query(strSOQL);
        return lstARLines;
    }
    
    /*
        Method Name: retrieveProductAttributes
        Description: This method is used to retrieve attribute of particular Order Line
        Parameter  : String strOLIId, String strProductId
    */
    @AuraEnabled
    public static List<wrapperAL> retrieveProductAttributes(String strSLIId, String strProductId){
        List<wrapperAL> lstwrapperALReturn = new List<wrapperAL>();
        
        // Fetch Existing Attribute_Lines__c -- START
        SBQQ__Subscription__c objSLI = [SELECT Id, Attribute_Relationship__c, SBQQ__Product__c FROM SBQQ__Subscription__c WHERE Id =: strSLIId];
        string strARId;
        if(objsli.Attribute_Relationship__c == null){
            Attribute_Relationship__c objAR = new Attribute_Relationship__c();
            insert objAR;
            
            strARId = objAR.Id;
            objsli.Attribute_Relationship__c = objAR.Id;
            update objSLI; 
        }else{
            strARId = objsli.Attribute_Relationship__c;
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
                // objAL.Attribute_Order__c = pa.Attribute_Order__c;
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
        else
        {
            optionlist.add('All');   //T01
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
    public static Map<Id, Integer> fetchSLIProductWithAttributeCount(String strContractId){
        Map<Id, Integer> returnProductWithAttCount = new Map<Id, Integer>();
        List<SBQQ__Subscription__c> lstSLI = [SELECT Id, SBQQ__Product__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c =: strContractId];
        set<Id> sProdId = new set<Id>();
        for(SBQQ__Subscription__c sli: lstSLI){
            sProdId.add(sli.SBQQ__Product__c);
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
        Method Name: getServiceStateWithCountiesNew
        Description: This method is used to Fetch list of Service States with county
        Parameter  : None
    */
    @AuraEnabled
    public static List<quoteLinesController.wrapperStates> getServiceStateWithCountiesNew(String strSLIId){
        List<SBQQ__Subscription__c> lstSLI = [SELECT Id, SBQQ__QuoteLine__c, Quote__c FROM SBQQ__Subscription__c WHERE Id =: strSLIId];
        if(!lstSLI.isEmpty()){
            return quoteLinesController.getServiceStateWithCountiesNew(lstSLI[0].SBQQ__QuoteLine__c);
        }
        return null;
    }
    
    public class wrapperSLI{
        @AuraEnabled
        public SBQQ__Subscription__c objSLI;
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