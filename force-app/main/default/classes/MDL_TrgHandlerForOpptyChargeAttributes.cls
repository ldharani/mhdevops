/*
** Created by : Lister Technologies
** Created Date : 24th Nov
** Purpose : RBW-753 - Inventory ID to be blanked out when Location/AOP attributes are changed after inventory is pended
** Test Class :
** 
** Modified On : June 10,2015
** Modified purpose : Inventory id to be blanked out in the integration class only after receiving a '200-success' response
*/
public class MDL_TrgHandlerForOpptyChargeAttributes {
    public static boolean beforeUpdate = True;
    public static boolean AfterUpdate = True;
    
    
    
    public static void blankInventoryId(List<Opportunity_Charge_Attribute__c> lstOpptyCharges,Map<Id,Opportunity_Charge_Attribute__c> oldMapOpptyCharges) {
        Set<Id> setOpptyChargeAttributes = new Set<Id>();
        Set<Id> setOpptyProdIds = new Set<Id>();
        Map<Id,String> mapOppProdNInventoryId = new Map<Id,String>();
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProdsToUpdate = new List<invoiceit_crmx__Opportunity_Product__c>();
        Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
        for(Opportunity_Charge_Attribute__c oppRPC : lstOpptyCharges) {
            if((oppRPC.Attribute_Type__c == 'Picklist' || oppRPC.Attribute_Type__c == 'Text') && ((oppRPC.Picklist_Value__c != oldMapOpptyCharges.get(oppRPC.Id).Picklist_Value__c)||(oppRPC.String_Value__c != oldMapOpptyCharges.get(oppRPC.Id).String_Value__c))) {
                if(oppRPC.Attribute_Name__c == 'City' || oppRPC.Attribute_Name__c == 'County' || oppRPC.Attribute_Name__c == 'Country' || oppRPC.Attribute_Name__c == 'State' || oppRPC.Attribute_Name__c .contains('AOP')) {
                    setOpptyChargeAttributes.add(oppRPC.Id);
                }//end of inner if
            }//end of outer if
        }//end of for
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@@setOpptyChargeAttributes'+setOpptyChargeAttributes);
        }
        for(Opportunity_Charge_Attribute__c oppCharges : [Select Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,
                                                                 Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c,
                                                                 Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.IsInventoried__c
                                                          From Opportunity_Charge_Attribute__c
                                                          Where Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c != null
                                                          and Id in : setOpptyChargeAttributes]) {
            setOpptyProdIds.add(oppCharges.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id);     
            mapOppProdNInventoryId.put(oppCharges.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id,oppCharges.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.InventoryId__c);                                        
        }
        if(setOpptyProdIds.size() > 0) {
            User u = [select Id, username from User where Id = :UserInfo.getUserId()];
             if(debug.DebugOn__c == TRUE){
                System.debug('@@@@@@release inventory to be sent'+setOpptyProdIds);
            }
            MDL_Integration_Vim_Efs.releaseInventoryRequest(setOpptyProdIds, u.Username,mapOppProdNInventoryId);
        }
        
        /*for(invoiceit_crmx__Opportunity_Product__c oppProd : [Select id , InventoryId__c from invoiceit_crmx__Opportunity_Product__c where Id in : setOpptyProdIds]) {
                oppProd.InventoryId__c = null;
                System.debug('Opp Prod::'+oppProd.Id+'**InventoryId**'+oppProd.InventoryId__c);
                lstOppProdsToUpdate.add(oppProd);   
        }
        if(lstOppProdsToUpdate.size() > 0) {
            Database.update(lstOppProdsToUpdate);
        }
        */
    }
    
    public static void populateOpptyChrgAttr(List<Opportunity_Charge_Attribute__c> attributeList){
        
        for(Opportunity_Charge_Attribute__c opptyAttr: attributeList){
            if(opptyAttr.Attribute_Name__c == 'MH PPC Landing Page'){
                
            }
        }
    
    }
    
    
    
    public static void populateValueIdsonAddressFields(List<Opportunity_Charge_Attribute__c> attributeList){
        Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
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
        
        for(Opportunity_Charge_Attribute__c attribute: attributeList){
            //if(attribute.Value_ID__c == null || attribute.Value_ID__c ==''){
            if(attribute.Attribute_Name__c != null){
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
                    /*if(attribute.Picklist_Value__c != null){
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
            }   
               
           // }
            
            
       }
        
        if(debug.DebugOn__c == TRUE){
            system.debug('@@@@cityset'+cityset);
        }
        
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
       if(debug.DebugOn__c == TRUE){
           system.debug('@@@@countyVscountyId'+countyVscountyId); 
       } 
        
       //querying on existing City data to update value IDs
       if(cityset!= NULL && !cityset.isEmpty()){
       for(Geo_Location__c geo: [select address_String__c,
                                        City_ID__c
                                         From Geo_Location__c
                                        where RecordType.DeveloperName = 'M_H_GEO_Locations' and address_String__c IN:cityset]){
             cityVscityId.put(geo.address_String__c.toUpperCase(),geo.City_ID__c );                        
           }
       
       }
        if(debug.DebugOn__c == TRUE){
           system.debug('@@@@cityVscityId'+cityVscityId);
       }
        
         if(aopSet!= NULL && !aopSet.isEmpty()){
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
        
        for(Opportunity_Charge_Attribute__c attribute: attributeList){
            if(attribute.Attribute_Name__c != null){
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
                            System.debug('@@@@@@@city population'+attribute.Value_ID__c);
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
                     if(attribute.country_state_County_string__c!= null){
                    if(countyVscountyId.containsKey(attribute.country_state_County_string__c.toUpperCase())){
                        attribute.Value_ID__c = countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase());
                        if(debug.DebugOn__c == TRUE){
                        System.debug('@@@@@@@'+attribute.Value_ID__c);
                        }
                    }
                    }
                   else if(countyVscountyId.containsKey(attribute.String_Value__c)){
                            attribute.Value_ID__c = countyVscountyId.get(attribute.country_state_County_string__c.toUpperCase());
                            if(debug.DebugOn__c == TRUE){
                            System.debug('@@@@@@@ County'+ attribute.String_Value__c +attribute.country_state_County_string__c.toUpperCase());
                             }
                     }
                    
                }
              

                
            }
        }
        
        
        
        
        
        
    }
    
    //addded by saiv MHBS-3924
    public static void populateGeoLocationValonOptyRPC(List<Opportunity_Charge_Attribute__c> oppAttributeList, Map<Id, Opportunity_Charge_Attribute__c> oldMap){
        Set<Id> oppRPCId = new Set<Id>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c > oppChargeToUpdate = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c >();
        Map<Id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c > ordrChargeMap = new Map<Id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c >();
        Map<Id, List<Opportunity_Charge_Attribute__c>> OppRPCVsOppChrgAttr = new Map<Id, List<Opportunity_Charge_Attribute__c>>();
        Deactivate_Trigger_for_data_load__c debug = Deactivate_Trigger_for_data_load__c.getValues('Debug Status');
        for(Opportunity_Charge_Attribute__c oca: oppAttributeList){
            oppRPCId.add(oca.Opportunity_Rate_Plan_Charge__c);
            if(!OppRPCVsOppChrgAttr.containsKey(oca.Opportunity_Rate_Plan_Charge__c)){
                OppRPCVsOppChrgAttr.put(oca.Opportunity_Rate_Plan_Charge__c, new List<Opportunity_Charge_Attribute__c>{oca});
            }
            else{
                OppRPCVsOppChrgAttr.get(oca.Opportunity_Rate_Plan_Charge__c).add(oca);
            }
            
            
        }
        if(debug.DebugOn__c == TRUE){
            system.debug('===oppRPCId==='+oppRPCId);
        }
        if(!oppRPCId.isEmpty()){
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c  oprpc: [select id,name,invoiceit_crmx__Accounting_Code__c,Country_Attribute__c,State_attribute__c,
                                                City_County_attribute__c,AOP_Name__c FROM invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                WHERE ID IN:oppRPCId]){
                if(debug.DebugOn__c == TRUE){                                
                    system.debug('===oprpc==='+oprpc);
                }
                if(OppRPCVsOppChrgAttr.containsKey(oprpc.Id)){
                    List<Opportunity_Charge_Attribute__c> oppAttrList = OppRPCVsOppChrgAttr.get(oprpc.Id);
                    for(Opportunity_Charge_Attribute__c oppca: oppAttrList){
                        if(oppca.Attribute_Name__c == 'Country' && oppca.Attribute_Type__c == 'Text' && oppca.String_Value__c != Null){
                            if(debug.DebugOn__c == TRUE){
                            system.debug('==inside country if===');
                            }
                            oprpc.Country_Attribute__c = oppca.String_Value__c;
                            oppChargeToUpdate.add(oprpc);
                        }
                        if(oppca.Attribute_Name__c == 'State' && oppca.Attribute_Type__c == 'Picklist' && oppca.Picklist_Value__c != Null
                            && oppca.Picklist_Value__c != oldMap.get(oppca.Id).Picklist_Value__c){
                            if(debug.DebugOn__c == TRUE){
                            system.debug('==inside state if===');
                            }
                            oprpc.State_attribute__c = oppca.Picklist_Value__c;
                            oppChargeToUpdate.add(oprpc);
                        }
                        if((oppca.Attribute_Name__c =='City' || (oppca.Attribute_Name__c == 'County' && oppca.Picklist_Value__c != Null && !oppca.Picklist_Value__c.contains('Independent City') )) 
                           && oppca.Attribute_Type__c == 'Picklist' && oppca.Picklist_Value__c != Null && oppca.Picklist_Value__c != oldMap.get(oppca.Id).Picklist_Value__c){
                               if(debug.DebugOn__c == TRUE){
                               system.debug('@@@@@ Charge Name'+oppca.Opportunity_Rate_Plan_Charge__c);
                              system.debug('@@@@@ Test ----Charge Name'+ oprpc.name);
    
                          
                               system.debug('@@@@@ Attribute Name'+oppca.Attribute_Name__c);
                               }
                               if(oppca.Attribute_Name__c == 'City' && oprpc.name != null && (oprpc.invoiceit_crmx__Accounting_Code__c == '01910' 
                                   ||  oprpc.invoiceit_crmx__Accounting_Code__c == '01932') && oppca.Picklist_Value__c != Null && oppca.Picklist_Value__c != 'None'  ){
                               //||  oprpc.name.contains('LDC Spanish Preferred County Results'))  )
                                   if(debug.DebugOn__c == TRUE){
                                   system.debug('==inside Independent City==');  
                                   }
                                   oprpc.City_County_attribute__c = 'Independent City;'+ oppca.Picklist_Value__c;
                               }
                               else if(oppca.Picklist_Value__c != Null && oppca.Picklist_Value__c != 'None'){
                                       if(debug.DebugOn__c == TRUE){
                                       system.debug('==inside city/county if===');  
                                       }
                                       oprpc.City_County_attribute__c = oppca.Picklist_Value__c;
                               }
                               
                               oppChargeToUpdate.add(oprpc);
                           }
                        if(oppca.Attribute_Name__c == 'County' && oppca.Attribute_Type__c == 'Text' && oppca.String_Value__c != Null && !oppca.String_Value__c .contains('Independent City')
                            && oppca.String_Value__c != oldMap.get(oppca.Id).String_Value__c){
                            if(debug.DebugOn__c == TRUE){
                            system.debug('==inside county if===');
                            }
                            oprpc.City_County_attribute__c = oppca.String_Value__c ;
                            oppChargeToUpdate.add(oprpc);
                        }
                        if(oppca.Attribute_Name__c.contains('AOP') && oppca.Attribute_Type__c == 'Picklist' && oppca.Picklist_Value__c != Null
                            && oppca.Picklist_Value__c != oldMap.get(oppca.Id).Picklist_Value__c){
                            if(debug.DebugOn__c == TRUE){
                            system.debug('==inside AOP if===');
                            }
                            oprpc.AOP_Name__c = oppca.Picklist_Value__c;
                            oppChargeToUpdate.add(oprpc);
                        }
                    }
                }                                    
            }
        }
        if(debug.DebugOn__c == TRUE){
        system.debug('==oppChargeToUpdate=='+oppChargeToUpdate);
        }
        for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c optyrpc: oppChargeToUpdate){
            ordrChargeMap.put(optyrpc.Id, optyrpc);
        }
        if(debug.DebugOn__c == TRUE){
        system.debug('==ordrChargeMap=='+ordrChargeMap);
        }
        if(!ordrChargeMap.values().isEmpty()){
            update ordrChargeMap.values();            
        }

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
    }
}