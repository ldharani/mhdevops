/**@@ 
#CLASS NAME           :    AccountOrderStatusLogic 
#TRIGGER NAME         :    ContractTrigger
#UTILITY CLASS NAME   :    Account_UtilityClass
#TEST CLASS           :    AccountCustomerOrderStatus_Test
#CREATED BY           :    Jeyamugundan
#Created Purpose      :    MHSCBM-254 Customer / Order Status on Account  
@@*
Change History
************************************************************************************************************************
Jira         ModifiedBy    Date         Requested By    Tag     Description
MHBS-6371    JM          08/03/2022     Richard Woyce   T-1     Staus update changes for Auto-Evergreen Process
MHBS-9435    Bharath     16/08/2023     John Mattheson  T02     MN Order Status/Customer status badge issues
*************************************************************************************************************************/
public class AccountOrderStatusLogic { 
    
    public static void handlerLogic(List<Contract> conRec){
        System.debug('@@@111');
        Set<Id> accId = new Set<Id>();
        Set<Id> accIdAA = new Set<Id>();
        for(Contract con: conRec){
            System.debug('@@@222 ' + con.AccountId);
            if(con.AccountId != NULL){
              //  system.debug('allll ' + con.Status__c  + '  = ' + con.IsRebased__c + ' = ' + ((contract)Trigger.Oldmap.get(con.Id)).Status__c);
                if(((con.Status__c != 'Rebased' && con.IsRebased__c == false) || (con.Status__c == 'Expired' && con.IsRebased__c == True))
                   && con.Status__c != Null && (Trigger.isInsert || (Trigger.isUpdate && con.Status__c != ((contract)Trigger.Oldmap.get(con.Id)).Status__c))){
                    System.debug('@@@333');
                    accId.add(con.AccountId);
                }  
                
                if(Trigger.isInsert|| Trigger.isUpdate){ //T02
                    System.debug('@@@444');
                    accIdAA.add(con.AccountId);
                }
            }
        }
        Map<Id,Account> conMapAA = new Map<Id,Account>();
        System.debug('@@@555 ' + accIdAA);
        if(accIdAA.Size() > 0 ) {
            System.debug('@@@666 ' + Account_UtilityClass.AccountOrderStatusLogic(accIdAA));
            for(Account accX : Account_UtilityClass.AccountOrderStatusLogic(accIdAA)){
                System.debug('@@@777');
                conMapAA.put(accX.Id,accX);
            }
            //conMapAA = new Map<Id,Account>([SELECT ID,Loss_Date__c,Re_acquisition_date__c,Acquisition_date__c,Customer_Status__c  FROM Account WHERE ID IN: accIdAA]);
        }
        
        
        Map<Id,List<Contract>> conMap = new Map<Id,List<Contract>>();
        System.debug('@@@888 ' + accId);        
        if(accId.size() > 0){
            System.debug('@@@999 ' + Account_UtilityClass.AccountOrderStatusLogicAA(accId));
            for(Contract conA: Account_UtilityClass.AccountOrderStatusLogicAA(accId)){
                System.debug('@@@101010 ' + conMap.containsKey(conA.AccountId) + ' ' + conMap.get(conA.AccountId)); 
                if(conMap.containsKey(conA.AccountId) && conMap.get(conA.AccountId) != null) {
                    System.debug('@@@111111 ' ); 
                    List<Contract> conList = conMap.get(conA.AccountId);
                    conList.add(conA);
                    conMap.put(conA.AccountId,conList); 
                }   
                else {
                    System.debug('@@@121212 ' ); 
                    conMap.put(conA.AccountId, new List<Contract> {conA});
                }
            }
        }
        Map<Id, Account> updateAcc = new Map<Id, Account>();
        Map<Id, Account> updateAccIns = new Map<Id, Account>();
        System.debug('@@@131313 ' + conRec); 
        for(Contract conB: conRec){
            System.debug('@@@131313dddd ' + conB); 
            Boolean active = False;
            Boolean amendInProgress = False;
            Boolean amended = False;
            Boolean renewInProgress = False;
            Boolean rebaseInProgress = False;
            Boolean evergreen = False;
            Boolean evergreenInProgress = False;
            Boolean cancelled = False;
            Boolean expired = False;
            if(!conMap.IsEmpty()){
                System.debug('1111111111111A ' + conMap);
                System.debug('2222222222222A ' + conB);
                System.debug('3333333333333A ' + conB.AccountId);
                for(Contract conC: conMap.get(conB.AccountId)){
                    System.debug('dadadadada ' + conC);
                    System.debug('dadadadadasaa ' + conC.Status__c);
                    System.debug('dadadadadasaa ' + conC.SBQQ__Evergreen__c);
                    System.debug('dadadadadasaa ' + conC.Cancelled__c);
                    if(conC.Status__c == 'Active' && conC.SBQQ__Evergreen__c == false){
                        active = True; 
                    }else if(conC.Status__c == 'Amend in progress'){
                        amendInProgress = True; 
                    }else if(conC.Status__c == 'Amended'){
                        amended = True; 
                    }else if(conC.Status__c == 'Renew in Progress'){ 
                        renewInProgress = True; 
                    }else if(conC.Status__c == 'Rebase in progress'){
                        rebaseInProgress = True; 
                    }else if(conC.Status__c == 'Evergreen' || (conC.SBQQ__Evergreen__c == true && conC.Cancelled__c == false && conC.Status__c != 'Rebased' && conC.Status__c != 'Cancelled' && conC.Status__c != 'Expired' && conC.Status__c != 'Cancel in progress' && conC.Status__c != 'Evergreened')){
                        system.debug('TESTHGHGHGHGH ' + conC);
                        evergreen = True; 
                    }else if(conC.Status__c == 'Evergreen in progress'){
                        evergreenInProgress = True; 
                    }else if(conC.Status__c == 'Cancelled'){
                        system.debug('TESTAAAFSFSFSF ' + conC);
                        cancelled = True; 
                    }else if(conC.Status__c == 'Expired'){
                        system.debug('dddsssasdssedrrvfss ' + conC);
                        expired = True; 
                    }
                }
            }
            System.debug('@@@active ' + active); 
            System.debug('@@@amendInProgress ' + amendInProgress);
            System.debug('@@@amended ' + amended);
            System.debug('@@@renewInProgress' + renewInProgress);
            System.debug('@@@rebaseInProgress ' + rebaseInProgress);
            System.debug('@@@evergreen ' + evergreen);
            System.debug('@@@evergreenInProgress ' + evergreenInProgress);
            System.debug('@@@cancelled ' + cancelled);
            System.debug('@@@expired ' + expired);
            System.debug('@@@Status__c ' + conB.Status__c); 
            
            Account accRecA = new Account(Id = conB.AccountId);
            if(Trigger.isUpdate && (conB.Status__c == 'Amend in progress' || conB.Status__c == 'Renew in Progress' || conB.Status__c == 'Rebase in progress' || conB.Status__c == 'Cancel in progress' || conB.Status__c == 'Mid-term in progress' || conB.Status__c == 'Evergreen in progress') && ((contract)Trigger.Oldmap.get(conB.Id)).Status__c == 'Evergreen'){
                System.debug('aaaaa aa ');
                accRecA.Order_Status__c = 'Evergreen'; 
                updateAcc.put(accRecA.Id,accRecA);
            }else if(evergreen == True){
                System.debug('bbbbb aa ');
                accRecA.Order_Status__c = 'Evergreen'; 
                updateAcc.put(accRecA.Id,accRecA);
            }else if(Trigger.isUpdate && (conB.Status__c == 'Amend in progress' || conB.Status__c == 'Renew in Progress' || conB.Status__c == 'Rebase in progress' || conB.Status__c == 'Cancel in progress' || conB.Status__c == 'Mid-term in progress' || conB.Status__c == 'Evergreen in progress') && ((contract)Trigger.Oldmap.get(conB.Id)).Status__c == 'Active'){
               System.debug('cccccc aa ');
                accRecA.Order_Status__c = 'Active'; 
                updateAcc.put(accRecA.Id,accRecA);
            }else if(active == True || amended == True){
                System.debug('dddddd aa ');
                accRecA.Order_Status__c = 'Active';
                updateAcc.put(accRecA.Id,accRecA);
            }else if(cancelled == True && (active == False && amendInProgress == False && amended == False && renewInProgress == False && rebaseInProgress == False && evergreen == False)){
                System.debug('eeeeee aa ');
                accRecA.Order_Status__c = 'Cancelled';
                updateAcc.put(accRecA.Id,accRecA);
            }else if(expired == True && (active == False && amendInProgress == False && amended == False && renewInProgress == False && rebaseInProgress == False && evergreen == False)){
                System.debug('fffffff aa ');
                accRecA.Order_Status__c = 'Expired'; 
                updateAcc.put(accRecA.Id,accRecA);
            } 
            
            //Loss Cancel Date Logic
            
            if((Trigger.isUpdate && conB.Status__c != ((contract)Trigger.Oldmap.get(conB.Id)).Status__c)){
                System.debug('afdsagfsgte ' + conB.Status__c + active + evergreen);
                if(conB.Status__c == 'Cancelled' && (active == False && evergreen == False)){
                        Date cancelDate = conB.CancelDate__c?.toStartOfMonth();
                        accRecA.Loss_Date__c = cancelDate?.addMonths(1).addDays(-1);
                        accRecA.Re_acquisition_date__c = Null; 
                        updateAcc.put(accRecA.Id,accRecA);
                }
                System.debug('afdsagfsgte ' + conB.Status__c + active + evergreen);
                if(conB.Status__c == 'Expired' && (active == False && evergreen == False)){
                        Date cancelDateA = conB.EndDate?.toStartOfMonth();
                        accRecA.Loss_Date__c = cancelDateA?.addMonths(1).addDays(-1);
                        accRecA.Re_acquisition_date__c = Null; 
                        updateAcc.put(accRecA.Id,accRecA);
                }
            }

            //if(Trigger.isInsert && conMapAA.containsKey(conB.AccountId)) {
            if(Trigger.isUpdate && conMapAA.containsKey(conB.AccountId)) { //T02
                Account acc = conMapAA.get(conB.AccountId);
                System.debug('afdssrgsdjtagfsgte ' + acc.Acquisition_date__c + acc.Loss_Date__c + acc.Customer_Status__c + acc.Order_Status__c);
                if(acc.Acquisition_date__c != Null && acc.Loss_Date__c != Null && acc.Customer_Status__c == 'Former Sub' && (conB.Status__c == 'Active' || conB.Status__c == 'Evergreen')){ //T02
                    System.debug('@@@@Test Nolo');
                    acc.Re_acquisition_date__c = System.today();
                    acc.LossDateCheck__c = acc.Loss_Date__c;
                    acc.Loss_Date__c = Null;
                    updateAccIns.put(acc.Id,acc);//T-1
                    //Update acc;
                }
            }
            
        }
        if(!updateAccIns.IsEmpty()){//T-1
            Update updateAccIns.values(); 
        }
        
        if(!updateAcc.IsEmpty()){//T-1
            Update updateAcc.values();//T02
        }
    }
}