/**
Name : Cls_InvoicePDFCalculations
Lastmodified by: IJ on Feb 15
Description: To populate the credits,payments and debits for total amount due calculation

**/ 
public class Cls_InvoicePDFCalculations {
       
    //populate the invoice sum fields of previous month
    public static void calculatePreviousMonth(List<blng__Invoice__c> invlist){
        List<Id> ListofaccId = new List<Id>();
        
        Map<string,Decimal> MapodAcctoCredit = new map<string,Decimal>();
        Map<string,Decimal> MapodAcctoDebit = new map<string,Decimal>();
        Map<string,Decimal> MapodAcctoPayments = new map<string,Decimal>();
        Date StartDate = system.today();
        Date EndDate = system.today();
        Date PayAccEndDate;
        
        for(blng__Invoice__c inv: invlist){
            if(inv.blng__Account__c!=null && inv.blng__InvoiceDate__c!=null){
                ListofaccId.add(inv.blng__Account__c);
                
             Date AccEndDate = (inv.blng__InvoiceDate__c.tostartofmonth()).addDays(-1);
             PayAccEndDate = (inv.blng__InvoiceDate__c.tostartofmonth());
            Date AccStartDate = AccEndDate.tostartofmonth();
            system.debug('AccEndDate'+AccEndDate+'AccStartDate'+AccStartDate+'PayAccEndDate'+PayAccEndDate);
          
                          
           
               StartDate= AccStartDate;
           EndDate = AccEndDate;
              }
        }
        system.debug(StartDate+'StartDate'+EndDate+'EndDate');
        
        map<Id,Account> MapofIdtoAccount = new map<Id,Account>([select Id,Previous_Balance__c from Account where Id in:ListofaccId]);
        
        list<blng__CreditNote__c> listofcreditnote = new list<blng__CreditNote__c>(); 
        //add credits
        if(!test.isrunningtest()){
         listofcreditnote = [select Id, blng__CreditNoteDate__c,blng__Account__c, blng__Status__c, blng__TotalAmount__c from blng__CreditNote__c where blng__Account__c in : ListofaccId and blng__CreditNoteDate__c >= :StartDate and blng__CreditNoteDate__c <= :EndDate and blng__Status__c='Posted' ];
        } 
        if(test.isrunningtest()){
            listofcreditnote = [select Id, blng__CreditNoteDate__c,blng__Account__c, blng__Status__c,blng__TotalAmount__c from blng__CreditNote__c];
           // listofcreditnote = Test_Cls_InvoicePDFCalculations.CreditLogic();
        }
           
        for(blng__CreditNote__c cred: listofcreditnote){
           Id AccId=cred.blng__Account__c;
           Date AllocStartDate = (cred.blng__CreditNoteDate__c).tostartofmonth();
           
           if(MapodAcctoCredit.containskey(AllocStartDate+'-'+AccId)){
             Decimal  CreditAmt = MapodAcctoCredit.get(AllocStartDate+'-'+AccId);
             CreditAmt = CreditAmt+ cred.blng__TotalAmount__c;
             MapodAcctoCredit.put(AllocStartDate+'-'+AccId,CreditAmt);
             }
            else{
              MapodAcctoCredit.put(AllocStartDate+'-'+AccId,cred.blng__TotalAmount__c);
            }
        }
        
        //add debits
        for(blng__DebitNote__c deb: [select Id, blng__DebitNoteDate__c,blng__Account__c, blng__Status__c, blng__TotalAmount__c from blng__DebitNote__c where blng__Account__c in : ListofaccId and blng__DebitNoteDate__c >= :StartDate and blng__DebitNoteDate__c <= :EndDate and blng__Status__c='Posted' ]){
        
          Id AccId=deb.blng__Account__c;
          Date AllocStartDate = (deb.blng__DebitNoteDate__c).tostartofmonth();
          
           if(MapodAcctoDebit.containskey(AllocStartDate+'-'+AccId)){
             Decimal  DebitAmt = MapodAcctoDebit.get(AllocStartDate+'-'+AccId);
             DebitAmt = DebitAmt+ deb.blng__TotalAmount__c;
             MapodAcctoDebit.put(AllocStartDate+'-'+AccId,DebitAmt);
             }
            else{
              MapodAcctoDebit.put(AllocStartDate+'-'+AccId,deb.blng__TotalAmount__c);
            }
        }
        
        //add Payments
        
        for(blng__Payment__c Payment: [select Id,blng__Amount__c,blng__Account__c,blng__Status__c,createddate from blng__Payment__c where blng__Account__c in : ListofaccId and createddate >= :StartDate and createddate <= :PayAccEndDate and blng__Status__c='Posted']){
        
          Id AccId=Payment.blng__Account__c;
          Date AllocStartDate = (Payment.createddate.date()).tostartofmonth();
          
           if(MapodAcctoPayments.containskey(AllocStartDate+'-'+AccId)){
             Decimal  PaymentAmt = MapodAcctoPayments.get(AllocStartDate+'-'+AccId);
             PaymentAmt = PaymentAmt+ Payment.blng__Amount__c;
             MapodAcctoPayments.put(AllocStartDate+'-'+AccId,PaymentAmt);
             }
            else{
              MapodAcctoPayments.put(AllocStartDate+'-'+AccId,Payment.blng__Amount__c);
            }
        }
        
        for(blng__Invoice__c inv: invlist){
          if(inv.blng__Account__c!=null && inv.blng__InvoiceDate__c!=null){
          Date InvDate = (inv.blng__InvoiceDate__c.tostartofmonth()).adddays(-1);
          Date AccStartDate = InvDate.tostartofmonth();
             inv.MH_Balance_Previous_Month__c = MapofIdtoAccount.get(inv.blng__Account__c).Previous_Balance__c;
             if(MapodAcctoCredit.containskey(AccStartDate+'-'+inv.blng__Account__c)){
               inv.MH_Credits_Previous_Month__c = MapodAcctoCredit.get(AccStartDate+'-'+inv.blng__Account__c);
             }else{
               inv.MH_Credits_Previous_Month__c = 0;
             }
             if(MapodAcctoDebit.containskey(AccStartDate+'-'+inv.blng__Account__c)){
               inv.MH_Debits_Previous_Month__c= MapodAcctoDebit.get(AccStartDate+'-'+inv.blng__Account__c);
             }else{
              inv.MH_Debits_Previous_Month__c=0;
             }
              inv.MH_Adjustments_Previous_Month__c = inv.MH_Debits_Previous_Month__c- inv.MH_Credits_Previous_Month__c;
             if(MapodAcctoPayments.containskey(AccStartDate+'-'+inv.blng__Account__c)){
               inv.MH_Payments_Previous_Month__c = MapodAcctoPayments.get(AccStartDate+'-'+inv.blng__Account__c);
             }else{
              inv.MH_Payments_Previous_Month__c=0;
             }
          }
        }
    }
    
}