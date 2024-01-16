global class Avvo_AutoLeadConvert implements Database.Batchable<sObject>, Database.AllowsCallouts{
    global String query;
    List<Lead> LeadList = new List<Lead>();
    //String s = String.valueOf(systemtoday()); 
     global Database.QueryLocator start(Database.BatchableContext BC) {
        
         
         query = 'SELECT Id, Claim_Attribution__c, Claimed_Method__c,Owner.Profile.Name,Avvo_com_Email__c,Name,FirstName,MiddleName,lastName,Email_2__c,Email_3__c,Address_3__c,Avvo_com_Rating_Text__c,Address_2__c, isConverted ,Claimed_Date__c,Email,RecordType.DeveloperName,Status,Professional_ID__c, '+
                 'Client_Review_Rating__c,Client_Reviews_All_Time__c,Contact_Name__c ,Client_Reviews_Calendar_Month__c,County_1__c,County_2__c,County_3__c,Guides_All_Time__c,Guides_Calendar_Month__c,Headshot_URL__c,Last_Login_Date__c,License_State_1__c,'+
                 'License_State_2__c,License_State_3__c,Peer_Endorsements_Received_All_Time__c,Peer_Endorsements_Received_Calendar_Mon__c,Phone_2__c,Phone_3__c,Practice_Area_1__c,Practice_Area_2__c,Practice_Area_3__c,Practice_Area_4__c,Practice_Area_5__c,Practice_Status__c,'+
                 'Professional_Type__c,Profile_URL__c,Questions_Answered_All_Time__c,Questions_Answered_Calendar_Month__c,State_2__c,State_3__c,'+
                 'State_ID__c,Zip_Postal_Code_2__c,Zip_Postal_Code_3__c,Subscription_Welcome__c,Subscription_Webinar__c,Subscription_Newsletter__c,Subscription_Feedback__c,Subscription_Conference__c,Subscription_Announcement__c,Subscription_Advertising__c,Street,City,State,Country,PostalCode,Phone,Q_A_Subscriptions__c,'+
                 'Opt_Out_URL_Advertising__c,Opt_Out_URL_Announcement__c,Lead_Conversion_Website__c,Opt_Out_URL_Conference__c,Opt_Out_URL_Feedback__c,Opt_Out_URL_Newsletter__c,Opt_Out_URL_Webinar__c,Opt_Out_URL_Welcome__c,Last_Profile_Update__c,Do_Not_Call_Date_Time__c,Assistant_Title__c,Assistant_Phone__c,Assistant_Name__c,'+
                 'Assistant_Email__c,Goes_By_Name__c,pi__Needs_Score_Synced__c,'+
                 'OwnerId,Ad_Region_ID__c,Ad_Region_Name__c,Avvo_Rating__c,City_2__c,City_3__c,Delete_Indicator__c, ConvertedDate,New_Claim__c,DoNotCall,Practice_Indicator__c,Campaign_ID__c,Date_Added_to_Avvo_Marketing_Campaign__c,Avvo_Lead_Source__c   FROM Lead '+
                 
                  //' where id=\'00Q5C0000029bfO\'';
            ' WHERE ((RecordType.DeveloperName = \'M_A_Claimed_Leads\' OR RecordType.DeveloperName = \'Martindale_Avvo_Lead\') AND Delete_Indicator__c != \'Deleted\' AND Email != NULL AND Claimed_Date__c < Today AND isConverted = false) ';
          
     
      if(Test.isRunningTest()) {
            query += ' order by CreatedDate DESC LIMIT 5';
         }
         else{
              query += ' ORDER BY Claimed_Date__c ';
         }  
        system.Debug('Query'+query);
        return Database.getQueryLocator(query);
      }
      
      
      global void execute(Database.BatchableContext BC, List<Lead> leadList) {
      
          avvoLeadBatchHandler.filterLeadstoCovert(leadList);
      }
      
        global void finish(Database.BatchableContext BC) {
        
        List<Email_Ids_for_Batch_Process__mdt> emailids= new List<Email_Ids_for_Batch_Process__mdt>();
          emailids = [Select id, DeveloperName, MasterLabel,Email_Ids_for_emailing__c, Link_for_Failure_Report__c,
                       Link_for_Success_Report__c From Email_Ids_for_Batch_Process__mdt Where MasterLabel = 'Avvo Auto Lead conversion'];
        Boolean dontExecute = false;
        String emailAddressString;
        String successReport;
        String failureReport;
        for(AsyncApexJob batch :[Select ExtendedStatus,NumberOfErrors,Status,JobItemsProcessed,TotalJobItems from AsyncApexJob where Id = :BC.getJobId()]){         
            if(batch.JobItemsProcessed > 0){
                dontExecute = false;
            }
            else{
                dontExecute = true;
            }
        }
        if(dontExecute==false){
            for(Email_Ids_for_Batch_Process__mdt emaildetails: emailids){
            
            
            emailAddressString = emaildetails.Email_Ids_for_emailing__c;
            successReport = emaildetails.Link_for_Success_Report__c;
            failureReport = emaildetails.Link_for_Failure_Report__c;
           // String unmatchedReport = autoEvergreen.Link_for_report_with_unmatching_dates__c;
            }
            List<String> sendTo = new List<String>();   
            List<String> toEmailAddress = new List<String>();       
            if(emailAddressString.contains(',')){
                sendTo = emailAddressString.split(',');
                for(String s : sendTo){
                    if(s!='' && s!=null){
                        toEmailAddress.add(s);
                    }
                }
            }
            else{
                toEmailAddress.add(emailAddressString);
            }
            try{
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
                mail.setSubject('Auto Lead Conversion batch report');      
                mail.setToAddresses(toEmailAddress);
                String body = '<html><body>The Auto Lead conversion process has completed running successfully<br><br>'+
                'Click on the following links to view more details regarding the run:<br>';
                if(successReport != '')
                body += '(1) Report for success records : <a href="'+successReport+'">'+successReport+'</a><br>';
                if(failureReport != '')
                body += '(2) Report for failure records : <a href="'+failureReport+'">'+failureReport+'</a><br>';
                           
                body += '</body></html>';
                mail.setHtmlBody(body);
                mails.add(mail);
                Messaging.sendEmail(mails);
            }
            catch(Exception e){
                System.debug('An exception occured' + e.getMessage());
            }
        } 
        
        }
    }