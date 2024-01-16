global class BatchtoUpdateOrderAttributeValues implements Database.Batchable<sObject>{
    
     global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = 'Select Id,Name,invoiceit_s__Job_Rate_Plan__c,SIN__c '
                       // + ' (SELECT Attribute_Order__c,Picklist_Value__c,Required__c, '
                       // + ' Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, '
                       // + ' Attribute_Picklist_Values__c, Name,Attribute_Name__c,Attribute_Type__c, '
                      //  + ' Boolean_Value__c,Date_Value__c,Phone_Value__c,Number_Value__c,Address_String__c, '
                      //  + ' Order_Rate_Plan_Charge__c,String_Value__c,Address_Order__c '
                     //   + ' FROM Order_Charge_Attributes__r '
                     //   + ' where Attribute_Name__c = \'Service Country\' or Attribute_Name__c = \'Service State\' '+
                     //   + ' or Attribute_Name__c = \'Service City\' or  Attribute_Name__c = \'Xref Country\' '
                     //    + ' or  Attribute_Name__c = \'Xref State\' or Attribute_Name__c = \'Xref City\' '
                    //    + ' or Attribute_Name__c = \'Country\' or Attribute_Name__c = \'State\' '
                    //    + ' or Attribute_Name__c = \'County\' or Attribute_Name__c = \'City\'  ORDER By Address_Order__c ASC ) '
                        + ' FROM invoiceit_s__Job_Rate_Plan_Charge__c '
                        + ' where (invoiceit_s__Status__c = \'Active\'  or (invoiceit_s__Status__c = \'Renewed\' and invoiceit_s__Service_End_Date__c > Today ) or (invoiceit_s__Status__c = \'Rebased\' and invoiceit_s__Service_End_Date__c > Today)'
                        + '  or (invoiceit_s__Status__c = \'Truncated\'and invoiceit_s__Service_End_Date__c > Today))' ;
                       // + ' and id= \'a0FW0000001jnar\'';
                       
                       // + ' where id= \'IdtoHadrdcodefortesting\'';
                 
            
        if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
        }
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<invoiceit_s__Job_Rate_Plan_Charge__c> orderchargeList){
        Set<String> countryset                = new Set<String>();
        Set<String> stateset                  = new Set<String>();  //coutry;state
        Set<String> cityset                   = new Set<String>();
        Set<String> countyset                 = new Set<String>();
        Set<String> aopSet                    = new Set<String>();
        Map<String,string> countryVscountryId = new Map<String,string>();
        Map<String,string> stateVsstateId     = new Map<String,string>();
        Map<String,string> cityVscityId       = new Map<String,string>();
        Map<String,string> countyVscountyId   = new Map<String,string>();
        Map<id,String> optychargeVsAttributeString         = new Map<id,String>();
        Map<id,String> optychargeVsxrefAttributeString     = new Map<id,String>();
        Map<id,String> optychargeVsInvAttributeString      = new Map<id,String>();
        Map<id,String> optychargeVsCountryStateString         = new Map<id,String>();
        Map<id,String> optychargeVsxrefCountryStateString     = new Map<id,String>();
        Map<id,String> optychargeVsInvCountryStateString      = new Map<id,String>();
        Map<String,string> aopVsaopId         = new Map<String,string>();
        List<Order_Charge_Attribute__c> attributesList     = new List<Order_Charge_Attribute__c>();
        
        List<invoiceit_s__Job_Rate_Plan_Charge__c> chargeList =
            [Select Id,Name,invoiceit_s__Job_Rate_Plan__c,SIN__c,
                (SELECT Attribute_Order__c,Picklist_Value__c,Required__c,
                        Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, 
                        Attribute_Picklist_Values__c, Name,Attribute_Name__c,Attribute_Type__c,
                        Boolean_Value__c,Date_Value__c,Phone_Value__c,Number_Value__c,Address_String__c,
                        Order_Rate_Plan_Charge__c,String_Value__c,Address_Order__c,Value_ID__c
                        FROM Order_Charge_Attributes__r
                        where (Attribute_Name__c = 'Service Country' or Attribute_Name__c = 'Service State'
                              or Attribute_Name__c = 'Service City' or  Attribute_Name__c = 'Xref Country'
                              or  Attribute_Name__c = 'Xref State' or Attribute_Name__c = 'Xref City'
                              or Attribute_Name__c = 'Country' or Attribute_Name__c = 'State'
                              or Attribute_Name__c = 'County' or Attribute_Name__c = 'City'
                              or ( Attribute_Name__c like '%AOP%') or Attribute_Name__c = 'Xref County' )
                              //and (Value_ID__c = null or Value_ID__c ='' )
                              ORDER By Address_Order__c ASC ) 
                FROM invoiceit_s__Job_Rate_Plan_Charge__c
                where (invoiceit_s__Status__c = 'Active'  
                      or (invoiceit_s__Status__c = 'Renewed' and invoiceit_s__Service_End_Date__c > Today ) 
                      or (invoiceit_s__Status__c = 'Rebased' and invoiceit_s__Service_End_Date__c > Today)
                      or (invoiceit_s__Status__c = 'Truncated'and invoiceit_s__Service_End_Date__c > Today))
                      AND Id IN:orderchargeList] ;
        
         for(invoiceit_s__Job_Rate_Plan_Charge__c optycharge : chargeList){
            if(optycharge.Order_Charge_Attributes__r.size() > 0){
                for(Order_Charge_Attribute__c attribute: optycharge.Order_Charge_Attributes__r){
                     if(attribute.Attribute_Name__c.contains('Country')){
                         if(attribute.String_Value__c != null){
                             countryset.add(attribute.String_Value__c);
                         } 
                        
                     }
                  /*  if(attribute.Attribute_Name__c.contains('State')){
                        if(attribute.Picklist_Value__c != null){
                            stateset.add(attribute.Picklist_Value__c);
                        }
                        else if(attribute.String_Value__c != null){
                            stateset.add(attribute.String_Value__c);
                        }
                        system.debug('@@@@stateset111111'+stateset);
                     }*/
                    if(attribute.Attribute_Name__c.contains('County')){
                        if(attribute.Picklist_Value__c != null){
                            countyset.add(attribute.Picklist_Value__c);
                        }
                         else if(attribute.String_Value__c != null){
                            countyset.add(attribute.String_Value__c);
                        }
                        
                    }
                    
                    if(attribute.Attribute_Name__c.contains('AOP')){
                    aopSet.add(attribute.Picklist_Value__c);
                    }
                   
                    
                
                    if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service State' 
                       || attribute.Attribute_Name__c == 'Service City'){
                           string serviceValue = '';
                           if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service City'){
                               if(attribute.String_Value__c != null){
                                   serviceValue = attribute.String_Value__c;
                               }
                               
                           }
                           else{
                               if(attribute.Picklist_Value__c != null){
                                   serviceValue = attribute.Picklist_Value__c;
                               }
                               else if(attribute.String_Value__c != null){
                                    serviceValue = attribute.String_Value__c;
                                }
                               
                           }
                           
                            //forming country state map here
                        if(attribute.Attribute_Name__c == 'Service Country' || attribute.Attribute_Name__c == 'Service State' ){
                            if(optychargeVsCountryStateString.containsKey(optycharge.id)){
                                string temp = optychargeVsCountryStateString.get(optycharge.id) + ';' + serviceValue;
                               optychargeVsCountryStateString.put(optycharge.id, temp);
                            }
                          else{
                              optychargeVsCountryStateString.put(optycharge.id,serviceValue);
                            }
                        }
                           
                           
                           if(optychargeVsAttributeString.containsKey(optycharge.id)){
                                string temp = optychargeVsAttributeString.get(optycharge.id) + ';' + serviceValue;
                               optychargeVsAttributeString.put(optycharge.id, temp);
                            }
                          else{
                              optychargeVsAttributeString.put(optycharge.id,serviceValue);
                          }
                     }
                  
                    
                    
                    /***city formation for xref******/
                     if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State' 
                        || attribute.Attribute_Name__c == 'Xref City'){
                             string xrefValue = '';
                           if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref City'){
                               if(attribute.String_Value__c != null){
                                   xrefValue = attribute.String_Value__c;
                               }
                               
                           }
                           else{
                               if(attribute.Picklist_Value__c != null){
                                   xrefValue = attribute.Picklist_Value__c;
                               }
                               else if(attribute.String_Value__c != null){
                                    xrefValue = attribute.String_Value__c;
                                }
                               
                           }
                            
                            if(attribute.Attribute_Name__c == 'Xref Country' || attribute.Attribute_Name__c == 'Xref State'){
                                if(optychargeVsxrefCountryStateString.containsKey(optycharge.id)){
                                    string temp = optychargeVsxrefCountryStateString.get(optycharge.id) + ';' + xrefValue;
                                    optychargeVsxrefCountryStateString.put(optycharge.id, temp);
                                }
                                else{
                                    optychargeVsxrefCountryStateString.put(optycharge.id,xrefValue );
                                }
                            }
                            
                            if(optychargeVsxrefAttributeString.containsKey(optycharge.id)){
                                string temp = optychargeVsxrefAttributeString.get(optycharge.id) + ';' + xrefValue;
                               optychargeVsxrefAttributeString.put(optycharge.id, temp);
                            }
                            else{
                                optychargeVsxrefAttributeString.put(optycharge.id,xrefValue );
                            }
                     }
                    
                    /****normal address formation****/
                    if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State' 
                             || attribute.Attribute_Name__c == 'City' ){ 
                              String value='';
                                if(attribute.Attribute_Name__c == 'Country'){
                                    if(attribute.String_Value__c != null){
                                        value = attribute.String_Value__c;
                                    }
                                    
                                } 
                                else{
                                    if(attribute.Picklist_Value__c != null){
                                        value = attribute.Picklist_Value__c;
                                    }
                                    else if(attribute.String_Value__c != null){
                                        value = attribute.String_Value__c;
                                    }
                                    
                                }
                                 
                                if(attribute.Attribute_Name__c == 'Country' || attribute.Attribute_Name__c == 'State'){
                                     if(optychargeVsInvCountryStateString.containsKey(optycharge.id)){
                                        string temp = optychargeVsInvCountryStateString.get(optycharge.id) + ';' + value;
                                        optychargeVsInvCountryStateString.put(optycharge.id, temp);
                                    }
                                    else{
                                        optychargeVsInvCountryStateString.put(optycharge.id,value );
                                    }
                                 }  
                                 
                               if(optychargeVsInvAttributeString.containsKey(optycharge.id)){
                                    string temp = optychargeVsInvAttributeString.get(optycharge.id) + ';' + value;
                                   optychargeVsInvAttributeString.put(optycharge.id, temp);
                                }
                              else{
                                  optychargeVsInvAttributeString.put(optycharge.id,value );
                              }
                           }    
                    
                    if(attribute.Attribute_Name__c == 'Service City'){
                            cityset.add(optychargeVsAttributeString.get(optycharge.id));
                            attribute.Address_String__c = optychargeVsAttributeString.get(optycharge.id);
                    }
                    else if(attribute.Attribute_Name__c == 'Xref City'){
                           cityset.add(optychargeVsxrefAttributeString.get(optycharge.id));
                           attribute.Address_String__c = optychargeVsxrefAttributeString.get(optycharge.id);
                     }
                     else if(attribute.Attribute_Name__c == 'City'){
                            cityset.add(optychargeVsInvAttributeString.get(optycharge.id));
                            attribute.Address_String__c = optychargeVsInvAttributeString.get(optycharge.id);
                           
                     }
                    else if(attribute.Attribute_Name__c == 'Service State'){
                        stateset.add(optychargeVsCountryStateString.get(optycharge.id));
                         attribute.CountryState_String__c = optychargeVsCountryStateString.get(optycharge.id);
                    }
                    else if(attribute.Attribute_Name__c == 'Xref State'){
                        stateset.add(optychargeVsxrefCountryStateString.get(optycharge.id));
                         attribute.CountryState_String__c = optychargeVsxrefCountryStateString.get(optycharge.id);
                    }
                    else if(attribute.Attribute_Name__c == 'State'){
                        stateset.add(optychargeVsInvCountryStateString.get(optycharge.id));
                         attribute.CountryState_String__c = optychargeVsInvCountryStateString.get(optycharge.id);
                    }
                    attributesList.add(attribute);
                    
                }
            }
            
        }
        
         if(!aopSet.isEmpty()){
                      for(aggregateResult geo : [select AOP_Name__c aop,AOP_ID__c aopId
                                                       from Geo_Location__c
                                                       where RecordType.DeveloperName = 'AOP_List' and AOP_Name__c IN:aopSet
                                                Group by AOP_Name__c,AOP_ID__c]){
                            aopVsaopId.put(string.valueOf(geo.get('aop')),string.valueOf(geo.get('aopId')) );                              
                      }
                     
             }
        
          //querying on existing country data to update value IDs
        if(!countryset.isEmpty()){
             for(AggregateResult geo: [select CountryName__c countryName,
                                            CountryID__c countryId
                                            From Geo_Location__c
                                            where Recordtype.DeveloperName =: 'M_H_GEO_Locations' and CountryName__c IN:countryset
                                     Group by CountryName__c,CountryID__c]){
                 countryVscountryId.put(string.valueOf(geo.get('countryName')).toUppercase(),string.valueOf(geo.get('countryId')) );                        
           } 
        }
      
        
        system.debug('@@@@ stateset'+ stateset);
        system.debug('@@@@cityset'+cityset);
       //querying on existing state data to update value IDs
        if(!stateset.isEmpty()){
             for(Geo_Location__c geo: [select countryStateString__c,
                                            StateID__c
                                            From Geo_Location__c
                                            where Recordtype.DeveloperName =: 'M_H_GEO_Locations' and countryStateString__c IN:stateset
                                     ]){
                 stateVsstateId.put(geo.countryStateString__c.toUppercase(),geo.StateID__c );                        
           } 
        }
       
       system.debug('@@@@@@@countyset'+countyset);
        
       //querying on existing county data to update value IDs
        if(!countyset.isEmpty()){
            for(AggregateResult geo: [select County_Name__c county,
                                            County_ID__c countyId
                                            From Geo_Location__c
                                            where Recordtype.DeveloperName =: 'M_H_GEO_Locations' and County_Name__c IN:countyset
                                     Group by County_Name__c,County_ID__c]){
                                         if(geo.get('county') != null && geo.get('countyId')!= null){
                                             countyVscountyId.put(string.valueOf(geo.get('county')).toUppercase(),string.valueOf(geo.get('countyId')) );       
               }                        
                                  
           }  
        }
        
        system.debug('@@@@@@@countyVscountyId'+countyVscountyId);
      
        
       //querying on existing City data to update value IDs
        if(!cityset.isEmpty()){
            for(Geo_Location__c geo: [select address_String__c,
                                        City_ID__c
                                         From Geo_Location__c
                                        where Recordtype.DeveloperName =: 'M_H_GEO_Locations' and address_String__c IN:cityset]){
             cityVscityId.put(geo.address_String__c.toUppercase(),geo.City_ID__c );                        
            }
        }
       
       system.debug('@@@@cityVscityId'+cityVscityId);
        
        for(Order_Charge_Attribute__c attribute: attributesList){
        
             if(attribute.Attribute_Name__c.contains('AOP') && (attribute.Value_ID__c == null || attribute.Value_ID__c == '')){
                    attribute.Value_ID__c = aopVsaopId.get(attribute.Picklist_Value__c);
                      System.debug('@@@@@@@ AOP value '+ attribute.Value_ID__c);
                      System.debug('@@@@@@@ aopVsaopId '+ aopVsaopId);
                } 
                
            else if(attribute.Attribute_Name__c.contains('Country') && (attribute.Value_ID__c == null || attribute.Value_ID__c == '')){
                if(attribute.String_Value__c != null){
                    if(countryVscountryId.containsKey(attribute.String_Value__c.toUppercase())){
                        attribute.Value_ID__c = countryVscountryId.get(attribute.String_Value__c.toUppercase());
                    }
                }
                
                
            }
            else if(attribute.Attribute_Name__c.contains('State') && (attribute.Value_ID__c == null || attribute.Value_ID__c == '')){
                
               /* if(attribute.Picklist_Value__c != null){
                     if(stateVsstateId.containsKey(attribute.Picklist_Value__c.toUppercase())){
                        attribute.Value_ID__c = stateVsstateId.get(attribute.Picklist_Value__c.toUppercase());
                        System.debug('@@@@@@@state'+ attribute.String_Value__c +attribute.Value_ID__c);
                    } 
                }
                else if(attribute.String_Value__c != null){
                     if(stateVsstateId.containsKey(attribute.String_Value__c.toUppercase())){
                        attribute.Value_ID__c = stateVsstateId.get(attribute.String_Value__c.toUppercase());
                        System.debug('@@@@@@@state'+ attribute.String_Value__c +attribute.Value_ID__c);
                    } 
                }*/
                if(attribute.CountryState_String__c != null){
                    if(stateVsstateId.containsKey(attribute.CountryState_String__c.toUppercase())){
                        attribute.Value_ID__c = stateVsstateId.get(attribute.CountryState_String__c.toUppercase());
                        System.debug('@@@@@@@city population'+attribute.Value_ID__c);
                    }
                }
                    
            }
            else if(attribute.Attribute_Name__c.contains('City') && (attribute.Value_ID__c == null || attribute.Value_ID__c == '')){
                if(attribute.address_String__c != null){
                    if(cityVscityId.containsKey(attribute.address_String__c.toUppercase())){
                        attribute.Value_ID__c = cityVscityId.get(attribute.Address_String__c.toUppercase());
                        System.debug('@@@@@@@city population'+attribute.Value_ID__c);
                    }
                }
                
            }
            else if(attribute.Attribute_Name__c.contains('County') && (attribute.Value_ID__c == null || attribute.Value_ID__c == '')){
                if(attribute.Picklist_Value__c != null){
                    if(countyVscountyId.containsKey(attribute.Picklist_Value__c.toUppercase())){
                        attribute.Value_ID__c = countyVscountyId.get(attribute.Picklist_Value__c.toUppercase());
                        System.debug('@@@@@@@'+attribute.Value_ID__c);
                    }
                }
                else if(attribute.String_Value__c != null){
                    if(countyVscountyId.containsKey(attribute.String_Value__c.toUppercase())){
                        attribute.Value_ID__c = countyVscountyId.get(attribute.String_Value__c.toUppercase());
                        System.debug('@@@@@@@ in county'+attribute.Value_ID__c);
                    }
                }
                
                
                
            }
       }
        
        try{
            system.debug('@@@@@attributesList'+attributesList); 
            update attributesList;
            //database.update(attributesList,false);
             
        } 
        catch(exception ex){
            system.debug('@@@@@exception'+ex);
        }
       
        
    }
    
     global void finish(Database.BatchableContext BC) {
            
    }
    
}