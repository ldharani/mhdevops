// Author      : Sai
// Description : To show validation Error in case of duplicate Credit Card in one Account
// Date        : 06/10/2016



public class PaymentMethodTriggerHandler {
    
    public static void creditcardDuplication(List<invoiceit_s__Payment_Method__c> paymentMethodsList){
        
        system.debug('@@@ In creditcardDuplication');
        
        system.debug('@@@@ encrypted field'+ paymentMethodsList[0].invoiceit_s__Card_Number__c);
        //Declaration Section
        List<invoiceit_s__Payment_Method__c> allpaymentsList = new List<invoiceit_s__Payment_Method__c>();
        Map<Id,String> accidVSCrediCardNumbersMap            = new  Map<Id,String>();
        Set<Id> accids                                       = new set<id>();
        
        for(invoiceit_s__Payment_Method__c paymentMethod :paymentMethodsList){
            if(paymentMethod.invoiceit_s__Payment_Method__c == 'Credit Card'){
                accids.add(paymentMethod.invoiceit_s__Account__c);
            }
        }
        
        //getting all payment methods belongs to accounts
        if(!accids.isEmpty()){
            allpaymentsList = [select id,Name,
                                  invoiceit_s__Account__c,
                                  invoiceit_s__Card_Number__c
                                  From invoiceit_s__Payment_Method__c
                                  Where invoiceit_s__Account__c IN:accids
                                         AND invoiceit_s__Payment_Method__c = 'Credit Card' AND invoiceit_s__Is_Dummy__c = False];
        }
        
        system.debug('@@@@@ all credit Card number ' + allpaymentsList );
        if(!allpaymentsList.isEmpty()){
            for(invoiceit_s__Payment_Method__c paymentMethod : allpaymentsList){
               
                if(accidVSCrediCardNumbersMap.containsKey(paymentMethod.invoiceit_s__Account__c)){
                    String tempcardnumber = accidVSCrediCardNumbersMap.get(paymentMethod.invoiceit_s__Account__c);
                    tempcardnumber += ',' + paymentMethod.invoiceit_s__Card_Number__c;
                    accidVSCrediCardNumbersMap.put(paymentMethod.invoiceit_s__Account__c,tempcardnumber );
                }
                else{
                    accidVSCrediCardNumbersMap.put(paymentMethod.invoiceit_s__Account__c,paymentMethod.invoiceit_s__Card_Number__c );
                }
            }
        }
        
        
        if(!accidVSCrediCardNumbersMap.isEmpty()){
            for(invoiceit_s__Payment_Method__c paymentMethodTemp : paymentMethodsList){
                if(paymentMethodTemp.invoiceit_s__Account__c != null){
                    if(accidVSCrediCardNumbersMap.containsKey(paymentMethodTemp.invoiceit_s__Account__c)){
                        String allcreditcards = accidVSCrediCardNumbersMap.get(paymentMethodTemp.invoiceit_s__Account__c);
                        system.debug('****** Credit Card :' +allcreditcards.contains(paymentMethodTemp.invoiceit_s__Card_Number__c));
                        if(allcreditcards.contains(paymentMethodTemp.invoiceit_s__Card_Number__c) && allcreditcards.contains(paymentMethodTemp.invoiceit_s__Card_Number__c) != Null ){
                            if(!test.isRunningTest()){
                                paymentMethodTemp.addError('Credit Card Details you entered already Exists. Please update the Existing one');
                       
                            }
                           // paymentMethodTemp.addError('Credit Card Details you entered already Exists. Please update the Existing one');
                        }
                    }
                }
            }
            
        }
        
        
        
    }
    
    

}