public class ExistingAcctsOrderStatusHandling {
    
    public static void orderStatusHandlingforExistingaccts(list<account> acclist){
        
        system.debug('@@@@Start orderStatusHandlingforExistingaccts');
        map<id, account> idVsAccount = new map<id, account>(accList);
        system.debug('@@@ idVsAccount' + idVsAccount);
        
        //map to set loss date accidVSloassdate from orders 
        //latest service end date from orders
        map<id, Date> accidVsLossDate = new map<id, Date>();
        
        //map to store accid vS its acquisition dates from its respective orders
        map<id,Date> accidVsacquisitionDate = new map<id, Date>();
        
        // set to store accid which specifies for each account is their any opportunity
        // other that closed lost stage
        set<id> accidwhichContainsopps = new set<id>();
        
        
        for(Account acc : [select id, Name,MH_Cust_Number__c,
                                  (select id, Name,
                                         invoiceit_s__Service_Activation_Date__c,invoiceit_s__Job__c.invoiceit_s__Account__c
                                        from invoiceit_s__Job__r
                                         ORDER BY invoiceit_s__Service_Activation_Date__c ASC LIMIT 1),
                                 //inner query to set Prospect status on account 
                                 (select id, Name
                                      from Opportunities
                                      where StageName != 'Closed Lost' )
                                  From account
                                  where Id IN:(idVsAccount.keySet()) ]){
             for(invoiceit_s__Job__c order : acc.invoiceit_s__Job__r){
                    accidVsacquisitionDate.put(order.invoiceit_s__Account__c, order.invoiceit_s__Service_Activation_Date__c);                      
              }
             
              // adding accountids to set which contains atlease one opportunity other than closed lost stage                         
              if(acc.Opportunities != null && acc.Opportunities.size() > 0){
                   accidwhichContainsopps.add(acc.id);                       
              }                        
                                      
         }
        
        system.debug('@@@@accidVsacquisitionDate'+ accidVsacquisitionDate);
        system.debug('@@@@accidwhichContainsopps'+ accidwhichContainsopps);
        
        set<id> accidsWithOrders = new set<id>();
        List<invoiceit_s__Job__c> queriedorders = new List<invoiceit_s__Job__c>();
        map<id,list<invoiceit_s__Job__c>> accidVsorders = new map<id,list<invoiceit_s__Job__c>>();
        
        //querying all orders in the accconts
        //querying orders and status as active or evergreen on order
        queriedorders = [select id,Name,LastModifiedDate,
                             invoiceit_s__Status__c,invoiceit_s__Account__c,
                             invoiceit_s__Service_Activation_Date__c,
                             invoiceit_s__Service_End_Date__c
                             from invoiceit_s__Job__c
                              where  invoiceit_s__Account__c IN:(idVsAccount.keySet())];
        system.debug('@@@queriedorders' + queriedorders);
        
        
        Map<Id,invoiceit_s__Job__c> accIdVsactiveStatus  = new Map<Id,invoiceit_s__Job__c>();
        Map<Id,invoiceit_s__Job__c> accIdVsCancelledStatus  = new Map<Id,invoiceit_s__Job__c>();
        
        //to set acquisition date forming an aggregate query and map
        
        // forming accountId Vs orders map
        if(queriedorders !=null && !queriedorders.isEmpty()){
            for(invoiceit_s__Job__c singleInvoiceJob : queriedorders){
                accidsWithOrders.add(singleInvoiceJob.invoiceit_s__Account__c);
                if(singleInvoiceJob.invoiceit_s__Status__c == 'Active'
                   || singleInvoiceJob.invoiceit_s__Status__c == 'Evergreen'
                   //added line for cancel orders which will end at Month-End
                   ||(singleInvoiceJob.invoiceit_s__Status__c == 'Cancelled' && singleInvoiceJob.invoiceit_s__Service_End_Date__c > date.today() )){
                      
                       // to get the latest between active or evergreen status orders
                       If(accIdVsactiveStatus.containsKey(singleInvoiceJob.invoiceit_s__Account__c)){
                           If(accIdVsactiveStatus.get(singleInvoiceJob.invoiceit_s__Account__c).LastModifiedDate >= singleInvoiceJob.LastModifiedDate){
                               accIdVsactiveStatus.put(singleInvoiceJob.invoiceit_s__Account__c,singleInvoiceJob);
                           }
                           
                           
                       }
                       else{
                           accIdVsactiveStatus.put(singleInvoiceJob.invoiceit_s__Account__c,singleInvoiceJob);
                       }
                       
                       
                       
                       /*
                       if(accidVsorders.containsKey(singleInvoiceJob.invoiceit_s__Account__c)){
                            accidVsorders.get(singleInvoiceJob.invoiceit_s__Account__c).add(singleInvoiceJob);
                        }
                        else{
                            accidVsorders.put(singleInvoiceJob.invoiceit_s__Account__c, new List<invoiceit_s__Job__c>{singleInvoiceJob});
                        }*/
                   }
                
                //logic for setting loss date
                if(singleInvoiceJob.invoiceit_s__Status__c == 'Expired'
                   || (singleInvoiceJob.invoiceit_s__Status__c == 'Cancelled' && singleInvoiceJob.invoiceit_s__Service_End_Date__c < date.today() )){
                      //
                      /* if(singleInvoiceJob.invoiceit_s__Status__c != 'Active' || singleInvoiceJob.invoiceit_s__Status__c != 'Evergreen'
                       ||(singleInvoiceJob.invoiceit_s__Status__c == 'Cancelled' && singleInvoiceJob.invoiceit_s__Service_End_Date__c > date.today() )){*/
                       if(accidVsLossDate.containsKey(singleInvoiceJob.invoiceit_s__Account__c)){
                           if(accidVsLossDate.get(singleInvoiceJob.invoiceit_s__Account__c) < singleInvoiceJob.invoiceit_s__Service_End_Date__c){
                                accidVsLossDate.put(singleInvoiceJob.invoiceit_s__Account__c, singleInvoiceJob.invoiceit_s__Service_End_Date__c);
                           }
                           
                           // to get the latest between Cancell or expired
                            If(accIdVsCancelledStatus.get(singleInvoiceJob.invoiceit_s__Account__c).LastModifiedDate >= singleInvoiceJob.LastModifiedDate){
                               accIdVsCancelledStatus.put(singleInvoiceJob.invoiceit_s__Account__c,singleInvoiceJob);
                           }


                       }
                       else{
                            accidVsLossDate.put(singleInvoiceJob.invoiceit_s__Account__c, singleInvoiceJob.invoiceit_s__Service_End_Date__c);
                           accIdVsCancelledStatus.put(singleInvoiceJob.invoiceit_s__Account__c,singleInvoiceJob);
                       }
                       //
                       //}
                   }
                   
              
            }
        }
        
        system.debug('@@@@accidVsLossDate'+ accidVsLossDate);
        for(account singleacc : acclist){
            system.debug('@@@in outer loop');
            //this if condition specifies that there are orders in the account
            if(accidsWithOrders.contains(singleacc.id)){
               
                // To set acquisition date to Last service activation date
                if(singleacc.MH_Cust_Number__c.startsWith('1')){
                    system.debug('@@@ customer number starts with 1');
                        system.debug('@@@ accidVsacquisitionDate in loop'+ accidVsacquisitionDate);
                        //setting acquisition date for existing accounts starts with '1' customer number
                        if(accidVsacquisitionDate != null  && !accidVsacquisitionDate.isEmpty()){
                            if(accidVsacquisitionDate.containsKey(singleacc.id)){
                                system.debug('@@@in acquistion date');
                                singleacc.Acquisition_date__c = accidVsacquisitionDate.get(singleacc.id);
                            }
                        }
                     
                }
                
                 //this if conditions specifies that there are orders with status as active or evergreen in the account
                if(accIdVsactiveStatus.containsKey(singleacc.id)){
                    //singleacc.Order_Status__c = 'Active';
                    if(accIdVsactiveStatus.get(singleacc.id).invoiceit_s__Status__c == 'Cancelled'){
                        singleacc.Order_Status__c = 'Active';
                    }
                    else{
                        singleacc.Order_Status__c = accIdVsactiveStatus.get(singleacc.id).invoiceit_s__Status__c;
                    }
                      
                    //checking for customer number starts with 1
                    
                    if(singleacc.Acquisition_date__c!= null && singleacc.Re_acquisition_date__c == NULL ){ // 
                    
                            Integer currentYear = System.Today().year();
                        //if(singleacc.MH_Cust_Number__c.startsWith('1')){
                            if( singleacc.Acquisition_date__c.year() >=  currentYear ){
                            singleacc.Customer_Status__c = 'New';
                        }
                        //else if(singleacc.MH_Cust_Number__c.startsWith('5')){
                        else if(singleacc.Acquisition_date__c.year() <  currentYear ){
                            singleacc.Customer_Status__c = 'Existing';
                        }   
                    }
                    else{
                         if(singleacc.Loss_Date__c != null && singleacc.Re_acquisition_date__c != null){
                                 if(singleacc.Loss_Date__c.year() == singleacc.Re_acquisition_date__c.year()){
                                        singleacc.Customer_Status__c = 'Existing';
                                        //singleacc.Win_back__c = false;
                                 }
                                 else if(singleacc.Re_acquisition_date__c.year() > singleacc.Loss_Date__c.year()){
                                             singleacc.Customer_Status__c = 'New';
                                            //singleacc.Win_back__c = true;
                                 }
                                 else if( Math.abs(Integer.valueOf(singleacc.Loss_Date__c.year() - singleacc.Re_acquisition_date__c.year())) >=0){
                                     singleacc.Customer_Status__c = 'New';
                                     //singleacc.Win_back__c = true;
                                 }
                                 else if(Math.abs(Integer.valueOf(singleacc.Loss_Date__c.year()-singleacc.Re_acquisition_date__c.year())) ==0){
                                     singleacc.Customer_Status__c = 'Existing';
                                     //singleacc.Win_back__c = true; 
                                 }
                                 
                             }
                    }
                     
                }
                else if(accIdVsCancelledStatus.containsKey(singleacc.id)){
                    singleacc.Order_Status__c = accIdVsCancelledStatus.get(singleacc.id).invoiceit_s__Status__c;
                    singleacc.Customer_Status__c = 'Former Sub';
                    //if(singleacc.MH_Cust_Number__c.startsWith('1')){
                        //setting Loss date for existing accounts starts with '1' customer number
                        if(accidVsLossDate != null  && !accidVsLossDate.isEmpty()){
                            if(accidVsLossDate.containsKey(singleacc.id)){
                                system.debug('@@@in loss date');
                                singleacc.Loss_Date__c = accidVsLossDate.get(singleacc.id);
                            }
                        }
                    //}
                     
                        
                }
                    
            }
            
            else{
                      //setting customer status as Prospect if this account contains atlease one opportunity
                        //other than closed lost stage
                        if(singleacc.MH_Cust_Number__c.startsWith('1')){
                            if(accidwhichContainsopps != null && !accidwhichContainsopps.isEmpty()){
                               if(accidwhichContainsopps.contains(singleacc.id)){
                                    singleacc.Customer_Status__c = 'PROSPECT';
                                }
                            }
                        }   
                        
            }
        }
        
        try{
            system.debug('@@@acclist'+ acclist);
            update acclist;
        }
        catch(exception e){
            system.debug('@@@exception' + e);
        }
        
        
    }

}