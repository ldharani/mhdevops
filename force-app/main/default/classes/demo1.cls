public class demo1 {
    public Map<Integer,List<blng__PaymentMethod__c > > mapOfEmails = new  Map<Integer,List<blng__PaymentMethod__c > >();
    public EmailTemplate emailTemplateFor15Days = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Card Expiry Notification Email template for 15 days'];
    public EmailTemplate emailTemplateFor30Days = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Card Expiry Notification Email template for 30 days'];
	public EmailTemplate emailTemplateFor45Days = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Card Expiry Notification Email template for 45 days'];
	public Map<Id,String > accNames = new  Map<Id,String >();
	public List<string> accNamesList = new  List<string>();
    Map<String,Id> contactWithAccount = new Map<String,Id>();
    
    
    public void testBatch(){
	String query = 'SELECT Id,blng__BillingEmail__c,blng__Nameoncard__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,Account_MH_Customer_Number__c,Account_Name__c FROM blng__PaymentMethod__c';
    List<blng__PaymentMethod__c > scope = [SELECT Id,blng__BillingEmail__c,blng__Nameoncard__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,Account_MH_Customer_Number__c,Account_Name__c,blng__CardNumber__c FROM blng__PaymentMethod__c where name='PM-14511' ];
        mapOfEmails.put(15,new List<blng__PaymentMethod__c >());
        mapOfEmails.put(30,new List<blng__PaymentMethod__c >());
        mapOfEmails.put(45,new List<blng__PaymentMethod__c >());
        System.debug('pmlist'+scope);
        for(blng__PaymentMethod__c pm:scope)
        {
            
            if(pm.blng__CardExpirationYear__c!=null && pm.blng__CardExpirationMonth__c!=null){
            Date dueDate = Date.newInstance(Integer.valueOf(pm.blng__CardExpirationYear__c), Integer.valueOf(pm.blng__CardExpirationMonth__c), 1);
            Integer numberDaysDue = System.Today().daysBetween(dueDate);
            
            if(numberDaysDue==-4)
            {
                System.debug('DAYS <=0 '+numberDaysDue+' pmemail '+pm.blng__BillingEmail__c);
                mapOfEmails.get(15).add(pm);
                mapOfEmails.put(15,mapOfEmails.get(15));
                accNames.put(pm.id,pm.Account_Name__c);
            	accNamesList.add(pm.Account_Name__c);
            }
            else if(numberDaysDue==30)
            {
                System.debug('DAYS =30 '+numberDaysDue+' pmemail '+pm.blng__BillingEmail__c);
                mapOfEmails.get(30).add(pm);
                mapOfEmails.put(30,mapOfEmails.get(30));
                accNames.put(pm.id,pm.Account_Name__c);
            	accNamesList.add(pm.Account_Name__c);
            }
            else if(numberDaysDue==45)
            {
                System.debug('DAYS =45'+numberDaysDue+' pmemail '+pm.blng__BillingEmail__c);
                mapOfEmails.get(45).add(pm);
                mapOfEmails.put(45,mapOfEmails.get(45));
                accNames.put(pm.id,pm.Account_Name__c);
            	accNamesList.add(pm.Account_Name__c);
            }
            }
        }
        Map<Id,Contact> contactIds = new Map<Id,Contact>([select Account_Name__c,Id from Contact Where Account_Name__c in :accNamesList]);
        for(Id id:contactIds.keySet())
        {
            contactWithAccount.put(contactIds.get(id).Account_Name__c,id);
        }
        System.debug('contactWithAccount'+contactWithAccount);
        
        ///////////////////////////
        //System.debug('MAPS FROM BATCH JOB'+mapOfEmails);
      //  List<Contact> contactIds = [select Id from Contact Where Account_Name__c in :accNamesList];
        
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
       
		for(Integer key: mapOfEmails.keySet()){
    		 for(blng__PaymentMethod__c pm:mapOfEmails.get(key))
            {
               {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      			List<String> sendTo = new List<String>();
      			sendTo.add(pm.blng__BillingEmail__c);
      			mail.setToAddresses(sendTo);
            	mail.setSenderDisplayName('Internet Brands'); 
      			mail.setSubject('Credit Card Expiration Notice - '+pm.Account_MH_Customer_Number__c+' '+pm.Account_Name__c);
	  			//UserInfo.getUserId()
              //  mail.setTargetObjectId(contactWithAccount.get(pm.Account_Name__c)); 
                   Integer k = 15;
                if(key==15)  k=15;
            	//mail.setTemplateID(emailTemplateFor15Days.Id); 
                else if(key==30) k=30;
                //mail.setTemplateID(emailTemplateFor30Days.Id); 
                else k=45;
                //mail.setTemplateID(emailTemplateFor45Days.Id); 
                String body = 'Dear Valued Customer, <br></br>';
      body += 'The Credit Card on file for Auto Payment for '+pm.Account_Name__c+' will expire in '+k+' days.<br></br>';
      body += 'Credit Card: '+pm.blng__CardNumber__c+'<br></br>';
      body += 'Please contact Customer Support at 800-526-4902 option 2 for assistance.<br></br>';
      body += 'Sincerely, <br></br>';
      body += 'Martindale-Hubbell Customer Support. <br></br>';
      mail.setHtmlBody(body);
               
                
				//mail.setBccSender(false); 
            	//mail.setUseSignature(false); 
            	//mail.setSaveAsActivity(false); 
     			mails.add(mail);
                   System.debug(mail+'mail');
                }
            }
		}
       
      List<Messaging.SendEmailResult> results =  Messaging.sendEmail(mails);

    }
}