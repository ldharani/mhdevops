@isTest(seeAllData = true)
public class LeadCampaignsExtensionTest {

    static testmethod void testMHLeadDuplication(){

        MDL_UtilClass_TestClass utilClass = new MDL_UtilClass_TestClass();
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTest_AddressDetails_Avalara2());
        //creating lead
         Campaign camp = new Campaign();
        
        camp.Name = 'TestCamp';
        camp.Busineess_Unit__c = 'Martindale-Hubbell';
        insert camp;
        
        Campaign camp2 = new Campaign();
        
        camp2.Name = 'TestCamp';
        camp2.Busineess_Unit__c = 'Martindale-Ngage';
        insert camp2;
        
        Campaign camp3 = new Campaign();
        
        camp3.Name = 'TestCamp';
        camp3.Busineess_Unit__c = 'Martindale-Nolo';
        insert camp3;
        
        
        String jvLeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-H lead').getRecordTypeId();
        String NoloLeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-N Leads').getRecordTypeId();
        String NGLeadRectypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId();
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        Email = 'testabc@gmail.com',
                        RecordTypeId = jvLeadRectypeId,
                        LeadSource = 'Web',  
                        Status = 'Qualified');
        
        Insert newLead;
        String leadId = newLead.Id; 
        
        Lead newLead2 = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        Email = 'testabc@gmail.com',
                        RecordTypeId = NoloLeadRectypeId,
                        MN_Lead_Source__c = 'Attorneys.com',  
                        Status = 'Qualified');
        
        Insert newLead2;
        String leadId2 = newLead2.Id; 
        
        Lead newLead3 = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead3',
                        Email = 'testabc@gmail.com',
                        RecordTypeId = NGLeadRectypeId,
                        LeadSource = 'Web',  
                        Status = 'Qualified');
        
        Insert newLead3;
        String leadId3 = newLead3.Id; 
        
        
       /* List<CampaignMember> testCampMemb1 = new List<CampaignMember>();
        
        testCampMemb1.add(new CampaignMember(LeadId =newLead.Id , CampaignId = camp.id, Status = 'Sent'));
            
            insert testCampMemb1; */
        
        //newLead.Campaignid = camp.id;
        //update newLead ;
        
        ApexPages.currentPage().getParameters().put('id',leadId);
        LeadCampaignsExtension ext = new LeadCampaignsExtension(new apexPages.StandardController(newLead));    
        
        
        ApexPages.currentPage().getParameters().put('id',leadId2);
        LeadCampaignsExtension ext1 = new LeadCampaignsExtension(new apexPages.StandardController(newLead2));    
        
        ApexPages.currentPage().getParameters().put('id',leadId3);
        LeadCampaignsExtension ext2 = new LeadCampaignsExtension(new apexPages.StandardController(newLead3));
        
        Test.stopTest();
        
        }
        
}