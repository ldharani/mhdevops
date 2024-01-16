/*
** Created By       : Lister Technologies
** Created Date     : 24th March,2015
** Created Purpose  : To display list of links from Dunning Letter object
*/
public class MDL_DunningEmailPageTest {
    public Set<Id> setDunningAccIds{get;set;}
    public Map<String,String> mapDunIdNAccIds;
    //public String letterType{get;set;}
    public String tdate{get;set;}
    public String docFolderId{get;set;}
    public integer countDocs{get;set;}
    public Map<Id,String> mapDunningNType{get;set;} 
    public Map<String,Integer> mapDunningNSeqNumber{get;set;}
    public List<Document> docList{get;set;}
    public List<Document> docListSorted{get;set;}
    public Map<String,String> mapDocIdAndDocName{get;set;} 
    public Map<String,Boolean> mapDunningIdNDocExist{get;set;}
    public String todayDate{get;set;}   
    public MDL_DunningEmailPageTest() {
        setDunningAccIds = new Set<Id>();
        mapDunIdNAccIds = new Map<String,String>();        
        tdate = String.valueof(Date.today());
        docList = new List<Document>();
        mapDocIdAndDocName = new Map<String,String>(); 
        for(Folder documtFolder : [Select Id from Folder where Name like '%Dunning%Documents%' limit 1]){
            docFolderId = documtFolder.Id;
        }
        //letterType = '';
        mapDunningNType = new Map<Id,String>();
        mapDunningIdNDocExist = new Map<String,Boolean>();
        mapDunningNSeqNumber = new Map<String,Integer>();
        for(Dunning_Account_ids__c dAccIds : [Select Id, Name , Account_Ids__c,Starting_Sequence_Number__c,Ending_Sequence_Number__c from Dunning_Account_ids__c]) {
            setDunningAccIds.add(dAccIds.Id);
            mapDunIdNAccIds.put(dAccIds.Id,dAccIds.Account_Ids__c);
            String numberPdf = '';
            if(dAccIds.Name.contains(';'))
                numberPdf = dAccIds.Name.split(';')[1];
            if(dAccIds.Name.contains('01-30')) {
                //letterType = 'Dunning Letter 1';
                mapDunningNType.put(dAccIds.Id,'MHF '+numberPdf+' for letter 1 ('+String.valueOf(dAccIds.Starting_Sequence_Number__c)+'-'+String.valueOf(dAccIds.Ending_Sequence_Number__c)+')');
                mapDunningNSeqNumber.put(dAccIds.Id,Integer.valueOf(dAccIds.Starting_Sequence_Number__c));                
            }
            /*else if(dAccIds.Name.contains('30-60')) {
                //letterType = 'Dunning Letter 2';
                mapDunningNType.put(dAccIds.Id,'MHS '+numberPdf+' for letter 2 ('+String.valueOf(dAccIds.Starting_Sequence_Number__c)+'-'+String.valueOf(dAccIds.Ending_Sequence_Number__c)+')');               
                mapDunningNSeqNumber.put(dAccIds.Id,Integer.valueOf(dAccIds.Starting_Sequence_Number__c)); 
            }*/
            else if(dAccIds.Name.contains('31-60')) {
                //letterType = 'Dunning Letter 3';
                mapDunningNType.put(dAccIds.Id,'MHT '+numberPdf+' for letter 2 ('+String.valueOf(dAccIds.Starting_Sequence_Number__c)+'-'+String.valueOf(dAccIds.Ending_Sequence_Number__c)+')');                
                mapDunningNSeqNumber.put(dAccIds.Id,Integer.valueOf(dAccIds.Starting_Sequence_Number__c)); 
            }
            else if(dAccIds.Name.contains('>60')) {
                //letterType = 'Dunning Letter 4';
                mapDunningNType.put(dAccIds.Id,'MHL '+numberPdf+' for letter 3 ('+String.valueOf(dAccIds.Starting_Sequence_Number__c)+'-'+String.valueOf(dAccIds.Ending_Sequence_Number__c)+')');                
                mapDunningNSeqNumber.put(dAccIds.Id,Integer.valueOf(dAccIds.Starting_Sequence_Number__c)); 
            }
        }
        countDocs = setDunningAccIds.size();
        //dunningAccIds = [Select Account_Ids__c, Used__c , Id, Name from Dunning_Account_ids__c];
        todayDate = '%'+String.valueOf(Date.Today())+'%';
        for(Document d : [Select Id,Name from Document where FolderId=:docFolderId and Name like :todayDate]){
            for(String s : setDunningAccIds){
                System.debug('1<<>>'+s);
                System.debug('2<<>>'+d.Name.subString(16,34));
                if(s.equals(d.Name.subString(16,34))){
                    mapDunningIdNDocExist.put(s,false);                 
                }                               
            }           
        }
        for(String s : setDunningAccIds){
            if(!mapDunningIdNDocExist.containsKey(s)){
                mapDunningIdNDocExist.put(s,true);
            }
        }
        System.debug('%%'+setDunningAccIds);
        System.debug('<><><>'+mapDunningIdNDocExist);
    }
    public Pagereference downloadDoc() {
        Integer i = 1;
        Blob pdf;
        Dunning_Account_ids__c startSeqNo;
        String dunId = Apexpages.currentPage().getParameters().get('dunId');  
        String dunningId = '%'+dunId+'%';      
        Document d = new Document();         
        i = mapDunningNSeqNumber.get(dunId);    
        PageReference Dunning_pdf = Page.MDL_VF_DunningLetter;
        Dunning_pdf.getParameters().put('DunningAccountId', dunId);  
        Dunning_pdf.getParameters().put('Seq',i+'');           
        if (!Test.IsRunningTest()) {
            pdf= Dunning_pdf.getContent();
        }
        else {
            pdf =Blob.valueOf('UNIT.TEST');
        }
        if(pdf!=null) {
            d.Name = 'Dunning_Letters_'+dunId+'_'+mapDunningNType.get(dunId)+'_'+String.valueOf(Date.today())+'.pdf';
            d.Body = pdf;
            d.FolderId = docFolderId;
            d.ContentType = 'application/pdf';
            d.IsPublic = true;
            insert d;
        }
        return null;
    }
    public PageReference viewDunningLetters(){
        docList = new List<Document>();
        docListSorted = new List<Document>();       
        mapDocIdAndDocName = new Map<String,String>();  
        Integer size = setDunningAccIds.size();
        for(Document doc : [Select Id,Name from Document where FolderId = :docFolderId and Name like :todayDate]){
            docList.add(doc);
        }
        if(docList.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'No records to display'));
            return null;
        }
        System.debug('<<>>'+docList);
        for(Document doc : docList){
            docListSorted.add(doc);
        }
        for(Integer i = 0; i<docListSorted.size()-1;i++){
            for(Integer j=i+1;j<docListSorted.size();j++){
                if(mapDunningNSeqNumber.get(docListSorted[i].Name.subString(16,34)) > mapDunningNSeqNumber.get(docListSorted[j].Name.subString(16,34))){
                    Document temp = docListSorted[i];
                    docListSorted[i] = docListSorted[j];
                    docListSorted[j] = temp;
                }
            }
        }
        System.debug('>>>><<<<'+docListSorted);
        for(Document documt : docListSorted){
            mapDocIdAndDocName.put(documt.Id,documt.Name.substring(35));
        }       
        return null;
    }
    public PageReference showDocs(){
        String docId = Apexpages.currentPage().getParameters().get('docId');  
        PageReference pf = new Pagereference('/servlet/servlet.FileDownload?file='+docId);    
        return pf;
    }
}