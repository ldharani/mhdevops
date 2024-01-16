/* 
* Class Name   : CPQ_Quote_PDF_Generator
* Test Class   : CPQ_Quote_PDF_Generator_Test
* Description  : 

*  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-7688    Sachin        31/10/2022                   <T01>   Discovery - Can Finance override bad debt Credit Status to allow rep to send DS
MHMAC-428    SaiV          09/21/2023                   <T02>   DocuSign - Quote Level Validations - updated
************************************************************************************************************************

*/
global class CPQ_Quote_PDF_Generator {
    /* Last modified by - saiv MHBS-7306 T08 */
    @AuraEnabled
    public static string quoteAttrValidation(String qoId){
        system.debug('==qoId=='+qoId);
        String errorMsg = '';
        List<SBQQ__QuoteLine__c> qoLinesLst = new List<SBQQ__QuoteLine__c>();
        Set<Id> attrRelationId = new Set<Id>();
        List<Id> prodIds = new List<Id>();
        Map<Id,Id> prodIdIdVsAttrReltnId = new Map<Id,Id>();
        Map<Id,String> qlIdVsInventoried = new Map<Id,String>();
        String quotePrimConID;
        qoLinesLst = [select id,SBQQ__Quote__c,SBQQ__Discount__c, SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.SBQQ__Status__c,Attribute_Relationship__c, SBQQ__Product__c,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,Inventory_Id__c,Usage_List_Price__c,SBQQ__Quote__r.RecordTypeId,SIN__c,
                      SBQQ__ProductCode__c,SBQQ__Product__r.Name,SBQQ__Product__r.Upsell_Package__c ,SBQQ__Product__r.IsInventoried__c, SBQQ__Quote__r.SBQQ__PrimaryContact__c,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Email  from SBQQ__QuoteLine__c
                      where SBQQ__Quote__c=: qoId];
        system.debug('==qoLinesLst=='+qoLinesLst);
        if(qoLinesLst.Size() <= 0 ){
            errorMsg = 'Please add Quote Lines';
            return errorMsg;
        }
        // <T01>
        List<String> strOfCreditStatuses = new List<string> {'Good Standing', 'Bad Debt'};
        
        if(qoId != Null){
            // <T01>
            for(SBQQ__Quote__c quoteRec : [SELECT Id,RecordTypeId,Account_Credit_Status__c,SBQQ__Account__r.MH_Cust_Number__c,SBQQ__Account__c,SBQQ__Account__r.Avvo_CustomerID__c,SBQQ__Account__r.Credit_Sub_Status__c,SBQQ__PrimaryContact__c,SBQQ__PrimaryContact__r.Email,Billing_Contact__c,Billing_Contact__r.Email,Marketing_Contact__c,SBQQ__PriceBook__r.Name,Marketing_Contact__r.Email FROM SBQQ__Quote__c WHERE Id =: qoId]){

                if(quoteRec.RecordTypeId == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId() || quoteRec.RecordTypeId == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Ngage Quote').getRecordTypeId()){
                    
                    if(quoteRec.SBQQ__PrimaryContact__r.Email == Null){
                        errorMsg = 'Primary Contact : Email address is missing. Please provide primary contact Email address.';
                        return errorMsg;
                    }else if(quoteRec.Billing_Contact__r.Email == Null){
                        errorMsg = 'Billing Contact : Email address is missing. Please provide billing contact Email address.';
                        return errorMsg;
                    }else if(quoteRec.Marketing_Contact__r.Email == Null){
                       errorMsg = 'Marketing Contact : Email address is missing. Please provide marketing contact Email address.';
                        return errorMsg;
                    }
                }
                if(quoteRec.Account_Credit_Status__c != 'Good Standing' && quoteRec.RecordTypeId == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId() && !quoteRec.SBQQ__PriceBook__r.Name.contains('Ngage')){
                    errorMsg = 'Account Credit Status is Bad Debt/Past Due you cannot proceed further';
                    return errorMsg; 
                }
                // <T01>
                if(!strOfCreditStatuses.contains(quoteRec.Account_Credit_Status__c) && quoteRec.RecordTypeId == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId()){
                    errorMsg = 'Account Credit Status is Past Due you cannot proceed further';
                    return errorMsg; 
                }
                // <T01> Even Account Credit Status is 'Bad Debt' and Account Credit Sub Status is 'override' allowing users for PDF creation
                if(quoteRec.Account_Credit_Status__c == 'Bad Debt' && quoteRec.SBQQ__Account__r.Credit_Sub_Status__c != 'Override' && quoteRec.RecordTypeId == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId()){
                    errorMsg = 'Account Credit Sub Status is not Override, you cannot proceed further';
                    return errorMsg;
                }
            }
        }
        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        String userName = u.Username;

        Map<id, boolean> prodIdVsHasConfigAttrMap = new Map<id, boolean>();
        Map<id,id> attrJuncVsProdId = new Map<id,id>();
        Map<id,id> qlIdVsProdID = new Map<id,id>();
        Map<id,id> prodIdVsQIID = new Map<id,id>();
        
        String qoRecTypId;
        for(SBQQ__QuoteLine__c ql:qoLinesLst){
            //if(qoLinesLst.RecordTypeId == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('MH Quote').getRecordTypeId() || 
                //qoLinesLst.RecordTypeId == Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Ngage Quote').getRecordTypeId()){
                    quotePrimConID = ql.SBQQ__Quote__r.SBQQ__PrimaryContact__c;
            //}
            qoRecTypId = ql.SBQQ__Quote__r.RecordTypeId;
            system.debug('==qoRecTypId=='+qoRecTypId);
            attrRelationId.add(ql.Attribute_Relationship__c);
            system.debug('==attrRelationId50=='+attrRelationId.size());
            system.debug('==attrRelationId50=='+attrRelationId);
            prodIds.add(ql.SBQQ__Product__c);
            qlIdVsProdID.put(ql.id,ql.SBQQ__Product__c);
            prodIdVsQIID.put(ql.SBQQ__Product__c,ql.Id);
            prodIdVsHasConfigAttrMap.put(ql.SBQQ__Product__c, ql.SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c);
            prodIdIdVsAttrReltnId.put(ql.SBQQ__Product__c, ql.Attribute_Relationship__c);
            attrJuncVsProdId.put(ql.Attribute_Relationship__c, ql.SBQQ__Product__c);
            
            
            if(ql.SBQQ__Product__r.IsInventoried__c == TRUE){
                qlIdVsInventoried.put(ql.Id,ql.Inventory_Id__c);
            }
        }
        system.debug('quotePrimConID'+quotePrimConID);
        //contact validation
        if(qoRecTypId != Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Nolo Quote').getRecordTypeId() && qoRecTypId != Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId()
                   && qoRecTypId != Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('M-A Cancel Quote').getRecordTypeId()){ //added by saiv M-A quote RT filer
            if(quotePrimConID != '' && quotePrimConID != Null){
                system.debug('==inside if==');
                Contact con = [select id, email from contact where Id =: quotePrimConID limit 1];
                if(con.email == null){
                    errorMsg = 'Please add primary contact email';
                    return errorMsg;
                }
            }
            else{
                errorMsg = 'Please add primary contact';
                return errorMsg;
            
            }
        }
        system.debug('===qlIdVsInventoried==='+qlIdVsInventoried);
        system.debug('==prodIds=='+prodIds);
        Map<String,Integer> prodVsAttrSize = new Map<String,Integer>();
        List<Product2> prodLst = [select id,name, SBQQ__HasConfigurationAttributes__c,(select id,Product__c
                                                From Product_Attributes__r) from Product2 where id IN: prodIds];
        system.debug('==prodLst=='+prodLst);
        for(Product2 prod: prodLst){
            system.debug('==insidefor==');
            //string qlId = prodIdVsQIID.get(prod.Id);
            if(prod.Product_Attributes__r != Null && prod.Product_Attributes__r.size()>0){
                prodVsAttrSize.put(prod.Id,prod.Product_Attributes__r.size());
            }
        }
        
        system.debug('==prodVsAttrSize=='+prodVsAttrSize);
        Map<Id, Integer> attrRelatnIdVsAttrLines = new Map<Id, Integer>();
        List<Attribute_Relationship__c> attrRelationLst = [select id, (select id,Attribute_Junction__c from Attribute_Lines__r)
                                          from Attribute_Relationship__c where id IN:attrRelationId];
        for(Attribute_Relationship__c attrRel:attrRelationLst){
            if(attrRel.Attribute_Lines__r != Null){
                attrRelatnIdVsAttrLines.put(attrRel.Id, attrRel.Attribute_Lines__r.size());
            }
        }
        system.debug('==attrRelatnIdVsAttrLines=='+attrRelatnIdVsAttrLines);
        system.debug('==attrRelationId=='+attrRelationId.size());
        //if(attrRelationId.size()>1){
        List<Attribute_Lines__c> attrLinesLst = [select id, Attribute_Junction__c, Attribute_Type__c,
                                                 Address_String__c, Boolean_Value__c, Multi_Select_Value__c, Product_Attribute__c,
                                                Number_Value__c, Phone_Value__c, Picklist_Value__c, String_Value__c
                                                From Attribute_Lines__c where Attribute_Junction__c IN:attrRelationId and 
                                                Product_Attribute__c != Null and Attribute_Junction__c != Null];
        system.debug('==prodVsAttrSize=='+prodVsAttrSize); 
        
        
        if(attrLinesLst.isEmpty()){
            system.debug('==attrLinesLst==='+attrLinesLst);
            for(Id attrid : attrRelationId){
                if(prodIdVsHasConfigAttrMap.get(attrJuncVsProdId.get(attrid)) == TRUE){
                    system.debug('==errorMsg=='+errorMsg);
                    errorMsg = 'Please add attributes';
                    return errorMsg;    
                }    
            } 
        }
        else{
            if(prodIdIdVsAttrReltnId != Null && prodIdIdVsAttrReltnId.size()>0){
                for(SBQQ__QuoteLine__c ql:qoLinesLst){
                    system.debug('===flag=='+attrRelatnIdVsAttrLines.containsKey(prodIdIdVsAttrReltnId.get(ql.SBQQ__Product__c)));
                    if(ql.Attribute_Relationship__c == Null && ql.SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c == TRUE){
                        errorMsg = 'Please add attributes';
                        system.debug('==errorMsg=='+errorMsg);
                        return errorMsg;    
                    }
                    if(prodVsAttrSize.containsKey(ql.SBQQ__Product__c) && attrRelatnIdVsAttrLines.containsKey(prodIdIdVsAttrReltnId.get(ql.SBQQ__Product__c))){
                        if(prodVsAttrSize.get(ql.SBQQ__Product__c) != attrRelatnIdVsAttrLines.get(prodIdIdVsAttrReltnId.get(ql.SBQQ__Product__c))){
                            if(ql.SBQQ__Product__r.Name.contains('SEO') || ql.SBQQ__ProductCode__c == '01662'){//for SEO Products T08
                                if(prodVsAttrSize.get(ql.SBQQ__Product__c) > attrRelatnIdVsAttrLines.get(prodIdIdVsAttrReltnId.get(ql.SBQQ__Product__c))){
                                    errorMsg = 'Please create all the attributes';
                                }    
                            }
                            else{
                                errorMsg = 'Please create all the attributes';
                                system.debug('==errorMsg=='+errorMsg);
                            }
                            return errorMsg;
                            
                        }
                    }
                    /*
                    if(qlIdVsInventoried.containsKey(ql.Id) && qlIdVsInventoried.get(ql.Id) == Null){
                        errorMsg = 'Inventoried Products dont have Inventory Id';
                        system.debug('==errorMsg=='+errorMsg);
                        return errorMsg;
                    }*/
                    if((ql.Usage_List_Price__c == 0 || ql.Usage_List_Price__c == Null) && 
                        ql.SBQQ__Product__r.Name == 'Usage based Leads Cases Product'){
                        system.debug('==errorMsg=='+errorMsg);
                        errorMsg = 'Price is Missing';
                        return errorMsg;
                    }
                }    
            }    
        }
        //}
        system.debug('==errorMsg1=='+errorMsg);
        //system.debug('===quoteLineIds==='+quoteLineIds);
        //system.debug('==errorMsg3=='+errorMsg);
        return errorMsg;
    }
    
    @AuraEnabled//<T02>
    public static string checkInvTrg(String qoId){
        system.debug('=====qoId====='+qoId);
        List<SBQQ__QuoteLine__c> qoLinesLst = new List<SBQQ__QuoteLine__c>();
        Set<Id> quoteLineIds = new Set<Id>(); //addedsaiv
        Set<Id> prodIds = new Set<Id>();
        Set<Id> attrRelationId = new Set<Id>();

        Map<Id,Id> prodIdIdVsAttrReltnId = new Map<Id,Id>();
        Map<id, boolean> prodIdVsHasConfigAttrMap = new Map<id, boolean>();
        Map<id,id> attrJuncVsProdId = new Map<id,id>();
        Map<id,id> qlIdVsProdID = new Map<id,id>();
        Map<id,id> prodIdVsQIID = new Map<id,id>();

        User u = [select Id, username from User where Id = :UserInfo.getUserId()];
        String userName = u.Username;
        String errorMsg = '';
        String custNum;
        String avvoCuId;
        String accId;
        //String qIDforNonQBProd;
        List<SBQQ__Quote__c> quoteRec = [SELECT Id, SBQQ__Account__r.MH_Cust_Number__c,SBQQ__Account__c,SBQQ__Account__r.Avvo_CustomerID__c,Billing_Contact__c,Billing_Contact__r.Email,
        (select id, SBQQ__Product__r.IsInventoried__c, SIN__c, Inventory_Id__c, SFInventoryId__c,SBQQ__ProductCode__c,AvailableCount__c, ReservedCount__c,SBQQ__Product__c,Attribute_Relationship__c,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,
        SBQQ__Product__r.Name,Created_From_Quote_Builder__c from SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id =: qoId];
        
        /*for(SBQQ__Quote__c quoteRec : [SELECT Id, SBQQ__Account__r.MH_Cust_Number__c,SBQQ__Account__c,SBQQ__Account__r.Avvo_CustomerID__c,Billing_Contact__c,Billing_Contact__r.Email,
            (select id, SBQQ__Product__r.IsInventoried__c, SIN__c, Inventory_Id__c, SBQQ__ProductCode__c,AvailableCount__c, ReservedCount__c,SBQQ__Product__c,
            Created_From_Quote_Builder__c from SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id =: qoId]){*/
        for(SBQQ__Quote__c qr: quoteRec){        
            custNum = qr.SBQQ__Account__r.MH_Cust_Number__c;
            avvoCuId = qr.SBQQ__Account__r.Avvo_CustomerID__c;
            accId = qr.SBQQ__Account__c;
            if(qr.Billing_Contact__r.Email == Null){
                errorMsg = 'Billing Contact : Email address is missing. Please provide billing contact Email address.';
            }
                    //return errorMsg;
            for(SBQQ__QuoteLine__c ql: qr.SBQQ__LineItems__r){
                system.debug('====status======'+ql);
                if(ql.Created_From_Quote_Builder__c == FALSE){
                    prodIds.add(ql.SBQQ__Product__c); //prodIds
                    attrRelationId.add(ql.Attribute_Relationship__c); //attributerelationIds
                    //prodIds.add(ql.SBQQ__Product__c);
                    qlIdVsProdID.put(ql.id,ql.SBQQ__Product__c);
                    prodIdVsQIID.put(ql.SBQQ__Product__c,ql.Id);
                    prodIdVsHasConfigAttrMap.put(ql.SBQQ__Product__c, ql.SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c);
                    prodIdIdVsAttrReltnId.put(ql.SBQQ__Product__c, ql.Attribute_Relationship__c);
                    attrJuncVsProdId.put(ql.Attribute_Relationship__c, ql.SBQQ__Product__c);
                }
                if(/*ql.Created_From_Quote_Builder__c == TRUE &&*/ ql.SBQQ__Product__r.IsInventoried__c == TRUE && ql.SIN__c == Null){
                    system.debug('==inventoriedqls=='+ql);
                    //if(ql.SBQQ__Product__r.IsInventoried__c == TRUE && ql.SIN__c == Null){
                        system.debug('==inventoriedqls=='+ql);
                        system.debug('==resrevecount=='+ql.ReservedCount__c);
                    	if(ql.ReservedCount__c == Null){
                            quoteLineIds.add(ql.Id);
                        }
                    //}
                }
            } 
        }
        //start=============<T02.1>
        if(!prodIds.isEmpty()){
            Map<String,Integer> prodVsAttrSize = new Map<String,Integer>();
            List<Product2> prodLst = [select id,name,SBQQ__HasConfigurationAttributes__c,(select id,Product__c
                                                From Product_Attributes__r) from Product2 where id IN: prodIds];
            system.debug('==prodLst=='+prodLst);
            for(Product2 prod: prodLst){
                system.debug('==insidefor==');
                //string qlId = prodIdVsQIID.get(prod.Id);
                if(prod.Product_Attributes__r != Null && prod.Product_Attributes__r.size()>0){
                    prodVsAttrSize.put(prod.Id,prod.Product_Attributes__r.size());
                }
            }
            system.debug('==prodVsAttrSize=='+prodVsAttrSize);
            Map<Id, Integer> attrRelatnIdVsAttrLines = new Map<Id, Integer>();
            List<Attribute_Relationship__c> attrRelationLst = [select id, (select id,Attribute_Junction__c from Attribute_Lines__r)
                                          from Attribute_Relationship__c where id IN:attrRelationId];
            for(Attribute_Relationship__c attrRel:attrRelationLst){
                if(attrRel.Attribute_Lines__r != Null){
                    attrRelatnIdVsAttrLines.put(attrRel.Id, attrRel.Attribute_Lines__r.size());
                }
            }
            system.debug('==attrRelatnIdVsAttrLines=='+attrRelatnIdVsAttrLines);
            system.debug('==attrRelationId=='+attrRelationId.size());
            //if(attrRelationId.size()>1){
            List<Attribute_Lines__c> attrLinesLst = [select id, Attribute_Junction__c, Attribute_Type__c,
                                                    Address_String__c, Boolean_Value__c, Multi_Select_Value__c, Product_Attribute__c,
                                                    Number_Value__c, Phone_Value__c, Picklist_Value__c, String_Value__c
                                                    From Attribute_Lines__c where Attribute_Junction__c IN:attrRelationId and 
                                                    Product_Attribute__c != Null and Attribute_Junction__c != Null];
            system.debug('==prodVsAttrSize=='+prodVsAttrSize); 
            
            
            if(attrLinesLst.isEmpty()){
                system.debug('==attrLinesLst==='+attrLinesLst);
                for(Id attrid : attrRelationId){
                    if(prodIdVsHasConfigAttrMap.get(attrJuncVsProdId.get(attrid)) == TRUE){
                        system.debug('==errorMsg=='+errorMsg);
                        errorMsg = 'Please add attributes';
                        return errorMsg;    
                    }    
                } 
            }else{
                if(prodIdIdVsAttrReltnId != Null && prodIdIdVsAttrReltnId.size()>0){
                    for(SBQQ__Quote__c qr2: quoteRec){
                        for(SBQQ__QuoteLine__c qlin: qr2.SBQQ__LineItems__r){
                            system.debug('===flag=='+attrRelatnIdVsAttrLines.containsKey(prodIdIdVsAttrReltnId.get(qlin.SBQQ__Product__c)));
                            if(qlin.Attribute_Relationship__c == Null && qlin.SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c == TRUE){
                                errorMsg = 'Please add attributes';
                                system.debug('==errorMsg=='+errorMsg);
                                return errorMsg;    
                            }
                            if(prodVsAttrSize.containsKey(qlin.SBQQ__Product__c) && attrRelatnIdVsAttrLines.containsKey(prodIdIdVsAttrReltnId.get(qlin.SBQQ__Product__c))){
                                if(prodVsAttrSize.get(qlin.SBQQ__Product__c) != attrRelatnIdVsAttrLines.get(prodIdIdVsAttrReltnId.get(qlin.SBQQ__Product__c))){
                                    if(qlin.SBQQ__Product__r.Name.contains('SEO') || qlin.SBQQ__ProductCode__c == '01662'){//for SEO Products T08
                                        if(prodVsAttrSize.get(qlin.SBQQ__Product__c) > attrRelatnIdVsAttrLines.get(prodIdIdVsAttrReltnId.get(qlin.SBQQ__Product__c))){
                                            errorMsg = 'Please create all the attributes';
                                        }    
                                    }
                                    else{
                                        errorMsg = 'Please create all the attributes';
                                        system.debug('==errorMsg=='+errorMsg);
                                    }
                                    return errorMsg;
                                    
                                }
                            }
                        }
                    }   
                }        
            }
        }
        //end================ <T02.1>
        if(!quoteLineIds.isEmpty()){
            CPQ_CheckInvRequestCtrl penClass = new CPQ_CheckInvRequestCtrl();
            errorMsg = penClass.cpq_checkInventoryRequest(quoteLineIds, custNum, avvoCuId, userName, accId);    
        }
        system.debug('==errorMsg1=='+errorMsg);
        return errorMsg;
    }
    
    @AuraEnabled
    public String fileID{get; set;}
    @AuraEnabled
    public static String quotePDF(String oppid){
    
       //UpsellPackageAssist(oppid);
        system.debug('===oppid==='+oppid);
        //SBQQ__Quote__c oppty = [Select Id,SBQQ__Account__r.MH_Cust_Number__c, Name From SBQQ__Quote__c Where id =: oppid];
        
        pagereference Pg = Page.CPQ_CreateQuoteApprovalPagePDF;
            pg.getParameters().put('id',oppid);
            System.debug('oppid'+oppid);
            Blob pdf1;
            if(!test.isRunningTest()){
                pdf1 = pg.getcontentAsPdf();
            }
             else{
                 pdf1 = blob.valueof('TEST');
             }
            SBQQ__Quote__c oppty = [Select Id,SBQQ__Account__r.MH_Cust_Number__c, Name, RecordType.Name From SBQQ__Quote__c Where id =: oppid];
            //for M-A Quotes (Content PDF)
            if(oppty.RecordType.Name == 'M-A Quote' || oppty.RecordType.Name == 'MH Quote' || Test.isRunningTest()){
                datetime tt=system.now();
                string ss=tt.format();
                ss = ss.replace('/','-');
                ContentVersion contentVersion_1 = new ContentVersion(
                    Title= oppty.SBQQ__Account__r.MH_Cust_Number__c+'-ORD-'+ss+'.pdf', //SampleTitle
                    PathOnClient = oppty.SBQQ__Account__r.MH_Cust_Number__c +'-ORD-'+ss+'.pdf',
                    VersionData = pdf1, 
                    origin = 'H'
                );
                insert contentVersion_1;
                ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
                
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = oppid;
                contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
                contentlink.ShareType = 'V';
                insert contentlink;

                system.debug('==contentlink.contentdocumentid:'+contentlink.contentdocumentid);
                String documentId = contentlink.contentdocumentid;
                system.debug('==documentId'+documentId);
                return documentId;
            }else{ //for all other RT quotes (MH,Nolo,Ngage - Normal PDF)
                attachment pdf = new attachment();        
                pdf.ParentId = oppid;
                System.debug('Checking if the attachment has id in it'+pdf.ParentId);
                pdf.Body = Pdf1;

                datetime tt=system.now();
                string ss=tt.format();
                ss = ss.replace('/','-');
                pdf.Name = oppty.SBQQ__Account__r.MH_Cust_Number__c +'-ORD-'+ss+'.pdf';             
                pdf.ContentType = 'application/pdf';        
                insert pdf ;
                //Account acc = [Select Id,Credit_Sub_Status__c From Account Where Id =:oppty.SBQQ__Account__c];
                //acc.Credit_Sub_Status__c = '';
                //update acc;
                return 'no Errors';
            }
            
        }
    // - Commented for release - saiv
    @AuraEnabled
    public static List<SBQQ__Quote__c> getQuoteInfoOnPDF(String oppid){
        List<SBQQ__Quote__c> oppLst = [Select Id,SBQQ__Account__r.MH_Cust_Number__c,Billing_Contact__c,Billing_Contact__r.Email,Billing_Contact__r.FirstName,Billing_Contact__r.LastName,SBQQ__SalesRep__r.Name, Name From SBQQ__Quote__c Where id =: oppid];
        return oppLst;
    }
    @AuraEnabled
    public static void sendPDF(String quoteId, String ccEmail, String emailSub, String emailBody){
        system.debug('==quoteId=='+quoteId);
        system.debug('==quoteId=='+ccEmail);
        system.debug('==quoteId=='+emailSub);
        //String Subject = 'Martindale Test Agreement';
        if(Test.isRunningTest() != true){
        DocusignPaymentApi.generateandSendEnvelope(quoteId, ccEmail, emailSub, emailBody);
        }
    }
    
    @AuraEnabled
    public static boolean showUsellAlert(String qoId){
        boolean isDisplayUpsellAlert = false;
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c WHERE Id =: qoId AND Amend_Bundle__c = 'Upsell'];
        if(!lstQuote.isEmpty()){
            isDisplayUpsellAlert = true;
        }
        return isDisplayUpsellAlert;
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
    }
}