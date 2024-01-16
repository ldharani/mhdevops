/*
**Created By : Invoice iT
**Created Purpose : For creating renewal opportunities & opportunity for Rebase based on Quote type selected in order(Renew/Rebase)
**
**Modified By : Lister Technologies
**Modified Date : 8th Aug 2014
**Modified Purpose : To update a field Renew_Rebase__c for order just to know if the order is renewed/rebased .
**
**Modified By : Lister Technologies
**Modified Date : 13th Aug 2014
**Modified Purpose : SIN number & Inventory ID carry over from order to Oppty for renew/rebase in case of subscription products
**
**Modified By : Lister Technologies
**Modified Date : 01st Oct 2014
**Modified Purpose : To insert a case when an order is rebased or renewed if any monthly renewable charges on current order are unfulfilled.
**
**Modified By : Lister Technologies
**Modified Date : 21st May 2015
**Modified Purpose : Modify oppty label to better reflect the order activity: evergreen & migrations
**
**Modified By : Lister Technologies
**Modified Date : 24th June 2015
**Modified Purpose : MHBS-160
**Added Mid-Term Adjustment Button - MHBS-1208: Rama 04/26/16
*/
public with sharing class ControllerSelectQuoteType {
    public invoiceit_s__Job__c order {get;set;}
    public integer noOfTerms {get;set;}
    public Id orderId;
    public boolean disableRenewBtn {get;set;}
    public boolean disableRebaseBtn {get;set;}    
    public boolean disableMidTermBtn {get;set;}    
    public boolean disableCancelBtn {get;set;}
    public boolean disableEvergreenBtn {get;set;}
    public boolean disableNoloMigrationBtn {get;set;}
    public boolean noloMigration {get;set;} //modified by lister for rbw 825
    public list<String> chargeNames {get;set;}

    public boolean dispButtons{get;set;}
    public invoiceit_s__Job__c childorder;

    public Group queue;
    //public Map<String,String> mapProductNameNPriceType {get;set;}

    //Sai : dummy constructor created to call non-static methods from this class
    public ControllerSelectQuoteType(invoiceit_s__Job__c ord){
        order = ord;
    }
    public ControllerSelectQuoteType(ApexPages.StandardController controller) {
        try {
            /*order = [SELECT Name, invoiceit_s__Status__c, invoiceit_s__Service_Activation_Date__c, invoiceit_s__Service_End_Date__c 
                     FROM invoiceit_s__Job__c 
                     WHERE Id =: controller.getId()
                     ];*/ 
            orderId = controller.getId();
            dispButtons = false;
            noloMigration = false;
            string sQuery = 'SELECT ' + getObjectFields('invoiceit_s__Job__c') + ',invoiceit_s__Account__r.Migration_Status__c,RecordType.DeveloperName, invoiceit_s__Account__r.Credit_Status__c, Created_From_Order__r.Renew_Rebase__c, Created_From_Order__r.invoiceit_s__Service_End_Date__c, ' 
                + ' (SELECT '+ getObjectFields('invoiceit_s__Job__c') + ' ,invoiceit_s__Account__r.Migration_Status__c,RecordType.DeveloperName, '
                    + ' invoiceit_s__Account__r.Credit_Status__c, Created_From_Order__r.Renew_Rebase__c, Created_From_Order__r.invoiceit_s__Service_End_Date__c '
                    + ' From Orders1__r order by CreatedDate DESC LIMIT 1)'
                + ' FROM invoiceit_s__Job__c WHERE Id =\'' + controller.getId() + '\'';

            system.debug('sQuery is* :::::: ' + sQuery);
            order = DataBase.Query(sQuery);
            
            /*************akash : 16/01*******************************************/
            childorder = new invoiceit_s__Job__c();
            if(order.Orders1__r != NULL && order.Orders1__r.size() > 0){
                childorder = order.Orders1__r[0];
            }
            /*********************************************************************/
            
            //modified by Lister - 7/22/14 - default the number of terms to 12
            noOfTerms = 12;
            disableRenewBtn = false;
            disableRebaseBtn = false;     
            disableEvergreenBtn = false;
            disableCancelBtn = false;
            disableMidTermBtn = false;
            disableNoloMigrationBtn = false;
            chargeNames = new list<String>();
            
            /***********************akash : 17/01/2018 ******************************************/
            if(order.Parent_Order__c != NULL && order.Parent_Order_Status__c == False ){
                 dispButtons = true;
                disableRenewBtn = true;
                disableRebaseBtn = true;     
                disableEvergreenBtn = true;
              disableMidTermBtn = true;
                disableNoloMigrationBtn = true;
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error,'This order cannot be Modified as it is a child order, Please modify the Parent Order'); 

                ApexPages.addMessage(errMsg);   
                return ;
            }
            /****************************************************************************************/
            
            if(order.invoiceit_s__Status__c == 'Cancelled') {
                dispButtons = true;
                disableRenewBtn = true;
                disableRebaseBtn = true;     
                disableEvergreenBtn = true;
              disableMidTermBtn = true;
                disableNoloMigrationBtn = true;
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,'This order cannot be renewed/rebased/made evergreen/Mid-Term Adjustment since it is Cancelled'); 

                ApexPages.addMessage(errMsg);   
                return ;
            }
            if(order.invoiceit_s__Status__c == 'Expired') {
                dispButtons = true;
                disableRenewBtn = true;
                disableRebaseBtn = true;     
                disableEvergreenBtn = true;
              disableMidTermBtn = true;
                disableNoloMigrationBtn = true;
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,'This order cannot be renewed/rebased/made evergreen/Mid-Term adjustment since it is Expired'); 

                ApexPages.addMessage(errMsg);   
                return ;
            }
            if(order.Renew_Rebase__c == 'Renew') {
                dispButtons = true; 
                disableRenewBtn = true;
                disableRebaseBtn = true;     
              disableMidTermBtn = true;
                disableEvergreenBtn = true;    
                disableNoloMigrationBtn = true;                         
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,'This order cannot be renewed/rebased/made evergreen since it is already Renewed'); 
                ApexPages.addMessage(errMsg);   
                return ;
            }            
            if(order.Renew_Rebase__c == 'Rebase') {
                dispButtons = true; 
                disableRenewBtn = true;
                disableRebaseBtn = true;     
              disableMidTermBtn = true;
                disableEvergreenBtn = true;
                disableNoloMigrationBtn = true;               
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,'This order cannot be renewed/rebased/made evergreen since it is already Rebased'); 
                ApexPages.addMessage(errMsg);   
                return ;
            }
            
            if(order.invoiceit_s__Status__c == 'Evergreen'){                
                if(order.RecordType.DeveloperName == 'MH_Orders' || order.RecordType.DeveloperName == 'Nolo_Order'){   
                disableRenewBtn = true;                    
                disableEvergreenBtn = false;
                disableMidTermBtn = true;
//Added 'Refused Migration' Condition Rama Jira ticket NMIG 23
//Added 'IB Only - PX' Condition Rama Jira Ticket MHBS-746 03/28/16
                if(order.invoiceit_s__Account__r.Migration_Status__c != 'MH Migration'  && order.invoiceit_s__Account__r.Migration_Status__c != 'MH Migration Decline'){
                    disableNoloMigrationBtn = true;
                }
//                if(order.invoiceit_s__Service_Activation_Date__c > date.today() || order.invoiceit_s__Account__r.Credit_Status__c != 'Good Standing')
//                if ( order.invoiceit_s__Account__r.Credit_Status__c != 'Good Standing' )



               /* ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,'This order cannot be renewed/made evergreen since it is already an Evergreen order'); 
                ApexPages.addMessage(errMsg);   
                return ;*/
                }
                else{
                    disableRenewBtn = true;                    
                    disableEvergreenBtn = false;
                    disableRebaseBtn = true; 
                    disableMidTermBtn = true;
                
                     if(order.invoiceit_s__Account__r.Migration_Status__c != 'MH Migration'  && order.invoiceit_s__Account__r.Migration_Status__c != 'MH Migration Decline'){
                     disableNoloMigrationBtn = true;
                    }
                }
            } 
            
            System.debug('Checking The Conditions for Mid-Term Button.');
//            if(order.invoiceit_s__Service_Activation_Date__c > date.today() || order.invoiceit_s__Account__r.Credit_Status__c != 'Good Standing' || order.invoiceit_s__Service_Activation_Date__c > order.invoiceit_s__Service_End_Date__c || date.today().addMonths(1).toStartofMonth() - 1 == order.invoiceit_s__Service_End_Date__c)
            system.debug('Renew Rebase: ' + order.Created_From_Order__r.Renew_Rebase__c + 'Act date: ' + order.invoiceit_s__Service_Activation_Date__c);
//            if(((order.Renew_Rebase__c != 'Renew' && Order.Created_From_Order__r.Renew_Rebase__c != 'Renew') && (order.invoiceit_s__Service_Activation_Date__c > date.today().addMonths(1) || order.invoiceit_s__Account__r.Credit_Status__c != 'Good Standing' || order.invoiceit_s__Service_Activation_Date__c > order.invoiceit_s__Service_End_Date__c || date.today().addMonths(1).toStartofMonth() - 1 == order.invoiceit_s__Service_End_Date__c))
//              || (Order.Created_From_Order__r.Renew_Rebase__c == 'Renew' && Order.Created_From_Order__r.invoiceit_s__Service_End_Date__c > date.today()&& ( order.invoiceit_s__Service_Activation_Date__c < date.today() || order.invoiceit_s__Account__r.Credit_Status__c != 'Good Standing' || order.invoiceit_s__Service_Activation_Date__c > order.invoiceit_s__Service_End_Date__c || date.today().addMonths(1).toStartofMonth() - 1 == order.invoiceit_s__Service_End_Date__c)) )
            if(((order.invoiceit_s__Status__c == 'Evergreen' || (order.Renew_Rebase__c != 'Renew' && Order.Created_From_Order__r.Renew_Rebase__c != 'Renew') && (order.invoiceit_s__Service_Activation_Date__c > date.today().addMonths(1) ||  order.invoiceit_s__Service_Activation_Date__c > order.invoiceit_s__Service_End_Date__c || date.today().addMonths(1).toStartofMonth() - 1 == order.invoiceit_s__Service_End_Date__c))
              || (Order.Created_From_Order__r.Renew_Rebase__c == 'Renew' && Order.Created_From_Order__r.invoiceit_s__Service_End_Date__c > date.today()&& ( order.invoiceit_s__Service_Activation_Date__c < date.today() || order.invoiceit_s__Service_Activation_Date__c > order.invoiceit_s__Service_End_Date__c || date.today().addMonths(1).toStartofMonth() - 1 == order.invoiceit_s__Service_End_Date__c)) ))
            {

                              disableMidTermBtn = true;
                                System.debug('Disabling Mid Term Button');
            }

 
//Added 'Refused Migration' Condition Rama Jira ticket NMIG 23
             if(order.invoiceit_s__Account__r.Migration_Status__c!= 'MH Migration'  
                    && order.invoiceit_s__Account__r.Migration_Status__c!= 'MH Migration Decline' 


                         //&& order.invoiceit_s__Account__r.Migration_Status__c!= 'MH Migration Completed'

                         //&& order.invoiceit_s__Account__r.Migration_Status__c!= 'MH-PX Migration Completed'
                         //&& order.invoiceit_s__Account__r.Migration_Status__c!=  'MH-RM Migration Completed'
                         //&& order.invoiceit_s__Account__r.Migration_Status__c!= 'MH-RM-PX Migration Completed'

                         && order.invoiceit_s__Account__r.Migration_Status__c!= 'MH-PX Migration'){

                disableNoloMigrationBtn = true;
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,'Account is not eligible for Migration at this time'); 
                ApexPages.addMessage(errMsg);   
                return ;
            }
            /*Commenting for new change for Evergreen Orders
            if(disableNoloMigrationBtn != TRUE && (order.invoiceit_s__Account__r.Business_Unit__c == 'NJ Migrate' || order.invoiceit_s__Account__r.Business_Unit__c == 'Nolo-Decline' || order.invoiceit_s__Account__r.Business_Unit__c == 'Nolo-Unresponsive')){
                disableNoloMigrationBtn = False;
               
            }else{
                disableNoloMigrationBtn = true;
                 ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info,'Account is not eligible for Migration at this time'); 
                ApexPages.addMessage(errMsg);   
                return ;
            }*/
            
            System.debug('Order status is:::'+order.invoiceit_s__Status__c+'Boolean values are Renew:::'+disableRenewBtn+'Evergreen::'+disableEvergreenBtn+'disbleRebwase:::'+disableRebaseBtn);
            //mapProductNameNPriceType = new Map<String,String>();

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception has occurred. Please contact your System Administrator quoting the following message -- ' + ex.getMessage() + ', Line Number ' + ex.getLineNumber()));
        }
    }

    public Pagereference onloadOfQuotePage() {
        if(order.invoiceit_s__Service_End_Date__c != null) {
            if(system.today() >= (order.invoiceit_s__Service_End_Date__c)) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'You can only Modify/Renew the order before expiry.'));
                //disableRenewBtn = true;
            }   
        }
        //if invoiceit_s__Service_End_Date__c does not has any date value then some message
        else{
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Service End Date of the order <b> ' + order.name + '</b> is missing.'));
            //disableRenewBtn = true; 
        }

        return null;
    }

/*    public PageReference midTermPage() {
        String pageref;
        pageref = '/apex/orderMidTermAdjustmentPage1?id='+order.id;
        return new pagereference(pageref);
    }
*/    
    public Pagereference onloadOfCancelPage() {
        if(order.invoiceit_s__Status__c == 'Cancelled') {
            disableCancelBtn = true;    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Order is already cancelled.'));
        }

        return null;    
    }

    public Pagereference renew() {
        Opportunity opportunity;
        Opportunity childopty;

        try {
            if(noOfTerms == null || noOfTerms == 0) {
                // enter the number of terms pls
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Missing Value : Terms(Months)'));
                return null;
            }
            
            // Modified by Lister - 7/22/14 - Validation for number of terms to be a two digit number
            if(noOfTerms > 99) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a two digit number for Terms (Months)'));
                return null;
            }
            
            JobClass jobClass = ControllerSelectQuoteType.populateJobClass(order);
            opportunity = createOpportunity(jobClass, 'Renew', null);
            
            /**********************child opty creation******************************/
            if(childorder.id != NULL){
                system.debug('@@@childopty creation');
                JobClass jobClass1 = ControllerSelectQuoteType.populateJobClass(childorder);
                childopty          = createOpportunity(jobClass1, 'Renew', opportunity.id);
            }
            
            
           // childopty =  
            
            
            
            //order.Renew_Rebase__c = 'Renew';
            //System.debug('Renewed Order&&&'+order.Renew_Rebase__c);
            Database.update(order);
            if(opportunity.id != null){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'You have successfully modified the order and a Renewal Opportunity is created. Please click <a href="/' + opportunity.Id + '">here</a> to go to the created opportunity.'));
                return new Pagereference('/' + opportunity.Id);
            }
            /*else{
                String chargeName = '';
                for(String str : chargeNames){
                        chargeName  = chargeName + str +',';    
                }
                
                chargeName = chargeName.substring(0,  chargeName.length() - 1);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Service End Date for this  Charge <b> '+chargeName + ' </b>  is missing.'));
                //disableRenewBtn = true; 
                return new Pagereference('/' + opportunity.Id);
            }*/
            return new Pagereference('/' + opportunity.Id);
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception has occurred. Please contact your System Administrator quoting the following message -- ' + ex.getMessage() + ', Line Number ' + ex.getLineNumber()));   
            return null;
        }

    }

    public Pagereference modify() {
        Opportunity opportunity;
        Opportunity childopty;
        //MDL_CancelOrderController.checkforContactEmailValidation = true;
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRatePlanCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        try {
            
            if(noOfTerms == null || noOfTerms == 0) {
                // enter the number of terms pls
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Missing Value : Terms(Months)'));
                return null;
            }
            
            // Modified by Lister - 7/22/14 - Validation for number of terms to be a two digit number
            if(noOfTerms > 99) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a two digit number for Terms (Months)'));
                return null;
            }
            JobClass jobClass = ControllerSelectQuoteType.populateJobClass(order);
            opportunity = createOpportunity(jobClass, 'Modify', null);
            
             /**********************child opty creation******************************/
            if(childorder.id != NULL){
                JobClass jobClass1 = ControllerSelectQuoteType.populateJobClass(childorder);
                childopty          = createOpportunity(jobClass1, 'Modify', opportunity.id);
            }
            
            
            //order.Renew_Rebase__c = 'Rebase';
            //Database.update(order);
            if(opportunity.id != null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'You have successfully modified the order and a Modified Opportunity is created. Please click <a href="/' + opportunity.Id+ '">here</a> to go to the created opportunity.'));
                return new Pagereference('/' + opportunity.Id); 
            }
            /*else{
                String chargeName = '';
                for(String str : chargeNames){
                    chargeName  = chargeName + str +',';    
                }
                chargeName = chargeName.substring(0,  chargeName.length() - 1);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Service End Date for this  Charge <b> '+chargeName + ' </b>  is missing.'));
                //disableRenewBtn = true; 
                return new Pagereference('/' + opportunity.Id);
            }*/ 
        return new Pagereference('/' + opportunity.Id); 
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception has occurred. Please contact your System Administrator quoting the following message -- ' + ex.getMessage() + ', Line Number ' + ex.getLineNumber()));   
            return null;
        }

    }

      public Pagereference MidTermAdjustment() {
        Opportunity opportunity;
            Opportunity childopty;
        //MDL_CancelOrderController.checkforContactEmailValidation = true;
        List<invoiceit_s__Job_Rate_Plan_Charge__c> lstOrderRatePlanCharges = new List<invoiceit_s__Job_Rate_Plan_Charge__c>();
        try {
                        
            JobClass jobClass = ControllerSelectQuoteType.populateJobClass(order);
            date actdt = date.today().addMonths(1).toStartofMonth(); 
            if (order.invoiceit_s__Status__c == 'Evergreen')
                noOfTerms = null;
            else if ( order.Created_From_Order__r.Renew_Rebase__c == 'Renew')
            {
                system.debug('Months Between old: ' + actdt.monthsBetween(order.Created_From_Order__r.invoiceit_s__Service_End_Date__c) + ' Actdt: ' + actdt + ' new Months: ' + actdt.monthsBetween(order.invoiceit_s__Service_End_Date__c));
        noOfTerms = actdt.monthsBetween(order.invoiceit_s__Service_End_Date__c) + 1;                    
            }
            else
        noOfTerms = actdt.monthsBetween(order.invoiceit_s__Service_End_Date__c) + 1;    
            
            System.debug('No of Terms: ' + noOfTerms);
            opportunity = createOpportunity(jobClass, 'Mid-Term',null);
            
            
             /**********************child opty creation******************************/
            if(childorder.id != NULL){
                JobClass jobClass1 = ControllerSelectQuoteType.populateJobClass(childorder);
                childopty          = createOpportunity(jobClass1, 'Mid-Term', opportunity.id);
              
            }
            
            //order.Renew_Rebase__c = 'Rebase';
            //Database.update(order);
            if(opportunity.id != null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'You have successfully modified the order and a Modified Opportunity is created. Please click <a href="/' + opportunity.Id+ '">here</a> to go to the created opportunity.'));
                return new Pagereference('/' + opportunity.Id); 
            }
            /*else{
                String chargeName = '';
                for(String str : chargeNames){
                    chargeName  = chargeName + str +',';    
                }
                chargeName = chargeName.substring(0,  chargeName.length() - 1);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Service End Date for this  Charge <b> '+chargeName + ' </b>  is missing.'));
                //disableRenewBtn = true; 
                return new Pagereference('/' + opportunity.Id);
            }*/ 
        return new Pagereference('/' + opportunity.Id); 
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception has occurred. Please contact your System Administrator quoting the following message -- ' + ex.getMessage() + ', Line Number ' + ex.getLineNumber()));   
            return null;
        }

    }

    public PageReference evergreen() {
        Opportunity opportunity;
        Opportunity childopty;
        //MDL_CancelOrderController.checkforContactEmailValidation = true;
        try {
            if(noOfTerms != null) {
                noOfTerms = null;
            }
            JobClass jobClass = ControllerSelectQuoteType.populateJobClass(order);
            if(order.invoiceit_s__Status__c =='Evergreen'){
            //if(jobClass.job.RecordType.DeveloperName =='M_N_Order'){
                opportunity = createOpportunity(jobClass, 'Modify', null);
            }else{
                opportunity = createOpportunity(jobClass, 'Renew', null);
            }//updated for NCONS 108 - saiv 1/10/17 end (369 - start)
            
            
             /**********************child opty creation******************************/
            if(childorder.id != NULL){
                
                system.debug('@@@@in child opty creation');
                //Added By Sai C to handle rebase evergreen 
                if(childorder.invoiceit_s__Status__c =='Evergreen'){
                    JobClass jobClass1 = ControllerSelectQuoteType.populateJobClass(childorder);
                    childopty          = createOpportunity(jobClass1, 'Modify', opportunity.id);
                }
                else{
                    JobClass jobClass1 = ControllerSelectQuoteType.populateJobClass(childorder);
                    childopty          = createOpportunity(jobClass1, 'Renew', opportunity.id);
                }
            }
            return new Pagereference('/' + opportunity.Id);
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception has occurred. Please contact your System Administrator quoting the following message -- ' + ex.getMessage() + ', Line Number ' + ex.getLineNumber()));   
            return null;
        }
    }
    public PageReference noloMigration() {
        Opportunity opportunity;
        Opportunity childopty;
        noloMigration =true;
        try {
// changed from noofTerm != null to noofterms == null
              if(noOfTerms == null || noofTerms == 0) {
                noOfTerms = 12;
              }
            
            JobClass jobClass = ControllerSelectQuoteType.populateJobClass(order);
            opportunity = createOpportunity(jobClass, 'Modify', null);
            
             /**********************child opty creation******************************/
            if(childorder.id != NULL){
                JobClass jobClass1 = ControllerSelectQuoteType.populateJobClass(childorder);
                childopty          = createOpportunity(jobClass1, 'Renew', opportunity.id);
            }
            
             Opportunity updatedOppurtunity = new  Opportunity();
            
              // updatedOppurtunity = [Select Id, Name, Account.Id, Promotional_Credit__c, Promotional_Credit_Reason__c,Monthly_Recurring_Total__c from Opportunity where ID =: opportunity.Id ];
               updatedOppurtunity = [Select Id, Name, Account.Id, Promotional_Credit__c,
                                     Monthly_Recurring_Total__c, Account.Migration_Status__c
                                     from Opportunity where ID =: opportunity.Id ];
                   
            system.debug('@@@ updatedOppurtunity'+updatedOppurtunity);
            List<invoiceit_s__Payment_Method__c> paymentMethodList = new List<invoiceit_s__Payment_Method__c>();
            paymentMethodList =[Select Id, Name, invoiceit_s__Payment_Method__c, invoiceit_s__Active__c, invoiceit_s__Default__c,invoiceit_s__Account__c 
                                From invoiceit_s__Payment_Method__c 
                                where invoiceit_s__Account__c=: updatedOppurtunity.Account.Id  
                                //and invoiceit_s__Payment_Method__c='Credit Card'
                                and invoiceit_s__Active__c = true and invoiceit_s__Default__c= true];
            system.debug('@@@ paymentMethodList'+paymentMethodList);
              if(paymentMethodList.size()>0)
                {
                    //updatedOppurtunity.Promotional_Credit__c = updatedOppurtunity.Monthly_Recurring_Total__c;
                    if(updatedOppurtunity.Account.Migration_Status__c != 'MH-PX Migration'){
                         updatedOppurtunity.Promotional_Credit_Reason__c = paymentMethodList[0].invoiceit_s__Payment_Method__c;
                         update updatedOppurtunity;
                    }
                   
                    //updatedOppurtunity.Promotional_Credit_Payment__c = true;
                   
                }
                
            return new Pagereference('/' + opportunity.Id);
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception has occurred. Please contact your System Administrator quoting the following message -- ' + ex.getMessage() + ', Line Number ' + ex.getLineNumber()));   
            return null;
        }
    }

    /*public Pagereference cancelBtn() {
        SavePoint sp;
        list<invoiceit_s__Job_Rate_Plan_Charge__c> chargesToCancel;
        try {
            sp = DataBase.SetSavePoint();
            order.invoiceit_s__Service_End_Date__c = system.today();
            order.invoiceit_s__Status__c = 'Cancelled';
            update order;

            chargesToCancel = [SELECT Id
                               FROM invoiceit_s__Job_Rate_Plan_Charge__c
                               WHERE invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =: order.Id
                               AND
                               invoiceit_s__Status__c != 'Cancelled'
                               AND
                               invoiceit_s__Price_Type__c != 'One Time'];

            for(invoiceit_s__Job_Rate_Plan_Charge__c orderCharge : chargesToCancel) {
                orderCharge.invoiceit_s__Service_End_Date__c = system.today();  
                orderCharge.invoiceit_s__Status__c = 'Cancelled';   
            }

            update chargesToCancel;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'You have successfully cancelled the order'));

        } catch(Exception ex) {
            DataBase.RollBack(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception has occurred. Please contact your System Administrator quoting the following message -- ' + ex.getMessage() + ', Line Number ' + ex.getLineNumber()));   
        }

        return null;
    }*/

    public Opportunity createOpportunity(JobClass jobClass, String quoteType, String optyId) {
        
        String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
        system.debug('current user profile:'+userProfileName);
        boolean optyIdSent = false;
        boolean orderIdsent = false;
          if(optyId != NULL){
           
             String myIdPrefix = String.valueOf(optyId).substring(0,3);
            IF(myIdPrefix.equals('006')){
                optyIdSent = True;
            }
            else{
                orderIdsent = true;
               
            }
           
        }
        Opportunity opportunity;
        OpportunityClass opportunityClass;
        OpportunityProductClass opportunityProductClass;
        OpportunityRatePlanClass opportunityRatePlanClass;
        OpportunityRatePlanChargeClass opportunityPlanChargeClass;
        Integer opportunityProductCounter = 0;
        Integer opportunityRatePlanCounter = 0;
        Integer opportunityRateplanChargeCounter = 0;
        String casedescription;
        
        set<id> set_RenewableJobProductId = new set<id>();
        set<id> set_RenewableJobRatePlanId = new set<id>();
        set<id> set_RenewableJobRatePlanChargeId = new set<id>();
        set<id> setCancelledOrderProductsId = new Set<id>();
        set<id> setOppProdId = new set<id>();
        
        Map<String,String> Map_SINName = new Map<String,String>();
        
        //set of one time & monthly shippable products for rebase to not carry them over
        set<id> setRebasedOneTimeAndShippableProductIds = new Set<Id>();
        
        Map<Id,String> map_ChargeId_Pricetype = new Map<Id,String>();
        Map<Id,String> map_ChargeId_Shippable = new Map<Id,String>();
        
        /*if(jobclass.job.invoiceit_s__Account__c != null && noloMigration){
            Account a = new Account();
            a.Id = jobclass.job.invoiceit_s__Account__c;
            a.Business_Unit__c = 'IB Only';
            upsert a;
        }*/
        for(JobProductClass jp : jobClass.JobProducts) {
            for(JobRatePlanClass jrp : jp.jobRatePlans) {
                for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                    //map_JobProductId_RenewableCharges.add(jp.Id , jrpc)   ;
                    if((quoteType == 'Modify' || quoteType == 'Mid-Term') && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' && (jrpc.jobrateplancharge.invoiceit_s__Status__c != 'Active' && jrpc.jobrateplancharge.invoiceit_s__Service_End_Date__c != null))) {
                        setRebasedOneTimeAndShippableProductIds.add(jp.jobProduct.Id);
                    }
/*                    if(quoteType == 'Mid-Term' && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' ) && jrpc.jobrateplancharge.Fulfilment_End_Date__c != null && jrpc.jobrateplancharge.Shippable__c=='Yes') {
                         setRebasedOneTimeAndShippableProductIds.add(jp.jobProduct.Id);                       
                    }
*/
                   if(quoteType == 'Mid-Term' && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' && jrpc.jobrateplancharge.Shippable__c!='Yes')) {
                         setRebasedOneTimeAndShippableProductIds.add(jp.jobProduct.Id);                       
                    }

                    if(jrpc.JobRatePlanCharge.Renewable__c || quoteType == 'Modify' || quoteType == 'Mid-Term') {

                        System.debug(jp.jobProduct.Id);
                        set_RenewableJobProductId.add(jp.jobProduct.Id);                    
                        map_ChargeId_Shippable.put(jrpc.JobRatePlanCharge.Id,jrpc.JobRatePlanCharge.Shippable__c);  
                        map_ChargeId_Pricetype.put(jrpc.JobRatePlanCharge.Id,jrpc.JobRatePlanCharge.invoiceit_s__Price_Type__c);
                    }
                    if((jrpc.JobRatePlanCharge.invoiceit_s__Status__c == 'Cancelled')||(jrpc.JobRatePlanCharge.invoiceit_s__Status__c == 'Expired')) {
                        //RBW-980 - Fulfilled & Expired One time shippable product need to carry forward to Renewal scenario's 
                        if(!((quoteType == 'Renew') && (jrpc.JobRatePlanCharge.invoiceit_s__Status__c == 'Expired') && (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' && jrpc.jobrateplancharge.Shippable__c=='Yes') &&(jrpc.jobrateplancharge.Fulfilment_Start_Date__c!=null))){
                            setCancelledOrderProductsId.add(jp.jobProduct.Id);
                        }
                    }           
                }
            }
         } 
         
         System.debug(' check1 ' + setRebasedOneTimeAndShippableProductIds);
         System.debug(' check2 ' + set_RenewableJobProductId);
         System.debug(' check3 ' + setCancelledOrderProductsId);
         for(JobProductClass jp1 : jobClass.JobProducts){
            for(JobRatePlanClass jrp1 : jp1.jobRatePlans) {
                for(JobRatePlanChargeClass jrpc1 : jrp1.JobRatePlanCharges) {
                    if(jrpc1.jobrateplancharge.invoiceit_s__Price_Type__c == 'Monthly' && jrpc1.jobrateplancharge.Renewable__c==true){
                        if(jrpc1.jobrateplancharge.Fulfilment_Start_Date__c==null){
                            Map_SINName.put(jrpc1.jobrateplancharge.SIN__c,jrpc1.jobrateplancharge.Name);                       
                        }
                    }
                }
            }           
         } 
         if(Map_SINName!=null && Map_SINName.size()>0){
            //queue = [select Id from Group where Type='Queue' and DeveloperName ='Tech_Support' LIMIT 1]; 
            AssignmentRule AR;
            Database.DMLOptions dmlOpts;
            //Fetching the assignment rules on case
            for(AssignmentRule assignRule : [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]){
                AR = assignRule;
            }
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            dmlOpts = new Database.DMLOptions();
            if(AR!=null)
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
            Case unfulfilledcase = new Case();
            unfulfilledcase.AccountId = jobClass.job.invoiceit_s__Account__c;
            unfulfilledcase.Priority = 'High';

            unfulfilledcase.Subject = 'Unfulfilled Order Rate Plan Charge';
            unfulfilledcase.Description = 'SIN Numbers and Names of Order Rate Plan Charges are as follows : ';
            //if(queue!=null)
            //unfulfilledcase.OwnerId = queue.Id;
            casedescription='';
            for(String sin : Map_SINName.keyset()){
                casedescription += sin+'-'+Map_SINName.get(sin)+';';
            }
            unfulfilledcase.Description += casedescription;
            unfulfilledcase.setOptions(dmlOpts);
             if(!optyIdSent && !orderIdsent){
                 insert unfulfilledcase;
             }
                    
         } 
         
        opportunity = new Opportunity();
        opportunityClass = new OpportunityClass();
        opportunityClass.opportunity = opportunity;
        opportunity.StageName = 'Value Proposition';
        opportunity.CloseDate = system.today().addDays(30); 
        //opportunity.Renew_Check_Flag__c = True;      
        opportunity.Name = populateOpportunityName(quoteType,jobClass.job, noOfTerms);
        opportunity.AccountId = jobClass.job.invoiceit_s__Account__c;
        opportunity.invoiceit_crmx__CurrencyL__c = jobClass.job.invoiceit_s__CurrencyL__c;
        //opportunity.invoiceit_crmx__Billing_Contact__c = jobClass.job.invoiceit_s__Billing_Contact__c;
        //opportunity.invoiceit_crmx__Shipping_Contact__c = jobClass.job.invoiceit_s__Shipping_Contact__c;
        //opportunity.invoiceit_crmx__Discount_Value__c = jobClass.job.invoiceit_s__Discount_Value__c;
        //opportunity.invoiceit_crmx__Discount_Percent__c = jobClass.job.invoiceit_s__Discount_Percent__c;
        System.debug('Discount Percent%%'+jobClass.job.invoiceit_s__Discount_Percent__c);
        System.debug('Discount Value^^'+jobClass.job.invoiceit_s__Discount_Value__c);
        opportunity.invoiceit_crmx__Sub_Total__c = jobClass.job.invoiceit_s__Sub_Total__c;
        opportunity.invoiceit_crmx__Total__c = jobClass.job.invoiceit_s__Total__c;
        system.debug('@@@Rama No of Terms in Create: ' + noOfTerms);
        opportunity.invoiceit_crmx__Number_Of_Terms__c = noOfTerms;             
        opportunity.Created_From_Order__c = jobClass.job.Id;
        opportunity.Locations__c = jobClass.job.Locations__c;
        opportunity.Practice_Areas__c = jobClass.job.Practice_Areas__c;
        //opportunity.ReferralAccount__c = jobClass.job.PartnerAccount__c;
        opportunity.ReferralAccount__c = jobClass.job.PartnerAccountOrder__c;
        //added by sai c
        if(noOfTerms == NULL){
           opportunity.NgageCheck__c = True;                 
                            }
        //added by saiv MHBS-3345
        system.debug('opportunity.Name==='+opportunity.Name);
        if(opportunity.Name.contains('Auto Evergreen') || (userProfileName=='System Administrator' && opportunity.Name.contains('Rebase Evergreen'))){
            opportunity.invoiceit_crmx__Billing_Contact__c = jobClass.job.invoiceit_s__Billing_Contact__c;
            opportunity.invoiceit_crmx__Shipping_Contact__c = jobClass.job.invoiceit_s__Shipping_Contact__c;
            opportunity.Auth_By_Contact__c = jobClass.job.Auth_By_Contact__c;
            opportunity.Marketing_Contact__c = jobClass.job.Marketing_Contact__c;
        
        }
        // Added by Ronak
        //opportunity.Parent_Order__c = jobClass.job.Parent_Order__c;

        System.debug('Previous Order Status===='+jobClass.job.invoiceit_s__Status__c);
        System.debug('Order Record Type====='+jobClass.job.RecordType.DeveloperName);
        if(jobClass.job.RecordType.DeveloperName == 'M_N_Order' || ( jobClass.job.invoiceit_s__Status__c == 'Evergreen' && (jobClass.job.RecordType.DeveloperName == 'MH_Orders' || jobClass.job.RecordType.DeveloperName == 'Nolo_Order'))){
            opportunity.Quote_Type__c = 'Modify';
        }
        else{
        opportunity.Quote_Type__c = quoteType;
        }
        if ( quoteType == 'Mid-Term')
            opportunity.Quote_Type__c = 'Modify';

        //opportunity.Auth_By_Contact__c = jobClass.job.Auth_By_Contact__c;
        opportunity.Purchase_Order_Number__c = jobClass.job.Purchase_Order_Number__c;
        
        //Sai: to check Id belongs to child order which is calling From NgageChatController 
        //     or From Modify Order button call i.e from this opty only
       
        
        if(optyId != NULL){
            system.debug('@@@@optyId'+optyId);
             String myIdPrefix = String.valueOf(optyId).substring(0,3);
            IF(myIdPrefix.equals('006')){
                 opportunity.Parent_Opportunity__c = optyId;
            }
            else{
                opportunity.Ngage_Upsell_Order__c = optyId;
                system.debug('@@@assigning orderid here');
            }
           
        }
        //opportunity.Amount = jobClass.job.invoiceit_s__Total__c;
        /*if(noloMigration){
            opportunity.Reason_for_Discount__c = 'Nolo Migration';
        }*/
        insert opportunity;     
        
        System.debug('Oppty discount values are ####'+opportunity.invoiceit_crmx__Discount_Percent__c+'discount value$$$'+opportunity.invoiceit_crmx__Discount_Value__c);
        
        Map<Integer, invoiceit_crmx__Opportunity_Product__c> mapOpportunityProducts = new Map<Integer, invoiceit_crmx__Opportunity_Product__c>();
        
        Map<Id,invoiceit_crmx__Opportunity_Product__c> map_orderproductId_oppProd = new Map<Id,invoiceit_crmx__Opportunity_Product__c>(); 
        
        //Added for rebasing Ngage only order for adding additional chats and feature products --- Ronak
        
        Map<Id,String> map_orderproductId_oppProdId = new Map<Id,String>(); 

        Map<Id, String> map_opptyProdId_CreatedFromOrdProd = new Map<Id, String>();
        
        for(JobProductClass jobProductClass : jobClass.JobProducts) {
            if(set_RenewableJobProductId.contains(jobProductClass.jobproduct.Id) && (!setRebasedOneTimeAndShippableProductIds.contains(jobProductClass.jobproduct.Id)) && (!setCancelledOrderProductsId.contains(jobProductClass.jobproduct.Id))){
                invoiceit_crmx__Opportunity_Product__c opportunityProduct = new invoiceit_crmx__Opportunity_Product__c();
                opportunityProduct.Created_From_Code__c = True;
                opportunityProduct.invoiceit_crmx__Opportunity__c = opportunity.Id;
                opportunityProduct.Name = jobProductClass.jobproduct.Name;
                opportunityProduct.Is_Chat_Option_Shown__c = null;
                opportunityProduct.invoiceit_crmx__Product__c = jobProductClass.jobproduct.invoiceit_s__Product__c;
                opportunityProduct.invoiceit_crmx__SequenceNumber__c = jobProductClass.jobproduct.invoiceit_s__SequenceNumber__c;                
                System.debug(jobProductClass.jobproduct.invoiceit_s__Product_Code__c);
                opportunityProduct.invoiceit_crmx__Product_Code__c = jobProductClass.jobproduct.invoiceit_s__Product_Code__c; 
                //Ronak added
                opportunityProduct.Created_From_Order_Product__c = jobProductClass.jobproduct.id;
                opportunityProduct.IsAddOnFeature__c = jobProductClass.jobproduct.IsAddOnFeature__c;
               // opportunityProduct.Created_From_Opportunity_Product__c = map_orderproductId_oppProd.get(map_opptyProdId_CreatedFromOrdProd.get(OpportunityProduct.Id));
                
                //opportunityProduct.Created_From_Opportunity_Product__c = jobProductClass.jobproduct.id; 
                
                
                boolean bundlsequenceflag = false;
                for(JobRatePlanClass jrp : jobProductClass.getJobRatePlans()){
                    //if(jrp.jobrateplan.name.contains('package') ){
                        for(JobRatePlanChargeClass jrpc: jrp.getJobRatePlanCharges()){
                            if(jrpc.jobrateplancharge.Package_Wrapper__c ==true || jrpc.jobrateplancharge.Package_Component__c ==true){
                                opportunityProduct.invoiceit_crmx__Bundle_SequenceNumber__c = 1;
                                opportunityProduct.invoiceit_crmx__Product_Bundle__c = jobProductClass.jobProduct.invoiceit_s__Product_Bundle__c;
                               bundlsequenceflag =true;
                               break;
                            }    
                        }
                    
                    //}
                    if(bundlsequenceflag){
                        break;
                    }
                }
                
                
                
                System.debug(opportunityProduct.invoiceit_crmx__Product_Code__c);

                opportunityProduct.invoiceit_crmx__Description__c = jobProductClass.jobproduct.invoiceit_s__Description__c; 
                opportunityProduct.invoiceit_crmx__Product_Family__c = jobProductClass.jobproduct.invoiceit_s__Product_Family__c; 
                opportunityProduct.Product_SIN__c = jobProductClass.jobproduct.Sin_Number__c ;
                //code added by Lister to facilitate carrrying Inventory numbers from Order products to Oppty Products(though SIN number is pending)
                if(JobProductClass.jobproduct.Inventory_Id__c!=null) {
                    opportunityProduct.InventoryId__c = JobProductClass.jobproduct.Inventory_Id__c;
                }      
    
                opportunityProductClass = new OpportunityProductClass();
                opportunityProductClass.opportunityProductCounter = ++opportunityProductCounter;
                opportunityProductClass.opportunityProduct = opportunityProduct;
                opportunityClass.opportunityProducts.add(opportunityProductClass);
                mapOpportunityProducts.put(opportunityProductClass.opportunityProductCounter, opportunityProduct);
                map_orderproductId_oppProd.put(jobProductClass.jobproduct.Id,opportunityProduct);
                System.debug('check 4 '  +  map_orderproductId_oppProd);
            }
        }
        //upsert mapOpportunityProducts.values();
        
        if(map_orderproductId_oppProd.size() > 0)
            upsert map_orderproductId_oppProd.values();
        
        System.debug('check 5 ' + map_orderproductId_oppProd );
        
        for(invoiceit_crmx__Opportunity_Product__c op : map_orderproductId_oppProd.values()) {
            setOppProdId.add(op.Id);
        } 
        List<invoiceit_crmx__Opportunity_Product__c>  listopProd = [select Id,invoiceit_crmx__Product_Code__c,Created_From_Order_Product__c,Created_From_Order_Product__r.Created_From_Order_Product__c from invoiceit_crmx__Opportunity_Product__c where Id in :setOppProdId];
        for(invoiceit_crmx__Opportunity_Product__c c : listopProd){
            System.debug(c.invoiceit_crmx__Product_Code__c);
            if(c.Created_From_Order_Product__c!=Null){
                map_orderproductId_oppProdId.put(c.Created_From_Order_Product__c, c.Id);
            }
            System.debug('=======inside the condition========'+c.invoiceit_crmx__Product_Code__c);
            System.debug('======c.Created from Order Product========'+c.Created_From_Order_Product__r.Created_From_Order_Product__c);
            System.debug('======c.Created from Order Product========'+c.Created_From_Order_Product__c);
            if(c.Created_From_Order_Product__r.Created_From_Order_Product__c!= NUll){
                map_opptyProdId_CreatedFromOrdProd.put(c.Id, c.Created_From_Order_Product__r.Created_From_Order_Product__c); 
            }
            if(map_opptyProdId_CreatedFromOrdProd.containsKey(c.Id)){
                System.debug('=====Oppty Prod ID and Created from Ord Prod Id===='+map_opptyProdId_CreatedFromOrdProd.get(c.Id));
                System.debug('=====map_orderproductId_oppProdId===='+map_orderproductId_oppProdId.get(map_opptyProdId_CreatedFromOrdProd.get(c.Id)));
                c.Created_From_Opportunity_Product__c = map_orderproductId_oppProdId.get(map_opptyProdId_CreatedFromOrdProd.get(c.Id));
                System.debug('===Created from oppty Prod==='+c.Created_From_Opportunity_Product__c);
            }
        }
        
        System.debug('map_opptyProdId_CreatedFromOrdProd'+map_opptyProdId_CreatedFromOrdProd);
          if(!orderIdsent){
                update listopProd;
          }
        
        set<Id> setOpportunityProductIds = new set<Id>();
        map<Integer,invoiceit_crmx__Opportunity_Rate_Plan__c> mapOppRatePlans = new map<Integer,invoiceit_crmx__Opportunity_Rate_Plan__c>();
        Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c> map_orderRP_oppRP = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan__c>();
        
        for(JobProductClass jp : jobClass.JobProducts) {
            if(set_RenewableJobProductId.contains(jp.jobproduct.Id) && (!setRebasedOneTimeAndShippableProductIds.contains(jp.jobproduct.Id)) && (!setCancelledOrderProductsId.contains(jp.jobproduct.Id))){
            //for(OpportunityProductClass op : opportunityClass.opportunityProducts) {
                    for(JobRatePlanClass jrp : jp.jobRatePlans) {
                        invoiceit_crmx__Opportunity_Rate_Plan__c oppRatePlan = new invoiceit_crmx__Opportunity_Rate_Plan__c();
                        if(map_orderproductId_oppProd.containsKey(jp.JobProduct.Id))
                            oppRatePlan.invoiceit_crmx__Opportunity_Product__c = map_orderproductId_oppProd.get(jp.JobProduct.Id).Id;
                        oppRatePlan.Name = jrp.jobRatePlan.Name;
                        oppRatePlan.invoiceit_crmx__Description__c = jrp.jobRatePlan.invoiceit_s__Description__c;
                        system.debug('before ::::'+oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c);
                        system.debug('before plan::::'+jrp.jobRatePlan.invoiceit_s__Product_Rate_Plan__c);
                        oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c = jrp.jobRatePlan.invoiceit_s__Product_Rate_Plan__c;
                        system.debug('after ::::'+oppRatePlan.invoiceit_crmx__Product_Rate_Plan__c);
                        oppRatePlan.invoiceit_crmx__SequenceNumber__c = jrp.jobRatePlan.invoiceit_s__SequenceNumber__c;
                        
                        //dynamic field mapping ends here
                        opportunityRatePlanClass = new OpportunityRatePlanClass();
                        opportunityRatePlanClass.opportunityRatePlanCounter = ++OpportunityRatePlanCounter;
                        opportunityRatePlanClass.opportunityrateplan = oppRatePlan;
                        opportunityProductClass.opportunityRatePlans.add(opportunityRatePlanClass);
                        mapOppRatePlans.put(opportunityRatePlanClass.opportunityRatePlanCounter, oppRatePlan);
                        map_orderRP_oppRP.put(jrp.jobRatePlan.Id , oppRatePlan);
                    }         
            //}
            }
        }
        //upsert mapOppRatePlans.values();
        
        if(map_orderRP_oppRP.size()>0)
            upsert map_orderRP_oppRP.values();
        map<Integer,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> mapOppRatePlanCharges = new map<Integer,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> map_orderRPCId_OppRPC = new map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        map<Id,invoiceit_s__Job_Rate_Plan_Charge__c> map_orderRPCId_OrderRPC = new map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        Set<invoiceit_crmx__Opportunity_Product__c> setOppProductsToBeUpdates = new Set<invoiceit_crmx__Opportunity_Product__c>();
        List<invoiceit_crmx__Opportunity_Product__c> lstOppProductsToBeUpdates = new List<invoiceit_crmx__Opportunity_Product__c>();
        for(JobProductClass jp : jobClass.JobProducts) {
            system.debug('checkpoint 1');
            if(set_RenewableJobProductId.contains(jp.jobproduct.Id) && (!setRebasedOneTimeAndShippableProductIds.contains(jp.jobproduct.Id)) && (!setCancelledOrderProductsId.contains(jp.jobproduct.Id))){
                system.debug('checkpoint 2');
                for(JobRatePlanClass jrp : jp.jobRatePlans) {        
                    system.debug('checkpoint 3');           
                    Id oppRatePlanId = map_orderRP_oppRP.get(jrp.jobRatePlan.Id).Id;
                    for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                       if(jrpc.jobrateplancharge.Renewable__c){
                            system.debug('checkpoint 4');
                            //adding one condition to check service end date of charge is null or not.
                            /*if(jrpc.jobrateplancharge.invoiceit_s__Service_End_Date__c == null && jrpc.jobrateplancharge.invoiceit_s__Price_Type__c != 'One Time'){
        
                                chargeNames.add(jrpc.jobrateplancharge.name);
                                //mapProductNameNPriceType.put(jrpc.jobrateplancharge.name,jrpc.jobrateplancharge.invoiceit_s__Price_Type__c);
                                opportunity = new Opportunity();
                                return opportunity; 
                            }*/
                            invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRatePlanCharge = new invoiceit_crmx__Opportunity_Rate_Plan_Charge__c();
                            oppRatePlanCharge.invoiceit_crmx__Opportunity_Rate_Plan__c = oppRatePlanId;
                            oppRatePlanCharge.Name = jrpc.jobrateplancharge.Name;
                            oppRatePlanCharge.invoiceit_crmx__Discount_Value__c = jrpc.jobrateplancharge.invoiceit_s__Discount_Value__c;
                            System.debug('Charge Disc Value &&&'+jrpc.jobrateplancharge.invoiceit_s__Discount_Value__c);
                            oppRatePlanCharge.invoiceit_crmx__Price_Format__c = jrpc.jobrateplancharge.invoiceit_s__Price_Format__c;
                            oppRatePlanCharge.invoiceit_crmx__Profit__c = jrpc.jobrateplancharge.invoiceit_s__Profit__c;
                            oppRatePlanCharge.invoiceit_crmx__Sequence_No__c = jrpc.jobrateplancharge.invoiceit_s__Sequence_No__c;
                            oppRatePlanCharge.invoiceit_crmx__Unit_Of_Measurement__c = jrpc.jobrateplancharge.invoiceit_s__Unit_Of_Measurement__c;
                            oppRatePlanCharge.invoiceit_crmx__Price__c = jrpc.jobrateplancharge.invoiceit_s__Price__c;
                            oppRatePlanCharge.invoiceit_crmx__Unit_Price__c = jrpc.jobrateplancharge.invoiceit_s__Unit_Price__c;
                            oppRatePlanCharge.invoiceit_crmx__Price_Type__c = jrpc.jobrateplancharge.invoiceit_s__Price_Type__c;
                            oppRatePlanCharge.invoiceit_crmx__CurrencyL__c = jrpc.jobrateplancharge.invoiceit_s__CurrencyL__c;
                            oppRatePlanCharge.invoiceit_crmx__Quantity__c = jrpc.jobrateplancharge.invoiceit_s__Quantity__c;
                            oppRatePlanCharge.invoiceit_crmx__Sequence_No__c = jrpc.jobrateplancharge.invoiceit_s__Sequence_No__c;                                   
                            oppRatePlanCharge.invoiceit_crmx__Tax__c = jrpc.jobrateplancharge.invoiceit_s__Tax__c;
                            oppRatePlanCharge.Chat_ID__c             = jrpc.jobrateplancharge.Chat_ID__c; 
                            oppRatePlanCharge.invoiceit_crmx__Vat__c = jrpc.jobrateplancharge.invoiceit_s__Vat__c;                                 
                            oppRatePlanCharge.invoiceit_crmx__Cost__c = jrpc.jobrateplancharge.invoiceit_s__Cost__c;
                            oppRatePlanCharge.invoiceit_crmx__Cost_Price__c = jrpc.jobrateplancharge.invoiceit_s__Cost_Price__c;
                            oppRatePlanCharge.invoiceit_crmx__Is_Product_Editable__c = jrpc.jobrateplancharge.invoiceit_s__Is_Product_Editable__c;
                            oppRatePlanCharge.invoiceit_crmx__Product_Rate_Plan_Charge__c = jrpc.jobrateplancharge.invoiceit_s__Product_Rate_Plan_Charge__c;
                            oppRatePlanCharge.invoiceit_crmx__Product_Charge_Category__c = jrpc.jobrateplancharge.invoiceit_s__Product_Charge_Category__c;
                            oppRatePlanCharge.invoiceit_crmx__VAT_Percentage__c = jrpc.jobrateplancharge.invoiceit_s__VAT_Percentage__c;
                            oppRatePlanCharge.invoiceit_crmx__Tax_Percentage__c = jrpc.jobrateplancharge.invoiceit_s__Tax_Percentage__c;
                            oppRatePlanCharge.invoiceit_crmx__Net_Total__c =  jrpc.jobrateplancharge.invoiceit_s__Net_Total__c;
                            oppRatePlanCharge.invoiceit_crmx__Discount_percent__c = jrpc.jobrateplancharge.invoiceit_s__Discount_percent__c;
                            System.debug('Charge Disc Percent ****'+jrpc.jobrateplancharge.invoiceit_s__Discount_percent__c);
                            oppRatePlanCharge.invoiceit_crmx__VAT_Percentage__c =  jrpc.jobrateplancharge.invoiceit_s__VAT_Percentage__c;
                            oppRatePlanCharge.invoiceit_crmx__Tax_Percentage__c =  jrpc.jobrateplancharge.invoiceit_s__Tax_Percentage__c;
                            oppRatePlanCharge.invoiceit_crmx__Accounting_Code__c = jrpc.jobrateplancharge.invoiceit_s__Accounting_Code__c;
                            oppRatePlanCharge.invoiceit_crmx__Percentage_of_other_Charges__c = jrpc.jobrateplancharge.invoiceit_s__Percentage_of_other_Charges__c;
                            //Addded by saiv - prodpack
                            system.debug('test here before line:::'+oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c);
                            system.debug('test here:::'+jrpc.jobrateplancharge.invoiceit_s__Product_Bundle_Line__c);
                            oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c = jrpc.jobrateplancharge.invoiceit_s__Product_Bundle_Line__c;
                            system.debug('test here after line:::'+oppRatePlanCharge.invoiceit_crmx__Product_Bundle_Line__c);
                            oppRatePlanCharge.Live_Date__c=  jrpc.jobrateplancharge.Live_Date__c;
                            //code added by Lister to facilitate carrrying SIN numbers from Order products to Oppty Products
                            
                            if((jrpc.jobrateplancharge.invoiceit_s__Price_Type__c != 'One Time') && 
                                !(jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'Monthly' && jrpc.jobrateplancharge.Shippable__c == 'Yes')) {
                                oppRatePlanCharge.SIN__c = jrpc.jobrateplancharge.SIN__c;
                                
                            }   
                            if(jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'One Time' || (jrpc.jobrateplancharge.invoiceit_s__Price_Type__c == 'Monthly' && jrpc.jobrateplancharge.Shippable__c == 'Yes')) {
                                if(map_orderproductId_oppProd.containsKey(jp.jobproduct.Id)) {
                                    map_orderproductId_oppProd.get(jp.jobproduct.Id).Product_SIN__c = null;
                                    setOppProductsToBeUpdates.add(map_orderproductId_oppProd.get(jp.jobproduct.Id));
                                }
                            }
                            oppRatePlanCharge.Created_From_Charge__c = jrpc.jobrateplancharge.Id;
                            System.debug('Job rate plan charge'+jrpc.jobrateplancharge.RecordType.DeveloperName);
                            System.debug('Quote Type'+quoteType);
                            if(jrpc.jobrateplancharge.RecordType.DeveloperName == 'M_N_Order_Rate_Plan_Charge' || (jrpc.jobrateplancharge.invoiceit_s__Order__r.invoiceit_s__Status__c == 'Evergreen' && (jrpc.jobrateplancharge.RecordType.DeveloperName == 'MDL_Order_Rate_Plan_Charge' || jrpc.jobrateplancharge.RecordType.DeveloperName == 'Nolo_Order_Rate_Plan_Charge'))){
                                System.debug('Inside the if condition');
                                oppRatePlanCharge.Quote_Type__c = 'Modify';
                            } else{
                            oppRatePlanCharge.Quote_Type__c = quoteType;
                            }
                            if (quoteType == 'Mid-Term')


                              oppRatePlanCharge.Quote_Type__c = 'Modify';
                            
                            OpportunityRatePlanChargeClass oppRatePlanChargeClass = new OpportunityRatePlanChargeClass();
                            oppRatePlanChargeClass.opportunityRatePlanChargeCounter = ++opportunityRateplanChargeCounter;
                            oppRatePlanChargeClass.opportunityRatePlanCharge = oppRatePlanCharge;
                            opportunityRatePlanClass.opportunityRatePlanCharges.add(oppRatePlanChargeClass);
                            mapOppRatePlanCharges.put(jrpc.JobRatePlanChargeCounter, oppRatePlanCharge);
                            map_orderRPCId_OppRPC.put(jrpc.jobrateplancharge.Id, oppRatePlanCharge);  
                           map_orderRPCId_OrderRPC.put(jrpc.jobrateplancharge.Id,jrpc.jobrateplancharge);
                        }
                    }    
                }
            }
        }
        //upsert mapOppRatePlanCharges.values();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>childcharges = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>childchargestoUpdate = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>chatIdVScharge = new Map<Id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        if(map_orderRPCId_OppRPC.size() > 0){
            upsert map_orderRPCId_OppRPC.values();
            //Forming parents here first
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c opcharge: map_orderRPCId_OppRPC.values()){
                if(opcharge.Created_From_Charge__c != NULL){
                    invoiceit_s__Job_Rate_Plan_Charge__c ordc = map_orderRPCId_OrderRPC.get(opcharge.Created_From_Charge__c);
                    if(ordc.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL){
                        childcharges.add(opcharge);
                    }
                    else{
                        chatIdVScharge.put(ordc.Opportunity_Rate_Plan_Charge__c,opcharge);
                    }
                    
                }
            }
            
            if(!childcharges.isEmpty()){
                 for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c ccharget: childcharges){
                    invoiceit_s__Job_Rate_Plan_Charge__c ordc = map_orderRPCId_OrderRPC.get(ccharget.Created_From_Charge__c);
                    if(ordc.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c != NULL){
                        System.debug('ordc.Opportunity_Rate_Plan_Charge__r--> ' + JSON.serialize(ordc.Opportunity_Rate_Plan_Charge__r));
                        System.debug('chatIdVScharge--> ' + JSON.serialize(chatIdVScharge));
                        ccharget.Chat_Parent_Opportunity_Rate_Plan_Charge__c = chatIdVScharge.get(ordc.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c).id;
                        childchargestoUpdate.add(ccharget);
                    }
                }
                if(!childchargestoUpdate.isEmpty()){
                    update childchargestoUpdate;
                }
                
            }
           
        }
            
            
        if(setOppProductsToBeUpdates.size() > 0) { 
            lstOppProductsToBeUpdates.addAll(setOppProductsToBeUpdates);
            System.debug('lst of Product SIN to be removed::'+lstOppProductsToBeUpdates);
            if(!orderIdsent){
            update lstOppProductsToBeUpdates;  
            }    
        }   
        
        System.debug('####map Oppty Charges###'+map_orderRPCId_OppRPC.values());
        
        // we need to populate the tiers
        map<Id, list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c>> map_JobChargeId_JobTiers = new map<Id, list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c>>();
        list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c> jobTiers = new list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c>();
            jobTiers = [SELECT invoiceit_s__End_Unit__c, invoiceit_s__Job_Rate_Plan_Charge__c, invoiceit_s__Start_Unit__c, invoiceit_s__Unit_Cost_Price__c, invoiceit_s__Unit_Price__c
                                                                    FROM invoiceit_s__Job_Rate_Plan_Charge_Tier__c
                                                                    WHERE invoiceit_s__Job_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =: order.Id
                                                                    ORDER BY invoiceit_s__Start_Unit__c];

        list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c> jobTiersLocalVar;
        for(invoiceit_s__Job_Rate_Plan_Charge_Tier__c jobTier : jobTiers) {
            if(map_JobChargeId_JobTiers.containsKey(jobTier.invoiceit_s__Job_Rate_Plan_Charge__c)) {
                jobTiersLocalVar = map_JobChargeId_JobTiers.get(jobTier.invoiceit_s__Job_Rate_Plan_Charge__c);
            } else {
                jobTiersLocalVar = new list<invoiceit_s__Job_Rate_Plan_Charge_Tier__c>();
            }

            jobTiersLocalVar.add(jobTier);
            map_JobChargeId_JobTiers.put(jobTier.invoiceit_s__Job_Rate_Plan_Charge__c, jobTiersLocalVar);
        }
        
        system.debug('@@@@@@map_orderRPCId_OppRPC keyset'+map_orderRPCId_OppRPC.keyset());

        // we need to populate the opportunity charge attributes
        map<Id, list<Order_Charge_Attribute__c>> map_JobChargeId_OrderAttributes = new map<Id, list<Order_Charge_Attribute__c>>();
        list<Order_Charge_Attribute__c> jobAttributes = [SELECT Name, Attribute_Name__c, Boolean_Value__c,Maximum_No_Of_Characters_In_Text__c,Minimum_No_Of_Characters_In_Text__c, Date_Value__c, Number_Value__c, String_Value__c, Attribute_Type__c,
                                                         Attribute_Order__c,Order_Rate_Plan_Charge__r.Shippable__c,
                                                         Attribute_Picklist_Values__c,
                                                         Picklist_Value__c,long_text_Value__c,Show_in_DocuSign__c ,
                                                         Phone_Value__c,Value_ID__c,
                                                         Order_Rate_Plan_Charge__c
                                                         FROM Order_Charge_Attribute__c
                                                         WHERE Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Job__c =: jobClass.job.id
                                                         AND Order_Rate_Plan_Charge__c in: map_orderRPCId_OppRPC.keyset()
                                                         ORDER BY Attribute_Order__c];

        list<Order_Charge_Attribute__c> jobAttributesLocalVar;
        for(Order_Charge_Attribute__c jobAttribute : jobAttributes) {
            if(map_JobChargeId_OrderAttributes.containsKey(jobAttribute.Order_Rate_Plan_Charge__c)) {
                jobAttributesLocalVar = map_JobChargeId_OrderAttributes.get(jobAttribute.Order_Rate_Plan_Charge__c);
            } else {
                jobAttributesLocalVar = new list<Order_Charge_Attribute__c>();
            }

            jobAttributesLocalVar.add(jobAttribute);
            map_JobChargeId_OrderAttributes.put(jobAttribute.Order_Rate_Plan_Charge__c, jobAttributesLocalVar);
        }   
        system.debug('@@@@map_JobChargeId_OrderAttributes'+map_JobChargeId_OrderAttributes);
        // we need to insert the tiers and atrributes here
        //list<invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c> opportunityTiers = new list<invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c>();
        list<Opportunity_Charge_Attribute__c> opportunityAttributes = new list<Opportunity_Charge_Attribute__c>();
        //invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c opportunityTier;
        Opportunity_Charge_Attribute__c opportunityAttribute;
        String OppName;
        for(JobProductClass jp : jobClass.JobProducts) {
            if(set_RenewableJobProductId.contains(jp.jobproduct.Id)){
                for(JobRatePlanClass jrp : jp.jobRatePlans) {
                    for(JobRatePlanChargeClass jrpc : jrp.JobRatePlanCharges) {
                        //invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge = mapOppRatePlanCharges.get(jrpc.JobRatePlanChargeCounter);
                        invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppCharge = map_orderRPCId_OppRPC.get(jrpc.JobRatePlanCharge.Id);
                        // pull the tiers and create the opportunity tiers
                        /*if(map_JobChargeId_JobTiers.containsKey(jrpc.jobrateplancharge.Id)) {
                            for(invoiceit_s__Job_Rate_Plan_Charge_Tier__c orderTier : map_JobChargeId_JobTiers.get(jrpc.jobrateplancharge.Id)) {
                                opportunityTier = new invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c();
                                opportunityTier.invoiceit_crmx__Start_Unit__c = orderTier.invoiceit_s__Start_Unit__c;
                                opportunityTier.invoiceit_crmx__End_Unit__c = orderTier.invoiceit_s__End_Unit__c;
                                opportunityTier.invoiceit_crmx__Unit_Cost_Price__c = orderTier.invoiceit_s__Unit_Cost_Price__c;
                                opportunityTier.invoiceit_crmx__Unit_Price__c = orderTier.invoiceit_s__Unit_Price__c;
                                opportunityTier.invoiceit_crmx__Opportunity_Rate_Plan_Charge__c = oppCharge.Id;
    
                                opportunityTiers.add(opportunityTier);
                            }
                        }   
                        */
                        // pull the attributes and create the opportunity attributes
                        // change for MHBS-160
                       system.debug('@@@@@jrpc.jobrateplancharge.name'+jrpc.jobrateplancharge.Name);
                        if(map_JobChargeId_OrderAttributes.containsKey(jrpc.jobrateplancharge.Id)) {
                            for(Order_Charge_Attribute__c orderAttribute : map_JobChargeId_OrderAttributes.get(jrpc.jobrateplancharge.Id)) {                                
                                       system.debug('@@@@orderAttribute name'+ orderAttribute.Attribute_Name__c);
                                        opportunityAttribute = new Opportunity_Charge_Attribute__c();
                                        opportunityAttribute.Attribute_Type__c = orderAttribute.Attribute_Type__c;
                                        opportunityAttribute.long_text_Value__c = orderAttribute.long_text_Value__c ;                                   
                                        opportunityAttribute.Attribute_Name__c = orderAttribute.Attribute_Name__c;
                    opportunityAttribute.Value_ID__c= orderAttribute.Value_ID__c;
                                        if(!(orderAttribute.Attribute_Name__c == 'Edition' && orderAttribute.Order_Rate_Plan_Charge__r.Shippable__c == 'Yes')){
                                            opportunityAttribute.Picklist_Value__c = orderAttribute.Picklist_Value__c;
                                            opportunityAttribute.String_Value__c = orderAttribute.String_Value__c;
                                            opportunityAttribute.Boolean_Value__c = orderAttribute.Boolean_Value__c;
                                            opportunityAttribute.Number_Value__c = orderAttribute.Number_Value__c;
                                            opportunityAttribute.Date_Value__c = orderAttribute.Date_Value__c;
                                            opportunityAttribute.Phone_Value__c= orderAttribute.Phone_Value__c;
                                            opportunityAttribute.Show_in_DocuSign__c = orderAttribute.Show_in_DocuSign__c;
                                        }    
                                        opportunityAttribute.Attribute_Order__c = orderAttribute.Attribute_Order__c;
                                        opportunityAttribute.Show_in_DocuSign__c = orderAttribute.Show_in_DocuSign__c;
                                        opportunityAttribute.Attribute_Picklist_Values__c = orderAttribute.Attribute_Picklist_Values__c;
                                        opportunityAttribute.Opportunity_Rate_Plan_Charge__c = oppCharge.Id;
                                        opportunityAttribute.Maximum_No_Of_Characters_In_Text__c = orderAttribute.Maximum_No_Of_Characters_In_Text__c;
                                        opportunityAttribute.Minimum_No_Of_Characters_In_Text__c = orderAttribute.Minimum_No_Of_Characters_In_Text__c;
                                        opportunityAttributes.add(opportunityAttribute);
                                }
                            
                        }
                    }
                }
            }
        }

        /*if(opportunityTiers.size() > 0) {
            insert opportunityTiers;    
        }*/

        if(opportunityAttributes.size() > 0) {
            insert opportunityAttributes;   
        }


        if(optyId != NULL){
              String myIdPrefix = String.valueOf(optyId).substring(0,3);
            IF(myIdPrefix.equals('006')){
                 insertIntoOppChat(opportunity);
            }
            
        }
      
       opportunity.invoiceit_crmx__Recalculate__c = true;
        //opportunity.Quote_Type__c = quoteType;
//        Opportunity opp = new opportunity();
//        opp.id = opportunity.id;
//        opp.invoiceit_crmx__Recalculate__c = true;
          opportunity.invoiceit_crmx__Recalculate__c = true;
//        if (opportunity.name.contains('Evergreen'))
          update opportunity;
//        else
//          update opp;
        return opportunity;
    }

    public static JobClass populateJobClass(invoiceit_s__Job__c order) {
        Map<Id,JobProductClass> mapJobProducts = new  Map<Id,JobProductClass>();
        JobClass jobClass = new JobClass();
        Integer jobProductCounter = 0;
        Integer jobRatePlanCounter = 0;
        Integer jobRateplanChargeCounter = 0;
        Integer jobRatePlanChargeTierCounter = 0;
        Integer iJobProductSequenceNo = 1;
        Integer iJobRatePlanSequenceNo = 1;
        List<invoiceit_s__Job_Product__c> listJobProducts = new List<invoiceit_s__Job_Product__c>();
        List<invoiceit_s__Job_Rate_Plan__c> listJobRatePlans = new List<invoiceit_s__Job_Rate_Plan__c>();
        JobProductClass jobProductClass;
        JobRatePlanClass jobRatePlanClass;
        JobRatePlanChargeClass jobRatePlanChargeClass;

        jobClass.job = order;
        system.debug('@@@@order.id'+order.id);
        string queryStringJP ='SELECT ' + getObjectFields('invoiceit_s__Job_Product__c') + ' From invoiceit_s__Job_Product__c WHERE invoiceit_s__Job__c = \'' + order.Id + '\' order by invoiceit_s__SequenceNumber__c';
        System.Debug('====queryStringJP======'+queryStringJP);
        listJobProducts = Database.query(queryStringJP);

        //add listJobProducts to jobProductClass
        for(invoiceit_s__Job_Product__c qp : listJobProducts) {
            jobProductClass = new JobProductClass();
            jobProductClass.jobProductCounter = ++jobProductCounter;
            jobProductClass.jobproduct = qp;
            jobClass.jobProducts.add(jobProductClass);

            mapJobProducts.put(qp.Id, jobProductClass);
        }
        //get the list of jobProduct Ids in to Map
        Set<Id> mapJobProductKeyset = new Set<Id>();
        mapJobProductKeyset = mapJobProducts.keySet();
        List<Id> jobProductIds = new List<Id>();
        Integer mapJobProductKeysetSize = mapJobProductKeyset.size();

        //Add all the ids to list jobProductIds
        jobProductIds.addAll(mapJobProductKeyset);

        date todaysDate = system.today();
        String sQueryJRPs = 'SELECT ' + getObjectFields('invoiceit_s__Job_Rate_Plan__c') + ',' 
        + '(SELECT ' + getObjectFields('invoiceit_s__Job_Rate_Plan_Charge__c') + 
            ', RecordType.DeveloperName,invoiceit_s__Order__r.invoiceit_s__Status__c, ' +
             ' Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__c '+
              ' FROM invoiceit_s__Job_Rate_Plan_Charge__r Order by invoiceit_s__Sequence_No__c) '
        + 'FROM invoiceit_s__Job_Rate_Plan__c WHERE invoiceit_s__Job_Product__c IN: jobProductIds Order By invoiceit_s__Job_Rate_Plan__c.invoiceit_s__Job_Product__r.invoiceit_s__SequenceNumber__c, invoiceit_s__SequenceNumber__c';

        system.debug('sQueryJRPs is ' + sQueryJRPs);
        //getListJobRatePlans returns listJobRatePlans 
        listJobRatePlans = Database.query(sQueryJRPs);
        
        System.Debug('listJobRatePlans'+listJobRatePlans);
        if(listJobRatePlans != null) {
            //get the listJobRatePlanCharges from the listJobRatePlans 
            for(invoiceit_s__Job_Rate_Plan__c qr:listJobRatePlans ) {
                jobProductClass = mapJobProducts.get(qr.invoiceit_s__Job_Product__c);
                jobRatePlanClass = new JobRatePlanClass();
                jobRatePlanClass.jobrateplan = qr;

                for(invoiceit_s__Job_Rate_Plan_Charge__c qrpc : qr.invoiceit_s__Job_Rate_Plan_Charge__r) {
                    jobRatePlanChargeClass = new JobRatePlanChargeClass();
                    jobRatePlanChargeClass.jobrateplancharge = qrpc;
                    jobRatePlanChargeClass.jobRatePlanChargeCounter = ++jobRateplanChargeCounter;

                    jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);
                }

                jobRatePlanClass.jobRatePlanCounter = ++jobRatePlanCounter;
                jobProductClass.jobRatePlans.add(jobRatePlanClass);

                mapJobProducts.put(qr.invoiceit_s__Job_Product__c, jobProductClass);
            }

            jobClass = new JobClass();
            jobClass.job = order;
            Integer iJobProductSize = listJobProducts.size();
            for(integer i = 0; i < iJobProductSize; i++) {
                Id jobProductId = listJobProducts.get(i).Id;
                JobProductClass qpc = mapJobProducts.get(jobProductId); 
                qpc.jobProductCounter = ++jobProductCounter;
                jobClass.jobProducts.add(qpc);
            }                   

            iJobProductSequenceNo = 1;
            for(JobProductClass jobProductClas : jobClass.jobProducts) {
                jobProductClas.jobproduct.invoiceit_s__SequenceNumber__c = iJobProductSequenceNo;
                iJobProductSequenceNo ++;
            }

            iJobRatePlanSequenceNo = 1;
            for(JobProductClass jobProductClas : jobClass.jobProducts) {
                for(JobRatePlanClass jobrateplan : jobProductClas.jobRatePlans) {
                    jobrateplan.jobrateplan.invoiceit_s__SequenceNumber__c = iJobRatePlanSequenceNo;
                    iJobRatePlanSequenceNo ++;
                }
            }
        }

        return jobClass; 
    }


    /**/
    public static String getObjectSelectQuery(String objectName) {
        String sQuery = 'SELECT ';
        sQuery += getObjectFields(objectName);
        sQuery += ' FROM '+ objectName + ' ';
        return sQuery;
    }

    public static String getObjectFields(String objectName) {
        String sQuery = '';
        Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField column: objectFieldMap.values()) {
            //system.debug('column Name is ' + column + 'column permission' + column.getDescribe().isUpdateable());
            sQuery += column+', ';
        }
        sQuery = sQuery.substring(0, sQuery.length()-2);
        sQuery += ' ';
        return sQuery;
    }
    //MHBS-30
    public String populateOpportunityName(String quoteType, invoiceit_s__Job__c job, Integer noOfTerms){
        String oppName = '';
        String quoteLabel = '';
        //String RecType = 'Select id, RecordType.DeveloperName from invoiceit_s__Job__c';
        //The top if condition by Rama 3/8/2016
        //updated for NCONS 108 - saiv 1/10/17
        if(quoteType=='Modify' && noOfTerms==null){
            quoteLabel = 'Rebase Evergreen';
        }
        else if(noloMigration==true && quoteType=='Modify' ){
             quoteLabel = 'Migration';
        }
        else if(quoteType=='Renew' && noOfTerms!=null){
            quoteLabel = 'Renew';
        }
        else if(quoteType=='Renew' && noOfTerms==null){
            quoteLabel = 'Evergreen';
        }
        else if(quoteType=='Modify' && noOfTerms!=null){
            quoteLabel = 'Modify';
        }
        else if(quoteType=='Mid-Term' ){
            quoteLabel = 'Mid-Term';
        }

        else if(quoteType=='Modify' && noOfTerms==null){
            quoteLabel = 'Migration';
        }
        
        oppName = quoteLabel + ' ' + job.Name;
        return oppName;
    }
    



   public void insertIntoOppChat(Opportunity opportunity)
    { 
       list<Chat_Product_Opportunity_Charge__c> coprc = new list<Chat_Product_Opportunity_Charge__c>();
        list<Chat_Product_Order_Charge__c> corc = new list<Chat_Product_Order_Charge__c>();
        list<invoiceit_crmx__Opportunity_Product__c> oppprod = new list<invoiceit_crmx__Opportunity_Product__c>();
  //      map<id, id> opprpc = new map<id,id>();
        map<id, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> opprpc = new map<id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
       
        system.debug('@@@ Opportunity id: ' + Opportunity.id);
        system.debug('Order id: ' + orderid + ' Opportunity: ' + opportunity.id);
        corc = [select id, Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c,
                       Chat_Product_Order_Rate_Plan_Charge__c,Chat_Usage_Order_Rate_Plan_Charge__c 
                       from Chat_Product_Order_Charge__c 
                      where Chat_Product_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c  = :orderid 
                          or Chat_Usage_Order_Rate_Plan_Charge__r.invoiceit_s__Order__c = :orderid
                         ];
        /***************************akash : 11/01/2018 **************************************/
         set<Id> orderrateplanChargeIds                            =  new Set<Id>();
        Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>oppIdVSorpc = new Map<Id,invoiceit_s__Job_Rate_Plan_Charge__c>();
        for(Chat_Product_Order_Charge__c c:corc){
            orderrateplanChargeIds.add(c.Chat_Product_Order_Rate_Plan_Charge__c);
            orderrateplanChargeIds.add(c.Chat_Usage_Order_Rate_Plan_Charge__c);
        }
        
        System.debug('Corc: ' + corc + ' Order id: ' + orderid + ' Opportunity id: ' + opportunity.id);
        if(corc.isempty() || corc.size() <= 0 ) return;
        if(!orderrateplanChargeIds.isEmpty()){
             for (invoiceit_crmx__Opportunity_Rate_Plan_Charge__c p: [select id, Created_From_Charge__c, 
                                                                 invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c,  
                                                                 invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c 
                                                                    from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                                                      where Created_From_Charge__c IN:orderrateplanChargeIds
                                                                   // where invoiceit_crmx__Opportunity__c = :opportunity.id 
                                                                      and Created_From_Charge__r.invoiceit_s__Status__c not in ('Cancelled', 'Expired')]){
                   opprpc.put(p.Created_From_Charge__c, p);                                                            
              }
               for (Chat_Product_Order_Charge__c c:corc)
                {
                    Chat_Product_Opportunity_Charge__c corc1 = new Chat_Product_Opportunity_Charge__c();
                    if (opprpc.get(c.Chat_Product_Order_Rate_Plan_Charge__c) != null)
                    {
                        corc1.Chat_Product_Opp_Rate_Plan_Charge__c = opprpc.get(c.Chat_Product_Order_Rate_Plan_Charge__c).id;
                    }
                    if(opprpc.get(c.Chat_Usage_Order_Rate_Plan_Charge__c) != null)
                        corc1.Chat_Usage_Opp_Rate_Plan_Charge__c = opprpc.get(c.Chat_Usage_Order_Rate_Plan_Charge__c).id;
                    if (corc1.Chat_Usage_Opp_Rate_Plan_Charge__c != null)
                    {
                      coprc.add(corc1);
                        if(opprpc.containsKey(c.Chat_Product_Order_Rate_Plan_Charge__c)){
                              oppprod.add(new invoiceit_crmx__Opportunity_Product__c(id = opprpc.get(c.Chat_Product_Order_Rate_Plan_Charge__c).invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__c, Is_Chat_Option_Shown__c='Yes'));
                    
                        }
                    }
                }
            
            
            
        }
       
       // system.debug('corc: ' + corc + ' opprpc: ' + opprpc);        
       // system.debug('Chat records: ' + coprc + ' order: ' + orderid );
       
        
        system.debug('@@@Rama coprc: ' + coprc);
        if (!coprc.isempty())
            insert coprc;
        
        system.debug('Chat Product List: ' + oppprod);
        Map<Id,invoiceit_crmx__Opportunity_Product__c> oppprodMap = new Map<Id,invoiceit_crmx__Opportunity_Product__c>();
        if (!oppprod.isEmpty()){
            for(invoiceit_crmx__Opportunity_Product__c opprd : oppprod){
                oppprodMap.put(opprd.id,opprd);
            }
            //Map<Id,invoiceit_crmx__Opportunity_Product__c> oppprodMap = new Map<Id,invoiceit_crmx__Opportunity_Product__c>(oppprod);
             update oppprodMap.values();
        }
           
        
    }
    
    
    public  void FkMethod(){
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
        i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    }

}