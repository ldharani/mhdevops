//Author            : sai
//Description       : test class fro STOWDTrigger and STOWDTriggerHandler


@isTest
public class STOWDTriggerHandlerTest {
    
    static testmethod void run2condition(){
        
        //creating a case
        case cs        = new case();
        cs.Status      = 'New';
        cs.Area__c     = 'Billing';
        cs.Origin      = 'Email';
        cs.Subject     = 'Test';
        cs.Description = 'Test';
        insert cs;
        
        //creaing Status & Ownership Duration object data
        STOWD__Status_Ownership_Duration__c stowd = new STOWD__Status_Ownership_Duration__c();
        stowd.STOWD__Parent__c                    = cs.id;
        stowd.STOWD__Status__c                    = 'New';
        stowd.STOWD__From__c                      = date.today();
        stowd.STOWD__Until__c                     = date.today();
        stowd.STOWD__Owner__c                     = userinfo.getName();
        insert stowd;
    }

}