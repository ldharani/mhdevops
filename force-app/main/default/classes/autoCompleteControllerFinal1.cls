global class autoCompleteControllerFinal1
{
    //public String countryName {get;set;}
    
    @RemoteAction @ReadOnly
    global static List<AggregateResult> findSObjects(string param, string fieldtoget,string countryName, string state, string county, string city, string chargeName) 
    {
        system.debug('countryName Here : '+countryName);
        system.debug('@@@@fieldtoget : '+fieldtoget);
        
        system.debug('@@@county value'+county);
        system.debug('@@@fieldtoget value'+fieldtoget);
        
      
        
        String filterClause = '';
        string picklistvalue = 'Yes';
        
      /*  if(fieldtoget == 'CountryName__c'){
            filterClause += ' and Country_Inv_Flag__c=:picklistvalue ';
        }
        else if(fieldtoget == 'State_Abbrevation__c'){
            filterClause += ' and State_Inv_Flag__c=:picklistvalue ';
        }
        else if(fieldtoget == 'County_Name__c'){
            filterClause += ' and County_Inv_Flag__c=:picklistvalue ';
        }
        else if(fieldtoget == 'City_Name__c'){
            filterClause += ' and City_Inv_Flag__c=:picklistvalue ';
        }*/
        
        if(Inventoried_Products_list__c.getValues(chargeName.split(' -')[0]).Type__c == 'Country'){
            filterClause += ' and Country_Inv_Flag__c=:picklistvalue ';
        }
        
        else if(Inventoried_Products_list__c.getValues(chargeName.split(' -')[0]).Type__c == 'State'){
            filterClause += ' and State_Inv_Flag__c=:picklistvalue ';
        }
        else if(Inventoried_Products_list__c.getValues(chargeName.split(' -')[0]).Type__c == 'City'){
            filterClause += ' and City_Inv_Flag__c=:picklistvalue ';
        }
        else if(Inventoried_Products_list__c.getValues(chargeName.split(' -')[0]).Type__c == 'County'){
            filterClause += ' and County_Inv_Flag__c=:picklistvalue ';
        }
        
        
        //county value check
          if(county == 'Independent City' && fieldtoget == 'City'){
            filterClause += ' and County_Name__c = \'Independent City\'';
        }
        else if(county != 'Independent City' && fieldtoget == 'City'){
             filterClause += 'and County_Name__c != \'Independent City\'';
        }
        
        
        if(countryName != null && countryName != 'Test' && countryName != ''){
            filterClause += ' and CountryName__c=:countryName ';
        }
        if(state != null && state != 'Test' && state != ''){
            filterClause += ' and State_Abbrevation__c=:state';
        }
        if(county != null && county != 'Test' && county != ''){
            filterClause += ' and County_Name__c=:county';
        }
        if((city != null && city != 'Test' && city != '') || (city != null && city != 'Test' && city != ''&& county == 'Independent City')){
            filterClause += ' and City_Name__c=:city';
        }
        
        system.debug('@@@@@filterClause'+filterClause);
        String MhRecordType = 'M_H_GEO_Locations';
        //List<aggregateResult> result = Database.query('SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \'%'+param+'%\' '+filterClause + ' AND RecordType.DeveloperName=: MhRecordType Group by '+ fieldtoget);
        //system.debug('@@@@ result'+ result);
        return Database.query('SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \'' +String.escapeSingleQuotes(param)+'%\' '+filterClause + ' AND RecordType.DeveloperName=: MhRecordType Group by '+ fieldtoget);
        
        
   }
}