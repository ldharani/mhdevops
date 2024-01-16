public with sharing class CommonUtilClass {
    public CommonUtilClass(){
        
    }
    
    public static invoiceit_s__Invoice_RunScheduler__c getinvoiceRunScheduler(string invoiceRunSchedulerId) {
        invoiceit_s__Invoice_RunScheduler__c invoiceRunScheduler;
        string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields('invoiceit_s__Invoice_RunScheduler__c')            
            + ' FROM invoiceit_s__Invoice_RunScheduler__c '
            + ' WHERE Id =' + '\'' + invoiceRunSchedulerId + '\'';
        sQuery = String.escapeSingleQuotes(sQuery);
        sQuery = sQuery.replace('\\','');
        invoiceRunScheduler = Database.query(sQuery);
        return invoiceRunScheduler;
    }
    
    //This method returns a select query string that contains all the standard fields of the object
    public static String getObjectSelectQuery(String objectName) {
        String sQuery = 'SELECT ';
        sQuery += getObjectFields(objectName);
        sQuery += ' FROM '+ objectName + ' ';
        return sQuery;
    }
    
    //This method returns a comma seperated string of all the standard fields of the object
    public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            //system.debug('column Name is ' + column + 'column permission' + column.getDescribe().isUpdateable());
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
    }
    
    public static String convertListOfIdsIntoString(List<Id> ids) {
        String idString = '';
        for(Id id : ids) {
            idString = idString + '\'' + id + '\',';
        }
        if(idString != null && idString.length() > 0){
            idString = idString.substring(0, idString.length()-1);
        }
        
        return idString;
    }
    
    public static Boolean IsWeekendDay(Date dateParam)
    {
        boolean result = false;
        //Recover the day of the week
        Date startOfWeek = dateParam.toStartOfWeek();
        Integer dayOfWeek = startOfWeek.daysBetween(dateParam);
        result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
        return result;
    }
    
    public static Boolean IsWeekendDay(Date dateParam, set<date> hday)
    {
        boolean result = false;
        //Recover the day of the week
        Date startOfWeek = dateParam.toStartOfWeek();
        Integer dayOfWeek = startOfWeek.daysBetween(dateParam);
        result = dayOfWeek == 0 || dayOfWeek == 6 || hday.contains(dateParam) ? true : false;
        return result;
    }
    
    public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd, set<date> hday)
    {
        //Add or decrease in BusinessDaysToAdd days 
        Date finalDate = StartDate;
        system.debug('finaldate = '+finalDate);
        integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
        system.debug('direction = '+direction);
        while(BusinessDaysToAdd != 0)
        {
            finalDate = finalDate.AddDays(direction);
            system.debug('BusinessDaysToAdd = '+BusinessDaysToAdd);            
            system.debug('finaldate = '+finalDate);
            if (!isWeekendDay(finalDate, hday))
            {
                BusinessDaysToAdd -= direction;                
            }
        }        
        return finalDate;
    }    
    
    public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd )
    {
        //Add or decrease in BusinessDaysToAdd days 
        Date finalDate = StartDate;
        system.debug('finaldate = '+finalDate);
        integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
        system.debug('direction = '+direction);
        while(BusinessDaysToAdd != 0)
        {
            finalDate = finalDate.AddDays(direction);
            system.debug('BusinessDaysToAdd = '+BusinessDaysToAdd);            
            system.debug('finaldate = '+finalDate);
            if (!isWeekendDay(finalDate))
            {
                BusinessDaysToAdd -= direction;
                
            }
        }        
        return finalDate;
    }    
}