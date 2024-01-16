@isTest
public class CloneLead_Test {
    
    public Static testmethod void testCase(){
        test.startTest();
        Lead leadRec = new Lead();
        leadRec.Company = 'Test Account';
        leadRec.LastName= 'Test Lead';
        leadRec.Email = 'testmaclaim@gmail.com';
        leadRec.LeadSource = 'Web';
        leadRec.Status = 'Qualified';
        leadRec.Claimed_Date__c = Date.today() - 31;
        leadRec.Claimed_Method__c = 'Admin';
        insert leadRec;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(leadRec);
        CloneLead_AC cloneAcc = new CloneLead_AC(sc);
        cloneAcc.Redirect();
        
        test.stopTest();
    }
}