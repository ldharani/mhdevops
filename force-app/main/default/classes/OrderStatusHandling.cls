// Author       : Sai
// Description  : this class is responsible for changing account's order status and other status
//                when order status changed on order


public class OrderStatusHandling {
    
    public static boolean RecursionOrderStatusHandling = true;
    public static void OrderStatusHandling_account(list<invoiceit_s__Job__c> orderList, map<id, invoiceit_s__Job__c> oldmap){
        
        system.debug('@@@@in OrderStatusHandling_account');
        set<id> accountids= new set<id>();
        List<invoiceit_s__Job__c> queriedAllorders = new List<invoiceit_s__Job__c>();
        List<invoiceit_s__Job__c> queriedorders = new List<invoiceit_s__Job__c>();
        List<invoiceit_s__Job__c> cancelledOrExpiredOrders = new List<invoiceit_s__Job__c>();
        
        map<id,list<invoiceit_s__Job__c>> accidVsorders = new map<id,list<invoiceit_s__Job__c>>();
        map<id,account> idVsaccount;  
        
        Map<id,list<invoiceit_s__Job__c>> currentAccIdVsOrders = new  Map<id,list<invoiceit_s__Job__c>>();
        
       
        system.debug('@@@ order list in OrderStatusHandling_account'+orderList); 
        //forming account ids set
        for(invoiceit_s__Job__c singleOrder : orderList){
            system.debug('@@@@@single order invsoice status'+ singleOrder.invoiceit_s__Status__c);
            
            //system.debug('@@@@@ single order old stataus'+ oldmap.get(singleOrder.id).invoiceit_s__Status__c);
            if(singleOrder.invoiceit_s__Status__c == 'Active' || singleOrder.invoiceit_s__Status__c == 'Evergreen'
                        || singleOrder.invoiceit_s__Status__c == 'Cancelled'
               || singleOrder.invoiceit_s__Status__c == 'Expired'){
                   //if(oldmap == null || (oldmap != null && oldmap.get(singleOrder.id).invoiceit_s__Status__c != singleOrder.invoiceit_s__Status__c)){
                   if(oldmap == null || (oldmap != null && oldmap.get(singleOrder.id).invoiceit_s__Status__c != singleOrder.invoiceit_s__Status__c) ){
                       accountids.add(singleOrder.invoiceit_s__Account__c);
                       
                       //this map holds the account id Vs orders of active or evergreen  or cancel with enddate > today
                      /* if(singleOrder.invoiceit_s__Status__c != 'Expired'){
                           if(currentAccIdVsOrders.containsKey(singleOrder.invoiceit_s__Account__c)){
                               currentAccIdVsOrders.get(singleOrder.invoiceit_s__Account__c).add(singleOrder);
                           }
                           else{
                               currentAccIdVsOrders.put(singleOrder.invoiceit_s__Account__c, new List<invoiceit_s__Job__c>{singleOrder});
                               
                           }
                       }*/
                       
                   }
               } 
                               
            
        }
        
        system.debug('@@@@accountids'+ accountids);
        
        if(accountids.size() > 0){
             //querying orders and status as active or evergreen on order
            queriedAllorders = [select id,Name,invoiceit_crmx__Opportunity__r.one_time_charge_available__c,
                                invoiceit_s__Status__c,invoiceit_s__Account__c,createdDate,invoiceit_s__Start_Date__c,
                                invoiceit_s__Service_Activation_Date__c,invoiceit_s__Service_End_Date__c 
                                from invoiceit_s__Job__c
                                where /*(invoiceit_s__Status__c = 'Active'
                                        OR invoiceit_s__Status__c = 'Evergreen'
                                        OR (invoiceit_s__Status__c = 'Cancelled' AND invoiceit_s__Service_End_Date__c > TODAY ) )
                                     
                                    and*/ invoiceit_s__Account__c IN:accountids
                                    ORDER BY CreatedDate DESC];
       
            for(invoiceit_s__Job__c singleInvoiceJob : queriedAllorders){
                if(singleInvoiceJob.invoiceit_s__Status__c == 'Active' || singleInvoiceJob.invoiceit_s__Status__c == 'Evergreen' || (singleInvoiceJob.invoiceit_s__Status__c == 'Cancelled' && singleInvoiceJob.invoiceit_s__Service_End_Date__c > System.Today())){
                    queriedorders.add(singleInvoiceJob);
                }/*else{
                    cancelledOrExpiredOrders.add(singleInvoiceJob);
                }*/
                    
            }
            cancelledOrExpiredOrders = [select id,Name,invoiceit_crmx__Opportunity__r.one_time_charge_available__c,
                                invoiceit_s__Status__c,invoiceit_s__Account__c,createdDate,invoiceit_s__Start_Date__c,
                                invoiceit_s__Service_Activation_Date__c,invoiceit_s__Service_End_Date__c 
                                from invoiceit_s__Job__c
                                where /*(invoiceit_s__Status__c = 'Active'
                                        OR invoiceit_s__Status__c = 'Evergreen'
                                        OR (invoiceit_s__Status__c = 'Cancelled' AND invoiceit_s__Service_End_Date__c > TODAY ) )
                                     
                                    and*/ invoiceit_s__Account__c IN:accountids
                                    ORDER BY LastModifiedDate DESC];
            
            system.debug('@@@queriedorders' + queriedorders);
            system.debug('===========cancelledOrExpiredOrders=========='+cancelledOrExpiredOrders);
            
                idVsaccount = new map<id,account>([select id, Name, Order_Status__c,
                                                        Acquisition_date__c, Customer_Status__c,
                                                        Loss_Date__c, Re_acquisition_date__c,LossDate_Check__c,
                                                        Win_back__c, Organization_Type__c,
                                                        MH_Cust_Number__c
                                                        from account 
                                                   where id IN:(accountids)]);
            system.debug('@@@@idVsaccount' + idVsaccount);
        }
       
       
        
        // forming accountId Vs orders map
        if(queriedorders !=null && !queriedorders.isEmpty()){
            for(invoiceit_s__Job__c singleInvoiceJob : queriedorders){
                
                if(accidVsorders.containsKey(singleInvoiceJob.invoiceit_s__Account__c)){
                    accidVsorders.get(singleInvoiceJob.invoiceit_s__Account__c).add(singleInvoiceJob);
                }
                else{
                    accidVsorders.put(singleInvoiceJob.invoiceit_s__Account__c, new List<invoiceit_s__Job__c>{singleInvoiceJob});
                }
                
            }
        }
        System.debug('======================accidVsorders==============='+accidVsorders);
        List<account> listtoUpdate = new list<account>();
        if(idVsaccount!= null){
            for(account acc : idVsaccount.values()){
                 if(acc.Organization_Type__c !=  null){
                //if(acc.Organization_Type__c == 'Law Firm' || acc.Organization_Type__c == 'Corporation'){
                    system.debug('@@@@in lawfirm');
                    if(accidVsorders != null && !accidVsorders.isEmpty()){
                        system.debug('@@@in accidVsorders after lawfirm');
                        if(accidVsorders.containsKey(acc.id)){
                            system.debug('@@@in containskey'+accidVsorders.get(acc.id)[0].invoiceit_s__Status__c);
                            
                            if(accidVsorders.get(acc.id)[0].invoiceit_s__Status__c == 'Cancelled'){
                               // acc.Order_Status__c = 'Active';
                             }
                            else{
                                
                                if(acc.Order_Status__c  == 'Evergreen' && accidVsorders.get(acc.id)[0].invoiceit_crmx__Opportunity__r.one_time_charge_available__c > 0){
                                    
                                }
                                else{
                                    acc.Order_Status__c = accidVsorders.get(acc.id)[0].invoiceit_s__Status__c;
                                }
                                
                                system.debug('@@@@@@acc.Order_Status__c '+acc.Order_Status__c );
                            }
                            
                          /*  if(!currentAccIdVsOrders.isEmpty() && currentAccIdVsOrders.containsKey(acc.id)){
                                integer size = currentAccIdVsOrders.get(acc.id).size();
                                //size -1 to get the most recent order
                                if(currentAccIdVsOrders.get(acc.id)[size -1].invoiceit_s__Status__c == 'Cancelled'){
                                    acc.Order_Status__c = 'Active'; 
                                }
                                else{
                                    acc.Order_Status__c = currentAccIdVsOrders.get(acc.id)[size -1].invoiceit_s__Status__c;
                                }
                                
                                
                            }*/
                           // acc.Order_Status__c = 'Active'; 
                            
                           
                            //if(insertOrUpdate){
                            system.debug('@@@@accidVsorders.get(acc.id).size()'+accidVsorders.get(acc.id).size());
                            system.debug('@@@@acc.Acquisition_date__c'+acc.Acquisition_date__c);
                            system.debug('@@@@accidVsorders.get(acc.id)[0].invoiceit_s__Service_Activation_Date__c '+accidVsorders.get(acc.id)[0].invoiceit_s__Service_Activation_Date__c );
                            if(accidVsorders.get(acc.id).size() == 1){
                                Date activationdate;
                                Integer currentYear = System.Today().year();
                                if(accidVsorders.get(acc.id)[0].invoiceit_s__Service_Activation_Date__c == null){
                                    if (accidVsorders.get(acc.id)[0].CreatedDate.month() == 12){    
                                        activationdate = Date.newInstance(accidVsorders.get(acc.id)[0].CreatedDate.year()+1, 1, 1);
                                     } else {
                                      activationdate = Date.newInstance(accidVsorders.get(acc.id)[0].CreatedDate.year(), accidVsorders.get(acc.id)[0].CreatedDate.month()+1, 1);
                                   }
                                }
                                else{
                                    activationdate  = accidVsorders.get(acc.id)[0].invoiceit_s__Service_Activation_Date__c;
                                }
                                if(acc.Acquisition_date__c == null && activationdate != null){
                                    system.debug('@@@@ Activation Date'+activationdate);
                                   // date d = accidVsorders.get(acc.id)[0].invoiceit_s__Service_Activation_Date__c;
                                   // date d = activationdate;
                                      date d = accidVsorders.get(acc.id)[0].invoiceit_s__Start_Date__c;
                                    //date newdate = d.addMonths(1);
                                    //date newdatenow = date.newInstance(newdate.year(), newdate.month(), 01);
                                      acc.Acquisition_date__c = d;
                                    system.debug('@@@@ Acquisition date '+acc.Acquisition_date__c);
                                      acc.Customer_Status__c = 'New';
                                   
                                    
                                    //if it is a already existing customer starts with 5.then first time 
                                 /*   if(acc.MH_Cust_Number__c.startsWith('5')){
                                        acc.Customer_Status__c = 'EXISTING';
                                    }
                                    else{
                                        acc.Customer_Status__c = 'NEW';
                                    }
                                    
                                    */
                                }
                                
                                else {
                                
                                if (acc.Acquisition_date__c != null && acc.Re_acquisition_date__c == null && acc.Acquisition_date__c.year() < currentYear ){
                                         acc.Customer_Status__c = 'Existing';   
                                         }
                                else if(acc.Acquisition_date__c != null && acc.Re_acquisition_date__c == null && acc.Acquisition_date__c.year() >= currentYear ) {
                                        acc.Customer_Status__c = 'New'; 
                                    }         
                                }
                               
                            }
                        //}
                    }
                    else if(acc.LossDate_Check__c == True){
                        //acc.Order_Status__c = 'InActive';
                        acc.Order_Status__c = accidVsorders.get(acc.id)[0].invoiceit_s__Status__c;
                        //added to set lost date for existing accounts
                        Integer numberOfDays = Date.daysInMonth(date.today().year(), date.today().month()-1);
                       Date lastDayOfMonth = Date.newInstance(date.today().year(), date.today().month()-1, numberOfDays);
                       
                        acc.Loss_Date__c = lastDayOfMonth;
                    }
                    
                    
                    listtoUpdate.add(acc);
                }
                else{
                    //acc.Order_Status__c = 'InActive';
                    System.debug('===========inside last else condition'+cancelledOrExpiredOrders);
                    if(!cancelledOrExpiredOrders.isEmpty()){
                        invoiceit_s__Job__c ord = cancelledOrExpiredOrders[0];
                            acc.Order_Status__c = ord.invoiceit_s__Status__c;

                    }
                    listtoUpdate.add(acc);
                }
            }
            
        }
        
      }
        
        
        try{
            if(listtoUpdate.size() > 0){
                update listtoUpdate;
                OrderStatusHandling.RecursionOrderStatusHandling = false;
            }
            
            
        }
        catch(exception e){
            system.debug('@@@@exception'+ e);
        }
        
        
        
        
        
    }

}