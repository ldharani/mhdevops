global class autoCompleteControllerInventory
{
    //public String countryName {get;set;}
    
    @RemoteAction @ReadOnly
    global static List<AggregateResult> findSObjects(string param, string fieldtoget,string countryName, string state, string city) 
    {
        system.debug('countryName Here : '+countryName);
        system.debug('@@@@fieldtoget : '+fieldtoget);
        system.debug('@@@@state: '+state);
        system.debug('@@@@city: '+city);
        String flag = 'Yes';
        
        String filterClause = '';
        if(countryName != null && countryName != 'Test' && countryName != ''){
            filterClause += ' and CountryName__c=:countryName and Country_Inv_Flag__c=: flag';
        }
        if(state != null && state != 'Test' && state != ''){
            filterClause += ' and State_Abbrevation__c=:state and State_Inv_Flag__c=: flag';
        }
        /*if(fieldtoget == 'County_Name__c'){
            filterClause += ' and County_Name__c=: flag';
        }*/
        //if(city != null && city != 'Test' && city != ''){
        if(fieldtoget == 'City_Name__c'){
            //filterClause += ' and City_Name__c=:city and City_Inv_Flag__c=: flag';
            filterClause += ' and City_Inv_Flag__c=: flag';
        }
        String MhRecordType = 'M_H_GEO_Locations';
        //List<aggregateResult> result = Database.query('SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \'%'+param+'%\' ' +filterClause+ ' AND RecordType.DeveloperName=: MhRecordType   Group by '+ fieldtoget);
        //system.debug('@@@@ result'+ result);
        return Database.query('SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \''+String.escapeSingleQuotes(param)+'%\' '+filterClause + ' AND RecordType.DeveloperName=: MhRecordType Group by '+ fieldtoget + ' order by '+fieldtoget +' ASC');
        
       
   }
}