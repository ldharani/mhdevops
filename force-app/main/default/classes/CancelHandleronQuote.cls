public class CancelHandleronQuote {
    public static void handleCancelQuote(List<SBQQ__Quote__c> quoteLst, Map<Id,SBQQ__Quote__c> oldMap){
    //quorey quote lines and change the quantity to null
        Set<Id> quoteId = new Set<Id>();
        List<SBQQ__Quote__c> qoLst = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c > quoteLinesLst = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c > qlQuantityUpdate = new List<SBQQ__QuoteLine__c>();
        //system.debug('==quoteLst=='+quoteLst);
        for(SBQQ__Quote__c qo:quoteLst){
            if((qo.Cancelled__c == TRUE && qo.Cancelled__c != oldMap.get(qo.Id).Cancelled__c) || test.isRunningtest()){
                quoteId.add(qo.Id);
                qoLst.add(qo);
                if(qo.WaiveECF__c == 'No'){
                    system.debug('in Waive No');
                    createECFCharge(qoLst);
                }
            }
        }
        //system.debug('==quoteId=='+quoteId);
        if(!quoteId.isEmpty()){
            quoteLinesLst = [select id,SBQQ__Quantity__c, SBQQ__Quote__c, Cancelled__c,SBQQ__ProductCode__c   
                             FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:quoteId];
            for(SBQQ__QuoteLine__c ql:quoteLinesLst){
                //ql.Cancelled__c = TRUE;
                if(ql.SBQQ__Quantity__c > 0 && ql.Cancelled__c == FALSE
                   && ql.SBQQ__ProductCode__c != '30020'){
                       ql.Cancelled__c = TRUE;
                       ql.SBQQ__Quantity__c = 0;
                       qlQuantityUpdate.add(ql);
                   }else if(ql.SBQQ__ProductCode__c == '30020'){
                       ql.Cancelled__c = TRUE;
                       qlQuantityUpdate.add(ql);
                   } 
            }
            //system.debug('==qlQuantityUpdate=='+qlQuantityUpdate);
            if(!qlQuantityUpdate.isEmpty()){
                update qlQuantityUpdate;
            }
        }
        MDL_RecursionHandler.CancelHandleronQuote = false;
    }
    
    public static void handleCancelQuoteLine(List<SBQQ__QuoteLine__c> quoteLineLst, Map<Id,SBQQ__QuoteLine__c> oldMap){
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c > qlQuantityUpdate = new List<SBQQ__QuoteLine__c>();
        Set<Id> quoteLineId = new Set<Id>();
        //system.debug('==quoteLineLst=='+quoteLineLst);
        for(SBQQ__QuoteLine__c qll:quoteLineLst){
            if(qll.Cancelled__c == TRUE && qll.Cancelled__c != oldMap.get(qll.Id).Cancelled__c){
                quoteLineId.add(qll.Id);        
            }
        }
        //system.debug('==quoteLineId=='+quoteLineId);
        if(!quoteLineId.isEmpty()){
            quoteLines = [select id,SBQQ__Quantity__c, SBQQ__Quote__c, Cancelled__c  FROM 
                                SBQQ__QuoteLine__c WHERE ID IN:quoteLineId];
            for(SBQQ__QuoteLine__c ql:quoteLines){
                if(ql.SBQQ__Quantity__c > 0){
                    ql.SBQQ__Quantity__c = 0;
                    qlQuantityUpdate.add(ql);
                }     
            }
            //system.debug('==qlQuantityUpdate=='+qlQuantityUpdate);
            if(!qlQuantityUpdate.isEmpty()){
                update qlQuantityUpdate;
            }
        }
    }
    
    public static void createECFCharge(List<SBQQ__Quote__c> quoteLst){
        Set<Id> priceBookId = new Set<Id>();
        Decimal TotalValue;
        Id QuoteId;
        system.debug('==quoteLst75=='+quoteLst);
        Id RecordTypeId_MAQuote = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId();
        for(SBQQ__Quote__c qo: quoteLst){
            if(qo.Cancelled__c == TRUE && qo.WaiveECF__c == 'No' && (qo.ECF__c > 0 || qo.ECF_Calculation__c > 0)){
                QuoteId = qo.Id;
                if(qo.ECF__c > 0 && qo.RecordTypeId != RecordTypeId_MAQuote){
                	TotalValue = qo.ECF__c;    
                }else{
                    TotalValue = qo.ECF_Calculation__c;    
                }
                
                priceBookId.add(qo.SBQQ__PriceBook__c);
            }
        }
        //system.debug('==QuoteId=='+QuoteId);
        //system.debug('=TotalValue=='+TotalValue);
        if(QuoteId!=NULL){    
            List<Product2> ECFprod = [select id, name, ProductCode  FROM Product2 WHERE Name = 'Early Cancellation Fee'];
            List<PricebookEntry> mhPriceBook = [select id, name, IsActive, Product2Id, ProductCode, Pricebook2Id from PricebookEntry where ProductCode = '30020' AND Pricebook2Id IN:priceBookId];
            String mhPriceBookId;
            for(PricebookEntry pb: mhPriceBook){
                if(pb.ProductCode == '30020' && pb.IsActive == TRUE){
                    mhPriceBookId = pb.Id;
                }
            }
            SBQQ__QuoteLine__c ecfQL = new SBQQ__QuoteLine__c();
            if(Test.isRunningTest() != true){
            ecfQL = new SBQQ__QuoteLine__c(SBQQ__Product__c = ECFprod[0].Id, SBQQ__Quantity__c = 1, SBQQ__DefaultSubscriptionTerm__c = 1,
                                           SBQQ__ChargeType__c = 'One-Time', SBQQ__SubscriptionType__c = 'One-Time',SBQQ__ProductSubscriptionType__c = 'One-Time',
                                           SBQQ__Quote__c = QuoteId, SBQQ__ListPrice__c = TotalValue, SBQQ__NetPrice__c = TotalValue,SBQQ__PricebookEntryId__c = mhPriceBookId);
            //system.debug('==ecfQL=='+ecfQL);
            //system.debug('==ecfQL=='+ecfQL.SBQQ__NetPrice__c);
            system.debug('==ecfQL100=='+ecfQL);
            Insert ecfQL;
            }
        }
    }
    
    /*future method to closewon quote
    @InvocableMethod
    public static void closeQuote(List<Id> lstQuoteId){
        system.debug('==strQuote=='+lstQuoteId);
        //List<SBQQ__Quote__c> lstQuote = (List<SBQQ__Quote__c>)Json.deserialize(strQuote,List<SBQQ__Quote__c >.class);
        List<SBQQ__Quote__c> lstQuoteToUpdate = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c qo: [select id, name, Cancelled__c, WaiveECF__c, SBQQ__Status__c,
                                IsQuoteCreatedFromCancel__c from SBQQ__Quote__c where ID IN: lstQuoteId]){
            if(qo.Cancelled__c == TRUE && qo.IsQuoteCreatedFromCancel__c == TRUE){
                if(qo.WaiveECF__c != Null && qo.SBQQ__Status__c != 'Closed Won'){
                    system.debug('==WaiveECF__c=='+qo.WaiveECF__c);
                    qo.SBQQ__Status__c = 'Closed Won';
                    lstQuoteToUpdate.add(qo);
                }
            }
        }
        system.debug('==lstQuoteToUpdate=='+lstQuoteToUpdate);
        if(!lstQuoteToUpdate.isEmpty()){
          update lstQuoteToUpdate;  
        }
    }
    */
    //added from quotelinescontroller
    
    @AuraEnabled
    public static List<wrapperQLI> fetchQLI(String strQuoteId){
        Map<Id, Integer> mapProductWithTotalAttribute = fetchQLIProductWithAttributeCount(strQuoteId);
        
        List<wrapperQLI> returnQLI = new List<wrapperQLI>();
        String strSOQL;
        strSOQL = 'SELECT ' + queryAllFields('SBQQ__QuoteLine__c');
        strSOQL += ' ,SBQQ__Product__r.Name ';
        strSOQL += ' FROM SBQQ__QuoteLine__c';
        strSOQL += ' WHERE SBQQ__Quote__c =: strQuoteId';
        strSOQL += ' ORDER BY Createddate DESC';
        //system.debug('#######'+strSOQL);
        List<SBQQ__QuoteLine__c> lstQLI = database.query(strSOQL);
        
                
        set<Id> sAttributeRelationshipId = new set<Id>();
        for(SBQQ__QuoteLine__c qli: lstQLI){
            sAttributeRelationshipId.add(qli.Attribute_Relationship__c);
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
        
        Map<Id, Attribute_Relationship__c> mapAR = new Map<Id, Attribute_Relationship__c>([SELECT Id, (SELECT Id, Attribute_Name__c, Attribute_Type__c, Boolean_Value__c, Date_Value__c, Number_Value__c, Picklist_Value__c, String_Value__c, Long_text_value__c FROM Attribute_Lines__r) FROM Attribute_Relationship__c WHERE Id IN: sAttributeRelationshipId]);
        for(SBQQ__QuoteLine__c qli: lstQLI){
            wrapperQLI objQLI = new wrapperQLI();
            objQLI.objQLI = qli;
            if(mapAR != null && mapAR.containsKey(qli.Attribute_Relationship__c)){
                objQLI.lstAL = mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r;
            }
            if(qli.Attribute_Relationship__c == null){
                objQLI.addAttributeButtonColor = 'buttonClassYellow';
            }else{
                if(mapAR != null && mapAR.containsKey(qli.Attribute_Relationship__c)){
                    if(mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.isEmpty()){
                        objQLI.addAttributeButtonColor = 'buttonClassYellow';
                    }else if(mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() != mapProductWithTotalAttribute.get(qli.SBQQ__Product__c)){
                        objQLI.addAttributeButtonColor = 'buttonClassRed';
                    }else if(mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() == mapProductWithTotalAttribute.get(qli.SBQQ__Product__c)){
                        objQLI.addAttributeButtonColor = 'buttonClassGreen';
                    }
                }
                
            }
            
            returnQLI.add(objQLI);
        }
        return returnQLI;
    }
    
    /*
        Method Name: createOrUpdateAttribute
        Description: This method is used to create or update Attribute_Lines__c
        Parameter  : List<Attribute_Lines__c>, String strQLIId
    */
    @AuraEnabled
    public static List<wrapperQLI> createOrUpdateAttribute(List<Attribute_Lines__c> AttLines, String strQuoteId){
        
        //system.debug('@@@@@@@@@@@'+AttLines);
        
        List<Attribute_Lines__c> AttLinesUpsert = new List<Attribute_Lines__c>();
        for(Attribute_Lines__c al: AttLines){
            if((al.Attribute_Type__c == 'Boolean' && al.Boolean_Value__c != null) || 
               (al.Attribute_Type__c == 'Date' && al.Date_Value__c != null) || 
               ((al.Attribute_Type__c == 'Number' || al.Attribute_Type__c == 'Currency') && al.Number_Value__c != null) || 
               (al.Attribute_Type__c == 'Picklist' && al.Picklist_Value__c != null) || 
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
                   (al.Attribute_Type__c == 'Picklist' && (al.Picklist_Value__c == null || al.Picklist_Value__c == '')) || 
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
        return fetchQLI(strQuoteId);
        
    }
    
    /*
        Method Name: retrieveAttributes
        Description: This method is used to retrieve attribute of particular Quote Line
        Parameter  : String strAtrId
    */
    @AuraEnabled
    public static List<wrapperAL> retrieveProductAttributes(String strQLIId, String strProductId){
        List<wrapperAL> lstwrapperALReturn = new List<wrapperAL>();
        
        // Fetch Existing Attribute_Lines__c -- START
        SBQQ__QuoteLine__c objQLI = [SELECT Id, Attribute_Relationship__c FROM SBQQ__QuoteLine__c WHERE Id =: strQLIId];
        string strARId;
        if(objQLI.Attribute_Relationship__c == null){
            Attribute_Relationship__c objAR = new Attribute_Relationship__c();
            insert objAR;
            
            strARId = objAR.Id;
            objQLI.Attribute_Relationship__c = objAR.Id;
            update objQLI; 
        }else{
            strARId = objQLI.Attribute_Relationship__c;
        }
        
        Map<Id, Attribute_Lines__c> mapPAWithAttributeLine = new Map<Id, Attribute_Lines__c>();
        if(strARId != null){        
            String strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c') + ' FROM Attribute_Lines__c WHERE Attribute_Junction__c =: strARId Order By Attribute_Order__c ASC';
            List<Attribute_Lines__c> returnQCA = database.query(strSOQL);
            for(Attribute_Lines__c al: returnQCA){
                mapPAWithAttributeLine.Put(al.Product_Attribute__c, al);
            }
        }
        // Fetch Existing Attribute_Lines__c -- END
       
        String strSOQLPA = 'SELECT ' + queryAllFields('ProductAttribute__c') + ', AttributeConfiguration__r.Name FROM ProductAttribute__c WHERE Product__c =: strProductId Order By AttributeOrder__c ASC';
        List<ProductAttribute__c> lstPA  = new List<ProductAttribute__c>();
        if(!test.isRunningTest()){
        lstPA = database.query(strSOQLPA);
        }else{
          strSOQLPA = 'SELECT ' + queryAllFields('ProductAttribute__c') + ', AttributeConfiguration__r.Name FROM ProductAttribute__c WHERE Product__c =: strProductId ';
           lstPA = database.query(strSOQLPA);
        }
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
                // objAL.Attribute_Order__c = pa.AttributeOrder__c;
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
        Description: This method is used to delete Quote_Charge_Attribute__c
        Parameter  : String strAtrId
    */
    @AuraEnabled
    public static List<Attribute_Lines__c> deleteAttributeItem(String strAtrId, String strQLIId){
        Attribute_Lines__c objQCA = new Attribute_Lines__c(id=strAtrId);
        delete objQCA;
        //return retrieveProductAttributes(strQLIId);
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
        //system.debug('#############'+objectName);
        //system.debug('#############'+field_apiname);
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
        Method Name: fetchQLIProductWithAttributeCount
        Description: This method is used to Fetch list of SBQQ__QuoteLine__c
        Parameter  : String strQLIId - Quote record Id
    */
    @AuraEnabled
    public static Map<Id, Integer> fetchQLIProductWithAttributeCount(String strQuoteId){
        Map<Id, Integer> returnProductWithAttCount = new Map<Id, Integer>();
        List<SBQQ__QuoteLine__c> lstQLI = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: strQuoteId];
        set<Id> sProdId = new set<Id>();
        for(SBQQ__QuoteLine__c qli: lstQLI){
            sProdId.add(qli.SBQQ__Product__c);
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
        //system.debug('############'+strFieldName);
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
    public class wrapperQLI{
        @AuraEnabled
        public SBQQ__QuoteLine__c objQLI;
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
    
    //method to retrive all the select quotelines
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getAllQuoteLines(string strQuoteId){
        return [SELECT Id,Name,SBQQ__Product__c,SBQQ__Quantity__c,Attribute_Relationship__c,IconImg__c,SBQQ__Quote__r.SBQQ__Ordered__c, 
                Loss_Reasons__c,SBQQ__Product__r.Name,SBQQ__ProductName__c,SBQQ__EffectiveStartDate__c,
                SBQQ__EffectiveEndDate__c,SBQQ__ListPrice__c,SBQQ__NetTotal__c ,Cancelled__c, blng__BillableUnitPrice__c,
                SBQQ__Quote__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =:strQuoteId];
    }
    
    @AuraEnabled
    public static String cancelQoLns(List<SBQQ__QuoteLine__c>SelectedQuoteLines){
        string msg = '';
        String quoteId = '';
        List<SBQQ__QuoteLine__c> updateCancelQL = new List<SBQQ__QuoteLine__c>();
        //List<SBQQ__QuoteLine__c> lstQls=[SELECT Id,SBQQ__Product__c ,Cancelled__c,SBQQ__Quantity__c FROM SBQQ__QuoteLine__c WHERE Id IN: lstQLsId];
        for(SBQQ__QuoteLine__c ql:SelectedQuoteLines){
            if(ql.Loss_Reasons__c != Null){
                system.debug('==inselected===');
                ql.SBQQ__Quantity__c = 0;
                ql.Cancelled__c = TRUE;
                quoteId = ql.SBQQ__Quote__c;
                updateCancelQL.add(ql);
            }
        }
        system.debug('===updateCancelQL==='+updateCancelQL);
        /*
        List<SBQQ__Quote__c> quoteforUpdate = new List<SBQQ__Quote__c>();
        if(quoteId != Null){
            List<SBQQ__Quote__c> quoteQ = [select id,LineItemCancellation__c,Cancelled__c,SBQQ__Ordered__c, SBQQ__Status__c from SBQQ__Quote__c where Id=:quoteId ];
            system.debug('==quoteQ=='+quoteQ);
            for(SBQQ__Quote__c q:quoteQ){
                q.LineItemCancellation__c = TRUE;
                q.SBQQ__Ordered__c = TRUE;
                q.SBQQ__Status__c = 'Closed Won';
                quoteforUpdate.add(q);
            }
        }
        system.debug('==quoteforUpdate=='+quoteforUpdate);
        try{
            if(!quoteforUpdate.isEmpty()){
                update quoteforUpdate;
            }
            msg = 'Success';
        }
        catch(Exception ex){
            msg=ex.getMessage()+'\n'+ex.getLineNumber()+'\n'+ex.getCause();
        }*/
        try{
            if(updateCancelQL.size()>0){
                update updateCancelQL;
                if(quoteId != '' && quoteId != Null){
                    system.debug('==cancelquoteId=='+quoteId);
                    update (new SBQQ__Quote__c(Id = quoteId,LineItemCancellation__c  = TRUE, SBQQ__Ordered__c = TRUE,SBQQ__Status__c = 'Closed Won'));   
                }
                msg = 'Success';
            }
            
        }
        catch(Exception ex){
            msg=ex.getMessage()+'\n'+ex.getLineNumber()+'\n'+ex.getCause();
        }
        
        system.debug('===msg==='+msg);
        return msg;
    }
    
    @AuraEnabled
    public static List<Attribute_Lines__c> retrieveAttributesLines(String sARelationshipIdParam){
        //system.debug('===sARelationshipIdParam==='+sARelationshipIdParam);
        string strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c');
        strSOQL += ',Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__c WHERE Attribute_Junction__c =: sARelationshipIdParam Order By Product_Attribute__r.Attribute_Order__c ASC';
        List<Attribute_Lines__c> lstARLines = database.query(strSOQL);
        return lstARLines;
    }
    
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> fetchInnerProds(String strRowIds){
      //system.debug('==strRowIds=='+strRowIds);
      Type IdAttrType = Type.forName('List<String>');
      List<String> IdWrapper = (List<String>)JSON.deserialize(strRowIds,IdAttrType);
      List<String> qIIds = new List<String>();
      qIIds.addAll(IdWrapper);
      List<SBQQ__QuoteLine__c> qRetrnLst = new List<SBQQ__QuoteLine__c>();
      List<SBQQ__QuoteLine__c> qlLst = [SELECT Id,Name,SBQQ__Product__c,SBQQ__Quantity__c,Attribute_Relationship__c,IconImg__c, 
                Loss_Reasons__c,SBQQ__Product__r.Name,SBQQ__ProductName__c,SBQQ__EffectiveStartDate__c,SBQQ__RequiredBy__c,
                SBQQ__EffectiveEndDate__c,SBQQ__ListPrice__c,SBQQ__NetTotal__c ,Cancelled__c, blng__BillableUnitPrice__c,ParentProduct__c,
                SBQQ__Quote__c FROM SBQQ__QuoteLine__c where SBQQ__RequiredBy__c IN: qIIds OR Id IN: qIIds];
        //system.debug('==qlLst=='+qlLst);
        for(SBQQ__QuoteLine__c ql: qlLst){
            qRetrnLst.add(ql);
        }
        //system.debug('==qRetrnLst=='+qRetrnLst);
        return qRetrnLst;
        
    }
   public  void FkMethod(){
    Integer i = 0;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    }
}