public class MDL_CtrlDunningDisplayPage {
    
    public Boolean isDataInsert {get;set;}
    public List<Dunning_Account_ids__c> list_toInsert {get;set;}
    public Integer Accounts_per_dunningPdf;
    
    
    public MDL_CtrlDunningDisplayPage(){
        isDataInsert = false;
        Accounts_per_dunningPdf = 100;
    }
    
    public void generateDunningLetters() {  
        List<Blob> list_pdfs = new List<Blob>();
        List<Document> list_DocumentToInsert = new List<Document>();
        List<Account> acc_list = new List<Account>();
        Map<String, List<String>> map_DunningRange_AccId = new Map<String, List<String>>();
        
        acc_list = [Select Id ,Name ,MH_Cust_Number__c, Collector__c , AccountNumber ,
                           BillingCity , BillingState , BillingCountry , BillingPostalCode ,    
                           Collector__r.Name ,Collector__r.Phone ,Collector__r.Extension ,     
                           Collector__r.Email , BillingStreet , Hold_dunning_letter_till__c,
                           Days_Old__c                                                                                                                       
                           from Account   
                           where Days_Old__c >= 1 
                           and RecordType.DeveloperName = 'MH_Accounts' 
                           and (Hold_dunning_letter_till__c >: system.today() or
                           Hold_dunning_letter_till__c = null)
                           and Dunning_Hold__c = false];
        
        
        system.debug('acc list ' + acc_List);      
        for(Account a : acc_List){
            if(a.Days_Old__c >= 1 && a.Days_Old__c < 30){
                if(map_DunningRange_AccId.containsKey('01-30')){ map_DunningRange_AccId.get('01-30').add(a.id);   }
                else{  map_DunningRange_AccId.put('01-30', new List<String>  {a.id});  }   
            }
            
            if(a.Days_Old__c >= 30 && a.Days_Old__c < 60){
                if(map_DunningRange_AccId.containsKey('30-60')){ map_DunningRange_AccId.get('30-60').add(a.id);  }
                else{ map_DunningRange_AccId.put('30-60', new List<String>  {a.id}); }   
            }
            
            if(a.Days_Old__c >= 60 && a.Days_Old__c < 120){
                if(map_DunningRange_AccId.containsKey('60-120')){
                    map_DunningRange_AccId.get('60-120').add(a.id);             
                }
                else{          
                    map_DunningRange_AccId.put('60-120', new List<String>  {a.id});
                }   
            }
            
            if(a.Days_Old__c >= 120){
                if(map_DunningRange_AccId.containsKey('>120')){
                    map_DunningRange_AccId.get('>120').add(a.id);               
                }
                else{          
                    map_DunningRange_AccId.put('>120', new List<String>  {a.id});
                }       
            }
        }
        system.debug('acc list ' + map_DunningRange_AccId);
        List<Dunning_Account_ids__c> list_toDelete = [Select Id from Dunning_Account_ids__c];
        
        if(list_toDelete.size() > 0)
            delete list_toDelete;
             
        Map<String,List<Dunning_Account_ids__c>> map_dunning_accounts = new Map<String,List<Dunning_Account_ids__c>>();
        
        list_toInsert = new List<Dunning_Account_ids__c>();
        
        List<String> list_dunningKey = new List<String>();
        list_dunningKey.add('01-30');
        list_dunningKey.add('30-60');
        list_dunningKey.add('60-120');
        list_dunningKey.add('>120');
        
        for(String key : list_dunningKey){
        	
            List<String> accids = new List<String>();
            List<String> tempList = new List<String>();
            
            if(map_DunningRange_AccId.containsKey(key)){
            	accids = map_DunningRange_AccId.get(key);
            }
            
            for(String a_id : accids){
                tempList.add(a_id);             
                if(tempList.size() >= Accounts_per_dunningPdf){
                     Dunning_Account_ids__c d = new Dunning_Account_ids__c();
                     d.Name = key + ';' + templist.size() + '';
                     d.Account_Ids__c = '';
                     for(String t : tempList){
                        d.Account_Ids__c += t + ',';
                     }
                     list_toInsert.add(d);
                     if(map_dunning_accounts.containskey(key)){
                        map_dunning_accounts.get(key).add(d);   
                     }
                     else{
                        map_dunning_accounts.put(key, new List<Dunning_Account_ids__c> {d});
                     }
                     tempList = new List<String>();
                }       
            }
            
            if(tempList.size() > 0){
                Dunning_Account_ids__c d = new Dunning_Account_ids__c();
                d.Name = key + ';' + templist.size() + '';
                d.Account_Ids__c = '';              
                for(String t : tempList){
                    d.Account_Ids__c += t + ',';
                }
                list_toInsert.add(d);
                if(map_dunning_accounts.containskey(key)){
                    map_dunning_accounts.get(key).add(d);   
                }
                else{
                    map_dunning_accounts.put(key, new List<Dunning_Account_ids__c> {d});
                }
            }
        }
        
        if(list_toInsert.size() > 0)
            insert list_toInsert;   
        
        isDataInsert = true;              
    }
    
    
    
    
    public void sendMail(){
        
        Map<String, List<Blob>> map_range_pdfs =  new Map<String, List<Blob>>();
        List<Document> list_DocumentToInsert = new List<Document>();
        List<String> list_key = new List<String>();
        Blob pdf ;
        Integer i = 1;
        for(Dunning_Account_ids__c d : list_toInsert){
        	
        	PageReference Dunning_pdf = Page.MDL_VF_DunningLetter;
            Dunning_pdf.getParameters().put('DunningAccountId', d.Id);  
            Dunning_pdf.getParameters().put('Seq', i+''); 
            if(d.Account_Ids__c.contains(',')){
        		for(String accId : d.Account_Ids__c.split(',')){
        			if(accId.startsWith('001')){
        				i++;
        			}
        		}
        	}
        	
            if (!Test.IsRunningTest())
            {
            pdf= Dunning_pdf.getContent();
            }
            else
            {
                  pdf =Blob.valueOf('UNIT.TEST');
            }
            
            
            if(map_range_pdfs.containskey(d.Name)){
                map_range_pdfs.get(d.Name).add(pdf);
            }   
            else{
            	list_key.add(d.Name);
                map_range_pdfs.put(d.Name, new List<Blob> {pdf});
            }
        }
        
        for(String key : list_key){ 
        	if(map_range_pdfs.containsKey(key)){                     
	            for(Blob b : map_range_pdfs.get(key)){
	                Document dunning_document = new Document();
	                dunning_document.Name = 'Dunning_Letters_' + key + '_' + system.today().format();
	                dunning_document.Body = b;
	                dunning_document.FolderId = '00lF0000001st04';
	                dunning_document.ContentType = 'application/pdf';
	                dunning_document.IsPublic = true;
	                dunning_document.Keywords = key;
	                list_DocumentToInsert.add(dunning_document);
	            }
        	}
        }
        
        if(list_DocumentToInsert.size() > 0)
            insert list_DocumentToInsert;
        
        
        List<String> toAddress = new List<String>();
        
        //toAddress.add('venkataraman.sriram@listertechnologies.com');
        //toAddress.add('venkatesan.mu@listertechnologies.com');
        //toAddress.add('randy.booth@martindale.com');
        //toAddress.add('dunning@martindale.com');
        
        String body = '';
        List<SiteBaseURL__c> SiteBaseURL = SiteBaseURL__c.getall().values(); 
        List<dunning_Mails__c> dunningMails = dunning_Mails__c.getall().values();       
        System.debug('result of custome setting ' + dunningmails);
        for(dunning_Mails__c mailId : dunningMails){
            toAddress.add(mailId.Mail_Id__c);
        } 
        
        Integer MHF = 1;
        Integer MHS = 1;
        Integer MHT = 1;
        Integer MHL = 1;
        
        for(Document d : list_DocumentToInsert){
            String totalLetter = ''; 
            if(d.Keywords.contains(';')){totalLetter = d.keywords.split(';')[1];}
            
            String Link_body;
            
            if(d.Keywords.contains('01-30')){Link_body = 'MHF '+ MHF + ' ' + totalLetter+ ' for letter 1'; MHF++;}
            else if(d.Keywords.contains('30-60')){Link_body = 'MHS '+ MHS + ' '  + totalLetter+ '  for letter 2'; MHS++;}
            else if(d.Keywords.contains('60-120')){Link_body = 'MHT  '+ MHT + ' '  + totalLetter+ ' for letter 3'; MHT++;}
            else{ Link_body = 'MHL  '+ MHL + ' '  + totalLetter+ '  for letter 4'; MHL++;}            
            
            body += '<a href="' +SiteBaseURL[0].Base_URL__c + 'MDL_ViewDunningLetters?Id=' + d.Id +'">'+ Link_body + '</a> <br/>';      
        }
        
        Messaging.SingleEmailMessage mail  = new Messaging.SingleEmailMessage();    
        mail.setToAddresses(toAddress);
        mail.setSubject('Dunning Letter Links'); 
        System.debug('inside mail function^^^');  
        mail.SetHTMLBody(body);
        Messaging.SendEmail(new Messaging.SingleEmailMessage[] { mail });
                       
    }   
}