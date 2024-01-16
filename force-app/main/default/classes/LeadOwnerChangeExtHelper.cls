public class LeadOwnerChangeExtHelper {
    
    public static database.SaveResult updateLeadOwner(Lead l, Boolean sendEmail){
        
        Database.DMLOptions dlo = new database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = sendEmail;
        l.Is_Email_Checked__c =sendEmail;
        Database.SaveResult sr = database.update(l, dlo);
        return sr;
        
    }

}