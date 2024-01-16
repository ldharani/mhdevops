/**************************************************************
 * Author      : Bharath
 * Description : To create MH Account from contact
 * Created Date : 07/04/2023
 * 
 * Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-9194    Bharath S     08/05/2023   Nama            <T01>   Create MH account from Avvo attorney account instead of Firm Account
************************************************************************************************************************/

public class CreateMHAccSKUFirm {
    public static String MHAccRectypeId;
    public static String Individual_String = 'Individual';
    public static String Legal_String = 'Legal';
    public static String MH_String = 'Martindale-Hubbell';
    public static String Prospect_String = 'Prospect';
    public static String Prospecting_String = 'Prospecting';
    
    public static void createAcc(Map<Id, Account> newAccMap){
        List<Account> accToBeAdded = new List<Account>();
        List<Opportunity> oppToBeAdded = new List<Opportunity>();
        List<AccountContactRelation> acrToBeAdded = new List<AccountContactRelation>();
        MHAccRectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('M-H Account').getRecordTypeId();
        Set<Id> accKey = newAccMap.KeySet();
        Map<Id, Contact> AccConMap = new Map<Id, Contact>();
		List<Account> accountContactRelations = new List<Account>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        Map<Id, Id> mhaccparentmap = new Map<Id, Id>();
        List<Account> mhacc = new List<Account>();
        
        //This Piece of code is used to create a Map of the Avvo firm Id and A Contact from its Parent Account
        if(accKey.size() != 0){
            accountContactRelations = [Select Id ,(SELECT Account__c, Contact__c FROM Account_Contact_Relations__r) from Account WHERE Id IN :accKey limit 1];
		}
		//<T01> starts
		for(Account acr : accountContactRelations) {
            for(Account_Contact_Relation__c con : acr.Account_Contact_Relations__r){
              	contactIds.add(con.Contact__c);
            }
		}
		//<T01> ends
        if(contactIds.size() > 0){
         	Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, AccountId, LastName, FirstName, Salutation, Account_Name__c,Account_Website__c,No_of_Employees__c,Firm_Org_ID__c,
                          Name, RecordTypeId, MailingStreet, MailingCity, Address_Street_Line_2__c ,
                          MailingState, MailingPostalCode, MailingCountry, 
                          MailingStateCode, MailingCountryCode, MailingLatitude, 
                          MailingLongitude, MailingGeocodeAccuracy, 
                          Phone, Fax, MobilePhone, ReportsToId, Email, Title,
                          Department, LeadSource, Description, OwnerId, 
                          HasOptedOutOfEmail, DoNotCall, Historical_SFDC_ID__c, 
                          MH_Siebel_ID__c, Role__c, Suffix__c, ISLN__c, 
                          pi__Needs_Score_Synced__c, 
                          pi__Pardot_Last_Scored_At__c, pi__campaign__c, pi__comments__c, 
                          pi__conversion_date__c, pi__conversion_object_name__c, 
                          pi__conversion_object_type__c, pi__created_date__c, pi__first_activity__c, 
                          pi__first_search_term__c, pi__first_search_type__c, pi__first_touch_url__c, 
                          pi__grade__c, pi__last_activity__c, pi__notes__c, pi__pardot_hard_bounced__c, 
                          pi__score__c, pi__url__c, pi__utm_campaign__c, pi__utm_content__c, 
                          pi__utm_medium__c, pi__utm_source__c, pi__utm_term__c, Building__c, Product_Preference__c,
                          Current_Sequence_ID__c,Current_Sequence_Name__c,Current_Sequence_Status__c,Current_Sequence_Step_Number__c,Current_Sequence_Step_Type__c,
                          Current_Sequence_Task_Due_Date__c,Current_Sequence_User_SFDC_ID__c,
                          Goes_By_Name__c, Comments__c, MH_Contact__c, Areas_of_Practice__c,M_NG_Classification__c,                          
                          County_Name__c, Zipcode__c, JV_Customer_Status__c, JV_Order_Status__c,M_NG_Sub_Type__c,
                          Account.Organization_Type__c,
                          JV_Organization_Type__c, JV_Sub_Type__c, MH_Customer_Status__c, MH_Order_Status__c, 
                          MH_Organization_Type__c, M_NG_Organization_Type__c, MH_Sub_Type__c, MN_Customer_Status__c, MN_Order_Status__c, 
                          MN_Organization_Type__c, MN_Sub_Type__c, Alternate_Email_Address__c, Do_Not_Solicit__c, Open_MH_Lead__c        
                   	   FROM Contact WHERE Id IN :contactIds]);
			//<T01> starts
            for(Account acr : accountContactRelations) {
            	for(Account_Contact_Relation__c con : acr.Account_Contact_Relations__r){
              		AccConMap.put(con.Account__c, contactMap.get(con.Contact__c));
            	}
			}
			//<T01> ends
        }
        System.debug('@@@@Account and Contact Map' + AccConMap);
        
        //This Piece of code is used to create a Map of the Parent IB Account and MH Account.
		for(Id acc : newAccMap.keySet()){
            Account a = newAccMap.get(acc);
    		parentIds.add(a.Avvo_18_digit_IB_Account__c); //<T01>
		}
        if(parentIds.size() != 0 && MHAccRectypeId != ''){
            mhacc = [SELECT Id,ParentId,Name FROM Account WHERE ParentId IN :parentIds and RecordTypeId =: MHAccRectypeId];
        	for(Account a: mhacc){
            	mhaccparentmap.put(a.ParentId,a.Id);
        	}
        }  
        System.debug('@@@@Parent IB Account and MH Account Map' + mhaccparentmap);
        
        //Here for each avvo firm account, if there is no MH account in its parent account , then a new mh account will be created
        for(Account a : newAccMap.Values()){
            if(!mhaccparentmap.containsKey(a.Avvo_18_digit_IB_Account__c) && AccConMap.containsKey(a.id)){ //<T01>
                System.debug('@@@@Inside For Loop');
                Contact con = AccConMap.get(a.Id);
                System.debug('@@@@con'+con);
                Account acc = new Account();
            	String accName = con.Account_Name__c;
            	if(accName =='' || accName == NULL){
                	acc.Name = Individual_String;
            	}else{    
                	acc.Name = accName ;
            	}
                acc.Org_Id__c = con.Firm_Org_ID__c;
            	acc.BillingCountry = con.MailingCountry;
            	acc.BillingStreet = con.MailingStreet;
            	acc.BillingCity = con.MailingCity;
            	acc.BillingState = con.MailingState;
            	acc.BillingPostalCode = con.MailingPostalCode;
            	acc.Phone = con.Phone;
            	acc.OwnerId = con.OwnerId;
                acc.Address_Street_Line_2__c = con.Address_Street_Line_2__c;
            	acc.County__c = con.County_Name__c;
            	//acc.AccountSource = 'Contact';
            	acc.MH_Customer_Status__c = con.MH_Customer_Status__c;
            	acc.MH_Order_Status__c = con.MH_Order_Status__c;
            	acc.JV_Customer_Status__c = con.JV_Customer_Status__c;
            	acc.JV_Order_Status__c  = con.JV_Order_Status__c;
            	acc.MN_Customer_Status__c = con.MN_Customer_Status__c;
            	acc.MN_Order_Status__c  = con.MN_Order_Status__c;   
            	acc.ParentId = a.Avvo_18_digit_IB_Account__c; //<T01> starts
            	acc.Classification__c = Legal_String;
            	acc.RecordTypeId = MHAccRectypeId;
            	acc.Business_Unit__c = MH_String;
            	acc.Website = con.Account_Website__c;	
            	acc.Customer_Status__c = Prospect_String;
                acc.Primary_Billing_Contact__c = con.id;
            	accToBeAdded.add(acc);
            }
        }
       	if(accToBeAdded.size() > 0){
            try{
                insert accToBeAdded;
                System.debug('@@@@MH Account created Successfully');
                for(Account acc2 : accToBeAdded){
                	AccountContactRelation acr2 = new AccountContactRelation();
					acr2.AccountId = acc2.Id;
            		acr2.ContactId = acc2.Primary_Billing_Contact__c;
            		acrToBeAdded.add(acr2);
                
                	Opportunity opp = new Opportunity();
            		opp.Name = acc2.Name+'-';
            		opp.StageName = Prospecting_String;
            		opp.AccountId = acc2.id;
            		opp.ContactId = acc2.Primary_Billing_Contact__c;
            		opp.invoiceit_crmx__Number_Of_Terms__c = 12; 
            		Date d = Date.today();
					Integer m = d.month();
            		Integer y = d.year();
            		if(m==1 || m==2 || m==3){
                		opp.CloseDate = Date.newInstance(y, 3, 31);
            		}
            		if(m==4 || m==5 || m==6){
                		opp.CloseDate = Date.newInstance(y, 6, 30);
            		}
            		if(m==7 || m==8 || m==9){
                		opp.CloseDate = Date.newInstance(y, 9, 30);
           			}
            		if(m==10 || m==11 || m==12){
                		opp.CloseDate = Date.newInstance(y, 12, 31);
            		}
            		oppToBeAdded.add(opp); 	  
                }
                
                if(oppToBeAdded.size() > 0){
                    try{
                        insert oppToBeAdded;
                        System.debug('@@@@Opportunity created Successfully under the MH Acccount');
                    }
                    catch(Exception e){
                		Util.processException(e,true,'Error while inserting the Opportunity: '+oppToBeAdded);
					}		
                }
                if(acrToBeAdded.size() > 0){
                    try{
                        insert acrToBeAdded;
                        System.debug('@@@@Contact is now related to the Account');
                    }
                    catch(Exception e){
                		Util.processException(e,true,'Error while inserting the AccountContactRelation: '+acrToBeAdded);
					}
                }
            }
            catch(Exception e){
                Util.processException(e,true,'Error while inserting the Account: '+accToBeAdded);
			}
        }
        System.debug('@@@@accToBeAdded :'+accToBeAdded);
        System.debug('@@@@acrToBeAdded :'+acrToBeAdded);
        System.debug('@@@@oppToBeAdded :'+oppToBeAdded);
	}
}