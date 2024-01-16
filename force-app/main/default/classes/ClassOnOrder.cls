public with sharing class ClassOnOrder {
    // Req : 1
    // For Renew Order we need to populate the service activation date and service end date
    //           service activation date =  old order.ServiceEndDate + 1
    //           service end date = above charge + number of terms on order

    // Req : 2
    // For Modify Order, once the old charge is modified we need to do :
    // A) Make the old charge expired
    // B) Make the new charge active from 30 days(i.e system.today + 30 days)

    // PS : Req : 1, 2 are done using before insert trigger
    //CHange made by Lister Technologies:allow creation of order for an account which has cancelled orders
    public static integer count = 0;
    
    public void handlebeforeOnOrder(list<invoiceit_s__Job__c> listOfOrders) {
        if(trigger.isInsert) {
            // LN-14
            // WHERE invoiceit_s__Service_End_Date__c > :todayDate
            map<Id, Account> mapAccountId_Account = new map<Id, Account>();
            Account account;
            //list<invoiceit_s__Job__c> orderList = new list<invoiceit_s__Job__c>();
            Date todayDate = System.today();
            for(invoiceit_s__Job__c order : listOfOrders) {
                if(order.Quote_Type__c != 'Renew' && order.Quote_Type__c != 'Modify') {
                    mapAccountId_Account.put(order.invoiceit_s__Account__c, null);  
                }
            }

            if(mapAccountId_Account.size() > 0) {
                mapAccountId_Account = new map<Id, Account>([SELECT Id, Name, (SELECT Id,invoiceit_s__Status__c,invoiceit_s__Service_End_Date__c FROM invoiceit_s__Job__r) FROM Account WHERE Id IN :mapAccountId_Account.keySet()]);

                for(invoiceit_s__Job__c order : listOfOrders) {
                    account = mapAccountId_Account.get(order.invoiceit_s__Account__c);
                    if(order.Quote_Type__c != 'Renew' && order.Quote_Type__c != 'Modify') {
                        if(account.invoiceit_s__Job__r.size() > 0) {
                            // needed to check Billing End Date
                            for(invoiceit_s__Job__c order1 : account.invoiceit_s__Job__r){
                                if(order1.invoiceit_s__Status__c != 'Cancelled') {
                                    if(order1.invoiceit_s__Service_End_Date__c != null){
                                        if(order1.invoiceit_s__Service_End_Date__c > todayDate){
                                            //order.addError('One account can have only one active order');   
                                            break;  
                                        }   
                                    } 
                                    else{
                                        //order.addError('One account can have only one active order');
                                        break;  
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else if(trigger.isUpdate) {
            list<invoiceit_s__Job__c> orders = new list<invoiceit_s__Job__c>();
            for(invoiceit_s__Job__c order : listOfOrders) {
                if((order.Quote_Type__c == 'Renew' || order.Quote_Type__c == 'Modify') && order.Recalculate_Date__c) {
                    //if(order.Orders_To_Expired__c == false && order.invoiceit_s__Service_End_Date__c == null) {
                    	orders.add(order);  
                    //}	
                    if(count >= 3) {
                        order.Recalculate_Date__c = false;
                    }
                }   
            }   

            system.debug('count is --> ' + count);
            system.debug('orders is --> ' + orders);
            
            if(orders.size() > 0) {
                ClassOnOrderRatePlanCharge.populateTheActivationDatesOnOrder(orders);
                ++count;
                
            }
            
        }
    }
}