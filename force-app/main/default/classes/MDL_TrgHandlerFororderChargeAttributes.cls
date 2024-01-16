public class MDL_TrgHandlerFororderChargeAttributes {
    public static void populateValueIdsonorderAddressFields(List<Order_Charge_Attribute__c> attributeList){
        
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
        Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
        
        for(Order_Charge_Attribute__c attribute: attributeList){
            //if(attribute.Value_ID__c == null || attribute.Value_ID__c ==''){
            if(attribute.Attribute_Name__c.contains('Country')){
                countryset.add(attribute.String_Value__c);
            }
            if(attribute.Attribute_Name__c.contains('State')){
                /* if(attribute.Picklist_Value__c != null){
stateset.add(attribute.Picklist_Value__c);
}
else if(attribute.String_Value__c != null){
stateset.add(attribute.String_Value__c);
}*/
                //stateset.add(attribute.Picklist_Value__c);
                stateset.add(attribute.CountryState_String__c);
            }
            if(attribute.Attribute_Name__c.contains('City')){
                cityset.add(attribute.Address_String__c);
            }
            if(attribute.Attribute_Name__c.contains('County')){
                /* if(attribute.Picklist_Value__c != null){
countyset.add(attribute.Picklist_Value__c);
}
else if(attribute.String_Value__c != null){
countyset.add(attribute.String_Value__c);
system.debug('@@@@@ County Value '+countyset);
}*/
                countyset.add(attribute.country_state_County_string__c);
            }
            
            if(attribute.Attribute_Name__c.contains('AOP')){
                aopSet.add(attribute.Picklist_Value__c);
            }
            
            // }
            
            
        }
        
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@aopSet'+aopSet);
        }
        
        //querying on existing country data to update value IDs
        for(AggregateResult geo: [select CountryName__c countryName,
                                  CountryID__c countryId
                                  From Geo_Location__c
                                  where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c IN:countryset
                                  Group by CountryName__c,CountryID__c]){
                                      countryVscountryId.put(string.valueOf(geo.get('countryName')),string.valueOf(geo.get('countryId')) );                        
                                  } 
        
        //querying on existing state data to update value IDs
        for(Geo_Location__c geo: [select countryStateString__c,
                                  StateID__c
                                  From Geo_Location__c
                                  where RecordType.DeveloperName = 'M_H_GEO_Locations' and countryStateString__c IN:stateset
                                 ]){
                                     stateVsstateId.put(geo.countryStateString__c.toUppercase(),geo.StateID__c );                        
                                 } 
        
        //querying on existing county data to update value IDs
        for(Geo_Location__c geo: [select country_state_County_string__c,
                                  County_ID__c
                                  From Geo_Location__c
                                  where RecordType.DeveloperName = 'M_H_GEO_Locations' and country_state_County_string__c IN:countyset
                                 ]){
                                     countyVscountyId.put(geo.country_state_County_string__c.toUpperCase(),geo.County_ID__c );                        
                                 } 
        
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@@countyVscountyId'+countyVscountyId);
        }
        
        //querying on existing City data to update value IDs
        for(Geo_Location__c geo: [select address_String__c,
                                  City_ID__c
                                  From Geo_Location__c
                                  where RecordType.DeveloperName = 'M_H_GEO_Locations' and address_String__c IN:cityset]){
                                      cityVscityId.put(geo.address_String__c.toUpperCase(),geo.City_ID__c );                        
                                  }
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@cityVscityId'+cityVscityId);
        }
        
        if(!aopSet.isEmpty()){
            for(aggregateResult geo : [select AOP_Name__c aop,AOP_ID__c aopId
                                       from Geo_Location__c
                                       where RecordType.DeveloperName = 'AOP_List' and AOP_Name__c IN:aopSet
                                       Group by AOP_Name__c,AOP_ID__c]){
                                           aopVsaopId.put(string.valueOf(geo.get('aop')),string.valueOf(geo.get('aopId')) );                              
                                       }
            
        }
        
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@aopVsaopId'+aopVsaopId);
        }
        
        for(Order_Charge_Attribute__c attribute: attributeList){
            
            if(attribute.Attribute_Name__c.contains('AOP')){
                attribute.Value_ID__c = aopVsaopId.get(attribute.Picklist_Value__c);
                
                if(debug.DebugOn__c == TRUE){
                    System.debug('@@@@@@@ AOP value '+ attribute.Value_ID__c);
                    System.debug('@@@@@@@ aopVsaopId '+ aopVsaopId);
                }
            }
            
            else if(attribute.Attribute_Name__c.contains('Country')){
                if(countryVscountryId.containsKey(attribute.String_Value__c)){
                    attribute.Value_ID__c = countryVscountryId.get(attribute.String_Value__c);
                }
                
            }
            else if(attribute.Attribute_Name__c.contains('State')){
                /* if(stateVsstateId.containsKey(attribute.Picklist_Value__c)){
attribute.Value_ID__c = stateVsstateId.get(attribute.Picklist_Value__c);
System.debug('@@@@@@@state'+ attribute.String_Value__c +attribute.Value_ID__c);
}
else if(stateVsstateId.containsKey(attribute.String_Value__c)){
attribute.Value_ID__c = stateVsstateId.get(attribute.String_Value__c);
System.debug('@@@@@@@state'+ attribute.String_Value__c +attribute.Value_ID__c);
}*/
                if(attribute.CountryState_String__c != null){
                    if(stateVsstateId.containsKey(attribute.CountryState_String__c.toUppercase())){
                        attribute.Value_ID__c = stateVsstateId.get(attribute.CountryState_String__c.toUppercase());
                         if(debug.DebugOn__c == TRUE){
                            System.debug('@@@@@@@State population'+attribute.Value_ID__c);
                        }
                    }
                }
            }
            else if(attribute.Attribute_Name__c.contains('City')){
                
                if(debug.DebugOn__c == TRUE){
                    system.debug('@@@@@@attribute.address_String__c'+attribute.address_String__c);
                }
                if(attribute.address_String__c != null){
                    if(cityVscityId.containsKey(attribute.address_String__c.toUpperCase())){
                        attribute.Value_ID__c = cityVscityId.get(attribute.Address_String__c.toUpperCase());
                        
                        if(debug.DebugOn__c == TRUE){
                            System.debug('@@@@@@@city population'+attribute.Value_ID__c);
                        }
                    }
                }
                
            }
            else if(attribute.Attribute_Name__c.contains('County')){
                if(attribute.country_state_County_string__c != NULL){
                    if(countyVscountyId.containsKey(attribute.country_state_County_string__c.toUpperCase())){
                        attribute.Value_ID__c = countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase());
                        if(debug.DebugOn__c == TRUE){
                            System.debug('@@@@@@@'+attribute.Value_ID__c);
                        }
                    }
                    else if(countyVscountyId.containsKey(attribute.country_state_County_string__c.toUpperCase())){
                        attribute.Value_ID__c = countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase());
                         
                         if(debug.DebugOn__c == TRUE){
                            System.debug('@@@@@@@ County'+ attribute.String_Value__c +attribute.Value_ID__c);
                        }
                    }
                }
                
                
            }
        }
    }
        //addded by saiv MHBS-3924
        //public static void populateGeoLocationValonOrderRPC(List<Order_Charge_Attribute__c> orderAttributeList){
        //added by saiv MHBS-4392 updated to future method
        @future
        public static void populateGeoLocationValonOrderRPC(String jsonString){
        List<Order_Charge_Attribute__c> orderAttributeList = (List<Order_Charge_Attribute__c>)Json.deserialize(jsonString,List<Order_Charge_Attribute__c>.class);
        Set<Id> orderRPCId = new Set<Id>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> ordrChargeToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<Id, invoiceit_s__Job_Rate_Plan_Charge__c> ordrChargeMap = new Map<Id, invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<Id, List<Order_Charge_Attribute__c>> OrdRPCVsOrdChrgAttr = new Map<Id, List<Order_Charge_Attribute__c>>();
        Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');

        for(Order_Charge_Attribute__c oca: orderAttributeList){
            orderRPCId.add(oca.Order_Rate_Plan_Charge__c);
            if(!OrdRPCVsOrdChrgAttr.containsKey(oca.Order_Rate_Plan_Charge__c)){
                OrdRPCVsOrdChrgAttr.put(oca.Order_Rate_Plan_Charge__c, new List<Order_Charge_Attribute__c>{oca});
            }
            else{
                OrdRPCVsOrdChrgAttr.get(oca.Order_Rate_Plan_Charge__c).add(oca);
            }
            
            
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('===orderRPCId==='+orderRPCId);
        }
        if(!orderRPCId.isEmpty()){
            for(invoiceit_s__Job_Rate_Plan_Charge__c  orpc: [select id,name,invoiceit_s__Accounting_Code__c ,Country_Attribute__c,State_attribute__c,
                                                City_County_attribute__c,AOP_Name__c FROM invoiceit_s__Job_Rate_Plan_Charge__c
                                                WHERE ID IN:orderRPCId]){
                if(OrdRPCVsOrdChrgAttr.containsKey(orpc.Id)){
                    List<Order_Charge_Attribute__c> ordAttrList = OrdRPCVsOrdChrgAttr.get(orpc.Id);
                    for(Order_Charge_Attribute__c ordca: ordAttrList){
                        if(ordca.Attribute_Name__c == 'Country' && ordca.Attribute_Type__c == 'Text' && ordca.String_Value__c != Null){
                            orpc.Country_Attribute__c = ordca.String_Value__c;
                            ordrChargeToUpdate.add(orpc);
                        }
                        if(ordca.Attribute_Name__c == 'State' && ordca.Attribute_Type__c == 'Picklist' && ordca.Picklist_Value__c != Null){
                            orpc.State_attribute__c = ordca.Picklist_Value__c;
                            ordrChargeToUpdate.add(orpc);
                        }
                        /*if(!Test.isRunningTest() && (ordca.Attribute_Name__c.contains('City') )
                            //|| (ordca.Attribute_Name__c.contains('County') && !ordca.Picklist_Value__c .contains('Independent'))
                            //|| (ordca.Attribute_Name__c.contains('County') && !ordca.Picklist_Value__c .contains('Independent'))
                            
                            ) 
                           && ordca.Attribute_Type__c == 'Text' && ordca.String_Value__c != Null){*/
                           
                           if(!Test.isRunningTest() && (ordca.Attribute_Name__c == 'City' || 
                               (ordca.Attribute_Name__c == 'County' && !ordca.Picklist_Value__c.contains('Independent City') )) 
                           && ordca.Attribute_Type__c == 'Picklist' && ordca.Picklist_Value__c != Null ){
                           
                               
                               /*if(ordca.Attribute_Name__c.contains('City') && orpc.name != null && (orpc.name.contains('LDC Preferred Banner Placements')||
                               orpc.name.contains('LDC Spanish Preferred County Results'))){
                                   
                                   system.debug('==inside Independent City=='); 
                                   orpc.City_County_attribute__c = 'Independent City;'+ ordca.Picklist_Value__c;
                                   }
                               else{
                                   orpc.City_County_attribute__c = ordca.Picklist_Value__c;
                               }
                               */
                               if(ordca.Attribute_Name__c =='City' && orpc.name != null && (orpc.invoiceit_s__Accounting_Code__c == '01910'
                                || orpc.invoiceit_s__Accounting_Code__c == '01932')  && ordca.Picklist_Value__c != Null && ordca.Picklist_Value__c != 'None' ){
                              //|| orpc.name.contains('LDC Spanish Preferred County Results'))  )
                                   if(debug.DebugOn__c == TRUE){
                                       system.debug('==inside Independent City==');
                                   }   
                                   orpc.City_County_attribute__c = 'Independent City;'+ ordca.Picklist_Value__c;
                               }
                               else if(ordca.Picklist_Value__c != Null && ordca.Picklist_Value__c != 'None'){
                                       if(debug.DebugOn__c == TRUE){
                                       system.debug('==inside city/county if===');  
                                   } 
                                       
                                       orpc.City_County_attribute__c = ordca.Picklist_Value__c;
                               }
                               ordrChargeToUpdate.add(orpc);
                           }
                        if(ordca.Attribute_Name__c == 'County' && ordca.Attribute_Type__c == 'Text' && ordca.String_Value__c != Null && !ordca.String_Value__c .contains('Independent City')){
                            orpc.City_County_attribute__c = ordca.String_Value__c;
                            ordrChargeToUpdate.add(orpc);
                        }
                        if(ordca.Attribute_Name__c!= null && ordca.Attribute_Name__c.contains('AOP') && ordca.Attribute_Type__c == 'Picklist' && ordca.Picklist_Value__c != Null){
                            orpc.AOP_Name__c = ordca.Picklist_Value__c;
                            ordrChargeToUpdate.add(orpc);
                        }
                    }
                }                                    
            }
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('==ordrChargeToUpdate=='+ordrChargeToUpdate);
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c ordpc: ordrChargeToUpdate){
            ordrChargeMap.put(ordpc.Id, ordpc);
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('==ordrChargeMap=='+ordrChargeMap);
        }
        if(!ordrChargeMap.values().isEmpty()){
            update ordrChargeMap.values();            
        }

    } 
    
    //addded by saiv MHBS-3924
        public static void populateGeoLocationValonOrderRPC_NF(List<Order_Charge_Attribute__c> orderAttributeList){
        Set<Id> orderRPCId = new Set<Id>();
        List<invoiceit_s__Job_Rate_Plan_Charge__c> ordrChargeToUpdate = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<Id, invoiceit_s__Job_Rate_Plan_Charge__c> ordrChargeMap = new Map<Id, invoiceit_s__Job_Rate_Plan_Charge__c>();
        Map<Id, List<Order_Charge_Attribute__c>> OrdRPCVsOrdChrgAttr = new Map<Id, List<Order_Charge_Attribute__c>>();
        Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');

        for(Order_Charge_Attribute__c oca: orderAttributeList){
            orderRPCId.add(oca.Order_Rate_Plan_Charge__c);
            if(!OrdRPCVsOrdChrgAttr.containsKey(oca.Order_Rate_Plan_Charge__c)){
                OrdRPCVsOrdChrgAttr.put(oca.Order_Rate_Plan_Charge__c, new List<Order_Charge_Attribute__c>{oca});
            }
            else{
                OrdRPCVsOrdChrgAttr.get(oca.Order_Rate_Plan_Charge__c).add(oca);
            }
            
            
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('===orderRPCId==='+orderRPCId);
        }
        if(!orderRPCId.isEmpty()){
            for(invoiceit_s__Job_Rate_Plan_Charge__c  orpc: [select id,name,invoiceit_s__Accounting_Code__c ,Country_Attribute__c,State_attribute__c,
                                                City_County_attribute__c,AOP_Name__c FROM invoiceit_s__Job_Rate_Plan_Charge__c
                                                WHERE ID IN:orderRPCId]){
                if(OrdRPCVsOrdChrgAttr.containsKey(orpc.Id)){
                    List<Order_Charge_Attribute__c> ordAttrList = OrdRPCVsOrdChrgAttr.get(orpc.Id);
                    for(Order_Charge_Attribute__c ordca: ordAttrList){
                        if(ordca.Attribute_Name__c == 'Country' && ordca.Attribute_Type__c == 'Text' && ordca.String_Value__c != Null){
                            orpc.Country_Attribute__c = ordca.String_Value__c;
                            ordrChargeToUpdate.add(orpc);
                        }
                        if(ordca.Attribute_Name__c == 'State' && ordca.Attribute_Type__c == 'Picklist' && ordca.Picklist_Value__c != Null){
                            orpc.State_attribute__c = ordca.Picklist_Value__c;
                            ordrChargeToUpdate.add(orpc);
                        }
                            if(!Test.isRunningTest() && (ordca.Attribute_Name__c == 'City' || 
                               (ordca.Attribute_Name__c == 'County' && !ordca.Picklist_Value__c.contains('Independent City') )) 
                           && ordca.Attribute_Type__c == 'Picklist' && ordca.Picklist_Value__c != Null ){
                           
                               
                               if(ordca.Attribute_Name__c =='City' && orpc.name != null && (orpc.invoiceit_s__Accounting_Code__c == '01910'
                                || orpc.invoiceit_s__Accounting_Code__c == '01932')  && ordca.Picklist_Value__c != Null && ordca.Picklist_Value__c != 'None' ){
                                   if(debug.DebugOn__c == TRUE){
                                       system.debug('==inside Independent City==');
                                   }   
                                   orpc.City_County_attribute__c = 'Independent City;'+ ordca.Picklist_Value__c;
                               }
                               else if(ordca.Picklist_Value__c != Null && ordca.Picklist_Value__c != 'None'){
                                       if(debug.DebugOn__c == TRUE){
                                       system.debug('==inside city/county if===');  
                                   } 
                                       
                                       orpc.City_County_attribute__c = ordca.Picklist_Value__c;
                               }
                               ordrChargeToUpdate.add(orpc);
                           }
                        if(ordca.Attribute_Name__c == 'County' && ordca.Attribute_Type__c == 'Text' && ordca.String_Value__c != Null && !ordca.String_Value__c .contains('Independent City')){
                            orpc.City_County_attribute__c = ordca.String_Value__c;
                            ordrChargeToUpdate.add(orpc);
                        }
                        if(ordca.Attribute_Name__c!= null && ordca.Attribute_Name__c.contains('AOP') && ordca.Attribute_Type__c == 'Picklist' && ordca.Picklist_Value__c != Null){
                            orpc.AOP_Name__c = ordca.Picklist_Value__c;
                            ordrChargeToUpdate.add(orpc);
                        }
                    }
                }                                    
            }
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('==ordrChargeToUpdate=='+ordrChargeToUpdate);
        }
        for(invoiceit_s__Job_Rate_Plan_Charge__c ordpc: ordrChargeToUpdate){
            ordrChargeMap.put(ordpc.Id, ordpc);
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('==ordrChargeMap=='+ordrChargeMap);
        }
        if(!ordrChargeMap.values().isEmpty()){
            update ordrChargeMap.values();            
        }

    } 
}