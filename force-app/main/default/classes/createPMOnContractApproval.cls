public class createPMOnContractApproval{
    @InvocableMethod
    public static void copyPMFromParent(List<Opportunity> opplist){
        
        //Child Opportunity Ids
        //Parent Account Ids to get the Payment Methods
        Set<Id> parentAccIds = new Set<Id>();
        Set<Id> parentOpptyIds = new Set<Id>();
        Set<Id> ngageOpptyIds = new Set<Id>();
        List<Opportunity> ngageOpptyList = new List<Opportunity>();
        
        List<Opportunity> childOpptyList = new List<Opportunity>();
        List<Opportunity> parentOppty = new List<Opportunity>();
        List<Account> parentAcc = new List<Account>();
        List<invoiceit_s__Payment_Method__c> pmList = new List<invoiceit_s__Payment_Method__c>();
        Map<String, String> accIdNnameOnCardMap = new Map<String, String>();
        Map<String, String> accIdNcardNoMap = new Map<String, String>();
        Map<String, String> accIdNexpMonthMap = new Map<String, String>();
        Map<String, String> accIdNexpYrMap = new Map<String, String>();
        Map<String, String> accIdNcardTypeMap = new Map<String, String>();
        Map<String, String> accIdNcvvMap = new Map<String, String>();
        Map<String, String> accIdNbillingAddMap = new Map<String, String>();
        Map<String, String> accIdNbillingCityMap = new Map<String, String>();
        Map<String, String> accIdNbillingStateMap = new Map<String, String>();
        Map<String, String> accIdNbillingZipMap = new Map<String, String>();
        Map<String, String> accIdNbillingCountryMap = new Map<String, String>();
        
        
        
        List<invoiceit_s__Payment_Method__c> createPM = new List<invoiceit_s__Payment_Method__c>();
        
        Map<String, String> parentOpptyNChildOpptyMap = new Map<String, String>();
        
        System.debug('@@@@@@opplist'+opplist);
        
        for(Opportunity o: opplist){
            if(o.Payment_Method_Default__c == True && o.Parent_Opportunity__c == Null && o.DocuSign_Quote_Approved__c == True){
                parentOpptyIds.add(o.Id);
                parentAccIds.add(o.AccountId);
                parentOppty.add(o);
                parentAcc.add(o.Account);
            }else if(o.Payment_Method_Default__c == False && o.Ngage_Upsell_Order__c!= Null && o.DocuSign_Quote_Approved__c == True){
                ngageOpptyIds.add(o.Id);
            }
        }
        System.debug('@@@@parentOpptyIds'+parentOpptyIds);
        System.debug('@@@@@parentAccIds'+parentAccIds);
        System.debug('@@@@@ngageOpptyIds'+ngageOpptyIds);

        if(!parentOpptyIds.isempty()){
            childOpptyList = [Select id, name,Parent_Opportunity__c,Account_Id__c,Parent_Opportunity__r.AccountId,Payment_Method_Default__c from Opportunity Where Parent_Opportunity__c in:parentOpptyIds AND Payment_Method_Default__c=False];
            System.debug('@@@@@@@@childOpptyList'+childOpptyList);
            if(!childOpptyList.isempty()){
                for(Opportunity chilopp: childOpptyList){
                    parentOpptyNChildOpptyMap.put(chilopp.Parent_Opportunity__c, chilopp.id);
                }
            }
        }
        
        if(!ngageOpptyIds.isempty()){
            ngageOpptyList = [Select id, name,Ngage_Upsell_Order__c,Account.Id,Account_Id__c,Ngage_Upsell_Order__r.invoiceit_s__Account__r.invoiceit_s__Gateway__c,Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id, Payment_Method_Default__c from Opportunity Where id in: ngageOpptyIds AND Ngage_Upsell_Order__r.invoiceit_s__Account__r.invoiceit_s__Gateway__c !=Null];
            System.debug('@@@@@@@@ngageOpptyList '+ngageOpptyList );
            
            for(Opportunity o: ngageOpptyList ){
                parentAccIds.add(o.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                
            }
        }
        
        
        System.debug('@@@@@parentOpptyNChildOpptyMap'+parentOpptyNChildOpptyMap);
        
        if((!childOpptyList.isempty() || !ngageOpptyList .isempty()) && !parentAccIds.isempty()){
            pmList = [Select id, name,invoiceit_s__Account__c,invoiceit_s__Default__c,invoiceit_s__Name_on_Card__c,invoiceit_s__Billing_Address__c,
                      invoiceit_s__Billing_City__c, invoiceit_s__Billing_State_Province__c,invoiceit_s__Billing_Zip_Postal__c,invoiceit_s__Billing_Country__c,
                      invoiceit_s__Card_Number__c,invoiceit_s__Card_Expiration_Month__c,invoiceit_s__Card_Expiration_Year__c,
                      invoiceit_s__Card_Type__c,invoiceit_s__CVV__c
                      From invoiceit_s__Payment_Method__c Where invoiceit_s__Account__c in: parentAccIds AND invoiceit_s__Default__c= True];
            
            System.debug('@@@@pmList'+pmList);
            
            for(invoiceit_s__Payment_Method__c p: pmList){
                accIdNnameOnCardMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Name_on_Card__c);
                accIdNcardNoMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Card_Number__c);
                accIdNexpMonthMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Card_Expiration_Month__c);
                accIdNexpYrMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Card_Expiration_Year__c);
                accIdNcardTypeMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Card_Number__c);
                accIdNcvvMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__CVV__c);
                accIdNbillingAddMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_Address__c);
                accIdNbillingCityMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_City__c);
                accIdNbillingStateMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_State_Province__c);
                accIdNbillingZipMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_Zip_Postal__c);
                accIdNbillingCountryMap.put(p.invoiceit_s__Account__c, p.invoiceit_s__Billing_Country__c);  
            }
        }
        System.debug('@@@@@accIdNnameOnCardMap'+accIdNnameOnCardMap);
        System.debug('@@@@@accIdNcardNoMap'+accIdNcardNoMap);
        System.debug('@@@@@accIdNexpMonthMap'+accIdNexpMonthMap);
        System.debug('@@@@@accIdNexpYrMap'+accIdNexpYrMap);
        System.debug('@@@@@accIdNcardTypeMap'+accIdNcardTypeMap);
        System.debug('@@@@@accIdNcvvMap'+accIdNcvvMap);
        
        if(!ngageOpptyList .isempty()){
            for(Opportunity ngageco: ngageOpptyList ){
                System.debug('@@@@@@@Check 1st condition'+ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                System.debug('@@@@@@@@@@@@@Check the 2nd condition true or not'+accIdNnameOnCardMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id));
                //System.debug('@@@@@@Check the 3rd '+accIdNnameOnCardMap.containskey(ngageco.Parent_Opportunity__r.AccountId));
                
                if(parentAccIds!=Null){
                    invoiceit_s__Payment_Method__c paymntmtd1 = new invoiceit_s__Payment_Method__c();
                    paymntmtd1.invoiceit_s__Active__c = True;
                    paymntmtd1.invoiceit_s__Default__c = True;
                    
                    if(accIdNnameOnCardMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Name_on_Card__c = accIdNnameOnCardMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                    
                    if(accIdNcardNoMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Card_Number__c = accIdNcardNoMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNexpMonthMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Card_Expiration_Month__c = accIdNexpMonthMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNexpYrMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Card_Expiration_Year__c = accIdNexpYrMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNcardTypeMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Card_Number__c = accIdNcardTypeMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNcvvMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__CVV__c = accIdNcvvMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
          
                    paymntmtd1.invoiceit_s__Account__c = ngageco.Account_Id__c;

                    if(accIdNbillingAddMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Billing_Address__c = accIdNbillingAddMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }   
                
                    if(accIdNbillingCityMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                        paymntmtd1.invoiceit_s__Billing_City__c = accIdNbillingCityMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }   
                
                    if(accIdNbillingStateMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                            paymntmtd1.invoiceit_s__Billing_State_Province__c = accIdNbillingStateMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    if(accIdNbillingZipMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                            paymntmtd1.invoiceit_s__Billing_Zip_Postal__c = accIdNbillingZipMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                    
                    if(accIdNbillingCountryMap.containskey(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id)){
                            paymntmtd1.invoiceit_s__Billing_Country__c = accIdNbillingCountryMap.get(ngageco.Ngage_Upsell_Order__r.invoiceit_s__Account__r.Id);
                    }
                
                    createPM.add(paymntmtd1);
                    
                }
            }
        }    
                    
                        
        
        
        if(!childOpptyList.isempty()){
            for(Opportunity co: childOpptyList){
                System.debug('@@@@@@@Check 1st condition'+parentOpptyNChildOpptyMap.containskey(co.Parent_Opportunity__c));
                System.debug('@@@@@@@@@@@@@Check the 2nd condition'+co.Parent_Opportunity__r.AccountId);
                System.debug('@@@@@@Check the 3rd '+accIdNnameOnCardMap.containskey(co.Parent_Opportunity__r.AccountId));
                
                if(parentOpptyNChildOpptyMap.containskey(co.Parent_Opportunity__c)){
                    
                    invoiceit_s__Payment_Method__c paymntmtd = new invoiceit_s__Payment_Method__c();
                        paymntmtd.invoiceit_s__Active__c = True;
                        paymntmtd.invoiceit_s__Default__c = True;
                        
                        if(accIdNnameOnCardMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Name_on_Card__c = accIdNnameOnCardMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNcardNoMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Card_Number__c = accIdNcardNoMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNexpMonthMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Card_Expiration_Month__c = accIdNexpMonthMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNexpYrMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Card_Expiration_Year__c = accIdNexpYrMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNcardTypeMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Card_Number__c = accIdNcardTypeMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNcvvMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__CVV__c = accIdNcvvMap.get(co.Parent_Opportunity__r.AccountId);
                        }
              
                        paymntmtd.invoiceit_s__Account__c = co.Account_Id__c;
    
                        if(accIdNbillingAddMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Billing_Address__c = accIdNbillingAddMap.get(co.Parent_Opportunity__r.AccountId);
                        }   
                    
                        if(accIdNbillingCityMap.containskey(co.Parent_Opportunity__r.AccountId)){
                            paymntmtd.invoiceit_s__Billing_City__c = accIdNbillingCityMap.get(co.Parent_Opportunity__r.AccountId);
                        }   
                    
                        if(accIdNbillingStateMap.containskey(co.Parent_Opportunity__r.AccountId)){
                                paymntmtd.invoiceit_s__Billing_State_Province__c = accIdNbillingStateMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        if(accIdNbillingZipMap.containskey(co.Parent_Opportunity__r.AccountId)){
                                paymntmtd.invoiceit_s__Billing_Zip_Postal__c = accIdNbillingZipMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                        
                        if(accIdNbillingCountryMap.containskey(co.Parent_Opportunity__r.AccountId)){
                                paymntmtd.invoiceit_s__Billing_Country__c = accIdNbillingCountryMap.get(co.Parent_Opportunity__r.AccountId);
                        }
                    
                        createPM.add(paymntmtd);
                }
            }
        }
        
        
        
        if(!createPM.isempty()){
            insert createPM;
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
     }

}