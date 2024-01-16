/***********************************************************************************************************************
 * @author - 
 * @date - 
 * @description - Auto complete address details on Account Page
 * @testclass - 

Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6861    VR            25/04/2022                   T01     Added changes for Street Line 2 Field
************************************************************************************************************************/

public class AutoCompleteMainController {
    
    public Id acctId              {get;set;}
    public account acc           {get;set;}
    public string  bcountryName  {get;set;}
    public string  bstateName    {get;set;}
    public string  bcountyName   {get;set;}
    public string  bcityName     {get;set;}
    public string  bstreetName   {get;set;}
    public string  bstreetLine2Name   {get;set;} //T01
    public string  bpostalcode   {get;set;}
    
    public string countryNameError {get;set;}

    public String countryName{set;get;}
    public String cityname{set;get;}
    public String AccountId {set;get;}
    public String countryName1{set;get;}
    
    public string billingCountryName {get;set;}
    public string stateName          {get;set;}
    public string billingStateName   {get;set;}
    public boolean selected          {get;set;}
    public AutoCompleteMainController (ApexPages.StandardController contrl){
        
        acc =(account)contrl.getRecord();
        
        acc = [select id,Name,
                      BillingCountry, BillingState,
                      BillingCity, BillingStreet,BillingPostalCode,Address_Street_Line_2__c, //T01
                      County__c, ShippingCountry, ShippingState, ShippingCity,
                      ShippingStreet, ShippingpostalCode
                      From account 
                      where id=:acc.id];
        if(acc.BillingCountry == null || acc.BillingCountry ==' '){
            acc.BillingCountry = 'USA';
        }
         if(acc.ShippingCountry == null || acc.ShippingCountry ==' '){
            acc.ShippingCountry = 'USA';
        }
        
        bcountryName     = acc.BillingCountry;
        bstateName       = acc.BillingState;
        //bcountyName      = acc.County__c;
        bcityName        = acc.BillingCity;
        bstreetName      = acc.BillingStreet;
        bstreetLine2Name = acc.Address_Street_Line_2__c; //T01
        bpostalcode      = acc.BillingPostalCode;
        countryNameError = '';
        
    }
    public void printAccountId(){
        system.debug('AccountId: '+countryName);        
    }
    
     public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Copy Billing address to Shipping Address','Copy Billing address to Shipping Address')); 
       return options; 
    }
    
    public PageReference copyshippingFields(){
        
        system.debug('@@@@copyshippingFields'+selected); 
        
        if(selected){
            acc.ShippingCountry    = acc.BillingCountry;
            acc.ShippingState      = acc.BillingState;
            acc.ShippingCity       = acc.BillingCity;
            acc.ShippingStreet     = bstreetName + ' , ' + bstreetLine2Name; //T01
            acc.ShippingpostalCode = acc.BillingPostalCode;
        }
        
        else{
            acc.ShippingCountry    ='';
            acc.ShippingState      ='';
            acc.ShippingCity       ='';
            acc.ShippingStreet     = '';
            acc.ShippingpostalCode = '';
        }
        return null; 
    }
    
    
   /* public PageReference emptyshippingFields(){
            acc.ShippingCountry    ='';
            acc.ShippingState      ='';
            acc.ShippingCity       ='';
            acc.ShippingStreet     ='';
            acc.ShippingpostalCode ='';
        return null;

    }*/
    
    
    
    public pageReference updateAccount(){
        
        List<GEO_Location__c> geolocationlist;
        boolean error = false;
        if(acc.BillingCountry != null && acc.BillingCountry !=''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:acc.BillingCountry Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                acc.BillingCountry.addError('Not a valid Country');
                return null;
            }
        }
        if(!error && acc.BillingState != null && acc.BillingState != ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:acc.BillingCountry 
                                              and State_Abbrevation__c =:acc.BillingState Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                acc.BillingState.addError('Not a valid State');
                return null;
            }
        }
        
      /*  if(!error && acc.County__c!= null && acc.County__c != ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where CountryName__c =:acc.BillingCountry 
                                              and State_Abbrevation__c =:acc.BillingState
                                              and County_Name__c =:acc.County__c Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                acc.County__c.addError('Not a valid County');
                return null;
            }
        }*/
        
        if(!error && acc.BillingCity!= null && acc.BillingCity!= ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:acc.BillingCountry 
                                              and State_Abbrevation__c =:acc.BillingState
                                              //and County_Name__c =:acc.County__c
                                              and City_Name__c =:acc.BillingCity Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                acc.BillingCity.addError('Not a valid City');
                return null;
            }
        }
        
        if(!error && acc.BillingPostalCode!= null && acc.BillingPostalCode!= ''){
          //if(!error && (acc.BillingPostalCode == null || acc.BillingPostalCode!= '')){  
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:acc.BillingCountry 
                                              and State_Abbrevation__c =:acc.BillingState
                                              and County_Name__c =:acc.County__c
                                              and City_Name__c =:acc.BillingCity 
                                              and Zipcode__c =:acc.BillingPostalCode Limit 1];
            /*if(geolocationlist.isEmpty()){
                error = true;
                acc.BillingPostalCode.addError('Not a valid Zip Code');
                return null;
            }*/
        }
        
        //***************Shipping Address Vadlidation*********************
        
        if(!error && acc.ShippingCountry != null && acc.ShippingCountry!= ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:acc.ShippingCountry Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                acc.ShippingCountry.addError('Not a valid Country');
                return null;
            }
        }
        
        if(!error && acc.ShippingState != null && acc.ShippingState != ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:acc.ShippingCountry 
                                              and State_Abbrevation__c =:acc.ShippingState Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                acc.ShippingState.addError('Not a valid State');
                return null;
            }
        }
        
         if(!error && acc.ShippingCity != null && acc.ShippingCity!= ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:acc.ShippingCountry 
                                              and State_Abbrevation__c =:acc.ShippingState                                           
                                              and City_Name__c =:acc.ShippingCity Limit 1];
            if(geolocationlist.isEmpty()){
                error = true;
                acc.ShippingCity.addError('Not a valid City');
                return null;
            }
        }
        
       //if(!error && acc.ShippingpostalCode != null && acc.ShippingpostalCode != ''){
         if(!error && acc.ShippingpostalCode != null && acc.ShippingpostalCode != ''){
            geolocationlist = new List<GEO_Location__c>();
            geolocationlist = [select id From GEO_Location__c
                                         where RecordType.DeveloperName = 'M_H_GEO_Locations' and CountryName__c =:acc.ShippingCountry 
                                              and State_Abbrevation__c =:acc.ShippingState
                                              
                                              and City_Name__c =:acc.ShippingCity 
                                              and Zipcode__c =:acc.ShippingpostalCode Limit 1];
           /* if(geolocationlist.isEmpty()){
                error = true;
                acc.ShippingpostalCode.addError('Not a valid Zip Code');
                return null;
            }*/
        }
       
       
        //acc.BillingCountry    = bcountryName;
        //acc.BillingState      = bstateName;
        //acc.County__c         = bcountyName;
        //acc.BillingCity       = bcityName;
        acc.BillingStreet     = bstreetName;
        acc.Address_Street_Line_2__c = bstreetLine2Name; //T01
        //acc.BillingPostalCode = bpostalcode;
        update acc;
        system.debug('Updated Account' + acc );
       pageReference pageRef = new PageReference('/lightning/r/Account/' + acc.Id +'/view');
    
       // pageReference pageRef = new PageReference('/apex/billingAddressOnAccount?id=' + acc.Id);
        return pageRef;
    }
    
    public pageReference Close(){
    pageReference close = new PageReference('/lightning/r/Account/' + acc.Id +'/view');
    //pageReference close = page.billingAddressOnAccount;
    //close.getParameters().put(acctId,acc.Id); 
    close.setRedirect(false);
    return close;
    }
}