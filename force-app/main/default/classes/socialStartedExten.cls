public class socialStartedExten{
    
    //public string abtUs{get;set;}
    public Opportunity oppt{get;set;}
    public Opportunity_Charge_Attribute__c opptyAttr{get;set;}
    public List<String> aopSelected{get;set;}
    public String chargeName{get;set;}
    public string oppAttrId{get;set;}
    public string oppId{get;set;}
    public string accId{get;set;}    
    public Boolean none{get; set;}
    public Boolean bankruptcy{get; set;}
    public Boolean criminal{get; set;}
    public Boolean divorce{get; set;}
    public Boolean estate{get; set;}
    public Boolean immigration{get; set;}
    public Boolean labor{get; set;}
    public Boolean business{get; set;}
    public Boolean family{get; set;}
    public Boolean workerscomp{get; set;}
    public Boolean civilright{get; set;}
    public Boolean resid{get; set;}
    public Boolean personalinj{get; set;}
    public Boolean persInjMV{get; set;}
    public Boolean persInPl{get; set;}
    public Boolean persInjMM{get; set;}
    public Boolean eldrLaw{get; set;}
    public Boolean intProp{get; set;}
    public String websiteURL{get;set;}
    public String conName{get;set;}
    public String conPhone{get;set;}
    public String conAddress{get;set;}
    public String conEmail{get;set;}
    public String facebookURL{get;set;}
    public String LinkedInURL{get;set;}
    public String googleURL{get;set;}
    public Boolean noToFbProf{get; set;}
    //public Boolean noToTwProf{get; set;}
    public Boolean noToGooglProf{get; set;}
    public Boolean noToLnProf{get; set;}
    public String Notes{get;set;}
    public id cancelId{get;set;}
    public RecordType rt;
    public List<String> aopList{get;set;}
    public string aops{get;set;}
    public String doesNtwanProf {get;set;}
    public string advArea {get;set;}
    public boolean isBasic{get;set;}
    public group unassignedQueue{get;set;}
    public String unAssignQu{get;set;}
    public boolean middleOrUpperBoost{get;set;}
    public Boolean taxLaw{get;set;} //added by saiv - 7/14/20 - MHBS-4415
    
  
    
    public socialStartedExten(){
        isBasic = False;
        middleOrUpperBoost = False;
        List<String> aopSelected = new List<String>() ;        
        
        //doesNtwanProf ='';
        oppId = ApexPages.currentPage().getParameters().get('id');
        oppAttrId = ApexPages.currentPage().getParameters().get('attrId');
       // aopList = null;
        System.debug('@@@@@@@@@@oppt'+oppId );
         
        oppt = [SELECT name, Amount,Account.Name,AOPs__c,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account_MH_Customer_No__c,Account.BillingCountry,Account.BillingPostalCode, CloseDate,StageName,Account.MH_Cust_Number__c,AccountId

             FROM Opportunity  
                WHERE id =: oppId ];
        accId =oppt.AccountId;        
        cancelId = oppId;
        
        rt = new RecordType();
        for(RecordType rtype : [Select Id from RecordType where DeveloperName='MDL_Customer_Service']) {
            rt = rtype;
        }
        
        if(oppt.Account.BillingStreet!=Null || Account.BillingCity!=Null){
            conAddress = oppt.Account.BillingStreet+', '+oppt.Account.BillingCity+', '+ oppt.Account.BillingState+', '+oppt.Account.BillingCountry+', '+ oppt.Account.BillingPostalCode;
        }
        
        opptyAttr = [Select id, name, String_value__c From Opportunity_Charge_Attribute__c Where id =:oppAttrId LIMIT 1]; 
        System.debug('@@@opptyAttr'+opptyAttr);
        
        Group unassignedQueue = [select Id from Group where  Type = 'Queue' AND NAME = 'Unassigned Case Queue' LIMIT 1];
        System.debug('@@@@@Unassigned Queue'+unassignedQueue);
        unAssignQu = unassignedQueue.id;
        System.debug('@@@@@Unassigned RT'+unAssignQu );

        
        //Query the charges on the oppoertunity to identify the rep boost product tier
        List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> oppRPCList = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        oppRPCList = [Select id, name,invoiceit_crmx__Accounting_Code__c from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c Where invoiceit_crmx__Opportunity__c =: oppId];
        
        if(!oppRPCList.isempty()){
            for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c oppRpc: oppRPCList){
                if(oppRpc.invoiceit_crmx__Accounting_Code__c =='12002' || oppRpc.invoiceit_crmx__Accounting_Code__c =='12003'){
                    middleOrUpperBoost = True;
                    chargeName = oppRpc.Name;
                }else if(oppRpc.invoiceit_crmx__Accounting_Code__c == '12001'){
                    middleOrUpperBoost = False;
                    chargeName = oppRpc.Name;
                }
                 
            }    
        }
              
    }
      
    public Pagereference Submit(){
        List<Case> lstCasesToInsert = new List<Case>();
        boolean error = false;
        string errorString = '';
        
        try{
            System.debug('@@@@@@@inside try'+conName );
            if(conName == NULL || conName == ''){
            
             ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the required field Contact Name'); 
             ApexPages.addMessage(errMsg);
               
            }
            
            if(conPhone == NULL || conPhone == ''){
               
              ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the required field Contact Phone'); 
              ApexPages.addMessage(errMsg);   
            }
            
            if(conEmail== NULL || conEmail == ''){
              
                
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the required field Contact Email'); 
                ApexPages.addMessage(errMsg);   
               
            }
            
            if(conAddress== NULL || conAddress== ''){
                
                
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter the required field Contact Address'); 
                ApexPages.addMessage(errMsg);   
              
            }
          
            if(oppt.AOPs__c != Null){
                  aopSelected = oppt.AOPs__c.split(';');
            }else{
                   
            } 
            System.debug('@@@@@@@aopSelected'+aopSelected );
            if(aopSelected.size()>3){
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select upto 3 AOPs only'); 
                    ApexPages.addMessage(errMsg);
            }
           
            if((conName == NULL || conName == '') || (conPhone == NULL || conPhone == '') || (conEmail == NULL || conEmail == '') || (conAddress == NULL || conAddress == '') || (aopSelected.size()>3)){
                
                return null;
            }
            
        if(noToFbProf == TRUE) {
            doesNtwanProf +='Client Does Not Want a Facebook Profile Created<br/>';
        }
         
        if(noToGooglProf== TRUE) {
            doesNtwanProf+='Client does not want a Google+ Brand Page<br/>';
        }
        if(noToLnProf == TRUE) {
            doesNtwanProf+='Client does not want a Linkedin Company Page<br/>';
        }
        
             
        if(none == true){
            aops = 'None <br/>';
        }else{
            if(bankruptcy == true){
                aops = 'Bankruptcy (2/week)<br/>';
            }
            if(criminal == true){
                aops += 'Criminal Defense (2/week)<br/>';
            }
            if(divorce == true){
                aops += 'Divorce (2/week)<br/>';
            }
            if(estate == true){
                aops += 'Estate Planning (2/week)<br/>';
            }
            if(immigration == true){
                aops += 'Immigration (2/week)<br/>';
            
            }
            if(labor == true){
                aops += 'Labor & Employment (2/week)<br/>';
            
            }
            if(business == true){
                aops += 'Business (1/week)<br/>';
            }
            if(family == true){
                aops += 'Family Law (1/week)<br/>';
            }
            if(workerscomp== true){
                aops += 'Workers Compensation (1/week)<br/>';
            }
            if(civilright == true){
                aops += 'Civil Rights (2/month)<br/>';
            }
            if(resid== true){
                aops += 'Real Estate (Residential) (2/month)<br/>';
            }
            if(personalinj == true){
                aops += 'Personal Injury - General (2/month)<br/>';
            }
            if(persInjMV== true){
                aops += 'Personal Injury - Motor Vehicle Accidents (2/month)<br/>';
            }
            if(persInPl== true){
                aops += 'Personal Injury - Product Liability (2/month)<br/>';
            }
            if(persInjMM== true){
                aops += 'Personal Injury - Medical Malpractice (1/month)<br/>';
            }
            else if(eldrLaw == true){
                aops += 'Elder Law (1/month)<br/>';
            }
            if(intProp == true){
                aops += 'Intellectual Property (1/month) - (does not include patent law)<br/>';
            }
            //added by saiv - 7/14/20 - MHBS-4415
            if(taxLaw == true){
                aops += 'Tax Law (1/month)<br/>';
            }
        }
        System.debug('@@aops '+aops );
        
       // aopList = aops.split(',<br/>');
     
        if(oppt.AOPs__c!= Null){
            Case cInsert1 = createCase1('Editorial','New Client Setup', 'Editorial Form - '+oppt.Account.Name, 'Please go through the AOP details.',  'Editorial', accId);
            lstCasesToInsert.add(cInsert1);
        }
        
        Case cInsert = createCase('Social Starter','New Client Setup', 'Social Starter Intake Form - '+oppt.Account.Name, 'Please go through the Social Starter form details which has been submitted.',  'SocialStarter', accId);
        lstCasesToInsert.add(cInsert);
        
        System.debug('@@@@@@@@lstCasesToInsert'+lstCasesToInsert);
        
        if(lstCasesToInsert.size() > 0) {
            insert lstCasesToInsert;
        }  
        
        if(opptyAttr!=Null){
            if(opptyAttr.String_value__c == Null){
                opptyAttr.String_value__c = 'Reputation Boost Intake Form Submitted';
            }
            System.debug('@@@@@opptyAttr.String_value'+opptyAttr.String_value__c);
            update opptyAttr;    
        }
        
        Pagereference pag = new Pagereference('/'+oppId);
        return pag;
        
        }
        catch(System.Exception e){
            System.debug('@@@@@@@inside catch'+e);
            String error1;
            
            error1 = errorString;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error1));
            return null;
        }
    }
    
    
    public PageReference Cancel() {
        Pagereference pag =new Pagereference('/'+cancelId);
        return pag;
    }
    
    public Case createCase(String area , String subArea , String subject , String description , String caseOrigin , Id accId) {
        Case c = new Case();
        c.AccountId = accId;
        c.Parent_Opportunity__c = oppId;
        c.Area__c = area;
        c.Sub_Area__c = subArea;
        c.Subject = subject;
        c.Description = description;
        System.debug('@@@@@@@@@@@@ unassigned quue check 2'+unassignedQueue );
        //if(unassignedQueue!=Null){
            c.OwnerId = unAssignQu ; // unassignedQueue.Id; //'00G290000013BCY';
        //}
        c.Origin = caseOrigin;
        if(rt!=null) {
            c.RecordTypeId = rt.Id; //Standard Case Record Type
        }
        c.Priority = 'Medium';
        c.Status = 'New';
        //c.Website_URL_Domain_Name__c = websiteURL;
        c.Customer_Name__c = conName;
        c.Customer_Phone_Number__c = conPhone;
        //c.Customer_Email_Address__c = conEmail; 
        
        
        c.Description__c =  'Social Starter Intake Form  <br/>'+
                            'Submitted Date <br/>'+
                            System.Today()+ '<br/>'+
                            '--------------------------------------------------------------------  <br/>'+
                            'Firm Name <br/>' +
                            oppt.Account.Name+ '<br/> <br/>' +
                            'MH Customer No <br/>'+
                            oppt.Account_MH_Customer_No__c + '<br/><br/>' +
                            'Product Name' + '<br/>'+
                            chargeName + '<br/><br/>';//+
                            
         if(aops!= NULL){
             c.Description__c+= 'AOP(s) <br/><br/>'+
                                 //aopList+'<br/><br/>'+//;
                                 aops+'<br/><br/>';
             
         }               
                            
        c.Description__c+= 'Website URL/Domain Name <br/>'+
                            websiteURL + '<br/><br/>'+
                            'Contact Name' + '<br/>'+
                            conName + '<br/><br/>'+
                            'Phone' + '<br/>'+
                            conPhone + '<br/><br/>'+
                            'Address' + '<br/>'+
                            conAddress + '<br/><br/>'+
                             '<br/>'+
                             'Email/s' + '<br/>'+
                            conEmail+ '<br/><br/>'+
                            '-------------------------------------------------------------------- <br/>'+
                            'Existing Social Media Profile Information'+ '<br/><br/>'+
                            'Facebook' + '<br/>'+
                            '<u>'+facebookURL +'</u><br/><br/>'+
                            'LinkedIn' + '<br/>'+
                            '<u>'+LinkedInURL+'</u><br/><br/>'+
                            'URLs of Google My Business listings' + '<br/>'+
                            '<u>'+googleURL+'</u><br/><br/>';
       
       
       if(doesNtwanProf !=Null){
           c.Description__c +=                      
                            'if a client lacks a profile on any platform we support, we will attempt to build them one. If the client does not want us to build them a profile,please record it here. <br/><br/>'+
                             doesNtwanProf + '<br/>';
                             
       }
       
        if(Notes!=Null){
            c.Description__c += '-Notes- <br/>'+
                                Notes ;
        }
        
        //c.setOptions(dmlOpts);
        return c;
    }
    
    public Case createCase1(String area , String subArea , String subject , String description , String caseOrigin , Id accId) {
        Case c = new Case();
        c.AccountId = accId;
        c.Parent_Opportunity__c = oppId;
        c.Area__c = area;
        c.Sub_Area__c = subArea;
        c.Subject = subject;
        c.Description = description;
        //if(unassignedQueue!=Null){
            c.OwnerId = unAssignQu ; //'00G290000013BCY';
        //}
        c.Origin = caseOrigin;
        
        //c.Description__c =  abtUs + '<br/><br/>';
        
        c.aops__c = oppt.AOPs__c;
        
        c.description__c = 'Editorial Intake Form  <br/>'+
                            'Submitted Date <br/>'+
                            System.Today()+ '<br/>'+
                            '--------------------------------------------------------------------  <br/>'+
                            'Firm Name <br/>' +
                            oppt.Account.Name+ '<br/> <br/>' +
                            'MH Customer No <br/>'+
                            oppt.Account_MH_Customer_No__c + '<br/><br/>'+// ;
                            'Product Name' + '<br/>'+
                            chargeName + '<br/><br/>'+
                            'Contact Name' + '<br/>'+
                            conName + '<br/><br/>'+
                            'Phone' + '<br/>'+
                            conPhone + '<br/><br/>'+
                            'Address' + '<br/>'+
                            conAddress + '<br/><br/>'+
                             '<br/>'+
                             'Email/s' + '<br/>'+
                            conEmail+ '<br/><br/>'+
                            '<br/>'+
                            'AOPs' + '<br/>'+
                            oppt.AOPs__c+'<br/><br/>'+
                            '-------------------------------------------------------------------- <br/>';
                            
        if(advArea!=Null){
            c.Description__c += advArea;
        }
                     
        //c.Aops__c = 
        return c;
    }
}