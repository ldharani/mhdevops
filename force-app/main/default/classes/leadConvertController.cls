/***********************************************************************************************************************
 * @author - 
 * @date - 
 * @description - This is the controller for the Visual Force page leadConvertPage.
 * @testclass - 

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6341    VR            26/05/2022                   T01     Avalara Address Validation
MHBS-9018    Bharath       06/07/2023                   T02     Sales Reps moving contacts to different accounts
************************************************************************************************************************/

public with sharing class leadConvertController extends PageControllerBase { 
    Public Static Boolean ValidationFire = True;
    public static List<string> profiles_to_bypass_validation = new List<String>{'System Administrator','System Integration','Data Governor'}; //<T02>
    public final string current_user_profile; //<T02>
    // This is the lead that is to be converted
    public  Lead leadToConvert {get; set;}
    
    // Constructor for this controller
    public leadConvertController(ApexPages.StandardController stdController) {
        
        current_user_profile = [select Name from profile where id =: userinfo.getProfileId()].Name; // <T02>
        System.debug('@@@@current_user_profile'+current_user_profile);
        //get the ID to query for the Lead fields
        Id leadId = stdController.getId();
        
        leadToConvert = [SELECT Id, Status,Description,FirstName,Contact_Email__c,Email, MiddleName, LastName,Claimed_Method__c, OwnerId, Name, RecordTypeId, Company,Professional_ID__c,Email_3__c,Email_2__c,
                        Avvo_com_Email__c,Avvo_com_Rating_Text__c,DoNotCall,Delete_Indicator__c ,Phone, Phone_2__c, Phone_3__c,Practice_Status__c ,  
                        Ad_Region_ID__c,Ad_Region_Name__c,LeadSource,Title ,Address,Avvo_Rating__c,City_2__c,City_3__c,Address_3__c,Address_2__c,Salutation,
                                          MobilePhone,Claimed_Date__c,Client_Review_Rating__c,Client_Reviews_All_Time__c,
                                          Client_Reviews_Calendar_Month__c, County_1__c, County_2__c, County_3__c,Website,
                                          Guides_All_Time__c, Guides_Calendar_Month__c, Headshot_URL__c, 
                                          Last_Login_Date__c, License_State_1__c, License_State_2__c,License_State_3__c,                                       
                                          Peer_Endorsements_Received_All_Time__c, Peer_Endorsements_Received_Calendar_Mon__c,
                                          Practice_Area_1__c, Practice_Area_2__c, Practice_Area_3__c, Practice_Area_4__c, Practice_Area_5__c, Practice_Indicator__c,
                                          Professional_Type__c, Profile_URL__c, Questions_Answered_All_Time__c,Questions_Answered_Calendar_Month__c,
                                          State_2__c, State_3__c, State_ID__c, Zip_Postal_Code_2__c, Zip_Postal_Code_3__c,Subscription_Welcome__c,
                                          Subscription_Webinar__c, Subscription_Newsletter__c, Subscription_Feedback__c, Subscription_Conference__c, Subscription_Announcement__c,
                                          Subscription_Advertising__c,Contact_Name__c,New_Claim__c,SF_State__c, Q_A_Subscriptions__c, 
                                          Opt_Out_URL_Advertising__c,Opt_Out_URL_Announcement__c, Opt_Out_URL_Conference__c, Opt_Out_URL_Feedback__c,
                                          Opt_Out_URL_Newsletter__c, Opt_Out_URL_Webinar__c, Opt_Out_URL_Welcome__c, Lead_Conversion_Website__c,Last_Profile_Update__c,
                                          Do_Not_Call_Date_Time__c,Assistant_Title__c, Assistant_Phone__c, Assistant_Name__c,Assistant_Email__c,Goes_By_Name__c,
                                          pi__Needs_Score_Synced__c, Address_Street_Line_2__c , //T01
                                          city, street, state, country, postalcode,License_Date__c,RecordType.DeveloperName,Date_Added_to_Avvo_Marketing_Campaign__c,
                                          Campaign_ID__c,Avvo_Lead_Source__c,Avvo_Account_Record_Type_Name__c,OrgID__c
                         FROM Lead WHERE Id = :leadId];
    }

    /*
    These are instances of the components' controllers which this class will access.
    
    If you add new custom components, add an instance of the class here
    */
    public leadConvertCoreComponentController myComponentController { get; set; }
    public leadConvertTaskInfoComponentController myTaskComponentController { get; set; }
    public leadConvertTaskDescComponentController myDescriptionComponentController { get; set; }
    
    /*
        These are the set methods which override the methods in PageControllerBase. 
        These methods will be called by the ComponentControllerBase class.
        
        If you add new custom components, a new overridden set method must be added here.
    */
    public override void setComponentController(ComponentControllerBase compController) {
        
        myComponentController = (leadConvertCoreComponentController)compController;
    
    }
   
    public override void setTaskComponentController(ComponentControllerBase compController) {
    
        myTaskComponentController = (leadConvertTaskInfoComponentController)compController;
    
    }
  
    public override void setDescriptionComponentController(ComponentControllerBase compController) {
    
        myDescriptionComponentController = (leadConvertTaskDescComponentController)compController;
    
    } 

    /*
        These are the get methods which override the methods in PageControllerBase.
        
        If you add new custom components, a new overridden get method must be added here.
    */
    public override ComponentControllerBase getMyComponentController() {

        return myComponentController;

    }

    public override ComponentControllerBase getmyTaskComponentController() {

        return myTaskComponentController;

    }   
  
    public override ComponentControllerBase getmyDescriptionComponentController() {

        return myDescriptionComponentController;

    }
    
    
    // This method is called when the user clicks the Convert button on the VF Page
    public PageReference convertLead() {
        
        // This is the lead convert object that will convert the lead 
        Database.LeadConvert leadConvert = new database.LeadConvert();
        
        // if a due date is set but the subject is not, then show an error 
        if (myTaskComponentController != null && myTaskComponentController.taskID.ActivityDate != null && string.isBlank(myTaskComponentController.taskID.Subject)){
            
            PrintError('You must enter a Subject if a Due Date is set..');
            return null;
            
        } 
        
        // if Lead Status is not entered show an error  
        if (myComponentController != null && myComponentController.leadConvert.Status == 'NONE'){
            
            PrintError('Please select a Lead Status.');
            return null;
            
        } 

         /*************************************************************************
         * Deleting all Campaign Members which are not belongs to lead business unit 
         * before conversion
         * ********************************************************************/
           LeadDuplicationExtension.deleteCampaignMembers(leadToConvert);
               
        //set lead ID
        leadConvert.setLeadId(leadToConvert.Id); 
        
          
        
        //if the main lead convert component is not set then return
        if (myComponentController == NULL) return null;
        
        //if the Account is not set, then show an error
       // if (myComponentController.selectedAccount == 'NONE')
       // {
       //     PrintError('Please select an Account.');
       //     return null;
            
      //  }
        
        // otherwise set the account id
       // else if (myComponentController != NULL && myComponentController.selectedAccount != 'NEW') {
       //     leadConvert.setAccountId(myComponentController.selectedAccount);
       // }
        
        //set the lead convert status
        leadConvert.setConvertedStatus(myComponentController.leadConvert.Status);
        
        if(leadToConvert.RecordType.DeveloperName== 'M_A_Claimed_Leads' || leadToConvert.RecordType.DeveloperName== 'Martindale_Avvo_Lead'){
            system.debug('In do not opty creation --->');
            leadConvert.setDoNotCreateOpportunity(true);
            
        
        } 
        //set the variable to create or not create an opportunity
        else{
            leadConvert.setDoNotCreateOpportunity(myComponentController.doNotCreateOppty);
            //set the Opportunity name
            leadConvert.setOpportunityName(((myComponentController.doNotCreateOppty) 
            ? null : myComponentController.opportunityID.Name));
        }
        
        
        
        //set the owner id
        leadConvert.setOwnerId(myComponentController.contactId.ownerID);
        
        //set whether to have a notification email
        leadConvert.setSendNotificationEmail(myComponentController.sendOwnerEmail);
        
        system.debug('leadConvert --> ' + leadConvert);
        
        //convert the lead
        //Added this flag to bypass outreach task association
        TaskTriggerHandler.leadcoversionflag = True;
        //System.debug('AAAAAAAAAAA ' + leadToConvert.IsConverted );
        ValidationFire = False;
        Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
            
            String childaccid          = leadConvertResult.getAccountId();
            string contctId            = leadConvertResult.getContactId();
            string oppId               = leadConvertResult.getOpportunityId();
            System.debug('oppId'+oppId);
            System.debug('childaccid'+childaccid);
            System.debug('contctId'+contctId);
            string whereClause              = 'id= :childaccid';
            system.debug('@@@whereClause'+whereClause);
            String soql                     = genericUtilityClass.getCreatableFieldsSOQL('account',whereClause);
            system.debug('@@@@@@@soql' + soql);
            
            List<Account>ParentAccounts     = new List<Account>();
            Account tempAcc                 = (Account)Database.query(soql);
            
            List<Account> ExistingAccWithSameOrgId = [Select Id,Org_Id__c,RecordtypeId from Account where Org_Id__c != null AND Org_Id__c = :tempAcc.Org_Id__c And RecordtypeId =: Schema.SObjectType.account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId()];
            if(ExistingAccWithSameOrgId.size()>0){
                System.debug('ExistingAccWithSameOrgId'+ExistingAccWithSameOrgId);
                tempAcc.ParentId = ExistingAccWithSameOrgId[0].Id;
                update tempAcc;
            }           
            else{
            Account parentAccount           = tempAcc.clone(false, true);
            parentAccount.RecordTypeId      = Schema.SObjectType.account.getRecordTypeInfosByName().get('IB Accounts').getRecordTypeId();
            parentAccount.Business_Unit__c  = 'Internet Brands';
            parentAccount.Legal_Entity__c   = ' M-N Taxable';
            parentAccount.MH_Cust_Number__c = '';
            System.debug('leadToConvert.OrgID__c--->'+leadToConvert.OrgID__c);
            if(leadToConvert.OrgID__c !=null){
                System.debug('Org Id update---->');
               parentAccount.Org_Id__c =  leadToConvert.OrgID__c;
            }
            ParentAccounts.add(parentAccount);     
            //insert parentAccount;
            }  
            
           // Sai : 09-24-2018 : creating avvo Frim Account
            //if(leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_Avvo_Lead ).getRecordTypeId()){
                Account avvoFirmAccount = new Account();
           if(leadToConvert.RecordTypeId!= null && leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Claimed Leads').getRecordTypeId()){
               avvoFirmAccount         = tempAcc.clone(false, true);
               avvoFirmAccount.RecordTypeId        = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
               avvoFirmAccount.MH_Cust_Number__c = '';
               ParentAccounts.add(avvoFirmAccount);
               
           }
           
            if(leadToConvert.RecordTypeId!= null && leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Lead').getRecordTypeId()){
               avvoFirmAccount         = tempAcc.clone(false, true);
               avvoFirmAccount.RecordTypeId        = Schema.SObjectType.account.getRecordTypeInfosByName().get('M-A Firm Account').getRecordTypeId();
               avvoFirmAccount.MH_Cust_Number__c = '';
               ParentAccounts.add(avvoFirmAccount);
               
           }
           
           //}
           insert ParentAccounts;
           String avvoFirmAccountId;

           if(ParentAccounts.size() == 2){
                avvoFirmAccountId = ParentAccounts[1].id;
           }
           
            LeadDuplicationExtension.updateChildAccount(leadToConvert, childaccid, ParentAccounts[0].id, OppId, contctId,avvoFirmAccountId);
            //updating contact
            //<T02> starts
            Deactivate_Customer_Order_Case_Update__c obj = Deactivate_Customer_Order_Case_Update__c.getInstance();
            if(!profiles_to_bypass_validation.contains(current_user_profile)){
                obj.ByPassValidation__c = true;
                upsert obj;
            }
            contact parentcon = new contact(id=contctId, accountId = ParentAccounts[0].id);
            update parentcon;
            if(!profiles_to_bypass_validation.contains(current_user_profile)){
                obj.ByPassValidation__c = false;
                upsert obj;
            }
            //<T02> ends
         // OpportunityContactRole opConRole= new OpportunityContactRole(ContactId=contctId,OpportunityId=oppId,Role='Decision Maker',IsPrimary=true);
         //insert opConRole;
        
        //  update new opportunity(id = oppId, Auth_By_Contact__c= contctId);
           //creating related contact for child account
           
           if(leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Claimed Leads').getRecordTypeId()){
               System.debug('@@@@@Test account contact relation test------->'+childaccid+'------contact'+contctId);
               Account_Contact_Relation__c actnew = new Account_Contact_Relation__c();
               actnew.Account__c   = childaccid;
               actnew.Contact__c   = contctId;
               actnew.Roles__c     = 'Lead/Paying Attorney';
               insert actnew; 
               System.debug('Act contact relationship------->'+actnew);           
           }
           
             if(leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Lead').getRecordTypeId()){
               System.debug('@@@@@Test account contact relation test------->'+childaccid+'------contact'+contctId);
               Account_Contact_Relation__c actnew = new Account_Contact_Relation__c();
               actnew.Account__c   = childaccid;
               actnew.Contact__c   = contctId;
               actnew.Roles__c     = 'Lead/Paying Attorney';
               insert actnew; 
               System.debug('Act contact relationship------->'+actnew);           
           }
           
           //MHMAC-184 Avvo Account Record Type update
        /*if(leadToConvert.RecordTypeId!= null && leadToConvert.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('M-A Lead').getRecordTypeId() && leadToConvert.Avvo_Account_Record_Type_Name__c !=null){
            System.debug('Res leadToConvert.Avvo_Account_Record_Type_Name__c'+leadToConvert.Avvo_Account_Record_Type_Name__c);
            tempAcc.RecordTypeId = leadToConvert.Avvo_Account_Record_Type_Name__c;
               update tempAcc;
            for(Opportunity opp: [Select Id from Opportunity Where Id =:oppId]){
                Sbqq__Quote__c newquote = new Sbqq__Quote__c();
                newquote.SBQQ__Opportunity2__c = opp.Id;
                newquote.RecordTypeId = Schema.SObjectType.Sbqq__Quote__c.getRecordTypeInfosByName().get('M-A Quote').getRecordTypeId();
                insert newquote;
                String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();  
                String targetURL = sfdcBaseURL.replace('-c.','-sbqq.') + '/apex/sbqq__sb?id='+newquote.Id;
                return new PageReference(targetURL);
            }
           }*/
       
        // if the lead converting was a success then create a task
        if (leadConvertResult.success)
        {
            // make sure that the task information component is being used and check to see if the user has filled out the Subject field 
            if(myTaskComponentController != NULL 
                && myDescriptionComponentController != NULL 
                && myTaskComponentController.taskID.subject != null)
            {
                //create a new task
                Task taskToCreate = new Task();
                
                //set whether there is a reminder
                taskToCreate.IsReminderSet = myTaskComponentController.remCon.taskID.IsReminderSet;
                
                //if the reminder is set, and the reminder's date is set
                if (taskToCreate.IsReminderSet 
                    && myTaskComponentController.remCon.taskID.ActivityDate != null) {
                    
                    //set the reminder time based on the reminder class's ActivityDate
                    //The date and time in the reminder class is converted into a datetime by the convertToDatetime() method
                    taskToCreate.ReminderDateTime = 
                        convertToDatetime(
                            myTaskComponentController.remCon.taskID.ActivityDate,
                            myTaskComponentController.remCon.reminderTime
                        );
                    system.debug('taskToCreate.ReminderDateTime --> ' + taskToCreate.ReminderDateTime);
                    
                }   
                
                //set the whatId to the Opportunity Id            
                taskToCreate.WhatId = leadConvertResult.getOpportunityId();
                
                //set the whoId to the contact Id
                taskToCreate.WhoId = leadConvertResult.getContactId();
                
                //set the subject
                taskToCreate.Subject = myTaskComponentController.taskID.Subject;
                
                //set the status
                taskToCreate.Status = myTaskComponentController.taskID.Status;
                
                //set the activity date 
                taskToCreate.ActivityDate = myTaskComponentController.taskID.ActivityDate;
                
                //set the Priority 
                taskToCreate.Priority = myTaskComponentController.taskID.Priority;
                
                //set the custom field Primary Resource (this is a custom field on the Task showing an example of adding custom fields to the page)
                //taskToCreate.Primary_Resource__c = myTaskComponentController.taskID.Primary_Resource__c;
                
                //set the Description field which comes from the leadConvertTaskDescComponent
                taskToCreate.Description =  myDescriptionComponentController.taskID.Description;
                
                taskToCreate.Status = 'Open';

                //if the sendNotificationEmail variable in the leadConvertTaskDescComponent class is set then send an email
                if (myDescriptionComponentController.sendNotificationEmail)
                {
                    //create a new DMLOptions class instance
                    Database.DMLOptions dmlo = new Database.DMLOptions();
                    
                    //set the trigger user email flag to true
                    dmlo.EmailHeader.triggerUserEmail = true;
                    
                    //insert the task
                    database.insert(taskToCreate, dmlo);
                }
                else
                {
                    //if the sendNotificationEmail field was not checked by the user then simply insert the task
                    insert taskToCreate;
                }
            }
            
            LeadDuplicationExtension.deletetasks(leadConvertResult.getAccountId());
            
            // redirect the user to the newly created Account
            PageReference pageRef = new PageReference('/' + leadConvertResult.getAccountId());
            
            pageRef.setRedirect(true);
            
            return pageRef; 
        }
        else
        {

            //if converting was unsucessful, print the errors to the pageMessages and return null
            System.Debug(leadConvertResult.errors);

            PrintErrors(leadConvertResult.errors);
            
            return null;
        }
        ValidationFire = True;
        return null;
    }
    
    //this method will take database errors and print them to teh PageMessages 
    public void PrintErrors(Database.Error[] errors)
    {
        for(Database.Error error : errors)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, error.message);
            ApexPages.addMessage(msg);
        }
    }
    
    //This method will put an error into the PageMessages on the page
    public void PrintError(string error) {
        ApexPages.Message msg = new 
            ApexPages.Message(ApexPages.Severity.ERROR, error);
        ApexPages.addMessage(msg);
    } 
    
    // given a date and time, where time is a string this method will return a DateTime
    private DateTime convertToDatetime(Date d, string t) {
        String timeFormat = DateTimeUtility.LocaleToTimeFormatMap().get(UserInfo.getLocale());
        
        //if the local of the user uses AM/PM 
        if (timeFormat != null && timeFormat.endsWith('a')) {
            
            //split the time into 2 strings 1 time and 1 am r pm
            string [] reminderTime = t.split(' ');
            
            //split the time into hour and minute
            string hour = reminderTime[0].split(':')[0];
            string min = reminderTime[0].split(':')[1];
            
            //get the am or pm
            string AM_PM = reminderTime[1];
            
            //turn the hour into an integer
            integer hr = Integer.valueOf(hour);
            
            //if the am/pm part of the string is PM then add 12 hours
            if (AM_PM.equalsIgnoreCase('PM')) hr += 12;
            
            //return a new DateTime based on the above information
            return (
                DateTime.newInstance(
                    d, 
                    Time.newInstance(
                        hr, 
                        Integer.valueOf(min), 
                        0,
                        0
                    )
                )
            ); 
        }
        //If the user's local does not use AM/PM and uses 24 hour time
        else {
            
            //split the time by a : to get hour and minute
            string hour = t.split(':')[0];
            string min = t.split(':')[1];
            
            //turn the hour into an integer
            integer hr = Integer.valueOf(hour);
            
            //return a new DateTime based on the above information
            return (
                DateTime.newInstance(
                    d, 
                    Time.newInstance(
                        hr, 
                        Integer.valueOf(min), 
                        0,
                        0
                    )
                )
            ); 
        }
    }
}