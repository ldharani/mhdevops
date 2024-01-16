public class CloneLead_AC {
    public static String retUrl;
    public static Id leadId;
    
    public CloneLead_AC(ApexPages.StandardController controller) {
        leadId = controller.getId();
        System.debug('XXX ' + leadId);
    }  
    
    public pagereference Redirect(){
        System.debug('YYY ' + leadId);
        if(leadId != Null){
            System.debug('AAA');
            Lead leadRec = [SELECT Id FROM Lead WHERE Id =:leadId LIMIT 1];
            System.debug('BBB ' + leadRec);
            if(leadRec.Id != Null){
                System.debug('CCC'); 
                retUrl = CreateLeadFromLead.createLead(leadRec.Id); 
            }
          //  else{
          //     System.debug('DDD'); 
          //     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'You cannot clone an actively sequenced lead'));
          //   } 
        }
        
        System.debug('EEE ' + retUrl); 
        if(!String.isBlank(retUrl)){
            System.debug('FFF'); 
            PageReference pageRef = new PageReference('/'+retUrl);
            pageRef.setRedirect(true);
            return pageRef;
        }else{
            System.debug('GGG'); 
            return null; 
        }
    }
}