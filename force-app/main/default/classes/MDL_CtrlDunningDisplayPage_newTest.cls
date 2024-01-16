public class MDL_CtrlDunningDisplayPage_newTest {
    /*
    public Boolean isDataInsert {get;set;}
    public List<Dunning_Account_ids__c> list_toInsert {get;set;}
    public Integer Accounts_per_dunningPdf;
    public Map<Decimal,List<Dunning_Account_ids__c>> mapIndexNLstDunningAccIds;
    public Decimal indexVal{get;set;}
    //public List<Document> list_DocumentToInsert;
    //public boolean callAgain{get;set;}
    //public Map<String, List<Blob>> map_range_pdfs;
    //public List<String> list_key;
    public Integer i ; 
    public Integer noOfPdfs;  
    public Integer startSeqNo;   
    //public Integer mapsize{get;set;}
    //public boolean callAgain{get;set;}
    //public Blob pdf ;
    
    public MDL_CtrlDunningDisplayPage_newTest() {
        isDataInsert = false;
        Accounts_per_Dunning_pdf__c nos = Accounts_per_Dunning_pdf__c.getValues('Test');
        Accounts_per_dunningPdf = Integer.valueOf(nos.PdfCount__c);
        //Accounts_per_dunningPdf = 1000;
        mapIndexNLstDunningAccIds = new Map<Decimal,List<Dunning_Account_ids__c>>();
        indexVal = 0;     
        noOfPdfs = 1; 
        startSeqNo = 1;  
        i = 1;
        //generateDunningLetters();
    }
    public PageReference generateDunningLetters() {
        List<Account> acc_list = new List<Account>();
        Map<String, List<String>> map_DunningRange_AccId = new Map<String, List<String>>();
        
        acc_list = [Select Id ,Name ,MH_Cust_Number__c, Collector__c , AccountNumber ,
                           BillingCity , BillingState , BillingCountry , BillingPostalCode ,Credit_Status__c,    
                           Collector__r.Name ,Collector__r.Phone ,Collector__r.Extension ,     
                           Collector__r.Email , BillingStreet , Hold_dunning_letter_till__c,
                           Days_Old__c                                                                                                                       
                           from Account   
                           where Days_Old__c >= 1 
                           and
                           Credit_Status__c != 'Bad Debt'
                           //and RecordType.DeveloperName = 'MH_Accounts'
                           //and (Hold_dunning_letter_till__c >: system.today() or
                           //Hold_dunning_letter_till__c = null)
                           //Commented for new Changes 
                           and Dunning_Hold__c = false
                           //and Total_Account_Balance__c > 10.00
                           and MH_Total_Account_Balance__c >=10.00
                           order by Name asc];
                           
       for(Account a : acc_List){
            if(a.Days_Old__c >= 1 && a.Days_Old__c <= 30){
                if(map_DunningRange_AccId.containsKey('01-30')){ map_DunningRange_AccId.get('01-30').add(a.id);   }
                else{  map_DunningRange_AccId.put('01-30', new List<String>  {a.id});  }   
            }
            
            if(a.Days_Old__c >= 31 && a.Days_Old__c <= 60){
                if(map_DunningRange_AccId.containsKey('31-60')){ map_DunningRange_AccId.get('31-60').add(a.id);  }
                else{ map_DunningRange_AccId.put('31-60', new List<String>  {a.id}); }   
            }
            
            if(a.Days_Old__c > 60){
                if(map_DunningRange_AccId.containsKey('>60')){
                    map_DunningRange_AccId.get('>60').add(a.id);               
                }
                else{          
                    map_DunningRange_AccId.put('>60', new List<String>  {a.id});
                }       
            }
        } 
        List<Dunning_Account_ids__c> list_toDelete = new List<Dunning_Account_ids__c>();
        List<Dunning_Account_ids__c> listDunningAccs = new List<Dunning_Account_ids__c>();
        for(Dunning_Account_ids__c toDelete : [Select Id,CreatedDate from Dunning_Account_ids__c]){
            listDunningAccs.add(toDelete);
            if(toDelete.CreatedDate.Date()!=system.today()){
                list_toDelete.add(toDelete);
            }
        }
        
        if(listDunningAccs.size()==0 || list_toDelete.size() > 0){
            if(list_toDelete.size() > 0){          
                delete list_toDelete;
            }                
            list_toInsert = new List<Dunning_Account_ids__c>();
            
            List<String> list_dunningKey = new List<String>();
            list_dunningKey.add('01-30');
            list_dunningKey.add('31-60');
            //list_dunningKey.add('60-120');
            list_dunningKey.add('>60');
            
            for(String key : list_dunningKey){              
                List<String> accids = new List<String>();
                List<String> tempList = new List<String>();
                
                if(map_DunningRange_AccId.containsKey(key)){
                    accids = map_DunningRange_AccId.get(key);
                }
                
                system.debug('@@@@Accounts_per_dunningPdf'+ Accounts_per_dunningPdf);
                system.debug('@@@@@accids size'+ accids.size());
                for(String a_id : accids){
                    tempList.add(a_id);                                 
                    if(tempList.size() >= Accounts_per_dunningPdf){
                         Dunning_Account_ids__c d = new Dunning_Account_ids__c();
                         d.Name = key + ';' + templist.size() + '';
                         d.Account_Ids__c = '';
                         for(String t : tempList){
                            d.Account_Ids__c += t + ',';
                         }
                         d.Starting_Sequence_Number__c = startSeqNo;
                         d.Ending_Sequence_Number__c = startSeqNo + tempList.size()-1;
                         list_toInsert.add(d);
                         noOfPdfs += tempList.size();
                         tempList = new List<String>();                      
                    }  
                    startSeqNo = noOfPdfs;     
                }
                
                if(tempList.size() > 0){
                    Dunning_Account_ids__c d = new Dunning_Account_ids__c();
                    d.Name = key + ';' + templist.size() + '';
                    d.Account_Ids__c = '';              
                    for(String t : tempList){
                        d.Account_Ids__c += t + ',';
                    }
                    d.Starting_Sequence_Number__c = startSeqNo;
                    d.Ending_Sequence_Number__c = startSeqNo + tempList.size()-1;
                    list_toInsert.add(d);
                    noOfPdfs += tempList.size();
                }
            }
            
            if(list_toInsert.size() > 0)
                insert list_toInsert;   
            
            
            if(list_toInsert.size() < Accounts_per_dunningPdf) {
                mapIndexNLstDunningAccIds.put(1,list_toInsert);
            }
            else{
                Decimal i = 0;
                for(Dunning_Account_ids__c dIds : list_toInsert) {
                    i++;
                    if(mapIndexNLstDunningAccIds.containsKey(Math.ceil(i/Accounts_per_dunningPdf))) {
                        mapIndexNLstDunningAccIds.get(Math.ceil(i/Accounts_per_dunningPdf)).add(dIds);
                    }
                    else {
                        mapIndexNLstDunningAccIds.put(Math.ceil(i/Accounts_per_dunningPdf),new List<Dunning_Account_ids__c>{dIds});
                    }
                }
            }
            System.debug('mapIndexNLstDunningAccIds'+mapIndexNLstDunningAccIds);
            isDataInsert = true;      
            //System.debug('mapSize'+mapSize);   
        } 
        return new PageReference('/apex/DunningEmailPage_Test');                          
    }
    public PageReference viewDunningLetters(){
        return new PageReference('/apex/DunningViewHistoryPage'); 
    }*/
}