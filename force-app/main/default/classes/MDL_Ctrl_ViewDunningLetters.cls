public with sharing class MDL_Ctrl_ViewDunningLetters {
	public String Doc_Id {get;set;}
	
	public MDL_Ctrl_ViewDunningLetters(){
		
		Date TimeStamp;
		if(ApexPages.currentPage().getParameters().get('Id')  != null){
            Doc_Id = ApexPages.currentPage().getParameters().get('Id') + '';
        }                       
	}
}