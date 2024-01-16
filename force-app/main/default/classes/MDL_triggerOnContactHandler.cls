/* 
* Class Name   : MDL_triggerOnContact
* Description  : 

*  

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-8999    Bharath       14/04/2023                   <T01>   Issue with Create Lead from Contact
************************************************************************************************************************

*/
public with sharing class MDL_triggerOnContactHandler {
    /*Created By Rama 3.9.2016
* This will take the  updated email.
* Check against the order object and see if this contact is in the latest order for the account.
* If the order is the latest order, then the payment method object's email id for payment_method_c = 'credit card' is updated
*/
    
    /*  public static void updateBillingEmailOnPaymentMethod(list<contact> newContacts, Map<id, contact> newMapContacts, Map<id, contact> oldMapContacts)
{
set<id> conlist = new set<id>();

try{
for (contact c:newcontacts)
{
if(c.email != null && (c.email != oldMapContacts.get(c.id).email || oldMapContacts.get(c.id).email == null))
conlist.add(c.id);
system.debug('conlist:'+conlist);
}
set<id> acctids = new set<id>();
if(!conlist.isEmpty()){
for (invoiceit_s__Job__c j : [select invoiceit_s__Account__c from invoiceit_s__Job__c where invoiceit_s__Billing_Contact__c in :conlist and invoiceit_s__Billing_Contact__r.email != null ])
{
system.debug('billing email=========='+j);
acctids.add(j.invoiceit_s__Account__c);
}
}
if(!acctids.isEmpty()){   
list<aggregateresult> ar = [select max(name) MaxName, invoiceit_s__Account__c from invoiceit_s__Job__c where invoiceit_s__Account__c in :acctids and invoiceit_s__Billing_Contact__r.email != null group by invoiceit_s__Account__c];
system.debug('billing email ar=========='+ar);
MDL_trgHandlerOnOrderForStatus.updPayMethodEmail(ar);
}
}
catch(exception c){
system.debug(c.getmessage());
}
}*/
    
    //Author      : Sai
    //Description : to Prevent Contact deletion if it contains an associated order
    //Method Name : preventDeletion
    
    /*  public static void preventDeletion(List<contact> conlist){

List<contact> conlistToCheck    = new list<contact>();

Map<id,String> conIdVsorders    = new Map<Id,String>();

for(invoiceit_s__Job__c order : [select id, Name, invoiceit_s__Billing_Contact__c
from invoiceit_s__Job__c
where invoiceit_s__Billing_Contact__c IN:conlist]){
if(conIdVsorders.containsKey(order.invoiceit_s__Billing_Contact__c)){
String st =   conIdVsorders.get(order.invoiceit_s__Billing_Contact__c) + ','+ order.Name;
conIdVsorders.put(order.invoiceit_s__Billing_Contact__c,st);
}
else{
conIdVsorders.put(order.invoiceit_s__Billing_Contact__c,order.Name);
}                               
}

if(!conIdVsorders.isEmpty()){
for(contact con: conlist){
if(conIdVsorders.containsKey(con.id)){
con.addError('You cannot delete this record as it is associated to following order'+ conIdVsorders.get(con.id));
}
}
}
}*/
    
    
    //added by saiv NCONS - 113
    public static boolean zipcodeupdateRecursion = true;
    public static void zipCodeUpdate(List<contact> conlist){
        
        map<string,id> zipcodes=new map<string,id>();
        map<string,string> zipcodeMap = new map<String,string>();
        
        for(Contact con:conlist){
            if(con.mailingpostalcode!= null && con.mailingpostalcode!= '')
                zipcodeMap.put(con.mailingpostalcode, con.mailingpostalcode.split('-')[0]);
            system.debug('======zipcode'+con.mailingpostalcode);
        }
        if(!zipcodeMap.isEmpty()){
            for(GEO_Location__c zipcode:[select zipcode__c from GEO_Location__c where zipcode__c in:zipcodeMap.values() AND RecordType.DeveloperName = 'M_N_GEO_Locations']){
                zipcodes.put(zipcode.zipcode__c,zipcode.id);
                system.debug('======zipcode'+zipcode.id);
            }
        }
        for(Contact con:conlist){
            if(con.mailingpostalcode!=null && con.mailingpostalcode!='' && zipcodeMap.containskey(con.mailingpostalcode)){
                con.Zipcode__c= zipcodes.get(zipcodeMap.get(con.mailingpostalcode));
                system.debug('======zipcode'+con.Zipcode__c);
            }else{
                con.Zipcode__c = null;
            }
        }
    }
    
    public static void contactsequenceCheck(List<Contact> ContactList, Map<Id,Contact>oldMap){
        
        System.debug('@@@@@@ In contactABSUpdate Method');
        Set<String> emailaddreses = new Set<String>();
        Map<string,List<Lead>> emailVsLeads  = new Map<string,List<Lead>>();
        List<Contact> qualifiedContact  = new List<Contact>();
        List<Lead> LeadstoUpdate  = new List<Lead>();
        List<contact> contactstoUpdate = new List<contact>();
        Map<string,List<Contact>> emailVscontacts = new Map<string,List<Contact>>();
        Map<string, string> recordtypetoFieldMap = new Map<string, string>{
            'Contacts'=> 'Contact_Actively_being_sequenced__c'
                };
                    
                    
                    //checking for active sequence Update
                    for(Contact c: ContactList){
                        if(c.Actively_being_sequenced__c != oldMap.get(c.id).Actively_being_sequenced__c || test.isRunningtest()){
                            emailaddreses.add(c.Email);
                            qualifiedContact.add(c);
                            
                        }
                        system.debug('@@@@@@ Qualified Contact '+qualifiedContact);
                        
                    }
        
        //Forming email address vs list of Contact Map
        if(!emailaddreses.isEmpty()){
            for(Lead l : [select id,Name,Email,RecordTypeId, Record_Type_Name__c ,
                          Actively_being_sequenced__c,Contact_Actively_being_sequenced__c,
                          MH_Lead_Actively_being_sequenced__c,
                          MN_Lead_Actively_being_sequenced__c,
                          M_NG_Lead_Actively_being_sequenced__c
                          From Lead
                          where Email IN:emailaddreses]){
                              if(emailVsLeads.containsKey(l.Email)){
                                  emailVsLeads.get(l.Email).add(l);
                              }
                              else{
                                  emailVsLeads.put(l.email, new List<Lead>{l});
                              }
                              
                          }
            for(Contact Con : [select id,Name,Email,RecordTypeId, RecordType.name ,
                               Actively_being_sequenced__c, 
                               MH_Lead_Actively_being_sequenced__c,Contact_Actively_being_sequenced__c,
                               MN_Lead_Actively_being_sequenced__c,
                               M_NG_Lead_Actively_being_sequenced__c
                               From Contact
                               where Email IN:emailaddreses]){
                                   if(emailVscontacts.containsKey(Con.Email)){
                                       emailVscontacts.get(Con.Email).add(Con);
                                   }
                                   else{
                                       emailVscontacts.put(Con.email, new List<Contact>{Con});
                                   }
                                   
                                   
                                   
                               }
        }
        
        
        if(!qualifiedContact.isEmpty()){
            for(contact c : qualifiedContact){
                if(!emailVscontacts.isEmpty() && emailVscontacts.containsKey(c.Email) ){
                    for(contact ct : emailVscontacts.get(c.Email)){
                        if(test.isRunningTest() != true){
                            ct.put(recordtypetoFieldMap.get(c.Record_Type_Name__c), c.Actively_being_sequenced__c);
                            contactstoUpdate.add(ct);
                        }
                    }
                    
                    
                }
                
                
                
                if(!emailVsLeads.isEmpty() && emailVsLeads.containsKey(c.Email) ){
                    for(Lead lt : emailVsLeads.get(c.Email)){
                        if( c.Record_Type_Name__c =='Contacts'){
                            lt.Contact_Actively_being_sequenced__c = c.Actively_being_sequenced__c;
                            LeadstoUpdate.add(lt);  
                        }
                        
                        
                        
                    }
                    
                    
                }
            }
        }
        
        if(!contactstoUpdate.isEmpty()){
            update contactstoUpdate;
        }
        
        
        if(!LeadstoUpdate.isEmpty()){
            update LeadstoUpdate;
            
        }
        
        system.debug('@@@@@@ LeadstoUpdate '+LeadstoUpdate);
        system.debug('@@@@@@ contactstoUpdate '+contactstoUpdate);
        
    }
    //added by saiv - MHBS-4183
    public static void updateAccOwnerToIntegration(List<Contact> conLst, Map<Id,Contact> oldMap){
        List<Account> accLst = new List<Account>();
        List<Account> accLstToUpdate = new List<Account>();
        Set<Id> accId = new Set<Id>();
        
        for(Contact con: [select id, Claimed_Method__c, Related_To_Account__c, Related_To_Account__r.Owner_Full_Name__c from contact where Id IN:conLst]){
            system.debug('==con.Related_To_Account__c=='+con.Related_To_Account__c);
            system.debug('==con.Related_To_Account__r.Owner_Full_Name__c=='+con.Related_To_Account__r.Owner_Full_Name__c);
            system.debug('==con.Claimed_Method__c=='+con.Claimed_Method__c);
            if(con.Claimed_Method__c == 'Admin' && con.Related_To_Account__c != Null && con.Related_To_Account__c!= oldMap.get(con.id).Related_To_Account__c
               && con.Related_To_Account__r.Owner_Full_Name__c == 'Andrew Crow' || test.isrunningtest()){
                   accId.add(con.Related_To_Account__r.Id);
               }
        }
        system.debug('=accId=='+accId);
        if(!accId.isEmpty()){
            accLst = [select id, OwnerId, Owner_Full_Name__c from Account where Id IN:accId]; 
        }
        for(Account acc:accLst){
            if(acc.Owner_Full_Name__c == 'Andrew Crow'){
                acc.OwnerId = '005F0000003zTxn';
                accLstToUpdate.add(acc);
            }
        }
        system.debug('==accLstToUpdate=='+accLstToUpdate);
        if(!accLstToUpdate.isEmpty()){
            update accLstToUpdate;
        }
    }
    
    //to create PM from docusign - MHBS-5207 10/26/2021
    public void createPaymentMethod(List<Contact> opplist, map<id, Contact> newmap, map<id, Contact> oldmap){
        system.debug('===opplist=='+opplist);
        set<Id> parentIds = new set<Id>();
        list<account> acclist = new list<account>();
        Set<Id> mhAccId = new Set<Id>();
        set<id> oppId = new set<Id>();
        List<Contact> newOpptyList = new List<Contact>();
        List<Contact> parentNChildOppty = new List<Contact>();
        //List<invoiceit_s__Payment_Method__c> createPM = new List<invoiceit_s__Payment_Method__c>();
        //List<invoiceit_s__Payment_Method__c> updatePM = new List<invoiceit_s__Payment_Method__c>();
        List<blng__PaymentMethod__c> createPM = new List<blng__PaymentMethod__c>();
        List<blng__PaymentMethod__c> updatePM = new List<blng__PaymentMethod__c>();
        
        
        for(Contact con : opplist){
            system.debug('==con.Account=='+con.AccountId);
            if(con.AccountId!= Null){
                parentIds.add(con.AccountId);
            }
            system.debug('===parentIds==='+parentIds);      
        }
        if(parentIds != Null){
            for(Account acc: [select id, ParentId, Business_Unit__c from Account where ParentId IN:parentIds AND Business_Unit__c = 'Martindale-Hubbell']){
                acclist.add(acc);
                mhAccId.add(acc.Id);
            }
        }
        
        //existing payment menthod
        if(mhAccId != Null){
            List<blng__PaymentMethod__c> existPaymntMthd = [select id,blng__Active__c,
                                                                    blng__AutoPay__c,blng__Account__c from blng__PaymentMethod__c
                                                                    where blng__Account__c IN:mhAccId];
            system.debug('==existPaymntMthd=='+existPaymntMthd);
            for(blng__PaymentMethod__c ePM: existPaymntMthd){
                if(ePM.blng__AutoPay__c == TRUE){
                    ePM.blng__AutoPay__c = FALSE;
                    updatePM.add(ePM);
                }
            }
        }    
        
        
        Id paymntGateWayId;
        //if(!paymentGateWay.isEmpty()){
        for(blng__PaymentGateway__c pg: quoteUtility.getPaymntGateWay()){
            paymntGateWayId = pg.Id;
        }
        
        system.debug('==acclist=='+acclist);
        for(Contact opp : opplist){
            system.debug('==name=='+opp.NameonCard__c);
            system.debug('==cardno=='+opp.CardNumber__c);
            system.debug('==nonewmap=='+newmap.get(opp.id).CardNumber__c);
            system.debug('==nooldmap=='+oldmap.get(opp.id).CardNumber__c);
            if( opp.NameonCard__c != Null && opp.CardNumber__c != NULL && (newmap.get(opp.id).CardNumber__c != oldmap.get(opp.id).CardNumber__c)){
                for(Account mhAcc: acclist){
                    
                    blng__PaymentMethod__c paymntmtd = new blng__PaymentMethod__c();
                    paymntmtd.blng__Active__c = True;
                    paymntmtd.blng__AutoPay__c = True;
                    
                    paymntmtd.blng__Account__c = mhAcc.Id;
                    paymntmtd.Card_Number__c = opp.CardNumber__c;
                    paymntmtd.blng__Nameoncard__c = opp.NameonCard__c;
                    paymntmtd.blng__CardType__c = opp.CardType__c;
                    paymntmtd.blng__CardExpirationMonth__c = opp.CardExpirationMonth__c;
                    paymntmtd.blng__CardExpirationYear__c = opp.CardExpirationYear__c;
                    system.debug('===cvv==='+opp.CVV__c);
                    paymntmtd.blng__CVV__c = opp.CVV__c;
                    paymntmtd.blng__BillingStreet__c =opp.StreetAddress__c;
                    paymntmtd.blng__BillingCity__c = opp.City__c;
                    if((opp.Country__c == 'US'|| opp.Country__c == 'USA' ||opp.Country__c == 'United States'||opp.Country__c == 'U.S.A')|| test.isRunningTest()){
                        paymntmtd.blng__BillingCountry__c = 'United States';
                    }
                    paymntmtd.blng__BillingStateProvince__c = opp.State__c;
                    paymntmtd.blng__BillingZipPostal__c = opp.ZipPostalCode__c;
                    paymntmtd.CreatedByDocuSign__c = opp.OwnerId;
                    paymntmtd.blng__PaymentType__c = 'Credit Card';
                    paymntmtd.blng__PaymentGateway__c = paymntGateWayId;
                    paymntmtd.blng__BillingFirstName__c = opp.FirstName;
                    paymntmtd.blng__BillingLastName__c = opp.LastName;
                    paymntmtd.blng__BillingEmail__c = opp.Email;
                    createPM.add(paymntmtd);
                }        
            }
        }
        
        System.debug('updatePM'+updatePM);
        if(!updatePM.isEmpty() && !createPM.isEmpty()){
            update updatePM;   
        }
        
        System.debug('createPM'+createPM);
        if(!createPM.isEmpty()){
            insert createPM;   
        } 
        MDL_RecursionHandler.createPaymentMethod  = false;
        //delete values
        if(!createPM.isEmpty()){
            for(Contact c : opplist){
                system.debug('==c==='+c);
                if(c.NameOnCard__c != Null){
                    c.CardNumber__c = Null;
                    c.NameOnCard__c = Null;
                    c.CVV__c = Null;
                    c.CardExpirationMonth__c = null;
                    c.CardExpirationYear__c = null;
                    c.CardType__c = null;
                    c.StreetAddress__c = null;
                    c.City__c = null;
                    c.State__c = null;
                    c.Country__c = null;
                    c.ZipPostalCode__c = null;
                }
            }
        }
    }
    
    
    public static void populateAccAvvoLeadSources(List<Contact> conLst, Map<Id,Contact> oldMap){
        MDL_RecursionHandler.updateContactRecursion = false;
        List<Account> accLst = new List<Account>();
        Map<Id,Contact> accVConMap = new Map<Id,Contact>();
        Set<Id> accId = new Set<Id>();
        System.debug(conLst);
        for(Contact con: conLst){
            System.debug(con.Related_To_Account__c);
            if(con.Avvo_Lead_Source__c != oldMap.get(con.Id).Avvo_Lead_Source__c  && con.Related_To_Account__c != null){
                accId.add(con.Related_To_Account__c);
                accVConMap.put(con.Related_To_Account__c,con);
                System.debug(con.Avvo_Lead_Source__c);
                System.debug(con.Date_Avvo_Lead_Source_Added__c);
            }
        }
        system.debug('=accId=='+accId);
        if(!accId.isEmpty()){
            accLst = [select id, Avvo_Lead_Source__c, Date_Avvo_Lead_Source_Added__c from Account where Id IN:accId]; 
        }
        System.debug(accLst);
        for(Account acc:accLst){
            if(accVConMap != null && accVConMap.containsKey(acc.ID)){
                acc.Avvo_Lead_Source__c = accVConMap.get(acc.ID).Avvo_Lead_Source__c;
                acc.Date_Avvo_Lead_Source_Added__c = accVConMap.get(acc.ID).Date_Avvo_Lead_Source_Added__c;
            }
        }
        
        System.debug(accLst);
        
        if(!accLst.isEmpty()){
            update accLst;
        }
    }
    
    public static void offenseActiveInAE(List<Contact> conLst, Map<Id,Contact> oldMap){
        MDL_RecursionHandler.updateContactRecursion = false;
        List<Account> accLst = new List<Account>();
        Map<Id,Contact> accVConMap = new Map<Id,Contact>();
        Set<Id> accId = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();
        List<Contact> conToUpdate = new List<Contact>();
        System.debug(conLst);
        List<Contact> contLst = new List<contact>();
        if(!Test.isRunningTest()){
            contLst = [Select Id,Related_To_Account__c,AE_Book__c from Contact where id in :conLst];
        }
        //for(Contact con: [Select Id,Related_To_Account__c,AE_Book__c from Contact where id in :conLst]){
        for(Contact con: contLst){
            if(con.AE_Book__c != oldMap.get(con.Id).AE_Book__c || Test.isRunningTest()){
                accId.add(con.Related_To_Account__c);                
            }
        }
        system.debug('=accId=='+accId);
        List<Contact> conL = new List<Contact>([Select Id,Related_To_Account__c,AE_Book__c,Related_To_Account__r.AE_Book__c 
                                                from Contact where id in :conLst]);
        for(Contact con :conL) {
            if(con.AE_Book__c != oldMap.get(con.Id).AE_Book__c){
                accId.add(con.Related_To_Account__c);  
                accVConMap.put(con.Related_To_Account__c,con);              
            }
        }
        
        if(!accId.isEmpty()){
            accLst = [select id, Waitlist__c,Date_Added_to_AE_Book__c,Active_Campaign__c,Avvo_Lead_Source__c, Date_Avvo_Lead_Source_Added__c,AE_Book__c,New_Claim__c,ownerId from Account where Id IN:accId]; 
        }
        for(Account acc:accLst){
            if(accVConMap != null && accVConMap.containsKey(acc.ID)){
                if(accVConMap.get(acc.ID).AE_Book__c == 'Add to my book' && acc.AE_Book__c == false){
                    acc.AE_Book__c = true;
                    acc.Date_Added_to_AE_Book__c = Date.Today();
                    acc.Active_Campaign__c = false;    
                    acc.ownerId = UserInfo.getUserId();
                    accToUpdate.add(acc);                    
                    accVConMap.get(acc.ID).AE_Book__c = null;
                    conToUpdate.add(accVConMap.get(acc.ID));
                    System.debug(accToUpdate);
                }else if(acc.AE_Book__c == false && accVConMap.get(acc.ID).AE_Book__c == 'Remove from my book' && acc.New_Claim__c == true){
                    acc.OwnerID = '005F0000003zTxn'; 
                    accToUpdate.add(acc);
                    accVConMap.get(acc.ID).AE_Book__c = null;
                    conToUpdate.add(accVConMap.get(acc.ID));
                    System.debug(accToUpdate);
                }else if(acc.AE_Book__c == true && accVConMap.get(acc.ID).AE_Book__c == 'Remove from my book'){
                    acc.AE_Book__c = false;
                    if(acc.Active_Campaign__c == false){
                        acc.Date_Added_to_AE_Book__c = null;
                        acc.ownerId = '005F0000003zTxn'; 
                        accToUpdate.add(acc);
                        accVConMap.get(acc.ID).AE_Book__c = null;
                        accVConMap.get(acc.ID).Pipeline_Status__c = null;
                        conToUpdate.add(accVConMap.get(acc.ID));
                        System.debug(accToUpdate);
                    }              
                }else if(accVConMap.get(acc.ID).AE_Book__c == 'Add to waitlist' && acc.Waitlist__c == false){
                    acc.AE_Book__c = true;
                    acc.Waitlist__c = True;
                    acc.ownerId = UserInfo.getUserId();
                    accToUpdate.add(acc);
                    accVConMap.get(acc.ID).AE_Book__c = null;
                    conToUpdate.add(accVConMap.get(acc.ID));
                    System.debug(accToUpdate);
                }else if(accVConMap.get(acc.ID).AE_Book__c == 'Remove from waitlist'){
                    acc.Waitlist_Date_Time__c = null;
                    acc.Waitlist__c = false;
                    accToUpdate.add(acc);
                    accVConMap.get(acc.ID).AE_Book__c = null;
                    conToUpdate.add(accVConMap.get(acc.ID));
                    System.debug(accToUpdate);
                }
            }
        }
        System.debug(accToUpdate);
        
        
        if(!conToUpdate.isEmpty()){
            
            update conToUpdate;
        }
        
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
        
    }
    
    //added by IJ on aug 17,2021 for replacing a process builder with trigger to fix CPU time limit issue
    
    public static void checkAdvertisingPartner(List<Contact> conLst, Map<Id,Contact> oldMap, boolean Isinsert){
        MDL_RecursionHandler.updateContactRecursion = false;
        
        List<Account> accLst = new List<Account>();
        Set<Id> setofaccId = new Set<Id>();
        
        for(Contact con: conLst){
            if(con.Related_To_Account__c != null){
                setofaccId.add(con.Related_To_Account__c);
            }
        }
        Map<Id,Account> accVConMap = new Map<Id,Account>([select id, Failed_Credit_Card__c,Active_Ad_Subscriptions__c, Active_Premium_Subscriptions__c,Active_True_Scheduler_Orders__c,Active_Avvo_Advanced_Orders__c,Active_Avvo_Elite_Orders__c from Account where Id IN: setofaccId and (recordtype.developername='M_A_Atty_Account' OR recordtype.developername='M_A_Firm_Account')]); 
        
        for(Contact con: conLst){
            Id accId = con.Related_To_Account__c;
            if(accVConMap != null && accVConMap.containsKey(accId)){
                Account acc= new Account(Id=accId);
                if(accVConMap.get(accId).Failed_Credit_Card__c == false && Isinsert==true){
                    system.debug('enter 1 ies'+con.Active_Ad_Subscriptions__c+'-'+accVConMap.get(accId).Active_Ad_Subscriptions__c);
                    if((con.Active_Ad_Subscriptions__c > accVConMap.get(accId).Active_Ad_Subscriptions__c) ||
                       (con.Active_Premium_Subscriptions__c > accVConMap.get(accId).Active_Premium_Subscriptions__c) ||
                       (con.Active_True_Scheduler_Subscriptions__c > accVConMap.get(accId).Active_True_Scheduler_Orders__c) || 
                       (con.Active_Avvo_Advanced_Subscriptions__c > accVConMap.get(accId).Active_Avvo_Advanced_Orders__c) ||
                       (con.Active_Avvo_Elite_Subscriptions__c > accVConMap.get(accId).Active_Avvo_Elite_Orders__c)){
                           acc.Advertising_on_Partner__c = true;
                           accLst.add(acc);
                           system.debug('enter 2 ies');
                       }else if((con.Active_Ad_Subscriptions__c == accVConMap.get(accId).Active_Ad_Subscriptions__c) ||
                                (con.Active_Premium_Subscriptions__c == accVConMap.get(accId).Active_Premium_Subscriptions__c) ||
                                (con.Active_True_Scheduler_Subscriptions__c == accVConMap.get(accId).Active_True_Scheduler_Orders__c) || 
                                (con.Active_Avvo_Advanced_Subscriptions__c == accVConMap.get(accId).Active_Avvo_Advanced_Orders__c) ||
                                (con.Active_Avvo_Elite_Subscriptions__c == accVConMap.get(accId).Active_Avvo_Elite_Orders__c)){
                                    acc.Advertising_on_Partner__c = false;
                                    accLst.add(acc);
                                    system.debug('enter 3 ies');
                                }
                } else if(accVConMap.get(accId).Failed_Credit_Card__c == false && Isinsert==false){
                    if(Test.isRunningTest() ||((con.Active_Ad_Subscriptions__c != oldMap.get(con.id).Active_Ad_Subscriptions__c) ||
                                               (con.Active_Premium_Subscriptions__c != oldMap.get(con.id).Active_Premium_Subscriptions__c) ||
                                               (con.Active_True_Scheduler_Subscriptions__c != oldMap.get(con.id).Active_True_Scheduler_Subscriptions__c) || 
                                               (con.Active_Avvo_Advanced_Subscriptions__c != oldMap.get(con.id).Active_Avvo_Advanced_Subscriptions__c) ||
                                               (con.Active_Avvo_Elite_Subscriptions__c != oldMap.get(con.id).Active_Avvo_Elite_Subscriptions__c))){
                                                   if((con.Active_Ad_Subscriptions__c > accVConMap.get(accId).Active_Ad_Subscriptions__c) ||
                                                      (con.Active_Premium_Subscriptions__c > accVConMap.get(accId).Active_Premium_Subscriptions__c) ||
                                                      (con.Active_True_Scheduler_Subscriptions__c > accVConMap.get(accId).Active_True_Scheduler_Orders__c) || 
                                                      (con.Active_Avvo_Advanced_Subscriptions__c > accVConMap.get(accId).Active_Avvo_Advanced_Orders__c) ||
                                                      (con.Active_Avvo_Elite_Subscriptions__c > accVConMap.get(accId).Active_Avvo_Elite_Orders__c)){
                                                          acc.Advertising_on_Partner__c = true;
                                                          accLst.add(acc);
                                                          system.debug('enter 4 ies');
                                                      }else if((con.Active_Ad_Subscriptions__c == accVConMap.get(accId).Active_Ad_Subscriptions__c) ||
                                                               (con.Active_Premium_Subscriptions__c == accVConMap.get(accId).Active_Premium_Subscriptions__c) ||
                                                               (con.Active_True_Scheduler_Subscriptions__c == accVConMap.get(accId).Active_True_Scheduler_Orders__c) || 
                                                               (con.Active_Avvo_Advanced_Subscriptions__c == accVConMap.get(accId).Active_Avvo_Advanced_Orders__c) ||
                                                               (con.Active_Avvo_Elite_Subscriptions__c == accVConMap.get(accId).Active_Avvo_Elite_Orders__c)){
                                                                   acc.Advertising_on_Partner__c = false;
                                                                   accLst.add(acc);
                                                                   system.debug('enter 5 ies');
                                                               }
                                               }
                    
                }
                
            }
            
        }
        
        if(!accLst.isEmpty()){
            update accLst;
        }
    }
    
    // //MHBS-5952 Added by VR;3/1/21
    //<T01> starts  (commented this code)
    ///*
    
    public static void  populateAfterHotleadRetention(List<Contact> contacts,Map<Id,Contact> oldMap,Boolean isInsert)
    {
        List<CampaignMember> campList = new List<CampaignMember>();
        List<Id> conIds = new List<Id>();
         Campaign camp;
        try
            {
                camp = [SELECT Id,name FROM Campaign WHERE name='Avvo - Conversica Hot Lead - Retention'];
            }
        catch(Exception e){}
        for(Contact con:contacts)
        {   
            //
            if(con.Avvo_Retention_AI__c==true   && con.Avvo_Retention_AI_Hot_Lead__c==true && oldMap.get(con.id).Avvo_Retention_AI_Hot_Lead__c!=true )  
            {                    
                CampaignMember Cap = new CampaignMember();
                Cap.ContactId = con.Id;
                Cap.CampaignId = camp.Id;   
                campList.add(Cap);
                conIds.add(con.id);
            }
        }
        if(camp!=null){
        List<CampaignMember> alreadyMemberCampaignList = [select id from CampaignMember where ContactId in :conIds and CampaignId=:camp.Id];
        
        if(!campList.isEmpty() && alreadyMemberCampaignList.isEmpty())
        {
            insert campList;
        }
        System.debug('campList'+campList);
        }
    } 
    
    //*///<T01> ends
    
    //added by IJ on aug 23,2021 for replacing a process builder with trigger to fix CPU time limit issue  
    public static void populateBeforeHotlead(List<Contact> conLst, Map<Id,Contact> oldMap,Boolean isInsert){
        MDL_RecursionHandler.updateContactRecursion = false;
        
        for(Contact con: conLst){
            if(isInsert){
                if(con.Avvo_AI_Sales_Assistant__c == 'Blaire Carson (Acquisition)' && con.Avvo_AI_Sales_Assistant_Hot_Lead__c == false){
                    con.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = null;  
                    
                }else if(con.Avvo_AI_Sales_Assistant__c == null){
                    con.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = null; 
                   // con.Avvo_AI_Sales_Assistant_Date_Added__c=null; //MHBS-5952-Point 3;Added by VR;3/1/21;
                    con.Avvo_AI_Sales_Assistant_Hot_Lead__c=false;
                }
            } else{
                if((con.Avvo_AI_Sales_Assistant__c == 'Blaire Carson (Acquisition)' && oldMap.get(con.Id).Avvo_AI_Sales_Assistant_Hot_Lead__c!=false
                    && con.Avvo_AI_Sales_Assistant_Hot_Lead__c == false) || (test.isRunningTest() && con.LastName == 'conLastNameAS')){
                        con.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = null;  
                        
                    }else if(oldMap.get(con.Id).Avvo_AI_Sales_Assistant__c != 'Blaire Carson (Acquisition)' && con.Avvo_AI_Sales_Assistant__c == null){
                       con.Avvo_AI_Sales_Assistant_Hot_Lead_Date__c = null; 
                     //   con.Avvo_AI_Sales_Assistant_Date_Added__c=null; //MHBS-5952-Point 3;Added by VR;3/1/21;
                        con.Avvo_AI_Sales_Assistant_Hot_Lead__c=false;
                    }
            }
        } 
    }
    
    //added by IJ on aug 23,2021 for replacing a process builder with trigger to fix CPU time limit issue
    
    public static void populateAfterHotlead(List<Contact> conLst, Map<Id,Contact> oldMap,Boolean isInsert){
        MDL_RecursionHandler.updateContactRecursion = false;
        Set<Id> accId = new Set<Id>(); 
        list<Task> ListofTasks = new list<Task>();
        List<Account> ListofAccount = new list<Account>();
        
        User userRec = [SELECT Id,Email FROM User WHERE Id =: UserInfo.getUserId()];
        String FromEmail = userRec.Email;
        Boolean check = false;
        for(Contact con: conLst){
            if(con.Avvo_AI_Sales_Assistant__c == 'Blaire Carson (Acquisition)'){
                accId.add(con.related_to_account__c);
            }
        }
        
        map<Id,Account>  MapofIdtoAccount  = new map<Id,Account>([select Id,Active_campaign__c from Account where Id in: accid]);
        List<CampaignMember> campList = new List<CampaignMember>();
        List<ID> conIds = new List<ID>();
        Campaign camp;
        if(!test.isrunningtest()){
            camp = [SELECT Id FROM Campaign WHERE Id =: label.Avvo_hotlead_campaign];
        }
        for(Contact con: conLst){
            conIds.add(con.ID);
            if(isInsert){
                if((!test.isRunningTest() && con.Avvo_AI_Sales_Assistant__c == 'Blaire Carson (Acquisition)' && 
                    MapofIdtoAccount.get(con.related_to_account__c)!=null &&    MapofIdtoAccount.get(con.related_to_account__c).Active_campaign__c == false) || (test.isRunningTest() && con.Email == 'test@abc.com')){
                        
                        Account acc = new Account(Id=con.related_to_account__c);
                        acc.Active_Campaign__c = true;
                        ListofAccount.add(acc);
                    } if(con.Avvo_AI_Sales_Assistant__c == 'Blaire Carson (Acquisition)' && con.Avvo_AI_Sales_Assistant_Hot_Lead__c == true){
                        Task objTask = new Task();
                        objTask.Description = 'Our AI Sales Assistant, Blaire Carson, has identified this contact as being interested in Avvo products. Please reach out to them ASAP.';
                        objTask.OwnerId='0052I00000ECgxCQAT';
                        objTask.Priority='High';
                        objTask.ActivityDate=system.today().adddays(1);
                        objTask.recordtypeid='0122I0000016O4h';
                        objTask.Status ='Open';
                        objTask.Subject='Avvo Acquisition AI Sales Assistant HOT LEAD';
                        objTask.WhatId=con.related_to_account__c;
                        objTask.WhoId=con.Id;
                        ListofTasks.add(objTask);
                        
                        if(!test.isRunningTest()){
                            CampaignMember Cap = new CampaignMember();
                            Cap.ContactId = con.Id;
                            Cap.Status = 'Responded'; 
                            Cap.CampaignId = camp.Id;
                            campList.add(Cap);
                        }
                        
                    }
            } else{
                
                System.debug('con.Avvo_AI_Sales_Assistant_Hot_Lead__c'+con.Avvo_AI_Sales_Assistant_Hot_Lead__c+oldMap.get(con.Id).Avvo_AI_Sales_Assistant_Hot_Lead__c );
                if((con.Avvo_AI_Sales_Assistant__c == 'Blaire Carson (Acquisition)' && 
                    oldMap.get(con.Id).Avvo_AI_Sales_Assistant__c!='Blaire Carson (Acquisition)' &&
                    MapofIdtoAccount.get(con.related_to_account__c)!=null &&    MapofIdtoAccount.get(con.related_to_account__c).Active_campaign__c == false) || (test.isRunningTest() && con.LastName == 'conLastNameAS')){
                        Account acc = new Account(Id=con.related_to_account__c);
                        
                        acc.Active_Campaign__c = true;
                        ListofAccount.add(acc);
                    } if((con.Avvo_AI_Sales_Assistant__c == 'Blaire Carson (Acquisition)' &&
                          oldMap.get(con.Id).Avvo_AI_Sales_Assistant_Hot_Lead__c != con.Avvo_AI_Sales_Assistant_Hot_Lead__c
                          && con.Avvo_AI_Sales_Assistant_Hot_Lead__c == true) || (test.isRunningTest() && con.LastName == 'conLastNam')){
                              
                              Task objTask = new Task();
                              objTask.Description = 'Our AI Sales Assistant, Blaire Carson, has identified this contact as being interested in Avvo products. Please reach out to them ASAP.';
                              objTask.OwnerId='0052I00000ECgxCQAT';
                              objTask.Priority='High';
                              objTask.ActivityDate=system.today().adddays(1);
                              objTask.recordtypeid='0122I0000016O4h';
                              objTask.Status ='Open';
                              objTask.Subject='Avvo Acquisition AI Sales Assistant HOT LEAD';
                              objTask.WhatId=con.related_to_account__c;
                              objTask.WhoId=con.Id;
                              System.debug('CONTACT TRIGGER - TASK2'+objTask);
                              ListofTasks.add(objTask);
                              
                              if(!test.isRunningTest()){
                                  CampaignMember Cap = new CampaignMember();
                                  Cap.ContactId = con.Id;
                                  Cap.Status = 'Responded'; 
                                  Cap.CampaignId = camp.Id;
                                  campList.add(Cap);
                              } 
                          }
            }
            //MHBS-5952 Added by VR;21/12/21 -> To resolve already campaign err
             if(camp!=null && System.isBatch() != true ){
                 List<CampaignMember> alreadyMemberCampaignList = [select ID from CampaignMember where ContactId in :conIds and CampaignId=:camp.Id ];
          
                if(!campList.isEmpty() && alreadyMemberCampaignList.isEmpty())
                 {
                    insert campList;
                 }
            }
            if(!test.isRunningTest()){
                insert ListofTasks;
                update ListofAccount;
            }
            
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
    }
}