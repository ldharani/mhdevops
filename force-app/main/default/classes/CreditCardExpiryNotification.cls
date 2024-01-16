/***********************************************************************************************************************
* @author - VR
* @date -  
* Ticket - MHBS-5416
* @description - Batch Job to send Credit Card Expiry Notification Email before 15,30 and 45 days of expiry
* @testclass - CreditCardExpiryNotification_Test

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-7502    VR            25/07/2022                   T01     Added Task Creation on successful email
MHBS-8966    Lakshmi       25/05/2023   Donna           T02     Added Payment Portal Link to the email body 
************************************************************************************************************************/

global  class CreditCardExpiryNotification implements Database.Batchable<Sobject>,Database.Stateful  {
    global Map<Integer,List<blng__PaymentMethod__c >> mapOfEmails ;
    global List<String> listOfPMEmails ; //T01
    global String BillingEmailAddress = System.Label.Martindale_Billing_Address; //<T02>
    global String MartindaleNoloLogo = System.Label.Martindale_Nolo_Logo;
    global String MartindaleBillingPhone = System.Label.Martindale_Billing_Phone;
    String PaymentMethodId;
    
    public CreditCardExpiryNotification()
    {
        mapOfEmails = new  Map<Integer,List<blng__PaymentMethod__c > >();
        
        listOfPMEmails = new List<String>(); //T01
        
        init('');
    }
    
    global void init(String PaymentMethodId){
        this.PaymentMethodId = PaymentMethodId;
    }
    
    global CreditCardExpiryNotification(String PaymentMethodId){
        mapOfEmails = new  Map<Integer,List<blng__PaymentMethod__c > >();
        
        listOfPMEmails = new List<String>(); //T01
        
        init(PaymentMethodId);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query = '';
        String currentMonth = String.valueOf(System.today().month());
        String currentYear = String.valueOf(System.today().year());
        String currentMonthPlus1 = String.valueOf(System.today().month()+1);
        String currentYearPlus1 = String.valueOf(System.today().year()+1);
        String currentMonthPlus2 = String.valueOf(System.today().month()+2);
        
        if(currentMonth.length()==1)
        {
            currentMonth = '0'+currentMonth;
        }
        if(currentMonthPlus1.length()==1)
        {
            currentMonthPlus1 = '0'+currentMonthPlus1;
        }
        if(currentMonthPlus2.length()==1)
        {
            currentMonthPlus2 = '0'+currentMonthPlus2;
        }
        
        if(currentMonth=='12')
        {
            currentMonthPlus1 = '01';
            currentMonthPlus2 = '02';
        }
        else if(currentMonth=='11')
        {
            currentMonthPlus2 = '01';
        }
        
        //and name=\'PM-17446\' //  and (name=\'PM-22413\')
        
        if(currentMonth=='12')
        {
            query = 'SELECT Id,blng__BillingEmail__c,blng__Nameoncard__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,Account_MH_Customer_Number__c,Account_Name__c,blng__CardNumber__c,Card_Number__c,blng__Account__c FROM blng__PaymentMethod__c where ((blng__CardExpirationMonth__c=:currentMonth and blng__CardExpirationYear__c=:currentYear)  or (blng__CardExpirationMonth__c=:currentMonthPlus1 and  blng__CardExpirationYear__c=:currentYearPlus1) or (blng__CardExpirationMonth__c=:currentMonthPlus2 and  blng__CardExpirationYear__c=:currentYearPlus1) ) and ( blng__Account__r.Customer_Status__c!=\'Former Sub\' and blng__Active__c=true and blng__AutoPay__c = true and blng__PaymentGatewayToken_c!=null)    '; //<T02>
            
        }
        else if(currentMonth=='11')
        {
            query = 'SELECT Id,blng__BillingEmail__c,blng__Nameoncard__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,Account_MH_Customer_Number__c,Account_Name__c,blng__CardNumber__c,Card_Number__c,blng__Account__c FROM blng__PaymentMethod__c where ((blng__CardExpirationMonth__c=:currentMonth and blng__CardExpirationYear__c=:currentYear)  or (blng__CardExpirationMonth__c=:currentMonthPlus1 and  blng__CardExpirationYear__c=:currentYear) or (blng__CardExpirationMonth__c=:currentMonthPlus2 and  blng__CardExpirationYear__c=:currentYearPlus1) ) and ( blng__Account__r.Customer_Status__c!=\'Former Sub\' and blng__Active__c=true and blng__AutoPay__c = true and blng__PaymentGatewayToken__c!=null  )    '; //<T02>
            
        }
        else 
        {
            query = 'SELECT Id,blng__BillingEmail__c,blng__Nameoncard__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,Account_MH_Customer_Number__c,Account_Name__c,blng__CardNumber__c,Card_Number__c,blng__Account__c FROM blng__PaymentMethod__c where ((blng__CardExpirationMonth__c=:currentMonth and blng__CardExpirationYear__c=:currentYear)  or (blng__CardExpirationMonth__c=:currentMonthPlus1 and  blng__CardExpirationYear__c=:currentYear) or (blng__CardExpirationMonth__c=:currentMonthPlus2 and  blng__CardExpirationYear__c=:currentYear) ) and ( blng__Account__r.Customer_Status__c!=\'Former Sub\' and blng__Active__c=true and blng__AutoPay__c = true and blng__PaymentGatewayToken__c!=null  )    ';//<T02>
            
        }
        
        If(test.isRunningTest())
        {
            query = 'SELECT Id,blng__BillingEmail__c,blng__Nameoncard__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,Account_MH_Customer_Number__c,Account_Name__c,blng__CardNumber__c,Card_Number__c,blng__Account__c FROM blng__PaymentMethod__c    ';
            
        } 
        
        if(!String.isEmpty(PaymentMethodId)){
            query = 'SELECT Id,blng__BillingEmail__c,blng__Nameoncard__c,blng__CardExpirationMonth__c,blng__CardExpirationYear__c,Account_MH_Customer_Number__c,Account_Name__c,blng__CardNumber__c,Card_Number__c,blng__Account__c FROM blng__PaymentMethod__c where Id =\''+PaymentMethodId+'\'';
        }
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc,List<blng__PaymentMethod__c> scope)
    {
        List<Task> tasklist = new List<Task>(); //T01
        System.debug('LENGTH '+scope.size());
        System.debug('scope '+scope);
        mapOfEmails.put(15,new List<blng__PaymentMethod__c >());
        mapOfEmails.put(30,new List<blng__PaymentMethod__c >());
        mapOfEmails.put(45,new List<blng__PaymentMethod__c >());
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: BillingEmailAddress];    //<T02> 
        
        for(blng__PaymentMethod__c pm:scope)
        {
            
            if(pm.blng__CardExpirationYear__c!=null && pm.blng__CardExpirationMonth__c!=null && pm.blng__BillingEmail__c!=null){
                Date dueDate = Date.newInstance(Integer.valueOf(pm.blng__CardExpirationYear__c), Integer.valueOf(pm.blng__CardExpirationMonth__c), 30);
                if(pm.blng__CardExpirationMonth__c=='2')
                {
                    dueDate = Date.newInstance(Integer.valueOf(pm.blng__CardExpirationYear__c), Integer.valueOf(pm.blng__CardExpirationMonth__c), 28);
                }
                Integer Day = Date.Today().day();
                Integer Month = Date.Today().month();
                Integer year = Date.Today().year();
                Date currentDate = Date.newInstance(year,Month,15);
                
                if(Day>=1 && Day<=14)
                {
                    currentDate = Date.newInstance(year,Month,1);
                }
                Integer numberDaysDue = currentDate.daysBetween(dueDate);
                System.debug('numberDaysDue '+numberDaysDue);
                //expd - shed           
                if(numberDaysDue<=18){  //dec 31,2021 - dec 15 2021 = 16;
                    mapOfEmails.get(15).add(pm);
                    mapOfEmails.put(15,mapOfEmails.get(15));
                }
                else if(numberDaysDue<=33)  //feb 1 - dec 30 = 33; may 1 - march 30 = 32 ; march 1 - jan 30 = 31;
                {
                    mapOfEmails.get(30).add(pm);
                    mapOfEmails.put(30,mapOfEmails.get(30));
                }
                else if(numberDaysDue<=49)  //jan 31,2022 - dec 15 2021 = 47; 
                {
                    mapOfEmails.get(45).add(pm);
                    mapOfEmails.put(45,mapOfEmails.get(45));
                }
            }
        }
        System.debug('mapOfEmailsexecute'+mapOfEmails);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> accIds = new Set<Id>();
        for(Integer key: mapOfEmails.keySet())
        {
            for(blng__PaymentMethod__c pm:mapOfEmails.get(key))
            {
                {
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    List<String> sendTo = new List<String>();
                    sendTo.add(pm.blng__BillingEmail__c);
                    listOfPMEmails.add(pm.blng__BillingEmail__c);
                    mail.setWhatId(pm.blng__Account__c);    //T01
                    mail.setToAddresses(sendTo);
                    accIds.add(pm.blng__Account__c);
                    //mail.setSenderDisplayName('Internet Brands'); //cannot be used , as do not reply is being set as from 
                    mail.setSubject('Credit Card Expiration Notice - '+pm.Account_MH_Customer_Number__c+' '+pm.Account_Name__c);
                    
                    String body = 'Dear Valued Customer, <br></br>';
                    body += '<br></br>';
                    body += 'The Credit Card on file for Auto Payment for '+pm.Account_Name__c+' will expire in '+key+' days.<br></br>';
                    body += '<br></br>';
                    body += 'Credit Card: '+pm.Card_Number__c+'<br></br>';
                    body += '<br></br>';
                    body += 'Please update your billing information online by clicking the payment link portal.martindalenolo.com or by calling the Billing Department directly.<br></br>'; //<T02>
                    body += '<br></br>';
                    body += 'Sincerely, <br></br>';
                    body += '<br></br>';
                    body += 'Martindale-Hubbell Billing Department';
                    body += '<br></br>' +MartindaleBillingPhone;
                    body += '<br></br>'+ BillingEmailAddress + '<br></br>';
                    body += '<img src =\"' + MartindaleNoloLogo + '\"></img>';
                    mail.setHtmlBody(body);
                    
                    mails.add(mail);
                }
            }
        }
        
        //T01
        
        
        List<Messaging.SendEmailResult> mrs = new List<Messaging.SendEmailResult>();
        
        // if(!test.isrunningtest())    //T01 //Adding try-catch in test class
        mrs =  Messaging.sendEmail(mails);
        
        System.debug('mrs '+mrs);
        List<Contact> contacts = [Select ID,Email from Contact where Email IN:listOfPMEmails];
        Map<String,Contact> mapOfEmailVsContact = new Map<String,Contact>();
        for(Contact con:contacts)
        { 
            mapOfEmailVsContact.put(con.Email,con);
        }
        Integer i =0;
        for (Messaging.SendEmailResult mr : mrs) 
        {
            if (mr.isSuccess()) {
                
                blng__PaymentMethod__c pm = scope[i];
                
                Task task = new Task();
                task.Subject = mails[i].getSubject();
                task.Status = 'Open';
                task.Priority = 'Normal';
                task.WhatId = mails[i].getWhatID();
                task.ActivityDate=System.today();
                if(mapOfEmailVsContact.get(pm.blng__BillingEmail__c)!=null){
                    task.WhoId = mapOfEmailVsContact.get(pm.blng__BillingEmail__c).ID;
                }
                tasklist.add(task);
            }
            else{
                // Operation failed, so get all errors     
                Task task = new Task();  
                task.Subject = 'Error in sending Credit Card Expiration Notice Email';
                task.Status = 'Open';
                task.Priority = 'High';
                task.ActivityDate=system.today();
                task.WhatId = mails[i].getWhatID();
                task.Description = '';
                for(Messaging.SendEmailError err : mr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('fields that affected this error: ' + err.getFields());
                    task.Description += err.getMessage();
                }
                tasklist.add(task);
            }
            i++;
        }
        if(tasklist.size() > 0){
            Insert tasklist;
        }
        
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}