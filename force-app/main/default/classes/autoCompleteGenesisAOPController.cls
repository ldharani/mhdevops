global class autoCompleteGenesisAOPController {
    
     @RemoteAction @ReadOnly
    global static List<AggregateResult> findSObjects(string param, string fieldtoget,string chargeName) 
    {
        String MhRecordType = 'Genesis_AOP_List';
        //string soql = 'SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \'%'+param+'%\' AND includes('+chargeName+') AND RecordType.DeveloperName=: MhRecordType Group by '+ fieldtoget;
        //system.debug('@@@@@ soql'+ soql);
        return Database.query('SELECT '+fieldtoget+' FROM GEO_Location__c WHERE '+fieldtoget+' LIKE \''+String.escapeSingleQuotes(param)+'%\' AND RecordType.DeveloperName=: MhRecordType Group by '+ fieldtoget);
    }

}