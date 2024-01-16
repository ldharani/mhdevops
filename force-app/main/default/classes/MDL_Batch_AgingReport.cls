/*
Purpose : to construct the aging report data and update the Aging_Report_Data__c field on Account

Developed by Lister technologies
*/

global class MDL_Batch_AgingReport implements Database.Batchable<sObject>,Database.Stateful , Database.AllowsCallouts{
        public String monthSelected;
        public String yearSelected;
        public Blob   csvFile;      
        public MDL_Batch_AgingReport(String month, String year){
            monthSelected = month;
            yearSelected = year;
        }
        
        global Database.QueryLocator start(Database.BatchableContext BC) {
            //select Id,Name,MH_Cust_Number__c from Account where Total_Account_Balance__c!=0.0 order by name
            //Account Query
            String query = 'Select Id,Name,MH_Cust_Number__c, Aging_Report_Data__c, ' +
                           
                           //Invoice Records
                           '(Select Name,  invoiceit_s__Invoice_Date__c ,invoiceit_s__Payment_Status__c,' +  
                           'invoiceit_s__Unpaid_Amount__c,  invoiceit_s__Due_Date__c, invoiceit_s__Account__c, '  + 
                           'invoiceit_s__Total_Invoice_Value__c ' +
                           'From invoiceit_s__Invoices__r ' +                                                
                           'where RecordType.DeveloperName = \'MH_Invoices\' ' +                            
                           'and invoiceit_s__Invoice_Status__c=\'Posted\' and invoiceit_s__Due_Date__c !=null ' + 
                           'and invoiceit_s__Unpaid_Amount__c!=0.0 order by invoiceit_s__Due_Date__c desc), ' +  
                           
                           //Payments Records
                           '(Select Id,Name, invoiceit_s__Payment_Date__c , invoiceit_s__Account__c, invoiceit_s__Unallocated_Amount__c, '+
                           'RecordType.DeveloperName ,invoiceit_s__Payment_Type__c, Applied_Type__c,invoiceit_s__Amount__c '+ 
                           'from invoiceit_s__Payments__r ' + 
                           'where invoiceit_s__Status__c=\'Completed\' and invoiceit_s__Payment_Date__c !=null ' + 
                           'and invoiceit_s__Unallocated_Amount__c!=0.0 and recordtype.developername = \'MH_Payments\' order by invoiceit_s__Payment_Date__c desc) ' + 
                            
                           'from Account where Total_Account_Balance__c!=0.0 and recordtype.developerName = \'MH_Accounts\'';
              if(test.isRunningTest()){
                      query +=  ' and Name like \'%test%\'';
              } 
              query += ' order by name';   
              if(test.isRunningTest()){
                      query +=  ' LIMIT 5';
              }          
                        
            return Database.getQueryLocator(query);
        }
        
        global void execute(Database.BatchableContext BC, List<Account> scope) {
            Integer monthInt = Integer.valueOf(monthSelected);
            Integer yearInt = Integer.valueOf(yearSelected);
            Date endDate = date.newInstance(yearInt, monthInt, 31);
            
            if(monthInt==1 || monthInt ==3 || monthInt ==5 || monthInt == 7 || monthInt == 8 || monthInt == 10 || monthInt ==12)
                endDate = date.newInstance(yearInt, monthInt, 31);
            else if (monthInt ==2 && Math.mod(yearInt,4)==0)
                endDate = date.newInstance(yearInt, monthInt, 29);
            else if (monthInt ==2 && Math.mod(yearInt,4)!=0)
                endDate = date.newInstance(yearInt, monthInt, 28);
            else
                endDate = date.newInstance(yearInt, monthInt, 30);
            
            Date startdate = endDate.addDays(-90);
        
            Map<Id,List<innerWrapperInv>> Map_Account_Invoices = new Map<Id,List<innerWrapperInv>>();
            Map<Id,List<innerWrapperPay>> Map_Account_Payments = new Map<Id,List<innerWrapperPay>>();
            
            for(Account acc : scope){
                for(invoiceit_s__Invoice__c inv : acc.invoiceit_s__Invoices__r){
                    innerwrapperInv tempobjInv  = new innerwrapperInv(inv);                  
                    if(Map_Account_Invoices.containsKey(inv.invoiceit_s__Account__c)) {
                        Map_Account_Invoices.get(inv.invoiceit_s__Account__c).add(tempobjInv);
                    } 
                    else{
                        Map_Account_Invoices.put(inv.invoiceit_s__Account__c,new List<innerWrapperInv> {tempobjInv});
                    }                   
                }
                
                for(invoiceit_s__Payment__c pay : acc.invoiceit_s__Payments__r){
                    innerwrapperPay tempobjPay;
                    tempobjPay = new innerwrapperPay(pay);
                    if(Map_Account_Payments.containsKey(pay.invoiceit_s__Account__c)) {
                        Map_Account_Payments.get(pay.invoiceit_s__Account__c).add(tempobjPay);
                    } 
                    else{
                        Map_Account_Payments.put(pay.invoiceit_s__Account__c,new List<innerWrapperpay> {tempobjPay});
                    }            
                } 
                
            }
            
            for(String kt : Map_Account_Invoices.keySet()){
                    for(innerWrapperInv i : Map_Account_Invoices.get(kt)){
                        if(i.invobj.invoiceit_s__Due_Date__c != null &&  i.invobj.invoiceit_s__Unpaid_Amount__c != null){ 
                            i.Invdaysopen = i.invobj.invoiceit_s__Due_Date__c.daysBetween(endDate);
                            if(i.Invdaysopen<=0)i.Invdaysopen = 0;
                            if(i.invobj.invoiceit_s__Due_Date__c >= endDate){
                                i.rcurrent = i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if((i.Invdaysopen>0)&&(i.Invdaysopen<=30)){
                                i.r0to30 =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if((i.Invdaysopen>30)&&(i.Invdaysopen<=60)){
                                i.r30to60 =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if((i.Invdaysopen>60)&&(i.Invdaysopen<=90)){
                                i.r60to90 =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if((i.Invdaysopen>90)&&(i.Invdaysopen<=120)){
                                i.r90to120 =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if((i.Invdaysopen>120)&&(i.Invdaysopen<=150)){
                                i.r120to150 =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if((i.Invdaysopen>150)&&(i.Invdaysopen<=180)){
                                i.r150to180 =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if((i.Invdaysopen>180)&&(i.Invdaysopen<=270)){
                                i.r180to270 =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if((i.Invdaysopen>270)&&(i.Invdaysopen<=360)){
                                i.r270to360 =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }
                            else if(i.Invdaysopen>360){
                                i.r360g =i.invobj.invoiceit_s__Unpaid_Amount__c.toPlainString();
                            }               
                      }
                  }
            }   
            
            
            for(String ktp : Map_Account_Payments.keySet()){
                for(innerWrapperPay i : Map_Account_Payments.get(ktp)){
                 if(i.payobj.invoiceit_s__Payment_Date__c != null &&  i.payobj.invoiceit_s__Unallocated_Amount__c != null){ 
                    i.Paydaysopen = i.payobj.invoiceit_s__Payment_Date__c.daysBetween(endDate);
                    if(i.Paydaysopen<=0)i.Paydaysopen = 0;
                    if(i.payobj.invoiceit_s__Payment_Date__c >= endDate){
                        i.pcurrent = (-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if((i.Paydaysopen>0)&&(i.Paydaysopen<=30)){
                        i.p0to30 =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if((i.Paydaysopen>30)&&(i.Paydaysopen<=60)){
                        i.p30to60 =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if((i.Paydaysopen>60)&&(i.Paydaysopen<=90)){
                        i.p60to90 =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if((i.Paydaysopen>90)&&(i.Paydaysopen<=120)){
                        i.p90to120 =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if((i.Paydaysopen>120)&&(i.Paydaysopen<=150)){
                        i.p120to150 =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if((i.Paydaysopen>150)&&(i.Paydaysopen<=180)){
                        i.p150to180 =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if((i.Paydaysopen>180)&&(i.Paydaysopen<=270)){
                        i.p180to270 =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if((i.Paydaysopen>270)&&(i.Paydaysopen<=360)){
                        i.p270to360 =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }
                    else if(i.Paydaysopen>360){
                        i.p360g =(-i.payobj.invoiceit_s__Unallocated_Amount__c).toPlainString();
                    }      
                   }              
                }
            }   
            
            List<Account> list_accToUpdate = new List<Account>();
            for(Account a : scope){
                //String agingData = '\'' + a.Name + '\'; ' + a.MH_Cust_Number__c + ';;;;;';
                String agingData = '\'' + a.Name + '\'; ' + a.MH_Cust_Number__c + ';;;;;;';
                Decimal totalCurrent = 0;
                Decimal total0to30 = 0;
                Decimal total30to60 = 0;
                Decimal total60to90 = 0;
                Decimal total90to120 = 0;
                Decimal total120to150 = 0;
                Decimal total150to180 = 0;
                Decimal total180to270 = 0;
                Decimal total270to360 = 0;
                Decimal total360g = 0;
                Decimal OpenBal = 0;
                if(Map_Account_Invoices.containsKey(a.Id) ){
                    
                    for(innerwrapperInv invoices : Map_Account_Invoices.get(a.Id)){
                        if(invoices.rcurrent!='')totalcurrent += Decimal.valueOf(invoices.rcurrent);
                        if(invoices.r0to30!='')total0to30 += Decimal.valueOf(invoices.r0to30);
                        if(invoices.r30to60!='')total30to60 += Decimal.valueOf(invoices.r30to60);
                        if(invoices.r60to90!='')total60to90 += Decimal.valueOf(invoices.r60to90);
                        if(invoices.r90to120!='')total90to120 += Decimal.valueOf(invoices.r90to120);
                        if(invoices.r120to150!='')total120to150 += Decimal.valueOf(invoices.r120to150);
                        if(invoices.r150to180!='')total150to180 += Decimal.valueOf(invoices.r150to180);
                        if(invoices.r180to270!='')total180to270 += Decimal.valueOf(invoices.r180to270);
                        if(invoices.r270to360!='')total270to360 += Decimal.valueOf(invoices.r270to360);
                        if(invoices.r360g!='')total360g += Decimal.valueOf(invoices.r360g);              
                        
                        OpenBal += invoices.invobj.invoiceit_s__Unpaid_Amount__c;       
                    }
                 }
                 
                 if(Map_Account_Payments.containsKey(a.Id) ) {
                    for(innerwrapperPay payments : Map_Account_Payments.get(a.Id)){                     
                        if(payments.pcurrent!='')totalcurrent += Decimal.valueOf(payments.pcurrent);
                        if(payments.p0to30!='')total0to30 += Decimal.valueOf(payments.p0to30);
                        if(payments.p30to60!='')total30to60 += Decimal.valueOf(payments.p30to60);
                        if(payments.p60to90!='')total60to90 += Decimal.valueOf(payments.p60to90);
                        if(payments.p90to120!='')total90to120 += Decimal.valueOf(payments.p90to120);
                        if(payments.p120to150!='')total120to150 += Decimal.valueOf(payments.p120to150);
                        if(payments.p150to180!='')total150to180 += Decimal.valueOf(payments.p150to180);
                        if(payments.p180to270!='')total180to270 += Decimal.valueOf(payments.p180to270);
                        if(payments.p270to360!='')total270to360 += Decimal.valueOf(payments.p270to360);
                        if(payments.p360g!='')total360g += Decimal.valueOf(payments.p360g);
                        
                        OpenBal -= payments.payobj.invoiceit_s__Unallocated_Amount__c;
                    }
                  }
                    
                    agingData += OpenBal + ';';
                    agingData += totalcurrent + ';';
                    agingData += total0to30 + ';';
                    agingData += total30to60 + ';';
                    agingData += total60to90 + ';';
                    agingData += total90to120 + ';';
                    agingData += total120to150 + ';';
                    agingData += total150to180 + ';';
                    agingData += total180to270 + ';';
                    agingData += total270to360 + ';';
                    agingData += total360g + '\r\n';
                    
                    if(Map_Account_Invoices.containsKey(a.Id) ){
                    for(innerwrapperInv invoices : Map_Account_Invoices.get(a.Id)){
                        
                        agingData += ';;'; // two tabs
                        agingData += invoices.Invtype + ';';
                        agingData += invoices.invobj.Name + ';;';
                        agingData += invoices.invobj.invoiceit_s__Invoice_Date__c + ';';
                        agingData += invoices.invobj.invoiceit_s__Total_Invoice_Value__c +';';
                        agingData += invoices.invobj.invoiceit_s__Unpaid_Amount__c +';';
                        agingData += invoices.rcurrent +';';
                        agingData += invoices.r0to30 +';';
                        agingData += invoices.r30to60 +';';
                        agingData += invoices.r60to90 +';';
                        agingData += invoices.r90to120 +';';
                        agingData += invoices.r120to150 +';';
                        agingData += invoices.r150to180 +';';
                        agingData += invoices.r180to270 +';';
                        agingData += invoices.r270to360 +';';
                        agingData += invoices.r360g +';';
                        agingData += invoices.Invdaysopen; 
                        agingData += '\r\n';   
                     }
                     }   
                     
                     if(Map_Account_Payments.containsKey(a.Id) ) {
                        for(innerwrapperPay payments : Map_Account_Payments.get(a.Id)){
                            agingData += ';;'; // two tabs
                            agingData += payments.Paytype + ';';
                            agingData += payments.payobj.Name + ';';
                            if(payments.payobj.invoiceit_s__Payment_Type__c=='Adjustment')
                                agingData += payments.payobj.Applied_Type__c ;
                            agingData += ';';    
                            agingData += payments.payobj.invoiceit_s__Payment_Date__c +';';
                            agingData += payments.payobj.invoiceit_s__Amount__c +';';
                            Decimal unallocatedAmt = payments.payobj.invoiceit_s__Unallocated_Amount__c * -1;
                            agingData += unallocatedAmt +';';
                            agingData += payments.pcurrent +';';
                            agingData += payments.p0to30 +';';
                            agingData += payments.p30to60 +';';
                            agingData += payments.p60to90 +';';
                            agingData += payments.p90to120 +';';
                            agingData += payments.p120to150 +';';
                            agingData += payments.p150to180 +';';
                            agingData += payments.p180to270 +';';
                            agingData += payments.p270to360 +';';
                            agingData += payments.p360g +';';
                            agingData += payments.Paydaysopen; 
                            agingData += '\r\n';   
                        
                        }
                    }                                   
                
                                                    
                
                
                a.Aging_Report_Data__c = agingData;
                list_accToUpdate.add(a);
                //csvFile = Blob.valueOf(csvFile.toString() + agingData);
            }
            
            
            if(list_accToUpdate.size() > 0)
                update list_accToUpdate;
        }
    
        global void finish(Database.BatchableContext BC) {
        	   Integration_Endpoints__c endPts = Integration_Endpoints__c.getValues('Aging Report');
               String endpoint = String.valueOf(endPts.Endpoint_URL__c);
               String methodType = String.valueOf(endPts.MethodType__c);
               HttpRequest req = new HttpRequest(); //initiate HTTP request
               req.setEndpoint(endPoint);   
               req.setMethod(methodType);         
               req.setTimeout(120000);
               //req.setHeader('Content-Length', '512');      
               if(!test.isRunningTest()){
                   HTTPResponse res = new Http().Send(req);
                   system.debug('res.getbody() ' + res.getbody());
               }
        } 
        
        public class innerwrapperInv{
        public String Invtype{get; set;}
        public String rcurrent{get; set;}
        public String r0to30{get; set;}
        public String r30to60{get; set;}
        public String r60to90{get; set;}
        public String r90to120{get; set;}
        public String r120to150{get; set;}
        public String r150to180{get; set;}
        public String r180to270{get; set;}
        public String r270to360{get; set;}
        public String r360g{get; set;}  
        public Integer Invdaysopen{get;set;}    
        public invoiceit_s__Invoice__c invobj{get; set;}
        public innerwrapperInv(invoiceit_s__Invoice__c obj){
            invobj=new invoiceit_s__Invoice__c();
            invobj=obj;
            Invtype = 'Invoice';
            rcurrent = '';
            r0to30 = '';
            r30to60 = '';
            r60to90 = '';
            r90to120 = '';
            r120to150 = '';
            r150to180 = '';
            r180to270 = '';
            r270to360 = '';
            r360g = '';
            Invdaysopen = 0;
            
        }
    }
    //wrapper class for payment
    public class innerwrapperPay{
        public String Paytype{get; set;}
        public String pcurrent{get; set;}
        public String p0to30{get; set;}
        public String p30to60{get; set;}
        public String p60to90{get; set;}
        public String p90to120{get; set;}
        public String p120to150{get; set;}
        public String p150to180{get; set;}
        public String p180to270{get; set;}
        public String p270to360{get; set;}
        public String p360g{get; set;}  
        public Integer Paydaysopen{get;set;}    
        public invoiceit_s__Payment__c payobj{get; set;}
        public innerwrapperPay(invoiceit_s__Payment__c pobj){
            payobj=new invoiceit_s__Payment__c();
            payobj=pobj;
            Paytype = 'Payment';
            pcurrent = '';
            p0to30 = '';
            p30to60 = '';
            p60to90 = '';
            p90to120 = '';
            p120to150 = '';
            p150to180 = '';
            p180to270 = '';
            p270to360 = '';
            p360g = '';
            Paydaysopen = 0;
        }
        
    }
}