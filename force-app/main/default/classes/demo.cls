public class demo {
    public demo(){}
	public static void  maildemo()
    {
        Account acc = (Account)[select Id from Account Where Name = 'West & Rose' Limit 1];
        //Account_Name__c
        Contact con = (Contact)[select Id,name from Contact Where Account_Name__c = 'West & Rose' Limit 1];
        System.debug('con'+con);
        
        blng__PaymentMethod__c pm = (blng__PaymentMethod__c)[select Id from blng__PaymentMethod__c Where Account_Name__c = 'West & Rose' Limit 1];

		EmailTemplate tpl = (EmailTemplate)[select Id FROM EmailTemplate WHERE Name = 'Card Expiry Notification Email template for 15 days' limit 1];
 
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setTemplateId(tpl.Id);
        	mail.setBccSender(false); 
            	mail.setUseSignature(false); 
            	mail.setSaveAsActivity(false); 
mail.setTargetObjectId(con.Id);
 List<String> sendTo = new List<String>();
      			sendTo.add('vishala.ramasamy@listertechnologies.com');
      			mail.setToAddresses(sendTo);

List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
if (results[0].success) {
System.debug('success');
} else {
System.debug('failure');
}

    }
}