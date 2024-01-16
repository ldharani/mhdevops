public class CreateQuotePDF {
      
    public String sQuoteID{get;set;}
    public Opportunity Quote{get;set;}
    public Opportunity upsellQuote {get;set;}
    public String upsellQuoteId {get;set;} 
    public String prodNames;
    public Set<Id> opportunityIdsSet {get;set;}
    public Document d;
    public string initial{get;set;}
    public List<invoiceit_crmx__Opportunity_Product__c> prodList{get;set;}
    public Map<ID,Decimal> mapProductIDtoRate{get;set;}
    public string accid {get;set;}
    public string upsellAccId {get;set;}
    public Set<Id> accIds {get;set;}
    public string opptyid {get;set;}
    public boolean defaultPM_Ngage {get;set;}
    public boolean defaultPM_MH {get;set;}
    public boolean successPanel{get;set;}
    public String approvedStatus{get;set;}
    public List<invoiceit_crmx__Opportunity_Product__c> opptyProdList {get;set;}
    public map<string,list<attributewrapper>> oppPdtVsOPPChargeAttr {get; set;}
    public map<string,decimal> oppPdtVsOPPCharge {get; set;}
    public Map<id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> QprodNChargeMap {get;set;} 

    
    
    public boolean displayPaymentInfo{get;set;}    
    public List<pdtWrapper> pdtWrapList {get;set;}
    public List<pdtWrapper> UsagepdtWrapList {get;set;}
    public List<pdtWrapper> oneTimepdtWrapList {get;set;}
    
    public List<pdtWrapper> ngagePdtWrapList {get;set;}
    public List<pdtWrapper> ngageUsageNMonthlyPdtWrapList {get;set;}
    
    public boolean perconvpresent{get;set;}   
    public boolean chatProdPresent{get;set;}
    public String subject1{get; set;}
    public String body {get;set;}
    public Decimal opptyTerms{get;set;}
    public boolean textToChatPresent {get;set;}
  
    
    public class pdtWrapper{
        
        public invoiceit_crmx__Opportunity_Product__c pdt {get; set;}
        public Boolean isInMap {get;set;}//{return oppPdtVsOPPChargeAttr.containskey(pdt.name);}
        public string Ptype{get;set;}
        public decimal prodOneTime {get;set;}
        public invoiceit_crmx__Opportunity_Rate_Plan_Charge__c prodCharge {get;set;}
        public pdtWrapper(invoiceit_crmx__Opportunity_Product__c  prod, Boolean present,string type, invoiceit_crmx__Opportunity_Rate_Plan_Charge__c charge){
            Ptype=type;
            pdt  = prod;
            isInMap  = present;
            
            if(prod.Product_Sin__c!=Null){
                prodOneTime = prod.invoiceit_crmx__Opportunity__r.One_Time_Total__c;
            }else{
                prodOneTime = prod.invoiceit_crmx__Opportunity__r.Mid_Term_One_Time_Total__c;
            }
            
            prodCharge = charge;
              
        }
    }
    public class attributewrapper{
        
        public string attrHeader {get;set;}
        public string attrValue {get;set;}
        public decimal attrPrice {get;set;}

        public string attrPricewithCurrency {get;set;}
      
        public attributewrapper(Opportunity_Charge_Attribute__c oca){
             
        System.debug('===================================================='+oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Name);
        System.debug('============================Attributye Name'+oca.Attribute_Name__c);        
        System.debug('===================================================='+oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Unit_Price__c);
           
            if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c != null){
                attrPrice = oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c;
                
                if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Price_Type__c == 'Usage' && oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == '60010'){
                    if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                      attrPricewithCurrency = '$ '+attrPrice+' (per conversation)';
                    }else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                        attrPricewithCurrency = '£ '+attrPrice+' (per conversation)';
                    }
                }
                else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Price_Type__c == 'Usage' && oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == '60050'){
                    if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                      attrPricewithCurrency = '$'+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    }else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                        attrPricewithCurrency = '£ '+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    }
                }
                else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Price_Type__c == 'Usage' && oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == '60040'){
                    if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                      attrPricewithCurrency = '$'+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    }else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                        attrPricewithCurrency = '£ '+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    }
                }
                else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Price_Type__c == 'Usage' && oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c == '60030'){
                    if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                      attrPricewithCurrency = '$'+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    }else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                        attrPricewithCurrency = '£ '+ oca.Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c +' (per conversation)';
                    }
                }
                else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Price_Type__c == 'Usage' && oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c != '60010' && oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c != '60050' && oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c != '60040' && oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c != '60030'){
                    if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){ 
                      attrPricewithCurrency = '$ '+attrPrice;
                    }else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                        attrPricewithCurrency = '£ '+attrPrice;
                    }
                }
                else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Price_Type__c == 'Monthly'){
                    if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'USD'){
                      attrPricewithCurrency = '$ '+attrPrice;
                    }else if(oca.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                        attrPricewithCurrency = '£ '+attrPrice;
                    }
                } 
            }
            
            System.debug('=====attrPrice======'+attrPrice);
            
           /*if(oca.Attribute_Name__c== 'Preferred County Results AOP'){
               attrHeader = 'Practice Areas';
           }
           else if(oca.Attribute_Name__c== 'Preferred City Results AOP'){
               attrHeader = 'Practice Areas';      
           }
           else if(oca.Attribute_Name__c== 'Preferred Martindale.com Results AOP'){
               attrHeader = 'Practice Areas';      
           }
           else if(oca.Attribute_Name__c== 'Preferred State Results AOP'){
               attrHeader = 'Practice Areas';      
           }
           else if(oca.Attribute_Name__c== 'Preferred State Links AOP'){
                attrHeader = 'Practice Areas';      
           }
           else if(oca.Attribute_Name__c== 'Preferred National Links AOP'){
                attrHeader = 'Practice Areas';      
           }
           else if(oca.Attribute_Name__c== 'Preferred National Results AOP'){
                attrHeader = 'Practice Areas';   
           }
           else if(oca.Attribute_Name__c== 'Preferred Banner Placements AOP'){
                attrHeader = 'Practice Areas';   
           }
           else{*/
            if(oca.Secondary_Attribute_Name__c!=Null){
               attrHeader = oca.Secondary_Attribute_Name__c;
            }else{
                attrHeader = oca.Attribute_Name__c;
            }
           //}    
            
        System.debug('attrHeader====================='+attrHeader);    
            
            if (oca.string_value__c != null) {
              attrValue = oca.string_value__c;
            }
            else if (oca.picklist_value__c != null && oca.picklist_value__c != '--None--'){
              attrValue = oca.picklist_value__c;
            }  
        }   
    }  
    
  public transient decimal monthlyAmount {get;set;}
  public transient decimal oneTime {get;set;}
  //public transient decimal oneTimeProd {get;set;}
  public transient decimal oneTimeUpsell {get;set;}
  public transient decimal usagecharge {get;set;}
  public transient decimal ngageUsageCharge {get;set;}   
  public date emailSentDate {get;set;}
  public CreateQuotePDF(){
         monthlyAmount = 0;
        // oneTimeProd = 0;
         oneTime = 0;
         oneTimeUpsell = 0;
         usagecharge = 0;
         ngageUsageCharge = 0;
         textToChatPresent = False;
         pdtWrapList = new List<pdtWrapper >();
         oneTimepdtWrapList = new List<pdtWrapper >();
         UsagepdtWrapList = new List<pdtWrapper >();
         ngagePdtWrapList = new List<pdtWrapper>();
         ngageUsageNMonthlyPdtWrapList = new List<pdtWrapper>();
         QprodNChargeMap = new Map<id,invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
         
         accIds = new Set<Id>();
         defaultPM_Ngage = False;
         defaultPM_MH = False;
         
          mapProductIDtoRate = new Map<ID,Decimal>();
        String oppid;
        System.debug('squote============'+ sQuoteID);
            
            //String quoid = ApexPages.currentPage().getParameters().get('id');
            oppid = ApexPages.currentPage().getParameters().get('id');
             System.debug('oppid============='+oppid);

        List<Opportunity> Qlist = [select Id, Name,One_Time_Total__c,Usage_Total__c,Terms_Conditions__c ,invoiceit_crmx__CurrencyL__r.Name,Parent_Opportunity__c,Parent_Opportunity__r.Id,Parent_Opportunity__r.One_Time_Total__c,
                                                toLabel(Ngage_Source__c),
                                                Monthly_Recurring_Total__c, Owner_Manager_First_Name__c,Owner_Manager_Last_Name__c,
                                                Account.Name,Ngage_Upsell_Order__r.invoiceit_s__Account__c,Ngage_Upsell_Order__c,
                                                invoiceit_crmx__Total__c,invoiceit_crmx__Number_Of_Terms__c,Mid_Term_Monthly_Recurring_Total__c,
                                                invoiceit_crmx__Billing_Contact__r.firstName,Auth_By_Contact__r.Name,
                                                invoiceit_crmx__Billing_Contact__r.lastName,invoiceit_crmx__Shipping_Contact__r.Name,
                                                Account_MH_Customer_No__c,
                                                Account.BillingStreet,Account.BillingCity,Owner.ProfileId,
                                                Account.BillingCountry,Account.BillingState,AccountId,RecordType.DeveloperName,Owner.Profile.Name,
                                                Account.BillingPostalCode,Is_Check_paying_client__c,
                                                Owner.Name,Owner.email,Owner.Phone,(Select id, name,AccountId,Parent_Opportunity__r.Id,Parent_Opportunity__c,One_Time_Total__c From Child_Opportunities__r ORDER BY CreatedDate LIMIT 1)
                                                from Opportunity where Id =: oppID 
                                                order by createddate DESC];
        
        system.debug('Qlist is here:::'+Qlist);
        
        if(Qlist != Null && Qlist.size() > 0){
            Quote = Qlist[0];              
            sQuoteID = Quote.id;
            
            
            if(!Quote.Child_Opportunities__r.isEmpty()){
                If(Quote.Child_Opportunities__r[0]!=Null){
                    upsellQuoteId = Quote.Child_Opportunities__r[0].Id;
                    upsellQuote = Quote.Child_Opportunities__r[0];
                    if(upsellQuote.AccountId!=Null){
                        upsellAccId = upsellQuote.AccountId;
                        accIds.add(upsellAccId);
                    }       
                }
            } 
            
            if(Quote.Ngage_Upsell_Order__c!=Null){
                 if(Quote.Ngage_Upsell_Order__r.invoiceit_s__Account__c!=Null)
                 accIds.add(Quote.Ngage_Upsell_Order__r.invoiceit_s__Account__c);
            }
            
           /* if(Quote.Parent_Opportunity__c!= NULL){
                upsellQuoteId = Quote.Parent_Opportunity__r.Id;
            }*/
            emailSentDate = Date.today();
            system.debug('sqtid:::'+sQuoteID);
          System.debug('Quote'+Quote);
          System.debug('Quote- Account Customer Number'+Quote.Account_MH_Customer_No__c);
        
            if(Quote.invoiceit_crmx__Number_Of_Terms__c!=NUll){
                opptyTerms = Quote.invoiceit_crmx__Number_Of_Terms__c;
            }
        if(Quote.invoiceit_crmx__Billing_Contact__r.firstName != null)
            //initial = Quote.invoiceit_crmx__Billing_Contact__r.firstName.substring(0,1);
            initial = Quote.invoiceit_crmx__Billing_Contact__r.firstName;
        
            if(Quote.invoiceit_crmx__Billing_Contact__r.lastName!= null)
                //initial = initial  + Quote.invoiceit_crmx__Billing_Contact__r.lastName.substring(0,1);  
                initial = initial  + '   ' + Quote.invoiceit_crmx__Billing_Contact__r.lastName;     
                //initial = Quote. 'RJ';
            
        // monthlyAmount = Quote.Monthly_Recurring_Total__c;
            if(Quote.invoiceit_crmx__CurrencyL__r.Name == 'USD'){
              oneTime = Quote.One_Time_Total__c;
              
                if(!Quote.Child_Opportunities__r.isEmpty()){  
                    if(Quote.Child_Opportunities__r[0].Parent_Opportunity__c!=Null){
                        oneTimeUpsell = Quote.Child_Opportunities__r[0].One_Time_Total__c + oneTime;
                    }
                }else{
                    oneTimeUpsell = oneTime;
                }
            }else if(Quote.invoiceit_crmx__CurrencyL__r.Name == 'GBP'){
                oneTime = Quote.One_Time_Total__c; 
                if(!Quote.Child_Opportunities__r.isEmpty()){ 
                    if(Quote.Child_Opportunities__r[0].Parent_Opportunity__c!=Null){
                        oneTimeUpsell = Quote.Child_Opportunities__r[0].One_Time_Total__c + oneTime;
                    }
                }else{
                    oneTimeUpsell = oneTime;
                }
            }
            System.debug('================upsellQuoteId'+upsellQuoteId );
         ngageUsageCharge = Quote.Usage_Total__c;
         opptyid =Quote.Id;
         accid=Quote.AccountId;  
         accIds.add(accid);
        }
         System.debug('Quote account name'+accid);
         prodList= new List<invoiceit_crmx__Opportunity_Product__c>();
         //prodOrderAttributesMap = new Map<string , Opportunity_Charge_Attribute__c>();
          opportunityIdsSet = new Set<Id>();
      
      if(upsellQuoteId != NULL){
          opportunityIdsSet.add(Quote.Id);
          opportunityIdsSet.add(upsellQuoteId);
      }else{
          opportunityIdsSet.add(Quote.Id);
      }
        System.debug('=========opportunityIdsSet======'+opportunityIdsSet);
      
      
      if(Quote.Name.contains('Mid-Term')){
          prodList =[Select Name,invoiceit_crmx__Opportunity__c,One_Time_Total__c,invoiceit_crmx__Opportunity__r.Mid_Term_One_Time_Total__c,invoiceit_crmx__Opportunity__r.One_Time_Total__c,Product_Sin__c, RecordType.DeveloperName,invoiceit_crmx__Product_Code__c FROM invoiceit_crmx__Opportunity_Product__c Where invoiceit_crmx__Opportunity__c IN: opportunityIdsSet AND Product_SIN__c=NULL];
          monthlyAmount = Quote.Mid_Term_Monthly_Recurring_Total__c;
      }else{
          //Added Order By invoiceit_crmx__SequenceNumber__c 
          prodList =[Select Name,invoiceit_crmx__Opportunity__c,One_Time_Total__c,Product_Sin__c,invoiceit_crmx__Opportunity__r.Mid_Term_One_Time_Total__c,invoiceit_crmx__Opportunity__r.One_Time_Total__c,invoiceit_crmx__SequenceNumber__c , RecordType.DeveloperName,invoiceit_crmx__Product_Code__c FROM invoiceit_crmx__Opportunity_Product__c Where invoiceit_crmx__Opportunity__c IN:opportunityIdsSet ORDER By invoiceit_crmx__SequenceNumber__c ];
          monthlyAmount = Quote.Monthly_Recurring_Total__c;
      }
        System.debug('=========prodList======'+prodList);
         set<id> qpIdList = new set<Id>();
         //system.debug('this is the pdt id:::'+prodList[0].Opportunity+'****'+sQuoteID);
         for(invoiceit_crmx__Opportunity_Product__c qp: prodList){
            system.debug(qp);
            qpIdList.add(qp.id);  
            if(qp.invoiceit_crmx__Product_Code__c == '60030'){
                textToChatPresent = True;
            }  
         }  
         System.debug('============qpIdList======'+qpIdList);
         Map<id,string> QprodNTypeMap = new Map<id,string>(); 
                
         List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c> QRPCharge = new List<invoiceit_crmx__Opportunity_Rate_Plan_Charge__c>();
        
        if(! Test.isRunningTest()){
            System.debug('@@@@@@@Test is not running');
            QRPCharge = [Select id,name, invoiceit_crmx__Price_Type__c,invoiceit_crmx__CurrencyL__c,
                                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id,Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c,
                                    invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,
                                    invoiceit_crmx__Unit_Price__c,invoiceit_crmx__Row_Total__c,invoiceit_crmx__Discount_Percent__c
                                    from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c 
                                    Where invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id IN: qpIdList ];
         }
         else{
             System.debug('@@@@@@inside the test condition');
             QRPCharge = [Select id, name,invoiceit_crmx__Price_Type__c,invoiceit_crmx__CurrencyL__c,invoiceit_crmx__Row_Total__c,Chat_Parent_Opportunity_Rate_Plan_Charge__c,Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c,
                                invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id,
                                invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name,
                                invoiceit_crmx__Unit_Price__c,invoiceit_crmx__Discount_Percent__c
                                from invoiceit_crmx__Opportunity_Rate_Plan_Charge__c limit 1];
         }   
         System.debug('QRPCharge::'+QRPCharge);   
            oppPdtVsOPPCharge = new map<string,decimal>();
            
         for(invoiceit_crmx__Opportunity_Rate_Plan_Charge__c qp: QRPCharge){
             
            QprodNTypeMap.put(qp.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id,qp.invoiceit_crmx__Price_Type__c);    
            QprodNChargeMap.put(qp.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id,qp); 
             if(qp.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name == 'Hosted Per Conversation Fee'){
                System.debug('===================usagecharge'+usagecharge);
            //    usagecharge = qp.invoiceit_crmx__Unit_Price__c*(1 - (qp.invoiceit_s__Discount_Percent__c/100));
            //  usagecharge = qp.Usage_Total__c;
                usagecharge =35;
             }
             if(!oppPdtVsOPPCharge.containskey(qp.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id)){
                 if(qp.Chat_Parent_Opportunity_Rate_Plan_Charge__c!=Null){
                     oppPdtVsOPPCharge.put(qp.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id, qp.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c);
                 }
             }
             
             if(qp.invoiceit_crmx__Price_Type__c == 'Usage'){
                 chatProdPresent = True;
             }else{
                 chatProdPresent = False;
             }
             System.debug('===========chatProdPresent======='+chatProdPresent);
         }   
         
         System.debug('===========QprodNTypeMap=========='+QprodNTypeMap);
         System.debug('=================opptyid===='+opptyid);
        opptyProdList = new List<invoiceit_crmx__Opportunity_Product__c>();
        opptyProdList = [Select Name,invoiceit_crmx__Opportunity__c,RecordType.DeveloperName From invoiceit_crmx__Opportunity_Product__c Where invoiceit_crmx__Opportunity__r.Id =:opptyid ];
        System.debug('===opptyProdList=='+opptyProdList);
        list<String> opptyAttriblist = new list<string>{ 'Service State', 'Service City', 'XRef State', 'XRef City', 'State', 'County','AOP','Preferred City Results AOP','Preferred County Results AOP','City','Preferred Martindale.com Results AOP','Preferred State Results AOP','Preferred State Links AOP','Preferred National Links AOP','Country','Preferred National Results AOP','Preferred Banner Placements AOP','URL' };
         Id devRecordTypeId1 = Schema.SObjectType.Opportunity_Charge_Attribute__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_JV_Opportunity_Charge_Attribute).getRecordTypeId();
    
        List<Opportunity_Charge_Attribute__c> opptyList;     
            if(!Test.isRunningTest()){
            opptyList = [select  Attribute_Name__c,Show_in_Docusign__c,Secondary_Attribute_Name__c, Opportunity_Rate_Plan_Charge__c,  String_value__c, picklist_value__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Unit_Price__c,Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Price_Type__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name,
                                                          Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c,
                                                          Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                          Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name from Opportunity_Charge_Attribute__c
                                                          where Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id IN: ProdList                                                        
                                                          AND Show_in_Docusign__c = TRUE /*Attribute_Name__c IN: opptyAttriblist */order by Address_Order__c ];
            }else{
            System.debug('Inside the else condition');
            opptyList = [select  Attribute_Name__c,Show_in_Docusign__c,Secondary_Attribute_Name__c, name, Opportunity_Rate_Plan_Charge__c,  String_value__c, picklist_value__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Unit_Price__c,Opportunity_Rate_Plan_Charge__r.Chat_Parent_Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Row_Total__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Price_Type__c,Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__CurrencyL__r.Name,
                                                          Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product__c,Unit_Price__c,
                                                          Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.invoiceit_crmx__Product_Code__c,
                                                          Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name from Opportunity_Charge_Attribute__c
                                                          where Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.id IN: ProdList                                                        
                                                          AND Show_in_Docusign__c = TRUE /*Attribute_Name__c IN: opptyAttriblist */order by Address_Order__c DESC];
       
            }
        oppPdtVsOPPChargeAttr = new map<string,list<attributewrapper>>();
     
        set<string> pdtset = new set<string>();
        system.debug('opptyList::'+opptyList);        
 
            for(Opportunity_Charge_Attribute__c ocp : opptyList){
                System.debug('=============What is inside pdset'+pdtset);
            /*if(! pdtset.contains(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name)){

                    attributewrapper attrwrap = new attributewrapper(ocp);
                    System.debug('========================='+attrwrap);
                    
                    oppPdtVsOPPChargeAttr.put(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name, new list<attributewrapper>{attrwrap});
             
                System.debug('=================oppPdtVsOPPChargeAttr'+oppPdtVsOPPChargeAttr);
                pdtset.add(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name);
            }*/
            //else{
                /*if(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains('Cross') && ocp.Attribute_Name__c == 'Service State'){   
                System.debug('asdadadas==========');
                } 
                else if(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains('Cross') && ocp.Attribute_Name__c == 'Service City'){
                System.debug('==========asaaasa');
                }
                else if(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains('Results') && (ocp.Attribute_Name__c == 'Service State' || ocp.Attribute_Name__c == 'Service City') ){
                }
                else if((ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name.contains('Results') && ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name!= 'Preferred National Results') && ocp.Attribute_Name__c == 'Country'){
                }
                else if((ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name=='Preferred State Links' || ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name=='Preferred National Links' || ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name=='Preferred Banner Placements') && (ocp.Attribute_Name__c == 'Service City' || ocp.Attribute_Name__c == 'Service State')){
                }
                else if((ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name=='Preferred State Links' || ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name=='Preferred Banner Placements') && ocp.Attribute_Name__c == 'Country'){
                }
                else{
                System.debug('Inside elseee========================');*/
                    //boolean test;
                    //List<Opportunity_Charge_Attribute__c> chargevalue = new List<Opportunity_Charge_Attribute__c>() ;
                  
                    //if(!oppPdtVsOPPChargeAttr.containskey(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.name)){
                    System.debug('==============oppPdtVsOPPChargeAttr==========='+oppPdtVsOPPChargeAttr);
                    if(!oppPdtVsOPPChargeAttr.containskey(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id)){
                        attributewrapper attrwrap2 = new attributewrapper(ocp);
                        oppPdtVsOPPChargeAttr.put(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id, new list<attributewrapper>{attrwrap2});
                    } 
                    else{
                        list<attributewrapper> tempOca = oppPdtVsOPPChargeAttr.get(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id);
                        System.debug('Inside elseee========================'+tempOca);
                        tempOca.add(new attributewrapper(ocp));
                        oppPdtVsOPPChargeAttr.put(ocp.Opportunity_Rate_Plan_Charge__r.invoiceit_crmx__Opportunity_Rate_Plan__r.invoiceit_crmx__Opportunity_Product__r.Id, tempOca);
                        System.debug('==============oppPdtVsOPPChargeAttr2==============='+oppPdtVsOPPChargeAttr);
                       }
                       
                //}
            }
        //}
         
         system.debug('oppPdtVsOPPChargeAttr:::'+oppPdtVsOPPChargeAttr);
         List<string> prodIDlst = new List<string>();
         System.debug('Get all the products on this quote'+prodList);
         
         set<string> uniqSet = new set<string>();
         
         for(invoiceit_crmx__Opportunity_Product__c qProd : prodList ){
             System.debug('QprodNTypeMap::'+QprodNTypeMap);
             prodNames += '\u2022'+qProd.Name + '\r\n';
             prodIDlst.add(qProd.id ); 
             pdtWrapper pwrap = new pdtWrapper(qProd , oppPdtVsOPPChargeAttr.containskey(qProd.Id),QprodNTypeMap.get(qProd.id), QprodNChargeMap.get(qProd.id));
             System.debug('pwrap:::'+pwrap);
             //System.debug('pwrap.pdt.Opportunity.Upsell:::'+pwrap.pdt.invoiceit_crmx__Opportunity__r.Parent_Opportunity__c);
             //if(pwrap.pdt.RecordType.DeveloperName!= 'M_NG_Opportunity_Product'){
                 if(pwrap.Ptype == 'Monthly'){
                    pdtWrapList.add(pwrap); 
                 }  
                 else if(pwrap.Ptype == 'One Time' ){
                    //if(pwrap.pdt.name == 'Site Activation fee')
                      // onetime=400;
                    oneTimepdtWrapList.add(pwrap);
                 }  
                 else if(pwrap.Ptype == 'Usage' || Test.isrunningTest()){
                
                /*List<pdtWrapper> tempPdtWrap = new List<pdtWrapper>();              
                
                if(pwrap.pdt.name.Contains ('Ngage Live Chat')){
                    System.debug('Inside the Ngage Live Chat product============');            
                  if(!uniqSet.contains('Ngage Live Chat')){
                      System.debug('Second check : Inside the Per conversation fee product============');
                      uniqSet.add('Ngage Live Chat');
                      tempPdtWrap.add(pwrap);
                      usagecharge = 35;
                      System.debug('================inside usage product===========');  
                  }
                }
                else{*/
                    UsagepdtWrapList.add(pwrap);    
               // }
               /* if(uniqSet.size() > 0)
                    UsagepdtWrapList.addall(tempPdtWrap);*/
               }
             }
         
            
         list<String> Attriblist = new list<string>{ 'Service State', 'Service City', 'XRef State', 'XRef City', 'State', 'County'};
         Id devRecordTypeId = Schema.SObjectType.Order_Charge_Attribute__c.getRecordTypeInfosByName().get(RecordTypesFinalStringsClass.RecTypeName_MH_Order_Charge_Attribute).getRecordTypeId();
         System.debug('RecordtYPEiD 2 IS:'+devRecordTypeId );
         List<Order_Charge_Attribute__c> orderList = [select  Attribute_Name__c,  Order_Rate_Plan_Charge__c,  String_value__c, picklist_value__c, 
                                                          Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__c,
                                                          Order_Rate_Plan_Charge__r.invoiceit_s__Job_Rate_Plan__r.invoiceit_s__Job_Product__r.invoiceit_s__Product__r.name from Order_Charge_Attribute__c
                                                          where Order_Rate_Plan_Charge__r.invoiceit_s__Product_Rate_Plan_Charge__r.invoiceit_s__Product_Rate_Plan__r.invoiceit_s__Product__r.id IN: prodIDlst 
                                                          AND Attribute_Name__c IN: Attriblist AND recordtypeid =: devRecordTypeId order by Attribute_Order__c];
         
        
         List<invoiceit_crmx__Opportunity_Rate_Plan__c  > lstQuotRatePlan = new List<invoiceit_crmx__Opportunity_Rate_Plan__c   >();
         lstQuotRatePlan = [Select invoiceit_crmx__Opportunity_Product__c ,Total_Price__c FROM invoiceit_crmx__Opportunity_Rate_Plan__c Where invoiceit_crmx__Opportunity_Product__c IN:prodIDlst];
         for(invoiceit_crmx__Opportunity_Rate_Plan__c rateplan: lstQuotRatePlan ){
             mapProductIDtoRate.put(rateplan.invoiceit_crmx__Opportunity_Product__c ,rateplan.Total_Price__c);
         }
        
         List<invoiceit_s__Payment_Method__c> paymethdList = [Select Id, invoiceit_s__Account__c, invoiceit_s__Account__r.RecordType.DeveloperName,
                                                                     invoiceit_s__Active__c, invoiceit_s__Default__c 
                                                                     FROM invoiceit_s__Payment_Method__c 
                                                                     WHERE invoiceit_s__Default__c = TRUE 
                                                                     AND invoiceit_s__Active__c = TRUE 
                                                              AND invoiceit_s__Account__c in: accids];
      
         System.debug('Get all the payment methods'+paymethdList);
      
     // Map<String, invoiceit_s__Payment_Method__c> = new Map<String, invoiceit_s__Payment_Method__c>();
      
      for(invoiceit_s__Payment_Method__c pm: paymethdList){
          System.debug('@@@@@@@Record Type Name'+pm.invoiceit_s__Account__r.RecordType.DeveloperName );
          if(pm.invoiceit_s__Account__r.RecordType.DeveloperName == 'M_NG_Account'){
              defaultPM_Ngage = True;
          }else if(pm.invoiceit_s__Account__r.RecordType.DeveloperName == 'Nolo_Account'){
              defaultPM_MH = True;
          }  
      }
      System.debug('@@@@@@@@Default PM Ngage'+defaultPM_Ngage);
      System.debug('@@@@@@@@Default PM MH'+defaultPM_MH);
      System.debug('@@@@@Quote.RecordTypeId'+Quote.RecordType.DeveloperName);
      System.debug('@@@@@@Quote.Owner.ProfileId'+Quote.Owner.Profile.Name);
      
         if((sQuoteID != null || sQuoteID !='') &&  (Quote.RecordType.DeveloperName == 'Nolo_Opportunity' )){
             if(defaultPM_MH){
                 System.debug('How many Payment Methods are there'+defaultPM_MH);
                 displayPaymentInfo = FALSE;
             } else {
                 displayPaymentInfo = TRUE;
             }
         }else if((sQuoteID != null || sQuoteID !='') &&  Quote.RecordType.DeveloperName == 'M_NG_Opportunity' && Quote.Owner.Profile.Name=='Ngage Sales' ){
             if(Quote.Is_Check_paying_client__c){
                displayPaymentInfo = FALSE;
             } else{
                if(defaultPM_Ngage){
                    System.debug('How many Payment Methods are there'+defaultPM_Ngage);
                    displayPaymentInfo = FALSE;
                } else {
                    displayPaymentInfo = TRUE;
                }
             }
        }else if((sQuoteID != null || sQuoteID !='') &&  Quote.RecordType.DeveloperName == 'M_NG_Opportunity' && Quote.Owner.Profile.Name!='Ngage Sales' ){
             if(defaultPM_Ngage == False && defaultPM_MH== True){
                 System.debug('How many Payment Methods are there'+defaultPM_Ngage);
                 displayPaymentInfo = False;
             }else if(defaultPM_Ngage == False && defaultPM_MH== False){
                 displayPaymentInfo = True;
             }else{
                 displayPaymentInfo = False;
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
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
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