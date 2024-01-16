global class BatchOrderConfirmation implements Database.Batchable<sObject>, Database.AllowsCallouts, database.stateful {

    public integer no_of_emails = 0;
    date qtd;
    set<date> hday = new set<date> ();
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        for(holiday h:[select ActivityDate from holiday])
            hday.add(h.ActivityDate);
        
        qtd  = CommonUtilClass.AddBusinessDays(date.today(), -3, hday);
        if (Test.isRunningTest())
            qtd = date.today();
        
        String Startdate = qtd + 'T00:00:00Z';
        String Enddate = qtd + 'T00:00:00Z';
        Enddate = Enddate.left(10) + ' 23:59:59 ';
        datetime stdt = datetime.valueOf(Startdate);
        datetime enddt = datetime.valueOf(Enddate);
        
//        datetime stdt = datetime.valueOf(Startdate);
//        datetime enddt = datetime.valueOf(Enddate);
//        no_of_emails = 0;
        system.debug('Start Date: ' + stdt + ' End Date: ' + enddt);
        string str = 'select id, name, invoiceit_s__Account__r.MH_Cust_Number__c, invoiceit_s__Start_Date__c, Auth_By_Contact__r.FirstName, Auth_By_Contact__r.LastName, Auth_By_Contact__r.Email, invoiceit_s__Service_End_Date__c, invoiceit_s__Service_Activation_Date__c  from invoiceit_s__Job__c where createdDate >= ' + stdt + ' and createdDate <= ' + enddt + ' and ((Created_From_Order__c = null and Renew_Rebase__c = null) or (Created_From_Order__c != null and Created_From_Order__r.Renew_Rebase__c = \'Renew\')) and invoiceit_s__Status__c not in (\'Cancelled\', \'Expired\') and id in (select invoiceit_s__Order__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Price_Type__c != \'One Time\')';
	    system.debug('Query String: ' + str);
        return Database.getQueryLocator('select id, name, invoiceit_s__Account__r.MH_Cust_Number__c, invoiceit_s__Start_Date__c, Auth_By_Contact__r.FirstName, Auth_By_Contact__r.LastName, Auth_By_Contact__r.Email, invoiceit_s__Service_End_Date__c, invoiceit_s__Service_Activation_Date__c  from invoiceit_s__Job__c where createdDate >= :stdt  and createdDate <= :enddt and ((Created_From_Order__c = null and Renew_Rebase__c = null) or (Created_From_Order__c != null and Created_From_Order__r.Renew_Rebase__c = \'Renew\')) and invoiceit_s__Status__c not in (\'Cancelled\', \'Expired\') and id in (select invoiceit_s__Order__c from invoiceit_s__Job_Rate_Plan_Charge__c where invoiceit_s__Price_Type__c != \'One Time\')');
    }
    
    global void execute(Database.BatchableContext BC, list<invoiceit_s__Job__c> ord)
    {
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        list<task> tl = new list<task>();
        id userid = [select id from user where name = 'System Administrator'].id;
        String EmailBody = 'Dear Valued Customer \r\n\r\nThank you for your recent Martindale-Hubbell order!';
        EmailBody += '\r\n\r\nCustomer Number: {0} \r\nOrder Number: {1}\r\n\r\n';
        EmailBody += 'To View your active order details on-line, please login in to the Client Service Center at csc.lawyers.com and click on the “My Orders” icon in “My Toolbox”.\r\n \r\n';
        EmailBody += 'For questions about your account or order, please contact our Customer Support Department at 800-526-4902 from 8:30 a.m. to 7:00 p.m. EST, or email info@martindale.com.';
        EmailBody += '\r\n\r\nSincerely,\r\nYour Martindale-Hubbell Customer Support Team';
        for (invoiceit_s__Job__c o : ord )
        {
             if (o.invoiceit_s__Service_End_Date__c == null || o.invoiceit_s__Service_End_Date__c > o.invoiceit_s__Service_Activation_Date__c )                 
             {
                no_of_emails++;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] arguments = new String[] {o.invoiceit_s__Account__r.MH_Cust_Number__c, o.name};
                String EBody = String.format(EmailBody, arguments);
                String[] toAddresses = new String[]{};
                task t = new task();
                t.Subject = 'Email - Outbound';
                t.Description = 'Email sent for order: ' + o.name;
                t.Status = 'Completed';
                t.OwnerId= userid;
                t.WhoId = o.Auth_By_Contact__c;
                t.WhatId = o.id;
                tl.add(t);
                toAddresses.add(o.Auth_By_Contact__r.Email);                
                mail.setToAddresses(ToAddresses) ;  
                mail.setSubject('Martindale-Hubbell Order Confirmation');
                mail.setPlainTextBody(EBody);
                msgListToBeSend.add(mail);
             }
            
        }
        system.debug(' No of records: ' + msgListToBeSend.size() + 'Email List' + msgListToBeSend );
        if(!msgListToBeSend.isEmpty() && !Test.isRunningTest() && ! CommonUtilClass.IsWeekendDay(date.today(), hday))
        {
              Messaging.sendEmail(msgListToBeSend);
        }

        try 
        {
        if(!tl.isEmpty() && !CommonUtilClass.IsWeekendDay(date.today(), hday) )
        {
             system.debug('Entered the if empty for the task');
             insert tl;
        }        
        else{
           system.debug('Error entered the else condition of  task');
        }
        }
        catch (exception e)
        {
            system.debug('Error in insert of task: ' + e.getMessage());
        }

    }        

    global void finish(Database.BatchableContext BC) {
/*        Create_Delete_Attachments_process__c create_del_attach = Create_Delete_Attachments_process__c.getValues('Create Attachments');
        String emailAddressString = create_del_attach.Emails_For_Attachment_Process__c;
        List<String> sendTo = new List<String>();   
        List<String> toEmailAddress = new List<String>();   
        String sendText='';
        try{
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setSubject( 'Email Sent to Customers ' );      
            mail.setToAddresses(toEmailAddress);
            String body = no_of_emails + ' emails sent to customer.';
            
            mail.setHtmlBody(body);
            mails.add(mail);
            Messaging.sendEmail(mails);
        }
        catch(Exception e){
            System.debug('An exception occured' + e.getMessage());
        }        
*/     
    }
   
}