/*
Controller for MDL_ReportAgingExcel page
Purpose - extract report of invoices and payments grouped by their account to an excel sheet
Associated with - MDL_ReportAging page
*/
public  with sharing class MDL_ReportAgingExcelCtrl {
    public  MDL_ReportAgingExcelCtrl(){
 }
/*
    public transient String monthSelected{get; set;}
    public transient String yearSelected{get; set;}    
    public transient List<Account> accounts_list_final {get;set;}
    public transient Map<Id,List<innerWrapperInv>> Map_Account_Invoices {get;set;}
    public transient Map<Id,List<innerWrapperPay>> Map_Account_Payments {get;set;}    
    public transient Map<Id,Boolean> map_Invdisp {get;set;}
    public transient Map<Id,Boolean> map_Paydisp {get;set;}    
    public transient Map<Id,List<Decimal>> totalmap  {get;set;}    
    public transient String RowsPerPage {get;set;} 
    public transient String monthName {get;set;}
    public transient String todayName {get;set;}
    
    public  MDL_ReportAgingExcelCtrl(){
        monthSelected = Apexpages.currentpage().getParameters().get('Month');
        yearSelected = Apexpages.currentpage().getParameters().get('Year');
        
        
        Decimal sumcurrent;         
        Decimal sum0to30;
        Decimal sum30to60;
        Decimal sum60to90;
        Decimal sum90to120;
        Decimal sum120to150;
        Decimal sum150to180;
        Decimal sum180to270;
        Decimal sum270to360;
        Decimal sum360g;
        Decimal openBal;
        
        Integer InvSize = 0;
        Integer PaySize = 0;
        Integer TotalSize = 0;
        Long Noofpages;
        Integer size = 0;      
       
        
        List<Decimal> sumInvlist;
        Map<Id,List<Decimal>> mapaccsumInv = new Map<Id,List<Decimal>>();
        List<Decimal> sumPaylist;
        Map<Id,List<Decimal>> mapaccsumPay = new Map<Id,List<Decimal>>();
        accounts_list_final = new List<Account>();
        
        monthName = getname(Integer.valueOf(monthSelected));
        todayName = getname(Date.Today().month())+'_'+Date.Today().day()+'_'+Date.Today().year();
        
        Integer monthInt = Integer.valueOf(monthSelected);
        Integer yearInt = Integer.valueOf(yearSelected);
        Date endDate = date.newInstance(yearInt, monthInt, 31);
        //calculate the endDate based on the month and year selected
        if(monthInt==1 || monthInt ==3 || monthInt ==5 || monthInt == 7 || monthInt == 8 || monthInt == 10 || monthInt ==12)
            endDate = date.newInstance(yearInt, monthInt, 31);
        else if (monthInt ==2 && Math.mod(yearInt,4)==0)
            endDate = date.newInstance(yearInt, monthInt, 29);
        else if (monthInt ==2 && Math.mod(yearInt,4)!=0)
            endDate = date.newInstance(yearInt, monthInt, 28);
        else
            endDate = date.newInstance(yearInt, monthInt, 30);
        Date startdate = endDate.addDays(-90);
            
        List<invoiceit_s__Invoice__c> list_invoices = new List<invoiceit_s__Invoice__c>();
        List<invoiceit_s__Payment__c> list_payments = new List<invoiceit_s__Payment__c>();
        
        map_Invdisp = new Map<Id,Boolean>();
        map_Paydisp = new Map<Id,Boolean>();
        
        List<Account> DispAcc = new List<Account>();
        
        //Map<Id,List<innerwrapperInv>> map_inv = new Map<Id,List<innerwrapperInv>>();
        //Map<Id,List<innerwrapperPay>> map_pay = new Map<Id,List<innerwrapperPay>>();
        
        Map_Account_Invoices = new Map<Id,List<innerWrapperInv>>();
        Map_Account_Payments = new Map<Id,List<innerWrapperPay>>();
        
        //List<innerwrapperInv> listInnerWrapperInv = new List<innerwrapperInv>();
        //List<innerwrapperPay> listInnerWrapperPay = new List<innerwrapperPay>();
        
               
        totalmap = new Map<Id,List<Decimal>>();
        
        List<Account> accounts_list_initial;
       
        //get the accounts,invoices and payments
        accounts_list_initial = [select Id,Name,MH_Cust_Number__c from Account where Total_Account_Balance__c!=0.0 order by name];
        
        list_invoices = [select Id,invoiceit_s__Account__c,
                                                invoiceit_s__Unpaid_Amount__c,
                                                Name,
                                                invoiceit_s__Invoice_Date__c,
                                                invoiceit_s__Due_Date__c,
                                                invoiceit_s__Total_Invoice_Value__c
                                                from invoiceit_s__Invoice__c 
                         where  invoiceit_s__Account__r.Total_Account_Balance__c!=0.0 and invoiceit_s__Invoice_Status__c='Posted' and invoiceit_s__Due_Date__c !=null and invoiceit_s__Unpaid_Amount__c!=0.0 order by invoiceit_s__Due_Date__c desc
                         limit 49999];
                         
                               
        list_payments = [select Id,invoiceit_s__Account__c,                                                
                                                Name,
                                                invoiceit_s__Unallocated_Amount__c,                                                
                                                invoiceit_s__Payment_Date__c,
                                                invoiceit_s__Amount__c,
                                                invoiceit_s__Payment_Type__c,
                                                Applied_Type__c
                                                from invoiceit_s__Payment__c
                         where  invoiceit_s__Account__r.Total_Account_Balance__c!=0.0 and invoiceit_s__Status__c='Completed' and invoiceit_s__Payment_Date__c !=null and invoiceit_s__Unallocated_Amount__c!=0.0 order by invoiceit_s__Payment_Date__c desc
                         limit 49999];           
                                         
        
         //create innerwrapperInv for each invoice and map innerwrapperInvs with their account                  
        for(invoiceit_s__Invoice__c inv : list_invoices){
            innerwrapperInv tempobjInv;
            tempobjInv = new innerwrapperInv(inv);  
            if(Map_Account_Invoices.containsKey(inv.invoiceit_s__Account__c)) {
                Map_Account_Invoices.get(inv.invoiceit_s__Account__c).add(tempobjInv);
            } 
            else{
                Map_Account_Invoices.put(inv.invoiceit_s__Account__c,new List<innerWrapperInv> {tempobjInv});
            }
            
        } 
        //create innerwrapperPay for each payment and map innerwrapperPays with their account    
        for(invoiceit_s__Payment__c pay : list_payments){
            innerwrapperPay tempobjPay;
            tempobjPay = new innerwrapperPay(pay);
            if(Map_Account_Payments.containsKey(pay.invoiceit_s__Account__c)) {
                Map_Account_Payments.get(pay.invoiceit_s__Account__c).add(tempobjPay);
            } 
            else{
                Map_Account_Payments.put(pay.invoiceit_s__Account__c,new List<innerWrapperpay> {tempobjPay});
            }            
        }                              
        
        
        
        //categorize invoices
        for(String kt : Map_Account_Invoices.keySet()){
            for(innerWrapperInv i : Map_Account_Invoices.get(kt)){
                if(i.invobj.invoiceit_s__Due_Date__c != null && i.invobj.invoiceit_s__Unpaid_Amount__c != null){
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
          //construct map with account id and innerwrapperPays      
        
        //categorize payments
        for(String ktp : Map_Account_Payments.keySet()){
            for(innerWrapperPay i : Map_Account_Payments.get(ktp)){
                if(i.payobj.invoiceit_s__Payment_Date__c != null && i.payobj.invoiceit_s__Unallocated_Amount__c != null){
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
        for(Account accnt : accounts_list_initial){
            if(Map_Account_Invoices.containsKey(accnt.Id)  || Map_Account_Payments.containsKey(accnt.Id)){
                accounts_list_final.add(accnt);
            }
        }
        //to build a map with the account Id and check if the account has invoices or not
        for(Account accnt : accounts_list_final){
            if(Map_Account_Invoices.containsKey(accnt.Id)){
                map_Invdisp.put(accnt.Id,true);
            }
            else{
                map_Invdisp.put(accnt.Id,false);
            }
        }
        //to build a map with the account Id and check if the account has payments or not
        for(Account accnt : accounts_list_final){
            if(Map_Account_Payments.containsKey(accnt.Id)){
                map_Paydisp.put(accnt.Id,true);
            }
            else{
                map_Paydisp.put(accnt.Id,false);
            }
        } 
            
        //find sum of each category for invoices
        for(String keyInv : Map_Account_Invoices.keySet()){
            sumInvlist = new List<Decimal>();
            sumcurrent = 0.0;
            sum0to30 = 0.0;
            sum30to60 = 0.0;
            sum60to90 = 0.0;
            sum90to120 = 0.0;
            sum120to150 = 0.0;
            sum150to180 = 0.0;
            sum180to270 = 0.0;
            sum270to360 = 0.0;
            sum360g = 0.0;
            openBal = 0.0;
            for(innerWrapperInv i : Map_Account_Invoices.get(keyInv)){
                if(i.rcurrent!='')sumcurrent += Decimal.valueOf(i.rcurrent);
                if(i.r0to30!='')sum0to30 += Decimal.valueOf(i.r0to30);
                if(i.r30to60!='')sum30to60 += Decimal.valueOf(i.r30to60);
                if(i.r60to90!='')sum60to90 += Decimal.valueOf(i.r60to90);
                if(i.r90to120!='')sum90to120 += Decimal.valueOf(i.r90to120);
                if(i.r120to150!='')sum120to150 += Decimal.valueOf(i.r120to150);
                if(i.r150to180!='')sum150to180 += Decimal.valueOf(i.r150to180);
                if(i.r180to270!='')sum180to270 += Decimal.valueOf(i.r180to270);
                if(i.r270to360!='')sum270to360 += Decimal.valueOf(i.r270to360);
                if(i.r360g!='')sum360g += Decimal.valueOf(i.r360g);
                openBal += i.invobj.invoiceit_s__Unpaid_Amount__c;
            }
            sumInvList.add(openBal);
            sumInvlist.add(sumcurrent);
            sumInvlist.add(sum0to30);
            sumInvlist.add(sum30to60);
            sumInvlist.add(sum60to90);
            sumInvlist.add(sum90to120);
            sumInvlist.add(sum120to150);
            sumInvlist.add(sum150to180);
            sumInvlist.add(sum180to270);
            sumInvlist.add(sum270to360);
            sumInvlist.add(sum360g);
            
            mapaccsumInv.put(keyInv,sumInvlist);            
        }
        //find sum of each category for payments
        for(String keyPay : Map_Account_Payments.keySet()){
            sumPaylist = new List<Decimal>();
            sumcurrent = 0.0;
            sum0to30 = 0.0;
            sum30to60 = 0.0;
            sum60to90 = 0.0;
            sum90to120 = 0.0;
            sum120to150 = 0.0;
            sum150to180 = 0.0;
            sum180to270 = 0.0;
            sum270to360 = 0.0;
            sum360g = 0.0;
            openBal = 0.0;
            for(innerWrapperPay i : Map_Account_Payments.get(keyPay)){
                if(i.pcurrent!='')sumcurrent += Decimal.valueOf(i.pcurrent);
                if(i.p0to30!='')sum0to30 += Decimal.valueOf(i.p0to30);
                if(i.p30to60!='')sum30to60 += Decimal.valueOf(i.p30to60);
                if(i.p60to90!='')sum60to90 += Decimal.valueOf(i.p60to90);
                if(i.p90to120!='')sum90to120 += Decimal.valueOf(i.p90to120);
                if(i.p120to150!='')sum120to150 += Decimal.valueOf(i.p120to150);
                if(i.p150to180!='')sum150to180 += Decimal.valueOf(i.p150to180);
                if(i.p180to270!='')sum180to270 += Decimal.valueOf(i.p180to270);
                if(i.p270to360!='')sum270to360 += Decimal.valueOf(i.p270to360);
                if(i.p360g!='')sum360g += Decimal.valueOf(i.p360g);
                openBal -= i.payobj.invoiceit_s__Unallocated_Amount__c;
            }
            sumPaylist.add(openBal);
            sumPaylist.add(sumcurrent);
            sumPaylist.add(sum0to30);
            sumPaylist.add(sum30to60);
            sumPaylist.add(sum60to90);
            sumPaylist.add(sum90to120);
            sumPaylist.add(sum120to150);
            sumPaylist.add(sum150to180);
            sumPaylist.add(sum180to270);
            sumPaylist.add(sum270to360);
            sumPaylist.add(sum360g);
            
            mapaccsumPay.put(keyPay,sumPaylist);
        }
        //to display categorized values for each account
        for(String keyInv : Map_Account_Invoices.keySet()){
            List<Decimal> totallist = new List<Decimal>();
            if(Map_Account_Payments.containsKey(keyInv)){
                for(integer ii=0;ii<11;ii++){
                    totallist.add(((mapaccsumInv.get(keyInv)[ii])+(mapaccsumPay.get(keyInv)[ii])));
                }                   
                    totalmap.put(keyInv,totallist);
            }
            else{
                totalmap.put(keyInv,mapaccsumInv.get(keyInv));
            }               
        }
        for(String keyPay : Map_Account_Payments.keySet()){
            if(!totalmap.containskey(keyPay)){
                totalmap.put(keyPay,mapaccsumPay.get(keyPay));
            }
        }        
        
    }
    public  String getDynamicFormatString()
    {
        Decimal value = 1000.10;
        String formattedValue = value.format();
        String thousandSep = formattedValue.substring(1,2);
        String decimalSep = formattedValue.substring(5,6);
        return '{0,number,#'+thousandSep+'###'+thousandSep+'###'+thousandSep+'###'+thousandSep+'###'+thousandSep+'##0'+decimalSep+'00}';
    }
    public  String getname(Integer monthSelected){
        String monthName;
        if(monthSelected==1)monthName = 'January';
        else if(monthSelected==2)monthName = 'February';
        else if(monthSelected==3)monthName = 'March';
        else if(monthSelected==4)monthName = 'April';
        else if(monthSelected==5)monthName = 'May';
        else if(monthSelected==6)monthName = 'June';
        else if(monthSelected==7)monthName = 'July';
        else if(monthSelected==8)monthName = 'August';
        else if(monthSelected==9)monthName = 'September';
        else if(monthSelected==10)monthName = 'October';
        else if(monthSelected==11)monthName = 'November';
        else if(monthSelected==12)monthName = 'December';
        return monthName;       
    }
    
    //wrapper class for invoice 
    public  class innerwrapperInv{
        public transient String Invtype{get; set;}
        public transient String rcurrent{get; set;}
        public transient String r0to30{get; set;}
        public transient String r30to60{get; set;}
        public transient String r60to90{get; set;}
        public transient String r90to120{get; set;}
        public transient String r120to150{get; set;}
        public transient String r150to180{get; set;}
        public transient String r180to270{get; set;}
        public transient String r270to360{get; set;}
        public transient String r360g{get; set;} 
        public transient Integer Invdaysopen{get;set;}    
        public transient invoiceit_s__Invoice__c invobj{get; set;}
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
    public  class innerwrapperPay{
        public transient String Paytype{get; set;}
        public transient String pcurrent{get; set;}
        public transient String p0to30{get; set;}
        public transient String p30to60{get; set;}
        public transient String p60to90{get; set;}
        public transient String p90to120{get; set;}
        public transient String p120to150{get; set;}
        public transient String p150to180{get; set;}
        public transient String p180to270{get; set;}
        public transient String p270to360{get; set;}
        public transient String p360g{get; set;}  
        public transient Integer Paydaysopen{get;set;}
        public transient invoiceit_s__Payment__c payobj{get; set;}
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
        
    }*/
}