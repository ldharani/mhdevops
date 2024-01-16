public class Avvo_Conversica_Process {
    
	public static void  populateAfterHotlead(List<Lead> leads,Map<Id,Lead> oldMap)
    {
        List<Task> tasklist = new List<Task>();
        List<CampaignMember> campList = new List<CampaignMember>();
		List<Id> leadIds = new List<Id>();
        Campaign camp;
        try
            {
    			camp = [SELECT Id,name FROM Campaign WHERE name='Avvo - Conversica Hot Lead'];
   			}
        catch(Exception e){System.debug('Exception Occurred! '+e.getMessage());}
        
        for(Lead ld:leads)
        {
          	if(ld.Active_AI_Campaign__c==true  && ld.Avvo_AI_Sales_Assistant__c=='Blaire Carson (Acquisition)' 
              && ld.Avvo_AI_Sales_Assistant_Hot_Lead__c==true && oldMap.get(ld.id).Avvo_AI_Sales_Assistant_Hot_Lead__c!=true
              && (ld.Record_Type_Name__c=='M-A Unclaimed Leads' || ld.Record_Type_Name__c =='M-A Claimed Leads') )  
            {        
                Task t = new Task(OwnerId='0052I00000ECgxCQAT', Priority='High', Status='Open',Description='Our AI Sales Assistant, Blaire Carson, has identified this contact as being interested in Avvo products. Please reach out to them ASAP',
                 RecordTypeId='0122I0000016O4h',Subject='Avvo Acquisition AI Sales Assistant HOT LEAD',WhoId=ld.ID,
                 ActivityDate=system.today().adddays(2));
            tasklist.add(t);
                
                if(camp!=null){  
                	CampaignMember Cap = new CampaignMember();
                	Cap.leadId = ld.Id;
                	Cap.CampaignId = camp.Id;   
                	campList.add(Cap);
                }
                leadIds.add(ld.id);
            }
        }
        
        List<CampaignMember> alreadyMemberCampaignList = [select id from CampaignMember where leadId in :leadIds ];
        if(!tasklist.isEmpty())
        {
            insert tasklist;
        }
        
        if(!campList.isEmpty() && alreadyMemberCampaignList.isEmpty())
        {
            insert campList;
        }
        System.debug('tasklist,camplist'+tasklist);
        System.debug('tasklist,camplist'+campList);
    }

}