//Added by SaiV NCONS-82 - 12/15/2016

public class AccountContactRelationHandler{
    public static Boolean recFlag = true;
    
    public static void addaccountContactRelatioship(List<AccountContactRelation> newAcrList){
    
        Set<Id> accountIdSet = new Set<Id>();
        List<AccountContactRelation> accContactRelationList = new List<AccountContactRelation>();
        Map<id,List<Account>> parentAccIdNAccList = new Map<id,List<Account>>();
        List<Contact> contactList = new List<Contact>();
        
        
        for(AccountContactRelation acr : newAcrList){
            accountIdSet.add(acr.accountId);
        }
        List<Account> accList = [select id, parentid  from Account where parentid In: accountIdSet];
        
        if(accList != null && !accList.isEmpty()){
            for(Account acc : accList){
                if(!parentAccIdNAccList.containsKey(acc.parentid)){
                    parentAccIdNAccList.put(acc.parentid, new List<account>{acc});
                }else{
                    parentAccIdNAccList.get(acc.parentid).add(acc);
                }
            }
        }
             
        for(AccountContactRelation acr :newAcrList){
           if(parentAccIdNAccList.containsKey(acr.accountId) && parentAccIdNAccList.get(acr.accountId) != null){
               for(Account a : parentAccIdNAccList.get(acr.accountId)){
                   AccountContactRelation acrobj = new AccountContactRelation();
                   acrobj.AccountId = a.id;
                   acrobj.ContactId = acr.contactid;
                   accContactRelationList.add(acrobj);
               } 
          }
        }
        try{
        system.debug('----accContactRelationList----'+accContactRelationList);
            if(!accContactRelationList.isEmpty()){
                DataBase.insert(accContactRelationList,false);
            
            }
        
        }catch(exception e){
        
        }
    
    }

}