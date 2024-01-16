global class autoCompleteControllerFinal
{
    //public String countryName {get;set;}
    
    @RemoteAction @ReadOnly
    global static List<AggregateResult> findSObjects(string param, string fieldtoget,string countryName, string state, string city) 
    {
        system.debug('countryName Here : '+countryName);
        system.debug('@@@@fieldtoget : '+fieldtoget);
        
        
        String filterClause = '';
        if(countryName != null && countryName != 'Test' && countryName != ''){
            filterClause += ' and CountryName__c=:countryName';
        }
        if(state != null && state != 'Test' && state != ''){
            filterClause += ' and State_Abbrevation__c=:state';
        }
      /*  if(county != null && county != 'Test' && county != ''){
            filterClause += ' and County_Name__c=:county';
        }*/
        if(city != null && city != 'Test' && city != ''){
            filterClause += ' and City_Name__c=:city';
        }
        String MhRecordType = 'M_H_GEO_Locations';
        //List<aggregateResult> result = Database.query('SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \'%'+param+'%\' ' +filterClause+ ' AND RecordType.DeveloperName=: MhRecordType   Group by '+ fieldtoget);
        //system.debug('@@@@ result'+ result);
        return Database.query('SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \''+String.escapeSingleQuotes(param)+'%\' '+filterClause + ' AND RecordType.DeveloperName=: MhRecordType Group by '+ fieldtoget + ' order by '+fieldtoget +' ASC');
        
       
   }
}