/*
Apex Class   : quoteLinesController
Created By   : Serge Kandukuri
Description  : This is Add Attribute Component Class

Change History
************************************************************************************************************************
Jira            ModifiedBy    Date         Requested By    Tag     Description
MHBS-6368       VR            21/04/2022                   T01     Free Sales Change - Hide Promo Fee Prods
MHBS-6894,6893  Sachin        02/6/2022                    T02      
************************************************************************************************************************

*/

Public class quoteLinesController{
    /*
Method Name: fetchQLI
Description: This method is used to Fetch list of SBQQ__QuoteLine__c
Parameter  : String strQLIId - Quote record Id
*/
    public static Map<String,List<String>> mapResults {get;set;}
    public static Map<String,SBQQ__QuoteLine__c> qLineMap {get;set;}
    public static Map<Id, List<Attribute_Lines__c>> mapARIdWithAttributeLines {get;set;}
    public static void returnUsageStateandCounty(String QuoteId){//addedbysaiv**START
        system.debug('===returnUsageStateandCounty===');
        qLineMap = new Map<String,SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c objQLI: [SELECT Id, Attribute_Relationship__c,MonthlyDiscountValue__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: QuoteId]){
            qLineMap.put(objQLI.Id,objQLI);
        }
        
        mapResults = new Map<String,List<String>>();
        List<Usage_State_and_County__c> lstUSC= [SELECT Id, State_Abbreviation__c, County_Name__c FROM Usage_State_and_County__c WHERE State_Abbreviation__c != null 
                                                 AND County_Name__c != null ORDER BY State_Abbreviation__c ASC];
        List<String> lstCounties;
        for(Usage_State_and_County__c usc: lstUSC){
            if(usc.State_Abbreviation__c != null){
                if(mapResults.containsKey(usc.State_Abbreviation__c) == false){
                    lstCounties = new List<String>();
                    lstCounties.add(usc.County_Name__c);
                    mapResults.put(usc.State_Abbreviation__c, lstCounties);
                }else{
                    mapResults.get(usc.State_Abbreviation__c).add(usc.County_Name__c);
                }
            }
        }
    }//END
    //this method is for subscription
    public static void returnSubUsageStateandCounty(List<String> QuoteIds){
        system.debug('===returnUsageStateandCounty===');
        qLineMap = new Map<String,SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c objQLI: [SELECT Id, Attribute_Relationship__c,SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: QuoteIds]){
            qLineMap.put(objQLI.Id,objQLI);
        }
        
        mapResults = new Map<String,List<String>>();
        List<Usage_State_and_County__c> lstUSC= [SELECT Id, State_Abbreviation__c, County_Name__c FROM Usage_State_and_County__c WHERE State_Abbreviation__c != null 
                                                 AND County_Name__c != null ORDER BY State_Abbreviation__c ASC];
        List<String> lstCounties;
        for(Usage_State_and_County__c usc: lstUSC){
            if(usc.State_Abbreviation__c != null){
                if(mapResults.containsKey(usc.State_Abbreviation__c) == false){
                    lstCounties = new List<String>();
                    lstCounties.add(usc.County_Name__c);
                    mapResults.put(usc.State_Abbreviation__c, lstCounties);
                }else{
                    mapResults.get(usc.State_Abbreviation__c).add(usc.County_Name__c);
                }
            }
        }
    }//END
    @AuraEnabled
    public static List<wrapperQLI> fetchQLI(String strQuoteId){
        Map<Id, Integer> mapProductWithTotalAttribute = fetchQLIProductWithAttributeCount(strQuoteId);
        
        List<wrapperQLI> returnQLI = new List<wrapperQLI>();
        String strSOQL;
        strSOQL = 'SELECT ' + queryAllFields('SBQQ__QuoteLine__c');
        strSOQL += ' ,SBQQ__Product__r.Name, SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.RecordType.Name,SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.Subscription_type__c, SBQQ__Product__r.Package_Wrapper__c,SBQQ__Product__r.SBQQ__HasConfigurationAttributes__c,SBQQ__Quote__r.Lock_Record__c,RecordType.DeveloperName,RecordType.Name  ';
        strSOQL += ' FROM SBQQ__QuoteLine__c ';
        strSOQL += ' WHERE SBQQ__Quote__c =: strQuoteId';
        strSOQL += ' AND SBQQ__ProductCode__c != \'PROMOFEE\' '; //T01
        strSOQL += ' ORDER BY Name ASC';
        //strSOQL += ' ORDER BY Createddate DESC';
        system.debug('#######'+strSOQL);
        List<SBQQ__QuoteLine__c> lstQLI = database.query(strSOQL);
        //SEO-Geo Changes
         List<AOPGeo_Products_List__c> aopGeoProd = [select id, Product_Code__c  from AOPGeo_Products_List__c];
        Set<String> aopGeoProdCode = new Set<String>();
        for(AOPGeo_Products_List__c ap:aopGeoProd){
            aopGeoProdCode.add(ap.Product_Code__c);
        }//end
        set<Id> sAttributeRelationshipId = new set<Id>();
        Boolean isAopGeoPro=false;//SEO-Geo Changes
        for(SBQQ__QuoteLine__c qli: lstQLI){
            sAttributeRelationshipId.add(qli.Attribute_Relationship__c);
            //SEO-Geo Changes
            if(aopGeoProdCode.contains(qli.SBQQ__ProductCode__c)){
                isAopGeoPro = true;
            }
        }
        //mapARIdWithAttributeLines = new Map<Id, List<Attribute_Lines__c>>();
        Map<Id, List<Attribute_Lines__c>> mapARIdWithAttributeLines = new Map<Id, List<Attribute_Lines__c>>();
        if(!sAttributeRelationshipId.isEmpty()){
            /*
            String strSOQLAL = 'SELECT ' + queryAllFields('Attribute_Lines__c') + ' FROM Attribute_Lines__c ';
            strSOQLAL += ' WHERE Attribute_Junction__c IN: sAttributeRelationshipId Order By Attribute_Order__c ASC';
            List<Attribute_Lines__c> lstARLines = database.query(strSOQLAL);*/
            List<Attribute_Lines__c> lstARLines = [SELECT Id, Attribute_Junction__c,Attribute_Order__c,Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__c WHERE Attribute_Junction__c IN: sAttributeRelationshipId order by Product_Attribute__r.Attribute_Order__c ASC Limit 5000];
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
        
        Map<Id, Attribute_Relationship__c> mapAR = new Map<Id, Attribute_Relationship__c>([SELECT Id, (SELECT Id, Attribute_Name__c, Attribute_Type__c, Boolean_Value__c, Date_Value__c, Number_Value__c, Picklist_Value__c, String_Value__c, Long_text_value__c,Product_Attribute__r.Attribute_Order__c  FROM Attribute_Lines__r Order By Product_Attribute__r.Attribute_Order__c ASC) FROM Attribute_Relationship__c WHERE Id IN: sAttributeRelationshipId]);
        system.debug('==mapAR=='+mapAR);
        for(SBQQ__QuoteLine__c qli: lstQLI){
            wrapperQLI objQLI = new wrapperQLI();
            objQLI.objQLI = qli;
            if(mapAR != null && mapAR.containsKey(qli.Attribute_Relationship__c)){
                objQLI.lstAL = mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r;
            }
            system.debug('==objQLI.lstAL=='+objQLI.lstAL);
            objQLI.ServiceStateWithCountiesHover = quoteLinesController.getServiceStateWithCountiesNew(qli.id);
            //objQLI.ServiceStateWithCountiesHover = quoteLinesController.getServiceStateWithCountiesUpdated(qli.id);
            if(qli.Attribute_Relationship__c == null){
                objQLI.addAttributeButtonColor = 'buttonClassRed'; // 'buttonClassYellow';
            }else{
                if(mapAR != null && mapAR.containsKey(qli.Attribute_Relationship__c)){
                    system.debug('####################');
                    system.debug('####################'+mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size());
                    system.debug('####################'+mapProductWithTotalAttribute.get(qli.SBQQ__Product__c));
                   
                    if(mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.isEmpty()){
                        objQLI.addAttributeButtonColor = 'buttonClassRed'; // 'buttonClassYellow';
                    /*}else if(mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() != mapProductWithTotalAttribute.get(qli.SBQQ__Product__c)){
                        objQLI.addAttributeButtonColor = 'buttonClassRed';
                    }else if(mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() == mapProductWithTotalAttribute.get(qli.SBQQ__Product__c)){
                        objQLI.addAttributeButtonColor = 'buttonClassGreen';
                    }*/
                     }else if(isAopGeoPro==false && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() != mapProductWithTotalAttribute.get(qli.SBQQ__Product__c)){
                        objQLI.addAttributeButtonColor = 'buttonClassRed';
                    }else if(isAopGeoPro==false && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() == mapProductWithTotalAttribute.get(qli.SBQQ__Product__c)){
                        objQLI.addAttributeButtonColor = 'buttonClassGreen';
                    }else if(isAopGeoPro==true && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() < mapProductWithTotalAttribute.get(qli.SBQQ__Product__c)){
                        objQLI.addAttributeButtonColor = 'buttonClassRed';
                    }else if(isAopGeoPro==true && mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > 0 && (mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() > mapProductWithTotalAttribute.get(qli.SBQQ__Product__c)
                            || mapAR.get(qli.Attribute_Relationship__c).Attribute_Lines__r.size() == mapProductWithTotalAttribute.get(qli.SBQQ__Product__c))){
                         objQLI.addAttributeButtonColor = 'buttonClassGreen';
                    }                                                                                                       
                }
            }
            objQLI.isShowViewAttribute = false;
            objQLI.isShowViewPdf = false; //change
            if(qli.SIN__c != null && qli.SIN__c != '' && qli.SBQQ__Quote__r.Subscription_type__c != null && qli.SBQQ__Quote__r.Subscription_type__c != '' && qli.SBQQ__ProductCode__c != '30030' && qli.SBQQ__ProductCode__c != '30040'){
                objQLI.isShowViewAttribute = true;
            }
            //change
            if(qli.SBQQ__Product__r.Name.contains('Rep Boost') || qli.SBQQ__Product__r.Name.contains('Reputation Boost')){
                objQLI.isShowViewPdf = true;
            }
            returnQLI.add(objQLI);
        }
        system.debug('===fetchQLI===');
        //returnUsageStateandCounty();
        return returnQLI;
    }
    
    /*
Method Name: createOrUpdateAttribute
Description: This method is used to create or update Attribute_Lines__c
Parameter  : List<Attribute_Lines__c>, String strQLIId
*/
    @AuraEnabled
    public static List<wrapperQLI> createOrUpdateAttribute(List<Attribute_Lines__c> AttLines, String strQuoteId, Boolean blnSelectAllParam, String aopGeoAttrLines){
        system.debug('==aopGeoAttrLines=='+aopGeoAttrLines);
        List<wrapperAL> aopGeoAttrLst = new List<wrapperAL>();
        if(aopGeoAttrLines != null){
            aopGeoAttrLst = (List<wrapperAL>)JSON.deserialize(aopGeoAttrLines, List<wrapperAL>.class);
        }
        system.debug('==aopGeoAttrLst=='+aopGeoAttrLst);
        string strAllState = '';
        string strAllCounty = '';
        string strAllCountyWithNumbers = '';
        //seo changes
        List<Attribute_Lines__c> alLst = new List<Attribute_Lines__c>();
        String attrJuncId = '';
        if(aopGeoAttrLst != null){
            for(wrapperAL al:aopGeoAttrLst){
                if(al.objAL != null){
                    attrJuncId = al.objAL.Attribute_Junction__c;
                }
            }
        }
        Map<Id,Attribute_Lines__c> extAopGeoMap = new Map<Id,Attribute_Lines__c>();
        List<Attribute_Lines__c> lstAopGeoLDel = [select id,Attribute_Junction__c,Product_Attribute__c,Attribute_Name__c,String_Value__c,
                                             Attribute_Type__c,Show_in_Docusign__c from Attribute_Lines__c
                                             where Attribute_Junction__c =: attrJuncId AND
                                             Attribute_Name__c =: 'Aop/Geo'];
        for(Attribute_Lines__c al: lstAopGeoLDel){
            extAopGeoMap.put(al.Id, al);
        }
        if(aopGeoAttrLst != null){
            for(wrapperAL al:aopGeoAttrLst){
                if(al.objAL != null){
                    Attribute_Lines__c a = new Attribute_Lines__c();
                    if(al.aopGeoId != null){
                        a.Id = al.aopGeoId;
                        if(extAopGeoMap != null && extAopGeoMap.containsKey(al.aopGeoId)){
                            extAopGeoMap.remove(al.aopGeoId);
                        }
                    }
                    a.Attribute_Type__c = 'String';
                    if(al.aopValue <> null && al.stateValue <> null && al.cityValue <> null){
                        a.String_Value__c = al.aopValue+';'+al.stateValue+';'+al.cityValue;    
                    }
                    //a.String_Value__c = al.aopValue+';'+al.stateValue+';'+al.cityValue;
                    a.Attribute_Name__c = al.objAL.Attribute_Name__c;
            a.Show_in_Docusign__c = true;    //T02
                    a.Attribute_Junction__c = al.objAL.Attribute_Junction__c;
                    //a.Product_Attribute__c = al.objAl.Product_Attribute__c;
                    if(a.String_Value__c <> null){
                        alLst.add(a);
                    }
                }
            }
        }
        if(!alLst.isEmpty()){
            Upsert alLst;
        }
        if(extAopGeoMap != null &&  extAopGeoMap.size() > 0){
            delete extAopGeoMap.values();
        }
        //end
        Map<String, List<String>> mapStateWithAllCounties = new Map<String, List<String>>();
        List<Usage_State_and_County__c> lstUSC= [SELECT Id, State_Abbreviation__c, County_Name__c FROM Usage_State_and_County__c ORDER BY State_Abbreviation__c ASC];
        for(Usage_State_and_County__c usc: lstUSC){
            if(mapStateWithAllCounties != null && mapStateWithAllCounties.containsKey(usc.State_Abbreviation__c)){
                mapStateWithAllCounties.get(usc.State_Abbreviation__c).add(usc.County_Name__c);
            }else{
                List<String> lstCounty = new List<String>();
                lstCounty.add(usc.County_Name__c);
                mapStateWithAllCounties.Put(usc.State_Abbreviation__c, lstCounty);
            }
        }
        system.debug('#############'+blnSelectAllParam);
        if(blnSelectAllParam != null && blnSelectAllParam){
            /*set<String> sAllState = new set<String>();
set<String> sAllCounty= new set<String>();

for(Usage_State_and_County__c usc: lstUSC){
if(usc.State_Abbreviation__c != null){
sAllState.add(usc.State_Abbreviation__c);
}
if(usc.County_Name__c != null){
sAllCounty.add(usc.County_Name__c);
}

}
for(String str: sAllState){
strAllState += str + ';';
}
for(String str: sAllCounty){
strAllCounty += str + ';';
}*/
            Nationwide_for_Service_County__mdt objNSC = [SELECT Id, All_Service_County__c, All_Service_State__c FROM Nationwide_for_Service_County__mdt LIMIT 1];
            strAllCounty = objNSC.All_Service_County__c;
            strAllState =  objNSC.All_Service_State__c;
        }
        
        List<Attribute_Lines__c> AttLinesUpsert = new List<Attribute_Lines__c>();
        for(Attribute_Lines__c al: AttLines){
            system.debug('===Attribute_Name__c==='+al.Attribute_Name__c);
            system.debug('===Attribute_Type__c==='+al.Attribute_Type__c);
            system.debug('===String_Value__c==='+al.String_Value__c);
            if((al.Attribute_Type__c == 'Boolean' && al.Boolean_Value__c != null) || 
               (al.Attribute_Type__c == 'Date' && al.Date_Value__c != null) || 
               ((al.Attribute_Type__c == 'Number' || al.Attribute_Type__c == 'Currency') && al.Number_Value__c != null) || 
               (al.Attribute_Type__c == 'Picklist' && al.Picklist_Value__c != null) || 
               (al.Attribute_Name__c == 'Xref State' && al.Picklist_Value__c != null) || 
               (al.Attribute_Name__c == 'County' && al.Picklist_Value__c != null) || 
               (al.Attribute_Name__c == 'Service County' && al.String_Value__c != null) || 
               (al.Attribute_Name__c == 'Xref County' && al.Picklist_Value__c != null) || 
               (al.Attribute_Name__c == 'Xref City' && al.Picklist_Value__c != null) || //added by saiv - 12/7/2020
               (al.Attribute_Name__c == 'City' && al.Picklist_Value__c != null) || 
               (al.Attribute_Type__c == 'Multi-Picklist' && al.Multi_Select_Value__c != null) || 
               ((al.Attribute_Type__c == 'String' || al.Attribute_Type__c == 'Text') && al.String_Value__c != null) || 
               (al.Attribute_Type__c == 'Text Area' && al.Long_text_value__c != null)
              ){
                  /*
if(al.Attribute_Name__c == 'Xref County' && (al.String_Value__c != null || al.Picklist_Value__c != null)){
if(al.String_Value__c != null){
al.Picklist_Value__c = al.String_Value__c;          
}
else if(al.Picklist_Value__c != null){
al.String_Value__c = al.Picklist_Value__c;    
}
}*/
                  if(blnSelectAllParam != null && blnSelectAllParam){
                      if(al.Attribute_Name__c == 'Service State' && al.Attribute_Type__c == 'Multi-Picklist'){
                          al.Multi_Select_Value__c = strAllState;
                      }
                      if(al.Attribute_Name__c == 'Service County' && al.Attribute_Type__c == 'Multi-Picklist'){
                          al.Multi_Select_Value__c = strAllCounty;
                          
                          al.State_and_Counties__c = '';
                      }
                  }
                  
                  AttLinesUpsert.add(al);
                  system.debug('==AttLinesUpsert=='+AttLinesUpsert);
              }
            
        }
        
        
        if(!AttLinesUpsert.isEmpty()){
            try{
                upsert AttLinesUpsert;
            }catch (DmlException ex) {
                throw new AurahandledException('Error Details : ' + ex.getDmlMessage(0));
            }
            Map<String, List<String>> mapStateWithSelectedCounties = new Map<String, List<String>>();
            List<Attribute_Lines__c> lstALUpdate = new List<Attribute_Lines__c>();
            for(Attribute_Lines__c al: AttLinesUpsert){
                if(al.Attribute_Name__c == 'Service County' && al.Attribute_Type__c == 'Multi-Picklist' && al.Multi_Select_Value__c != null){
                    string[] arrStateWithCounties = al.Multi_Select_Value__c.split(';');
                    for(String str: arrStateWithCounties){
                        string[] arrSingleStateWithCounty = str.split('---');
                        system.debug('############'+arrSingleStateWithCounty.size());
                        if(arrSingleStateWithCounty != null && !arrSingleStateWithCounty.isEmpty()){
                            if(mapStateWithSelectedCounties.containsKey(arrSingleStateWithCounty[0])){
                                mapStateWithSelectedCounties.get(arrSingleStateWithCounty[0]).add(arrSingleStateWithCounty[1]);
                            }else{
                                List<String> lstCounty = new List<String>();
                                if(arrSingleStateWithCounty.size() > 1){
                                    lstCounty.add(arrSingleStateWithCounty[1]);
                                    mapStateWithSelectedCounties.Put(arrSingleStateWithCounty[0], lstCounty);
                                }
                            }
                        }
                    }
                    
                    for(String str: mapStateWithSelectedCounties.keyset()){
                        if(str != null && str != ''){
                            if(mapStateWithSelectedCounties != null && mapStateWithSelectedCounties.containsKey(str) && mapStateWithSelectedCounties.get(str) != null && mapStateWithAllCounties != null && mapStateWithAllCounties.containsKey(str)){
                                if(strAllCountyWithNumbers == null){
                                    strAllCountyWithNumbers = '';
                                }
                                strAllCountyWithNumbers += str + '---(' + mapStateWithSelectedCounties.get(str).size() + '/' + mapStateWithAllCounties.get(str).size() + ');';
                            }
                        }
                    }
                    
                    Attribute_Lines__c objAL = new Attribute_Lines__c(id=al.id);
                    objAL.State_and_Counties__c = strAllCountyWithNumbers;
                    lstALUpdate.add(objAL);
                }
            }
            update lstALUpdate;
        }
        
        // Delete Attribute Lines -- START
        List<Attribute_Lines__c> lstALDel = new List<Attribute_Lines__c>();
        for(Attribute_Lines__c al: AttLines){
            if(al.id != null){
                if((al.Attribute_Type__c == 'Boolean' && al.Boolean_Value__c == null) || 
                   (al.Attribute_Type__c == 'Date' && al.Date_Value__c == null) || 
                   ((al.Attribute_Type__c == 'Number' || al.Attribute_Type__c == 'Currency') && al.Number_Value__c == null) || 
                   (al.Attribute_Type__c == 'Picklist' && (al.Picklist_Value__c == null || al.Picklist_Value__c == '') && al.Attribute_Name__c != 'County' && al.Attribute_Name__c != 'City' && al.Attribute_Name__c != 'Xref State' && al.Attribute_Name__c != 'Xref County' && al.Attribute_Name__c != 'Service County') || 
                   (al.Attribute_Name__c == 'County' && (al.Picklist_Value__c == null || al.Picklist_Value__c == '')) || 
                   (al.Attribute_Name__c == 'Xref State' && (al.Picklist_Value__c == null || al.Picklist_Value__c == '')) || 
                   (al.Attribute_Name__c == 'Xref County' && (al.Picklist_Value__c == null || al.Picklist_Value__c == '')) ||
                   (al.Attribute_Name__c == 'Xref City' && (al.Picklist_Value__c == null || al.Picklist_Value__c == '')) || //added by saiv - 12/7/2020
                   (al.Attribute_Name__c == 'Service County' && al.Attribute_Type__c != 'Multi-Picklist' && (al.String_Value__c == null || al.String_Value__c == '')) || 
                   (al.Attribute_Name__c == 'City' && (al.Picklist_Value__c == null || al.Picklist_Value__c == '')) || 
                   (al.Attribute_Type__c == 'Multi-Picklist' && (al.Multi_Select_Value__c == null || al.Multi_Select_Value__c == '')) || 
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
    //SEO-Geo changes
    //for AOP/GEO
    @AuraEnabled
    public static wrapperAL addNewProductAttributeforAopGeo(String strQLIId, String strProductId){
        SBQQ__QuoteLine__c objQLI = [SELECT Id, Attribute_Relationship__c, SBQQ__Product__c,SBQQ__Product__r.Name,SBQQ__ProductCode__c,
                                     SBQQ__Quote__r.SBQQ__Account__c FROM SBQQ__QuoteLine__c WHERE Id =: strQLIId]; 
        string strARId = objQLI.Attribute_Relationship__c;
        wrapperAL objwrapperAL = new wrapperAL();
        Attribute_Lines__c objAL;
        objAL = new Attribute_Lines__c();
        //objAL.Product_Attribute__c = objQLI.SBQQ__Product__c;
        objAL.Attribute_Junction__c = strARId;
        objAL.Attribute_Name__c = 'Aop/Geo';
        // objAL.Attribute_Order__c = pa.AttributeOrder__c;
        //objAL.Attribute_Picklist_Values__c = pa.Attribute_Picklist_Values__c;
        //objAL.Required__c = pa.Required__c;
        //objAL.Secondary_Attribute_Name__c = pa.SecondaryAttributeName__c;
        objAL.Show_in_Docusign__c = true;
        objAL.Attribute_Type__c = 'String';
        objwrapperAL.objAL = objAL;
        return objwrapperAL;
    }
    
    @AuraEnabled
    public static List<wrapperAL> retrieveProductAttributesforAopGeo(String strQLIId, String strProductId){
        SBQQ__QuoteLine__c objQLI = [SELECT Id, Attribute_Relationship__c, SBQQ__Product__c,SBQQ__Product__r.Name,SBQQ__ProductCode__c,
                                     SBQQ__Quote__r.SBQQ__Account__c FROM SBQQ__QuoteLine__c WHERE Id =: strQLIId];  
        string prdCode = objQLI.SBQQ__ProductCode__c;
        string strARId = objQLI.Attribute_Relationship__c;
        List<wrapperAL> aopGeoWrapperList = new List<wrapperAL>();
        if(prdCode != null){
            Map<string, AOPGeo_Products_List__c>  stringVSAopGeoPrdLst = AOPGeo_Products_List__c.getAll();
            Map<string, AOPGeo_Products_List__c>  prdCodeVSAopGeoPrdLst = new Map<string, AOPGeo_Products_List__c>();
            for(AOPGeo_Products_List__c a: stringVSAopGeoPrdLst.values()){
                prdCodeVSAopGeoPrdLst.put(a.Product_Code__c, a);
            }
            List<Attribute_Lines__c> alLst = [select id,Attribute_Junction__c,Product_Attribute__c,Attribute_Name__c,String_Value__c,
                                             Attribute_Type__c,Show_in_Docusign__c from Attribute_Lines__c
                                             where Attribute_Junction__c =: objQLI.Attribute_Relationship__c AND
                                             Attribute_Name__c =: 'Aop/Geo'];
            if(prdCodeVSAopGeoPrdLst != null && prdCodeVSAopGeoPrdLst.containsKey(prdCode)){
                if(alLst != Null && !alLst.isEmpty()){
                    for(Attribute_Lines__c al: alLst){
                        wrapperAL objwrapperAL = new wrapperAL();
                        objwrapperAL.aopGeoId = al.Id;
                        String[] strVal = al.String_Value__c.split(';');
                        objwrapperAL.aopValue = strVal[0];
                        objwrapperAL.stateValue = strVal[1];
                        objwrapperAL.cityValue = strVal[2];
                        Attribute_Lines__c objAL;
                        objAL = new Attribute_Lines__c();
                        //objAL.Product_Attribute__c = pa.Id;
                        objAL.Attribute_Junction__c = strARId;
                        objAL.Attribute_Name__c = 'Aop/Geo';
                        // objAL.Attribute_Order__c = pa.AttributeOrder__c;
                        //objAL.Attribute_Picklist_Values__c = pa.Attribute_Picklist_Values__c;
                        //objAL.Required__c = pa.Required__c;
                        //objAL.Secondary_Attribute_Name__c = pa.SecondaryAttributeName__c;
                        objAL.Show_in_Docusign__c = true;
                        objAL.Attribute_Type__c = 'String';
                        objwrapperAL.objAL = objAL;
                        aopGeoWrapperList.add(objwrapperAL);
                    }
                }else{
                    wrapperAL objwrapperAL = new wrapperAL();
                    Attribute_Lines__c objAL;
                    objAL = new Attribute_Lines__c();
                    //objAL.Product_Attribute__c = pa.Id;
                    objAL.Attribute_Junction__c = strARId;
                    objAL.Attribute_Name__c = 'Aop/Geo';
                    // objAL.Attribute_Order__c = pa.AttributeOrder__c;
                    //objAL.Attribute_Picklist_Values__c = pa.Attribute_Picklist_Values__c;
                    //objAL.Required__c = pa.Required__c;
                    //objAL.Secondary_Attribute_Name__c = pa.SecondaryAttributeName__c;
                    objAL.Show_in_Docusign__c = true;
                    objAL.Attribute_Type__c = 'String';
                    objwrapperAL.objAL = objAL;
                    aopGeoWrapperList.add(objwrapperAL);
                }
                return aopGeoWrapperList;
            }
            
        }
        return null;
    }
    //end
    
    /*
Method Name: retrieveAttributes
Description: This method is used to retrieve attribute of particular Quote Line
Parameter  : String strAtrId
*/
    @AuraEnabled
    public static List<wrapperAL> retrieveProductAttributes(String strQLIId, String strProductId){
        List<wrapperAL> lstwrapperALReturn = new List<wrapperAL>();
        System.debug(strProductId);
        // Fetch Existing Attribute_Lines__c -- START
        List<String> strList = new List<String>{'01514','01516','50050'};
        // Fetch Existing Attribute_Lines__c -- START
        SBQQ__QuoteLine__c objQLI = [SELECT Id, Attribute_Relationship__c, SBQQ__ProductCode__c,
                                     SBQQ__Product__c,SBQQ__Product__r.Name,SBQQ__Product__r.ProductCode,SBQQ__Quote__r.SBQQ__Account__c 
                                     FROM SBQQ__QuoteLine__c WHERE Id =: strQLIId];
        Boolean isCTN= strList.contains(objQLI.SBQQ__Product__r.ProductCode)?true:false;
         string strARId;
        //addedbysaiv
        string accId;
        accId = objQLI.SBQQ__Quote__r.SBQQ__Account__c;
        string ProductNameCheck=objQLI.SBQQ__Product__r.Name;
        if(strProductId == null){
            strProductId = objQLI.SBQQ__Product__c;
        }
        //end
        if(objQLI.Attribute_Relationship__c == null){
            Attribute_Relationship__c objAR = new Attribute_Relationship__c();
            insert objAR;
            
            strARId = objAR.Id;
            objQLI.Attribute_Relationship__c = objAR.Id;
            update objQLI; 
            
            System.debug(strARId);
        }else{
            strARId = objQLI.Attribute_Relationship__c;
            System.debug(strARId);
        }        
        
        Map<Id, Attribute_Lines__c> mapPAWithAttributeLine = new Map<Id, Attribute_Lines__c>();
        
        if(strARId != null){        
            String strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c') + ', Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__c WHERE Attribute_Junction__c =: strARId Order By Product_Attribute__r.Attribute_Order__c ASC';
            system.debug('strSOQL======'+strSOQL);
            List<Attribute_Lines__c> returnQCA = database.query(strSOQL);
            
            for(Attribute_Lines__c al: returnQCA){
                mapPAWithAttributeLine.Put(al.Product_Attribute__c, al);
            }
        }
        // Fetch Existing Attribute_Lines__c -- END
        
        String strSOQLPA = 'SELECT ' + queryAllFields('ProductAttribute__c') + ', AttributeConfiguration__r.Name,Product__r.Name FROM ProductAttribute__c WHERE Product__c =: strProductId Order By Attribute_Order__c ASC';
        system.debug('strSOQLPA======'+strSOQLPA);
        List<ProductAttribute__c> lstPA = database.query(strSOQLPA);
        Attribute_Lines__c objAL;
        
        String[] arrpicklistvalues = new String[]{};
            wrapperAL objwrapperAL;
        List<Account> accLst = new List<Account>();
        if(accId != Null){
            accLst = [select id, name, BillingStreet, BillingCity, BillingState,Phone,Website,
                      BillingCountry, BillingPostalCode from account where Id=: accId];
        }
        system.debug('##############'+mapPAWithAttributeLine);
        System.debug('lstPA'+lstPA);
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
            if(objAL.Attribute_Name__c == 'Service Account Name' || objAL.Attribute_Name__c == 'Xref Service Account Name'){
                if(objAL.String_Value__c == Null){
                    objAL.String_Value__c = (objAL.String_Value__c == Null && accLst!=Null && !accLst.isEmpty() ? accLst[0].name : Null);    
                } 
            }
            system.debug('@@@@@@@@@@@@'+objAL);
            if(objAL.Attribute_Name__c == 'Service Country' && objAL.String_Value__c == Null){
                objAL.String_Value__c = (objAL.String_Value__c == Null && accLst!=Null && !accLst.isEmpty() ? accLst[0].BillingCountry : Null);
            }
            if(objAL.Attribute_Name__c == 'Service State' && objAL.Picklist_Value__c == Null){
                objAL.Picklist_Value__c = (objAL.Picklist_Value__c == Null && accLst!=Null && !accLst.isEmpty() ? accLst[0].BillingState : Null);
            }
            if(objAL.Attribute_Name__c == 'Service City' && objAL.String_Value__c == Null){
                objAL.String_Value__c = (objAL.String_Value__c == Null && accLst!=Null && !accLst.isEmpty() ? accLst[0].BillingCity : Null);
            }
            if(objAL.Attribute_Name__c == 'Service Zip' && objAL.String_Value__c == Null){
                objAL.String_Value__c = (objAL.String_Value__c == Null && accLst!=Null && !accLst.isEmpty() ? accLst[0].BillingPostalCode : Null);
            }
            if(objAL.Attribute_Name__c == 'Service Street Address' && objAL.String_Value__c == Null){
                objAL.String_Value__c = (objAL.String_Value__c == Null && accLst!=Null && !accLst.isEmpty() ? accLst[0].BillingStreet : Null);
            }//Phone,Website
            if(objAL.Attribute_Name__c == 'Ring to Number' && objAL.String_Value__c == Null){
                objAL.String_Value__c = (objAL.String_Value__c == Null && accLst!=Null && !accLst.isEmpty() ? accLst[0].Phone : Null);
                
                //removing the special characters from phone number
                objAL.String_Value__c = (objAL.String_Value__c!=Null ? objAL.String_Value__c.replaceAll('[^a-zA-Z0-9\\s+]', '') : Null);
                objAL.String_Value__c = (objAL.String_Value__c!=Null ? objAL.String_Value__c.replaceAll( '\\s+', '') : Null);
                system.debug('enter4'+objAL.String_Value__c);             
            }
            system.debug('enter11'+ProductNameCheck);
            if((objAL.Attribute_Name__c == 'URL' || objAL.Attribute_Name__c == 'Domain Name' || objAL.Attribute_Name__c == 'Location') && objAL.String_Value__c == Null){
                objAL.String_Value__c = (objAL.String_Value__c == Null && accLst!=Null && !accLst.isEmpty() ? accLst[0].Website : Null);
                if(ProductNameCheck == 'Ngage Live Chat - Professional Profile'){
                    objAL.String_Value__c = 'www.lawyers.com';
                }
                if(ProductNameCheck == 'Spanish Chat'){
                    objAL.String_Value__c = null;
                }
            }
            if((objAL.Attribute_Name__c == 'Call Tracking' || objAL.Attribute_Name__c == 'Primary Website' || objAL.Attribute_Name__c == 'Direct Website Link') && objAL.Picklist_Value__c == Null){
                objAL.Picklist_Value__c = (objAL.Picklist_Value__c == Null?'Y':objAL.Picklist_Value__c);
            }
            if(objAL.Attribute_Name__c == 'Phone Number Type' && objAL.Picklist_Value__c == Null){
                objAL.Picklist_Value__c = (objAL.Picklist_Value__c == Null?'Local':objAL.Picklist_Value__c);
            }
            
            objwrapperAL = new wrapperAL();
            objwrapperAL.objAL = objAL;
            objwrapperAL.isCTN = isCTN;
            if(pa.Attribute_Picklist_Values__c != null){
                for(String str: pa.Attribute_Picklist_Values__c.split(',')){
                    arrpicklistvalues.add(str.trim());
                }
                objwrapperAL.picklistValues = arrpicklistvalues;
            }
            
            lstwrapperALReturn.add(objwrapperAL);
        }
        
        //return returnQCA;
        //system.debug('===retrieveProductAttributes===');
        //returnUsageStateandCounty(objQLI.SBQQ__Quote__c);
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
Method Name: fetchQLIProductWithAttributeCount
Description: This method is used to Fetch list of SBQQ__QuoteLine__c
Parameter  : String strQLIId - Quote record Id
*/
    @AuraEnabled
    public static Map<Id, Integer> fetchQLIProductWithAttributeCount(String strQuoteId){
        system.debug('==fetchQLIProductWithAttributeCount==');
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
        returnUsageStateandCounty(strQuoteId);
        return returnProductWithAttCount;
    }
    
    /*
Method Name: fetchSuggestionsApex
Description: This method is used to Fetch list of suggested values from GEO_Location__c
Parameter  : String input
*/
    @AuraEnabled
    public static List<String> fetchSuggestionsApex(String input, String strFieldName, String strCountry, String strServiceCountry, String strXrefCountry, String strServiceState, String strState, String strXrefState, String strProductId,String countyName){
        List<String> lstSuggestionsReturn = new List<String>();
        Set<String> sSuggestions = new Set<String>();
        system.debug('############'+strFieldName);
        Product2 prd;
        if(strProductId != Null){
            prd = [select id, ProductCode from Product2 where Id=:strProductId];
            system.debug('==prd=='+prd);
        }
        
        if(strFieldName == 'Country'){
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, CountryName__c FROM GEO_Location__c WHERE CountryName__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforCountry(inputTemp)){
                if(gl.CountryName__c != null){
                    sSuggestions.add(gl.CountryName__c);
                }
            }
        }else if(strFieldName == 'Service Country'){
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, CountryName__c FROM GEO_Location__c WHERE CountryName__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforCountry(inputTemp)){
                if(gl.CountryName__c != null){
                    sSuggestions.add(gl.CountryName__c);
                }
            }
        }else if(strFieldName == 'Xref Country'){
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, CountryName__c FROM GEO_Location__c WHERE CountryName__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforCountry(inputTemp)){
                if(gl.CountryName__c != null){
                    sSuggestions.add(gl.CountryName__c);
                }
            }
        }else if(strFieldName == 'State'){
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, State_Abbrevation__c FROM GEO_Location__c WHERE CountryName__c =: strCountry AND State_Abbrevation__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforState(inputTemp, strCountry)){
                if(gl.State_Abbrevation__c != null){
                    sSuggestions.add(gl.State_Abbrevation__c);
                }
            }
        }else if(strFieldName == 'Service State'){
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, State_Abbrevation__c FROM GEO_Location__c WHERE CountryName__c =: strServiceCountry AND State_Abbrevation__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforState(inputTemp, strServiceCountry)){
                if(gl.State_Abbrevation__c != null){
                    sSuggestions.add(gl.State_Abbrevation__c);
                }
            }
        }else if(strFieldName == 'Xref State'){
            Id MHGeoRecTypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, State_Abbrevation__c FROM GEO_Location__c WHERE CountryName__c =: strXrefCountry AND State_Abbrevation__c LIKE :inputTemp AND RecordTypeId =:MHGeoRecTypeId LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforXrefState(inputTemp, strXrefCountry, MHGeoRecTypeId)){
                if(gl.State_Abbrevation__c != null){
                    sSuggestions.add(gl.State_Abbrevation__c);
                }
            }
        }else if(strFieldName == 'City'){
            Id MHGeoRecTypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
            string inputTemp = input + '%';
            system.debug('############'+strState );
            if(strCountry == null){
                strCountry = 'USA';
            }
            //List<GEO_Location__c> lstGL= [SELECT Id, City_Name__c FROM GEO_Location__c WHERE CountryName__c =: strCountry AND State_Abbrevation__c =: strState AND City_Name__c LIKE :inputTemp AND RecordTypeId =:MHGeoRecTypeId LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforXrefCnCity(inputTemp, strCountry, strState,countyName,MHGeoRecTypeId)){
                if(gl.City_Name__c != null){
                    sSuggestions.add(gl.City_Name__c);
                }
            }
        }else if(strFieldName == 'Service City'){
            string inputTemp = input + '%';
            system.debug('############'+strState );
            //List<GEO_Location__c> lstGL= [SELECT Id, City_Name__c FROM GEO_Location__c WHERE CountryName__c =: strServiceCountry AND State_Abbrevation__c =: strServiceState AND City_Name__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforSerCity(inputTemp, strServiceCountry, strServiceState)){
                if(gl.City_Name__c != null){
                    sSuggestions.add(gl.City_Name__c);
                }
            }
        }else if(strFieldName == 'County'){
            Id MHGeoRecTypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, County_Name__c FROM GEO_Location__c WHERE CountryName__c =: strServiceCountry AND State_Abbrevation__c =: strState AND County_Name__c LIKE :inputTemp AND RecordTypeId =:MHGeoRecTypeId LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforXrefCoNCounty(inputTemp,strServiceCountry,strState,MHGeoRecTypeId)){
                if(gl.County_Name__c != null){
                    sSuggestions.add(gl.County_Name__c);
                }
            }
        }else if(strFieldName == 'Service County'){
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, County_Name__c FROM GEO_Location__c WHERE State_Abbrevation__c =: strServiceState AND County_Name__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforSerCounty(inputTemp,strServiceState)){
                if(gl.County_Name__c != null){
                    sSuggestions.add(gl.County_Name__c);
                }
            }
        }else if(strFieldName == 'Service County'){
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, County_Name__c FROM GEO_Location__c WHERE County_Name__c LIKE :inputTemp LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforSerCountyUsage(inputTemp)){
                if(gl.County_Name__c != null){
                    sSuggestions.add(gl.County_Name__c);
                }
            }
        }else if(strFieldName == 'Xref County'){
            Id MHGeoRecTypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, County_Name__c FROM GEO_Location__c WHERE CountryName__c =: strXrefCountry AND State_Abbrevation__c =: strXrefState AND County_Name__c LIKE :inputTemp AND RecordTypeId =:MHGeoRecTypeId LIMIT 5];
            for(GEO_Location__c gl:  quoteLinesControllerUtility.fetchSuggesforXrefCoNCounty(inputTemp,strXrefCountry,strXrefState,MHGeoRecTypeId)){
                if(gl.County_Name__c != null){
                    sSuggestions.add(gl.County_Name__c);
                }
            }
        }else if(strFieldName == 'Xref City'){ //added by saiv 12/7/2020
            Id MHGeoRecTypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('M-H GEO Locations').getRecordTypeId();
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL= [SELECT Id, City_Name__c FROM GEO_Location__c WHERE CountryName__c =: strXrefCountry AND State_Abbrevation__c =: strXrefState AND City_Name__c LIKE :inputTemp AND RecordTypeId =:MHGeoRecTypeId LIMIT 5];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforXrefCnCity(inputTemp, strXrefCountry, strXrefState,countyName,MHGeoRecTypeId)){
                if(gl.City_Name__c != null){
                    sSuggestions.add(gl.City_Name__c);
                }
            }
        }else if(strFieldName == 'Practice Area'){
            string inputTemp = input + '%';
            //List<Usage_State_and_County__c> lstUSC = [SELECT Id, Practice_Area__c, Practice_Area_Integration_Id__c FROM Usage_State_and_County__c WHERE Practice_Area__c LIKE :inputTemp AND Practice_Area__c != null LIMIT 10];
            for(Usage_State_and_County__c usc: quoteLinesControllerUtility.fetchSuggesforPA(inputTemp)){
                if(usc.Practice_Area__c != null){
                    sSuggestions.add(usc.Practice_Area__c);
                }
            }
        }else if(strFieldName == 'AOP'){
            Id AOPListRecTypeId = Schema.SObjectType.GEO_Location__c.getRecordTypeInfosByName().get('AOP List').getRecordTypeId();
            string inputTemp = input + '%';
            //List<GEO_Location__c> lstGL = [SELECT Id, AOP_Name__c FROM GEO_Location__c WHERE AOP_Name__c LIKE :inputTemp AND AOP_Name__c != null AND RecordTypeId =: AOPListRecTypeId LIMIT 10];
            for(GEO_Location__c gl: quoteLinesControllerUtility.fetchSuggesforAOP(inputTemp,AOPListRecTypeId,prd)){
                if(gl.AOP_Name__c != null){
                    sSuggestions.add(gl.AOP_Name__c);
                }
            }
        }
        lstSuggestionsReturn.addAll(sSuggestions);
        return lstSuggestionsReturn;
    }
    
    
    /*
Method Name: getServiceStateWithCounties
Description: This method is used to Fetch list of Service States
Parameter  : None
*/
    @AuraEnabled
    public static Map<String,List<String>> getServiceStateWithCounties(){
        Map<String,List<String>> mapResults = new Map<String,List<String>>();
        List<Usage_State_and_County__c> lstUSC= [SELECT Id, State_Abbreviation__c, County_Name__c FROM Usage_State_and_County__c ORDER BY State_Abbreviation__c ASC];
        List<String> lstCounties;
        for(Usage_State_and_County__c usc: lstUSC){
            if(usc.State_Abbreviation__c != null){
                if(mapResults.containsKey(usc.State_Abbreviation__c) == false){
                    lstCounties = new List<String>();
                    lstCounties.add(usc.County_Name__c);
                    mapResults.put(usc.State_Abbreviation__c, lstCounties);
                }else{
                    mapResults.get(usc.State_Abbreviation__c).add(usc.County_Name__c);
                }
            }
        }
        
        return mapResults;
    }
    
    /*Method added by saiV */
    @AuraEnabled
    public static List<wrapperStates> getServiceStateWCoun(String strQLIId){
        SBQQ__QuoteLine__c objQLI = [SELECT Id, Attribute_Relationship__c FROM SBQQ__QuoteLine__c WHERE Id =: strQLIId];
        string strARId;
        strARId = objQLI.Attribute_Relationship__c;
        set<String> sExistingStates = new set<String>();
        string[] arrStates = new string[]{};
            set<String> sExistingCounties = new set<String>();
        string[] arrCounties = new string[]{};
            if(strARId != null){        
                String strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c') + ' FROM Attribute_Lines__c WHERE Attribute_Junction__c =: strARId Order By Attribute_Order__c ASC';
                List<Attribute_Lines__c> returnQCA = database.query(strSOQL);
                for(Attribute_Lines__c al: returnQCA){
                    if(al.Attribute_Name__c == 'Service State' && al.Multi_Select_Value__c != null){
                        arrStates = al.Multi_Select_Value__c.split(';');
                    }
                    if(al.Attribute_Name__c == 'Service State' && al.Picklist_Value__c != null){
                        sExistingStates.add(al.Picklist_Value__c);
                    }
                    if(al.Attribute_Name__c == 'Service County' && al.Multi_Select_Value__c != null){
                        arrCounties = al.Multi_Select_Value__c.split(';');
                    }
                }
            }
        for(String str: arrStates){
            sExistingStates.add(str);
        }
        for(String str: arrCounties){
            sExistingCounties.add(str);
        }
        Map<String,List<String>> mapAttrResults = new Map<String,List<String>>();
        List<Usage_State_and_County__c> lstUSC = [SELECT Id, State_Abbreviation__c, County_Name__c FROM Usage_State_and_County__c ORDER BY State_Abbreviation__c ASC];
        List<String> lstCounties;
        for(Usage_State_and_County__c usc: lstUSC){
            if(usc.State_Abbreviation__c != null){
                if(mapAttrResults.containsKey(usc.State_Abbreviation__c) == false){
                    lstCounties = new List<String>();
                    lstCounties.add(usc.County_Name__c);
                    mapAttrResults.put(usc.State_Abbreviation__c, lstCounties);
                }else{
                    mapAttrResults.get(usc.State_Abbreviation__c).add(usc.County_Name__c);
                }
            }
        }
        
        List<wrapperStates> wrapperStateResults = new List<wrapperStates>();
        wrapperStates objWS;
        
        List<wrapperCounty> lstWCounty = new List<wrapperCounty>();
        wrapperCounty objWC;
        integer intSel;
        for(String state: mapAttrResults.keyset()){
            intSel = 0;
            objWS = new wrapperStates();
            objWS.strState = state;
            objWS.countyCount = mapAttrResults.get(state).size();
            lstWCounty = new List<wrapperCounty>();
            for(String county: mapAttrResults.get(state)){
                
                objWC = new wrapperCounty();
                objWC.strCounty = county;
                if(sExistingCounties.contains(state + '---' + county)){
                    objWC.blnCountySelected = true;
                    objWS.blnStateSelected = true;
                    intSel++;
                }
                lstWCounty.add(objWC);
            }
            objWS.selectedCountyCount = intSel;
            objWS.countyList = lstWCounty;
            wrapperStateResults.add(objWS);
            
        }
        return wrapperStateResults;
        
    }
    /*
    Method Name: getServiceStateWithCountiesNew
    Description: This method is used to Fetch list of Service States with county
    Parameter  : None
    */
    @AuraEnabled
    public static List<wrapperStates> getServiceStateWithCountiesNew(String strQLIId){
        system.debug('==strQLIId=='+strQLIId);
        //SBQQ__QuoteLine__c objQLI = [SELECT Id, Attribute_Relationship__c FROM SBQQ__QuoteLine__c WHERE Id =: strQLIId];
        system.debug('==qLineMap=='+qLineMap);
        SBQQ__QuoteLine__c objQLI = qLineMap.get(strQLIId);
        system.debug('==objQLI=='+objQLI);
        string strARId;
        if(objQLI!=Null){
            strARId = objQLI.Attribute_Relationship__c;    
        }
        set<String> sExistingStates = new set<String>();
        string[] arrStates = new string[]{};
            set<String> sExistingCounties = new set<String>();
        string[] arrCounties = new string[]{};
            if(strARId != null && mapARIdWithAttributeLines != null && mapARIdWithAttributeLines.containsKey(strARId)){    
                //String strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c') + ' FROM Attribute_Lines__c WHERE Attribute_Junction__c =: strARId Order By Attribute_Order__c ASC';
                //List<Attribute_Lines__c> returnQCA = database.query(strSOQL);
                List<Attribute_Lines__c> returnQCA = mapARIdWithAttributeLines.get(strARId);
                for(Attribute_Lines__c al: returnQCA){
                    if(al.Attribute_Name__c == 'Service State' && al.Multi_Select_Value__c != null){
                        arrStates = al.Multi_Select_Value__c.split(';');
                    }
                    if(al.Attribute_Name__c == 'Service State' && al.Picklist_Value__c != null){
                        sExistingStates.add(al.Picklist_Value__c);
                    }
                    if(al.Attribute_Name__c == 'Service County' && al.Multi_Select_Value__c != null){
                        arrCounties = al.Multi_Select_Value__c.split(';');
                    }
                }
            }
        for(String str: arrStates){
            sExistingStates.add(str);
        }
        for(String str: arrCounties){
            sExistingCounties.add(str);
        }
        
        /*
Map<String,List<String>> mapResults = new Map<String,List<String>>();
List<Usage_State_and_County__c> lstUSC= [SELECT Id, State_Abbreviation__c, County_Name__c FROM Usage_State_and_County__c WHERE State_Abbreviation__c != null 
AND County_Name__c != null ORDER BY State_Abbreviation__c ASC];
List<String> lstCounties;
for(Usage_State_and_County__c usc: lstUSC){
if(usc.State_Abbreviation__c != null){
if(mapResults.containsKey(usc.State_Abbreviation__c) == false){
lstCounties = new List<String>();
lstCounties.add(usc.County_Name__c);
mapResults.put(usc.State_Abbreviation__c, lstCounties);
}else{
mapResults.get(usc.State_Abbreviation__c).add(usc.County_Name__c);
}
}
}*/
        
        List<wrapperStates> wrapperStateResults = new List<wrapperStates>();
        wrapperStates objWS;
        
        List<wrapperCounty> lstWCounty = new List<wrapperCounty>();
        wrapperCounty objWC;
        integer intSel;
        for(String state: mapResults.keyset()){
            intSel = 0;
            objWS = new wrapperStates();
            objWS.strState = state;
            objWS.countyCount = mapResults.get(state).size();
            lstWCounty = new List<wrapperCounty>();
            for(String county: mapResults.get(state)){
                
                objWC = new wrapperCounty();
                objWC.strCounty = county;
                if(sExistingCounties.contains(state + '---' + county)){
                    objWC.blnCountySelected = true;
                    objWS.blnStateSelected = true;
                    intSel++;
                }
                lstWCounty.add(objWC);
            }
            objWS.selectedCountyCount = intSel;
            objWS.countyList = lstWCounty;
            wrapperStateResults.add(objWS);
            
        }
        return wrapperStateResults;
        
    }
    
    /*
    Method Name: getServiceStateWithCountiesNew
    Description: This method is used to Fetch list of Service States with county
    Parameter  : None
    */
    @AuraEnabled
    public static List<wrapperStates> getServiceStateWithCountiesLatest(String strQLIId){
        system.debug('==strQLIId=='+strQLIId);
        //SBQQ__QuoteLine__c objQLI = [SELECT Id, Attribute_Relationship__c FROM SBQQ__QuoteLine__c WHERE Id =: strQLIId];
        system.debug('==qLineMap=='+qLineMap);
        SBQQ__QuoteLine__c objQLI = qLineMap.get(strQLIId);
        system.debug('==objQLI=='+objQLI);
        string strARId;
        if(objQLI!=Null){
            strARId = objQLI.Attribute_Relationship__c;    
        }
        set<String> sExistingStates = new set<String>();
        string[] arrStates = new string[]{};
        set<String> sExistingCounties = new set<String>();
        string[] arrCounties = new string[]{};
            if(strARId != null){        
                String strSOQL = 'SELECT ' + queryAllFields('Attribute_Lines__c') + ', Product_Attribute__r.Attribute_Order__c FROM Attribute_Lines__c WHERE Attribute_Junction__c =: strARId Order By Product_Attribute__r.Attribute_Order__c ASC';
                List<Attribute_Lines__c> returnQCA = database.query(strSOQL);
                for(Attribute_Lines__c al: returnQCA){
                    if(al.Attribute_Name__c == 'Service State' && al.Multi_Select_Value__c != null){
                        arrStates = al.Multi_Select_Value__c.split(';');
                    }
                    if(al.Attribute_Name__c == 'Service State' && al.Picklist_Value__c != null){
                        sExistingStates.add(al.Picklist_Value__c);
                    }
                    if(al.Attribute_Name__c == 'Service County' && al.Multi_Select_Value__c != null){
                        arrCounties = al.Multi_Select_Value__c.split(';');
                    }
                }
            }
        for(String str: arrStates){
            sExistingStates.add(str);
        }
        for(String str: arrCounties){
            sExistingCounties.add(str);
        }
        
        /*
        Map<String,List<String>> mapResults = new Map<String,List<String>>();
        List<Usage_State_and_County__c> lstUSC= [SELECT Id, State_Abbreviation__c, County_Name__c FROM Usage_State_and_County__c WHERE State_Abbreviation__c != null 
        AND County_Name__c != null ORDER BY State_Abbreviation__c ASC];
        List<String> lstCounties;
        for(Usage_State_and_County__c usc: lstUSC){
        if(usc.State_Abbreviation__c != null){
        if(mapResults.containsKey(usc.State_Abbreviation__c) == false){
        lstCounties = new List<String>();
        lstCounties.add(usc.County_Name__c);
        mapResults.put(usc.State_Abbreviation__c, lstCounties);
        }else{
        mapResults.get(usc.State_Abbreviation__c).add(usc.County_Name__c);
        }
        }
        }*/
                
                List<wrapperStates> wrapperStateResults = new List<wrapperStates>();
                wrapperStates objWS;
                
                List<wrapperCounty> lstWCounty = new List<wrapperCounty>();
                wrapperCounty objWC;
                integer intSel;
                for(String state: mapResults.keyset()){
                    intSel = 0;
                    objWS = new wrapperStates();
                    objWS.strState = state;
                    objWS.countyCount = mapResults.get(state).size();
                    lstWCounty = new List<wrapperCounty>();
                    for(String county: mapResults.get(state)){
                        
                        objWC = new wrapperCounty();
                        objWC.strCounty = county;
                        if(sExistingCounties.contains(state + '---' + county)){
                            objWC.blnCountySelected = true;
                            objWS.blnStateSelected = true;
                            intSel++;
                        }
                        lstWCounty.add(objWC);
                    }
                    objWS.selectedCountyCount = intSel;
                    objWS.countyList = lstWCounty;
                    wrapperStateResults.add(objWS);
            
        }
        return wrapperStateResults;
    }
    
    /*
    Method Name: fetchServiceCountiesApex
    Description: This method is used to Fetch list of Service Counties
    Parameter  : String input
    */
    @AuraEnabled
    public static List<String> fetchServiceCountiesApex(List<String> lstStates){
        List<String> lstCountiesReturn = new List<String>();
        Set<String> sCountiesReturn = new Set<String>();
        List<Usage_State_and_County__c> lstUSC = [SELECT Id, State_Abbreviation__c, County_Name__c FROM Usage_State_and_County__c WHERE State_Abbreviation__c IN :lstStates AND County_Name__c != null ORDER BY State_Abbreviation__c ASC];
        for(Usage_State_and_County__c usc: lstUSC){
            if(usc.County_Name__c != null){
                sCountiesReturn.add(usc.State_Abbreviation__c + '---' + usc.County_Name__c);
            }
        }
        lstCountiesReturn.addAll(sCountiesReturn);
        return lstCountiesReturn;
    }
    
    public class wrapperQLI{
        @AuraEnabled
        public SBQQ__QuoteLine__c objQLI;
        @AuraEnabled
        public boolean isShowViewAttribute;
        @AuraEnabled
        public boolean isShowViewPdf; //change
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
        public Boolean isCTN;
        @AuraEnabled
        public String productCode;//seo-geo
        @AuraEnabled
        public List<string> picklistValues;
        //seogeo
        @AuraEnabled
        public id aopGeoId;
        @AuraEnabled
        public string aopValue;
        @AuraEnabled
        public string stateValue;
        @AuraEnabled
        public string cityValue;//end
    }
    
    public class wrapperStates{
        @AuraEnabled
        public string strState;
        @AuraEnabled
        public boolean blnAllCountiesSelected;
        @AuraEnabled
        public boolean blnStateSelected;
        @AuraEnabled
        public Integer countyCount;
        @AuraEnabled
        public Integer selectedCountyCount;
        @AuraEnabled
        public List<wrapperCounty> countyList;
    }
    
    public class wrapperCounty{
        @AuraEnabled
        public string strCounty;
        @AuraEnabled
        public boolean blnCountySelected;
    }
    @AuraEnabled
    public static string fetchQuoteStatus(String strQliId){
        
        List<SBQQ__QuoteLine__c> qlLst = [select id, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Status__c from SBQQ__QuoteLine__c where Id =:strQliId]; 
        system.debug('==qlLst=='+qlLst);
        if(qlLst != null && !qlLst.isEmpty()){
            return qlLst[0].SBQQ__Quote__r.SBQQ__Status__c;
        }
        return null;
    }
    
    /*
    Method Name: fetchOppAttrIds
    Description: This method is used to Fetch oppId and attrId
    Parameter  : String strQLIId - Quote Line record Id
    */
    @AuraEnabled
    public static String fetchOppAttrIds(String strQliId){
        system.debug('==fetchOppAttrIds==');
        String str = '';
        SBQQ__QuoteLine__c lstQLI = [SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Account__c,Attribute_Relationship__c FROM SBQQ__QuoteLine__c WHERE Id =: strQliId];
        if(lstQLI.Attribute_Relationship__c != null){
            List<Attribute_Lines__c> lstAttrLine = [Select Id from Attribute_Lines__c where Attribute_Junction__c = :lstQLI.Attribute_Relationship__c];
            system.debug(lstAttrLine);
            if(lstAttrLine != null){
                List<Case> c = [Select id from case where accountId = :lstQLI.SBQQ__Quote__r.SBQQ__Account__c and Origin ='SocialStarter' order by CreatedDate DESC limit 1];
                if(c.size()>0){
                    str = lstQLI.Id+','+c[0].Id;
                }
            }            
        }else{
            str = lstQLI.Id;  
        }
        return str;
    }
}