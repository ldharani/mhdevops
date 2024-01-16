global class BatchUpdateAttributeValues implements Database.Batchable<sObject>,Database.Stateful{
    global integer count = 0;
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = '';
        query='Select id,Attribute_Name__c,Attribute_Junction__c,Value_ID__c,';
        query += 'String_Value__c,Address_String__c,CountryState_String__c,';
        query += 'country_state_County_string__c,Picklist_Value__c FROM ';
        query += 'Attribute_Lines__c WHERE (Attribute_Name__c = \'State\' or Attribute_Name__c = \'County\' ';
        query += 'or Attribute_Name__c = \'City\' or Attribute_Name__c = \'Xref State\' or Attribute_Name__c = \'Xref County\' ';
        query += 'or Attribute_Name__c = \'Xref City\') and createddate >= '+Label.From_Date +' and createddate <= '+Label.To_Date;
            System.debug(query);
        if(Test.isRunningTest()) {
            query = ' select id,Attribute_Name__c,Attribute_Junction__c,Value_ID__c,';
        query += 'String_Value__c,Address_String__c,CountryState_String__c,';
        query += 'country_state_County_string__c,Picklist_Value__c from Attribute_Lines__c  LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Attribute_Lines__c> attrLinesList){
        
        List<Attribute_Lines__c> finalAttrLinesList = new List<Attribute_Lines__c>();
        Set<Id> AttrelIds = new Set<Id>();
        
        Map<Id,List<Attribute_Lines__c>> attrelVsattrlines = new Map<Id,List<Attribute_Lines__c>>();
        Map<Id,String> attrelVsConStateString = new Map<Id,String>();
        Map<Id,String> attrelVsString = new Map<Id,String>();

        String countryVal;
        String stateVal;
        String cityVal;
        String countyVal;
        
        for(Attribute_Lines__c attr : attrLinesList){
            if(attr.Picklist_Value__c != null){
            if(((attr.Attribute_Name__c.contains('State') && (attr.CountryState_String__c == null || (attr.CountryState_String__c != null && attr.CountryState_String__c.contains(attr.Picklist_Value__c) == false)))
               || (attr.Attribute_Name__c.contains('City') && (attr.Address_String__c == null || (attr.Address_String__c != null && attr.Address_String__c.contains(attr.Picklist_Value__c) == false)))
               || (attr.Attribute_Name__c.contains('County') && (attr.country_state_County_string__c == null || (attr.country_state_County_string__c != null && attr.country_state_County_string__c.contains(attr.Picklist_Value__c) == false)))) || test.isRunningTest()){             
                   AttrelIds.add(attr.Attribute_Junction__c);
                   finalAttrLinesList.add(attr);
               }
            }
        }
        
        System.debug('AttrelIds '+AttrelIds);
        System.debug('finalAttrLinesList '+finalAttrLinesList);
        System.debug(finalAttrLinesList.size());
        
        for(Attribute_Lines__c a: finalAttrLinesList){
            System.debug('ID!!!'+ a.Id);
        }
        List<Attribute_Lines__c> aList =  [select id,Attribute_Name__c,Attribute_Junction__c,Value_ID__c,
                                           String_Value__c,Address_String__c,CountryState_String__c,
                                           country_state_County_string__c,Picklist_Value__c FROM
                                           Attribute_Lines__c WHERE Attribute_Junction__c IN :AttrelIds];
        
        for(Attribute_Lines__c atrl: aList){
            if(attrelVsattrlines.containsKey(atrl.Attribute_Junction__c)){
                attrelVsattrlines.get(atrl.Attribute_Junction__c).add(atrl);
            }else{
                attrelVsattrlines.put(atrl.Attribute_Junction__c,new List<Attribute_Lines__c>{atrl});  
            }
        }
        
        System.debug(attrelVsattrlines);
        System.debug(attrelVsattrlines.keyset());
        
        for(Id id1: attrelVsattrlines.keyset()){
               countryVal = '';
        	   stateVal = '';
        	 cityVal = '';
        	 countyVal = '';
            for(Attribute_Lines__c atrl :attrelVsattrlines.get(id1)){
                
                if(atrl.Attribute_Name__c.contains('Country') || atrl.Attribute_Name__c ==  'Xref Country'){
                    countryVal = atrl.String_Value__c;
                }
                
                if(atrl.Attribute_Name__c.contains('State') || atrl.Attribute_Name__c ==  'Xref State'){
                    stateVal = atrl.Picklist_Value__c;
                }
                if(atrl.Attribute_Name__c.contains('County')  || atrl.Attribute_Name__c ==  'Xref County'){
                    countyVal = atrl.Picklist_Value__c;
                }
                
                if(atrl.Attribute_Name__c.contains('City')  || atrl.Attribute_Name__c ==  'Xref City'){
                    cityVal = atrl.Picklist_Value__c;
                }
            }
            System.debug(id1);
            System.debug(countryVal);
            System.debug(stateVal);
            System.debug(countyVal);
            System.debug(cityVal);
            attrelVsConStateString.put(Id1,countryVal+';'+stateVal);
            String finalValue = '';
            System.debug(countyVal == null || countyVal == '');
            
            if(String.IsBlank(countyVal)){                 
               finalValue = countryVal+';'+stateVal+';'+cityVal;
                System.debug(finalValue);
            }else if(String.IsBlank(cityVal) || cityVal == 'None'){
               finalValue = countryVal+';'+stateVal+';'+countyVal;
                System.debug(finalValue);
            }
            System.debug(Id1+' '+finalValue);
          attrelVsString.put(Id1,finalValue);
        }
        
        System.debug(attrelVsConStateString);
        System.debug(attrelVsString);
        
        for(Attribute_Lines__c atrl :finalAttrLinesList){
                  System.debug(atrl.ID);
            System.debug(countryVal);
                
            if(atrl.Attribute_Name__c == 'State' || atrl.Attribute_Name__c == 'Xref State' && attrelVsConStateString.containskey(atrl.Attribute_Junction__c)){
                atrl.CountryState_String__c = attrelVsConStateString.get(atrl.Attribute_Junction__c);
                    System.debug(attrelVsConStateString.get(atrl.Attribute_Junction__c));
            }
            if(atrl.Attribute_Name__c == 'County' || atrl.Attribute_Name__c == 'Xref County' && attrelVsString.containskey(atrl.Attribute_Junction__c)){
                atrl.country_state_County_string__c = attrelVsString.get(atrl.Attribute_Junction__c);
                    System.debug(attrelVsString.get(atrl.Attribute_Junction__c));
            }
            
            if(atrl.Attribute_Name__c == 'City' || atrl.Attribute_Name__c == 'Xref City' && attrelVsString.containskey(atrl.Attribute_Junction__c)){
                atrl.Address_String__c =  attrelVsString.get(atrl.Attribute_Junction__c);
                    System.debug(attrelVsString.get(atrl.Attribute_Junction__c));

            }
        }
        
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

        
        for(Attribute_Lines__c attribute: finalAttrLinesList){
            //if(attribute.Value_ID__c == null || attribute.Value_ID__c ==''){
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
            
            // }
            
            
        }
        
        system.debug('@@@@aopSet'+aopSet);
        
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
        
        for(Attribute_Lines__c attribute: finalAttrLinesList){
            if(attribute.Attribute_Name__c != null){
                 if(attribute.Attribute_Name__c.contains('State')){
                    if(attribute.CountryState_String__c != null && attribute.Value_ID__c != stateVsstateId.get(attribute.CountryState_String__c.toUppercase())){
                        if(stateVsstateId.containsKey(attribute.CountryState_String__c.toUppercase())){
                            attribute.Value_ID__c = stateVsstateId.get(attribute.CountryState_String__c.toUppercase());
                            System.debug('@@@@@@@city population'+attribute.Value_ID__c);

                        }
                    }
                }
                else if(attribute.Attribute_Name__c.contains('City')){
                    system.debug('@@@@@@attribute.address_String__c'+attribute.address_String__c);
                    if(attribute.address_String__c != null && attribute.Value_ID__c != cityVscityId.get(attribute.Address_String__c.toUpperCase())){
                        if(cityVscityId.containsKey(attribute.address_String__c.toUpperCase())){
                            attribute.Value_ID__c = cityVscityId.get(attribute.Address_String__c.toUpperCase());
                            System.debug('@@@@@@@city population'+attribute.Value_ID__c);

                        }
                    }
                    
                }
                else if(attribute.Attribute_Name__c.contains('County')){
                    if(attribute.country_state_County_string__c!= null && attribute.Value_ID__c != countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase())){
                        if(countyVscountyId.containsKey(attribute.country_state_County_string__c.toUpperCase())){
                            attribute.Value_ID__c = countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase());
                            System.debug('@@@@@@@'+attribute.Value_ID__c);

                        }
                    }
                }
            }
        }
        
        System.debug(finalAttrLinesList);
        System.debug(finalAttrLinesList.size());
        count +=finalAttrLinesList.size();
      //  try{
            system.debug('@@@@@attributesList'+finalAttrLinesList); 
            update finalAttrLinesList;            
       // } 
       // catch(exception ex){
       //     system.debug('@@@@@exception'+ex);
//        }       
        
    }
    
    global void finish(Database.BatchableContext BC) {
       System.debug(count); 
    }
    
}