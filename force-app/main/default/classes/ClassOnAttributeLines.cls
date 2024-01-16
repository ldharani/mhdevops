/* 
* Class Name: ClassOnAttributeLines    
* Test Class: 
* Description: 
* Developed By:  
*  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6956    SaiV          06/21/22     Bryan Clark      T08    Pull "Creative Discovery Link" from Orders into Projects 
MHBS-8118    Shashikanth   03/03/22     John Mattheson   T01    Inventory Tool - Optimisation
MHBS-8256    Bharath       09/03/23     Namachivayam     T02    Geo value ID's are not populating correctly
MHBS-8923    Chetna        09/03/23                      T03    Fix for value ID's being null, recursive run and logic update
MHBS-8916    Chetna        09/03/23                      T04    Fix for Quote Lines are not created on choosing 60+ products from Inventory Search Tool
MHBS-9083    SaiV          06/06/2023                    T09    New Attribute Values field doesn't work for SEO Services
************************************************************************************************************************
 
*/
public class ClassOnAttributeLines {
    public static boolean AfterUpdate = True;
    public static void updateAttrValues(List<Attribute_Lines__c> attrLines){
        Map<ID, Attribute_Relationship__c> attrRelationMap = new Map<ID, Attribute_Relationship__c >(); 
        Set<Id> listIds = new Set<Id>();
        
        for (Attribute_Lines__c childObj : attrLines) {
            listIds.add(childObj.Attribute_Junction__c );
        }
        
        attrRelationMap = new Map<Id, Attribute_Relationship__c>([SELECT id ,Attribute_Values__c ,CreativeDiscLink__c, AttributeValues__c,
                                                                  (SELECT ID, Attr_Name__c,AllValues__c,String_Value__c, Show_in_Docusign__c  FROM Attribute_Lines__r) 
                                                                  FROM Attribute_Relationship__c WHERE ID IN :listIds]);//<T04> New field Attribute_Values__c
        
        List<Attribute_Relationship__c> lstAttrRelation = new List<Attribute_Relationship__c>();
        //String cdlValue = '';
        for(Attribute_Relationship__c acct:attrRelationMap.values())
        {  
            List<String> strType = new List<String>();
            String cdlValue = '';
            Boolean aopGeo = false;
            for(Attribute_Lines__c atrl:acct.Attribute_Lines__r)
            {
                if(atrl.Show_in_Docusign__c == TRUE){
                    strType.add(atrl.AllValues__c);
                }
                if(atrl.Attr_Name__c == 'Creative Discovery Link'){ //T09
                    cdlValue = atrl.String_Value__c;
                }
                if(atrl.Attr_Name__c == 'Aop/Geo'){ //T09
                    aopGeo = true;
                }
            }
            if(aopGeo == false){
                acct.Attribute_Values__c = String.join(strType,';');//<T04> New field Attribute_Values__c
            }else{
                acct.AttributeValues__c = String.join(strType,';');//T09
            }
            
            if(cdlValue != Null){
                acct.CreativeDiscLink__c = cdlValue;
            }
            
        }
        system.debug('==attrRelationMap=='+attrRelationMap);
        update attrRelationMap.values();
        
         //updating the attribute values on quotelines. This is a replacement of the workflow rule.
        /*if(listIds!=null && !listIds.isEmpty()){
            list<SBQQ__QuoteLine__c> listofquoteline = new list<SBQQ__QuoteLine__c>();
            for( SBQQ__QuoteLine__c quoteline: [select Id,Attribute_Relationship__c,Attribute_Relationship__r.AttributeValues__c from SBQQ__QuoteLine__c where Attribute_Relationship__c in:listIds AND CreatedById=:UserInfo.getUserId()]){//<T01>
                quoteline.AttributeValues__c= quoteline.Attribute_Relationship__r.AttributeValues__c;
                listofquoteline.add(quoteline);        
            } 
            update listofquoteline;
        }*/ //<T04> Commented out as this is causing 101 SOQL issue when bulk Line items are updated during Attribute insertion / update. This is instead moved to a formula field(Attribute_Values__c on Quote line) using new Text area field(Attribute_Values__c on Attribute Relationship)
    }
    //public static boolean AfterUpdate = True;
    //@future(callout = true)
    //public static void blankInventoryId(String jsonString, String jsonStringMap){
    public static void blankInventoryId(List<Attribute_Lines__c> lstOpptyCharges, Map<Id, Attribute_Lines__c> oldMapOpptyCharges){
        //List<Attribute_Lines__c> lstOpptyCharges = (List<Attribute_Lines__c>)Json.deserialize(jsonString,List<Attribute_Lines__c>.class);
        //Map<Id, Attribute_Lines__c> oldMapOpptyCharges = (Map<Id, Attribute_Lines__c>)Json.deserialize(jsonStringMap,Map<Id, Attribute_Lines__c>.class);
        system.debug('==lstOpptyCharges=='+lstOpptyCharges);
        system.debug('==oldMapOpptyCharges=='+oldMapOpptyCharges);
        Set<Id> setAttrRelationId = new Set<Id>();
        Set<Id> setOpptyProdIds = new Set<Id>();
        Map<Id,String> mapOppProdNInventoryId = new Map<Id,String>();
        List<SBQQ__QuoteLine__c> lstOppProdsToUpdate = new List<SBQQ__QuoteLine__c>();
        for(Attribute_Lines__c oppRPC : lstOpptyCharges) {
            system.debug('==oppRPC.Attribute_Type__c=='+oppRPC.Attribute_Type__c);
            system.debug('==oldMapOpptyCharges.get(oppRPC.Id).Picklist_Value__c=='+oldMapOpptyCharges.get(oppRPC.Id).Picklist_Value__c);
            system.debug('==oppRPC.Picklist_Value__c=='+oppRPC.Picklist_Value__c);
            if((oppRPC.Attribute_Type__c == 'Picklist' || oppRPC.Attribute_Type__c == 'Text' || oppRPC.Attribute_Type__c == 'String') && ((oppRPC.Picklist_Value__c != oldMapOpptyCharges.get(oppRPC.Id).Picklist_Value__c)||(oppRPC.String_Value__c != oldMapOpptyCharges.get(oppRPC.Id).String_Value__c))) {
                if(oppRPC.Attribute_Name__c == 'City' || oppRPC.Attribute_Name__c == 'County' || oppRPC.Attribute_Name__c == 'Country' || oppRPC.Attribute_Name__c == 'State' || oppRPC.Attribute_Name__c .contains('AOP')) {
                    system.debug('oppRPC.Attribute_Junction__c'+oppRPC.Attribute_Junction__c);
                    setAttrRelationId.add(oppRPC.Attribute_Junction__c);
                    
                }//end of inner if
            }//end of outer if
        }//end of for
        system.debug('@@@@@setAttrRelationId'+setAttrRelationId);
        for(SBQQ__QuoteLine__c oppCharges : [Select id, SBQQ__Quote__c, Attribute_Relationship__c, SBQQ__Product__c,customerNumber__c,
                                             SBQQ__ProductCode__c, SBQQ__ProductName__c, SBQQ__Product__r.IsInventoried__c, 
                                             Inventory_Id__c FROM SBQQ__QuoteLine__c
                                             Where Inventory_Id__c != null and Attribute_Relationship__c IN : setAttrRelationId]) {
                                                 setOpptyProdIds.add(oppCharges.Id);     
                                                 mapOppProdNInventoryId.put(oppCharges.Id, oppCharges.Inventory_Id__c);                                        
                                             }
        if(setOpptyProdIds.size() > 0) {
            User u = [select Id, username from User where Id = :UserInfo.getUserId()];
            System.debug('@@@@@@release inventory to be sent'+setOpptyProdIds);
            CPQ_MDL_Integration_Vim_Efs.releaseInventoryRequest(setOpptyProdIds, u.Username,mapOppProdNInventoryId);
        }
    }
    
    //T02 Starts
    public static void populateAddressStringFields(List<Attribute_Lines__c> attributeList){ //, Map<Id, Attribute_Lines__c> oldMap){
        //Set<Id> attrRelationId = new Set<Id>();
        Map<Id,Map<String,String>> attRelSummaryMap = new Map<Id,Map<String,String>>();//<T03>
        List<Attribute_Lines__c> attrLstToUpdate = new List<Attribute_Lines__c>();
        String countryVal;
        String stateVal;
        String cityVal;
        String countyVal;
        String sercountryVal;
        String serstateVal;
        String sercityVal;
        system.debug('==attributeList=='+attributeList);
        for(Attribute_Lines__c atrl: attributeList){
            //attrRelationId.add(atrl.Attribute_Junction__c);
            if(atrl.Attribute_Name__c.contains('Country') && atrl.Attribute_Name__c != 'Service Country'){
                if (!attRelSummaryMap.containsKey(atrl.Attribute_Junction__c)) {//<T03> Starts
                    attRelSummaryMap.put(atrl.Attribute_Junction__c, new Map<String,String>());
                }
                attRelSummaryMap.get(atrl.Attribute_Junction__c).put('Country',atrl.String_Value__c);
            }
            if(atrl.Attribute_Name__c.contains('State') && atrl.Attribute_Name__c != 'Service State'){
                if (!attRelSummaryMap.containsKey(atrl.Attribute_Junction__c)) {
                    attRelSummaryMap.put(atrl.Attribute_Junction__c, new Map<String,String>());
                }
                attRelSummaryMap.get(atrl.Attribute_Junction__c).put('State',atrl.Picklist_Value__c);
            }
            if(atrl.Attribute_Name__c.contains('County')){
                if (!attRelSummaryMap.containsKey(atrl.Attribute_Junction__c)) {
                    attRelSummaryMap.put(atrl.Attribute_Junction__c, new Map<String,String>());
                }
                attRelSummaryMap.get(atrl.Attribute_Junction__c).put('County',atrl.Picklist_Value__c);
            } 
            if(atrl.Attribute_Name__c.contains('City') && atrl.Attribute_Name__c != 'Service City'){
                if (!attRelSummaryMap.containsKey(atrl.Attribute_Junction__c)) {
                    attRelSummaryMap.put(atrl.Attribute_Junction__c, new Map<String,String>());
                }
                attRelSummaryMap.get(atrl.Attribute_Junction__c).put('City',atrl.Picklist_Value__c);
            }
            //added by saiv 10/19/2021
            if(atrl.Attribute_Name__c == 'Service Country'){
                if (!attRelSummaryMap.containsKey(atrl.Attribute_Junction__c)) {
                    attRelSummaryMap.put(atrl.Attribute_Junction__c, new Map<String,String>());
                }
                attRelSummaryMap.get(atrl.Attribute_Junction__c).put('Service Country',atrl.String_Value__c);
            }  
            if(atrl.Attribute_Name__c == 'Service State' ){
                if (!attRelSummaryMap.containsKey(atrl.Attribute_Junction__c)) {
                    attRelSummaryMap.put(atrl.Attribute_Junction__c, new Map<String,String>());
                }
                attRelSummaryMap.get(atrl.Attribute_Junction__c).put('Service State',atrl.Picklist_Value__c);
            }
            if(atrl.Attribute_Name__c == 'Service City'){
                if (!attRelSummaryMap.containsKey(atrl.Attribute_Junction__c)) {
                    attRelSummaryMap.put(atrl.Attribute_Junction__c, new Map<String,String>());
                }
                attRelSummaryMap.get(atrl.Attribute_Junction__c).put('Service City',atrl.String_Value__c);
            }
        }
        
        system.debug('==attRelSummaryMap=='+attRelSummaryMap);
        Map<String,String> attributeStringMap = new Map<String,String>();
        for(Attribute_Lines__c atrl: attributeList) {
            if(attRelSummaryMap.containsKey(atrl.Attribute_Junction__c)) {
                attributeStringMap = attRelSummaryMap.get(atrl.Attribute_Junction__c);
                if(attributeStringMap!=null){
                    if(attributeStringMap.containsKey('Country')
                       && (atrl.Attribute_Name__c == 'State' 
                           || atrl.Attribute_Name__c == 'County' 
                           || atrl.Attribute_Name__c == 'City')){
                               countryVal = attributeStringMap.get('Country');
                               if(attributeStringMap.containsKey('State')){
                                   stateVal = attributeStringMap.get('State');
                                   if(atrl.Attribute_Name__c == 'State'){
                                       atrl.CountryState_String__c = countryVal+';'+stateVal;
                                   }
                                   if(attributeStringMap.containsKey('County') && atrl.Attribute_Name__c == 'County'){
                                       countyVal = attributeStringMap.get('County');
                                       atrl.country_state_County_string__c = countryVal+';'+stateVal+';'+countyVal;
                                   }
                                   if(attributeStringMap.containsKey('City') && atrl.Attribute_Name__c == 'City'){
                                       cityVal = attributeStringMap.get('City');
                                       atrl.Address_String__c = countryVal+';'+stateVal+';'+cityVal;
                                   }
                               }
                           }
                    if(attributeStringMap.containsKey('Service Country')
                       && (atrl.Attribute_Name__c == 'Service State' 
                           || atrl.Attribute_Name__c == 'Service City')){
                               sercountryVal = attributeStringMap.get('Service Country');
                               if(attributeStringMap.containsKey('Service State')){
                                   serstateVal = attributeStringMap.get('Service State');
                                   if(atrl.Attribute_Name__c == 'Service State'){
                                       atrl.CountryState_String__c = sercountryVal+';'+serstateVal;
                                   }
                                   if(attributeStringMap.containsKey('Service City') && atrl.Attribute_Name__c == 'Service City'){
                                       sercityVal = attributeStringMap.get('Service City');
                                       atrl.Address_String__c = sercountryVal+';'+serstateVal+';'+sercityVal;
                                   }
                               }
                           }
                }
            }
            system.debug('==atrl.Address_String__c=='+atrl.Address_String__c+' '+atrl.Id);
            system.debug('==atrl.country_state_County_string__c=='+atrl.country_state_County_string__c+' '+atrl.Id);
            system.debug('==atrl.CountryState_String__c=='+atrl.CountryState_String__c+' '+atrl.Id);
        }//<T03> Ends
        
        
       /* 
       if(!attrRelationId.isEmpty()){
            for(Attribute_Lines__c attrLst : [select id,Attribute_Name__c,Attribute_Junction__c,Value_ID__c,
                                                    String_Value__c,Address_String__c,CountryState_String__c,
                                                    country_state_County_string__c,Picklist_Value__c FROM
                                                    Attribute_Lines__c WHERE Attribute_Junction__c IN :attrRelationId]){
                                                        if((attrLst.Attribute_Name__c == 'Country' || attrLst.Attribute_Name__c ==  'Xref Country') && countryVal == null){ 
                                                            countryVal = attrLst.String_Value__c;

                                                            //}
                                                        }
                                                        if((attrLst.Attribute_Name__c == 'State'  || attrLst.Attribute_Name__c ==  'Xref State') && stateVal == null){ //&& attrLst.Picklist_Value__c != oldMap.get(attrLst.Id).Picklist_Value__c){
                                                            stateVal = attrLst.Picklist_Value__c;


                                                        }
                                                        if((attrLst.Attribute_Name__c == 'County'  || attrLst.Attribute_Name__c ==  'Xref County') && countyVal == null){ //&& attrLst.String_Value__c != oldMap.get(attrLst.Id).String_Value__c){
                                                            countyVal = attrLst.Picklist_Value__c;


                                                        }
                                                        
                                                        
                                                        
                                                        if((attrLst.Attribute_Name__c == 'City'|| attrLst.Attribute_Name__c ==  'Xref City') && cityVal == null){ //&& attrLst.String_Value__c != oldMap.get(attrLst.Id).String_Value__c){
                                                            cityVal = attrLst.Picklist_Value__c;




                                                        }
                                                        if(attrLst.Attribute_Name__c == 'Service Country' && sercountryVal == null){
                                                            sercountryVal = attrLst.String_Value__c;
                                                        }
                                                        if(attrLst.Attribute_Name__c == 'Service State' && serstateVal == null){
                                                            serstateVal = attrLst.Picklist_Value__c;
                                                        }
                                                        if(attrLst.Attribute_Name__c == 'Service City' && sercityVal == null){
                                                            sercityVal = attrLst.String_Value__c;
                                                        }
                                                        
                                                        }
                                                    }
        
        system.debug('==countryVal=='+countryVal);
            system.debug('==stateVal=='+stateVal);
            system.debug('==countyVal=='+countyVal);
            system.debug('==cityVal=='+cityVal);
            system.debug('==sercityVal=='+sercityVal);
        
        for(Attribute_Lines__c atrl: attributeList){
                      
            if(atrl.Attribute_Name__c == 'State' || atrl.Attribute_Name__c == 'Xref State'){
                atrl.CountryState_String__c = countryVal+';'+stateVal;
            }
            if(atrl.Attribute_Name__c == 'County' || atrl.Attribute_Name__c == 'Xref County'){
                atrl.country_state_County_string__c = countryVal+';'+stateVal+';'+countyVal;
            }
            
            if(atrl.Attribute_Name__c == 'City' || atrl.Attribute_Name__c == 'Xref City'){
                atrl.Address_String__c = countryVal+';'+stateVal+';'+cityVal;

            }
            if(atrl.Attribute_Name__c == 'Service State'){
                atrl.CountryState_String__c = sercountryVal+';'+serstateVal;

            }
            if(atrl.Attribute_Name__c == 'Service City'){
                atrl.Address_String__c = sercountryVal+';'+serstateVal+';'+sercityVal;
               
            }
            
            system.debug('==atrl.Address_String__c=='+atrl.Address_String__c);
            system.debug('==atrl.country_state_County_string__c=='+atrl.country_state_County_string__c);
            system.debug('==atrl.CountryState_String__c=='+atrl.CountryState_String__c);
        }*/
    }//T02 ends
    public static void populateValueIdsonAddressFields(List<Attribute_Lines__c> attributeList){
        
        Set<String> countryset                = new Set<String>();
        Set<String> stateset                  = new Set<String>();
        Set<String> cityset                   = new Set<String>();
        Set<String> countyset                 = new Set<String>();
        Set<String> aopSet                    = new Set<String>();
        Map<String,string> countryVscountryId = new Map<String,string>();
        Map<String,string> stateVsstateId     = new Map<String,string>();
        Map<String,string> cityVscityId       = new Map<String,string>();
        Map<String,string> countyVscountyId   = new Map<String,string>();
        Map<String,string> aopVsaopId         = new Map<String,string>();
        List<Attribute_Lines__c> attrLstToUpdateVID = new List<Attribute_Lines__c>();
        
        for(Attribute_Lines__c attribute: attributeList){
          system.debug('======Value_ID__c========='+attribute.Value_ID__c);
          if(attribute.Value_ID__c == null || attribute.Value_ID__c ==''){
            if(attribute.Attribute_Name__c != null){
                if(attribute.Attribute_Name__c.contains('Country')){
                    countryset.add(attribute.String_Value__c);
                }
                if(attribute.Attribute_Name__c.contains('State')){
                    stateset.add(attribute.CountryState_String__c);
                }
                if(attribute.Attribute_Name__c.contains('City')){
                    cityset.add(attribute.Address_String__c);
                }
                if(attribute.Attribute_Name__c.contains('County')){
                    countyset.add(attribute.country_state_County_string__c);
                }
                if(attribute.Attribute_Name__c.contains('AOP')){
                    aopSet.add(attribute.Picklist_Value__c);
                }
             } 
          }
            
            
        }
        
        system.debug('@@@@aopSet'+aopSet);
        system.debug('@@@@stateset'+stateset);
        system.debug('@@@@cityset'+cityset);
        system.debug('@@@@countyset'+countyset);
        
        //querying on existing country data to update value IDs
        if(countryset!= NULL &&!countryset.isEmpty()){
            for(AggregateResult geo: [select CountryName__c countryName,
                                      CountryID__c countryId
                                      From Geo_Location__c
                                      where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c IN:countryset
                                      Group by CountryName__c,CountryID__c]){
                                          countryVscountryId.put(string.valueOf(geo.get('countryName')),string.valueOf(geo.get('countryId')) );                        
                                      } 
        } 
        //querying on existing state data to update value IDs
        if(stateset!= NULL && !stateset.isEmpty()){
            for(Geo_Location__c geo: [select countryStateString__c,
                                      StateID__c
                                      From Geo_Location__c
                                      where RecordType.DeveloperName = 'M_H_GEO_Locations' and countryStateString__c IN:stateset
                                     ]){
                                         stateVsstateId.put(geo.countryStateString__c.toUppercase(),geo.StateID__c );                        
                                     } 
        } 
        //querying on existing county data to update value IDs
        if(countyset!= NULL && !countyset.isEmpty()){
            for(Geo_Location__c geo: [select country_state_County_string__c ,
                                      County_ID__c 
                                      From Geo_Location__c
                                      where RecordType.DeveloperName = 'M_H_GEO_Locations' and country_state_County_string__c IN:countyset
                                     ]){
                                         countyVscountyId.put(geo.country_state_County_string__c.toUpperCase(),geo.County_ID__c);                        
                                     }  
        }
        system.debug('@@@@countyVscountyId'+countyVscountyId); 
        
        //querying on existing City data to update value IDs
        if(cityset!= NULL && !cityset.isEmpty()){
            for(Geo_Location__c geo: [select address_String__c,
                                      City_ID__c
                                      From Geo_Location__c
                                      where RecordType.DeveloperName = 'M_H_GEO_Locations' and address_String__c IN:cityset]){
                                          cityVscityId.put(geo.address_String__c.toUpperCase(),geo.City_ID__c );                        
                                      }
            
        }
        system.debug('@@@@cityVscityId'+cityVscityId);
        
        if(aopSet!= NULL && !aopSet.isEmpty()){
            for(aggregateResult geo : [select AOP_Name__c aop,AOP_ID__c aopId
                                       from Geo_Location__c
                                       where RecordType.DeveloperName = 'AOP_List' and AOP_Name__c IN:aopSet
                                       Group by AOP_Name__c,AOP_ID__c]){
                                           aopVsaopId.put(string.valueOf(geo.get('aop')),string.valueOf(geo.get('aopId')) );                              
                                       }
            
        }
        system.debug('@@@@aopVsaopId'+aopVsaopId);
        
        for(Attribute_Lines__c attribute: [select id,Attribute_Name__c,Attribute_Junction__c,Value_ID__c, Attribute_Junction__r.CreatedFromQB__c,
                                                    String_Value__c,Address_String__c,CountryState_String__c,
                                                    country_state_County_string__c,Picklist_Value__c FROM
                                                    Attribute_Lines__c WHERE Id IN:attributeList]){
            if(attribute.Attribute_Name__c != null && attribute.Value_ID__c == null && attribute.Attribute_Junction__r.CreatedFromQB__c == false){
                if(attribute.Attribute_Name__c.contains('AOP') && attribute.Value_ID__c != aopVsaopId.get(attribute.Picklist_Value__c)){
                    attribute.Value_ID__c = aopVsaopId.get(attribute.Picklist_Value__c);
                    System.debug('@@@@@@@ AOP value '+ attribute.Value_ID__c);
                    System.debug('@@@@@@@ aopVsaopId '+ aopVsaopId);
                    attrLstToUpdateVID.add(attribute);
                } 
                else if(attribute.Attribute_Name__c.contains('Country') && attribute.Value_ID__c != countryVscountryId.get(attribute.String_Value__c)){
                    if(countryVscountryId.containsKey(attribute.String_Value__c)){
                        attribute.Value_ID__c = countryVscountryId.get(attribute.String_Value__c);
                        attrLstToUpdateVID.add(attribute);
                    }
                    
                }
                else if(attribute.Attribute_Name__c.contains('State')){
                    if(attribute.CountryState_String__c != null && attribute.Value_ID__c != stateVsstateId.get(attribute.CountryState_String__c.toUppercase())){
                        if(stateVsstateId.containsKey(attribute.CountryState_String__c.toUppercase())){
                            attribute.Value_ID__c = stateVsstateId.get(attribute.CountryState_String__c.toUppercase());
                            System.debug('@@@@@@@city population'+attribute.Value_ID__c);
                            attrLstToUpdateVID.add(attribute);
                        }
                    }
                }
                else if(attribute.Attribute_Name__c.contains('City')){
                    system.debug('@@@@@@attribute.address_String__c'+attribute.address_String__c);
                    if(attribute.address_String__c != null && attribute.Value_ID__c != cityVscityId.get(attribute.Address_String__c.toUpperCase())){
                        if(cityVscityId.containsKey(attribute.address_String__c.toUpperCase())){
                            attribute.Value_ID__c = cityVscityId.get(attribute.Address_String__c.toUpperCase());
                            System.debug('@@@@@@@city population'+attribute.Value_ID__c);
                            attrLstToUpdateVID.add(attribute);
                        }
                    }
                    
                }
                else if(attribute.Attribute_Name__c.contains('County')){
                    if(attribute.country_state_County_string__c!= null && attribute.Value_ID__c != countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase())){
                        if(countyVscountyId.containsKey(attribute.country_state_County_string__c.toUpperCase())){
                            attribute.Value_ID__c = countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase());
                            System.debug('@@@@@@@'+attribute.Value_ID__c);
                            attrLstToUpdateVID.add(attribute);
                        }
                    }
                    /*else if(countyVscountyId.containsKey(attribute.String_Value__c) && attribute.Value_ID__c != countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase())){
                        attribute.Value_ID__c = countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase());
                        System.debug('@@@@@@@ County'+ attribute.String_Value__c +attribute.country_state_County_string__c.toUpperCase());
                        //attrLstToUpdateVID.add(attribute);
                    }*/
                    //attrLstToUpdateVID.add(attribute);
                }
            }
        }
        if(!attrLstToUpdateVID.isEmpty()){
            MDL_RecursionHandler.firstRun = false;//<T03>
            update attrLstToUpdateVID;
        }
    }
    
    
}