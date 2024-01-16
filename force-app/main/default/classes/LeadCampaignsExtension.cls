public class LeadCampaignsExtension {
    
    public List<CampaignMember> campaignList{get;set;}
    
    public LeadCampaignsExtension(ApexPages.StandardController controller){
        campaignList = new List<CampaignMember>();
        string businessUnit='';
        Lead l = [select id, RecordType.DeveloperName From Lead
                             where id=:apexPages.currentPage().getparameters().get('id')];
        //Mapping Business Unit here
        if(l != NULL){
            if(l.RecordType.DeveloperName == 'MDL_Leads'){
                businessUnit = 'JV';
             }
            else if(l.RecordType.DeveloperName == 'Nolo_Leads'){
                businessUnit = 'Martindale-Hubbell';
             }
            else if(l.RecordType.DeveloperName == 'M_N_Leads'){
                businessUnit = 'Martindale-Nolo';
             }
            else if(l.RecordType.DeveloperName == 'M_NG_Leads'){
                businessUnit = 'Martindale-Ngage';
             }
            
            campaignList = [select id,CampaignId, Campaign.StartDate, Campaign.Type,
                                    Status,Campaign.Name,HasResponded
                                  From CampaignMember
                                   where LeadId =: l.id AND Campaign.Busineess_Unit__c =:businessUnit];
            
        }
        
    }

}