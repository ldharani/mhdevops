/*
**************************************************************************************************************************************************************
ModifiedBy        Date          JIRA No.      Requested By      Description                                                Tag                                  
**************************************************************************************************************************************************************
Lakshmi      02/16/2023         MHBS-8373     John             Update null check on Task Subject                           T01
*/
public class OutreachJSON {
    
    public static void outreachmsg(Map<Id,Task> newMapTask,Map<Id,Task> oldMapTask){
        String leadName;
        String leadEmail;
        String leadReferenceId;
        Id leadRecId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-NG Leads').getRecordTypeId();
        Set<Id> leadIds = new Set<Id>();
        
        for(Task tRec : newMapTask.values()){
            String SubName = newMapTask.get(tRec.Id).Subject;
            if(!String.isEmpty(SubName)){ //<T01>
                String SubNameCaps = SubName.toUpperCase(); 
                Boolean resultA= SubNameCaps.contains('HOW IS NGAGE DOING');
                if(newMapTask.get(tRec.Id).Replied_At__c != Null && newMapTask.get(tRec.Id).Replied_At__c != oldMapTask.get(tRec.Id).Replied_At__c && resultA == True){
                    System.debug('AAAAAAAAAAAAAA');
                    leadIds.add(tRec.WhoId);
                }
            }
        }
        
        for(Lead leadRec: [SELECT Id,Name,RecordTypeId,Email,Current_Sequence_Name__c,Current_Sequence_Step_Number__c FROM Lead WHERE Id IN: leadIds AND RecordTypeId =: leadRecId]){
            String SeqName = leadRec.Current_Sequence_Name__c;
            String SeqNameCaps = SeqName.toUpperCase();
            Boolean result= SeqNameCaps.contains('NEW CLIENT');
            if( result == True && leadRec.Current_Sequence_Step_Number__c == 4){
                leadName = leadRec.Name;
                leadEmail = leadRec.Email;
                leadReferenceId = leadRec.Id;
            } 
        }
        if(leadReferenceId != Null){
            JSON2Apex Msgjson = new JSON2Apex();
            Msgjson.recipientName = leadName;
            Msgjson.recipientEmail = leadEmail;
            Msgjson.referenceId = leadReferenceId ;
            
            String str = JSON.serialize(Msgjson);
            String requestbodyX = '<script type="application/json+trustpilot">'+ '\n' + str + '\n'+ '</script>';
            System.debug('requestbodyX-->' + requestbodyX);   
            
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = System.Label.OutreachEmail.split(', ');
            message.subject = 'Trustpilot Invitation';
            message.plainTextBody = requestbodyX;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }
    public class JSON2Apex {
        
        public String recipientName;
        public String recipientEmail;
        public String referenceId;
        
    }
}