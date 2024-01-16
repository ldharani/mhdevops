global class autoCompleteAOPController {
    
     @RemoteAction @ReadOnly
    global static List<AggregateResult> findSObjects(string param, string fieldtoget,string chargeName) 
    {
        string soql = 'SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \'%'+param+'%\' AND includes('+chargeName+') Group by '+ fieldtoget;
        system.debug('@@@@@ soql'+ soql);
        return Database.query('SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \''+param+'%\' AND AOP_List_value__c includes('+'\''+chargeName+'\''+') Group by '+ fieldtoget);
    }

}