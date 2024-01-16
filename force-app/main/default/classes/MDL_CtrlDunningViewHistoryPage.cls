public with sharing class MDL_CtrlDunningViewHistoryPage {
	public Set<Date> docDateList;	
	public Map<Date,String> mapDocDateNString;
	public String selectedDate{get;set;}
	public List<Document> docList{get;set;}
	public Map<String,String> mapDocIdAndDocName{get;set;}
	public String docFolderId{get;set;}
	public List<Document> docListSorted{get;set;}
	public String todayDate{get;set;}
	public MDL_CtrlDunningViewHistoryPage(){
		Date pastDate = Date.Today().addMonths(-3).toStartOfMonth();
		mapDocDateNString = new Map<Date,String>();		
		docDateList = new Set<Date>();
		docList = new List<Document>();
		String docDateString;
		todayDate = '%'+String.valueOf(Date.Today())+'%';
		mapDocIdAndDocName = new Map<String,String>();
		for(Folder documtFolder : [Select Id from Folder where Name like '%Dunning%Documents%' limit 1]){
        	docFolderId = documtFolder.Id;
        }		
		for(Document doc : [Select Id,Name,CreatedDate from Document where FolderId = :docFolderId and CreatedDate > :pastDate]){
			docDateString = doc.Name.subString(doc.Name.lastIndexOf('_')+1,doc.Name.lastIndexOf('.'));
			docDateList.add(Date.valueOf(docDateString));
		}
		for(Date d : docDateList){
			mapDocDateNString.put(d,convertDateToUSAFormat(d));
		}
		System.debug('***'+mapDocDateNString);
	}
	public List<SelectOption> getDateStrings(){
		List<SelectOption> dateStrngs = new List<SelectOption>();
        dateStrngs.add(new SelectOption('','--None--'));
        for(Date d : mapDocDateNString.keyset()){
        	dateStrngs.add(new SelectOption(String.valueOf(d),mapDocDateNString.get(d)));
        }
        System.debug('*****'+dateStrngs);
        dateStrngs.sort();
        System.debug('<><>*****'+dateStrngs);
        return dateStrngs;
	}
	public PageReference viewDunningLetters(){
		docList = new List<Document>();
		docListSorted = new List<Document>();
		mapDocIdAndDocName = new Map<String,String>();
		if(selectedDate==null || selectedDate==''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Please select a date to view Dunning Letters generated on that date'));
			return null;
		}		
		//Date createdDt = Date.valueOf(selectedDate);
		String displayDt = '%'+selectedDate+'%';		
		for(Document doc : [Select Id,Name from Document where FolderId = :docFolderId and Name like :displayDt]){
			docList.add(doc);
		}
		for(Document doc : docList){
			docListSorted.add(doc);
		}
		for(Integer i = 0; i<docListSorted.size()-1;i++){
			for(Integer j=i+1;j<docListSorted.size();j++){
				if(Integer.valueOf(docListSorted[i].Name.subString(docListSorted[i].Name.indexOf('(')+1,docListSorted[i].Name.indexOf('-'))) > Integer.valueOf(docListSorted[j].Name.subString(docListSorted[j].Name.indexOf('(')+1,docListSorted[j].Name.indexOf('-')))){
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
	public PageReference downloadDoc(){
		String docId = Apexpages.currentPage().getParameters().get('docId');  
		PageReference pf = new Pagereference('/servlet/servlet.FileDownload?file='+docId);    
        return pf;
	}
	//Convert the given date to the US Format , eg. January 1, 2014
    public String convertDateToUSAFormat(Date d){        
	    Integer getday = d.day();
	    Integer getmonth = d.month();
	    Integer getyear = d.year();
	    
	    String formattedString;
	    
	    system.debug('day - ' + getday + ' month - ' + getmonth + ' year - ' + getyear);
	    Map<Integer,String> monthMap = new Map<Integer,String>();
	    monthMap.put(1,'January');
	    monthMap.put(2,'February');
	    monthMap.put(3,'March');
	    monthMap.put(4,'April');
	    monthMap.put(5,'May');
	    monthMap.put(6,'June');
	    monthMap.put(7,'July');
	    monthMap.put(8,'August');
	    monthMap.put(9,'September');
	    monthMap.put(10,'October');
	    monthMap.put(11,'November');
	    monthMap.put(12,'December');
	    
	    if(monthMap.containsKey(getMonth))
	        formattedString = monthMap.get(getmonth) + ' ' + getday + ', ' + getyear;
	    return formattedString;         
    }  
}