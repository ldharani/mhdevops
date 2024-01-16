public class CPQ_PaymentMethodController {
    public static void CPQ_PaymentMethodController(List<blng__PaymentMethod__c> pymntMthdLst){
        system.debug('==pymntMthdLst=='+pymntMthdLst);
        Boolean valid; 
        String errMsg = '';
        
        Profile objProfile = [Select Id, Name from Profile where Name =: 'System Administrator' limit 1];
        User objeUser = [Select Id, ProfileId from User where Id=: UserInfo.getUserId()];
        
        for(blng__PaymentMethod__c pm: pymntMthdLst){
            system.debug('==pm.blng__PaymentType__c=='+pm.blng__PaymentType__c);
            if(pm.blng__PaymentType__c == 'Credit Card'){
                system.debug('==pm.Card_Number__c=='+pm.Card_Number__c);
                //if(pm.blng__CardNumber__c == null || pm.blng__CardNumber__c == '') {
                if(pm.Card_Number__c == null || pm.Card_Number__c == '') {
                    pm.addError('Please enter the card number before saving the payment method');
                }   
                if(pm.blng__CardType__c == null) {
                    system.debug('==pm.blng__CardType__c=='+pm.blng__CardType__c);
                    pm.addError('Please select the card type before saving the payment method');
                }
                if(pm.blng__CardExpirationMonth__c == null) {
                    pm.addError('Please select the card expiration month before saving the payment method');
                }
                if(pm.blng__CardExpirationYear__c == null) {
                    pm.addError('Please select the card expiration year before saving the payment method');
                }
                //Added condition to Throw Validation Error only For new Records which dont have CVV OR existing records whose Default is set to 1 and CVV is blank 
               /*
                if(pm.CVV__c == null){
                    system.debug('==pm.CVV__c=='+pm.blng__CVV__c);
                    pm.addError('Please enter the CVV before saving the payment method');
                }
                 */
                if(pm.blng__Nameoncard__c == null || pm.blng__Nameoncard__c == '') {
                    pm.addError('Please enter Name of the card holder');
                }
                //for mod - 10 validation of credit card
                
                //if(pm.blng__CardNumber__c != Null){
                if(pm.Card_Number__c != Null){
                    //if(pm.blng__CardNumber__c.isNumeric()){
                    if(pm.Card_Number__c.isNumeric()){
                        //system.debug('==pm.blng__CardNumber__c=='+pm.blng__CardNumber__c.length());
                        system.debug('==pm.Card_Number__c=='+pm.Card_Number__c.length());
                        //valid = validateCreditCardNumber(pm.blng__CardNumber__c);
                        valid = validateCreditCardNumber(pm.Card_Number__c);
                        if(valid==false){
                            system.debug('==valid==');
                            pm.addError('The credit card number is not valid. Please enter a valid credit card number');
                        }
                    }
                    else{
                        pm.addError('The credit card number is not valid. Please enter a valid credit card number');
                    }
                }            
            }
        }
        //system.debug('==errMsg=='+errMsg);
        //return errMsg;
    }
    //mod - 10 validation
    public static boolean validateCreditCardNumber(String creditCardNumber){
        //// 1. Starting with the check digit double the value of every other digit 
        //// 2. If doubling of a number results in a two digits number, add up the digits to get a single digit number. This will results in eight single digit numbers                    
        //// 3. Get the sum of the digits
        String reversedCCN = creditCardNumber.reverse();
        system.debug('==reversedCCN=='+reversedCCN);
        Integer[] chars = reversedCCN.getChars();
        system.debug('==chars=='+chars);
        Boolean isValid = false;
        Integer sumOfNumbers = 0;
        for(Integer i = 0;i<chars.size();i++){
            chars[i] = chars[i] - 48;
            if(math.mod(i,2)!=0){
                chars[i] = chars[i] * 2;
            }
            sumOfNumbers += (chars[i]/10) + (math.mod(chars[i],10));
            System.debug(i+'  '+chars[i]+'  '+sumOfNumbers);
        }
        System.debug('sumOfNumbers'+sumOfNumbers);
        if(math.mod(sumOfNumbers,10)==0){
            isValid = true;
        }
        else{
            isValid = false;
        }
        return isValid;
    }
    
    public static void populateCreditCardNumber(List<blng__PaymentMethod__c> pymntMthdLst){
        for(blng__PaymentMethod__c pm: pymntMthdLst){
            system.debug('==pm.blng__CardNumber__c=='+pm.blng__CardNumber__c);
            if(pm.blng__CardNumber__c == null || pm.blng__CardNumber__c == ''){
                pm.blng__CardNumber__c = pm.Card_Number__c;
            }
            if(pm.blng__CVV__c == null || pm.blng__CVV__c == ''){
                pm.blng__CVV__c = pm.CVV__c;
            }
        }
        
    }
}