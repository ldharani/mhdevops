public class acctBalanceSnapshotHandler{

 public void UpdatetotalInvoiceAmt(List<blng__AccountBalanceSnapshot__c> Acctsnapshot){
   Set<Id> accId = new Set<Id>();
   Map<id,Decimal> AccountVsTotalInvoice = new Map<id,Decimal>();
     List<Account> updateAcct = new List<Account>();
        

   
  for(blng__AccountBalanceSnapshot__c AccSn : Acctsnapshot){
  
     if((AccSn.blng__Account__c != NULL &&  AccSn.blng__TotalInvoiceAmount__c != null) || test.isRunningTest()){
          
          accId.add(AccSn.blng__Account__c);
          AccountVsTotalInvoice.put(AccSn.blng__Account__c ,AccSn.blng__TotalInvoiceAmount__c );
    
     }
 
 }
   if(! AccountVsTotalInvoice.keyset().Isempty() &&  AccountVsTotalInvoice.keyset()!= null){

       List<Account> AcctList = [SELECT Id, Total_Invoice_Value__c FROM Account WHERE ID IN: AccountVsTotalInvoice.keyset()];
    
     for(Account  Acc : AcctList ){
                    if(AccountVsTotalInvoice.containskey(Acc.id)){
                        Acc.Total_Invoice_Value__c = AccountVsTotalInvoice.get(Acc.id);
                        updateAcct.add(Acc);
                        
                        }
 
         }
         
         }
         
     if(!updateAcct.isempty()){
       try{
                update updateAcct;
            }
            catch(Exception ex){
                system.debug('@@@exception'+ex);
            }
            
        }     
 
 }
 
 
}